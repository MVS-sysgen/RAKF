//RAK00011     JOB (SYS),'INSTALL RAK00011',CLASS=A,MSGCLASS=A
//RAK00011 EXEC PGM=IEBGENER
//SYSPRINT DD  SYSOUT=*
//SYSUT1   DD  *
++USERMOD(RAK0001).
++VER(Z038) FMID(EBB1102)
 /*
  *  Desc: Type 3/4 SVC for setting/unsetting JSCBAUTH
  *
  *        If a security system (for example RAKF) is installed
  *        read access to ressource SVC244 in class FACILITY is
  *        requested and the JSCBAUTH change is made only if the
  *        security system grants this access
  */.
++MOD(IGC0024D) DISTLIB(LPALIBA).
/*
//SYSUT2   DD  DSN=&&SMPMCS,DISP=(NEW,PASS),UNIT=SYSALLDA,
//             SPACE=(CYL,3),
//             DCB=(DSORG=PS,RECFM=FB,LRECL=80,BLKSIZE=4080)
//SYSIN    DD  DUMMY
//*
//RAK00012 EXEC PGM=IFOX00,PARM='OBJECT,NODECK,NOTERM,XREF(SHORT),RENT'
//SYSPRINT DD  SYSOUT=*
//SYSUT1   DD  UNIT=SYSALLDA,SPACE=(CYL,10)
//SYSUT2   DD  UNIT=SYSALLDA,SPACE=(CYL,10)
//SYSUT3   DD  UNIT=SYSALLDA,SPACE=(CYL,10)
//SYSLIB   DD  DSN=SYS1.MACLIB,DISP=SHR
//         DD  DSN=SYS1.SMPMTS,DISP=SHR
//         DD  DSN=SYS1.AMODGEN,DISP=SHR
//SYSGO    DD  DSN=&&SMPMCS,DISP=(MOD,PASS)
//SYSIN    DD  *
         TITLE ' SVC 244 - Toggle Authorization '
***********************************************************************
*                                                                     *
*  Name: IGC0024D                                                     *
*                                                                     *
*  Type: Assembler source                                             *
*                                                                     *
*  Desc: Type 3/4 SVC for setting/unsetting JSCBAUTH                  *
*                                                                     *
*        If a security system (for example RAKF) is installed         *
*        read access to ressource SVC244 in class FACILITY is         *
*        requested and the JSCBAUTH change is made only if the        *
*        security system grants this access                           *
*                                                                     *
*  Regs at Entry:                                                     *
*                                                                     *
*          R0 must be 0                                               *
*          R1 = Request code.  R1 = 1 ===> Authon                     *
*                                else ===> Authoff                    *
*          R2       undetermined                                      *
*          R3  ---> CVT                                               *
*          R4  ---> TCB                                               *
*          R5  ---> SVRB                                              *
*          R6  ---> Entry point                                       *
*          R7  ---> ASCB                                              *
*          R8  ---> undetermined                                      *
*          R9  ---> undetermined                                      *
*          R10 ---> undetermined                                      *
*          R11 ---> undetermined                                      *
*          R12 ---> undetermined                                      *
*                                                                     *
***********************************************************************
IGC0024D CSECT                             , SVC 244
R0       EQU   0
R1       EQU   1
R2       EQU   2
R3       EQU   3
R4       EQU   4
R5       EQU   5
R6       EQU   6
R7       EQU   7
R8       EQU   8
R9       EQU   9
R10      EQU   10
R11      EQU   11
R12      EQU   12
R13      EQU   13
R14      EQU   14
R15      EQU   15
         USING *,6                         , use R6 as base register
         LTR   R0,R0                       , R0 = 0 ?
         BNZR  R14                         , return if not
         ICM   R8,B'1111',CVTSAF(R3)       , SAFV defined ?
         BZ    GOFORIT                     , no RAC, permit JSCB auth
         USING SAFV,R8                     , addressability of SAFV
         CLC   SAFVIDEN(4),SAFVID          , SAFV initialized ?
         BNE   GOFORIT                     , no RAC, permit JSCB auth
         DROP  R8                          , SAFV no longer needed
         LR    R8,R1                       , remember R1
         LR    R9,R15                      , remember R15
         RACHECK ENTITY=SVC244,CLASS='FACILITY',ATTR=READ ask RAC
         LR    R1,R8                       , restore R1
         LR    R8,R15                      , remember return code
         LR    R15,R9                      , restore R15
         XR    R0,R0                       , restore R0
         LTR   R8,R8                       , RAC authorization granted?
         BNZR  R14                         , return if not
GOFORIT  L     R11,180(,R4)                , R11 = JSCB (from TCBJSCB)
         BCT   R1,AUTHOFF                  , R1 NOT = 1 ==> Authoff
         OI    236(R11),X'01'              , set JSCBAUTH on
         BR    R14                         , and return
AUTHOFF  NI    236(11),255-X'01'           , set JSCBAUTH off
         BR    R14                         , and return
SVC244   DC    CL39'SVC244'                , facility name to authorize
SAFVID   DC    CL4'SAFV'                   , SAFV eye catcher
CVTSAF   EQU   248 CVTSAF doesn't exist but is a reserved field in 3.8J
         ICHSAFV  DSECT=YES                , map SAFV
         END                               , of SVC 244
/*
//RAK00013 EXEC SMPREC,WORK='SYSALLDA'
//SMPPTFIN DD  DSN=&&SMPMCS,DISP=(OLD,DELETE)
//SMPCNTL  DD  *
  RECEIVE
          SELECT(RAK0001)
          .
/*
//*
//RAK00014 EXEC SMPAPP,WORK='SYSALLDA'
//SMPCNTL  DD  *
  APPLY
        SELECT(RAK0001)
        CHECK
        .
/*
//*
//RAK00015   EXEC SMPAPP,WORK='SYSALLDA'
//SMPCNTL  DD  *
  APPLY
        SELECT(RAK0001)
        DIS(WRITE)
      /*  COMPRESS(ALL) */
        .
/*