         MACRO
&NAME    LEAVE &EQ,&RC=
         GBLC  &LV,&SP
&NAME    LR    2,13
         L     13,4(13)
         AIF   ('&RC' EQ '').L0
         LA    15,&RC         LOAD THE RETURN CODE
.L0      STM   15,1,16(13)  STORE RETURN REGS
         AIF   ('&LV' EQ '').L1  ANYTHING TO FREE?
         FREEMAIN R,LV=&LV,SP=&SP,A=(2)  FREE THE AREA
.L1      RETURN (14,12),T     RETURN FROM WHENCE WE CAME
         AIF   ('&EQ' NE 'EQ').L4  REGISTERS TOO?
         COPY  REGS
.L4      MEND
