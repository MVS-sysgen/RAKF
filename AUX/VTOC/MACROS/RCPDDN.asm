         MACRO
         RCPDDN &DDN
         GBLC  &DYNP
         SPACE 1
***********************************************************************
**   BUILD THE DDNAME TEXT UNIT                                      **
***********************************************************************
         AIF   ('&DDN'(K'&DDN,1) EQ '/').BTU
         AIF   ('&DDN'(1,1) EQ '''').Q
         RCPSR2
         AIF   ('&DDN'(1,1) EQ '(').R
         L     R14,&DDN                LOAD ADDRESS OF DDNAME
         LH    R2,&DDN+4               LOAD LENGTH OF DDNAME
         AGO   .STH
.R       L     R14,0&DDN               LOAD ADDRESS OF DDNAME
         LH    R2,4&DDN                LOAD LENGTH OF DDNAME
.STH     STH   R2,S99TULNG             STORE DDNAME LENGTH
         BCTR  R2,0                    DECREMENT FOR EXECUTE
         EX    R2,&DYNP.MVC            MOVE DDNAME
         MVI   S99TUKEY+1,DALDDNAM     MOVE IN DDNAME KEY
         MVI   S99TUNUM+1,1            SET NUMBER FIELD
         RCPDINC 14
         MEXIT
.Q       RCPBTU DALDDNAM,1,&DDN
         MEXIT
.BTU     RCPTUBFR DALDDNAM,14,&DDN
         MEND
