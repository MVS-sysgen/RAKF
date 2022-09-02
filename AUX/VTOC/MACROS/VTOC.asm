VTOC     TITLE 'VTOC COMMAND - LIST DATA SETS AND ATTRIBUTES'
***********************************************************************
*                                                                     *
*                                                                     *
* TITLE -      VTOC COMMAND - LIST DATA SETS AND ATTRIBUTES           *
*                                                                     *
* FUNCTION -   PROVIDE THE ABILITY FOR A TSO USER OR A BATCH JOB      *
*              TO LIST THE CONTENTS OF VARIOUS VOLUMES, WITH A        *
*              FAIR AMOUNT OF SELECTION.                              *
*                                                                     *
*                                                                     *
* OPERATION -  ACCEPT FROM THE TSO USER OR BATCH JOB A COMMAND        *
*              WITH THE FOLLOWING SYNTAX.  THEN CHECK THE COMMAND     *
*              AND LOOP THROUGH, GETTING A DSCB, FORMATTING IT,       *
*              PERFORMING THE DATA SET NAME AND LIMIT CHECKS, AND     *
*              CALLING AN EXIT ROUTINE IF DESIRED, THEN PUT THE       *
*              ENTRY IN THE CORRECT SORT SEQUENCE.                    *
*              FINALLY CALL THE PRINT ROUTINE TO PRINT THE            *
*              SPECIFIED ITEMS, HEADERS, AND BREAKS, OR JUST          *
*              THE TOTALS.                                            *
*                                                                     *
*                                                                     *
* INPUT -      STANDARD COMMAND PROCESSOR PARAMETER LIST              *
*              POINTED TO BY REGISTER 1                               *
*                                                                     *
*                                                                     *
* OUTPUT -     TO SYSOUT, A LIST OF THE REQUESTED DATA SETS AND       *
*              THEIR ATTRIBUTES.                                      *
*                                                                     *
*                                                                     *
* ATTRIBUTES - REENTRANT, REUSEABLE, REFRESHABLE.                     *
*                                                                     *
*                                                                     *
*         PROGRAMMED BY R. L. MILLER  (415) 485-6241                  *
*              FIREMAN'S FUND INSURANCE  CPSD 2N                      *
*              ONE LUCAS GREEN                                        *
*              SAN RAFAEL, CA  94911                                  *
*                                                                     *
* 9/26/84 - MODIFIED BY A. BRUCE LELAND AT HITACHI TO USE       ABL-UCB
*           UCB SCAN SERVICES FOR MVS/XA AND MVS 1.1.3.         ABL-UCB
*                                                                     *
*                                                                     *
***********************************************************************
*
         MACRO
&LABEL   VTOCEXCP  &FUNC
         AIF   ('&FUNC' NE 'EQ').CALL
VTCOPEN  EQU   1              DEFINE FUNCTION CODES FOR VTOCEXCP
VTCCLOSE EQU   2
VTCREAD  EQU   0
         MEXIT
.CALL    ANOP                 CALL VTOCEXCP
&LABEL   MVI   VTCEFUNC,VTC&FUNC   SET THE FUNCTION CODE
         VTCALL EXCP          GO GET A DSCB
         MEND
*
*        MACRO FOR INITIALIZING SUBROUTINE WORK AREA ADDRESSES
*
         MACRO
&LABEL   WORKADDR &RTN,&PRMADDR
&LABEL   L     R1,=A(WORK&RTN-WORKAREA)  GET THE OFFSET ( OVER 4K )
         LA    R1,0(R1,R13)   RELOCATE IT
         ST    R1,&PRMADDR   THEN STORE IT FOR THE ROUTINES
         MEND
*
         EJECT
VTOCCMD  ENTERX 12,(1,LENWORK,C)     DO THE HOUSEKEEPING
         LR    R2,R1          SAVE ADDR OF CPPL
         SPACE
         USING WORKAREA,WORKREG
         EJECT
         BAL   R14,PARSINIT   PERFORM THE PARSING
         LTR   R15,R15        TEST THE RETURN CODE
         BNZ   RETURN         BAD NEWS, GET OUT
         VTCALL PRNT         INITIALIZE FOR PRINTING
         L     R9,ADDRANSR    ADDR OF PARSE DESCRIPTOR LIST
         USING PDL,R9         RETURNED BY PARSE
*
*
*        SCAN SORT PARSE LIST AND BUILD SORT FIELD TABLE
*
*
SORTPAR  LA    R4,SUBSORT     SORT PARSE LIST
         LA    R5,SORTTAB     SORT FIELD TABLE
         XC    0(64,R5),0(R5) CLEAR SORT FIELD TABLE
         MVC   0(4,R5),SORTTABX DEFAULT TO DSNAME
         SPACE 1
SORTPAR1 LA    R1,SORTTABX-12 SORT COMPARE TABLE
         SPACE 1
SORTPAR2 LA    R1,12(0,R1)    POINT TO NEXT COMPARE ENTRY
         CLC   0(4,R1),=F'0'  END OF TABLE
         BE    SORTPAR3       ITEM NOT FOUND, IGNORE
         L     R6,0(0,R4)     POINT TO TEXT
         LH    R3,4(0,R4)     TEXT LENGTH
         LTR   R3,R3          IGNORE IF ZERO
         BZ    SORTPAR3
         BCTR  R3,0
         EX    R3,SORTCOMP    FIELD NAME MATCH
         BE    SORTPAR4       YES
         B     SORTPAR2       NO, TRY NEXT
         SPACE 1
SORTPAR3 ICM   R4,7,9(R4)     NEXT ITEM
         BNZ   SORTPAR1       CONTINUE IF MORE
         B     SORTPAR5
         SPACE 1
SORTPAR4 MVC   0(4,R5),0(R1)  SET UP SORT FIELD
         ICM   R4,7,9(R4)     ASCENDING/DESCENDING INDICATOR
         BZ    PARMERR        ERROR IF MISSING
         L     R6,0(0,R4)     INDICATOR ADDR
         CLC   4(2,R4),=F'0'  ERROR IF MISSING
         BE    PARMERR
         MVC   0(1,R5),0(R6)  A/D INDICATOR
         LA    R5,4(0,R5)
         CLI   0(R6),C'A'     ASCENDING SORT
         BE    SORTPAR3       YES, OK
         CLI   0(R6),C'D'     DESCENDING SORT
         BNE   PARMERR        NO, ERROR
         B     SORTPAR3       CHECK IF ANY MORE
         SPACE 1
SORTCOMP CLC   4(0,R1),0(R6)
         SPACE 1
SORTPAR5 LA    R3,SORTKTAB-12 SORT HEADER INDEX TABLE
SORTK1   LA    R3,12(0,R3)    NEXT ENTRY
         CLC   0(4,R3),=F'0'  END OF TABLE
         BE    SORTK3         YES
         CLC   SORTTAB+1(1),1(R3)  ENTRY MATCH
         BNE   SORTK1         NO, CHECK NEXT
         SR    R4,R4
         LH    R5,2(0,R3)     LOAD TABLE LENGTH
         D     R4,=F'12'      TABLE ENTRIES
         LA    R5,1(0,R5)
         LA    R6,VTCSORTH
         L     R4,4(0,R3)     LOAD TABLE BEGIN ADDR
         CLI   SORTTAB,C'D'   DESCENDING SORT
         BE    SORTK2         YES
         L     R4,8(0,R3)     LOAD TABLE END ADDR
SORTK2   MVC   0(12,R6),0(R4)
         LA    R4,12(0,R4)
         LA    R6,12(0,R6)
         CLI   SORTTAB,C'D'   DESCENDING SORT
         BE    *+8            YES
         S     R4,=F'24'
         BCT   R5,SORTK2
         B     SORTK4
SORTK3   MVC   VTCSORTH(12),=3F'0'
SORTK4   MVC   0(12,R6),=3F'0'
*
*        CHECK THROUGH THE UCB'S TO SELECT THE VOLUMES TO PROCESS
*
*
**  FIND A VOLUME SERIAL NUMBER
*
         LA    R3,VOLS        POINT TO THE PDL
LOOP1    L     R5,0(R3)       GET THE ADDRESS OF THE TEXT
         LH    R4,4(R3)       ALSO GET ITS LENGTH
         LTR   R4,R4          FOR EXECUTES, GET THE LENGTH
         BZ    PHASE2         NO MORE VOLUMES, CONTINUE TO NEXT PHASE
         BCTR  R4,0           MAKE IT READY FOR THE EX INSTR
         MVC   VOLSER,BLANKS   INITIALIZE FIELD
         EX    R4,MOVVOL
*
**  VOLUME FOUND - VERIFY AND CHECK FOR GLOBAL OR SPECIAL REQUESTS
*
         CH    R4,H5          IS THE ENTIRE NAME THERE?
         BE    VOLSET         YES, IT'S A SPECIFIC VOLUME
         MVI   FLAG,X'01'     IT'S A GENERIC REQUEST
         CH    R4,H2          CHECK FOR THE ALL KEYWORD, FIRST LENGTH
         BNE   VOLSET         NOT A GLOBAL REQUEST
         CLC   0(3,R5),CHARALV  IS THIS THE KEYWORD 'ALLV'?
         BE    VOLSETV        NO, NOT A GLOBAL REQUEST
         CLC   0(3,R5),CHARALL  IS THIS THE KEYWORD 'ALL'?
         BNE   VOLSET         NO, NOT A GLOBAL REQUEST
         MVI   FLAG,X'02'   GLOBAL REQUEST
         B     VOLSET
*
**  FIND THE A(UCB)
*
VOLSETV  MVI   FLAG,X'82'   GLOBAL REQUEST FOR VIRTUAL
         B     VOLSET
VOLSET   LA    R5,UCBWORK         WORK AREA ADDRESS             ABL-UCB
         LA    R6,=AL1(UCB3DACC)  DASD UCB'S DESIRED            ABL-UCB
         LA    R7,UCBANSR         RESULTANT UCB ADDRESS         ABL-UCB
         STM   R5,R7,UCBPARMS     SAVE PARAMETER LIST           ABL-UCB
         OI    UCBPARMS+8,X'80'   MARK END OF LIST              ABL-UCB
         SPACE 1                                                ABL-UCB
INCR1    LA    R1,UCBPARMS           START OF PARAMETER LIST    ABL-UCB
         L     R5,16                 A(CVT)                     ABL-UCB
         L     R15,CVTUCBSC-CVT(R5)  START OF UCB SCAN SERVICE  ABL-UCB
         BALR  R14,R15               GO SCAN UCB LIST           ABL-UCB
         SPACE 1                                                ABL-UCB
         LTR   R15,R15               END OF LIST?               ABL-UCB
         BNZ   NOTMNT                YES, BRANCH                ABL-UCB
         L     R6,UCBANSR            START OF THIS UCB          ABL-UCB
         SPACE 1                                                ABL-UCB
         TM    FLAG,X'02'   CHECK FOR GLOBAL
         BO    FNDGBL   IT IS
         TM    FLAG,X'01'   CHECK FOR SPECIAL REQUESTS
         BO    SPECUCB   IT IS
         CLC   VOLSER,28(R6)   COMPARE FULL VOLSER
         BE    FNDUCB   FOUND IT
         B     INCR1
SPECUCB  EX    R4,CLCVOL   COMPARE FIRST X CHARACTERS ONLY
         BE    CHKRDY
         B     INCR1                                            ABL-UCB
*
*        VARIOUS ERRORS, LET THE PERSON KNOW
*
NOTMNT   TM    FLAG,X'04'     WAS A VOLUME  FOUND?
         BO    NEXTVOL        YES, LOOK FOR THE NEXT SPEC
         MVC   MSGTEXT2,MSGNOTMT  NO, GET THE ERROR MESSAGE
SETVOL   MVC   MSGTEXT2+5(6),VOLSER ADD THE VOLUME SERIAL NUMBER
         VTOCMSG MSGTEXT2     AND ISSUE THE MESSAGE
         B     NEXTVOL       GO GET THE NEXT VOLUME FROM PARSE
PENDING  MVC   MSGTEXT2,MSGPEND   SET UP THE MESSAGE
*
*        SEE IF THIS IS A GENERIC OR GLOBAL REQUEST
*
         TM    FLAG,X'03'    WAS IT ALL OR A PARTIAL VOLUME SERIAL?
         BNZ   INCR1         IN EITHER CASE, SKIP THE MESSAGE
*                            THEN FIND MORE VOLUMES
*
*        OUTPUT THE OFFLINE PENDING MESSAGE
         B     SETVOL         THEN ADD THE VOLUME
OFFLINE  MVC   MSGTEXT2,MSGOFFLN SET UP THE MESSAGE
         B     SETVOL         THEN ADD THE VOLUME
*
**  FOR GLOBAL REQUESTS JUST LIST ONLINE PACKS
*
FNDGBL   TM    3(R6),X'80'   ONLINE BIT
         BZ    INCR1   NOPE
*
**  FOR GLOBAL AND SPECIAL REQUESTS, CHECK FOR DEVICE READY
*
CHKRDY   TM    6(R6),X'40'   TEST READY BIT
         BO    INCR1   NOT READY
         TM    FLAG,X'80'   GLOBAL REQUEST FOR VIRTUAL
         BO    CHKVIRT
         TM    FLAG,X'02'   GLOBAL REQUEST
         BZ    FNDUCB
         TM    17(R6),X'08'  VIRTUAL UCB
         BO    INCR1   YES
         B     FNDUCB
CHKVIRT  TM    17(R6),X'08'  VIRTUAL UCB
         BZ    INCR1   NO
*
**  MOVE UCB INFORMATION TO OUTPUT LINE
*
FNDUCB   MVC   VOLID,28(R6)   MOVE VOLID
         MVC   ADDR,13(R6)   MOVE UNIT ADDRESS
         OI    FLAG,X'04'      NOTE THE VOLUME AS FOUND
*
**  IF OFFLINE, DO NOT PROCESS
*
         TM    3(R6),X'40'   PENDING BIT - SHOULD BE OFF
         BO    PENDING
         TM    3(R6),X'80'   ONLINE BIT - SHOULD BE ON
         BZ    OFFLINE
*
*        NOW GET DSCB'S FROM THE VOLUME
*
*
*        SET UP THE PARM LIST FOR VTOCEXCP
*
         VTOCEXCP OPEN        OPEN THE VTOC
         LTR   R15,R15        DID IT OPEN OK?
         BNE   RETURN         NO, JUST EXIT
READDSCB CLI   TABFULL,0     CHECK FOR FULL TABLES
         BNE   ENDVTOC       IF FULL, TRY END OF VTOC TO CLEAR
         VTOCEXCP READ        GET A DSCB
         CH    R15,H4         CHECK THE RETURN CODE
         BE    ENDVTOC        END OF VTOC
         BH    RETURN         BAD ERROR, VTOCEXCP GAVE THE MESSAGE
*
*        CHECK THE DATA SET QUALIFICATIONS, LIMIT, AND, OR
*
         VTCALL CHEK          CALL THE CHECK ROUTINE
         LTR   R15,R15        DOES THIS DATA SET GET PASSED ON?
         BNZ   READDSCB       NO, GET ANOTHER
*                             YES, CONTINUE PROCESSING
*
*        FORMAT THE DSCB INFORMATION
*
         TM    VTCFMTCK,VTCFMTCD WAS FORMAT CALLED BY CHECK?
         BO    CALLEXIT       YES, DON'T CALL IT AGAIN
         VTCALL FORM          CALL THE FORMATTING ROUTINE
         LTR   R15,R15        DID IT FUNCTION?
         BNZ   READDSCB       NO, GET ANOTHER DSCB
*
*        CALL THE EXIT ROUTINE IF ONE WAS SPECIFIED
*
CALLEXIT VTCALL EXIT,TEST     CALL THE EXIT ROUTINE
         LTR   R15,R15        SHOULD THE DATA SET BE PASSED ON?
         BNZ   READDSCB       NO, GET ANOTHER DSCB
*
*        SORT THE ENTRIES INTO THE NEW LIST
*
         VTCALL SORT          CALL THE SORT ROUTINE
         B     READDSCB       GET ANOTHER DSCB
*
*        END OF THE VOLUME, CHECK FOR MORE
*
ENDVTOC  VTOCEXCP CLOSE FIRST CLOSE THE VTOC
*
ENDVOL   TM    FLAG,X'03'         IS THIS A GENERIC VOLUME SEARCH
         BNZ   INCR1              YES, SEARCH FOR MORE
NEXTVOL  ICM   R3,B'0111',25(R3)  GET THE NEXT VOLUME FROM THE PDL
         BP    LOOP1              THERE IS ANOTHER, GET IT
*
*        PRINT THE SELECTED ITEMS FOR THE SELECTED DATA SETS
*
PHASE2   DS    0H
         VTCALL PRNT          CALL THE PRINT ROUTINE
         B     EXIT0
         EJECT
*
*        PROCESSING IS COMPLETE, EXEUNT
*
PARMERR  LA    R15,16
         B     RETURN
EXIT0    SR    R15,R15
         SPACE 3
RETURN   LTR   R2,R15         NORMAL EXIT?
         BZ    RETURN1        YES, LEAVE EVERY THING ALONE
         SPACE 2
         LA    R1,PARMLIST    AREA FOR STACK PARM LIST
         USING IOPL,R1        AN ERROR WAS FOUND, FLUSH THE STACK
         SPACE
         MVC   IOPLUPT,ADDRUPT
         MVC   IOPLECT,ADDRECT
         LA    R0,ATTNECB
         MVI   ATTNECB,0
         ST    R0,IOPLECB
         SPACE 2
         STACK PARM=PARMLIST+16,DELETE=ALL,MF=(E,(1))
         SPACE 3
         TCLEARQ INPUT        CLEAR INPUT BUFFERS
         SPACE 3
RETURN1  DS    0H
         BAL   R14,FREEPDL    FREE THE PARSE STROAGE
         MVI   VTCEPRNT,15    TELL PRINT TO CLEAN UP HIS ACT
*                                CLOSE DATA SETS AND FREE MAIN STORAGE
         VTCALL PRNT          CALL THE PRINT ROUTINE
         SPACE
         LR    R15,R2          GET THE RETURN CODE AGAIN
         LEAVE EQ
WORKREG  EQU   13
*
*        PARSE INITIALIZATION
*
         SPACE 3
PARSINIT DS    0H
         ST    R2,CPPLADDR    AND THE CPPL ADDRESS
         USING CPPL,R2        BASE FOR COMMAND PARM LIST
         MVC   ADDRUPT,CPPLUPT ADDR OF USER PROFILE TABLE
         MVC   ADDRPSCB,CPPLPSCB
         MVC   ADDRECT,CPPLECT ADDR OF ENVIROMENT TABLE
         MVC   ADDRCBUF,CPPLCBUF
         DROP  R2
         SPACE 3
*
*        PUT THE WORK AREA ADDRESSES INTO THE PARM LISTS
*
         WORKADDR MSG,VTCWMSG     WORK AREA FOR VTOCMSG
         WORKADDR EXCP,VTCWEXCP   WORK AREA FOR VTOCEXCP
         WORKADDR CHEK,VTCWCHEK   WORK AREA FOR VTOCCHEK
         WORKADDR FORM,VTCWFORM   WORK AREA FOR VTOCFORM
         WORKADDR EXIT,VTCWEXIT   WORK AREA FOR VTOCEXIT
         WORKADDR SORT,VTCWSORT   WORK AREA FOR VTOCSORT
         WORKADDR PRNT,VTCWPRNT   WORK AREA FOR VTOCPRNT
         SPACE 3
*        SET UP THE ADDRESSES FOR CALLING
*
         MVC   VADMSG(RTNADLEN),RTNADDRS  MOVE IN THE ADDRESSES
*
*
*
*        BUILD PARSE PARAMETER LIST AND INVOKE
*        IKJPARS TO ANALYZE COMMAND OPERANDS
*
         SPACE 3
GOPARSE  DS    0H
         ST    R14,R14PARSE   SAVE THE RETURN ADDRESS
         LA    R1,PARSELST    AREA FOR PARSE PARAMETERS
         USING PPL,R1         BASE FOR PARSE PARAMETER LIST
         SPACE 2
         MVC   PPLUPT,ADDRUPT PASS UPT ADDRESS
         MVC   PPLECT,ADDRECT AND ECT ADDRESS
         MVC   PPLCBUF,ADDRCBUF AND COMMAND BUFFER ADDR
         SPACE
         ST    WORKREG,PPLUWA ALSO WORK AREA ADDR FOR VALIDITY EXITS
         SPACE
         LA    R0,ATTNECB     ECB FOR ATTN INTERRUPTS
         MVI   ATTNECB,0      CLEAR ECB
         ST    R0,PPLECB      PASSE TO PARSE
         SPACE
         LA    R0,ADDRANSR    PASS ADDR OF WORD WHERE PARSE
         ST    R0,PPLANS      RETURNS PDL ADDRESS
         SPACE
         MVC   PPLPCL,ADDRPCL STORE PCL ADDRESS
         SPACE 3
         CALLTSSR EP=IKJPARS  INVOKE PARSE
         DROP  R1
         SPACE 2
         LA    R14,MAXPARSE   RETURN CODE LIMIT
         SPACE
         CR    R15,R14        VERIFY RETURN CODE WITHIN LIMITS
         BH    PARSEBAD       NO, ERROR
         SPACE
         B     *+4(R15)       PROCESS RETURN CODE
         SPACE
PARSERET B     PARSEOK         0- SUCESSFUL
         B     PARSEERR        4- PARSE UNABLE TO PROMPT
         B     PARSEERR        8- USER ENTERED ATTENTION
         B     PARSEBAD       12- INVALID PARAMETERS
         B     PARSEBAD       16- PARSE INTERNAL FAILURE
         B     PARSEERR       20 - VALIDITY CHECK ERROR
MAXPARSE EQU   *-PARSERET
         SPACE 5
PARSEBAD DS    0H
         MVC   MSGTEXT2+4(L'MSGPARSE),MSGPARSE
         LA    R1,MSGTEXT2+4+L'MSGPARSE
         SPACE
         CVD   R15,DOUBLE
         OI    DOUBLE+7,X'0F'
         UNPK  0(2,R1),DOUBLE
         SPACE
         LA    R0,MSGTEXT2-2
         SR    R1,R0
         SLL   R1,16
         ST    R1,MSGTEXT2
         SPACE 2
         VTOCMSG MSGCMDER,MSGTEXT2    PUT OUT 'COMMAND ERROR' MSG
         SPACE 3
PARSEERR LA    R15,12         ERROR CODE 12 - COMMAND FAILED
         B     PARSERTN       RETURN FROM PARSE
         SPACE
PARSEOK  SR    R15,R15        CLEAR THE RETURN CODE
PARSERTN L     R14,R14PARSE   GET THE RETURN LOCATION
         BR    R14            AND GET OUT OF HERE
         SPACE
         EJECT
*
*        PARSE CLEANUP ROUTINE
*
         SPACE 3
FREEPDL  DS    0H
         SPACE
         ST    R14,R14SAVE
         SPACE
         IKJRLSA ADDRANSR     RELEASE THE STORAGE
         SPACE 2
         XC    ADDRANSR,ADDRANSR
         SPACE
         L     R14,R14SAVE
         BR    R14
         EJECT
*
*
*        CONSTANTS
*
*
         LTORG
RTNADDRS DC    V(VTOCMSG)
         DC    A(0)           DUMMY ENTRY FOR THE EXIT ROUTINE
         DC    V(VTOCEXCP)
         DC    V(VTOCCHEK)
         DC    V(VTOCFORM)
         DC    V(VTOCPRNT)
         DC    V(VTOCSORT)
RTNADLEN EQU   *-RTNADDRS
ADDRPCL  DC    A(PCLMAIN)     ADDR OF MAIN PARSE CONTROL LIST
FMIN1    DC    X'0000FFFF'    END OF UCB LIST
BLANKS   DC    CL8' '         BALNKS
H2       DC    H'2'
H4       DC    H'4'
H5       DC    H'5'
*
*
*
*
*
CHARALL  DC    CL3'ALL'
CHARALV  DC    CL3'ALV'
MOVVOL   MVC   VOLSER(0),0(R5)
CLCVOL   CLC   VOLSER(0),28(R6)
         EJECT
SORTTABX DC    AL2(VTFDSN-VTFMT),AL2(43),CL8'DSNAME'
         DC    AL2(VTFVOLUM-VTFMT),AL2(5),CL8'VOLUME'
         DC    AL2(VTFALLOC-VTFMT),AL2(3),CL8'ALLOC'
         DC    AL2(VTFUSED-VTFMT),AL2(3),CL8'USED'
         DC    AL2(VTFUNUSD-VTFMT),AL2(3),CL8'UNUSED'
         DC    AL2(VTFPCT-VTFMT),AL2(1),CL8'PCT'
         DC    AL2(VTFNOEPV-VTFMT),AL2(0),CL8'EX'
         DC    AL2(VTFDSORG-VTFMT),AL2(2),CL8'DSO'
         DC    AL2(VTFRECFM-VTFMT),AL2(4),CL8'RFM'
         DC    AL2(VTFLRECL-VTFMT),AL2(1),CL8'LRECL'
         DC    AL2(VTFBLKSZ-VTFMT),AL2(1),CL8'BLKSZ'
         DC    AL2(VTFCREDT-VTFMT),AL2(2),CL8'CDATE'
         DC    AL2(VTFEXPDT-VTFMT),AL2(2),CL8'EXPDT'
         DC    AL2(VTFLSTAC-VTFMT),AL2(2),CL8'REFDT'
         DC    F'0'
         EJECT
*
*        PROGRAM MESSAGES
*
         SPACE 2
         PRINT NOGEN
         SPACE
MSGPARSE MSG   ' PARSE ERROR CODE '
MSGCMDER MSG   ' COMMAND SYSTEM ERROR'
MSGNOTMT MSG   ' VVVVVV VOLUME IS NOT MOUNTED'
MSGOFFLN MSG   ' VVVVVV VOLUME IS OFFLINE'
MSGPEND  MSG   ' VVVVVV VOLUME IS PENDING OFFLINE'
*
*
         EJECT
         DS    0F
SORTKTAB DC    AL2(VTFDSN-VTFMT),AL2(DSNSORTE-DSNSORT)
         DC    A(DSNSORT),A(DSNSORTE)
         DC    AL2(VTFVOLUM-VTFMT),AL2(VOLSORTE-VOLSORT)
         DC    A(VOLSORT),A(VOLSORTE)
         DC    AL2(VTFUSED-VTFMT),AL2(USESORTE-USESORT)
         DC    A(USESORT),A(USESORTE)
         DC    AL2(VTFALLOC-VTFMT),AL2(ALCSORTE-ALCSORT)
         DC    A(ALCSORT),A(ALCSORTE)
         DC    AL2(VTFUNUSD-VTFMT),AL2(UNUSORTE-UNUSORT)
         DC    A(UNUSORT),A(UNUSORTE)
         DC    AL2(VTFPCT-VTFMT),AL2(PCTSORTE-PCTSORT)
         DC    A(PCTSORT),A(PCTSORTE)
         DC    AL2(VTFNOEPV-VTFMT),AL2(EXTSORTE-EXTSORT)
         DC    A(EXTSORT),A(EXTSORTE)
         DC    AL2(VTFDSORG-VTFMT),AL2(DSOSORTE-DSOSORT)
         DC    A(DSOSORT),A(DSOSORTE)
         DC    AL2(VTFRECFM-VTFMT),AL2(RFMSORTE-RFMSORT)
         DC    A(RFMSORT),A(RFMSORTE)
         DC    AL2(VTFLRECL-VTFMT),AL2(LRCSORTE-LRCSORT)
         DC    A(LRCSORT),A(LRCSORTE)
         DC    AL2(VTFBLKSZ-VTFMT),AL2(BLKSORTE-BLKSORT)
         DC    A(BLKSORT),A(BLKSORTE)
         DC    AL2(VTFCREDT-VTFMT),AL2(CDTSORTE-CDTSORT)
         DC    A(CDTSORT),A(CDTSORTE)
         DC    AL2(VTFLSTAC-VTFMT),AL2(RDTSORTE-RDTSORT)
         DC    A(RDTSORT),A(RDTSORTE)
         DC    AL2(VTFEXPDT-VTFMT),AL2(EDTSORTE-EDTSORT)
         DC    A(EDTSORT),A(EDTSORTE)
         DC    2F'0'
         SPACE 3
DSNSORT  DC    A(0),AL2(0),CL6'Z'
         DC    A(0),AL2(1),CL6'TV'
         DC    A(0),AL2(1),CL6'TM'
         DC    A(0),AL2(2),CL6'T.Z'
         DC    A(0),AL2(2),CL6'T.Y'
         DC    A(0),AL2(2),CL6'T.X'
         DC    A(0),AL2(2),CL6'T.W'
         DC    A(0),AL2(2),CL6'T.V'
         DC    A(0),AL2(2),CL6'T.U'
         DC    A(0),AL2(2),CL6'T.T'
         DC    A(0),AL2(2),CL6'T.S'
         DC    A(0),AL2(2),CL6'T.R'
         DC    A(0),AL2(2),CL6'T.Q'
         DC    A(0),AL2(2),CL6'T.P'
         DC    A(0),AL2(2),CL6'T.O'
         DC    A(0),AL2(2),CL6'T.N'
         DC    A(0),AL2(2),CL6'T.M'
         DC    A(0),AL2(2),CL6'T.L'
         DC    A(0),AL2(2),CL6'T.K'
         DC    A(0),AL2(2),CL6'T.J'
         DC    A(0),AL2(2),CL6'T.I'
         DC    A(0),AL2(2),CL6'T.H'
         DC    A(0),AL2(2),CL6'T.G'
         DC    A(0),AL2(2),CL6'T.F'
         DC    A(0),AL2(2),CL6'T.E'
         DC    A(0),AL2(2),CL6'T.D'
         DC    A(0),AL2(2),CL6'T.C'
         DC    A(0),AL2(2),CL6'T.B'
         DC    A(0),AL2(2),CL6'T.A'
         DC    A(0),AL2(1),CL6'SY'
         DC    A(0),AL2(1),CL6'SV'
         DC    A(0),AL2(1),CL6'PV'
         DC    A(0),AL2(2),CL6'P.Z'
         DC    A(0),AL2(2),CL6'P.Y'
         DC    A(0),AL2(2),CL6'P.X'
         DC    A(0),AL2(2),CL6'P.W'
         DC    A(0),AL2(2),CL6'P.V'
         DC    A(0),AL2(2),CL6'P.U'
         DC    A(0),AL2(2),CL6'P.T'
         DC    A(0),AL2(2),CL6'P.S'
         DC    A(0),AL2(2),CL6'P.R'
         DC    A(0),AL2(2),CL6'P.Q'
         DC    A(0),AL2(2),CL6'P.P'
         DC    A(0),AL2(2),CL6'P.O'
         DC    A(0),AL2(2),CL6'P.N'
         DC    A(0),AL2(2),CL6'P.M'
         DC    A(0),AL2(2),CL6'P.L'
         DC    A(0),AL2(2),CL6'P.K'
         DC    A(0),AL2(2),CL6'P.J'
         DC    A(0),AL2(2),CL6'P.I'
         DC    A(0),AL2(2),CL6'P.H'
         DC    A(0),AL2(2),CL6'P.G'
         DC    A(0),AL2(2),CL6'P.F'
         DC    A(0),AL2(2),CL6'P.E'
         DC    A(0),AL2(2),CL6'P.D'
         DC    A(0),AL2(2),CL6'P.C'
         DC    A(0),AL2(2),CL6'P.B'
         DC    A(0),AL2(2),CL6'P.A'
         DC    A(0),AL2(0),CL6'N'
DSNSORTE DC    A(0),AL2(0),CL6' '
         SPACE 3
VOLSORT  DC    A(0),AL2(4),CL6'33509'
         DC    A(0),AL2(4),CL6'33508'
         DC    A(0),AL2(4),CL6'33507'
         DC    A(0),AL2(4),CL6'33506'
         DC    A(0),AL2(4),CL6'33505'
         DC    A(0),AL2(4),CL6'33504'
         DC    A(0),AL2(4),CL6'33503'
         DC    A(0),AL2(4),CL6'33502'
         DC    A(0),AL2(4),CL6'33501'
         DC    A(0),AL2(4),CL6'33500'
         DC    A(0),AL2(4),CL6'33309'
         DC    A(0),AL2(4),CL6'33308'
         DC    A(0),AL2(4),CL6'33307'
         DC    A(0),AL2(4),CL6'33306'
         DC    A(0),AL2(4),CL6'33305'
         DC    A(0),AL2(4),CL6'33304'
         DC    A(0),AL2(4),CL6'33303'
         DC    A(0),AL2(4),CL6'33302'
         DC    A(0),AL2(4),CL6'33301'
         DC    A(0),AL2(4),CL6'33300'
         DC    A(0),AL2(0),CL6'T'
         DC    A(0),AL2(0),CL6'R'
         DC    A(0),AL2(0),CL6'P'
         DC    A(0),AL2(0),CL6'M'
         DC    A(0),AL2(0),CL6'I'
         DC    A(0),AL2(0),CL6'H'
VOLSORTE DC    A(0),AL2(0),CL6' '
         SPACE 3
USESORT  DS    0F
UNUSORT  DS    0F
ALCSORT  DC    A(0),AL2(3),XL4'0000F000',XL2'00'
         DC    A(0),AL2(3),XL4'0000C000',XL2'00'
         DC    A(0),AL2(3),XL4'0000A000',XL2'00'
         DC    A(0),AL2(3),XL4'00008000',XL2'00'
         DC    A(0),AL2(3),XL4'00006000',XL2'00'
         DC    A(0),AL2(3),XL4'00005000',XL2'00'
         DC    A(0),AL2(3),XL4'00004000',XL2'00'
         DC    A(0),AL2(3),XL4'00003000',XL2'00'
         DC    A(0),AL2(3),XL4'00002000',XL2'00'
         DC    A(0),AL2(3),XL4'00001000',XL2'00'
         DC    A(0),AL2(3),XL4'00000C00',XL2'00'
         DC    A(0),AL2(3),XL4'00000800',XL2'00'
         DC    A(0),AL2(3),XL4'00000400',XL2'00'
         DC    A(0),AL2(3),XL4'00000300',XL2'00'
         DC    A(0),AL2(3),XL4'00000200',XL2'00'
         DC    A(0),AL2(3),XL4'00000100',XL2'00'
         DC    A(0),AL2(3),XL4'000000C0',XL2'00'
         DC    A(0),AL2(3),XL4'00000080',XL2'00'
         DC    A(0),AL2(3),XL4'00000040',XL2'00'
         DC    A(0),AL2(3),XL4'00000010',XL2'00'
USESORTE DS    0F
UNUSORTE DS    0F
ALCSORTE DC    A(0),AL2(3),XL6'00'
         SPACE 3
PCTSORT  DC    A(0),AL2(1),XL2'0064',XL4'00'
         DC    A(0),AL2(1),XL2'005A',XL4'00'
         DC    A(0),AL2(1),XL2'0050',XL4'00'
         DC    A(0),AL2(1),XL2'0046',XL4'00'
         DC    A(0),AL2(1),XL2'003C',XL4'00'
         DC    A(0),AL2(1),XL2'0032',XL4'00'
         DC    A(0),AL2(1),XL2'0028',XL4'00'
         DC    A(0),AL2(1),XL2'001E',XL4'00'
         DC    A(0),AL2(1),XL2'0014',XL4'00'
         DC    A(0),AL2(1),XL2'000A',XL4'00'
PCTSORTE DC    A(0),AL2(1),XL6'00'
         SPACE 3
EXTSORT  DC    A(0),AL2(0),CL6'0'
EXTSORTE DC    A(0),AL2(0),CL6'0'
         SPACE 3
DSOSORT  DC    A(0),AL2(1),CL6'VS'
         DC    A(0),AL2(1),CL6'PS'
         DC    A(0),AL2(1),CL6'PO'
         DC    A(0),AL2(1),CL6'DA'
DSOSORTE DC    A(0),AL2(1),CL6' '
         SPACE 3
RFMSORT  DC    A(0),AL2(1),CL6'VS'
         DC    A(0),AL2(2),CL6'VBS'
         DC    A(0),AL2(1),CL6'VB'
         DC    A(0),AL2(0),CL6'V'
         DC    A(0),AL2(0),CL6'U'
         DC    A(0),AL2(1),CL6'FS'
         DC    A(0),AL2(2),CL6'FBS'
         DC    A(0),AL2(1),CL6'FB'
         DC    A(0),AL2(0),CL6'F'
RFMSORTE DC    A(0),AL2(0),CL6' '
         SPACE 3
LRCSORT  DS    0F
BLKSORT  DC    A(0),AL2(1),XL2'4650',XL4'00'
         DC    A(0),AL2(1),XL2'3A98',XL4'00'
         DC    A(0),AL2(1),XL2'2EE0',XL4'00'
         DC    A(0),AL2(1),XL2'2328',XL4'00'
         DC    A(0),AL2(1),XL2'1770',XL4'00'
         DC    A(0),AL2(1),XL2'0BB8',XL4'00'
         DC    A(0),AL2(1),XL2'07D0',XL4'00'
         DC    A(0),AL2(1),XL2'0640',XL4'00'
         DC    A(0),AL2(1),XL2'04B0',XL4'00'
         DC    A(0),AL2(1),XL2'0320',XL4'00'
         DC    A(0),AL2(1),XL2'0258',XL4'00'
         DC    A(0),AL2(1),XL2'0190',XL4'00'
         DC    A(0),AL2(1),XL2'00C8',XL4'00'
         DC    A(0),AL2(1),XL2'00A0',XL4'00'
         DC    A(0),AL2(1),XL2'0078',XL4'00'
         DC    A(0),AL2(1),XL2'0050',XL4'00'
         DC    A(0),AL2(1),XL2'0028',XL4'00'
BLKSORTE DS    0F
LRCSORTE DC    A(0),AL2(1),XL6'00'
         SPACE 3
CDTSORT  DS    0F
EDTSORT  DS    0F
RDTSORT  DC    A(0),AL2(2),AL1(99),AL2(0),XL3'00'
         DC    A(0),AL2(2),AL1(83),AL2(300),XL3'00'
         DC    A(0),AL2(2),AL1(83),AL2(200),XL3'00'
         DC    A(0),AL2(2),AL1(83),AL2(100),XL3'00'
         DC    A(0),AL2(2),AL1(83),AL2(000),XL3'00'
         DC    A(0),AL2(2),AL1(82),AL2(300),XL3'00'
         DC    A(0),AL2(2),AL1(82),AL2(200),XL3'00'
         DC    A(0),AL2(2),AL1(82),AL2(100),XL3'00'
         DC    A(0),AL2(2),AL1(82),AL2(000),XL3'00'
         DC    A(0),AL2(2),AL1(81),AL2(300),XL3'00'
         DC    A(0),AL2(2),AL1(81),AL2(200),XL3'00'
         DC    A(0),AL2(2),AL1(81),AL2(100),XL3'00'
         DC    A(0),AL2(2),AL1(81),AL2(000),XL3'00'
         DC    A(0),AL2(2),AL1(80),AL2(300),XL3'00'
         DC    A(0),AL2(2),AL1(80),AL2(200),XL3'00'
         DC    A(0),AL2(2),AL1(80),AL2(100),XL3'00'
         DC    A(0),AL2(2),AL1(80),AL2(000),XL3'00'
         DC    A(0),AL2(2),AL1(79),AL2(300),XL3'00'
         DC    A(0),AL2(2),AL1(79),AL2(200),XL3'00'
         DC    A(0),AL2(2),AL1(79),AL2(100),XL3'00'
         DC    A(0),AL2(2),AL1(79),AL2(000),XL3'00'
         DC    A(0),AL2(2),AL1(78),AL2(300),XL3'00'
         DC    A(0),AL2(2),AL1(78),AL2(200),XL3'00'
         DC    A(0),AL2(2),AL1(78),AL2(100),XL3'00'
         DC    A(0),AL2(2),AL1(78),AL2(000),XL3'00'
         DC    A(0),AL2(2),AL1(77),AL2(300),XL3'00'
         DC    A(0),AL2(2),AL1(77),AL2(200),XL3'00'
         DC    A(0),AL2(2),AL1(77),AL2(100),XL3'00'
         DC    A(0),AL2(2),AL1(77),AL2(000),XL3'00'
         DC    A(0),AL2(2),AL1(76),AL2(300),XL3'00'
         DC    A(0),AL2(2),AL1(76),AL2(200),XL3'00'
         DC    A(0),AL2(2),AL1(76),AL2(100),XL3'00'
         DC    A(0),AL2(2),AL1(76),AL2(000),XL3'00'
         DC    A(0),AL2(2),AL1(75),AL2(300),XL3'00'
         DC    A(0),AL2(2),AL1(75),AL2(200),XL3'00'
         DC    A(0),AL2(2),AL1(75),AL2(100),XL3'00'
         DC    A(0),AL2(2),AL1(75),AL2(000),XL3'00'
EDTSORTE DS    0F
RDTSORTE DS    0F
CDTSORTE DC    A(0),AL2(2),XL6'00'
         EJECT
*
*
*        P A R S E   C O N T R O L   L I S T
*
*
         SPACE 3
         COPY  VTOCPARS
         EJECT
*
*        DYNAMIC WORK AREA
*
         SPACE 3
WORKAREA DSECT
MAINSAVE DS    18A
         SPACE
         VTOCEXCP EQ          DEFINE VTOCEXCP CODES
         SPACE
PARSELST DS    8A             AREA FOR PARSE PARAMETER LIST
         SPACE
R14SAVE  DS    A
R14PARSE DS    A
*
*        VTOC COMMAND COMMON AREA
*
         PRINT GEN
         VTOCOM  NODSECT
         PRINT NOGEN
         SPACE 3
*
*        WORK AREAS FOR SUBROUTINES
*
WORKMSG  DS    XL256
WORKEXCP DS    4XL256
WORKCHEK DS    XL256
WORKFORM DS    2XL256
WORKEXIT DS    8XL256
WORKSORT DS    XL256
WORKPRNT DS    10XL256
         DS    0D
LENWORK  EQU   *-WORKAREA
         SPACE 3
         VTFMT
         SPACE 3
         PDEDSNAM
         SPACE 3
         IKJPPL
         SPACE 3
         IKJIOPL
         SPACE 3
         IKJPSCB
         SPACE 3
         IKJECT
         SPACE 3
         IKJCPPL
         SPACE 3
         IKJUPT
         SPACE 3
         PRINT NOGEN
         CVT   DSECT=YES                                        ABL-UCB
         IEFUCBOB ,                                             ABL-UCB
         END   VTOCCMD                                          ABL-UCB
