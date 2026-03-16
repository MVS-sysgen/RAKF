#!/usr/bin/env python3
"""
gen_upload.py  -  Generate a JCL job to upload and assemble RAKF source files
                  on an MVS 3.8j mainframe.

Usage:
    python3 gen_upload.py [options] > upload.jcl
    python3 gen_upload.py --only ICHSFR00 > upload.jcl
    python3 gen_upload.py --changes > upload.jcl
    python3 gen_upload.py --submit            # send directly to card reader

Libraries are auto-discovered from subdirectories of this script's location.
Dataset names are derived as: HLQ.DIRNAME  (e.g. RAKF.MACLIB)

Upload behaviour:
  Full reload (no --only):
    IDCAMS deletes every target PDS, IEFBR14 re-allocates them, PDSLOAD loads all.
  Partial reload (--only MEMBER):
    MACLIB is still fully deleted/reallocated/reloaded (assembly needs current macros).
    The library containing MEMBER is loaded with PDSLOAD DISP=SHR (member replace).
    NOTE: target PDSes must already exist. Run without --only for initial setup.

Assembly behaviour:
  Default (no --changes, no --only):
    Assemble and link every module defined in MODULES.
  --changes:
    Only assemble modules whose source files have uncommitted git changes.
  --only MEMBER:
    Only assemble modules that include MEMBER in their source list.
  --changes + --only:
    Intersection of the above two.

SPF statistics are derived from filesystem timestamps:
  - Creation date  : file birth time (macOS) or mtime fallback
  - Modify date/time: file mtime
  - SIZE / INIT    : line count of the file
"""

from __future__ import annotations

import argparse
import datetime
import socket
import subprocess
import sys
from dataclasses import dataclass, field as dc_field
from pathlib import Path

# ---------------------------------------------------------------------------
# Configuration — edit these to suit your site
# ---------------------------------------------------------------------------

JOB_ACCOUNT  = "1"
JOB_TITLE    = "LOAD RAKF"
JOB_CLASS    = "A"
MSGLEVEL     = "(1,1)"

DEFAULT_HLQ      = "RAKF"          # high-level qualifier for all target datasets
STEPLIB_DSN      = "SYSC.LINKLIB"  # PDS containing the PDSLOAD load module
DLM              = "@@"            # DD DATA inline delimiter (must not appear in source)
LRECL            = 80

DEFAULT_USERID   = "IBMUSER"
DEFAULT_PASSWORD = "SYS1"
CARD_HOST        = "localhost"
CARD_PORT        = 3505

# Subdirectories to skip during auto-discovery (not PDS-style libraries)
SKIP_DIRS = frozenset({"TEMPLATES", "AUX", "JCLIN", "USERMODS", "TOOLS"})

# Libraries always fully reloaded (delete+alloc+load) even with --only,
# because they contain macros required by the assembler.
ALWAYS_FULL_UPLOAD = frozenset({"MACLIB"})

BASE_DIR = Path(__file__).parent

# ---------------------------------------------------------------------------
# Module definitions  (derived from JCLIN/TRKF126.jcl)
# ---------------------------------------------------------------------------

@dataclass
class Module:
    """One assembled+linked load module."""
    name: str           # load module name (also used as the link step name)
    sources: list       # SRCLIB member names, in link order
    asm_steps: list     # ASM step name for each source (parallel to sources)
    entry: str          # ENTRY linker directive
    target: str         # destination PDS (SYS1.LINKLIB or SYS1.LPALIB)
    link_parm: str      # IEWL PARM= string
    aliases: list = dc_field(default_factory=list)  # ALIAS linker directives

#                name        sources                            asm step names                entry        target           link parm
MODULES = [
    Module("ICHSEC00", ["ICHSEC00", "CJYRCVT"],           ["ASMSEC",  "ASMRCVT"],  "ICHSEC00", "SYS1.LINKLIB", "MAP,LIST,LET,NCAL,AC=1"),
    Module("RAKFUSER", ["RAKFUSER", "RAKFPSAV"],           ["ASMUSER", "ASMPSAV"],  "CJYRUIDS", "SYS1.LINKLIB", "MAP,LIST,LET,NCAL,AC=1"),
    Module("RAKFPROF", ["RAKFPROF"],                       ["ASMPROF"],             "CJYRPROF", "SYS1.LINKLIB", "MAP,LIST,LET,NCAL,AC=1"),
    Module("RAKFPWUP", ["RAKFPWUP"],                       ["ASMPWUP"],             "RAKFPWUP", "SYS1.LINKLIB", "MAP,LIST,LET,NCAL,AC=1"),
    Module("ICHSFR00", ["ICHSFR00"],                       ["ASMSFR"],              "ICHSFR00", "SYS1.LPALIB",  "MAP,LIST,NCAL,LET,RENT,REFR,REUS,AC=1"),
    Module("ICHRIN00", ["ICHRIN00", "IGC00130", "IGC0013A", "IGC0013C"],
                       ["ASMRIN",  "ASM130",   "ASM13A",   "ASM13C"],
                       "ICHRIN00", "SYS1.LPALIB",  "MAP,LIST,NCAL,LET,RENT,REFR,REUS,AC=1",
                       aliases=["IGC0013{", "IGC0013A", "IGC0013B", "IGC0013C"]),
    Module("RACIND",   ["RACIND"],                         ["ASMIND"],              "RACIND",   "SYS1.LINKLIB", "MAP,LIST,LET,NCAL,AC=1"),
]

# ---------------------------------------------------------------------------
# Library discovery
# ---------------------------------------------------------------------------

def discover_libraries(hlq: str = DEFAULT_HLQ) -> list[tuple[str, str]]:
    """
    Scan BASE_DIR for PDS-like subdirectories and return
    (local_dir_name, mainframe_dsn) pairs, sorted alphabetically.

    A directory is included if:
      - It is not hidden and not in SKIP_DIRS
      - It contains no subdirectories (flat PDS structure)
      - It is non-empty
      - Its uppercased name is a valid MVS dataset qualifier
        (no leading digit, 8 chars max)
    """
    result = []
    for d in sorted(BASE_DIR.iterdir()):
        if not d.is_dir() or d.name.startswith("."):
            continue
        if d.name.upper() in SKIP_DIRS:
            continue

        children = list(d.iterdir())
        if any(c.is_dir() and not c.name.startswith(".") for c in children):
            continue
        if not children:
            continue

        qual = d.name.upper()

        if len(qual) > 8:
            print(
                f"WARNING: '{d.name}' name exceeds 8 chars, "
                f"truncating DSN qualifier to '{qual[:8]}'",
                file=sys.stderr,
            )
            qual = qual[:8]

        if qual[0].isdigit():
            print(
                f"WARNING: skipping '{d.name}' — "
                "DSN qualifier cannot start with a digit",
                file=sys.stderr,
            )
            continue

        result.append((d.name, f"{hlq}.{qual}"))

    return result


# ---------------------------------------------------------------------------
# Git change detection
# ---------------------------------------------------------------------------

def get_changed_srclib_members() -> set:
    """
    Return the uppercased member name (stem) of every SRCLIB file that has
    uncommitted changes (staged, unstaged, or untracked) according to git.
    """
    try:
        result = subprocess.run(
            ["git", "status", "--porcelain"],
            capture_output=True, text=True, cwd=BASE_DIR, timeout=10,
        )
    except FileNotFoundError:
        print("WARNING: git not found — --changes has no effect", file=sys.stderr)
        return set()
    except subprocess.TimeoutExpired:
        print("WARNING: git status timed out — --changes has no effect", file=sys.stderr)
        return set()

    changed = set()
    for line in result.stdout.splitlines():
        if len(line) < 4:
            continue
        xy = line[:2]
        if not xy.strip():          # "  " means unmodified — skip
            continue
        filepath_str = line[3:].strip()
        # Renamed files are shown as "old -> new"; take the new path
        if " -> " in filepath_str:
            filepath_str = filepath_str.split(" -> ")[-1]
        filepath = Path(filepath_str)
        # Only care about SRCLIB files (case-insensitive directory match)
        if filepath.parts and filepath.parts[0].upper() == "SRCLIB":
            changed.add(filepath.stem.upper())

    return changed


def select_modules(
    changes_only: bool,
    member_filter: str | None,
) -> list[Module]:
    """
    Return the subset of MODULES to assemble/link.

    changes_only  → only modules with at least one changed source file
    member_filter → only modules that include this SRCLIB member
    Both          → intersection
    Neither       → all modules
    """
    modules = list(MODULES)

    if member_filter:
        modules = [m for m in modules if member_filter in m.sources]

    if changes_only:
        changed = get_changed_srclib_members()
        if not changed:
            print("INFO: no changed SRCLIB files detected — nothing to assemble",
                  file=sys.stderr)
            return []
        print(f"INFO: changed SRCLIB members: {sorted(changed)}", file=sys.stderr)
        modules = [m for m in modules if any(s.upper() in changed for s in m.sources)]

    if not modules and (changes_only or member_filter):
        print("INFO: no modules match the filter criteria — skipping assembly",
              file=sys.stderr)

    return modules


# ---------------------------------------------------------------------------
# SPF statistics
# ---------------------------------------------------------------------------

def _yyddd(dt: datetime.datetime) -> str:
    """Format datetime as YYDDD (2-digit year + 3-digit julian day)."""
    return f"{dt.year % 100:02d}{dt.timetuple().tm_yday:03d}"


def spf_stats(path: Path, line_count: int, userid: str) -> str:
    """
    Build the 50-char SPF statistics field used in ./ ADD statements.

    Layout (cols 22-71 of the ADD record):
      VVMM-YYDDD-YYDDD-HHMM-NNNNN-NNNNN-NNNNN-UUUUUUUUUU
      VV    = version (01 for fresh load)
      MM    = mod level (00)
      YYDDD = creation date  (file birth time, or mtime if unavailable)
      YYDDD = last-modify date (file mtime)
      HHMM  = last-modify time (file mtime HH:MM)
      NNNNN = current size in lines
      NNNNN = initial size (same as current for fresh load)
      NNNNN = lines modified since initial (00000)
      UUUU  = userid, max 8 chars
    """
    stat = path.stat()
    ctime = getattr(stat, "st_birthtime", stat.st_mtime)
    create_dt = datetime.datetime.fromtimestamp(ctime)
    modify_dt = datetime.datetime.fromtimestamp(stat.st_mtime)
    uid = userid[:8].strip()

    return (
        f"0100"
        f"-{_yyddd(create_dt)}"
        f"-{_yyddd(modify_dt)}"
        f"-{modify_dt.hour:02d}{modify_dt.minute:02d}"
        f"-{line_count:05d}"
        f"-{line_count:05d}"
        f"-00000"
        f"-{uid}"
    )


# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

def member_name(path: Path) -> str:
    """PDS member name: stem uppercased, max 8 chars."""
    return path.stem[:8].upper()


def pad_line(line: str) -> str:
    """Strip line ending and truncate to LRECL."""
    return line.rstrip("\r\n")[:LRECL]


def check_delimiter(raw_lines: list, filename: Path) -> None:
    """Warn if the DLM token appears alone on a line."""
    for i, line in enumerate(raw_lines, 1):
        if line.rstrip("\r\n").rstrip() == DLM:
            print(
                f"WARNING: delimiter '{DLM}' found in {filename} at line {i} — "
                "upload will be truncated!",
                file=sys.stderr,
            )


# ---------------------------------------------------------------------------
# JCL step generators — upload
# ---------------------------------------------------------------------------

def idcams_cleanup(dsns: list) -> list:
    """IDCAMS step: delete each DSN (PURGE), then reset condition codes."""
    out = [
        "//*",
        "//* Delete existing datasets before reload",
        "//*",
        "//CLEANUP  EXEC PGM=IDCAMS",
        "//SYSPRINT DD  SYSOUT=*",
        "//SYSIN    DD  *",
    ]
    for dsn in dsns:
        out.append(f"  DELETE '{dsn}' PURGE")
    out += [
        "  SET MAXCC=0",
        "  SET LASTCC=0",
        "/*",
    ]
    return out


def iefbr14_alloc(lib_specs: list) -> list:
    """IEFBR14 step: allocate a fresh PDS for each (local_dir, dsn) pair."""
    out = [
        "//*",
        "//* Allocate fresh PDSes",
        "//*",
        "//ALLOC    EXEC PGM=IEFBR14",
    ]
    for local_dir, dsn in lib_specs:
        ddname = Path(local_dir).name[:8].upper()
        out += [
            f"//{ddname:<8} DD  DSN={dsn},DISP=(NEW,CATLG),",
            f"//             UNIT=SYSDA,SPACE=(TRK,(10,5,20)),",
            f"//             DCB=(RECFM=FB,LRECL=80,BLKSIZE=3120,DSORG=PO)",
        ]
    return out


def pdsload_step(
    step_name: str,
    dsn: str,
    files: list,
    userid: str,
) -> list:
    """PDSLOAD step: load one or more members into a PDS."""
    out = [
        "//*",
        f"//* Load {dsn}",
        "//*",
        f"//{step_name:<8} EXEC PGM=PDSLOAD,PARM='SPF'",
        f"//STEPLIB  DD  DSN={STEPLIB_DSN},DISP=SHR",
        "//SYSPRINT DD  SYSOUT=*",
        f"//SYSUT2   DD  DSN={dsn},DISP=SHR",
        f"//SYSUT1   DD  DATA,DLM={DLM}",
    ]

    for path in files:
        name = member_name(path)
        raw_lines = path.read_text(errors="replace").splitlines()
        check_delimiter(raw_lines, path)
        stats = spf_stats(path, len(raw_lines), userid)
        out.append(f"./ ADD NAME={name:<8} {stats}")
        out.extend(pad_line(ln) for ln in raw_lines)

    out.append(DLM)
    return out


# ---------------------------------------------------------------------------
# JCL step generators — assembly and link
# ---------------------------------------------------------------------------

def build_steps(modules: list, hlq: str) -> list:
    """
    Generate IFOX00 assembly + IEWL link JCL for each module in `modules`.

    The &&OBJ temporary PDS is shared across all steps:
      - First ASM step  : DISP=(,PASS)   to create it
      - Subsequent ASM  : DISP=(OLD,PASS) to add members
      - Each LINK step  : DISP=(OLD,PASS) for SYSPUNCH (reads the obj PDS)
      - Very last usage : DISP=(OLD,DELETE) to clean up
    """
    if not modules:
        return []

    out = [
        "//*",
        "//* -------------------------------------------------------",
        "//* Assemble and link",
        "//* -------------------------------------------------------",
        "//*",
    ]

    # Collect all (step_lines, obj_syspunch_index) tuples so we can
    # fix up the last &&OBJ reference from PASS to DELETE at the end.
    all_steps: list[list] = []
    obj_syspunch_indices: list[tuple[int, int]] = []  # (step_idx, line_idx)
    obj_created = False

    for mod in modules:
        out += [
            f"//*",
            f"//* Module: {mod.name}  ->  {mod.target}",
            f"//*",
        ]

        # --- Assembly step(s) ---
        for src, step_name in zip(mod.sources, mod.asm_steps):
            if obj_created:
                obj_disp = f"DISP=(OLD,PASS),DSN=&&OBJ({src}),UNIT=SYSALLDA"
            else:
                obj_disp = f"DSN=&&OBJ({src}),DISP=(MOD,PASS),\n//             SPACE=(800,(2000,1000,10)),UNIT=SYSDA"
                obj_created = True

            step = [
                f"//{step_name:<8} EXEC PGM=IFOX00,PARM=(NOOBJ,DECK),COND=(0,NE)",
                f"//SYSLIB   DD  DISP=SHR,DSN=SYS1.MACLIB",
                f"//         DD  DISP=SHR,DSN=SYS1.AMODGEN",
                f"//         DD  DISP=SHR,DSN={hlq}.MACLIB",
                f"//SYSIN    DD  DISP=SHR,DSN={hlq}.SRCLIB({src})",
                f"//SYSUT1   DD    DSN=&&SYSUT1,UNIT=SYSDA,SPACE=(1700,(5600,500))",
                f"//SYSUT2   DD    DSN=&&SYSUT2,UNIT=SYSDA,SPACE=(1700,(1300,500))",
                f"//SYSUT3   DD    DSN=&&SYSUT3,UNIT=SYSDA,SPACE=(1700,(1300,500))",
                f"//SYSPUNCH DD  {obj_disp}",
                f"//SYSPRINT DD  SYSOUT=*",
            ]
            syspunch_idx = 5   # index of the SYSPUNCH line within `step`
            obj_syspunch_indices.append((len(all_steps), syspunch_idx))
            all_steps.append(step)

        # --- Link step ---
        link_step = [
            f"//{mod.name:<8} EXEC PGM=IEWL,",
            f"//  PARM='{mod.link_parm}',",
            f"//  COND=(0,NE)",
            f"//SYSPRINT DD  SYSOUT=*",
            f"//SYSLMOD  DD  DISP=SHR,DSN={mod.target}",
            f"//SYSPUNCH DD  DISP=(OLD,PASS),DSN=&&OBJ",
            f"//SYSUT1   DD  UNIT=SYSDA,SPACE=(CYL,(1,1))",
            f"//SYSLIN   DD  *",
        ]
        for src in mod.sources:
            link_step.append(f" INCLUDE SYSPUNCH({src})")
        for alias in mod.aliases:
            link_step.append(f" ALIAS   {alias}")
        link_step += [
            f" ENTRY   {mod.entry}",
            f" NAME    {mod.name}(R)",
            f"/*",
        ]
        syspunch_idx = 4   # index of the SYSPUNCH line within link_step
        obj_syspunch_indices.append((len(all_steps), syspunch_idx))
        all_steps.append(link_step)

    # Fix up the very last &&OBJ reference: PASS → DELETE
    if obj_syspunch_indices:
        last_step_idx, last_line_idx = obj_syspunch_indices[-1]
        line = all_steps[last_step_idx][last_line_idx]
        all_steps[last_step_idx][last_line_idx] = line.replace(
            "OLD,PASS", "OLD,DELETE"
        )

    for step in all_steps:
        out.extend(step)

    return out


# ---------------------------------------------------------------------------
# Load plan
# ---------------------------------------------------------------------------

def build_load_plan(
    all_libs: list,
    member_filter: str | None,
) -> list:
    """
    Return (local_dir, dsn, files, is_full_reload) tuples.

    is_full_reload=True  → delete + alloc + full PDSLOAD
    is_full_reload=False → PDSLOAD DISP=SHR member-replace only
    """
    plan = []
    member_found = False

    for local_dir, dsn in all_libs:
        dir_path = BASE_DIR / local_dir
        all_files = sorted(
            f for f in dir_path.glob("*")
            if f.is_file() and not f.name.startswith(".")
        )
        if not all_files:
            print(f"WARNING: {local_dir}/ is empty, skipping", file=sys.stderr)
            continue

        if member_filter is None:
            plan.append((local_dir, dsn, all_files, True))

        elif local_dir.upper() in ALWAYS_FULL_UPLOAD:
            plan.append((local_dir, dsn, all_files, True))

        else:
            matching = [f for f in all_files if f.stem.upper() == member_filter]
            if matching:
                member_found = True
                plan.append((local_dir, dsn, matching, False))

    if member_filter and not member_found:
        print(
            f"WARNING: member '{member_filter}' was not found in any library",
            file=sys.stderr,
        )

    return plan


# ---------------------------------------------------------------------------
# Top-level generator
# ---------------------------------------------------------------------------

def generate(
    jobname: str,
    libs_filter: list,
    member_filter: str | None,
    userid: str,
    password: str,
    hlq: str = DEFAULT_HLQ,
    changes_only: bool = False,
) -> str:
    # Discover library directories
    all_libs = discover_libraries(hlq)

    # Apply --libs filter; with --only, always keep ALWAYS_FULL_UPLOAD
    if libs_filter:
        libs_upper = {l.upper() for l in libs_filter}
        kept = [(d, dsn) for d, dsn in all_libs if d.upper() in libs_upper]

        if member_filter:
            kept_upper = {d.upper() for d, _ in kept}
            for d, dsn in all_libs:
                if d.upper() in ALWAYS_FULL_UPLOAD and d.upper() not in kept_upper:
                    kept.append((d, dsn))
                    print(f"INFO: adding {d} — required for assembly", file=sys.stderr)
        all_libs = sorted(kept, key=lambda x: x[0])

    if not all_libs:
        print("ERROR: no libraries found to process", file=sys.stderr)
        sys.exit(1)

    plan = build_load_plan(all_libs, member_filter)
    if not plan:
        print("ERROR: nothing to upload", file=sys.stderr)
        sys.exit(1)

    full_reload = [(d, dsn) for d, dsn, _, is_full in plan if is_full]

    lines = [
        f"//{jobname:<8} JOB {JOB_ACCOUNT},'{JOB_TITLE}',"
        f"CLASS={JOB_CLASS},MSGLEVEL={MSGLEVEL},",
        f"// USER={userid},PASSWORD={password}",
    ]

    if full_reload:
        lines.extend(idcams_cleanup([dsn for _, dsn in full_reload]))
        lines.extend(iefbr14_alloc(full_reload))

    for i, (_, dsn, files, _) in enumerate(plan, 1):
        lines.extend(pdsload_step(f"LOAD{i:04d}", dsn, files, userid))

    modules = select_modules(changes_only, member_filter)
    lines.extend(build_steps(modules, hlq))

    return "\n".join(lines) + "\n"


# ---------------------------------------------------------------------------
# Submission
# ---------------------------------------------------------------------------

def submit_to_reader(jcl: str, host: str, port: int) -> None:
    """Send JCL bytes to the Hercules card reader via a TCP socket."""
    data = jcl.encode("ascii", errors="replace")
    with socket.create_connection((host, port), timeout=10) as s:
        s.sendall(data)
    print(f"Submitted {len(data)} bytes to {host}:{port}", file=sys.stderr)


# ---------------------------------------------------------------------------
# Entry point
# ---------------------------------------------------------------------------

def main() -> None:
    discovered = discover_libraries()
    lib_names = [d for d, _ in discovered]

    parser = argparse.ArgumentParser(
        description=__doc__,
        formatter_class=argparse.RawDescriptionHelpFormatter,
    )
    parser.add_argument(
        "--only", metavar="MEMBER", type=str.upper,
        help=(
            "Upload only this member (MACLIB always fully reloaded). "
            "Assembly is restricted to modules that include this member."
        ),
    )
    parser.add_argument(
        "--changes", action="store_true",
        help="Only assemble modules whose source files have uncommitted git changes.",
    )
    parser.add_argument(
        "--libs", metavar="LIB", nargs="+",
        help=f"Limit upload to these libraries (default: all). Discovered: {lib_names}",
    )
    parser.add_argument(
        "--jobname", metavar="NAME", default="RAKFLOAD",
        help="JCL job name, max 8 chars (default: RAKFLOAD)",
    )
    parser.add_argument(
        "--userid", metavar="ID", default=DEFAULT_USERID,
        help=f"Mainframe user ID (default: {DEFAULT_USERID})",
    )
    parser.add_argument(
        "--password", metavar="PASS", default=DEFAULT_PASSWORD,
        help=f"Mainframe password (default: {DEFAULT_PASSWORD})",
    )
    parser.add_argument(
        "--hlq", metavar="HLQ", default=DEFAULT_HLQ,
        help=f"High-level qualifier for target datasets (default: {DEFAULT_HLQ})",
    )
    parser.add_argument(
        "-o", "--output", metavar="FILE",
        help="Write JCL to FILE instead of stdout",
    )
    parser.add_argument(
        "--submit", action="store_true",
        help=f"Send JCL directly to card reader at {CARD_HOST}:{CARD_PORT}",
    )
    parser.add_argument(
        "--host", default=CARD_HOST,
        help=f"Card reader host (default: {CARD_HOST})",
    )
    parser.add_argument(
        "--port", type=int, default=CARD_PORT,
        help=f"Card reader port (default: {CARD_PORT})",
    )
    args = parser.parse_args()

    jobname = args.jobname[:8].upper()
    jcl = generate(
        jobname,
        args.libs or [],
        args.only,
        args.userid,
        args.password,
        args.hlq,
        args.changes,
    )

    if args.submit:
        submit_to_reader(jcl, args.host, args.port)
    elif args.output:
        Path(args.output).write_text(jcl)
        print(f"Written to {args.output}", file=sys.stderr)
    else:
        sys.stdout.write(jcl)


if __name__ == "__main__":
    main()
