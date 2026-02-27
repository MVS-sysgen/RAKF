//RAKFUDMP JOB (TSO),'RAKF User Dump',CLASS=A,MSGCLASS=A,
//             REGION=8192K,MSGLEVEL=(1,1),USER=IBMUSER,PASSWORD=SYS1
//*
//* RAKFUDMP - Dump RAKF in-memory user table with decoded passwords
//*
//* Walks the control block chain:
//*   PSA+X'10'   -> CVT pointer
//*   CVT+X'F8'   -> SAFV pointer (CVTSAF, NOT CVTRAC - RAKF/MVS 3.8J)
//*   CVT+CVTRAC  -> RCVT pointer (offset found by scanning CVT)
//*   RCVT+X'30'  -> CJYRCVTD installation extension (RCVTISTL)
//*   CJYRCVTD+0  -> CBLK chain head (CJYUSERS)
//*   CJYRCVTD+4  -> RPECBLK chain head (CJYPROFS) - not walked here
//*
//* CBLK layout (36 bytes, CSA subpool 241 key 0):
//*   +0  CBLKNEXT F    next CBLK (0=end)
//*   +4  CBLKGRPS F    connected groups chain head
//*   +8  CBLKUSRL X    userid length
//*   +9  CBLKUSRI CL8  userid name
//*   +17 CBLKGRPL X    default group length
//*   +18 CBLKGRPN CL8  default group name
//*   +26 CBLKPWDL X    password length
//*   +27 CBLKPWDE CL8  password XOR-encrypted with 'SECURITY'
//*   +35 CBLKFLG1 C    oper authority flag (Y/N)
//*
//* CONNGRUP layout (16 bytes, CSA subpool 241 key 0):
//*   +0  CONNNEXT F    next CONNGRUP (0=end)
//*   +4  CONNGRPL X    group name length
//*   +5  CONNGRPN CL8  group name
//*
//* NOTE: RAKF must be active (S RAKF) before submitting this job
//*
//STAGE    EXEC PGM=IEBGENER
//SYSPRINT DD SYSOUT=*
//SYSIN    DD DUMMY
//SYSUT2   DD DSN=&&RXPGM,DISP=(,PASS),UNIT=VIO,
//            SPACE=(TRK,(5,5)),
//            DCB=(RECFM=FB,LRECL=80,BLKSIZE=800)
//SYSUT1   DD *
 /* RAKFUDMP - RAKF In-Memory User Table Dump                  */
 /* Requires RAKF active. Decodes XOR passwords with SECURITY  */
 /* CVT+X'F8' is CVTSAF (SAFV) in RAKF/MVS 3.8J, NOT CVTRAC. */
 /* RCVT offset found by scanning CVT for 'RCVT' eyecatcher.  */
PSA_CVT   = 16
RCVT_ISTL = 48  /* RCVT+X'30' confirmed on MVS 3.8J */
CBLK_NEXT = 0
CBLK_GRPS = 4
CBLK_USRL = 8
CBLK_USRI = 9
CBLK_GRPL = 17
CBLK_GRPN = 18
CBLK_PWDL = 26
CBLK_PWDE = 27
CBLK_FLG1 = 35
CBLK_LEN  = 36
CONN_NEXT = 0
CONN_GRPL = 4
CONN_GRPN = 5
CONN_LEN  = 16
XORKEY    = 'SECURITY'
BAR       = COPIES('-', 72)
SAY COPIES('*', 60)
SAY '*  RAKFUDMP - RAKF IN-MEMORY USER TABLE DUMP'
SAY COPIES('*', 60)
SAY ''
cvt  = RD4('00000000', PSA_CVT)
SAY 'CVT      @ X''' || cvt || ''''
 /* CVT+X'F8'=CVTSAF=SAFV in RAKF/MVS 3.8J (not CVTRAC).    */
 /* Scan CVT at 4-byte intervals to find the RCVT pointer.   */
rcvt = ''
 /* Only dereference pointers in the SQA range (GETMAIN SP=245).  */
 /* On this MVS 3.8J system SAFV is X'00FDB008' so SQA is ~F00000 */
 /* Avoids S0C4 from nucleus/LPA pages that have fetch-protection. */
DO off = 4 TO 1020 BY 4
  ptr = RD4(cvt, off)
  IF X2D(ptr) < X2D('00E00000') THEN ITERATE
  IF X2D(ptr) > X2D('00FFFFFF') THEN ITERATE
  IF STORAGE(ptr, 4) = 'RCVT' THEN DO
    SAY 'RCVT     @ X''' || ptr || ''' (CVT+X''' || D2X(off) || ''')'
    rcvt = ptr
    LEAVE
  END
END
IF rcvt = '' THEN DO
  SAY 'ERROR: RCVT not found scanning CVT. Is RAKF active?'
  EXIT 8
END
 /* RCVTISTL confirmed at RCVT+X'30' on MVS 3.8J (offsets 4-2F */
 /* are IBM flags/padding, all zero in this RACF stub RCVT).  */
istl = RD4(rcvt, RCVT_ISTL)
IF istl = '00000000' THEN DO
  SAY 'ERROR: RCVTISTL is null. Is RAKF active?'
  EXIT 8
END
head = RD4(istl, 0)
SAY 'CJYRCVTD @ X''' || istl || ''''
SAY 'CBLK HEAD @ X''' || head || ''''
SAY ''
IF head = '00000000' THEN DO
  SAY 'User table is empty or RAKF not fully initialized.'
  EXIT 4
END
SAY BAR
SAY LEFT('USERID',8) LEFT('DFLT-GRP',9) LEFT('PASSWORD',9),
    'OPR  CONNECTED GROUPS'
SAY BAR
count = 0
cblk  = head
DO WHILE cblk <> '00000000'
  count = count + 1
  blk  = STORAGE(cblk, CBLK_LEN)
  usrl = C2D(SUBSTR(blk, CBLK_USRL+1, 1))
  user = LEFT(SUBSTR(blk, CBLK_USRI+1, 8), usrl)
  grpl = C2D(SUBSTR(blk, CBLK_GRPL+1, 1))
  dfgp = LEFT(SUBSTR(blk, CBLK_GRPN+1, 8), grpl)
  pwdl = C2D(SUBSTR(blk, CBLK_PWDL+1, 1))
  pwde = SUBSTR(blk, CBLK_PWDE+1, 8)
  pwdp = LEFT(BITXOR(pwde, XORKEY), pwdl)
  oper = SUBSTR(blk, CBLK_FLG1+1, 1)
  gptr = C2X(SUBSTR(blk, CBLK_GRPS+1, 4))
  grps = ''
  DO WHILE gptr <> '00000000'
    cg   = STORAGE(gptr, CONN_LEN)
    cgl  = C2D(SUBSTR(cg, CONN_GRPL+1, 1))
    cgn  = LEFT(SUBSTR(cg, CONN_GRPN+1, 8), cgl)
    grps = grps || ' ' || cgn
    gptr = C2X(SUBSTR(cg, CONN_NEXT+1, 4))
  END
  SAY LEFT(user,8) LEFT(dfgp,9) LEFT(pwdp,9) oper '  ' STRIP(grps)
  cblk = C2X(SUBSTR(blk, CBLK_NEXT+1, 4))
END
SAY BAR
SAY count 'user(s) found in RAKF table.'
SAY ''
EXIT 0
RD4: PROCEDURE
  PARSE ARG base, off
  RETURN C2X(STORAGE(D2X(X2D(base)+off, 8), 4))
/*
//RUN      EXEC PGM=BREXX,PARM='RXRUN',REGION=8192K
//RXRUN    DD   DSN=&&RXPGM,DISP=SHR
//RXLIB    DD   DSN=BREXX.CURRENT.RXLIB,DISP=SHR
//STDIN    DD   DUMMY
//STDOUT   DD   SYSOUT=*,DCB=(RECFM=FB,LRECL=133,BLKSIZE=5320)
//STDERR   DD   SYSOUT=*,DCB=(RECFM=FB,LRECL=133,BLKSIZE=5320)
