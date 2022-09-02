VTOCSORT TITLE 'VTOC COMMAND  SORT  ROUTINE'
***********************************************************************
*                                                                     *
*                                                                     *
* TITLE -      VTOC COMMAND  SORT  ROUTINE                            *
*                                                                     *
* FUNCTION -   PUT THIS FORMATTED DSCB INTO THE SORTED LIST.          *
*                                                                     *
* OPERATION -  IF THIS IS A NOSORT RUN, JUST CALL THE PRINT ROUTINE.  *
*              TO BUILD THE SORTED LIST, FIRST DO A SIMPLE HASH       *
*              ON THE FIRST CHARACTER.  BUILD UP TO 256 SEPARATE      *
*              LISTS TO SAVE SORT TIME.  THEN SEARCH THROUGH THESE    *
*              LISTS SEQUENTIALLY.                                    *
*                                                                     *
* INPUT -      VTOC COMMON AREA ( VTOCOM )                            *
*              POINTED TO BY REGISTER 1                               *
*              USE PARSE DATA, CURRENT FORMATTED DSCB, SORTED LIST    *
*                                                                     *
* OUTPUT -     THE FORMATTED DSCB IS PLACED INTO THE SORTED LIST.     *
*                                                                     *
* ATTRIBUTES - REENTRANT, REUSEABLE, REFRESHABLE.                     *
*                                                                     *
*                                                                     *
*         PROGRAMMED BY R. L. MILLER  (415) 485-6241                  *
*                                                                     *
*                                                                     *
***********************************************************************
         EJECT
VTOCSORT ENTER 12,24          DO THE HOUSEKEEPING
         LR    R11,R1         SAVE ADDR OF VTOCOM
         USING VTOCOM,R11     SET ITS ADDRESSABILITY
         L     R9,ADDRANSR    POINT TO THE PARSE ANSWER
         USING PDL,R9         SET ITS ADDRESSABILITY
         USING SORTWORK,R13   SET ADDRESSABILITY FOR LOCAL WORK AREA
         SPACE 3
*
*        IS THIS A NOSORT RUN ?
*        IF SO, JUST CALL PRINT
*
         CLI   SORTK+1,2      IS THIS NOSORT?
         BNE   GOSORT         NO, KEEP ON TRUCKIN'
         VTCALL PRNT          YES, CALL PRINT AND GET OUT
         B     SORTRET        GET OUT OF HERE
*
*        PUT THIS ENTRY WHERE IT BELONGS
*
GOSORT   L     R3,FORMATAD    POINT TO THE FORMATTED DSCB
         USING VTFMT,R3       SET ADDRESSABILITY
         LA    R6,SORTTAB     POINT TO THE SORT FIELDS TABLE
         SR    R4,R4
         IC    R4,1(0,R6)     LOAD HIGH KEY OFFSET
         LA    R4,VTFMT(R4)   POINT TO HIGH KEY
         LA    R2,VTCSORTH-12 SORT HEADER AREA
GOSORT1  LA    R2,12(0,R2)    NEXT ENTRY
         LH    R5,4(0,R2)     LOAD COMAPRE LENGTH
         CLI   0(R6),C'D'     DESCENDING SORT
         BE    GOSORT3        YES
         B     GOSORT4        NO
GOSORT2  ICM   R5,B'1111',0(R2) GET THE HEAD OF THE LIST
         BNZ   NOTFIRST       IF NON-ZERO, SEARCH THE LIST
*
*        FIRST ENTRY ON THE LIST, IT'S EASY
*
         ST    R3,0(R2)       START UP THE LIST
         B     SORTRET        THEN RETURN
GOSORT3  EX    R5,GOSORTCL    COMPARE TO GET CORRECT LIST
         BL    GOSORT1
         B     GOSORT2
GOSORT4  EX    R5,GOSORTCL    COMPARE TO GET CORRECT LIST
         BH    GOSORT1
         B     GOSORT2
*
*        FIND A SLOT FOR THIS ENTRY
*              FIRST GET THE SHORTER DSN LENGTH
*
NOTFIRST SR    R1,R1
         IC    R1,1(0,R6)     OFFSET OF SORT FIELD
         LA    R7,0(R1,R5)    LOAD PREV ENTRY FIELD ADDR
         LA    R8,0(R1,R3)    LOAD NEW ENTRY FIELD ADDR
         C     R1,=A(VTFDSN-VTFMT)  DSN
         BNE   NOTFRST1
         LH    R1,VTFDSNL-VTFMT(0,R3)
         CH    R1,VTFDSNL-VTFMT(0,R5)
         BNH   NOTFRST0
         LH    R1,VTFDSNL-VTFMT(0,R5)
NOTFRST0 BCTR  R1,0
         B     NOTFRST2
NOTFRST1 LH    R1,2(0,R6)     LOAD SORT FIELD EXEC LENGTH
NOTFRST2 CLI   0(R6),C'D'     DESCENDING SORT
         BE    NOTFRST4       YES
NOTFRST3 EX    R1,COMPVTF     COMPARE THE FIELDS
         BL    NEXTENT        LIST ENTRY IS LOWER, UP THE CHAIN
         BE    CHECKNXT       IDENTICAL, CHECK NEXT FIELD
         B     INSERT
NOTFRST4 EX    R1,COMPVTF     COMPARE THE FIELDS
         BH    NEXTENT        LIST ENTRY IS LOWER, UP THE CHAIN
         BE    CHECKNXT       IDENTICAL, CHECK NEXT FIELD
*
*        THE NEW ENTRY GOES HERE
*
INSERT   ST    R3,0(R2)       SAVE THE NEW POINTER
         ST    R5,VTFNEXT     JUST BEFORE THIS LIST ENTRY
         B     SORTRET        THEN EXIT
*
*
CHECKNXT LA    R6,4(0,R6)     NEXT SORT FIELD
         CLC   0(4,R6),=F'0'  ANY MORE FIELDS
         BE    INSERT         NO, PUT IT HERE
         B     NOTFIRST       YES, CHECK IT
*
*        GET THE NEXT ENTRY ON THIS LIST
*
NEXTENT  LA    R2,VTFNEXT-VTFMT(R5)  POINT BACK TO THIS ENTRY
         LA    R6,SORTTAB     RELOAD SORT FIELD TABLE ADDR
         ICM   R5,B'1111',VTFNEXT-VTFMT(R5)  GET THE NEXT ENTRY
         BNZ   NOTFIRST       THERE IS ONE, CHECK IT
         ST    R3,0(R2)       LAST ENTRY ON THE LIST, PUT IT THERE
*
*        RETURN
*
SORTRET  LEAVE EQ,RC=0
*
*
*
*        PROGRAM CONSTANTS
*
COMPVTF  CLC   0(0,R7),0(R8)     EXECUTED COMPARE
GOSORTCL CLC   0(0,R4),6(R2)     EXECUTED COMPARE
*
*
         PRINT NOGEN
         EJECT
*
*
*        P A R S E   C O N T R O L   L I S T
*
*
         PRINT OFF
         COPY  VTOCPARS
         PRINT ON
*
*        DYNAMIC WORK AREA
*
         SPACE 3
SORTWORK DSECT
         DS    18A            PRINT ROUTINE SAVE AREA
         SPACE
         DS    0D
LENWORK  EQU   *-SORTWORK
*
*        VTOC COMMAND COMMON AREA
*
         PRINT NOGEN
         VTOCOM
         SPACE 3
*
*        FORMATTED DSCB
*
         VTFMT
         SPACE 3
         PDEDSNAM
         SPACE 3
         END
