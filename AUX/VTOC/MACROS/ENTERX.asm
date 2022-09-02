         MACRO
&SUBR    ENTERX &BASES,&SAVE,&CSECT
.*   THIS MACRO, USED WITH THE LEAVE MACRO, WILL PERFORM
.*   STANDARD HOUSEKEEPING FOR A CSECT, INCLUDING SAVEAREA
.*   CONSTRUCTION AND CHAINING, AND GETTING SOME STORAGE,
.*   IF THAT IS DESIRED.
.*   THE LEAVE MACRO WILL FREE THE GOTTEN STORAGE
.*   THE OPERANDS ARE
.*       &SUBR    ENTER  &BASES,&SAVE,&CSECT
.*    WHERE
.*       &SUBR    IS THE NAME OF THE CSECT
.*       &BASES   ARE THE BASE REGISTERS FOR THE ROUTINE
.*       &SAVE    IS THE LABEL FOR A SAVEAREA, OR A SUBPOOL
.*                AND LENGTH FOR THE GETMAIN
.*       &CSECT   TO CONTINUE AN EXISTING CSECT WITH ENTRY
.*                POINT &SUBR
.*
.*    EXAMPLES -
.*               ENTER 13,*
.*
.*       THIS WILL GENERATE NON-REENTRANT CODE, USING SAVEAREA
.*       AS THE SAVE AREA LABEL, AND REGISTER 13 FOR THE BASE
.*       REGISTER.
.*
.*       RENTMOD  ENTER (12,11),(,LDSECT)
.*
.*       THIS WILL GENERATE REENTRANT CODE WITH REGISTERS 12 AND
.*       11 FOR BASE REGISTERS.  A GETMAIN WILL BE DONE FOR THE
.*       DEFAULT SUBPOOL (0) WITH A LENGTH 'LDSECT'.
.*
         GBLC  &LV,&SP
         LCLA  &K,&N
         LCLC  &AREA,&B(16),&SUBNAME,&S
&SUBNAME SETC  '&SUBR'
         AIF   ('&SUBNAME' NE '').SUBSPEC
&SUBNAME SETC  'MAIN'         DEFAULT CSECT NAME
.SUBSPEC AIF   ('&CSECT' EQ '').NOTENT  IS IT AN ENTRY POINT?
&CSECT   CSECT
&SUBNAME DS    0F
         AGO   .CSSPEC
.NOTENT  ANOP
&SUBNAME CSECT
.CSSPEC  ANOP
         SAVE  (14,12),T,&SUBNAME   SAVE THE REGISTERS
         AIF   ('&BASES(1)' EQ '15' OR '&BASES' EQ '').R15SET
         AIF   ('&BASES(1)' EQ '13' AND '&SAVE' NE '').R15SET
         LR    &BASES(1),15  SET FIRST BASE REG
.R15SET  CNOP  0,4
&S       SETC  '&SUBNAME'
         AIF   (N'&SAVE EQ 2).P4   SUBPOOL, SIZE SPEC?
         AIF   ('&SAVE' EQ '').P3  NO SAVEAREA - DEFAULT
&AREA    SETC  '&SAVE'
         AIF   ('&SAVE' NE '*').P2
&AREA    SETC  'SAVEAREA'
.P2      AIF   ('&BASES(1)' NE '13').P4
&S       SETC  '*'
         USING &SUBNAME,15
         ST    14,&AREA+4
         LA    14,&AREA
         ST    14,8(13)
         L     14,&AREA+4
         ST    13,&AREA+4
         BAL   13,*+76        SKIP AROUND THE SAVEAREA
         DROP  15
         AGO   .P4
.P3      AIF   ('&BASES(1)' NE '13').P4
         MNOTE 8,'*** CONTENTS OF REG 13 ARE LOST.  NO SAVE AREA WAS ESX
               TABLISHED.'
.P4      AIF   ('&BASES(1)' NE '14' OR '&SAVE' EQ '').P5
         MNOTE 8,'*** MACRO RESTRICTION - REG 14 MUST NOT BE USED AS THX
               E FIRST BASE REGISTER IF A SAVE AREA IS USED.'
.P5      AIF   ('&BASES' EQ '').P9
&N       SETA  N'&BASES
.P6      ANOP
&K       SETA  &K+1
&B(&K)   SETC  ','.'&BASES(&K)'
         AIF   (N'&SAVE EQ 1).PE
         AIF   ('&BASES(&K)' NE '13').P7
         MNOTE 8,'*** REG 13 MAY NOT BE USED AS A BASE REGISTER FOR REEX
               NTRANT CODE.'
         AGO   .P7
.PE      AIF   ('&BASES(&K+1)' NE '13' OR '&SAVE' EQ '').P7
         MNOTE 8,'*** WHEN USING A SAVE AREA, REG 13 MAY NOT BE USED ASX
                A SECONDARY BASE REGISTER.'
.P7      AIF   ('&BASES(&K+1)' NE '').P6
         USING &S&B(1)&B(2)&B(3)&B(4)&B(5)&B(6)&B(7)&B(8)&B(9)&B(10)&B(X
               11)&B(12)&B(13)&B(14)&B(15)&B(16)
&K       SETA  1
         AIF   ('&BASES(1)' NE '13' OR '&SAVE' EQ '').P8
&AREA    DC    18F'0'
.P8      AIF   (&K GE &N).P10
         LA    &BASES(&K+1),X'FFF'(&BASES(&K))
         LA    &BASES(&K+1),1(&BASES(&K+1))
&K       SETA  &K+1
         AGO   .P8
.P9      USING &SUBNAME,15
.P10     AIF   (N'&SAVE GE 2).P13
         AIF   ('&SAVE' EQ '' OR '&BASES(1)' EQ '13').P12
         AIF   ('&SAVE(1,1)' GE '0').P16  NUMERIC MEANS A PASSED AREA
         ST    14,&AREA+4
         LA    14,&AREA
         ST    14,8(13)
         L     14,&AREA+4
         ST    13,&AREA+4
.P11     BAL   13,*+76       SKIP AROUND THE SAVEAREA
&AREA    DC    18F'0'
.P12     MEXIT
.P13     ANOP
&LV      SETC  '&SAVE(2)'
&SP      SETC  '0'
         AIF   ('&SAVE(1)' EQ '').P14
&SP      SETC  '&SAVE(1)'
.P14     CNOP  0,4          DO A GETMAIN FOR THE AREA
         BAL   1,*+8          POINT THE SP AND LV
ENT&SYSNDX DC  AL1(&SP)       SUBPOOL FOR THE GETMAIN
         DC    AL3(&LV)       LENGTH OF THE GETMAIN
         L     0,0(1)         GET THE DATA IN REG 1
         SVC   10             ISSUE THE GETMAIN
.*                            CHAIN THE SAVEAREAS
         ST    13,4(1)        PRIOR SAVEAREA ADDRESS TO MINE
         ST    1,8(13)        MY SAVEAREA ADDRESS TO HIS
         LR    2,13           KEEP THE SAVEAREA ADDRESS FOR REGS
         LR    13,1           THIS IS MY SAVEAREA
         LA    4,12(13)       YES, POINT PAST THE CHAIN
         L     5,ENT&SYSNDX   GET THE SIZE
         LA    6,12           MINUS THE CHAIN AREA (12 BYTES )
         SR    5,6            GIVES THE AMOUNT TO CLEAR
         SR    7,7            CLEAR THE FROM COUNT AND CLEAR BYTE
         MVCL  4,6            WHEE, CLEAR IT OUT
         LM    0,7,20(2)      RESTORE THE ORIGINAL REGISTERS
         MEXIT
.P16     L     1,&AREA+0(1)   NUMERIC &SAVE IMPLIES A PASSED SAVEAREA
         ST    13,4(1)        PRIOR SAVEAREA ADDRESS TO MINE
         ST    1,8(13)        MY SAVEAREA ADDRESS TO HIS
         LR    2,13           KEEP THE SAVEAREA ADDRESS FOR REGS
         LR    13,1           THIS IS MY SAVEAREA
         LM    0,2,20(2)      RESTORE ORIGINAL REGS
         MEND
