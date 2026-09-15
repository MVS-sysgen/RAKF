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
                        help="Target library for the ADDUSER/ALTUSER programs")
arg_parser.add_argument('--helplib', default="SYS2.HELP",
                        help="Target help library for the ADDUSER/ALTUSER HELP members")
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
arg_parser.add_argument('--shadow-recovery', action='store_true',
                        help="Emit only a standalone EBCDIC job that recreates and "
                             "populates the RAKF password shadow dataset from users.txt")
arg_parser.add_argument('--shadow-dsn', default="SYS1.SECURE.SHADOW",
                        help="Shadow dataset name for --shadow-recovery")
arg_parser.add_argument('--shadow-volume', default=None,
                        help="Optional VOL=SER for a newly recreated shadow dataset")
arg_parser.add_argument('--run-rakfuser', action='store_true',
                        help="After shadow recovery, EXEC the installed RAKFUSER procedure "
                             "to reload the in-core user table (otherwise IPL/reload later)")
RAKF_FUNCTION = 'TRKF200'
DEFAULT_UPGRADE_FROM = 'TRKF126'

arg_parser.add_argument('--upgrade', action='store_true',
                        help="Generate an in-place RAKF upgrade job instead of a fresh install. "
                             "Implied by --upgrade-from.")
arg_parser.add_argument('--upgrade-from', default=None, metavar='FMID',
                        help="Previous RAKF function FMID whose elements {} replaces. "
                             "Implies --upgrade (default: {} when --upgrade is given)."
                             .format(RAKF_FUNCTION, DEFAULT_UPGRADE_FROM))
args = arg_parser.parse_args()
if args.upgrade_from:
    args.upgrade = True
    args.upgrade_from = args.upgrade_from.upper()
elif args.upgrade:
    args.upgrade_from = DEFAULT_UPGRADE_FROM
else:
    args.upgrade_from = DEFAULT_UPGRADE_FROM

running_folder = os.path.dirname(os.path.abspath(__file__))

# ------------------------------------------------------------------ #
#  Output is a byte stream of 80-column EBCDIC card images.          #
# ------------------------------------------------------------------ #
OUT = bytearray()
CP = args.codepage


def emit(line=''):
    """Append one line as an 80-column EBCDIC card image.

    The reader consumes a fixed 80-byte record.  A single over-length line
    shifts every subsequent card by that extra byte, so JCL that used to
    start in column 1 (for example RECEIVER's //SMPCNTL) is no longer
    recognized.  Fail here rather than silently misalign the stream.
    """
    line = line.rstrip()
    if len(line) > 80:
        sys.exit('generate_release.py: card image exceeds 80 columns ({}):\n  {}'
                 .format(len(line), line))
    card = "{:80}".format(line).encode(CP)
    if len(card) != 80:
        sys.exit('generate_release.py: EBCDIC card is {} bytes, not 80:\n  {}'
                 .format(len(card), line))
    OUT.extend(card)


def emit_text(text):
    """Append a (multi-line) text block, one card image per line."""
    for l in text.split('\n'):
        emit(l.rstrip())


APPLY_GUARD = "(4,LT,APPLYR.HMASMP)"


def _exec_line(line):
    """True for a named JCL EXEC statement (not comments/continuations)."""
    if not line.startswith('//') or line.startswith('//*'):
        return False
    body = line[2:]
    return bool(body) and not body[0].isspace() and ' EXEC ' in line


def _exec_continuation(line):
    """True for a blank-name JCL continuation card such as // PARM=... ."""
    if not line.startswith('//') or line.startswith('//*'):
        return False
    body = line[2:]
    return bool(body) and body[0].isspace()


def _next_exec_continuation(lines, index):
    """Return True when the EXEC at index is followed by an active continuation.

    JCL comments and blank cards may occur between continuation cards, so ignore
    those while looking ahead. A named JCL statement ends the EXEC statement.
    """
    for j in range(index + 1, len(lines)):
        r = lines[j].rstrip()
        if not r or r.startswith('//*'):
            continue
        return _exec_continuation(r)
    return False


def _exec_has_cond(lines, index):
    """Check the EXEC card and its active continuation cards for COND=."""
    r = lines[index].rstrip()
    if 'COND=' in r.upper():
        return True

    for j in range(index + 1, len(lines)):
        s = lines[j].rstrip()
        if not s or s.startswith('//*'):
            continue
        if not _exec_continuation(s):
            break
        if 'COND=' in s.upper():
            return True
        # A continuation without a trailing comma completes the EXEC.
        if not s.endswith(','):
            break
    return False


def _split_exec_for_guard(line):
    """Make a noncontinued EXEC continuable without using column 72.

    MVS JCL's statement field ends at column 71.  If an EXEC already occupies
    all 71 columns, simply appending ',' puts the comma in column 72 and JES
    reports IEF618I.  Move the last top-level EXEC operand to a continuation
    card instead.

    Example:
      //ASMCDSCB EXEC PGM=IFOX00,REGION=2048K,PARM=(...)
    becomes:
      //ASMCDSCB EXEC PGM=IFOX00,REGION=2048K,
      //         PARM=(...),
    """
    line = line.rstrip()
    if line.endswith(','):
        return [line]

    # If there is room for a comma in the actual JCL statement field, use it.
    # Column 71 is the last usable character, so the existing line may be at
    # most 70 columns before the comma is appended.
    if len(line) <= 70:
        return [line + ',']

    # Find top-level commas (ignore commas inside quotes/parentheses) and move
    # the shortest possible final operand to a continuation card.
    comma_positions = []
    depth = 0
    quote = None
    for i, ch in enumerate(line):
        if quote:
            if ch == quote:
                quote = None
            continue
        if ch in ("'", '"'):
            quote = ch
        elif ch == '(':
            depth += 1
        elif ch == ')':
            if depth:
                depth -= 1
        elif ch == ',' and depth == 0:
            comma_positions.append(i)

    prefix = '//         '
    for pos in reversed(comma_positions):
        head = line[:pos + 1]
        tail = line[pos + 1:].strip()
        continuation = prefix + tail + ','
        if len(head) <= 71 and len(continuation) <= 71:
            return [head, continuation]

    sys.exit('generate_release.py: cannot safely add APPLY guard to EXEC '
             'within JCL columns 1-71:\n  {}'.format(line))


def emit_jcl_line(line, guard_apply=False, exec_continues=False,
                  existing_cond=False):
    """Emit one JCL line, optionally bypassing the step if core APPLY failed.

    When the original EXEC already has continuation cards, the inserted COND
    must itself end in a comma.  When there is no following continuation, COND
    closes the EXEC statement.  Full-width EXEC cards are split first so no
    continuation comma is ever placed in column 72.
    """
    line = line.rstrip()
    if (guard_apply and args.upgrade and _exec_line(line)
            and not existing_cond):
        if line.endswith(','):
            emit(line)
        else:
            for part in _split_exec_for_guard(line):
                emit(part)
        suffix = ',' if exec_continues else ''
        emit('//         COND={}{}'.format(APPLY_GUARD, suffix))
    else:
        emit(line)


def emit_guarded_lines(lines):
    """Emit JCL lines with an APPLY guard added safely to complete EXEC statements."""
    for i, l in enumerate(lines):
        r = l.rstrip()
        emit_jcl_line(
            r,
            guard_apply=True,
            exec_continues=_next_exec_continuation(lines, i) if _exec_line(r) else False,
            existing_cond=_exec_has_cond(lines, i) if _exec_line(r) else False,
        )


def emit_guarded_text(text):
    """Emit a post-APPLY JCL block with the upgrade APPLY guard on each step."""
    emit_guarded_lines(text.split('\n'))


steps = []


def check_step(line, jcl_filename):
    if (' EXEC ' in line and
        line.split()[1] == 'EXEC'):
        step_name = line.split()[0][2:]
        if step_name not in steps:
            steps.append(step_name)
        else:
            raise ValueError("Duplicate Step Name {} (from {}) Already exists".format(step_name, jcl_filename))


def read_file(filename, guard_apply=False):
    emit("//*" + "*" * 66)
    emit("//* {}".format("/".join(filename.split("/")[-2:])))
    emit("//*" + "*" * 66)
    with open(filename, 'r') as f:
        raw = f.readlines()

    jobcard = True
    lines = []
    for l in raw:
        if l.strip() == "//":
            continue
        if not l.strip():
            continue
        if jobcard:
            if l.strip()[-1] == ",":
                continue
            jobcard = False
            continue
        lines.append(l.rstrip())

    if guard_apply and args.upgrade:
        emit_guarded_lines(lines)
    else:
        for l in lines:
            emit(l)

    for l in lines:
        check_step(l, filename)


# VTOCSRAC's original REXX generates commands such as:
#   CDSCB 'dsn' VOL(vol) UNIT(SYSALLDA) SHR RACF
# RACINDVT feeds those records to IKJEFT01 through SYSTSIN.  Batch TSO uses
# only columns 1-72, so sufficiently long data set names lose the end of RACF
# (one observed command ended "... SHR R" and failed as "R AMBIGUOUS").
#
# The original generator also emits commands for data sets whose indicator is
# already in the requested state.  Besides wasting hundreds of CDSCB calls,
# that makes an otherwise-good run return RC 12 when an already-indicated data
# set happens to be allocated elsewhere.
#
# Keep the upstream VTOCSRAC scanner, but place its commands in an FB128 work
# data set.  A small BREXX filter then:
#   1. compares each command against the VTOC "DSNAME VOLUME RACF" report,
#   2. drops commands that would be a no-op, and
#   3. compacts commands to "CDSCB 'dsn' V(vol) SHR RACF".
#
# CDSCB's parser defines VOLUME and UNIT as separate optional top-level
# keywords.  "V(" is an unambiguous abbreviation of VOLUME at that level and,
# without UNIT(SYSALLDA), the longest legal 44-character MVS DSN produces a
# 71-character command -- safely inside the 72-column SYSTSIN command field.
VTOCSRAC_FILTER = r"""//*******************************************************************
//* Filter and compact CDSCB commands before batch TSO executes them.
//*******************************************************************
//CDSCBF  EXEC PGM=BREXX,PARM='RXRUN',REGION=8192K
//RXRUN   DD *
/* Filter/compact VTOCSRAC CDSCB commands for batch TSO */
address mvs
"EXECIO * DISKR STATDD (STEM ST. FINIS"
"EXECIO * DISKR CMDIN (STEM CM. FINIS"
n=0
skip=0
bad=0
do i=1 to cm.0
  cmd=strip(cm.i)
  if left(cmd,6)<>'CDSCB' then iterate
  q1=pos("'",cmd)
  q2=pos("'",cmd,q1+1)
  vp=pos('VOL(',cmd)
  ve=pos(')',cmd,vp+4)
  if q1=0 | q2=0 | vp=0 | ve=0 then do
    say '*** BAD CDSCB COMMAND:' cmd
    bad=bad+1
    iterate
  end
  dsn=substr(cmd,q1+1,q2-q1-1)
  vol=substr(cmd,vp+4,ve-vp-4)
  action=translate(word(cmd,words(cmd)))
  cur=''
  do j=1 to st.0
    sdsn=strip(substr(st.j,1,44))
    svol=strip(substr(st.j,46,6))
    sind=strip(substr(st.j,55,1))
    if sdsn=dsn & svol=vol then do
      if sind='Y' | sind='N' then cur=sind
      leave
    end
  end
  if action='RACF' & cur='Y' then do
    skip=skip+1
    iterate
  end
  if action='NORACF' & cur='N' then do
    skip=skip+1
    iterate
  end
  if action<>'RACF' & action<>'NORACF' then do
    say '*** BAD CDSCB ACTION:' cmd
    bad=bad+1
    iterate
  end
  short="CDSCB '"||dsn||"' V("||vol||") SHR "||action
  if length(short)>72 then do
    say '*** CDSCB COMMAND STILL TOO LONG:' short
    bad=bad+1
    iterate
  end
  n=n+1
  out.n=short
end
out.0=n
"EXECIO * DISKW CMDOUT (STEM OUT. FINIS"
say '*** VTOCSRAC:' n 'COMMANDS,' skip 'ALREADY CORRECT'
if bad>0 then do
  say '*** VTOCSRAC FILTER ERRORS:' bad
  exit 8
end
exit 0
/*
//RXLIB   DD DSN=BREXX.CURRENT.RXLIB,DISP=SHR
//STATDD  DD DSN=&&LISTCC,DISP=SHR
//CMDIN   DD DSN=&&CDRAW,DISP=(OLD,DELETE)
//CMDOUT  DD DSN=&&CDSCB,DISP=(,PASS),UNIT=VIO,SPACE=(TRK,(5,5)),
//            DCB=(LRECL=80,BLKSIZE=800,RECFM=FB)
//STDIN   DD DUMMY
//STDOUT  DD SYSOUT=*,DCB=(RECFM=FB,LRECL=140,BLKSIZE=5600)
//STDERR  DD SYSOUT=*,DCB=(RECFM=FB,LRECL=140,BLKSIZE=5600)"""


def emit_vtocsrac(filename, guard_apply=False):
    """Emit VTOCSRAC with a restart-safe RACINDVT command filter.

    The upstream EXEC/BREXX step is retained unchanged except that its OUTDD is
    widened to FB128 and renamed &&CDRAW.  CDSCBF filters/compacts that stream
    to the original FB80 &&CDSCB data set immediately before RACINDVT.
    """
    emit("//*" + "*" * 66)
    emit("//* {}".format("/".join(filename.split("/")[-2:])))
    emit("//*" + "*" * 66)

    with open(filename, 'r') as f:
        raw = f.readlines()

    # Strip the source job card just like read_file().
    jobcard = True
    lines = []
    for l in raw:
        if l.strip() == "//" or not l.strip():
            continue
        if jobcard:
            if l.strip().endswith(","):
                continue
            jobcard = False
            continue
        lines.append(l.rstrip())

    outdd_seen = False
    dcb_seen = False
    racindvt_seen = False
    transformed = []
    in_cmd_outdd = False

    for l in lines:
        r = l

        # Capture the original generated CDSCB commands before IKJEFT01's
        # 72-column SYSTSIN limit can truncate them.  FB128 also covers a
        # maximum-length (44 byte) MVS data set name in the old verbose form.
        if r.startswith("//OUTDD") and "DSN=&&CDSCB" in r:
            r = r.replace("DSN=&&CDSCB", "DSN=&&CDRAW", 1)
            outdd_seen = True
            in_cmd_outdd = True
        elif in_cmd_outdd and "DCB=(" in r:
            if "LRECL=80" not in r or "BLKSIZE=800" not in r:
                sys.exit("generate_release.py: unexpected VTOCSRAC OUTDD DCB: {}"
                         .format(r))
            r = r.replace("LRECL=80", "LRECL=128", 1)
            r = r.replace("BLKSIZE=800", "BLKSIZE=1280", 1)
            dcb_seen = True
            in_cmd_outdd = False

        if r.startswith("//RACINDVT") and _exec_line(r):
            if racindvt_seen:
                sys.exit("generate_release.py: duplicate RACINDVT in {}"
                         .format(filename))
            transformed.extend(VTOCSRAC_FILTER.split("\n"))
            racindvt_seen = True

        transformed.append(r)

    missing = []
    if not outdd_seen:
        missing.append("OUTDD DSN=&&CDSCB")
    if not dcb_seen:
        missing.append("OUTDD DCB=(LRECL=80,BLKSIZE=800,...)")
    if not racindvt_seen:
        missing.append("//RACINDVT EXEC")
    if missing:
        sys.exit("generate_release.py: VTOCSRAC layout not recognized; missing: {}"
                 .format(", ".join(missing)))

    # The Python card emitter must never silently create >80 byte records.
    # JCL itself is kept <=71 where practical; inline REXX may use all 80.
    too_long = [(i + 1, l) for i, l in enumerate(transformed) if len(l) > 80]
    if too_long:
        n, l = too_long[0]
        sys.exit("generate_release.py: VTOCSRAC generated card {} exceeds 80 "
                 "columns ({}): {}".format(n, len(l), l))

    if guard_apply and args.upgrade:
        emit_guarded_lines(transformed)
    else:
        for l in transformed:
            emit(l)

    for l in transformed:
        check_step(l, filename)


def _data_file(arg, default):
    """Resolve a users/profiles file path (relative paths are under the repo)."""
    fn = arg if arg else default
    return fn if os.path.isabs(fn) else os.path.join(running_folder, fn)


def emit_header(filename):
    """Emit 01_header.template with the fixes needed by an upgrade.

    RESETRC lets the ACDS UCLIN run even when harmless CDS deletes report RC 8.
    During an upgrade ICHSFR00 must remain in LPALIB because SMP can use the
    existing LMOD as link-edit input while changing functional ownership.

    01_header.template also contains the FUNCTION's ++VER MCS, so an upgrade
    from a different FMID rewrites DELETE(...) to --upgrade-from and adds
    VERSION(...) there.  Reworking TRKF200 in place (--upgrade-from TRKF200)
    leaves ++VER alone: DELETE/VERSION of the function being installed is
    invalid.  JCLIN/TRKF200.jcl contains only the JCLIN body and therefore
    must not be searched for ++VER.
    """
    with open(filename) as f:
        lines = f.readlines()

    # The V2 target/distribution libraries named by the LIBS step are release
    # work libraries.  On an upgrade/retry they may already exist from an
    # earlier attempt.  Since LIBS allocates them NEW, that otherwise ends in:
    #   IEF253I ... LIBS ASAMPLIB - DUPLICATE NAME ON DIRECT ACCESS VOLUME
    # Recreate them from scratch so a retry cannot reuse stale V2 members.
    upgrade_lib_dsns = []
    if args.upgrade:
        in_libs = False
        for raw in lines:
            r = raw.rstrip()
            if _exec_line(r):
                if r.startswith('//LIBS '):
                    in_libs = True
                    continue
                if in_libs:
                    break
            if in_libs and 'DSN=' in r.upper():
                dsn = r.upper().split('DSN=', 1)[1].split(',', 1)[0].strip()
                if dsn and dsn not in upgrade_lib_dsns:
                    upgrade_lib_dsns.append(dsn)

    last_control = ''
    found_ver = False
    cleanup_emitted = False
    for l in lines:
        stripped = l.strip()

        if (args.upgrade and not cleanup_emitted and
                l.rstrip().startswith('//LIBS ') and _exec_line(l.rstrip())):
            emit('//* UPGRADE: remove stale V2 target/distribution libraries')
            emit('//CLNV2LIB EXEC PGM=IDCAMS')
            emit('//SYSPRINT DD SYSOUT=*')
            emit('//SYSIN    DD *')
            for dsn in upgrade_lib_dsns:
                emit('  DELETE {} PURGE'.format(dsn))
            emit('  SET MAXCC=0')
            emit('/*')
            check_step('//CLNV2LIB EXEC PGM=IDCAMS', filename)
            cleanup_emitted = True

        if stripped == 'UCLIN ACDS .' and last_control != 'RESETRC.':
            emit(' RESETRC.')

        if args.upgrade and 'SCRATCH ' in l and 'MEMBER=ICHSFR00' in l:
            # Do not emit a //* comment here: SYSIN DD * treats // in
            # columns 1-2 as the end of in-stream data, and JES then
            # generates a replacement SYSIN.
            continue

        if args.upgrade and stripped.startswith('++VER('):
            found_ver = True
            up = args.upgrade_from.upper()
            # Same-FMID rework is not a function replacement.
            if up != RAKF_FUNCTION and 'VERSION(' not in stripped.upper():
                # Keep VERSION on a continuation card.  Appending it to the
                # ++VER line itself (VERSION(TRKF126) is 17 characters) makes
                # the current header 81 bytes; encode() then emits a 81-byte
                # "card" and every later 80-column record — including
                # RECEIVER's DLM and //SMPCNTL — starts in column 2.
                r = l.rstrip()
                period = r.endswith('.')
                if period:
                    r = r[:-1].rstrip()
                # Fresh-install ++VER deletes TRKF120.  An upgrade must
                # DELETE/VERSION the function that is actually on the CDS.
                dpos = r.upper().find('DELETE(')
                if dpos >= 0:
                    dend = r.find(')', dpos)
                    if dend < 0:
                        sys.exit('generate_release.py: unterminated DELETE( '
                                 'on ++VER in TEMPLATES/01_header.template')
                    r = r[:dpos] + 'DELETE({})'.format(up) + r[dend + 1:]
                else:
                    r = r + ' DELETE({})'.format(up)
                if not r.endswith(','):
                    r += ','
                emit(r)
                l = ' VERSION({})'.format(up)
                if period:
                    l += '.'

        emit(l.rstrip())
        check_step(l, filename)
        if stripped and not stripped.startswith('***'):
            last_control = stripped

    if args.upgrade and not found_ver:
        sys.exit('generate_release.py: no ++VER statement found in '
                 'TEMPLATES/01_header.template')


def emit_trkf200_jclin(filename):
    """Emit TRKF200 JCLIN after verifying the V2 password-hash linkage."""
    with open(filename) as f:
        text = f.read().rstrip()

    # V2 ICHSFR00 must contain both hashing CSECTs. Refuse to generate a deck
    # from an old/stale JCLIN, because that produces a load module that links
    # with unresolved RAKFPWH and fails at TSO logon.
    required = ('INCLUDE SYSPUNCH(RAKFHASH)', 'INCLUDE SYSPUNCH(RAKFPWH)')
    missing = [item for item in required if item not in text]
    if missing:
        sys.exit('generate_release.py: JCLIN/TRKF200.jcl is missing: {}'
                 .format(', '.join(missing)))

    emit_text(text)


def emit_smp_tail(filename):
    """Emit 02_smp4.template, preventing ACCEPT after a failed APPLY."""
    with open(filename) as f:
        for l in f.readlines():
            r = l.rstrip()
            if r.startswith('//ACCEPTR ') and ' EXEC ' in r and 'COND=' not in r.upper():
                r += ',COND={}'.format(APPLY_GUARD)
            emit(r)
            check_step(l, filename)


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


# These continue the RAKFINST job rather than starting one of their own.
# They MUST: SYS1.SECURE.SHADOW is allocated by RAKFCUST's ALLOC step, which
# is part of RAKFINST, and this references it DISP=SHR. As a separate job it
# raced -- JES2 is genned with two initiators on class A (I1 START,CLASS=A
# and I2 START,CLASS=BA), so it started on INIT 2 while RAKFINST was still
# running on INIT 1 and failed before the dataset existed:
#     IEF453I RAKFSHAD - JOB FAILED - JCL ERROR
#     IEFACTRT SHADLOAD/IEBGENER/.../NOXEC/RAKFSHAD
# leaving the shadow file empty, and every password on the system unusable.
# Steps within one job are serialized, so ordering is guaranteed -- and it
# brings these under the caller's existing check_maxcc('RAKFINST').
SHADOW_LOAD = """//*******************************************************************
//* Populate SYS1.SECURE.SHADOW with the salted SHA-256 password
//* hashes (computed at release-generation time).  The 48-byte
//* records are shipped padded to 80-byte cards through the EBCDIC
//* reader; IEBGENER trims each back to LRECL 48 on the way in.
//*******************************************************************
//SHADLOAD EXEC PGM=IEBGENER
//SYSPRINT DD SYSOUT=*
//SYSUT2   DD DSN={dsn},DISP=SHR
//SYSUT1   DD DATA,DLM='{dlm}'"""

SHADOW_LOAD_SYSIN = """//SYSIN    DD *
  GENERATE MAXFLDS=1
  RECORD FIELD=(48,1,,1)"""


def emit_shadow_load(shadow, dsn="SYS1.SECURE.SHADOW"):
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
    (emit_guarded_text if args.upgrade else emit_text)(
        SHADOW_LOAD.format(dlm=dlm, dsn=dsn))
    OUT.extend(cards)          # raw binary, 80-byte cards
    emit(dlm)
    (emit_guarded_text if args.upgrade else emit_text)(SHADOW_LOAD_SYSIN)


def emit_rakfcust(filename, inserts):
    """Emit RAKFCUST.jcl, splicing USERS/PROFILES and handling upgrades.

    On an upgrade SYS1.SECURE.PWUP and SYS1.SECURE.CNTL already exist, so the
    ALLOC step references them DISP=SHR instead of attempting DISP=NEW. SHADOW
    is still allocated by the original RAKFCUST JCL after a guarded delete.
    """
    emit("//*" + "*" * 66)
    emit("//* {}".format("/".join(filename.split("/")[-2:])))
    emit("//*" + "*" * 66)
    with open(filename) as f:
        lines = f.read().split('\n')
    jobcard = True
    skipping = False          # dropping an old placeholder body up to its /*
    skip_dd_cont = False      # dropping allocation continuations for reused DSNs
    n = 0                     # number of placeholders filled so far
    for line_index, l in enumerate(lines):
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

        # In upgrade mode these two datasets came from the previous RAKF
        # installation. Keep them and suppress the UNIT/DCB/SPACE continuation
        # cards belonging to their original DISP=(,CATLG) allocation DDs.
        if args.upgrade and skip_dd_cont:
            if l.startswith('//') and len(l) > 2 and l[2].isspace():
                continue
            skip_dd_cont = False
        if args.upgrade and l.startswith('//PWUP') and 'SYS1.SECURE.PWUP' in l:
            emit('//PWUP    DD DISP=SHR,DSN=SYS1.SECURE.PWUP')
            skip_dd_cont = True
            continue
        if args.upgrade and l.startswith('//RAKF') and 'SYS1.SECURE.CNTL' in l:
            emit('//RAKF    DD DISP=SHR,DSN=SYS1.SECURE.CNTL')
            skip_dd_cont = True
            continue

        emit_jcl_line(
            l,
            guard_apply=True,
            exec_continues=_next_exec_continuation(lines, line_index)
                           if _exec_line(l.rstrip()) else False,
            existing_cond=_exec_has_cond(lines, line_index)
                          if _exec_line(l.rstrip()) else False,
        )
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


# Also a continuation of RAKFINST, for the same reason as SHADOW_LOAD above:
# separate jobs run on separate initiators and race the install they depend on.

HELP_HEADER = """//* --- TSO HELP members for the admin commands -------------------
//HELPLOAD EXEC PGM=IEBUPDTE,PARM=NEW
//SYSPRINT DD SYSOUT=*
//SYSUT2   DD DSN={helplib},DISP=SHR
//SYSIN    DD *"""


def cmdlib_aliases_from_jclin(jclin_path):
    """Map NAME -> ALIAS list for load modules linked into *.CMDLIB.

    JCLIN names and operands are uppercase.  ALIAS cards apply to the
    following NAME in the same SYSLIN stream.  LPALIB/LINKLIB aliases
    (e.g. ICHRIN00) are ignored.
    """
    aliases = {}
    current_cmdlib = False
    in_syslin = False
    pending = []

    with open(jclin_path) as f:
        for raw in f:
            line = raw.rstrip()
            if line.startswith('//SYSLMOD') and 'DSN=' in line:
                dsn = line.split('DSN=', 1)[1].split(',', 1)[0].strip()
                current_cmdlib = dsn.endswith('.CMDLIB')
                in_syslin = False
                pending = []
                continue
            if line.startswith('//SYSLIN') and '*' in line:
                in_syslin = True
                pending = []
                continue
            if not in_syslin:
                continue
            stripped = line.strip()
            if stripped == '/*' or (line.startswith('//') and not line.startswith('//*')):
                in_syslin = False
                pending = []
                continue
            if stripped.startswith('ALIAS'):
                rest = stripped[5:].strip()
                pending.extend(a.strip() for a in rest.split(',') if a.strip())
            elif stripped.startswith('NAME'):
                name = stripped[4:].strip().split('(', 1)[0].strip()
                if current_cmdlib and pending:
                    aliases[name] = pending
                pending = []
    return aliases


def emit_help():
    """Load HELP/* into the help library so 'HELP ADDUSER' works.

    One member per file in HELP/, named after the command. PDSLOAD is used
    rather than IEBUPDTE because it copies the text verbatim -- IEBUPDTE
    would want sequence numbers in columns 73-80, and TSO HELP would then
    display them.

    If JCLIN links that command into *.CMDLIB with ALIAS statements,
    matching `./ ALIAS NAME=` cards are appended so TSO HELP finds the
    short names too (e.g. ALU for ALTUSER).
    """
    help_dir = os.path.join(running_folder, "HELP")
    if not os.path.isdir(help_dir):
        return
    members = sorted(f for f in os.listdir(help_dir)
                     if os.path.isfile(os.path.join(help_dir, f)))
    if not members:
        return
    jclin = os.path.join(running_folder, "JCLIN", "TRKF200.jcl")
    cmdlib_aliases = cmdlib_aliases_from_jclin(jclin) if os.path.isfile(jclin) else {}
    listed = []
    for m in members:
        aliases = cmdlib_aliases.get(m, [])
        listed.append("/".join([m] + aliases) if aliases else m)
    sys.stderr.write("[gen] help members: {}\n".format(", ".join(listed)))
    (emit_guarded_text if args.upgrade else emit_text)(
        HELP_HEADER.format(helplib=args.helplib))
    for m in members:
        emit("./ ADD NAME={}".format(m))
        with open(os.path.join(help_dir, m)) as f:
            for line in f.read().split('\n'):
                line = line.rstrip()
                if len(line) > 80:
                    sys.exit("generate_release.py: HELP/{} has a line over 80 "
                             "columns:\n  {}".format(m, line))
                emit(line)
        for alias in cmdlib_aliases.get(m, []):
            emit("./ ALIAS NAME={}".format(alias))
    emit("/*")



# ------------------------------------------------------------------ #
#  Standalone shadow-file recovery mode.                              #
# ------------------------------------------------------------------ #
def write_output():
    """Write the accumulated EBCDIC card-image stream."""
    if args.output:
        with open(args.output, 'wb') as f:
            f.write(bytes(OUT))
        sys.stderr.write("[gen] wrote {} ({} bytes). Submit via the EBCDIC reader:\n"
                         "      cat {} | ncat --send-only -w1 127.0.0.1 3506\n"
                         .format(args.output, len(OUT), args.output))
    else:
        sys.stdout.buffer.write(bytes(OUT))
        sys.stderr.write("[gen] wrote {} bytes to stdout. Submit the EBCDIC stream via port 3506.\n"
                         .format(len(OUT)))


def emit_shadow_recovery(shadow):
    """Emit a self-contained job to recreate and populate the shadow file.

    This intentionally does not touch the RAKF USERS member or any load module.
    By default it stops after loading the dataset; use --run-rakfuser only when
    the installed RAKFUSER procedure is known to be runnable in the current
    system. Otherwise an IPL/reload can rebuild the in-core user table later.
    """
    dsn = args.shadow_dsn.upper()
    emit("//RAKFSHAD JOB (RAKF),'RAKF SHADOW RECOVERY',CLASS=A,MSGCLASS=A,")
    emit("//            MSGLEVEL=(1,1),REGION=4096K,USER=IBMUSER,PASS=SYS1")
    emit("//* Recreate the RAKF V2 password shadow file")
    emit("//DELETE   EXEC PGM=IDCAMS")
    emit("//SYSPRINT DD SYSOUT=*")
    emit("//SYSIN    DD *")
    emit("  DELETE {} PURGE".format(dsn))
    emit("  SET MAXCC=0")
    emit("/*")
    emit("//ALLOC    EXEC PGM=IEFBR14")
    emit("//SHADOW   DD DSN={},DISP=(NEW,CATLG,DELETE),".format(dsn))
    emit("//             UNIT=SYSDA,")
    if args.shadow_volume:
        emit("//             VOL=SER={},".format(args.shadow_volume.upper()))
    emit("//             SPACE=(TRK,(1,1)),")
    emit("//             DCB=(DSORG=PS,RECFM=FB,LRECL=48,BLKSIZE=19008)")
    emit_shadow_load(shadow, dsn=dsn)
    if args.run_rakfuser:
        emit("//* Reload the in-core RAKF user table from USERS + SHADOW")
        emit("//RELOAD   EXEC RAKFUSER")


if args.shadow_recovery:
    users_path = _data_file(args.users, 'users.txt')
    with open(users_path) as f:
        recovery_users = f.read()
    _, recovery_shadow = build_credentials(recovery_users)
    if not recovery_shadow:
        sys.exit("generate_release.py: no userid/password records found in {}"
                 .format(users_path))
    sys.stderr.write("[gen] shadow recovery from {}: {} user(s)\n"
                     .format(users_path, len(recovery_shadow) // 48))
    emit_shadow_recovery(recovery_shadow)
    write_output()
    sys.exit(0)


##################################################

emit_header(running_folder + "/TEMPLATES/01_header.template")
emit_trkf200_jclin(running_folder + "/JCLIN/TRKF200.jcl")

smp_dict = {
        'MACLIB': "++MAC({}) DISTLIB(AMACLIB)  SYSLIB(MACLIB).",
        'SRCLIB': "++SRC({}) DISTLIB(ASRCLIB)  SYSLIB(SRCLIB).",
        'PROCLIB': "++MAC({}) DISTLIB(APROCLIB) SYSLIB(PROCLIB).",
        'PARMLIB': "++MAC({}) DISTLIB(APARMLIB) SYSLIB(PARMLIB).",
        'SAMPLIB': "++MAC({}) DISTLIB(ASAMPLIB) SYSLIB(SAMPLIB)."
        }

folders = ["MACLIB", "SRCLIB", "PROCLIB", "PARMLIB", "SAMPLIB"]

for folder in folders:
    fileList = os.listdir("{}/{}".format(running_folder, folder))
    for filename in fileList:
        member = filename.split(".")[0]
        if not (1 <= len(member) <= 8):
            sys.exit('generate_release.py: {} member {} is not 1-8 characters '
                     '(from {})'.format(folder, member, filename))
        emit(smp_dict[folder].format(member))
        jfile = os.path.join('{}/{}/{}'.format(running_folder, folder, filename))
        with open(jfile, 'r') as f:
            body = f.read().rstrip()
        for line in body.split('\n'):
            line = line.rstrip()
            # Columns 1-2 of PTFIN starting with ++ begin a new MCS.
            # RAKF2MVS's ++LMODIN/++ENDLMODIN would abort RECEIVE
            # (HMA2032 / HMA3980) if left in column 1.
            if line.startswith('++'):
                line = ' ' + line
                if len(line) > 80:
                    sys.exit('generate_release.py: {}/{} ++ data exceeds 80 '
                             'columns after MCS-safe indent'.format(
                                 folder, filename))
            emit(line)

emit_smp_tail(running_folder + "/TEMPLATES/02_smp4.template")

install = []

# These two USERMODs are part of the normal/fresh RAKF installation, but the
# old TRKF126 installation already has them.  Do not RECEIVE/APPLY them again
# during an upgrade; among other things, ZPY0001's PRE(ZJW0003) is already
# satisfied by the existing ZJW0003.
if not args.upgrade:
    install.extend([
        'USERMODS/RAK0001.jcl',
        'USERMODS/ZJW0003.jcl',
    ])

install.extend([
    # ZPY0001 MACUPDs SGIEE0MS to add the //RAKFSHAD DD to MSTJCL00, which is
    # how RAKFUSER reaches SYS1.SECURE.SHADOW at IPL. It declares
    # PRE(ZJW0003): fresh install emits ZJW0003 above; --upgrade relies on the
    # ZJW0003 already installed with the previous RAKF release.
    # Without it the OPEN fails with 'IEC130I RAKFSHAD DD STATEMENT MISSING',
    # no hashes load, and -- since build_credentials() blanks the USERS
    # password column -- every credential on the system becomes unverifiable.
    'TOOLS/RAKFCUST.jcl',
    'AUX/VTOC/vtoc.jcl',
    'AUX/CDSCB.jcl',
    'TOOLS/VSAMSRAC.jcl',
    'TOOLS/VTOCSRAC.jcl',
])

# ---- process the initial users: blank passwords, build the shadow --
_users_raw = open(_data_file(args.users, 'users.txt')).read()
_profiles = open(_data_file(args.profiles, 'profiles.txt')).read().strip()
blanked_users, shadow_bytes = build_credentials(_users_raw)

for jcl in install:
    path = running_folder + "/" + jcl
    if 'RAKFCUST' in jcl:
        if args.upgrade:
            # RAKF 1.x has no shadow file. Delete any leftover from a partial
            # V2 attempt so RAKFCUST can allocate a clean FB48 dataset and
            # SHADLOAD cannot leave stale trailing records on a retry.
            emit_guarded_text("""//SHADDEL  EXEC PGM=IDCAMS
//SYSPRINT DD SYSOUT=*
//SYSIN    DD *
  DELETE SYS1.SECURE.SHADOW PURGE
  SET MAXCC=0
/*""")
        emit_rakfcust(path, [blanked_users, _profiles])
        # The shadow load and the tools install belong HERE -- after
        # RAKFCUST's ALLOC step has created SYS1.SECURE.SHADOW, and before
        # VSAMSRAC's RACIND and VTOCSRAC's RACINDVT steps set the RACF
        # indicator bit on the datasets.
        #
        # Once a dataset is RACF-indicated, OPEN issues SVC 130 (RACHECK).
        # RAKF supplies that SVC but does not activate until the next IPL,
        # so within this job the SVC has no handler and the step dies:
        #     IEF472I RAKFINST SHADLOAD - COMPLETION CODE - SYSTEM=E82
        # Running them before the indicators are set avoids the RACHECK
        # entirely. (They were originally trailing jobs, which also raced
        # RACIND -- separate jobs on separate initiators, same root cause.)
        emit_shadow_load(shadow_bytes)
        emit_help()
    elif 'VTOCSRAC' in jcl:
        emit_vtocsrac(path, guard_apply=args.upgrade)
    else:
        read_file(path, guard_apply=args.upgrade)

emit("//* Steps in this job stream")
for i in steps:
    emit("//* {}".format(i))

# ------------------------------------------------------------------ #
#  Write the EBCDIC byte stream.                                     #
# ------------------------------------------------------------------ #
write_output()
#
