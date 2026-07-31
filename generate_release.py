#!/usr/bin/env python3
#
# Generate the RAKF install job stream.
#
# The RAKF core (HLASM modules, procs, macros) ships as SMP source that MVS
# assembles/link-edits on-target -- pure text.  The administration tools
# ADDUSER/ALTUSER are cc370-built C *load modules* that cannot be assembled
# on MVS, so they are delivered here as an inline TSO XMIT: the whole stream
# is emitted as EBCDIC card images and the XMIT's raw bytes are embedded
# after a `DD DATA,DLM=` card, installed on-target with RECEIVE + IEBCOPY.
#
# Because the file now contains raw binary, submit it through the EBCDIC
# pass-through reader (device 001A / port 3506), NOT the ASCII reader 3505:
#     cat install_rakf.jcl | ncat --send-only -w1 127.0.0.1 3506
#
import os
import sys
import glob
import hashlib
import argparse

arg_parser = argparse.ArgumentParser()
arg_parser.add_argument('-u', '--users', help="Custom users file", default=False)
arg_parser.add_argument('-p', '--profiles', help="Custom profiles file", default=False)
arg_parser.add_argument('-x', '--xmit', default=None,
                        help="TSO XMIT of the admin tools (default: newest APPLICATIONS/dist/*.xmit)")
arg_parser.add_argument('-o', '--output', default=None,
                        help="Output file (binary EBCDIC card images). Default: stdout.")
arg_parser.add_argument('--cmdlib', default="SYS2.CMDLIB",
                        help="Target load library for ADDUSER/ALTUSER")
arg_parser.add_argument('--volume', default="PUB000",
                        help="DASD volume for the transient staging datasets")
arg_parser.add_argument('--codepage', default="cp037",
                        help="EBCDIC codepage for card images (cp037 or cp1047)")
arg_parser.add_argument('--no-tools', action="store_true",
                        help="Emit the RAKF core only, without the admin tools")
arg_parser.add_argument('--recv370', action="store_true",
                        help="Unpack the admin-tool XMIT with RECV370 (SYSC.LINKLIB) "
                             "instead of TSO RECEIVE. Needed when RAKF is installed "
                             "during a sysgen, before the TSO XMIT facility exists.")
args = arg_parser.parse_args()

running_folder = os.path.dirname(os.path.abspath(__file__))

# ------------------------------------------------------------------ #
#  Output is a byte stream of 80-column EBCDIC card images.          #
# ------------------------------------------------------------------ #
OUT = bytearray()
CP = args.codepage


def emit(line=''):
    """Append one line as an 80-column EBCDIC card image."""
    OUT.extend("{:80}".format(line).encode(CP))


def emit_text(text):
    """Append a (multi-line) text block, one card image per line."""
    for l in text.split('\n'):
        emit(l.rstrip())


steps = []


def check_step(line, jcl_filename):
    if (' EXEC ' in line and
        line.split()[1] == 'EXEC'):
        step_name = line.split()[0][2:]
        if step_name not in steps:
            steps.append(step_name)
        else:
            raise ValueError("Duplicate Step Name {} (from {}) Already exists".format(step_name, jcl_filename))


def read_file(filename):
    emit("//*" + "*" * 66)
    emit("//* {}".format("/".join(filename.split("/")[-2:])))
    emit("//*" + "*" * 66)
    with open(filename, 'r') as f:
        jobcard = True
        for l in f.readlines():
            if l.strip() == "//":
                continue
            if not l.strip():
                continue
            if jobcard:
                if l.strip()[-1] == ",":
                    continue
                else:
                    jobcard = False
                    continue
            emit(l.rstrip())
            check_step(l, filename)


def _data_file(arg, default):
    """Resolve a users/profiles file path (relative paths are under the repo)."""
    fn = arg if arg else default
    return fn if os.path.isabs(fn) else os.path.join(running_folder, fn)


# ------------------------------------------------------------------ #
#  Initial credentials: blank the USERS passwords, hash into a shadow #
# ------------------------------------------------------------------ #
#  Field offsets in a USERS record (0-based), per RAKFUSER's DSECT:    #
#    0-7 userid   8 dflt-flag   9-16 group   17 rsvd   18-25 password  #
def build_credentials(users_text):
    """From the raw users file produce (1) a USERS table with the password
    column blanked and (2) the raw shadow-file bytes: for each distinct userid,
    userid(8) + 8-byte salt + SHA-256(salt || UPPER(password)) — the exact
    layout RAKFPWH/ICHSFR00 verify against (validated byte-for-byte)."""
    blanked, shadow, seen = [], bytearray(), set()
    for line in users_text.split('\n'):
        s = line.strip()
        # Blank and comment lines are DROPPED, not preserved. What this
        # builds is not a text file -- it is spliced into the USERS member
        # and read positionally by RAKFUSER, which rejects any record whose
        # userid field is blank:
        #     RAKFUIDS2  INPUT DATA INVALID OR OUT OF SEQ.
        #     RAKFUIDSX  ** PROGRAM TERMINATED **
        # and then terminates, leaving the system with no users at all. A
        # comment line has no group or password field either, so it is just
        # as invalid as a blank one. Note split('\n') yields a trailing empty
        # element for any file ending in a newline, so keeping blanks breaks
        # every normally-terminated users file (this repo's own users.txt has
        # no trailing newline, which is why it never showed up here).
        if not s or s.startswith('*'):
            continue
        p = line.ljust(80)
        userid = p[0:8].rstrip()
        password = p[18:26].strip()
        blanked.append((p[:18] + ' ' * 8 + p[26:]).rstrip())   # cols 19-26 blanked
        if userid and password and userid not in seen:
            seen.add(userid)
            salt = os.urandom(8)
            digest = hashlib.sha256(salt + password.upper().encode('cp037')).digest()
            shadow += userid.ljust(8).encode('cp037') + salt + digest   # 48 bytes
    return '\n'.join(blanked), bytes(shadow)


SHADOW_LOAD = """//RAKFSHAD JOB (SYSGEN),'LOAD SHADOW',
//             CLASS=A,
//             MSGCLASS=A,
//             MSGLEVEL=(1,1),
//             USER=IBMUSER,PASSWORD=SYS1
//*******************************************************************
//* Populate SYS1.SECURE.SHADOW with the salted SHA-256 password
//* hashes (computed at release-generation time).  The 48-byte
//* records are shipped padded to 80-byte cards through the EBCDIC
//* reader; IEBGENER trims each back to LRECL 48 on the way in.
//*******************************************************************
//SHADLOAD EXEC PGM=IEBGENER
//SYSPRINT DD SYSOUT=*
//SYSUT2   DD DSN=SYS1.SECURE.SHADOW,DISP=SHR
//SYSUT1   DD DATA,DLM='{dlm}'"""

SHADOW_LOAD_SYSIN = """//SYSIN    DD *
  GENERATE MAXFLDS=1
  RECORD FIELD=(48,1,,1)"""


def emit_shadow_load(shadow):
    """Emit a job that loads the (host-computed) shadow records into
    SYS1.SECURE.SHADOW.  The FB48 records don't align to 80-byte cards, so each
    is padded to 80 for transport and IEBGENER's RECORD FIELD trims it to 48."""
    if not shadow:
        sys.stderr.write("[gen] no passwords in the users file; skipping shadow load\n")
        return
    cards = bytearray()
    for i in range(0, len(shadow), 48):
        cards += shadow[i:i+48] + b'\x00' * 32       # 48 data + 32 filler = one card
    dlm = pick_dlm(bytes(cards))
    sys.stderr.write("[gen] shadow: {} user(s), {} bytes (DLM={})\n"
                     .format(len(shadow) // 48, len(shadow), dlm))
    emit_text(SHADOW_LOAD.format(dlm=dlm))
    OUT.extend(cards)          # raw binary, 80-byte cards
    emit(dlm)
    emit_text(SHADOW_LOAD_SYSIN)


def emit_rakfcust(filename, inserts):
    """Emit RAKFCUST.jcl into the stream, splicing `inserts` (the blanked users
    table and the profiles table) into its first two `//SYSUT1 DD *` placeholders
    (the USERSIEB and PROFSIEB IEBGENER steps).  Later instream SYSUT1s -- e.g.
    the SORTREXX script -- are left untouched, and the source file is NOT
    modified (unlike the old in-place rewrite, which mis-matched every 'SYSUT1'
    and could corrupt the member)."""
    emit("//*" + "*" * 66)
    emit("//* {}".format("/".join(filename.split("/")[-2:])))
    emit("//*" + "*" * 66)
    with open(filename) as f:
        lines = f.read().split('\n')
    jobcard = True
    skipping = False          # dropping an old placeholder body up to its /*
    n = 0                     # number of placeholders filled so far
    for l in lines:
        if l.strip() == "//" or not l.strip():
            continue
        if jobcard:
            if l.strip().endswith(","):
                continue
            jobcard = False
            continue
        if skipping:
            if l.strip() == "/*":
                skipping = False
                emit(l.rstrip())
            continue
        emit(l.rstrip())
        check_step(l, filename)
        toks = l.split()
        if n < 2 and len(toks) >= 3 and toks[0] == "//SYSUT1" \
                and toks[1] == "DD" and toks[2] == "*":
            emit_text(inserts[n])     # splice users.txt / profiles.txt
            n += 1
            skipping = True


# ------------------------------------------------------------------ #
#  Inline the admin-tool XMIT (raw binary) into the stream.          #
# ------------------------------------------------------------------ #
def find_xmit():
    if args.xmit:
        return args.xmit
    cands = sorted(glob.glob(os.path.join(running_folder, "APPLICATIONS", "dist", "*.xmit")),
                   key=os.path.getmtime)
    if not cands:
        cands = sorted(glob.glob(os.path.join(running_folder, "APPLICATIONS", "build", "*.xmit")),
                       key=os.path.getmtime)
    return cands[-1] if cands else None


def pick_dlm(xmit_bytes):
    """Choose a 2-char delimiter whose EBCDIC bytes never start an 80-byte
    record of the XMIT (so DD DATA reads the whole binary intact)."""
    for cand in ("$$", "??", "@@", "##", "%%", "&&", "!!", "~~", "^^", "=="):
        b = cand.encode(CP)
        if not any(xmit_bytes[i:i+2] == b for i in range(0, len(xmit_bytes), 80)):
            return cand
    raise SystemExit("generate_release.py: could not find a collision-free DD DATA delimiter")


TOOLS_HEADER = """//RAKFTOOL JOB (SYSGEN),'INSTALL RAKF TOOLS',
//             CLASS=A,
//             MSGCLASS=A,
//             MSGLEVEL=(1,1),
//             USER=IBMUSER,PASSWORD=SYS1
//*******************************************************************
//* Install the cc370-built RAKF admin tools (ADDUSER, ALTUSER).
//* They are C load modules (cannot be assembled on MVS), shipped as
//* an inline TSO XMIT read by the EBCDIC card reader, then installed
//* with RECEIVE + IEBCOPY into {cmdlib}.
//*******************************************************************
//DELOLD  EXEC PGM=IDCAMS
//SYSPRINT DD SYSOUT=*
//SYSIN    DD *
  DELETE RAKF.TOOLS.XMIT    SCRATCH PURGE
  DELETE RAKF.TOOLS.LINKLIB SCRATCH PURGE
  SET MAXCC=0
//* --- stage the inline XMIT binary into an FB80 dataset -----------
//STAGE   EXEC PGM=IEBGENER
//SYSPRINT DD SYSOUT=*
//SYSIN    DD DUMMY
//SYSUT2   DD DSN=RAKF.TOOLS.XMIT,DISP=(,CATLG,DELETE),
//            UNIT=SYSDA,VOL=SER={vol},SPACE=(TRK,(200,50)),
//            DCB=(RECFM=FB,LRECL=80,BLKSIZE=3120)
//SYSUT1   DD DATA,DLM='{dlm}'"""

# The XMIT has to be unpacked into a load library before IEBCOPY can put the
# members into the command library. There are two ways to do that and which one
# works depends on when in a system's life RAKF is being installed:
#
#   TSO RECEIVE  the normal path on a finished system, but RECEIVE/TRANSMIT is
#                NOT part of base MVS 3.8J -- on MVS/CE it arrives with NJE38,
#                which needs MVP, which needs RAKF. Installing RAKF during a
#                sysgen therefore hits 'IKJ56500I COMMAND RECEIVE NOT FOUND'.
#
#   RECV370      a standalone unXMIT program in SYSC.LINKLIB, present from the
#                base sysgen onward (sysgen's own BREXX step uses it), so it
#                works before TSO RECEIVE exists. Selected with --recv370.
#
# RECEIVE self-allocates its output; RECV370 does not, so the RECV370 form has
# to allocate RAKF.TOOLS.LINKLIB itself. It is modelled on the command library
# with DCB={cmdlib} so the IEBCOPY that follows is a same-DCB copy.
TOOLS_RECV_TSO = """//* --- RECEIVE the XMIT into a transient load library -------------
//RECV    EXEC PGM=IKJEFT01,DYNAMNBR=50
//SYSTSPRT DD SYSOUT=*
//SYSTSIN  DD *
  RECEIVE INDSN('RAKF.TOOLS.XMIT') DATASET('RAKF.TOOLS.LINKLIB')"""

TOOLS_RECV_370 = """//* --- unXMIT into a transient load library with RECV370 ----------
//RECV    EXEC PGM=RECV370,REGION=4096K
//STEPLIB  DD DISP=SHR,DSN=SYSC.LINKLIB
//RECVLOG  DD SYSOUT=*
//XMITIN   DD DSN=RAKF.TOOLS.XMIT,DISP=SHR
//SYSPRINT DD SYSOUT=*
//SYSUT1   DD DSN=&&RECVWRK,UNIT=SYSDA,VOL=SER={vol},
//            SPACE=(CYL,(10,10)),DISP=(NEW,DELETE,DELETE)
//SYSUT2   DD DSN=RAKF.TOOLS.LINKLIB,DISP=(,CATLG,DELETE),
//            UNIT=SYSDA,VOL=SER={vol},SPACE=(CYL,(5,5,20),RLSE),
//            DCB={cmdlib}
//SYSIN    DD DUMMY"""

TOOLS_INSTALL = """//* --- copy the tool members into the command library ------------
//INSTALL EXEC PGM=IEBCOPY
//SYSPRINT DD SYSOUT=*
//IN       DD DSN=RAKF.TOOLS.LINKLIB,DISP=SHR
//OUT      DD DSN={cmdlib},DISP=SHR
//SYSIN    DD *
  COPY OUTDD=OUT,INDD=IN
//* --- clean up the staging datasets -----------------------------
//CLEANUP EXEC PGM=IDCAMS
//SYSPRINT DD SYSOUT=*
//SYSIN    DD *
  DELETE RAKF.TOOLS.XMIT    SCRATCH PURGE
  DELETE RAKF.TOOLS.LINKLIB SCRATCH PURGE
  SET MAXCC=0"""


def emit_tools():
    xmit_path = find_xmit()
    if not xmit_path or not os.path.isfile(xmit_path):
        sys.exit("generate_release.py: admin-tool XMIT not found. Build it first:\n"
                 "    cd APPLICATIONS && PATH=~/.local/bin:$PATH make package\n"
                 "or pass --xmit <path>.")
    with open(xmit_path, 'rb') as f:
        xmit = f.read()
    if len(xmit) % 80 != 0:
        sys.exit("generate_release.py: XMIT is not FB80 (len {} not a multiple of 80).".format(len(xmit)))
    dlm = pick_dlm(xmit)
    sys.stderr.write("[gen] embedding {} ({} bytes, DLM={})\n".format(xmit_path, len(xmit), dlm))
    emit_text(TOOLS_HEADER.format(cmdlib=args.cmdlib, vol=args.volume, dlm=dlm))
    OUT.extend(xmit)          # raw binary, already 80-byte card images
    emit(dlm)                 # delimiter card closes the DD DATA
    recv = TOOLS_RECV_370 if args.recv370 else TOOLS_RECV_TSO
    sys.stderr.write("[gen] unXMIT step: {}\n".format("RECV370" if args.recv370 else "TSO RECEIVE"))
    emit_text(recv.format(cmdlib=args.cmdlib, vol=args.volume))
    emit_text(TOOLS_INSTALL.format(cmdlib=args.cmdlib))


##################################################

with open(running_folder + "/TEMPLATES/01_header.template", 'r') as f:
    for l in f.readlines():
        emit(l.rstrip())
        check_step(l, "01_header.template")

with open(running_folder + "/JCLIN/TRKF126.jcl") as f:
    emit_text(f.read().rstrip())

smp_dict = {
        'MACLIB': "++MAC({}) DISTLIB(AMACLIB)  SYSLIB(MACLIB).",
        'SRCLIB': "++SRC({}) DISTLIB(ASRCLIB)  SYSLIB(SRCLIB).",
        'PROCLIB': "++MAC({}) DISTLIB(APROCLIB) SYSLIB(PROCLIB).",
        'PARMLIB': "++MAC({}) DISTLIB(APARMLIB) SYSLIB(PARMLIB)."
        }

folders = ["MACLIB", "SRCLIB", "PROCLIB", "PARMLIB"]

for folder in folders:
    fileList = os.listdir("{}/{}".format(running_folder, folder))
    for filename in fileList:
        emit(smp_dict[folder].format(filename.split(".")[0]))
        jfile = os.path.join('{}/{}/{}'.format(running_folder, folder, filename))
        with open(jfile, 'r') as f:
            emit_text(f.read().rstrip())

with open(running_folder + "/TEMPLATES/02_smp4.template", 'r') as f:
    for l in f.readlines():
        emit(l.rstrip())
        check_step(l, "02_smp4.template")

install = [
    'USERMODS/RAK0001.jcl',
    'USERMODS/ZJW0003.jcl',
    # ZJW0004 MACUPDs SGIEE0MS to add the //RAKFSHAD DD to MSTJCL00, which is
    # how RAKFUSER reaches SYS1.SECURE.SHADOW at IPL. It declares
    # PRE(ZJW0003), so it must stay after ZJW0003 or SMP/E rejects the APPLY.
    # Without it the OPEN fails with 'IEC130I RAKFSHAD DD STATEMENT MISSING',
    # no hashes load, and -- since build_credentials() blanks the USERS
    # password column -- every credential on the system becomes unverifiable.
    'USERMODS/ZJW0004.jcl',
    'TOOLS/RAKFCUST.jcl',
    'AUX/VTOC/vtoc.jcl',
    'AUX/CDSCB.jcl',
    'TOOLS/VSAMSRAC.jcl',
    'TOOLS/VTOCSRAC.jcl',
]

# ---- process the initial users: blank passwords, build the shadow --
_users_raw = open(_data_file(args.users, 'users.txt')).read()
_profiles = open(_data_file(args.profiles, 'profiles.txt')).read().strip()
blanked_users, shadow_bytes = build_credentials(_users_raw)

for jcl in install:
    path = running_folder + "/" + jcl
    if 'RAKFCUST' in jcl:
        emit_rakfcust(path, [blanked_users, _profiles])
    else:
        read_file(path)

# ---- populate the shadow file with the salted SHA-256 hashes -------
emit_shadow_load(shadow_bytes)

# ---- admin tools (inline binary XMIT) ------------------------------
if not args.no_tools:
    emit_tools()

emit("//* Steps in this job stream")
for i in steps:
    emit("//* {}".format(i))

# ------------------------------------------------------------------ #
#  Write the EBCDIC byte stream.                                     #
# ------------------------------------------------------------------ #
if args.output:
    with open(args.output, 'wb') as f:
        f.write(bytes(OUT))
    sys.stderr.write("[gen] wrote {} ({} bytes). Submit via the EBCDIC reader:\n"
                     "      cat {} | ncat --send-only -w1 127.0.0.1 3506\n"
                     .format(args.output, len(OUT), args.output))
else:
    sys.stdout.buffer.write(bytes(OUT))
    sys.stderr.write("[gen] wrote {} bytes to stdout. Submit the EBCDIC stream via port 3506.\n".format(len(OUT)))
