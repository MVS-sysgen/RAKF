         MACRO
         RCPDISP &DISP
         LCLA  &I
         LCLB  &B(4)
         AIF   ('&DISP(1)' EQ '').TD2
         SPACE
***********************************************************************
**     DATA SET INITIAL STATUS                                       **
***********************************************************************
&B(1)    SETB  ('&DISP(1)' EQ 'SHR')
&B(2)    SETB  ('&DISP(1)' EQ 'NEW')
&B(3)    SETB  ('&DISP(1)' EQ 'MOD')
&B(4)    SETB  ('&DISP(1)' EQ 'OLD')
         AIF   (&B(1) OR &B(2) OR &B(3) OR &B(4)).OK1
         MNOTE 8,'&DISP(1) IS INVALID, DISP=SHR USED'
&B(1)    SETB  1
.OK1     ANOP
&I       SETA  8*&B(1)+4*&B(2)+2*&B(3)+&B(4)
         MVC   S99TUKEY(8),=Y(DALSTATS,1,1,X'0&I.00')
         RCPDINC 8
.TD2     AIF   ('&DISP(2)' EQ '').TD3
         SPACE
***********************************************************************
**    DATA SET NORMAL DISPOSITION                                    **
***********************************************************************
&B(1)    SETB  ('&DISP(2)' EQ 'KEEP')
&B(2)    SETB  ('&DISP(2)' EQ 'DELETE')
&B(3)    SETB  ('&DISP(2)' EQ 'CATLG')
&B(4)    SETB  ('&DISP(2)' EQ 'UNCATLG')
         AIF   (&B(1) OR &B(2) OR &B(3) OR &B(4)).OK2
         MNOTE 8,'&DISP(2) IS INVALID, DISP=(,KEEP) USED'
&B(1)    SETB  1
.OK2     ANOP
&I       SETA  8*&B(1)+4*&B(2)+2*&B(3)+&B(4)
         MVC   S99TUKEY(8),=Y(DALNDISP,1,1,X'0&I.00')
         RCPDINC 8
.TD3     AIF   ('&DISP(3)' EQ '').EXIT
         SPACE
***********************************************************************
**   DATASET CONDITIONAL DISPOSITION                                 **
***********************************************************************
&B(1)    SETB  ('&DISP(3)' EQ 'KEEP')
&B(2)    SETB  ('&DISP(3)' EQ 'DELETE')
&B(3)    SETB  ('&DISP(3)' EQ 'CATLG')
&B(4)    SETB  ('&DISP(3)' EQ 'UNCATLG')
         AIF   (&B(1) OR &B(2) OR &B(3) OR &B(4)).OK3
         MNOTE 8,'&DISP(3) IS INVALID, DISP=(,,KEEP) USED'
&B(1)    SETB  1
.OK3     ANOP
&I       SETA  8*&B(1)+4*&B(2)+2*&B(3)+&B(4)
         MVI   S99TUKEY(8),=Y(DALCDISP,1,1,X'0&I.00')
         RCPDINC 8
.EXIT    MEND
