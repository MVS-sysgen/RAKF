//CDSCB     JOB (SYS),'INSTALL CDSCB',CLASS=A,MSGCLASS=A
//ASMCDSCB EXEC PGM=IFOX00,REGION=2048K,PARM=(NOLOAD,DECK,'LINECNT=55')
//* STEPLIB  DD  DSN=SYSC.LINKLIB,DISP=SHR
//SYSTERM  DD  SYSOUT=*
//SYSPRINT DD  SYSOUT=*
//SYSLIB   DD  DSN=SYS1.MACLIB,DISP=SHR
//         DD  DSN=SYS1.AMODGEN,DISP=SHR
//SYSUT1   DD  UNIT=SYSDA,SPACE=(TRK,(30,15))
//SYSUT2   DD  UNIT=SYSDA,SPACE=(TRK,(30,15))
//SYSUT3   DD  UNIT=SYSDA,SPACE=(TRK,(30,15))
//SYSPUNCH DD  DSN=&&SYSLIN,UNIT=SYSDA,DISP=(,PASS,DELETE),
//             SPACE=(TRK,(30,15))
//SYSIN DD *
         TITLE '    C D S C B              '
************************************************************
*                                                          *
*        'CDSCB' TSO COMMAND                               *
*                                                          *
************************************************************
         SPACE
* WRITTEN BY. BILL GODFREY
* DATE WRITTEN. MAY 20 1975.
* DATE UPDATED. FEBRUARY 22 1999.
* ATTRIBUTES. RE-ENTRANT, REFRESHABLE, REUSABLE.
* DISCLAIMER.
*  NO WARRANTY. NO GUARANTEE. INSTALL/USE USE AT YOUR OWN RISK.
* COMMENTS.
*  THIS TSO COMMAND ALTERS THE CONTENTS OF A
*  FORMAT-1 DSCB IN A VTOC.
*
*  THE DATA SET IS ALLOCATED, THEN THE VTOC OF THE
*  VOLUME CONTAINING IT IS OPENED VIA TYPE-J OPEN.
*  THE DSCB IS READ USING THE DSNAME AS A KEY. THE
*  TTR (BLOCK ADDRESS) OF THE RECORD IS RETURNED BY
*  THE READ.  THE DSCB IS RE-WRITTEN USING THE DSNAME
*  AS THE KEY, WITH THE KEY SEARCH STARTING AT THE
*  TTR ADDRESS FROM THE READ.
*
*  NOTE. UNDER VS2 MVS, A VTOC MAY BE OPENED FOR
*  UPDATE ONLY BY AUTHORIZED PROGRAMS. THEREFORE
*  THIS WILL ABEND WITH A 913-10 UNLESS THE COMMAND
*  CAN BE MADE TO RUN AUTHORIZED.
*
*  AUTHORIZE IT BY ADDING THE NAME OF THE COMMAND
*  TO THE TABLE IN MODULE IKJEFT02 CSECT IKJEFTE2.
*  OR, WRITE AN SVC AND REPLACE THE 2 'NOPR'
*  INSTRUCTIONS IN THIS PROGRAM WITH THE SVC.
*
*  04NOV77 - ADDED RECFM, DSORG, CREATE, EXPDT, UNIT
*  09DEC77 - ADDED IMPLEXEC, EXIT12
*  29MAR78 - JFCB+52 SET ON TO PREVENT WRITE-BACK
*  26JUL78 - PREFIXING DONE BY PARSE (USID)
*  22NOV78 - REMOVE LOCATE IF VOL NOT SPEC
*  24NOV78 - ADD CLEAR, PUTLINE, PUTMSG, 2ND BASE REG
*  12OCT79 - ADD GBLB, RESERVE, DEVTYPE FOR LIMCT.
*  14OCT79 - ADD STACK DELETE.
*  10APR80 - USID REMOVED FROM IKJPOSIT FOR SVS/MVT.
*  11APR80 - SHR KEYWORD ADDED.
*  25JUL80 - TESTAUTH ADDED. ASTERISK IN CREATE DATE.
*  01APR81 - ERROR MESSAGE FOR BAD DATES. COMMON EXIT PATH
*            USING STATUS. MESSAGE IF NOTHING CHANGED.
*            MORE RECFMS AND DSORGS. REFDT. FORMAT1 DSECT.
*            ALLOW TO RUN IF UNDER STARTED TASK (TSSO).
*            WTO MESSAGE FOR EXPDT CHANGES.
*  20APR81 - RACF/NORACF KEYWORDS ADDED.
*  08MAY81 - MORE RECFMS ADDED (UT UA UM).
*  29DEC81 - ADD JOB KEYWORD, PUT NAME IN DS1SYSCD.
*  07MAY86 - INSTALLED AT NOAA. NEW USERIDS IN TABLE.
*  02JUN94 - ALLOW DATES IN MM/DD/YY YY.DDD YYYY/DDD YYYY.DDD OR
*            YYDDD FORMAT, OR 0. PREVIOUSLY, ONLY YYDDD WAS ALLOWED.
*            COPIED PARSE VALIDITY CHECK ROUTINE FROM STATS COMMAND,
*            ADDED SUPPORT FOR YYYY/DDD AND 0, SO THAT CLIST
*            VARIABLES SYSCREATE AND SYSREFDATE
*            FROM LISTDSI CAN BE USED.
*  08MAR96 - ADD MSG KEYWORD
*  05JUN97 - IF NEW DSORG RECFM LRECL BLKSI SAME AS OLD, SKIP CHANGE.
*  24JUN97 - YEAR 2000 SUPPORT. YEARS > 65 (66 TO 99) SAME AS BEFORE.
*            EXCEPT 66-69 WERE PREVIOUSLY REJECTED, NOW THEY ARE OK.
*            MINIMUM YEAR CHANGED FROM 1970 TO 1966 FOR 4-DIGIT INPUT.
*            YEARS 00 THRU 65 WILL BE STORED IN DSCB AS 100 THRU 165.
*            THEY WERE PREVIOUSLY REJECTED. AS WERE 66-69.
*            HAVE NOT SEEN DOCUMENTATION FROM IBM INDICATING HOW
*            YEARS BEYOND 1999 WILL BE STORED IN THE DSCB, BUT
*            THIS LOGIC IS SIMILAR TO THE WAY IBM IS HANDLING THE
*            'TIME' MACRO RESULTS.
*  22FEB99 - CHANGE THE MM/DD/YY FORMAT TO YY/MM/DD.  ENSURE NEW
*            EXPIRY DATE IS SHOWN IN LOGGING WTO.  EXTEND MESSAGE
*            TO REPORT NEW EXPIRY DATE IN YYYY.DDD FORMAT.  CHANGE
*            WTO ROUTCDE FROM 2 TO 9 (SECURITY).  READ THE ATTENTION
*            NOTE BELOW ABOUT USING TSO OPER OR HARD-CODED USERIDS
*            LISTS.  ADJUST THE SOURCE FOR YOUR SITE BEFORE USE.  GP@P6
*  12OCT21 - REMOVED CHECK THAT CHECKED IF PROGRAM WAS RUN FROM JOB
*            FOR USE IN RAKF AUTOMATION AND ATTEMPTED TO ADD SVC244
*            CHECKING                                              @SOF
*
*  SPECIFYING 'SYSPARM(OS)' TO THE ASSEMBLER WILL CAUSE
*  A VERSION FOR OS/MVT TO BE ASSEMBLED.
*  THE VS ASSEMBLER (OR H ASSEMBLER) MUST BE USED.
         SPACE
         GBLB  &MVS
&MVS     SETB  ('&SYSPARM' NE 'OS')
         EJECT
CDSCB    START
         USING *,R10,R11
         B     @PROLOG-*(,R15)
         DC    AL1(11),CL11'CDSCB   '
         DC    CL16' &SYSDATE &SYSTIME '
@SIZE    DC    0F'0',AL1(1),AL3(@DATAL)  SUBPOOL AND LENGTH
@PROLOG  STM   14,12,12(R13)
         LR    R10,R15             1ST BASE REGISTER
         LA    R11,1(,R10)
         LA    R11,4095(,R11)      2ND BASE REGISTER
         LR    R2,R1
         USING CPPL,R2
         L     R0,@SIZE
         GETMAIN R,LV=(0)
         LR    R9,R1               SET WORKAREA POINTER
         USING @DATA,R9
         SPACE
         LR    R15,R1              POINT TO AREA TO CLEAR
         L     R1,@SIZE            GET LENGTH TO CLEAR
         LA    R0,0(,R1)           CLEAR HIGH ORDER BYTE
         SRDL  R0,8                DIVIDE BY 256
         SRL   R1,24               ISOLATE REMAINDER
         LTR   R0,R0               IS QUOTIENT ZERO
         BZ    CLEARR              YES, GO DO REMAINDER
CLEARQ   XC    0(256,R15),0(R15)   ZERO 256 BYTES
         LA    R15,256(,R15)       INCREMENT ADDRESS
         BCT   R0,CLEARQ           DECREMENT QUOTIENT AND BRANCH
CLEARR   LTR   R1,R1               IS REMAINDER ZERO?
         BZ    CLEARX              YES, BRANCH TO EXIT
         BCTR  R1,0                LENGTH MINUS 1 FOR EX
         B     *+10                GO AROUND EXECUTED INST
         XC    0(0,R15),0(R15)     EXECUTED
         EX    R1,*-6              DO THE ABOVE XC
CLEARX   EQU   *
         SPACE
         ST    R13,4(,R9)
         ST    R9,8(,R13)
         LR    R13,R9
         STM   R10,R11,BASES
         SPACE
         MVC   SIZE,@SIZE
         EJECT
         AIF   (NOT &MVS).SKIP1
         L     R1,548              PSAAOLD
         L     R15,172(,R1)        ASCBJBNI
         LTR   R15,R15             IS THIS A JOB
* LETTING THIS PROGRAM BE CALLED AS A JOB                        @SOF21
*         BNZ   IMPLEXEC            YES, QUIT
         L     R15,60(,R1)         ASCBTSB
         LTR   R15,R15             IS THIS A TSO SESSION
         BZ    PROCEED             NO, BRANCH IF STARTED TASK
.SKIP1   ANOP
AUTHID   L     R1,16               CVTPTR
         L     R15,0(,R1)          TCB WORDS CVTTCBP
         L     R15,4(,R15)         CURRENT TCB
         L     R1,180(,R15)        TCBJSCB
         L     R1,264(,R1)         JSCBPSCB
         LTR   R1,R1               ANY PSCB?
         BZ    IMPLEXEC            NO - NOT A TSO SESSION
         USING PSCB,R1
         TM    PSCBATR1,PSCBCTRL   OPERATOR                       FEB99
         BO    PROCEED             YES - PROCEED                  FEB99
         AGO   .IMPLEX                                            FEB99
* ATTENTION:                       PERSONALLY, I THINK THAT IF YOU HAVE
* =========                        TSO OPER AND RACF UPDATE TO DASDVOL,
*                                  YOU'RE PROBABLY OKAY TO PROCEED.  IF
*                                  YOU WANT TO HARD-CODE VALID USERIDS,
*                                  THEN DELETE THE 3 FEB99 LINES ABOVE.
*                                  - GREG PRICE                   FEB99
*
*        TM    PSCBATR1,PSCBCTRL   OPERATOR
*        BZ    IMPLEXEC            NO - BRANCH
*        CLC   PSCBUSER(2),SAMURAI SYSTEMS SUPPORT USERID
*        BE    PROCEED             YES, BRANCH
         LA    R15,USERIDS
AUTHLOOP CLI   0(R15),0            END OF LIST?
         BE    IMPLEXEC            YES, NOT AUTHORIZED
         CLC   PSCBUSER(7),0(R15)
         BE    PROCEED
         LA    R15,8(,R15)         POINT TO NEXT USERID
         B     AUTHLOOP            GO CHECK IT
         DROP  R1                  PSCB
*SAMURAI DC    C'SP  '
USERIDS  DC    0D'0'               ALIGN FOR EASY ZAPS
         DC    CL8'USERNAME'
         DC    CL8'USERNAME'
         DC    CL8'USERNAME'
         DC    CL8'USERNAME'
         DC    H'0'                END OF USERID LIST
.IMPLEX  ANOP
         SPACE
IMPLEXEC EQU   *
         L     R1,CPPLCBUF
         XC    2(2,R1),2(R1)       SET CBUF TO IMPLICIT EXEC
         L     R1,CPPLECT          GET ECT ADDRESS
         USING ECT,R1
         CLI   ECTSCMD,C' '        IS THIS A SUBCOMMAND
         BNE   *+10                YES - SAY SUBCOMMAND NOT FOUND
         MVC   ECTPCMD,=CL8'EXEC'  NO  - SAY COMMAND NOT FOUND
         DROP  R1                  ECT
         LR    R1,R13
         L     R0,@SIZE
         L     R13,4(,R13)
         FREEMAIN R,A=(1),LV=(0)
         L     R1,24(,R13)         RESTORE CPPL POINTER
         LA    R15,12(,R13)        POINT TO 2-WORD XCTL PARM
         XC    0(8,R15),0(R15)     CLEAR IT
         XCTL  (2,12),EP=EXEC,SF=(E,(15))
         EJECT
************************************************************
*                                                          *
*        SET UP IOPL FOR PUTLINE                           *
*                                                          *
************************************************************
         SPACE
PROCEED  LA    R15,MYIOPL
         USING IOPL,R15
         MVC   IOPLUPT(4),CPPLUPT
         MVC   IOPLECT(4),CPPLECT
         LA    R0,MYECB
         ST    R0,IOPLECB
         XC    MYECB,MYECB
         LA    R0,MYPTPB
         ST    R0,IOPLIOPB
         DROP  R15
         SPACE
         AIF   (NOT &MVS).SKIP2
         L     R15,16              LOAD CVT POINTER
         TM    444(R15),X'80'      IS PUTLINE LOADED? (VS2)
         BNO   PUTLOAD             NO - BRANCH TO LOAD
         L     R15,444(,R15)       YES - USE CVTPUTL
         B     PUTLOADX            BRANCH AROUND LOAD
.SKIP2   ANOP
PUTLOAD  LA    R0,=CL8'IKJPUTL '
         LOAD  EPLOC=(0)
         LR    R15,R0              GET ENTRY ADDRESS
         LA    R15,0(,R15)         CLEAR HI BYTE FOR DELETE ROUTINE
PUTLOADX ST    R15,MYPUTLEP        SAVE PUTLINE ENTRY ADDRESS
         EJECT
************************************************************
*                                                          *
*        SET UP PPL FOR PARSE                              *
*                                                          *
************************************************************
         SPACE
         LA    R15,MYPPL
         USING PPL,R15
         MVC   PPLUPT(4),CPPLUPT
         MVC   PPLECT(4),CPPLECT
         LA    R0,MYECB
         ST    R0,PPLECB
         XC    MYECB,MYECB
*        L     R0,=A(CDSCBPCL)
         LA    R0,PCLADDR
         ST    R0,PPLPCL
         LA    R0,MYANS
         ST    R0,PPLANS
         MVC   PPLCBUF(4),CPPLCBUF
         ST    R9,PPLUWA
         DROP  R15                 PPL
         SPACE 1
************************************************************
*                                                          *
*        CALL THE PARSE SERVICE ROUTINE                    *
*                                                          *
************************************************************
         SPACE 1
         LR    R1,R15              POINT TO PPL
         AIF   (NOT &MVS).SKIP3
         L     R15,16              CVTPTR
         TM    524(R15),X'80'      IF HI ORDER BIT NOT ON
         BNO   PARSELNK               THEN DO LINK, NOT CALL
         L     R15,524(,R15)       CVTPARS
         BALR  R14,R15             CALL IKJPARS
         B     PARSEEXT            SKIP AROUND LINK
PARSELNK EQU   *
.SKIP3   ANOP
         LINK  EP=IKJPARS,SF=(E,LINKAREA)
PARSEEXT EQU   *
         SPACE 1
         LTR   R15,R15
         BNZ   PARSERR
         EJECT
         L     R12,MYANS
         USING IKJPARMD,R12
         SPACE
************************************************************
*                                                          *
*        PROCESS THE 'ZAP' PARAMETER'                      *
*                                                          *
************************************************************
         SPACE
         CLI   ZAPKW+1,0           ZAP SPECIFIED?
         BE    NOREP               NO - BRANCH
         TM    REP+6,X'80'         ZAP SPECIFIED?
         BZ    NOREP
         CLI   REP+8,X'FF'         ONLY ONE REP PARAMETER?
         BE    INVREP              YES - ERROR - BRANCH
         MVC   OFFSET(5),=XL5'00'
         LA    R1,OFFSET
         CLI   REP+5,4
         BE    MOVEOFF
         CLI   REP+5,2
         BNE   INVREP              OFFSET MUST BE 2 OR 4 CHARS
         LA    R1,OFFSET+1
MOVEOFF  L     R14,REP             REG 14 --> OFFSET
         LH    R15,REP+4           REG 15  =  LENGTH (2 OR 4)
         BCTR  R15,0
         B     *+10
         MVC   0(0,R1),0(R14)      MOVE 1ST REP TO OFFSET
         EX    R15,*-6
         SPACE
         LH    R0,REP+4
         SRL   R0,1                CUT LENGTH IN HALF
         BAL   R14,PACK            CONVERT TO BINARY
         CLI   OFFSET+1,44+1       OFFSETS START WITH X'2D'
         BL    REPOERR             IF LESS ISSUE MESSAGE
         SPACE
         L     R6,REP+8            REG 6 --> NEXT PDE IN LIST (VER DATA
         L     R14,0(,R6)          REG 14 --> VERDATA
         LH    R15,4(,R6)          REG 15  =  LENGTH
         BCTR  R15,0
         B     *+10
         MVC   VERDATA+1(0),0(R14) MOVE 2ND REP TO VERDATA
         EX    R15,*-6
         LH    R0,4(,R6)
         SRL   R0,1                CUT LENGTH IN HALF
         BCTR  R0,0
         STC   R0,VERDATA
         LH    R0,4(,R6)
         SRL   R0,1                CUT LENGTH IN HALF
         LA    R1,VERDATA+1
         BAL   R14,PACK
         SR    R14,R14
         IC    R14,VERDATA         R14 = LEN-1 OF VERDATA
         AH    R14,OFFSET
         CH    R14,ENDOFREC        BEYOND END OF RECORD?
         BH    REPVERR             YES - ISSUE MESSAGE
         SPACE
         CLI   8(R6),X'FF'         3RD REP (REPDATA) SPECIFIED?
         MVI   VR,C'V'
         BE    REPX
         L     R6,8(,R6)           REG 6 --> NEXT PDE (REP DATA)
         MVI   VR,C'R'
         L     R14,0(,R6)          REG 14 --> REPDATA
         LH    R15,4(,R6)          R15  =  LENGTH
         BCTR  R15,0
         B     *+10
         MVC   REPDATA+1(0),0(R14) MOVE 3RD REP TO REPDATA
         EX    R15,*-6
         LH    R0,4(,R6)
         SRL   R0,1                CUT LENGTH IN HALF
         BCTR  R0,0
         STC   R0,REPDATA
         LH    R0,4(,R6)
         SRL   R0,1                CUT LENGTH IN HALF
         LA    R1,REPDATA+1
         BAL   R14,PACK
         CLC   VERDATA(1),REPDATA  COMPARE LENGTHS
         BL    REPDERR             VER DATA MUST NOT BE SHORTER
REPX     EQU   *
NOREP    EQU   *
         SPACE
************************************************************
*                                                          *
*        PROCESS THE 'RECFM' KEYWORD                       *
*                                                          *
************************************************************
         SPACE
         LH    R1,RECFM            GET RECFM
         LTR   R1,R1               RECFM SPECIFIED?
         BZ    NOREC               NO - BRANCH
         IC    R14,RECFMTAB(R1)    GET RECFM BITS
         STC   R14,NEWRECFM        SAVE NEW RECFM
         MVI   NEWRECSW,C'R'       SET SWITCH ON
NOREC    EQU   *
         SPACE
************************************************************
*                                                          *
*        PROCESS THE 'BLKSIZE' KEYWORD                     *
*                                                          *
************************************************************
         SPACE
         CLI   BLKKW+1,0           BLKSIZE SPECIFIED?
         BE    NOBLK               NO - BRANCH
         TM    BLK+6,X'80'         VALUE PRESENT?
         BZ    NOBLK               NO - BRANCH
         LH    R14,BLK+4           GET LENGTH
         LTR   R14,R14             LENGTH ZERO?
         BZ    NOBLK               YES - BRANCH
         L     R1,BLK              POINT TO VALUE
         BCTR  R14,0
         B     *+10
         PACK  DOUBLE(8),0(0,R1)
         EX    R14,*-6
         CVB   R1,DOUBLE           GET BINARY VALUE
         C     R1,=F'32767'        TOO LARGE?
         BNH   *+8                 NO - BRANCH
         L     R1,=F'32767'        YES - REDUCE IT
         STH   R1,NEWBLK           SAVE IT
         MVI   NEWBLKSW,C'B'       SET SWITCH ON
NOBLK    EQU   *
         SPACE
************************************************************
*                                                          *
*        PROCESS THE 'LRECL' KEYWORD                       *
*                                                          *
************************************************************
         SPACE
         CLI   LREKW+1,0           LRECL SPECIFIED?
         BE    NOLRE               NO - BRANCH
         TM    LRE+6,X'80'         VALUE PRESENT?
         BZ    NOLRE               NO - BRANCH
         LH    R14,LRE+4           GET LENGTH
         LTR   R14,R14             LENGTH ZERO?
         BZ    NOLRE               YES - BRANCH
         L     R1,LRE              POINT TO VALUE
         BCTR  R14,0
         B     *+10
         PACK  DOUBLE(8),0(0,R1)
         EX    R14,*-6
         CVB   R1,DOUBLE           GET BINARY VALUE
         C     R1,=F'32767'        TOO LARGE?
         BNH   *+8                 NO - BRANCH
         L     R1,=F'32767'        YES - REDUCE IT
         STH   R1,NEWLRE           SAVE IT
         MVI   NEWLRESW,C'L'       SET SWITCH ON
NOLRE    EQU   *
         SPACE
************************************************************
*                                                          *
*        PROCESS THE 'DSORG' KEYWORD                       *
*                                                          *
************************************************************
         SPACE
         LH    R1,DSORG            GET DSORG
         LTR   R1,R1               DSORG SPECIFIED?
         BZ    NODSO               NO - BRANCH
         IC    R14,DSORGTAB(R1)    GET DSORG BITS
         STC   R14,NEWDSORG        SAVE NEW DSORG
         MVI   NEWDSORG+1,0        NEW DSORG PART 2
         MVI   NEWDSOSW,C'R'       SET SWITCH ON
NODSO    EQU   *
         SPACE
************************************************************
*                                                          *
*        PROCESS THE PROTECTION KEYWORDS                   *
*                                                          *
************************************************************
         SPACE
         CLI   PROKW+1,0           ANY PROTECTION KEYWORDS?
         BE    NOPRO               NO - BRANCH
         MVI   NEWPRO0,X'FF'       START WITH NO BITS TO SET OFF
         MVI   NEWPRO1,X'00'              AND NO BITS TO SET ON.
         CLI   PROKW+1,2           'PW' OR 'PWREAD'?
         BH    PRO3                NO - BRANCH
         MVI   NEWPRO0,B'11111011' SET OFF 1 BIT
         MVI   NEWPRO1,B'00010000' SET ON 1 BIT
         B     PROX
PRO3     CLI   PROKW+1,3           'PWWRITE'?
         BNE   PRO4                NO - BRANCH
         MVI   NEWPRO1,B'00010100' SET ON 2 BITS
         B     PROX
PRO4     CLI   PROKW+1,4           'NOPW'?
         BNE   PRO5                NO - BRANCH
         MVI   NEWPRO0,B'11101011' SET OFF 2 BITS
         B     PROX
PRO5     CLI   PROKW+1,5           'RACF'
         BNE   PRO6
         MVI   NEWPRO1,X'40'       SET ON 1 BIT
         B     PROX
PRO6     CLI   PROKW+1,6           'NORACF'
         BNE   NOPRO
         MVI   NEWPRO0,255-X'40'   SET OFF 1 BIT
PROX     MVI   NEWPROSW,C'P'       SET SWITCH ON
NOPRO    EQU   *
         SPACE
************************************************************
*                                                          *
*        PROCESS THE 'ALLOC' KEYWORD                       *
*                                                          *
************************************************************
         SPACE
         CLI   ALLKW+1,0           'ALLOC' SPECIFIED?
         BE    NOALL               NO - BRANCH
         CLI   ALL+1,0             ANY SUBKEYWORDS?
         BE    NOALL               NO - BRANCH
         MVI   NEWALL0,X'FF'       START WITH NO BITS TO SETOFF
         MVI   NEWALL1,X'00'              AND NO BITS TO SETON
         CLI   ALL+1,1             'NONE'?
         BNE   ALL2                NO - BRANCH
         MVI   NEWALL0,B'00111111' SET OFF 2 BITS
         B     ALLX
ALL2     CLI   ALL+1,2             'BLOCKS'
         BNE   ALL3                NO - BRANCH
         MVI   NEWALL0,B'01111111' SET OFF 1 BIT
         MVI   NEWALL1,B'01000000' SET ON 1 BIT
         B     ALLX
ALL3     CLI   ALL+1,3             'TRACKS'
         BNE   ALL4                NO - BRANCH
         MVI   NEWALL0,B'10111111' SET OFF 1 BIT
         MVI   NEWALL1,B'10000000' SET ON 1 BIT
         B     ALLX
ALL4     CLI   ALL+1,4             'CYLINDERS'
         BNE   NOALL               NO - BRANCH
         MVI   NEWALL1,B'11000000' SET ON 2 BITS
ALLX     MVI   NEWALLSW,C'A'       SET ON SWITCH
NOALL    EQU   *
         SPACE
************************************************************
*                                                          *
*        PROCESS THE 'SPACE' PARAMETER                     *
*                                                          *
************************************************************
         SPACE
         CLI   SPAKW+1,0           SPACE SPECIFIED?
         BE    NOSPA               NO - BRANCH
         TM    SPA+6,X'80'         VALUE PRESENT?
         BZ    NOSPA               NO - BRANCH
         LH    R14,SPA+4           GET LENGTH
         LTR   R14,R14             LENGTH ZERO?
         BZ    NOSPA               YES - BRANCH
         L     R1,SPA              POINT TO VALUE
         BCTR  R14,0
         B     *+10
         PACK  DOUBLE(8),0(0,R1)
         EX    R14,*-6
         CVB   R1,DOUBLE           GET BINARY VALUE
         C     R1,=F'32767'        TOO LARGE?
         BNH   *+8                 NO - BRANCH
         L     R1,=F'32767'        YES - REDUCE IT
         ST    R1,NEWSPA           SAVE IT
         MVI   NEWSPASW,C'S'       SET SWITCH ON
NOSPA    EQU   *
         EJECT
************************************************************
*                                                          *
*        PROCESS THE 'CREATE' KEYWORD                      *
*                                                          *
************************************************************
         SPACE
         CLI   CREATEKW+1,0        CREATE SPECIFIED?
         BE    CREATEX             NO - BRANCH
         TM    CREATE+6,X'80'      VALUE PRESENT?
         BZ    CREATEX             NO - BRANCH
         L     R15,CDATE
         SR    R14,R14
         D     R14,=F'1000'        GET REMAINDER DDD IN R14, YY IN R15
         SLL   R15,16              00YY0000
         OR    R15,R14             00YY0DDD
         ST    R15,NEWCRE          SAVE NEW CREATION DATE
         MVI   NEWCRESW,C'C'       SET SWITCH ON
CREATEX  EQU   *
         EJECT
************************************************************
*                                                          *
*        PROCESS THE 'EXPDT' KEYWORD                       *
*                                                          *
************************************************************
         SPACE
         CLI   EXPDTEKW+1,0        EXPDTE SPECIFIED?
         BE    NOEXP               NO - BRANCH
         TM    EXPDTE+6,X'80'      VALUE PRESENT?
         BZ    NOEXP               NO - BRANCH
         L     R15,EDATE
         CVD   R15,DOUBLE          SAVE NEW EXPIRY DATE FOR WTO   FEB99
         AP    DOUBLE,=P'1900000'                                 FEB99
         OI    DOUBLE+7,X'0F'                                     FEB99
         UNPK  EXPCH,DOUBLE                                       FEB99
         MVC   EXPCH(4),EXPCH+1                                   FEB99
         MVI   EXPCH+4,C'.'        RETAIN NEW YYYY.DDD            FEB99
         SR    R14,R14
         D     R14,=F'1000'        GET REMAINDER DDD IN R14, YY IN R15
         SLL   R15,16              00YY0000
         OR    R15,R14             00YY0DDD
         ST    R15,NEWEXP          SAVE NEW EXPIRATION DATE
         MVI   NEWEXPSW,C'C'       SET SWITCH ON
NOEXP    EQU   *
         EJECT
************************************************************
*                                                          *
*        PROCESS THE 'REFDT' KEYWORD                       *
*                                                          *
************************************************************
         SPACE
         CLI   REFDTEKW+1,0        REFDT SPECIFIED?
         BE    REFDTEX             NO - BRANCH
         TM    REFDTE+6,X'80'      VALUE PRESENT?
         BZ    REFDTEX             NO - BRANCH
         L     R15,RDATE
         SR    R14,R14
         D     R14,=F'1000'        GET REMAINDER DDD IN R14, YY IN R15
         SLL   R15,16              00YY0000
         OR    R15,R14             00YY0DDD
         ST    R15,NEWREF          SAVE NEW REFERENCED DATE
         MVI   NEWREFSW,C'C'       SET SWITCH ON
REFDTEX  EQU   *
         EJECT
************************************************************
*                                                          *
*        PROCESS THE 'JOB' KEYWORD                         *
*                                                          *
************************************************************
         SPACE
         MVC   JOBNAME(8),=CL8' '
         MVI   JOBNAME+8,X'FF'
         CLI   JOBKW+1,0           JOB SPECIFIED?
         BE    JOBX                NO - BRANCH
         TM    JOBNME+6,X'80'      VALUE PRESENT?
         BZ    JOBX                NO - BRANCH
         LH    R14,JOBNME+4        GET LENGTH
         L     R1,JOBNME           POINT TO VALUE
         BCTR  R14,0
         B     *+10
         MVC   JOBNAME(0),0(R1)
         EX    R14,*-6
         CLC   JOBNAME(8),=CL8'IBM'  SPECIAL JOBNAME
         BNE   JOBX
         MVC   JOBNAME(9),=C'IBMOSVS2 '
JOBX     EQU   *
         EJECT
************************************************************
*                                                          *
*        PROCESS THE DSNAME PARAMETER                      *
*                                                          *
************************************************************
         SPACE
         LA    R1,DSN
         L     R8,0(,R1)           R8  -> DSNAME
         LH    R7,4(,R1)           R7  =  LENGTH
         LTR   R7,R7               IS LENGTH ZERO?
         BZ    ERRDSN              YES, WAS (MEMBER) ONLY
         LR    R6,R7
         MVI   DSNAME,C' '
         MVC   DSNAME+1(43),DSNAME
         SLR   R14,R14
         AIF   (&MVS).SKIP4        PREFIX DSNAME WITH USERID
         TM    6(R1),X'40'         IS DSN QUOTED?
         BO    DSNQUOTE
         SPACE
*
*              GET THE USERID AND PREFIX THE DSNAME
*
         SPACE
         L     R15,CPPLPSCB
         USING PSCB,R15
         IC    R14,PSCBUSRL        LENGTH OF PREFIX
         LTR   R14,R14             NOPREFIX
         BZ    DSNQUOTE            SAME AS QUOTED
         LA    R6,1(R14,R6)        R6 = TOTAL LEN
         MVC   DSNAME(7),PSCBUSER
         DROP  R15                 UPT
         LA    R14,DSNAME(R14)
         MVI   0(R14),C'.'         ADD PERIOD
         LA    R14,1(,R14)         PERIOD LENGTH
         B     *+8
.SKIP4   ANOP
DSNQUOTE LA    R14,DSNAME(R14)
         BCTR  R7,0
         B     *+10
         MVC   0(0,R14),0(R8)
         EX    R7,*-6
         STH   R6,DSNAMEL
         EJECT
************************************************************
*                                                          *
*        PROCESS THE VOLUME PARAMETER                      *
*                                                          *
************************************************************
         SPACE
         MVC   WRKUNIT,=CL8' '
         MVC   WRKVOL(6),=CL8' '
         TM    VOL+6,X'80'         VOLUME SPECIFIED?
         BZ    NOVOL               NO - BRANCH
         L     R14,VOL             R14 --> VOLUME
         LH    R15,VOL+4           R15  =  LENGTH
         BCTR  R15,0
         B     *+10
         MVC   WRKVOL(0),0(R14)
         EX    R15,*-6
         SPACE
************************************************************
*                                                          *
*        IF VOLUME SPECIFIED, CHECK FOR UNIT PARAMETER     *
*                                                          *
************************************************************
         SPACE
         TM    UNIT+6,X'80'        UNIT SPECIFIED?
         BZ    NOUNIT              NO - BRANCH
         L     R14,UNIT            POINT TO UNIT NAME
         LH    R15,UNIT+4          LENGTH OF UNIT NAME
         BCTR  R15,0
         B     *+10
         MVC   WRKUNIT(0),0(R14)
         EX    R15,*-6
NOUNIT   EQU   *
NOVOL    EQU   *
         EJECT
************************************************************
*                                                          *
*        CALL DYNAMIC ALLOCATION                           *
*                                                          *
************************************************************
         SPACE
DYNALLOC EQU   *
         LA    R1,MYDAPL
         USING DAPL,R1
         MVC   DAPLUPT(4),CPPLUPT
         MVC   DAPLECT(4),CPPLECT
         LA    R0,MYECB
         ST    R0,DAPLECB
         MVC   DAPLPSCB(4),CPPLPSCB
         LA    R0,MYDAPB
         ST    R0,DAPLDAPB
         SPACE
         XC    MYECB,MYECB
         L     R15,DAPLDAPB
         USING DAPB08,R15
         XC    0(84,R15),0(R15)
         MVI   DA08CD+1,X'08'
         LA    R14,DA08DDN
         MVI   0(R14),X'40'
         MVC   1(23,R14),0(R14)  DD,UNIT,VOL
         MVC   DA08SER(6),WRKVOL
         MVC   DA08UNIT(8),WRKUNIT
         MVC   DA08MNM(16),0(14)
         MVC   DA08ALN(8),0(R14)
         LA    R0,DSNAMEL
         ST    R0,DA08PDSN
         MVI   DA08DSP1,DA08OLD
         CLI   SHRKW+1,0           'SHR' SPECIFIED ?
         BE    *+8                 BRANCH IF NOT
         MVI   DA08DSP1,DA08SHR    'SHR' SPECIFIED
         MVI   DA08DPS2,DA08KEEP
         MVI   DA08DPS3,DA08KEP
         BAL   R14,CALLDAIR
         SPACE
         LTR   R15,R15
         BNZ   DAIRERR
         OI    STATUS,STATA        INDICATE ALLOCATED
         EJECT
************************************************************
*                                                          *
*        SET UP THE DCB                                    *
*                                                          *
************************************************************
         SPACE
         MVC   DCB(DCBLEN),DCBMODEL
         LA    R15,MYDAPB
         LA    R3,DCB
         USING IHADCB,R3
         MVC   DCBDDNAM(8),DA08DDN
         LA    R15,JFCB
         ST    R15,EXLSTD
         MVI   EXLSTD,X'87'
         LA    R15,EXLSTD
         IC    R14,DCBEXLST
         ST    R15,DCBEXLST        SET DCB EXLST=EXLSTD
         STC   R14,DCBEXLST
         SPACE
************************************************************
*                                                          *
*        READ THE JFCB                                     *
*                                                          *
************************************************************
         SPACE
         MVC   RDJFCBD,RDJFCB
         RDJFCB ((R3)),MF=(E,RDJFCBD)
         SPACE
************************************************************
*                                                          *
*        DEFER ATTENTION INTERRUPTS                        *
*                                                          *
************************************************************
         SPACE
         MVC   STAXD(20),STAXDEF
         STAX  DEFER=YES,MF=(E,STAXD)
         SPACE
************************************************************
*                                                          *
*        INSTALLATION-DEPENDENT CODE                       *
*        TO GET AROUND ABEND 913-10                        *
*                                                          *
************************************************************
         SPACE
         L     1,16
         L     1,0(,1)
         L     1,4(,1)             R1 --> TCB
         L     4,180(,1)           R4 --> JSCB
         TM    236(4),X'01'        ARE WE AUTHORIZED
         BO    KEY0X               YES, BYPASS AUTHSET
         LA    0,0                 R0 = FUNCTION CODE FOR USER SVC
         LA    15,KEY0A            R15 POINTS TO ROUTINE TO BE CALLED
         LA    1,1                 ATTEMPT TO ADD SVC AUTH       @SOF21
         SVC   244                 ATTEMPT TO ADD SVC AUTH       @SOF21
         NOPR  0                   *** REPLACE WITH USER SVC ***
         B     KEY0B               BRANCH AROUND ROUTINE
KEY0A    OI    236(4),X'01'        SET ON JSCBAUTH
         BR    14                  RETURN TO SVC
KEY0B    OI    STATUS,STATM        INDICATE AUTH HAS BEEN CHANGED
KEY0X    EQU   *
         SPACE
         AIF   (NOT &MVS).SKIP5    TESTAUTH
         TESTAUTH FCTN=1
         LTR   R15,R15
         BNZ   AUTHERR
.SKIP5   ANOP
         SPACE
************************************************************
*                                                          *
*        OPEN THE VTOC                                     *
*                                                          *
************************************************************
         SPACE
         DEVTYPE DCBDDNAM,DEVAREA,DEVTAB
         SPACE
         LH    R1,DEVAREA+10       TRACKS PER CYL
         MH    R1,=H'5'            ASSUME 5 CYLINDER VTOC
         STH   R1,TRACKS
         SPACE
         GETPOOL (R3),2,96
         SPACE
         OI    STATUS,STATG        INDICATE GETPOOL ISSUED
         MVI   JFCB,X'04'
         MVC   JFCB+1(43),JFCB
         OI    JFCB+52,X'08'       DO NOT WRITE BACK      29MAR78
         MVC   OPENJD,OPENJ
         OPEN  ((R3),UPDAT),TYPE=J,MF=(E,OPENJD)
         TM    DCBOFLGS,X'10'
         BZ    OPENERR
         OI    STATUS,STATO        INDICATE OPENED
         EJECT
************************************************************
*                                                          *
*        ENQ ON THE VTOC                                   *
*                                                          *
************************************************************
         SPACE
         L     R1,DCBDEBAD         POINT TO DEB
         L     R1,32(,R1)          POINT TO UCB
         ST    R1,UCBAD            STORE UCB ADDRESS
         MVC   RNAME,28(R1)        MOVE VOLUME TO RNAME
         MVC   QNAME,=CL8'SYSVTOC'
         MVC   RW(RL),R            MOVE MF=L TO WORK AREA
         SPACE
         RESERVE (QNAME,RNAME,E,6,SYSTEMS),RET=HAVE,UCB=UCBAD,MF=(E,RW)
         SPACE
         OI    STATUS,STATQ        INDICATE ENQ ACTIVE
         SPACE
************************************************************
*                                                          *
*        READ THE FORMAT 1 DSCB USING DSNAME AS KEY        *
*                                                          *
************************************************************
         SPACE
         GETBUF (R3),(R4)
         SPACE
         LH    R1,TRACKS
         STH   R1,DCBLIMCT+1
         MVC   READDECB(READL),DECBMODR
         MVC   TTR(3),=X'000001'
         SPACE
         READ  READDECB,DKF,(R3),(R4),'S',DSNAME,TTR,MF=E
         SPACE
         MVI   SYNADSWT,0
         SPACE
         CHECK READDECB
         SPACE
         CLI   SYNADSWT,0          SYNAD EXIT TAKEN?
         BNE   READERR             YES - BRANCH
         L     R4,READDECB+12      R4 --> AREA ADDRESS
         LR    R5,R4
         SH    R5,=H'44'           R5 --> IMAGINARY KEY-DATA AREA
         USING FORMAT1,R5
         SPACE
************************************************************
*                                                          *
*        VERIFY                                            *
*                                                          *
************************************************************
         SPACE
         CLI   VR,0                REP SPECIFIED?
         BE    VRX                 NO - BRANCH
         LR    R1,R5
         AH    R1,OFFSET           R1 --> LOCATION OF VICTIM
         SR    R14,R14
         IC    R14,VERDATA
         B     *+10
         CLC   0(0,R1),VERDATA+1
         EX    R14,*-6             COMPARE VICTIM TO VER DATA
         BNE   VERREJ              NOT EQUAL - REJECT
         SPACE
         CLI   VR,C'R'             WAS REP DATA SPECIFIED?
         BE    REPROUT             YES - BRANCH
         LA    R1,=C'VERIFIED'
         LA    R0,8
         BAL   R14,PUTMSG
         SPACE
         B     VRX
         SPACE
************************************************************
*                                                          *
*        REPLACE                                           *
*                                                          *
************************************************************
         SPACE
REPROUT  IC    R14,REPDATA
         B     *+10
         MVC   0(0,R1),REPDATA+1
         EX    R14,*-6              MOVE REP DATA TO RECORD
         MVI   CHANGED,C'C'         SET CHANGED SWITCH
VRX      EQU   *
         SPACE
         CLI   NEWRECSW,0          RECFM SPECIFIED?
         BE    NURECX              NO - BRANCH
         CLC   DS1RECFM,NEWRECFM   IF SAME AS OLD
         BE    NURECX                 LEAVE CHANGE SWITCH OFF
         MVC   DS1RECFM,NEWRECFM   MOVE IN NEW RECFM
         MVI   CHANGED,C'C'        SET SWITCH ON
NURECX   EQU   *
         SPACE
         CLI   NEWDSOSW,0          DSORG SPECIFIED?
         BE    NUDSOX              NO - BRANCH
         CLC   DS1DSORG,NEWDSORG   IF SAME AS OLD
         BE    NUDSOX                 LEAVE CHANGE SWITCH OFF
         MVC   DS1DSORG,NEWDSORG   MOVE IN NEW DSORG
         MVI   CHANGED,C'C'        SET SWITCH ON
NUDSOX   EQU   *
         SPACE
         CLI   NEWBLKSW,0          BLKSIZE SPECIFIED?
         BE    NUBLKX              NO - BRANCH
         CLC   DS1BLKL,NEWBLK      IF SAME AS OLD
         BE    NUBLKX                 LEAVE CHANGE SWITCH OFF
         MVC   DS1BLKL,NEWBLK      MOVE IN NEW BLKSIZE
         MVI   CHANGED,C'C'        SET SWITCH ON
NUBLKX   EQU   *
         SPACE
         CLI   NEWLRESW,0          LRECL SPECIFIED?
         BE    NULREX              NO - BRANCH
         CLC   DS1LRECL,NEWLRE     IF SAME AS OLD
         BE    NULREX                 LEAVE CHANGE SWITCH OFF
         MVC   DS1LRECL,NEWLRE     MOVE IN NEW LRECL
         MVI   CHANGED,C'C'        SET SWITCH ON
NULREX   EQU   *
         SPACE
         CLI   NEWPROSW,0          PROTECTION MODIFIED?
         BE    NUPROX              NO - BRANCH
         MVC   NEWPROSV,DS1DSIND   HOLD A COPY
         NC    DS1DSIND,NEWPRO0    SET REQUIRED BITS OFF
         OC    DS1DSIND,NEWPRO1    SET REQUIRED BITS ON
         CLC   NEWPROSV,DS1DSIND   ANY CHANGE?
         BE    *+8                 NO - LEAVE SWITCH OFF
         MVI   CHANGED,C'C'        YES - SET SWITCH ON
NUPROX   EQU   *
         CLI   NEWALLSW,0          SEC. ALLOCATION ALTERED?
         BE    NUALLX              NO - BRANCH
         MVC   NEWPROSV,DS1SCALO   HOLD A COPY
         NC    DS1SCALO(1),NEWALL0 SET REQUIRED BITS OFF
         OC    DS1SCALO(1),NEWALL1 SET REQUIRED BITS ON
         CLC   NEWPROSV,DS1SCALO   ANY CHANGE?
         BE    *+8                 NO - LEAVE SWITCH OFF
         MVI   CHANGED,C'C'        YES - SET SWITCH ON
NUALLX   EQU   *
         CLI   NEWSPASW,0          SPACE SPECIFIED?
         BE    NUSPAX              NO - BRANCH
         MVC   DS1SCALO+1(3),NEWSPA+1 MOVE IN NEW SPACE
         MVI   CHANGED,C'C'        SET SWITCH ON
NUSPAX   EQU   *
         SPACE
         CLI   NEWCRESW,0          CREATE SPECIFIED?
         BE    NUCREX              NO - BRANCH
         MVC   DS1CREDT,NEWCRE+1   MOVE IN NEW CREATION DATE
         MVI   CHANGED,C'C'        SET SWITCH ON
NUCREX   EQU   *
         SPACE
         MVI   EXPSW,X'FF'
         CLI   NEWEXPSW,0          EXPDT SPECIFIED?
         BE    NUEXPX              NO - BRANCH
         CLC   DS1EXPDT,NEWEXP+1   IS IT ALREADY THAT VALUE
         BE    NUEXPX              YES, BRANCH
         MVC   DS1EXPDT,NEWEXP+1   MOVE IN NEW EXPIRATION DATE
         MVI   CHANGED,C'C'        SET SWITCH ON
         MVI   EXPSW,1             INDICATE NEW EXPDT
         CLC   NEWEXP+1(3),=AL3(0)
         BNE   *+8
         MVI   EXPSW,0             INDICATE NEW EXPDT ZERO
NUEXPX   EQU   *
         SPACE
         CLI   NEWREFSW,0          REFDT SPECIFIED?
         BE    NUREFX              NO - BRANCH
         CLC   DS1REFD,NEWREF+1    IS IT ALREADY THAT VALUE
         BE    NUREFX              YES, BRANCH
         MVC   DS1REFD,NEWREF+1    MOVE IN NEW REFERENCE DATE
         MVI   CHANGED,C'C'        SET SWITCH ON
NUREFX   EQU   *
         SPACE
         CLI   JOBNAME,C' '        JOB SPECIFIED?
         BE    NUJOBX              NO - BRANCH
         CLC   DS1SYSCD(9),JOBNAME IS IT ALREADY THAT VALUE
         BE    NUJOBX              YES, BRANCH
         MVC   DS1SYSCD(9),JOBNAME MOVE IN NEW JOB NAME
         MVI   CHANGED,C'C'        SET SWITCH ON
NUJOBX   EQU   *
         SPACE
         DROP  R5                  FORMAT1
         CLI   CHANGED,0           ANYTHING CHANGED?
         BNE   REWRITE             YES, GO REWRITE THE DSCB
         CLI   MSGKW+1,2           NOMSG
         BE    NOMSG1
         LA    R1,SAMEMSG
         LA    R0,L'SAMEMSG
         BAL   R14,PUTMSG
NOMSG1   EQU   *
         B     EXIT0
SAMEMSG  DC    C'NOTHING CHANGED'
         SPACE
************************************************************
*                                                          *
*        REWRITE THE FORMAT 1 DSCB                         *
*                                                          *
************************************************************
         SPACE
REWRITE  MVC   WRITDECB(WRITEL),DECBMODW
         WRITE WRITDECB,DK,(R3),(R4),,DSNAME,TTR,MF=E
         SPACE
         MVI   SYNADSWT,0
         SPACE
         CHECK WRITDECB
         SPACE
         CLI   SYNADSWT,0          SYNAD EXIT TAKEN?
         BNE   WRITERR             YES - BRANCH
TEMPJUMP EQU   *
         CLI   MSGKW+1,2           NOMSG
         BE    NOMSG2
         LA    R1,=C'CHANGED'
         LA    R0,7
         BAL   R14,PUTMSG
NOMSG2   EQU   *
         SPACE
************************************************************
*                                                          *
*         WRITE A MESSAGE ON THE CONSOLE LOG               *
*                                                          *
************************************************************
         SPACE
         CLI   LOGKW+1,2           NOLOG
         BE    NOLOG
         CLI   EXPSW,X'FF'         WAS EXPDT CHANGED
         BE    NOLOG               NO, BRANCH
         MVC   MSGW(LOGL),LOG
         L     R1,16
         L     R1,0(,R1)
         L     R1,4(,R1)
         L     R1,12(,R1)          TIOT
         LA    R15,MSGW+21
         MVC   0(8,R15),0(R1)      INSERT JOBNAME/USERID IN MESSAGE
         LA    R15,7(,R15)         POINT TO LAST BYTE OF JOBNAME
         CLI   0(R15),C' '
         BNE   *+8
         BCT   R15,*-8
         MVC   2(44,R15),DSNAME
         LA    R15,45(,R15)        POINT TO LAST BYTE OF DSNAME
         CLI   0(R15),C' '
         BNE   *+8
         BCT   R15,*-8
         MVC   2(2,R15),=C'ON'
         AH    R1,40(,R3)          DCBTIOT
         L     R1,16(,R1)          TIOEFSRT-1, PTR TO UCB
         MVC   5(6,R15),28(R1)     UCBVOLI
         MVC   12(8,R15),EXPCH     NEW EXPDT
         WTO   MF=(E,MSGW)
NOLOG    B     EXIT0
         EJECT
************************************************************
*                                                          *
*        THIS ROUTINE IS ENTERED DURING THE 'CHECK' MACRO  *
*        IF AN I/O ERROR OCCURS.                           *
*                                                          *
************************************************************
         SPACE
SYNAD    SYNADAF ACSMETH=BDAM
         MVC   SYNADMSG(78),50(R1)
         MVI   SYNADSWT,X'FF'      INDICATE EXIT TAKEN
         SYNADRLS
         BR    R14
         EJECT
************************************************************
*                                                          *
*        CALL IKJDAIR                                      *
*                                                          *
************************************************************
         SPACE
CALLDAIR EQU   *
         AIF   (NOT &MVS).SKIP6
         L     R15,16              CVTPTR
         TM    X'02DC'(R15),X'80'  IF HI ORDER BIT NOT ON
         BNO   CALLDLNK               THEN DO LINK, NOT CALL
         L     R15,X'02DC'(,R15)   CVTDAIR
         BR    R15                 CALL IKJDAIR (R14 IS SET)
CALLDLNK EQU   *
.SKIP6   ANOP
         ST    R14,CALLDR14
         LINK  EP=IKJDAIR,SF=(E,LINKAREA)
         L     R14,CALLDR14
         BR    R14
         EJECT
************************************************************
*                                                          *
*        THIS ROUTINE CONVERTS EXTERNAL HEX TO BINARY HEX  *
*                                                          *
************************************************************
         SPACE
PACK     ST    R14,PACK14
         LR    R15,R1              REG 15 --> SENDING/RECEIVING FIELD
         SR    R14,R14
         IC    R14,0(,R1)          REG 14  =  1ST CHAR
         CLI   0(R1),C'0'          NUMBER OR LETTER
         BNL   *+8                 NUMBER - BRANCH
         LA    R14,57(,R14)        LETTER - CONVERT TO FA-FF
         SLL   R14,4               SHIFT LEFT 4 BITS
         STC   R14,0(,R15)         STORE THE LEFT HALF
         IC    R14,1(,R1)          REG 14  =  2ND CHAR
         CLI   1(R1),C'0'          NUMBER OR LETTER
         BNL   *+8                 NUMBER - BRANCH
         LA    R14,57(,R14)        LETTER - CONVERT
         SLL   R14,28              SHIFT LEFT HALF TO OBLIVION
         SRL   R14,28              SHIFT BACK AGAIN
         STC   R14,1(,R15)         STORE RIGHT HALF
         OC    0(1,R15),1(R15)     'OR' RIGHT HALF OVER LEFT HALF
         LA    R1,2(,R1)           INCREMENT SENDING FIELD
         LA    R15,1(,R15)         INCREMENT RECEIVING FLD
         BCT   R0,PACK+6           LOOP USING LENGTH IN REG 0
         L     R14,PACK14
         BR    R14                 EXIT
         SPACE
************************************************************
*                                                          *
*  UNPACK - CONVERT A FIELD TO HEXADECIMAL.                *
*  REG 1 --> INPUT   REG 15 --> OUTPUT                     *
*  REG 0  =  INPUT LENGTH  (OUTPUT IS TWICE PLUS 1 BLANK)  *
*  REG 14 --> RETURN ADDRESS ( BAL   R14,UNPACK )          *
*                                                          *
************************************************************
         SPACE
UNPACK   UNPK  0(3,R15),0(2,R1)    UNPACK
         TR    0(2,R15),UNPACKT-240
         LA    R15,2(,R15)         INCREMENT OUTPUT PTR
         LA    R1,1(,R1)           INCREMENT INPUT PTR
         BCT   R0,UNPACK           DECREMENT LENGTH, THEN LOOP
         MVI   0(R15),C' '         BLANK THE TRAILING BYTE
         BR    R14                 RETURN TO CALLER
UNPACKT  DC    C'0123456789ABCDEF' TRANSLATE TABLE
         EJECT
************************************************************
*                                                          *
*        ERROR MESSAGES                                    *
*                                                          *
************************************************************
         SPACE
INVREP   LA    R1,INVREPM
         LA    R0,L'INVREPM
         B     ERRMSG
INVREPM  DC    C'MISSING OR INVALID REP PARAMETER'
         SPACE
READERR  EQU   *
WRITERR  LA    R1,SYNADMSG
         LA    R0,78
         B     ERRMSG
         SPACE
REPDERR  LA    R1,REPDERRM
         LA    R0,L'REPDERRM
         B     ERRMSG
REPDERRM DC    CL44'INVALID REP - REP LENGTH EXCEEDS VER LENGTH '
         SPACE
REPOERR  LA    R1,REPOERRM
         LA    R0,40
         B     ERRMSG
REPOERRM DC    CL40'REP OFFSET INVALID - MUST BE AT LEAST 2D'
         SPACE
REPVERR  LA    R1,REPVERRM
         LA    R0,L'REPVERRM
         B     ERRMSG
REPVERRM DC    CL32'REP GOES BEYOND END OF RECORD   '
         SPACE
VERREJ   LA    R1,VERREJM
         LA    R0,L'VERREJM
         B     ERRMSG
VERREJM  DC    CL14'VERIFY REJECT '
         SPACE
LOCERR   LA    R1,LOCERRM
         LA    R0,L'LOCERRM
         B     ERRMSG
LOCERRM  DC    CL22'DATASET NOT IN CATALOG'
         SPACE
DAIRERR  BAL   R14,DAIRFAIL
         B     EXIT12
         SPACE
AUTHERR  LA    R1,AUTHERRM
         LA    R0,L'AUTHERRM
         B     ERRMSG
AUTHERRM DC    C'ENVIRONMENT IS NOT APF AUTHORIZED'
         SPACE
OPENERR  LA    R1,OPENERRM
         LA    R0,L'OPENERRM
         B     ERRMSG
OPENERRM DC    CL12'OPEN FAILED '
         SPACE
PARSERR  LA    R1,PARSERRM
         LA    R0,L'PARSERRM
         B     ERRMSG
PARSERRM DC    C'PARSE FAILED'
         SPACE
ERRCDATE LA    R1,CDATERRM
         LA    R0,L'CDATERRM
         B     ERRMSG
CDATERRM DC    C'INVALID CREATE DATE'
         SPACE
ERRXDATE LA    R1,XDATERRM
         LA    R0,L'XDATERRM
         B     ERRMSG
XDATERRM DC    C'INVALID EXPIRATION DATE'
         SPACE
ERRRDATE LA    R1,RDATERRM
         LA    R0,L'RDATERRM
         B     ERRMSG
RDATERRM DC    C'INVALID REFERENCE DATE'
         SPACE
ERRDSN   LA    R1,MSGDSN
         LA    R0,L'MSGDSN
ERRMSG   BAL   R14,PUTMSG
         B     EXIT12
MSGDSN   DC    C'DATA SET NAME MUST NOT CONTAIN MEMBER NAME'
         SPACE
************************************************************
*                                                          *
*        PUTMSG ROUTINE                                    *
*                                                          *
************************************************************
         SPACE
PUTMSG   STM   R14,R1,PUTSAVE
         XC    MYOLD(8),MYOLD
         XC    MYSEG1(4),MYSEG1
         MVC   MYPTPB(12),MODLPTPM
         LA    R14,1               NO. OF MESSAGE SEGMENTS
         ST    R14,MYOLD
         LA    R14,MYSEG1          POINT TO 1ST SEGMENT
         ST    R14,MYOLD+4
         LR    R14,R0              LENGTH IN R0
         LA    R14,4(,R14)         ADD 4
         LA    R15,MYSEG1+4
         CLC   0(3,R1),=C'IKJ'     IS DATA PRECEEDED BY MESSAGE ID?
         BE    *+16                YES - BRANCH
         LA    R14,1(,R14)         ADD 1 TO LENGTH
         MVI   0(R15),C' '         INSERT LEADING BLANK
         LA    R15,1(,R15)         BUMP POINTER
         STH   R14,MYSEG1
         LR    R14,R0
         BCTR  R14,0
         B     *+10
         MVC   0(0,R15),0(R1)      MOVE MESSAGE IN
         EX    R14,*-6
         LA    R1,MYIOPL
         L     R15,MYPUTLEP
         SPACE
         PUTLINE PARM=MYPTPB,OUTPUT=(MYOLD),ENTRY=(15),MF=(E,(1))
         SPACE
         LM    R14,R1,PUTSAVE
         BR    R14
         SPACE
************************************************************
*                                                          *
*        PUTLINE ROUTINE                                   *
*                                                          *
************************************************************
         SPACE
PUTLINE  STM   R14,R1,PUTSAVE
         XC    MYSEG1(4),MYSEG1
         MVC   MYPTPB(12),MODLPTPB
         LR    R14,R0              LENGTH IN R0
         LA    R14,4(,R14)         ADD 4
         STH   R14,MYSEG1
         LR    R14,R0
         BCTR  R14,0
         B     *+10
         MVC   MYSEG1+4(0),0(R1)   MOVE TEXT IN
         EX    R14,*-6
         LA    R1,MYIOPL
         L     R15,MYPUTLEP
         SPACE
         PUTLINE PARM=MYPTPB,OUTPUT=(MYSEG1,DATA),ENTRY=(15),MF=(E,(1))
         SPACE
         LM    R14,R1,PUTSAVE
         BR    R14
         SPACE
         PRINT GEN
         EJECT
************************************************************
*                                                          *
*        DYNAMIC ALLOCATION FAILURE ROUTINE                *
*                                                          *
************************************************************
         SPACE
DAIRFAIL ST    R14,MYDFREGS
         LA    R1,MYDFPARM
*        USING DFDSECTD,R1         MAPPED BY IKJEFFDF DFDSECT=YES MACRO
         ST    R15,MYDFRC
         LA    R15,MYDFRC
         ST    R15,4(,R1)          DFRCP
         LA    R15,MYDAPL
         ST    R15,0(,R1)          DFDAPLP
         SLR   R15,R15
         ST    R15,MYJEFF02
         LA    R15,MYJEFF02
         ST    R15,8(,R1)          DFJEFF02
         LA    R15,1               DFDAIR
         STH   R15,MYDFID
         LA    R15,MYDFID
         ST    R15,12(,R1)         DFIDP
         ST    R2,16(,R1)          DFCPPLP
         LINK  EP=IKJEFF18,SF=(E,LINKAREA)
         L     R15,MYDFRC
*        DROP  R1                  DFDSECTD
         L     R14,MYDFREGS
         BR    R14
         SPACE
         EJECT
************************************************************
*                                                          *
*        CLOSE THE VTOC                                    *
*                                                          *
************************************************************
         SPACE
EXIT12   LA    R15,12
         B     EXIT
EXIT0    SR    R15,R15             RETURN CODE ZERO
EXIT     ST    R15,RC
         TM    STATUS,STATQ        IS ENQ ACTIVE
         BZ    EXITNODQ            NO, SKIP DEQ
         MVC   DW(DL),D            MOVE MF=L TO WORK AREA
         SPACE
         DEQ   (QNAME,RNAME,6,SYSTEMS),RET=HAVE,MF=(E,DW)
         SPACE
         NI    STATUS,255-STATQ    DEQ
EXITNODQ EQU   *
         TM    STATUS,STATO        IS DCB OPEN
         BZ    EXITNOCL            NO, SKIP CLOSE
         FREEBUF (R3),(R4)
         SPACE
         MVC   CLOSED,CLOSE
         CLOSE ((R3)),MF=(E,CLOSED)
         NI    STATUS,255-STATO    CLOSED
EXITNOCL EQU   *
         SPACE
         TM    STATUS,STATG        WAS GETPOOL ISSUED
         BZ    EXITNOFP            NO, SKIP FREEPOOL
         FREEPOOL (R3)
         NI    STATUS,255-STATG    CLOSED
EXITNOFP EQU   *
         SPACE
************************************************************
*                                                          *
*        INSTALLATION-DEPENDENT CODE                       *
*        TO UNDO THE EARLIER INSTALLATION-DEPENDENT CODE   *
*                                                          *
************************************************************
         SPACE
         L     1,16                CVTPTR
         L     1,0(,1)             TCB WORDS
         L     1,4(,1)             CURRENT TCB
         L     4,180(,1)           JSCB
         TM    STATUS,STATM        WAS AUTH CHANGED
         BZ    EXITNOMS            NO, BRANCH
         LA    0,0                 R0 = FUNCTION CODE FOR USER SVC
         LA    15,KEYUA            R15 POINTS TO ROUTINE TO BE CALLED
         LA    1,1                 ATTEMPT TO ADD SVC AUTH       @SOF21
         SVC   244                 ATTEMPT TO ADD SVC AUTH       @SOF21
         NOPR  0                   *** REPLACE WITH USER SVC ***
         B     KEYUB               BRANCH AROUND THE ROUTINE
KEYUA    NI    236(4),X'FE'        SET OFF JSCBAUTH
         BR    14                  RETURN TO SVC
KEYUB    NI    STATUS,255-STATM
EXITNOMS EQU   *
         SPACE
************************************************************
*                                                          *
*        UNALLOCATE VIA DYNAMIC ALLOCATION                 *
*                                                          *
************************************************************
         SPACE
         TM    STATUS,STATA        WAS ALLOCATE DONE
         BZ    EXITNOFR            NO, BYPASS FREE
         LA    R1,MYDAPL
         USING DAPL,R1
         L     14,DAPLECB
         XC    0(4,14),0(14)
         L     15,DAPLDAPB
         DROP  R1
         USING DAPB18,15
         XC    0(40,15),0(15)
         MVI   DA18CD+1,X'18'
         MVC   DA18MNM,=CL8' '
         MVI   DA18DPS2,DA18KEEP
         MVI   DA18CTL,X'00'
         MVC   DA18SCLS(2),=CL8' '
         MVC   DA18JBNM(8),=CL8' '
         MVC   DA18DDN(8),DCBDDNAM
         SPACE
         BAL   R14,CALLDAIR
         NI    STATUS,255-STATA
EXITNOFR EQU   *
         SPACE
************************************************************
*                                                          *
*        FINAL EXIT FROM PROGRAM                           *
*                                                          *
************************************************************
         SPACE
         IKJRLSA MYANS
         CLI   RC+3,0              IS RC ZERO?
         BE    STACKDX             YES, BRANCH
         MVC   MYSTPB(STACKDL),STACKD
         SPACE
         STACK DELETE=ALL,PARM=MYSTPB,MF=(E,MYIOPL)
         SPACE
         TCLEARQ
STACKDX  EQU   *
         SPACE
         L     R15,RC
         LR    R1,R13
         L     R0,SIZE
         L     R13,4(,R13)
         LR    R2,R15
         FREEMAIN R,A=(1),LV=(0)
         LR    R15,R2
         RETURN (14,12),RC=(15)
         SPACE
************************************************************
*                                                          *
*        PARSE VALIDITY CHECK ROUTINE FOR 'REP' KEYWORD    *
*                                                          *
************************************************************
         SPACE
REPVALCK EQU   *
         USING *,R6
         STM   R14,R12,12(R13)
         LR    R6,R15
         L     R7,0(,R1)           REG 7 --> PDE
         L     R4,0(,R7)           REG 4 --> CHARACTER STRING
         LH    R0,4(,R7)           REG 0  =  LENGTH
         LA    R15,4               RETURN 4 IF CHECK FAILS
         TM    5(R7),X'01'         LENGTH AN EVEN NUMBER?
         BO    VALREXIT            NO - EXIT WITH RC=4
VALLOOP  CLI   0(R4),C'0'          NUMERIC?
         BNL   VALINCR             YES - THIS CHAR OK
         CLI   0(R4),C'F'          IN RANGE A THRU F?
         BH    VALREXIT            NO - EXIT WITH RC=4
VALINCR  LA    R4,1(,R4)           POINT TO NEXT CHAR
         BCT   R0,VALLOOP
         SR    R15,R15             SET RC=0
VALREXIT L     R14,12(,R13)
         LM    0,12,20(R13)
         BR    R14
         DROP  R6
         SPACE
***********************************************************************
*                                                                     *
*         PARSE VALIDITY CHECK ROUTINE FOR DATE                       *
*                                                                     *
***********************************************************************
         SPACE
*
*              THE IKJIDENT MACRO SPECIFIES THE FOLLOWING:
*                FIRST=NUMERIC,OTHER=ANY,VALIDCK=VCCDATE OR VCRDATE
*
VCCDATE  DC    0H'0'
         STM   R14,R12,12(R13)
         L     R9,4(,R1)           RESTORE R9 PASSED IN PPLUWA
         LM    R10,R11,BASES       RESTORE BASE REGISTERS
         LA    R8,CDATE            POINT R8 TO RESULT
         B     VCDATE
VCEDATE  DC    0H'0'
         STM   R14,R12,12(R13)
         L     R9,4(,R1)           RESTORE R9 PASSED IN PPLUWA
         LM    R10,R11,BASES       RESTORE BASE REGISTERS
         LA    R8,EDATE            POINT R8 TO RESULT
         B     VCDATE
VCRDATE  DC    0H'0'
         STM   R14,R12,12(R13)
         L     R9,4(,R1)           RESTORE R9 PASSED IN PPLUWA
         LM    R10,R11,BASES       RESTORE BASE REGISTERS
         LA    R8,RDATE            POINT R8 TO RESULT
VCDATE   L     R7,0(,R1)           REG 7 --> PDE
         L     R4,0(,R7)           REG 4 --> CHARACTER STRING
         LH    R0,4(,R7)           REG 0  =  LENGTH
         LA    R15,4               RETURN 4 IF CHECK FAILS
         CH    R0,=H'5'            LENGTH MUST BE EITHER 5 (YYDDD)
         BE    VCDATE5
         CH    R0,=H'6'             OR 6 (YY.DDD)
         BE    VCDATE6
         CH    R0,=H'8'             OR 8 (YY/MM/DD)
         BE    VCDATE8
         CH    R0,=H'1'             OR 1 (*) (0)
         BNE   VALEXIT
         CLI   0(R4),C'*'
         BE    VALTODAY
         CLI   0(R4),C'0'
         BNE   VALEXIT
         LA    R0,CDATE            CREATE(0) NOT ALLOWED
         CR    R0,R8               BUT EXPDT(0) IS OK
         BE    VALEXIT
         SR    R0,R0
         B     VALSTORE
VALTODAY TIME  BIN
         ST    R1,DOUBLE+4         STORE 00YYDDDC (01YYDDDC AFTER 1999)
         SR    R1,R1
         ST    R1,DOUBLE
         CVB   R0,DOUBLE
VALSTORE ST    R0,0(,R8)           SAVE RESULT
         SR    R15,R15             SET RC=0
         B     VALEXIT
*
*               DATE IN YY/MM/DD FORMAT
*
*         TO CHANGE THE ORDER OF YY/MM/DD, JUST CHANGE THESE 3 OFFSETS
*         AND THE TEXT IN THE IKJIDENT MACROS AT 'CREATE' AND 'DATE'.
*                   (COULDN'T FIND ANY IKJIDENT TEXT TO CHANGE - FEB99)
VCYY     EQU   0
VCMM     EQU   3
VCDD     EQU   6
*
VCDATE8  CLI   4(R4),C'/'
         BE    VCDATE4
         CLI   4(R4),C'.'
         BE    VCDATE4
         TRT   0(2,R4),NUMERIC
         BNZ   VALEXIT
         CLI   2(R4),C'/'
         BNE   VALEXIT
         TRT   3(2,R4),NUMERIC
         BNZ   VALEXIT
         CLI   5(R4),C'/'
         BNE   VALEXIT
         TRT   6(2,R4),NUMERIC
         BNZ   VALEXIT
*        CLC   VCYY(2,R4),VCMINYY+2 MINIMUM YEAR                 *Y2K
*        BL    VALEXIT                                           *Y2K
         CLC   VCMM(2,R4),=C'01'   MIN MONTH
         BL    VALEXIT
         CLC   VCDD(2,R4),=C'01'   MIN DAY
         BL    VALEXIT
         CLC   VCMM(2,R4),=C'12'   MAX MONTH
         BH    VALEXIT
         CLC   VCDD(2,R4),=C'31'   MAX DAY
         BH    VALEXIT
         PACK  DOUBLE,VCYY(2,R4)   PACK YEAR
         CVB   R0,DOUBLE
         CH    R0,VCMINYR (H'66')  IF 00 THRU 65                  Y2K
         BNL   *+8                    THEN                        Y2K
         AH    R0,=H'100'             MAKE IT 100 THRU 165        Y2K
         STC   R0,DOUBLE           SAVE BINARY YEAR FOR LEAP TEST
         MH    R0,=H'1000'
         ST    R0,0(,R8)           SAVE YY000 IN RESULT
         LA    R1,VCDY365          POINT TO NORMAL YEAR OF MAX DAYS/MO
         TM    DOUBLE,X'03'        TEST YEAR FOR MULTIPLE OF 4
         BNZ   *+8                 BRANCH IF NOT A MULTIPLE OF 4
         LA    R1,VCDY366          POINT TO LEAP YEAR OF MAX DAYS/MO
         PACK  DOUBLE,VCMM(2,R4)   PACK MONTH
         CVB   R0,DOUBLE            TO BINARY
         BCTR  R0,0                DECREMENT MONTH
         SLL   R0,1                MULTIPLY MONTH BY 2
         AR    R1,R0               POINT TO MAX DAYS FOR MONTH
         PACK  DOUBLE,VCDD(2,R4)   PACK DAY
         CVB   R0,DOUBLE            TO BINARY
         CH    R0,0(,R1)           COMPARE TO MAX DAYS FOR MONTH
         BH    VALEXIT             BRANCH IF TOO LARGE
         AH    R0,24(,R1)          CONVERT TO JULIAN DAY
         A     R0,0(,R8)           ADD YY000 TO DDD GIVING YYDDD
         ST    R0,0(,R8)           SAVE RESULT
         SR    R15,R15             SET RC=0
         B     VALEXIT
*
*               DATE IN YYYY/DDD OR YYYY.DDD FORMAT
*
VCDATE4  TRT   0(4,R4),NUMERIC     YYYY
         BNZ   VALEXIT
         TRT   5(3,R4),NUMERIC     DDD
         BNZ   VALEXIT
         CLC   5(3,R4),=C'001'     MIN DDD
         BL    VALEXIT
         CLC   5(3,R4),=C'366'     MAX DDD
         BH    VALEXIT
         CLC   0(4,R4),VCMINYY     MINIMUM YEAR
         BL    VALEXIT
         CLC   0(4,R4),VCMAXYY     MAXIMUM YEAR
         BH    VALEXIT
         MVC   VCWK7(4),0(R4)      YYYY
         MVC   VCWK7+4(3),5(R4)    DDD
         PACK  DOUBLE,VCWK7
         CVB   R0,DOUBLE
         S     R0,=F'1900000'      SUBTRACT 1900 FROM YYYY
         ST    R0,0(,R8)           SAVE RESULT
         CLC   3(3,R4),=C'366'     IF DAY IS 366
         BNE   VALGOOD                THEN
         PACK  DOUBLE,0(4,R4)      PACK YEAR
         CVB   R0,DOUBLE
         S     R0,=F'1900'
         STC   R0,DOUBLE
         TM    DOUBLE,X'03'        TEST YEAR FOR MULTIPLE OF 4
         BNZ   VALEXIT             BRANCH IF NOT A MULTIPLE OF 4
         B     VALGOOD
*
*               DATE IN YY.DDD FORMAT
*
VCDATE6  TRT   0(2,R4),NUMERIC     YY
         BNZ   VALEXIT
         CLI   2(R4),C'.'
         BNE   VALEXIT
         TRT   3(3,R4),NUMERIC     DDD
         BNZ   VALEXIT
         CLC   3(3,R4),=C'001'     MIN DDD
         BL    VALEXIT
         CLC   3(3,R4),=C'366'     MAX DDD
         BH    VALEXIT
*        CLC   0(2,R4),VCMINYY+2   MINIMUM YEAR                  *Y2K
*        BL    VALEXIT                                           *Y2K
*
*        MVC   VCWK5(2),0(R4)      YY      OLDEST LOGIC
*        MVC   VCWK5+2(3),3(R4)    DDD
*        PACK  DOUBLE,VCWK5
*
*        MVC   DOUBLE(2),0(R4)     YY      OLD LOGIC
*        MVC   DOUBLE+2(3),3(R4)   DDD
*        PACK  DOUBLE+5(3),DOUBLE(5)
*        XC    DOUBLE(5),DOUBLE
*
         MVC   VCWK7(2),=C'00'     00      NEW LOGIC
         CLC   0(2,R4),VCMINYY+2   IF 00 THRU 65                  Y2K
         BNL   *+8                    THEN                        Y2K
         MVI   VCWK7+1,C'1'           MAKE TO 100 THRU 165        Y2K
         MVC   VCWK7+2(2),0(R4)    YY
         MVC   VCWK7+4(3),3(R4)    DDD
         PACK  DOUBLE,VCWK7
*
         CVB   R0,DOUBLE
         ST    R0,0(,R8)           SAVE RESULT
         CLC   3(3,R4),=C'366'     IF DAY IS 366
         BNE   VALGOOD                THEN
VCLEAP   PACK  DOUBLE,0(2,R4)      PACK YEAR
         CVB   R0,DOUBLE
         STC   R0,DOUBLE
         TM    DOUBLE,X'03'        TEST YEAR FOR MULTIPLE OF 4
         BNZ   VALEXIT             BRANCH IF NOT A MULTIPLE OF 4
         B     VALGOOD
*
*               DATE IN YYDDD FORMAT
*
VCDATE5  TRT   0(5,R4),NUMERIC     YYDDD
         BNZ   VALEXIT
*        PACK  DOUBLE,0(5,R4)                                    *Y2K
         MVC   VCWK7(2),=C'00'     00      NEW LOGIC
         CLC   0(2,R4),VCMINYY+2   IF 00 THRU 65                  Y2K
         BNL   *+8                    THEN                        Y2K
         MVI   VCWK7+1,C'1'           MAKE TO 100 THRU 165        Y2K
         MVC   VCWK7+2(2),0(R4)    YY
         MVC   VCWK7+4(3),2(R4)    DDD
         PACK  DOUBLE,VCWK7
         CVB   R0,DOUBLE
         ST    R0,0(,R8)           SAVE RESULT
         CLC   2(3,R4),=C'001'     MIN DDD
         BL    VALEXIT
         CLC   2(3,R4),=C'366'     MAX DDD
         BH    VALEXIT
*        CLC   0(2,R4),VCMINYY+2   MINIMUM YEAR                  *Y2K
*        BL    VALEXIT                                           *Y2K
         CLC   2(3,R4),=C'366'     IF DAY IS 366
         BE    VCLEAP                 THEN CHECK FOR LEAP YEAR
VALGOOD  SR    R15,R15             SET RC=0
VALEXIT  L     R14,12(,R13)
         LM    0,12,20(R13)
         BR    R14
         SPACE
VCMINYR  DC    H'66'               <66 = 2000 - 2065.  >=66 = 19XX
VCMINYY  DC    C'1966'
VCMAXYY  DC    C'2099' (2100 HAS DIFFERENT LEAP YEAR RULE)
*              12 WORDS REPRESENTING MAX DAYS PER MONTH, FOLLOWED BY
*              12 WORDS REPRESENTING DAYS IN YEAR BEFORE THAT MONTH
VCDY365  DC    AL2(31,28,31,030,031,030,031,031,030,031,030,031)
         DC    AL2(00,31,59,090,120,151,181,212,243,273,304,334)
VCDY366  DC    AL2(31,29,31,030,031,030,031,031,030,031,030,031)
         DC    AL2(00,31,60,091,121,152,182,213,244,274,305,335)
         SPACE
************************************************************
*                                                          *
*        CONSTANTS                                         *
*                                                          *
************************************************************
         SPACE
         LTORG
         SPACE
*              THE BYTES IN THE FOLLOWING TABLE
*              MUST BE IN THE SAME ORDER AS THE
*              'IKJNAME' ENTRIES IN THE PARSE
*              PCL PARAMETERS.
RECFMTAB DC    X'00'              NO RECFM
         DC    X'80'               F
         DC    X'88'               FS
         DC    X'84'               FA
         DC    X'82'               FM
         DC    X'90'               FB
         DC    X'98'               FBS
         DC    X'94'               FBA
         DC    X'92'               FBM
         DC    X'40'               V
         DC    X'48'               VS
         DC    X'44'               VA
         DC    X'42'               VM
         DC    X'50'               VB
         DC    X'58'               VBS
         DC    X'54'               VBA
         DC    X'52'               VBM
         DC    X'C0'               U
         DC    X'E0'               UT
         DC    X'C4'               UA
         DC    X'C2'               UM
DSORGTAB DC    X'00'
         DC    X'40'               PS
         DC    X'41'               PSU
         DC    X'02'               PO
         DC    X'03'               POU
         DC    X'20'               DA
         DC    X'21'               DAU
         SPACE
MODLPTPM PUTLINE OUTPUT=(1,TERM,SINGLE,INFOR),                         X
               TERMPUT=(EDIT,WAIT,NOHOLD,NOBREAK),MF=L
         SPACE
MODLPTPB PUTLINE OUTPUT=(1,TERM,SINGLE,DATA),                          X
               TERMPUT=(EDIT,WAIT,NOHOLD,NOBREAK),MF=L
         SPACE
ENDOFREC DC    0H'0',AL2(44+96-1) OFFSET TO LAST BYTE OF RECORD
         PRINT GEN                 LIST DCB SO LIMCT CAN BE ZAPPED
         SPACE
DCBMODEL DCB   DDNAME=DYNAM,DSORG=DA,MACRF=(RKC,WKC),                  X
               BUFL=96,OPTCD=EF,LIMCT=57,                              X
               RECFM=F,BLKSIZE=96,KEYLEN=44,                           X
               EXLST=0,SYNAD=SYNAD
DCBLEN   EQU   *-DCBMODEL
         PRINT GEN
         SPACE
RDJFCB   RDJFCB 0,MF=L
         SPACE
OPENJ    OPEN  0,TYPE=J,MF=L
         SPACE
CLOSE    CLOSE 0,MF=L
         SPACE
READ     READ  DECBMODR,DKF,0,'S','S',0,0,MF=L
READL    EQU   *-DECBMODR
         SPACE
WRITE    WRITE  DECBMODW,DK,0,'S','S',0,0,MF=L
WRITEL   EQU   *-DECBMODW
         SPACE
STAXDEF  STAX  DEFER=YES,MF=L
         SPACE
STAXDEN  STAX  DEFER=NO,MF=L
         SPACE
R        RESERVE (77,88,E,6,SYSTEMS),RET=HAVE,UCB=99,MF=L
RL       EQU   *-R
         SPACE
D        DEQ   (77,88,6,SYSTEMS),RET=HAVE,MF=L
DL       EQU   *-D
         SPACE
LOG      WTO   'CMI000I CDSCB BY                                       +
                                                    ',ROUTCDE=(9),MF=L
LOGL     EQU   *-LOG
*        WTO   'CMI000I CDSCB BY UUUUUUUU TO DSNAME78901234567890123456
*              789012345678901234 ON VVVVVV YYYY.DDD',ROUTCDE=(9),MF=L
         SPACE
STACKD   STACK DELETE=ALL,MF=L
STACKDL  EQU   *-STACKD
         DC    0D'0'
NUMERIC  DC    240X'FF',10X'00',6X'FF'
PCLADDR  DC    0D'0'               END OF CSECT, BEGIN PARSE PCL CSECT
         SPACE
************************************************************
*                                                          *
*         PARSE PCL CSECT AND PDL DSECT                    *
*                                                          *
************************************************************
         PRINT NOGEN
         SPACE
CDSCBPCL IKJPARM
         AIF   (NOT &MVS).SKIP7
DSN      IKJPOSIT DSNAME,USID,PROMPT='DATASET NAME'
.SKIP7   AIF   (&MVS).SKIP8
DSN      IKJPOSIT DSNAME,PROMPT='DATA SET NAME'
.SKIP8   ANOP
SHRKW    IKJKEYWD
         IKJNAME 'SHR'
VOLKW    IKJKEYWD
         IKJNAME 'VOLUME',SUBFLD=VOLSUB
UNIKW    IKJKEYWD
         IKJNAME 'UNIT',SUBFLD=UNISUB
ZAPKW    IKJKEYWD
         IKJNAME 'ZAP',SUBFLD=ZAPSUB
RECKW    IKJKEYWD
         IKJNAME 'RECFM',SUBFLD=RECSF
LREKW    IKJKEYWD
         IKJNAME 'LRECL',SUBFLD=LRESF
BLKKW    IKJKEYWD
         IKJNAME 'BLKSIZE',SUBFLD=BLKSF
DSOKW    IKJKEYWD
         IKJNAME 'DSORG',SUBFLD=DSOSF
PROKW    IKJKEYWD
         IKJNAME 'PW'
         IKJNAME 'PWREAD'
         IKJNAME 'PWWRITE'
         IKJNAME 'NOPW'
         IKJNAME 'RACF'
         IKJNAME 'NORACF'
ALLKW    IKJKEYWD
         IKJNAME 'ALLOC',SUBFLD=ALLSF
SPAKW    IKJKEYWD
         IKJNAME 'SPACE',SUBFLD=SPASF
CREATEKW IKJKEYWD
         IKJNAME 'CREATE',SUBFLD=CRESF
EXPDTEKW IKJKEYWD
         IKJNAME 'EXPDT',SUBFLD=EXPSF
REFDTEKW IKJKEYWD
         IKJNAME 'REFDT',SUBFLD=REFSF
LOGKW    IKJKEYWD
         IKJNAME 'LOG'
         IKJNAME 'NOLOG'
MSGKW    IKJKEYWD
         IKJNAME 'MSG'
         IKJNAME 'NOMSG'
JOBKW    IKJKEYWD
         IKJNAME 'JOB',SUBFLD=JOBSF
*
*              SUBFIELDS
*
VOLSUB   IKJSUBF
VOL      IKJIDENT 'VOLUME',FIRST=ALPHANUM,OTHER=ALPHANUM,MAXLNTH=6,    X
               PROMPT='VOLUME SERIAL'
UNISUB   IKJSUBF
UNIT     IKJIDENT 'UNIT',FIRST=ALPHANUM,OTHER=ANY,MAXLNTH=8,           +
               PROMPT='UNIT NAME'
ZAPSUB   IKJSUBF
REP      IKJIDENT 'ZAP PARAMETER',LIST,                                +
               FIRST=ALPHANUM,OTHER=ALPHANUM,MAXLNTH=12,               +
               PROMPT='ZAP IN FORMAT OFFSET,VERDATA,REPDATA',          +
               VALIDCK=REPVALCK
RECSF    IKJSUBF
RECFM    IKJKEYWD
         IKJNAME 'F'
         IKJNAME 'FS'
         IKJNAME 'FA'
         IKJNAME 'FM'
         IKJNAME 'FB'
         IKJNAME 'FBS'
         IKJNAME 'FBA'
         IKJNAME 'FBM'
         IKJNAME 'V'
         IKJNAME 'VS'
         IKJNAME 'VA'
         IKJNAME 'VM'
         IKJNAME 'VB'
         IKJNAME 'VBS'
         IKJNAME 'VBA'
         IKJNAME 'VBM'
         IKJNAME 'U'
         IKJNAME 'UT'
         IKJNAME 'UA'
         IKJNAME 'UM'
LRESF    IKJSUBF
LRE      IKJIDENT 'LRECL',                                             +
               FIRST=NUMERIC,OTHER=NUMERIC,MAXLNTH=5,                  +
               PROMPT='LOGICAL RECORD LENGTH'
BLKSF    IKJSUBF
BLK      IKJIDENT 'BLOCK SIZE',                                        +
               FIRST=NUMERIC,OTHER=NUMERIC,MAXLNTH=5,                  +
               PROMPT='BLOCK SIZE'
DSOSF    IKJSUBF
DSORG    IKJKEYWD
         IKJNAME 'PS'
         IKJNAME 'PSU'
         IKJNAME 'PO'
         IKJNAME 'POU'
         IKJNAME 'DA'
         IKJNAME 'DAU'
ALLSF    IKJSUBF
ALL      IKJKEYWD
         IKJNAME 'NONE'
         IKJNAME 'BLOCKS'
         IKJNAME 'TRACKS'
         IKJNAME 'CYLINDERS'
SPASF    IKJSUBF
SPA      IKJIDENT 'SECONDARY SPACE AMOUNT',                            +
               FIRST=NUMERIC,OTHER=NUMERIC,MAXLNTH=4,                  +
               PROMPT='SECONDARY SPACE AMOUNT'
CRESF    IKJSUBF
CREATE   IKJIDENT 'CREATION DATE',ASTERISK,                            +
               FIRST=NUMERIC,OTHER=ANY,MAXLNTH=8,VALIDCK=VCCDATE,      +
               PROMPT='CREATION DATE'
EXPSF    IKJSUBF
EXPDTE   IKJIDENT 'EXPIRATION DATE',                                   +
               FIRST=NUMERIC,OTHER=ANY,MAXLNTH=8,VALIDCK=VCEDATE,      +
               PROMPT='EXPIRATION DATE'
REFSF    IKJSUBF
REFDTE   IKJIDENT 'REFERENCE DATE',ASTERISK,                           +
               FIRST=NUMERIC,OTHER=ANY,MAXLNTH=8,VALIDCK=VCRDATE,      +
               PROMPT='REFERENCE DATE'
JOBSF    IKJSUBF
JOBNME   IKJIDENT 'JOBNAME',                                           +
               FIRST=ALPHA,OTHER=ALPHANUM,MAXLNTH=8,                   +
               PROMPT='JOBNAME'
         IKJENDP
         SPACE
************************************************************
*                                                          *
*        DSECTS                                            *
*                                                          *
************************************************************
         PRINT GEN
         SPACE
@DATA    DSECT
         DS    18F
SIZE     DS    F
STATUS   DS    F
LINKAREA DS    2F
STATA    EQU   X'80'
STATM    EQU   X'40'
STATG    EQU   X'20'
STATO    EQU   X'10'
STATQ    EQU   X'08'
MYPPL    DS    7F
MYANS    DS    F
MYECB    DS    F                   USED BY PUTLINE ROUTINE
MYIOPL   DS    4F                  USED BY PUTLINE ROUTINE
MYPTPB   DS    3F                  USED BY PUTLINE ROUTINE
MYPUTLEP DS    F                   USED BY PUTLINE ROUTINE
MYOLD    DS    2F                  USED BY PUTLINE ROUTINE
MYSEG1   DS    2H,CL100            USED BY PUTLINE ROUTINE
PUTSAVE  DS    4F                  USED BY PUTLINE ROUTINE
MYSTPB   DS    5F
MYDAPL   DS    5F
MYDAPB   DS    21F
CALLDR14 DS    F
DSNAMEL  DS    H
DSNAME   DS    CL44
RW       DS    4F
QNAME    DS    CL8
RNAME    DS    CL6
UCBAD    DS    F
DW       DS    3F
DEVAREA  DS    5F
TRACKS   DS    H
SYNADMSG DS    0CL78
MSGW     DS    CL100
SYNADSWT DS    C
JOBNAME  DS    CL9
CHANGED  DS    C
EXPSW    DS    C
EXPCH    DS    CL8
NEWPROSW DS    C
NEWPRO0  DS    C
NEWPRO1  DS    C
NEWPROSV DS    C
NEWBLKSW DS    C
NEWLRESW DS    C
NEWBLK   DS    H
NEWLRE   DS    H
NEWALLSW DS    C
NEWALL0  DS    C
NEWALL1  DS    C
NEWSPASW DS    C
NEWSPA   DS    F
NEWCRESW DS    C
NEWEXPSW DS    C
NEWREFSW DS    C
NEWCRE   DS    F
NEWEXP   DS    F
NEWREF   DS    F
NEWRECSW DS    C
NEWRECFM DS    C
NEWDSOSW DS    CL2
NEWDSORG DS    C
TTR      DS    D
OPEND    DS    F
OPENJD   DS    F
RDJFCBD  DS    F
READDECB DS    7F
WRITDECB DS    7F
CLOSED   DS    F
DCB      DS    0D,XL104
JFCB     DS    0D,XL176
EXLSTD   DS    F
WRKUNIT  DS    CL8
DATE5    DS    0CL5
WRKVOL   DS    CL6
OFFSET   DS    H,CL3
VERDATA  DS    CL14     LENGTH TIED TO MAXLNTH IN IKJPOSIT
REPDATA  DS    CL14     1ST BYTE IS LENGTH, LAST BYTE USED BY 'PACK'
VR       DS    C
PACK14   DS    F
EXTRACTD DS    3F
EXTRACT  DS    2F
STAXD    DS    5F
DOUBLE   DS    D
RC       DS    F
BASES    DS    2F
CDATE    DS    F
EDATE    DS    F
RDATE    DS    F
VCWK7    DS    CL7
MYDFPARM DS    5F  USED BY DAIRFAIL
MYDFREGS DS    F   USED BY DAIRFAIL
MYDFRC   DS    F   USED BY DAIRFAIL
MYJEFF02 DS    F   USED BY DAIRFAIL
MYDFID   DS    H   USED BY DAIRFAIL
         DS    0D
@DATAL   EQU   *-@DATA
         SPACE
IHADCB   DSECT
         DS    XL36
DCBEXLST DS    F
DCBDDNAM DS    XL8
DCBDEBAD EQU   *-4,4
DCBOFLGS DS    X
DCBLIMCT EQU   IHADCB+81,3
         SPACE
         IKJCPPL
         SPACE 2
         IKJIOPL
         SPACE 2
         IKJUPT
         SPACE 2
         IKJPSCB
         SPACE 2
         IKJECT
         SPACE 2
         IKJPPL
         SPACE 2
         IKJDAPL
         SPACE 2
         IKJDAP08
         SPACE 2
         IKJDAP18
         SPACE 2
FORMAT1  DSECT
IECSDSL1 EQU   *                   FORMAT 1 DSCB
IECSDSF1 EQU   IECSDSL1
DS1DSNAM DS    CL44                DATA SET NAME
DS1FMTID DS    CL1                 FORMAT IDENTIFIER
DS1DSSN  DS    CL6                 DATA SET SERIAL NUMBER
DS1VOLSQ DS    XL2                 VOLUME SEQUENCE NUMBER
DS1CREDT DS    XL3                 CREATION DATE
DS1EXPDT DS    XL3                 EXPIRATION DATE
DS1NOEPV DS    XL1                 NUMBER OF EXTENTS ON VOLUME
DS1NOBDB DS    XL1                 NUMBER OF BYTES USED IN LAST
*                                     DIRECTORY BLOCK
         DS    XL1                 RESERVED
DS1SYSCD DS    CL13                SYSTEM CODE
DS1REFD  DS    XL3                 DATE LAST REFERENCED OR    @G60ASBJ
*                                     ZERO IF NOT MAINTAINED  @G60ASBJ
         DS    XL4                 RESERVED                   @G60ASBJ
DS1DSORG DS    XL2                 DATA SET ORGANIZATION
DS1RECFM DS    XL1                 RECORD FORMAT
DS1OPTCD DS    XL1                 OPTION CODE
DS1BLKL  DS    XL2                 BLOCK LENGTH
DS1LRECL DS    XL2                 RECORD LENGTH
DS1KEYL  DS    XL1                 KEY LENGTH
DS1RKP   DS    XL2                 RELATIVE KEY POSITION
DS1DSIND DS    XL1                 DATA SET INDICATORS
DS1IND80 EQU   X'80'               LAST VOLUME ON WHICH A DATA@G60ASBJ
*                                  SET RESIDES                @G60ASBJ
DS1IND40 EQU   X'40'               DATA SET IS RACF DEFINED   @G60ASBJ
DS1IND20 EQU   X'20'               BLOCK LENGTH IS A MULTIPLE @G60ASBJ
*                                  OF 8 BYTES                 @G60ASBJ
DS1IND10 EQU   X'10'               PASSWORD IS REQUIRED TO    @G60ASBJ
*                                  READ OR WRITE OR BOTH-SEE  @G60ASBJ
*                                  DS1IND04                   @G60ASBJ
DS1IND08 EQU   X'08'               RESERVED                   @G60ASBJ
DS1IND04 EQU   X'04'               IF DS1IND10 IS 1 THEN IF   @G60ASBJ
*                                  DS1IND04 IS . . .          @G60ASBJ
*                                  1-PASSWORD REQUIRED TO     @G60ASBJ
*                                  WRITE BUT NOT TO READ      @G60ASBJ
*                                  0-PASSWORD REQUIRED TO     @G60ASBJ
*                                  WRITE AND TO READ          @G60ASBJ
DS1IND02 EQU   X'02'               DATASET OPENED FOR OTHER   @G60ASBJ
*                                  THAN INPUT SINCE LAST      @G60ASBJ
*                                  BACKUP COPY MADE.          @G60ASBJ
DS1DSCHA EQU   DS1IND02            SAME USE AS BIT DS1IND02   @G60ASBJ
DS1IND01 EQU   X'01'               RESERVED                   @G60ASBJ
DS1SCALO DS    XL4                 SECONDARY ALLOCATION
DS1LSTAR DS    XL3                 LAST USED TRACK AND BLOCK ON TRACK
DS1TRBAL DS    XL2                 BYTES REMAINING ON LAST TRACK USED
         DS    XL2                 RESERVED
DS1EXT1  DS    XL10                FIRST EXTENT DESCRIPTION
*        FIRST BYTE                EXTENT TYPE INDICATOR
*        SECOND BYTE               EXTENT SEQUENCE NUMBER
*        THIRD - SIXTH BYTES       LOWER LIMIT
*        SEVENTH - TENTH BYTES     UPPER LIMIT
DS1EXT2  DS    XL10                SECOND EXTENT DESCRIPTION
DS1EXT3  DS    XL10                THIRD EXTENT DESCRIPTION
DS1PTRDS DS    XL5                 POSSIBLE PTR TO A FORMAT 2 OR 3 DSCB
DS1END   EQU   *
         SPACE
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
         END
/*
//CDSCBLKD EXEC PGM=IEWL,
//             PARM='LIST,RENT,XREF,AC=1'
//SYSPRINT DD  SYSOUT=*
//SYSUT1   DD  UNIT=SYSDA,SPACE=(TRK,10)
//SYSLMOD  DD  DSN=SYS2.CMDLIB,DISP=SHR
//SYSLIN   DD  DSN=&&SYSLIN,DISP=(OLD,DELETE)
//         DD  DDNAME=SYSIN
//SYSIN  DD *
 NAME CDSCB(R)
/*