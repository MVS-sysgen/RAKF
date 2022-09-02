VTOCMSGX TITLE 'VTOC COMMAND - ERROR MESSAGE ROUTINE'
*
*   VTOC ERROR MESSAGE ROUTINE, R1 POINTS TO VTOC COMMON AT ENTRY
*
VTOCMSG  ENTER 12,0           DO THE STANDARD HOUSEKEEPING
         LR    R11,R1         GET THE PARM REGISTER
         USING VTOCOM,R11     SET ADDRESSABILITY
         SPACE
         LM    R0,R1,MSGADDRS GET THE MESSAGE(S) TO SEND
         LTR   R0,R0          SECOND LEVEL MSG?
         BZ    ERRORM1        NO
         SPACE
         MVC   MSGTEXT1,0(R1) INSURE MSG IN WORK AREA
         LA    R1,MSGTEXT1
         SPACE
         LH    R14,0(R1)      LENGTH OF FIRST LEVEL MSG
         LA    R15,0(R14,R1)  ADDR OF END OF MSG
         LA    R14,1(R14)     JUMP MSG LENGTH
         STH   R14,0(R1)
         MVI   0(R15),C'+'    INDICATE SECOND LEVEL MSG EXISTS
         SPACE 2
         SR    R14,R14        CLEAR CHAIN FIELD
         LA    R15,1          ONE SEGMENT IN 2ND MSG
         STM   R14,R0,PUTOLD2 CREATE SECOND-LEVEL
*                             OUTPUT LINE DESCRIPTOR ('OLD')
         LA    R0,PUTOLD2
         SPACE 3
ERRORM1  LR    R14,R0         NEXT 'OLD' ADDR OR ZERO
         LA    R15,1          ONE SEGMENT
         LR    R0,R1          MSG ADDR
         STM   R14,R0,PUTOLD1 FIRST LEVEL 'OLD'
         SPACE
         LA    R1,PARMLIST
         USING IOPL,R1
         SPACE
         MVC   IOPLECT,ADDRECT
         MVC   IOPLUPT,ADDRUPT
         SPACE
         LA    R0,ATTNECB
         ST    R0,IOPLECB
         MVI   ATTNECB,0
         SPACE 3
         XC    PARMLIST+16(4),PARMLIST+16
         PUTLINE PARM=PARMLIST+16,MF=(E,(1)),                          X
               OUTPUT=(PUTOLD1,TERM,MULTLVL,INFOR)
         SPACE 3
         LEAVE EQ
         SPACE 3
         IKJIOPL
         SPACE 3
         VTOCOM
         END
