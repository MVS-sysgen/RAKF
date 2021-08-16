//RAKFPTF1 JOB (TSO),
//             'PDSLOAD RAKF PTFs',
//             CLASS=A,
//             MSGCLASS=A,
//             MSGLEVEL=(1,1)
//*
//*  Installs RAKF.PTFS
//*
//STEP1   EXEC PGM=PDSLOAD,PARM='UPDTE(><)'
//STEPLIB  DD  DSN=SYSC.LINKLIB,DISP=SHR
//SYSPRINT DD  SYSOUT=*
//SYSUT2   DD  DSN=SYSGEN.RAKF.PTFS,DISP=(NEW,CATLG),
//             VOL=SER=PUB000,
//             UNIT=3380,SPACE=(TRK,(7,5,17)),
//             DCB=(RECFM=FB,LRECL=80,BLKSIZE=19040)
//SYSUT1   DD  DATA,DLM=@@
./ ADD NAME=RRKF001  0201-11111-11111-1415-00051-00051-00000-PTF     32
++PTF(RRKF001) /*
 Enhancements and Fixes to RAKFUSER and RAKFPROF */ .
++VER(Z038) FMID(TRKF120)
 /*
 + introduce change history to source members RAKFUSER and RAKFPROF
 + enable comment lines in RAKF users and profiles tables
 + consistently don't highlight error messages on MVS console
 + fix S378 abend after syntax/sequencing error in first line of UDATA
 + add missing DEQ for SECURITY,USERS
 */ .
++SRCUPD(RAKFPROF) .
><  CHANGE NAME=RAKFPROF,SSI=02010000
*                                                                   @01 00260301
*    Change History                                                 @01 00260601
*                                                                   @01 00260901
*    2011/04/03 TRKF120 base version                                @01 00261201
*    2011/04/18 RRKF001 introduce change history                    @01 00261501
*                       enable comment lines in UDATA and PDATA     @01 00261801
*                                                                   @01 00262101
********************************************************************@01 00262401
         CLI   CLASS,C'*'              Comment?                     @01 00493001
         BE    READLOOP                 read next record            @01 00497001
>< ENDUP
++SRCUPD(RAKFUSER) .
><  CHANGE NAME=RAKFUSER,SSI=02010000
*                                                                   @01 00220301
*    Change History                                                 @01 00220601
*                                                                   @01 00220901
*    2011/04/03 TRKF120 base version                                @01 00221201
*    2011/04/18 RRKF001 introduce change history                    @01 00221501
*                       enable comment lines in UDATA and PDATA     @01 00221801
*                       consistently don't specify msg descriptor   @01 00222101
*                       fix S378 after error in first line of UDATA @01 00222401
*                       add missing DEQ for SECURITY,USERS          @01 00222701
*                                                                   @01 00223001
********************************************************************@01 00223301
         ENQ    (SECURITY,USERS,E,,SYSTEM),RET=HAVE serialization   @01 00370000
         XR     R5,R5               initialize GM chain             @01 00395001
         CLI    USERID,C'*'         Comment?                        @01 00413001
         BE     READLOOP             read next record               @01 00417001
         BE     NEWGROUP             same USER, check for new group @01 00430000
         BNH    ABEND2               not in sort seq, tell about it @01 00435001
         DEQ   (SECURITY,USERS,,SYSTEM) release ENQ                 @01 01355001
ABEND100 WTO    'RAKFUIDS1  RCVT NOT PROPERLY INITIALIZED'          @01 01400000
         WTO    'RAKFUIDSX  ** PROGRAM TERMINATED **'               @01 01410000
ABEND2   WTO    'RAKFUIDS2  INPUT DATA INVALID OR OUT OF SEQ.'      @01 01440000
                                           '                        @01 01480000
         WTO    'RAKFUIDSX  ** PROGRAM TERMINATED **'               @01 01490000
ABEND300 WTO    'RAKFUIDS3  EMPTY INPUT FILE ?!?!'                  @01 01560000
         WTO    'RAKFUIDSX  ** PROGRAM TERMINATED **'               @01 01570000
>< ENDUP
./ ADD NAME=RRKF002  0202-11118-11116-1800-00336-00336-00000-PTF     00
++PTF(RRKF002) /*
 Make RACINIT Password Changes permanent */ .
++VER(Z038) FMID(TRKF120) PRE(RRKF001)
 /*
 Summary of Changes:
 -------------------

 + Make RACINIT Password Changes permanent:

   Before application of this PTF a new password supplied as NEWPASS
   parameter of a RACINIT macro was updated in the in-core users table
   only and thus lived until the in-core table was replaced by the
   contents of the source users table at RAKF intialization time or by
   running RAKFUSER. Thus users were able to change their passwords
   only temporary. Permanent password changes required an RAKF
   administrator to edit the RAKF users table manually.

   This PTF changes processing of the NEWPASS parameter to queue the
   new password for update in the source users table in addition to
   updating the in-core users table. The password changes queue is
   applied during RAKFUSER processing to the source users table before
   the new in-core users table is created from the source table. This
   makes all password changes initiated by end users through using the
   password change facility of an application permanent and thus
   fully functional (for example changing the password at TSO logon
   time by entering currentpw/newpw at the "ENTER PASSWORD" prompt).

 + introduce change history to source member ICHSFR00

 Special Installation Instructions:
 ----------------------------------

 1. This PTF modifies elements that are not provided inline. These
    elements will be read during APPLY and ACCEPT processing from
    a PDS pointed to by ddname ELEMENTS. File RRKF002.elements.zip
    contains this PDS in XMIT370 format. Before the PTF can be APPLIed
    or ACCEPTed the PDS needs to be RECEIVed with an arbitrary name and
    a //ELEMENTS DD DSN=.... statement pointing to the PDS needs to
    be added to the SMP jobs used for APPLYing or ACCEPTing PTFs. After
    the PTF has been APPLIed (and ACCEPTed if desired) the PDS can be
    deleted and the //ELEMENTS DD statement can be removed from the
    SMP jobs.

    The following steps can be used to RECEIVE the PDS from file
    RRKF002.elements.zip:

    o Unzip rrkf002.elements.xmi from RRKF002.elements.zip and upload
      it to dataset RAKF.RRKF002.ELEMENTS.XMI (LRECL=80,RECFM=FB) on
      your MVS system using your standard unzip utility and upload
      software.

    o Submit the following job (requires the RECV370 utility to be
      installed, of course):

      //RCVELEMS JOB ...
      //RECV370  EXEC PGM=RECV370
      //RECVLOG   DD SYSOUT=*
      //XMITIN    DD DSN=RAKF.RRKF002.ELEMENTS.XMI,DISP=SHR
      //SYSPRINT  DD SYSOUT=*
      //SYSUT1    DD DSN=&&SYSUT1,
      //             UNIT=SYSDA,
      //             SPACE=(CYL,(10,5)),
      //             DISP=(,DELETE,DELETE)
      //SYSUT2    DD DSN=RAKF.RRKF002.ELEMENTS,
      //             DISP=(,CATLG),SPACE=(TRK,(6,2,1),RLSE),
      //             DCB=(LRECL=80,BLKSIZE=5600,RECFM=FB),
      //             UNIT=SYSDA
      //SYSIN     DD DUMMY
      //SYSUDUMP  DD SYSOUT=*

    The dataset names used in this example can be changed to anything
    you like as long as the //ELEMENT DD statement in the SMP APPLY
    and ACCEPT jobs points to the dataset created by //SYSUT2 DD of
    the RCVELEMS job.

 2. RECEIVE and APPLY the PTF as usual. Don't IPL the system!

 3. Perform step 1. b) from member $$$$CUST in HLQ.SAMPLIB (HLQ = high
    level qualifier of the RAKF libraries) to define the RAKF
    password changes queue dataset.

 4. Perform step 4 from member $$$$CUST in HLQ.SAMPLIB to add the RAKF
    password changes queue dataset DD statement to MSTRJCL. The sample
    usermod ZJW0003 provided in HLQ.SAMPLIB has been adapted by this
    PTF and can be rerun without changes if the original version had
    been used at RAKF installation time.

 5. IPL the system using the CLPA option.

 6. ACCEPT the PTF according to your preferences after sufficient
    testing.
 */ .
++JCLIN .
//RRKF002  JOB 1,'RAKF 1.2',MSGLEVEL=1,CLASS=A
//*
//* JCLIN for RAKF 1.2 PTF RRKF002
//*
//ASMUSER  EXEC PGM=IFOX00,PARM=(NOOBJ,DECK)
//SYSLIB   DD  DISP=SHR,DSN=SYS1.MACLIB
//         DD  DISP=SHR,DSN=SYS1.AMODGEN
//         DD  DISP=SHR,DSN=RAKF.MACLIB
//SYSIN    DD  DISP=SHR,DSN=SYSGEN.RAKF.V1R2M0.SRCLIB(RAKFUSER)
//SYSPUNCH DD  DISP=(OLD,PASS),DSN=&&OBJ(RAKFUSER)
//ASMPSAV  EXEC PGM=IFOX00,PARM=(NOOBJ,DECK)
//SYSLIB   DD  DISP=SHR,DSN=SYS1.MACLIB
//         DD  DISP=SHR,DSN=SYS1.AMODGEN
//         DD  DISP=SHR,DSN=RAKF.MACLIB
//SYSIN    DD  DISP=SHR,DSN=SYSGEN.RAKF.V1R2M0.SRCLIB(RAKFPSAV)
//SYSPUNCH DD  DISP=(OLD,PASS),DSN=&&OBJ(RAKFPSAV)
//RAKFUSER EXEC  PGM=IEWL,PARM='MAP,LIST,LET,NCAL,AC=1'
//SYSLMOD  DD  DISP=SHR,DSN=SYS1.LINKLIB
//SYSPUNCH DD  DISP=(OLD,PASS),DSN=&&OBJ
//SYSLIN   DD  *
 INCLUDE SYSPUNCH(RAKFUSER)
 INCLUDE SYSPUNCH(RAKFPSAV)
 ENTRY   CJYRUIDS
 NAME    RAKFUSER(R)
/*
++SRCUPD(ICHSFR00) .
><  CHANGE NAME=ICHSFR00,SSI=02020000
*                                                                   @02 00220302
*    Change History                                                 @02 00220502
*                                                                   @02 00220702
*    2011/04/03 TRKF120 base version                                @02 00222002
*    2011/04/26 RRKF002 introduce change history                    @02 00222302
*                       enable end users to change their passwords  @02 00222502
*                       permanently: store user's password change   @02 00222702
*                       request in fetch protected CSA and pass the @02 00224002
*                       request address to RAKFPWUP which queues it @02 00224302
*                       for replacement in the RAKF users table     @02 00224502
*                       at next run of RAKFUSER                     @02 00224702
*                                                                   @02 00226002
********************************************************************@02 00226302
         GETMAIN RU,LV=PWUPL,SP=227 get fetch protected CSA         @02 03702002
         MVC   0(PWUPCMDL,R1),PWUPSTRT move SVC 34 plist to CSA area@02 03704002
         L     R3,PWUPXTBA         get translate table address      @02 03706002
         USING PWUPSTRT,R1         address CSA area now             @02 03708002
         ST    R1,PWUPADDR         store CSA area address for unpack@02 03710000
         UNPK  PWUPUNPK(9),PWUPADDR(5) unpack CSA area address      @02 03712002
         MVC   PWUPAHEX(8),PWUPUNPK unpacked address to SVC 34 plist@02 03714002
         TR    PWUPAHEX(8),0(R3)   translate address to printable   @02 03716002
         DROP  R1                  revert to standard addressability@02 03718002
         MVC   PWUPCMDL(PWUPRECL,R1),PWUP initialize change record  @02 03720000
         IC    R3,0(,R5)           length of user                   @02 03722002
         BCTR  R3,0                subtract 1 for MVC               @02 03724002
         EX    R3,PWUPMVCU         copy user                        @02 03726002
         IC    R3,WORKPASS         length of new password           @02 03728002
         BCTR  R3,0                subtract 1 for MVC               @02 03730000
         EX    R3,PWUPMVCP         copy new password                @02 03732002
         XR    R0,R0               set R0 = 0 for SVC 34            @02 03734002
         SVC   34                  S RAKFPWUP,PARM='PWUPAHEX'       @02 03736002
         XC    WORKPASS+1(8),=C'SECURITY' encrypt                       03740000
         IC    R1,WORKPASS         length of new password               03750000
         EX    R1,RACIRPWD         replace password                     03760000
PWUPSTRT DC    AL2(PWUPCMDL)       parameter list to start RAKFPWUP>@02 03780000
         DC    X'0000'              >is copied to CSA subpool 227  >@02 03790000
         DC    C'S RAKFPWUP,PARM=''' >fetch protected storage with >@02 03790302
PWUPAHEX DS    CL8                  >address passed in PARM field  >@02 03790502
         DC    C''''                >in hexadecimal printable format@02 03790702
PWUPCMDL EQU   *-PWUPSTRT          length of parameter list         @02 03792002
PWUP     DS    0C                  changes queue record             @02 03792302
PWUPUSER DC    CL8' '              userid                           @02 03792502
         DC    C' '                filler                           @02 03792702
PWUPPSWD DC    CL8' '              new password                     @02 03794002
         DC    C' '                filler                           @02 03794302
PWUPRECL EQU   *-PWUP              record length of changes queue   @02 03794502
PWUPL    EQU   *-PWUPSTRT          total length of CSA area         @02 03794702
         ORG   PWUP                changes queue record is >        @02 03796002
PWUPADDR DS    F                      > temporarily used   >        @02 03796302
         DS    X                      > for conversion of  >        @02 03796502
PWUPUNPK DS    CL8                    > CSA area to        >        @02 03796702
         DS    X                      > unpacked format             @02 03798002
         ORG   PWUP+PWUPRECL       restore program counter          @02 03798302
         USING PWUPSTRT,R1         address CSA area now             @02 03798502
PWUPMVCU MVC   PWUPUSER(1),1(R5)   get user and new password >      @02 03798702
PWUPMVCP MVC   PWUPPSWD(1),WORKPASS+1  > into change queue record   @02 03799002
         DROP  R1                  revert to standard addressability@02 03799302
*                                  spaceholder blanks removed       @02 08000000
         DC    CL23' '             rest of spaceholder blanks       @02 08010000
PWUPHXTB DC    C'0123456789ABCDEF' translate RAKFPWUP address to >  @02 08020000
PWUPXTBA DC    A(PWUPHXTB-240)      > hex printable format          @02 08030000
>< ENDUP
++SRCUPD(RAKFPWUP) .
><  CHANGE NAME=RAKFPWUP,SSI=02020000
         PRINT NOGEN                                                    00030000
*                                                                       00040000
**********************************************************************  00050000
*                                                                    *  00060000
* NAME: RAKFPWUP                                                     *  00070000
*                                                                    *  00080000
* TYPE: Assembler Source                                             *  00090000
*                                                                    *  00100000
* DESC: Process Password Update Requests                             *  00110000
*                                                                    *  00120000
* FUNCTION: - retrieve username and new password from CSA area       *  00130000
*             allocated by ICHSFR00 in subpool 227 (fetch protected) *  00140000
*           - clear and free CSA area                                *  00150000
*           - append username and new password to the RAKF password  *  00160000
*             change queue, a sequential dataset with LRECL=18,      *  00170000
*             RECFM=F containing one line per password change in the *  00180000
*             following format:                                      *  00190000
*                                                                    *  00200000
*             ----+----1----+---                                     *  00210000
*             uuuuuuuu pppppppp                                      *  00220000
*                                                                    *  00230000
*             where uuuuuuuu is the username and pppppppp is the new *  00240000
*             password, each padded to the right with blanks to 8    *  00250000
*             characters.                                            *  00260000
*                                                                    *  00270000
* REQUIREMENTS: - RAKF password change queue pointed to by ddname    *  00280000
*                 RAKFPWUP using DISP=MOD in the DD statement.       *  00290000
*                                                                    *  00300000
**********************************************************************  00310000
*                                                                       00320000
* initialize                                                            00330000
*                                                                       00340000
         SAVE  (14,12),,RAKFPWUP_&SYSDATE._&SYSTIME                     00350000
         USING RAKFPWUP,R15        establish => program EP              00360000
         ST    R13,SAVEAREA+4      save HSA                             00370000
         LA    R11,SAVEAREA        establish => savearea                00380000
         ST    R11,8(R13)          save LSA                             00390000
         LR    R13,R11             setup => our savearea                00400000
         USING SAVEAREA,R13        new addressability                   00410000
         DROP  R15                 program EP no longer needed          00420000
         B     CONTINUE            branch around savearea               00430000
SAVEAREA DS    18F                 savearea                             00440000
*                                                                       00450000
* Begin of code                                                         00460000
*                                                                       00470000
CONTINUE LR    R5,R1               remember PARM plist address          00480000
         MODESET MODE=SUP,KEY=ZERO authorize ourselves                  00490000
         L     R1,0(,R5)           address of PARM field plist          00500000
         LH    R5,0(,R1)           length of PARM field                 00510000
         CH    R5,=H'8'            is PARM field length 8 characters?   00520000
         BNE   INVPARM              talk dirrty and exit if not         00530000
         MVC   ADDRHEX,2(R1)       get PARM field in check plist        00540000
         MVC   ADDRUNPK,2(R1)      get PARM field for translate         00550000
         TR    ADDRUNPK,HEXTBL     translate PARM field to zoned        00560000
         PACK  ADDRESS(5),ADDRUNPK(9) pack PARM field                   00570000
         L     R1,ADDRESS          address storage pointed to by PARM   00580000
         CLC   0(LPWUPCMD,R1),STRTPWUP parmlist from ICHSFR00 found?    00590000
         BNE   INVPARM              talk dirrty and exit if not         00600000
         MVC   PWUPUSER(8),PWUPUSER-STRTPWUP(R1) get user               00610000
         MVC   PWUPPSWD(8),PWUPPSWD-STRTPWUP(R1) get new password       00620000
         XC    0(LPWUP,R1),0(R1)   clear ICHSFR00 parmlist storage      00630000
         FREEMAIN RU,LV=LPWUP,A=ADDRESS,SP=227 free parmlist storage    00640000
         ENQ    (SECURITY,USERS,E,,SYSTEM),RET=HAVE serialization       00650000
         OPEN  (QUEUE,(OUTPUT))    open password change queue           00660000
         PUT   QUEUE,PWUP          write entry                          00670000
         CLOSE (QUEUE)             close password change queue          00680000
         DEQ   (SECURITY,USERS,,SYSTEM) release ENQ                     00690000
         MVC   SUCCESS+38(8),PWUPUSER move user into success message    00700000
         WTO   MF=(E,SUCCESS)      tell operator                        00710000
*                                                                       00720000
* return                                                                00730000
*                                                                       00740000
RETURN   MODESET MODE=PROB,KEY=NZERO return to problem state            00750000
         L     R13,SAVEAREA+4      get caller's savearea                00760000
         RETURN (14,12),,RC=0      return                               00770000
INVPARM  WTO   'RAKF006W invalid password update request ignored'       00780000
         B     RETURN                                                   00790000
*                                                                       00800000
* data area                                                             00810000
*                                                                       00820000
STRTPWUP DC    AL2(LPWUPCMD)       parameter list that must have been.. 00830000
         DC    X'0000'               .. used to start this RAKFPWUP ..  00840000
         DC    C'S RAKFPWUP,PARM=''' .. run. This is used to perform .. 00850000
ADDRHEX  DS    CL8                   .. a validity check of the CSA ..  00860000
         DC    C''''                 .. storage addressed through ..    00870000
LPWUPCMD EQU   *-STRTPWUP            .. the PARM field                  00880000
PWUP     DS    0C                  changes queue record                 00890000
PWUPUSER DC    CL8' '              userid                               00900000
         DC    C' '                filler                               00910000
PWUPPSWD DC    CL8' '              new password                         00920000
         DC    C' '                filler                               00930000
CHGLRECL EQU   *-PWUP              record length of changes queue       00940000
LPWUP    EQU   *-STRTPWUP          total length of CSA area             00950000
ADDRUNPK DS    CL8                 unpacked address                     00960000
         DC    X'C0'               sign and dummy digit                 00970000
ADDRESS  DS    F                   packed address                       00980000
         DS    X                   dummy digit and sign after pack      00990000
SECURITY DC     CL8'CJYRCVT'       resource name for ENQ                01000000
USERS    DC     CL8'CJYUSRS'       resource name for ENQ                01010000
QUEUE    DCB   DDNAME=RAKFPWUP,MACRF=PM,DSORG=PS password change queue  01020000
SUCCESS  WTO   'RAKF007I password update for user UUUUUUUU queued',MF=L 01030000
*                 0 1 2 3 4 5 6 7 8 9 A B C D E F                       01040000
HEXTBL   DC    X'00000000000000000000000000000000' 0                    01050000
         DC    X'00000000000000000000000000000000' 1                    01060000
         DC    X'00000000000000000000000000000000' 2                    01070000
         DC    X'00000000000000000000000000000000' 3                    01080000
         DC    X'00000000000000000000000000000000' 4                    01090000
         DC    X'00000000000000000000000000000000' 5 translate table    01100000
         DC    X'00000000000000000000000000000000' 6 to convert CSA     01110000
         DC    X'00000000000000000000000000000000' 7 address from PARM  01120000
         DC    X'00000000000000000000000000000000' 8 field to zoned     01130000
         DC    X'00000000000000000000000000000000' 9 format             01140000
         DC    X'00000000000000000000000000000000' A                    01150000
         DC    X'00000000000000000000000000000000' B                    01160000
         DC    X'00FAFBFCFDFEFF000000000000000000' C                    01170000
         DC    X'00000000000000000000000000000000' D                    01180000
         DC    X'00000000000000000000000000000000' E                    01190000
         DC    X'F0F1F2F3F4F5F6F7F8F9000000000000' F                    01200000
*                                                                       01210000
* equates                                                               01220000
*                                                                       01230000
         YREGS                     register equates                     01240000
         END   RAKFPWUP            end of program                       01250000
>< ENDUP
++SRCUPD(RAKFUSER) .
><  CHANGE NAME=RAKFUSER,SSI=02020000
*    2011/04/26 RRKF002 enable end users to change their passwords  @02 00223001
*                       permanently: Before updating the incore     @02 00223301
*                       users table RAKFUSER calls RAKFPSAV to      @02 00223602
*                       update UDATA with the temporary password    @02 00223902
*                       changes queued since the previous execution @02 00224202
*                                                                   @02 00224502
********************************************************************@02 00224802
*                                                                   @02 00372002
         L      R15,RAKFPSAV        get password changer address    @02 00374002
         BALR   R14,R15             call it                         @02 00376002
*                                                                   @02 00378002
RAKFPSAV DC     V(RAKFPSAV)        password change utility          @02 01673002
*                                                                   @02 01677002
>< ENDUP
++MACUPD(RAKFPWUP) .
><  CHANGE NAME=RAKFPWUP,SSI=02020000
//RAKFPWUP  DD  DSN=SYS1.SECURE.PWUP,DISP=MOD                       @02 00020002
>< ENDUP
++MACUPD(RAKFUSER) .
><  CHANGE NAME=RAKFUSER,SSI=02020000
//RAKFPWUP DD DSN=SYS1.SECURE.PWUP,DISP=SHR                         @02 00030002
>< ENDUP
++SRC(RAKFPSAV) TXLIB(ELEMENTS) DISTLIB(ASRCLIB) SYSLIB(SRCLIB) .
++MAC($$$$CUST) TXLIB(ELEMENTS) .
++MAC(RAKFRMV)  TXLIB(ELEMENTS) .
++MAC(ZJW0003)  TXLIB(ELEMENTS) .
./ ADD NAME=RRKF003  0102-11123-11123-1056-00082-00082-00000-PTF     07
++PTF(RRKF003) /*
 Security Enhancement in Users and Profiles Tables Processing */ .
++VER(Z038) FMID(TRKF120) PRE(RRKF001,RRKF002)
 /*
 Summary of Changes:
 -------------------

 + Security Enhancement in Users and Profiles Tables Processing:

   The in-core users and profiles tables which control RAKF's access
   decisions are maintained by editing source versions of these tables
   and using the utilities RAKFUSER and RAKFPROF to replace the in-core
   tables with the current source tables to activate changes.

   Although typically access to the source tables will be restricted
   to users and/or groups responsible for security administration a
   malicious user could take over control of the security environment
   by creating private versions of the source tables and running
   RAKFUSER and RAKFPROF to replace the in-core tables from the private
   source. MVS 3.8j doesn't call the security product for access
   verification through the PROGRAM class before executing a program which
   would in later versions of MVS be the way to protect the utilities from
   unauthorized use.

   PTF RRKF003 introduces a request for READ access to profile RAKFADM
   in the FACILITY class before updating the in-core tables. To prevent
   unwanted accesses to the RAKFUSER or RAKFPROF utilities define profile
   RAKFADM in the FACILITY class with universal access NONE and grant
   only RAKF administration users or groups READ access to this profile.

 Special Installation Instructions:
 ----------------------------------

 None

 */ .
++SRCUPD(RAKFPROF) .
><  CHANGE NAME=RAKFPROF,SSI=02030000
*    2011/04/29 RRKF003 if in-core PDATA table already exists check @03 00262101
*                       for READ access to profile RAKFADM in the   @03 00262401
*                       FACILITY class to ensure that only properly @03 00262703
*                       authorized users can replace the in-core    @03 00263003
*                       PDATA table                                 @03 00263303
*                                                                   @03 00263603
********************************************************************@03 00263903
*                                                                   @03 00390303
         ICM    R5,B'0111',CJYPROFS-CJYRCVTD(R8) does PDATA exist?  @03 00390603
         BZ     OK2GO                   NO, go ahead                @03 00390903
         RACHECK ENTITY=RAKFADM,CLASS='FACILITY',ATTR=READ authorize@03 00391203
         LTR    R15,R15                RAKFADM granted?             @03 00391503
         BNZ    ABEND600                NO, abend                   @03 00391803
*                                                                   @03 02122003
ABEND600 WTO    'RAKF008W illegal operation -- access denied'       @03 02124003
         WTO    'RAKF008W   ** program terminated **'               @03 02126003
         ABEND  600,,STEP                                           @03 02128003
*                                                                   @03 02491003
RAKFADM  DC     CL39'RAKFADM'      facility name to authorize       @03 02495003
*                                                                   @03 02499003
>< ENDUP
++SRCUPD(RAKFUSER) .
><  CHANGE NAME=RAKFUSER,SSI=02030000
*    2011/04/29 RRKF003 if in-core UDATA table already exists check @03 00224502
*                       for READ access to profile RAKFADM in the   @03 00224802
*                       FACILITY class to ensure that only properly @03 00225103
*                       authorized users can replace the in-core    @03 00225403
*                       UDATA table                                 @03 00225703
*                                                                   @03 00226003
********************************************************************@03 00226303
*                                                                   @03 00360303
         ICM    R5,B'0111',CJYUSERS-CJYRCVTD(R8) does UDATA exist?  @03 00360603
         BZ     OK2GO                NO, go ahead                   @03 00360903
         RACHECK ENTITY=RAKFADM,CLASS='FACILITY',ATTR=READ authorize@03 00361203
         LTR    R15,R15             RAKFADM granted?                @03 00361503
         BNZ    ABEND600             NO, abend                      @03 00361803
*                                                                   @03 00362103
OK2GO    ENQ    (SECURITY,USERS,E,,SYSTEM),RET=HAVE serialization   @03 00370000
*                                                                   @03 01582003
ABEND600 WTO    'RAKF008W illegal operation -- access denied'       @03 01584003
         WTO    'RAKF008W   ** program terminated **'               @03 01586003
         ABEND  600,,STEP                                           @03 01588003
RAKFADM  DC     CL39'RAKFADM'      facility name to authorize       @03 01675003
>< ENDUP
./ ADD NAME=RRKF004  0204-11123-11123-1100-00149-00149-00000-PTF     00
++PTF(RRKF004) /*
 RAKF User's Guide */ .
++VER(Z038) FMID(TRKF120) PRE(RRKF001,RRKF002,RRKF003)
 /*
 Summary of Changes:
 -------------------

 + RAKF User's Guide:

   RAKF documention was widespread over 5 SAMPLIB members referencing
   each other: $$$$INST, $$$$CUST, $$$$M38J, $$$$RMVE and $$$$$DOC.
   This documentation had been written at different stages of the
   evolution from the ESG Security System to RAKF and became increasingly
   difficult to read as newer parts often invalidated parts of the
   older documentation. In addition the total amount of documentation
   materials exceeds the size that can be edited with reasonable effort
   in handcrafted text files with fixed length 80 byte records.

   With this PTF the documentation is republished as the "RAKF Version 1
   Release 2 Modifaction 0 User's Guide" which is available in two
   formats:

   o Microsoft Word 2010 .docx:        The source document ("original
                                       copy") and base for further
                                       evolutions.

   o Portable Document Format (PDF/A): Display and printer friendly
                                       format intended for reading or
                                       printing the document using
                                       publicly available no-cost
                                       software (Adobe Acrobat Reader).

   These two formats are made available as member $DOC$ZIP in SAMPLIB
   which is a zip archive containing the two files "Users_Guide.docx"
   and "Users_Guide.pdf". This member is intended to be downloaded in
   binary format to the user's PC using the 3270 terminal emulation's
   file transfer function (typically based on IND$FILE) or any other
   suitable method.

   Once downloaded, the User's Guide can be extracted in the desired
   format (.pdf or .docx) using the PC's standard unzip utility for
   reading or printing using Word, Acrobat Reader or other tools
   compatible with these formats.

   With the installation of this PTF the original documentation members
   $$$$INST, $$$$CUST, $$$$M38J and $$$$RMVE become obsolete and are
   deleted from SAMPLIB. Member $$$$$DOC, which is the original
   documentation of the ESG Security System prepared by Sam Golob in
   1991, is retained in SAMPLIB as a historical reference.

 Special Installation Instructions:
 ----------------------------------

 1. This PTF modifies elements that are not provided inline. These
    elements will be read during APPLY and ACCEPT processing from
    a PDS pointed to by ddname DOCLIB. File RRKF004.doclib.zip
    contains this PDS in XMIT370 format. Before the PTF can be APPLIed
    or ACCEPTed the PDS needs to be RECEIVed with an arbitrary name and
    a //DOCLIB DD DSN=.... statement pointing to the PDS needs to
    be added to the SMP jobs used for APPLYing or ACCEPTing PTFs. After
    the PTF has been APPLIed (and ACCEPTed if desired) the PDS can be
    deleted and the //DOCLIB DD statement can be removed from the
    SMP jobs.

    The following steps can be used to RECEIVE the PDS from file
    RRKF004.doclib.zip:

    o Unzip RRKF004.doclib.xmi from RRKF004.doclib.zip and upload
      it to dataset RAKF.RRKF004.DOCLIB.XMI (LRECL=80,RECFM=FB) on
      your MVS system using your standard unzip utility and upload
      software (use binary mode for upload!)

    o Submit the following job (requires the RECV370 utility to be
      installed, of course):

      //RCVDOCS  JOB ...
      //RECV370  EXEC PGM=RECV370
      //RECVLOG   DD SYSOUT=*
      //XMITIN    DD DSN=RAKF.RRKF004.DOCLIB.XMI,DISP=SHR
      //SYSPRINT  DD SYSOUT=*
      //SYSUT1    DD DSN=&&SYSUT1,
      //             UNIT=SYSDA,
      //             SPACE=(CYL,(10,5)),
      //             DISP=(,DELETE,DELETE)
      //SYSUT2    DD DSN=RAKF.RRKF004.DOCLIB,
      //             DISP=(,CATLG),SPACE=(TRK,(30,15,1),RLSE),
      //             DCB=(LRECL=80,BLKSIZE=5600,RECFM=FB),
      //             UNIT=SYSDA
      //SYSIN     DD DUMMY
      //SYSUDUMP  DD SYSOUT=*

    The dataset names used in this example can be changed to anything
    you like as long as the //DOCLIB DD statement in the SMP APPLY
    and ACCEPT jobs points to the dataset created by //SYSUT2 DD of
    the RCVDOCS job.

 2. RECEIVE, APPLY and ACCEPT the PTF as usual.

 */ .
++MAC($$$$INFO) SSI(02040000) .
*
*    See members $$COPYRT and $$NOTICE in this library.
*
**********************************************************************
*                                                                    *
*    RAKF is based on the ESG Security System                        *
*    written by Craig J. Yasuna               (Mar 1991)             *
*    adapted to MVS 3.8J: A. Philip Dickinson (Aug 2005)             *
*                         Phil Roberts        (Apr 2011)             *
*                         Juergen Winkelmann  (Apr 2011)             *
*                                                                    *
**********************************************************************
*
*    Member $$$$$DOC in this library is the original documentation of
*    the ESG Security System as prepared by Sam Golob in 1991. It is
*    retained here as a historic reference although it is no longer
*    current in some aspects due to the changes introduced by RAKF to
*    achieve MVS 3.8j compatibility.
*
*    The current RAKF documentation is the "RAKF Version 1 Release 2
*    Modifaction 0 User's Guide" which is available in two formats:
*
*    o Microsoft Word 2010 .docx:        The source document ("original
*                                        copy") and base for further
*                                        evolutions.
*
*    o Portable Document Format (PDF/A): Display and printer friendly
*                                        format intended for reading or
*                                        printing the document using
*                                        publicly available no-cost
*                                        software (Adobe Acrobat Reader).
*
*    These two formats are available as member $DOC$ZIP in this library
*    which is a zip archive containing the two files "Users_Guide.docx"
*    and "Users_Guide.pdf". This member is intended to be downloaded in
*    binary format to the user's PC using the 3270 terminal emulation's
*    file transfer function (typically based on IND$FILE) or any other
*    suitable method.
*
*    Once downloaded, the User's Guide can be extracted in the desired
*    format (.pdf or .docx) using the PC's standard unzip utility for
*    reading or printing using Word, Acrobat Reader or other tools
*    compatible with these formats.
*
++MAC($DOC$ZIP) TXLIB(DOCLIB) DISTLIB(ASAMPLIB) SYSLIB(SAMPLIB) .
++MAC($$$$CUST) DELETE .
++MAC($$$$INST) DELETE .
++MAC($$$$M38J) DELETE .
++MAC($$$$RMVE) DELETE .
./ ADD NAME=RRKF005  0205-11131-11130-2115-00140-00140-00000-PTF     00
++PTF(RRKF005) /*
 RACIND Utility to control VSAM RACF Indicators */ .
++VER(Z038) FMID(TRKF120) PRE(RRKF001,RRKF002,RRKF003,RRKF004)
 /*
 Summary of Changes:
 -------------------

 + RACIND Utility to control VSAM RACF Indicators

   This PTF adds a new utility named RACIND to RAKF. RACIND allows
   to switch the RACF indicator of any VSAM catalog entry on or off,
   thus enabling easy indication and unindication of the system's VSAM
   catalogs and objects.

   SAMPLIB member RACIND is a sample job stream illustrating the use
   of the RACIND utility.

 Special Installation Instructions:
 ----------------------------------

 1. This PTF adds elements that are not provided inline. These
    elements will be read during APPLY and ACCEPT processing from
    a PDS pointed to by ddname RACIND. File RRKF005.racind.zip
    contains this PDS in XMIT370 format. Before the PTF can be APPLIed
    or ACCEPTed the PDS needs to be RECEIVed with an arbitrary name and
    a //RACIND DD DSN=.... statement pointing to the PDS needs to
    be added to the SMP jobs used for APPLYing or ACCEPTing PTFs. After
    the PTF has been APPLIed (and ACCEPTed if desired) the PDS can be
    deleted and the //RACIND DD statement can be removed from the
    SMP jobs.

    The following steps can be used to RECEIVE the PDS from file
    RRKF005.racind.zip:

    o Unzip RRKF005.RACIND.XMI from RRKF005.racind.zip and upload
      it to dataset RAKF.RRKF005.RACIND.XMI (LRECL=80,RECFM=FB) on
      your MVS system using your standard unzip utility and upload
      software.

    o Submit the following job (requires the RECV370 utility to be
      installed, of course):

      //RCVIND   JOB ...
      //RECV370  EXEC PGM=RECV370
      //RECVLOG   DD SYSOUT=*
      //XMITIN    DD DSN=RAKF.RRKF005.RACIND.XMI,DISP=SHR
      //SYSPRINT  DD SYSOUT=*
      //SYSUT1    DD DSN=&&SYSUT1,
      //             UNIT=SYSDA,
      //             SPACE=(CYL,(10,5)),
      //             DISP=(,DELETE,DELETE)
      //SYSUT2    DD DSN=RAKF.RRKF005.RACIND,
      //             DISP=(,CATLG),SPACE=(TRK,(6,3,1),RLSE),
      //             DCB=(LRECL=80,BLKSIZE=5600,RECFM=FB),
      //             UNIT=SYSDA
      //SYSIN     DD DUMMY
      //SYSUDUMP  DD SYSOUT=*

    The dataset names used in this example can be changed to anything
    you like as long as the //RACIND DD statement in the SMP APPLY
    and ACCEPT jobs points to the dataset created by //SYSUT2 DD of
    the RCVIND job.

 2. RECEIVE and APPLY the PTF as usual.

 3. ACCEPT the PTF according to your preferences after sufficient
    testing.
 */ .
++JCLIN .
//RRKF005  JOB 1,'RAKF 1.2',MSGLEVEL=1,CLASS=A
//*
//* JCLIN for RAKF 1.2 PTF RRKF005
//*
//ASMIND   EXEC PGM=IFOX00,PARM=(NOOBJ,DECK)
//SYSLIB   DD  DISP=SHR,DSN=SYS1.MACLIB
//         DD  DISP=SHR,DSN=SYS1.AMODGEN
//         DD  DISP=SHR,DSN=RAKF.MACLIB
//SYSIN    DD  DISP=SHR,DSN=SYSGEN.RAKF.V1R2M0.SRCLIB(RACIND)
//SYSPUNCH DD  DISP=(OLD,PASS),DSN=&&OBJ(RACIND)
//RACIND   EXEC  PGM=IEWL,PARM='MAP,LIST,LET,NCAL,AC=1'
//SYSLMOD  DD  DISP=SHR,DSN=SYS1.LINKLIB
//SYSPUNCH DD  DISP=(OLD,PASS),DSN=&&OBJ
//SYSLIN   DD  *
 INCLUDE SYSPUNCH(RACIND)
 ENTRY   RACIND
 NAME    RACIND(R)
/*
++SRC(RACIND)   TXLIB(RACIND) DISTLIB(ASRCLIB)  SYSLIB(SRCLIB)  .
++MAC(IEZCTGFL) TXLIB(RACIND) DISTLIB(AMACLIB)  SYSLIB(MACLIB)  .
++MAC(RAKFRMV)  TXLIB(RACIND) .
++MAC(RACIND)   SSI(02050000) DISTLIB(ASAMPLIB) SYSLIB(SAMPLIB) .
//RACIND   JOB
//********************************************************************
//*
//* Name: RACIND
//*
//* Desc: Run RACIND Utility
//*
//* FUNTION: Act upon control statements read from SYSIN to set or
//*          clear the RACF indicator of VSAM catalog entries. The
//*          following control statements are valid:
//*
//*          ----+----1----+----2----+----3----+----4----+----5----+
//*          CATALOG   name of catalog to search for entries
//*          RACON     name of entry to indicate
//*          RACOFF    name of entry to unindicate
//*          * Comment
//*
//*          Any number of control statements is allowed. The first
//*          none comment statement must be a CATALOG statement. A
//*          CATALOG statement remains active until a new CATALOG
//*          statement replaces it.
//*
//********************************************************************
//RACIND  EXEC PGM=RACIND
//SYSPRINT DD  SYSOUT=*
//SYSIN    DD  *
**********************************************************************
*
* Example: Switch on the RACF indicator for a VSAM catalog
*          and a cluster contained in that catalog.
*
* Note:    - The data and index components of a VSAM catalog
*            MUST NOT be RACF indicated.
*
*          - All other entry types MUST have either all of their
*            components RACF indicated or all components not
*            indicated.
*
*          For that reason in the example only one RACON statement
*          is coded for the catalog, but three for the cluster.
*
**********************************************************************
CATALOG   SYS1.UCAT.TST
RACON     SYS1.UCAT.TST
RACON     TSTCAT.CLUSTER
RACON     TSTCAT.CLUSTER.INDEX
RACON     TSTCAT.CLUSTER.DATA
/*
//
./ ADD NAME=RRKF006  0206-11171-11171-1423-00115-00115-00000-PTF     00
++PTF(RRKF006) /*
 Sample jobs to RACF indicate or unindicate the whole system */ .
++VER(Z038) FMID(TRKF120) PRE(RRKF001,RRKF002,RRKF003,RRKF004,RRKF005)
 /*
 Summary of Changes:
 -------------------

 + Sample jobs to RACF indicate or unindicate the whole system

   These jobs provide a fully automated way to set or clear the RACF
   indicators of all eligible datasets, VSAM objects and catalogs in
   the system.

 + OCO distribution of RAKF-external utilities

   The sample jobs for RACF indication or unindication need some
   utilities from other sources than RAKF. To ease installation of
   these utilities they are collected to an XMI file containing the
   modules needed and a sample job to install them from this XMI file
   is provided. The User's Guide describes the procedure to install
   these utilities as well as the original source from which they
   were derived.

 + Sample jobs for creation of SYS1.SECURE.CNTL and SYS1.SECURE.PWUP

   These jobs are provided to help with the initial customization
   tasks on systems not having interactive dataset allocation and
   or move/copy utilities available.

 + add missing //RAKFPWUP DD statement to the RAKF cataloged procedure

 + update the RAKF User's Guide with changes introduced since RRKF004

 Special Installation Instructions:
 ----------------------------------

 1. Due to the large amount of new sample and documentation material
    the space allocation of hlq.SAMPLIB and hlq.ASAMPLIB needs to be
    enlarged to avoid space related abends during installation of this
    PTF. Please reallocate these libraries to meet the following
    definitions (calculation based on 3350 type DASD):

    //ASAMPLIB DD  DISP=(,CATLG),DSN=hlq.ASAMPLIB,VOL=SER=dddddd,
    //             UNIT=SYSDA,DCB=(RECFM=FB,LRECL=80,BLKSIZE=19040),
    //             SPACE=(TRK,(120,40,10))
    //SAMPLIB  DD  DISP=(,CATLG),DSN=hlq.SAMPLIB,VOL=SER=ssssss,
    //             UNIT=SYSDA,DCB=(RECFM=FB,LRECL=80,BLKSIZE=19040),
    //             SPACE=(TRK,(120,40,10))

    Of course, the original contents needs to be copied into the
    newly allocated libraries!

 2. This PTF adds elements that are not provided inline. These
    elements will be read during APPLY and ACCEPT processing from
    a PDS pointed to by ddname RRKF006E. File RRKF006E.zip
    contains this PDS in XMIT370 format. Before the PTF can be APPLIed
    or ACCEPTed the PDS needs to be RECEIVed with an arbitrary name and
    an //RRKF006E DD DSN=.... statement pointing to the PDS needs to
    be added to the SMP jobs used for APPLYing or ACCEPTing PTFs. After
    the PTF has been APPLIed (and ACCEPTed if desired) the PDS can be
    deleted and the //RRKF006E DD statement can be removed from the
    SMP jobs.

    The following steps can be used to RECEIVE the PDS from file
    RRKF006E.zip:

    o Unzip RRKF006E.XMI from RRKF006E.zip and upload
      it to dataset RAKF.RRKF006E.XMI (LRECL=80,RECFM=FB) on
      your MVS system using your standard unzip utility and upload
      software.

    o Submit the following job (requires the RECV370 utility to be
      installed, of course):

      //RCVTLIB  JOB ...
      //RECV370  EXEC PGM=RECV370
      //RECVLOG   DD SYSOUT=*
      //XMITIN    DD DSN=RAKF.RRKF006E.XMI,DISP=SHR
      //SYSPRINT  DD SYSOUT=*
      //SYSUT1    DD DSN=&&SYSUT1,
      //             UNIT=SYSDA,
      //             SPACE=(CYL,(10,5)),
      //             DISP=(,DELETE,DELETE)
      //SYSUT2    DD DSN=RAKF.RRKF006E,
      //             DISP=(,CATLG),SPACE=(TRK,(6,3,1),RLSE),
      //             DCB=(LRECL=80,BLKSIZE=5600,RECFM=FB),
      //             UNIT=SYSDA
      //SYSIN     DD DUMMY
      //SYSUDUMP  DD SYSOUT=*

    The dataset names used in this example can be changed to anything
    you like as long as the //RRKF006E DD statement in the SMP APPLY
    and ACCEPT jobs points to the dataset created by //SYSUT2 DD of
    the RCVTLIB job.

 3. RECEIVE and APPLY the PTF as usual.

 4. ACCEPT the PTF according to your preferences after sufficient
    testing.
 */ .
++MACUPD(RAKF) .
><  CHANGE NAME=RAKF,SSI=02060000
//RAKFPWUP DD DSN=SYS1.SECURE.PWUP,DISP=SHR                         @06 00060006
>< ENDUP
++MAC($DOC$ZIP) TXLIB(RRKF006E) .
++MAC(RAKFRMV)  TXLIB(RRKF006E) .
++MAC(A@PREP)   TXLIB(RRKF006E) .
++MAC(AUXINST)  TXLIB(RRKF006E) DISTLIB(ASAMPLIB) SYSLIB(SAMPLIB) .
++MAC(AUXUTILS) TXLIB(RRKF006E) DISTLIB(ASAMPLIB) SYSLIB(SAMPLIB) .
++MAC(INITTBLS) TXLIB(RRKF006E) DISTLIB(ASAMPLIB) SYSLIB(SAMPLIB) .
++MAC(INITPWUP) TXLIB(RRKF006E) DISTLIB(ASAMPLIB) SYSLIB(SAMPLIB) .
++MAC(VSAMLRAC) TXLIB(RRKF006E) DISTLIB(ASAMPLIB) SYSLIB(SAMPLIB) .
++MAC(VSAMSRAC) TXLIB(RRKF006E) DISTLIB(ASAMPLIB) SYSLIB(SAMPLIB) .
++MAC(VTOCLRAC) TXLIB(RRKF006E) DISTLIB(ASAMPLIB) SYSLIB(SAMPLIB) .
++MAC(VTOCSRAC) TXLIB(RRKF006E) DISTLIB(ASAMPLIB) SYSLIB(SAMPLIB) .
