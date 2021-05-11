//SVC244 JOB   (SETUP),
//             'Build SVC 244',
//             CLASS=S,
//             MSGCLASS=A,
//             MSGLEVEL=(1,1),USER=IBMUSER,PASSWORD=SYS1
//*******************************************************************
//*                                                                 *
//*  This job builds SVC 244 which can be used to set/unset the     *
//*  authorization bit in the JSCB                                  *
//*                                                                 *
//*******************************************************************
//ASMSVC  EXEC PGM=IFOX00,
//             PARM='XREF(SHORT),LIST,DECK,NOOBJ',
//             REGION=1024K
//SYSTERM  DD  SYSOUT=*
//SYSPRINT DD  SYSOUT=*
//SYSUT1   DD  UNIT=VIO,SPACE=(CYL,(1,1))
//SYSUT2   DD  UNIT=VIO,SPACE=(CYL,(1,1))
//SYSUT3   DD  UNIT=VIO,SPACE=(CYL,(1,1))
//SYSLIB   DD  DISP=SHR,DSN=SYS1.MACLIB,DCB=BLKSIZE=32720
//         DD  DISP=SHR,DSN=SYS1.AMODGEN
//*         DD  DISP=SHR,DSN=SYS2.MACLIB
//SYSPUNCH DD  DISP=(,PASS),UNIT=VIO,SPACE=(CYL,(1,1)),
//             DCB=(LRECL=80,BLKSIZE=3120,RECFM=FB)
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
//LINK    EXEC PGM=IEWL,
//             REGION=1024K,
//             COND=(0,LT),
//             PARM='LIST,MAP.RENT,REUS,REFR'
//SYSPRINT DD  SYSOUT=*
//SYSLIN   DD  DISP=(OLD,DELETE),DSN=*.ASMSVC.SYSPUNCH
//SYSUT1   DD  UNIT=VIO,SPACE=(CYL,(1,1))
//SYSLMOD  DD  DISP=SHR,DSN=SYS1.LPALIB(IGC0024D)
