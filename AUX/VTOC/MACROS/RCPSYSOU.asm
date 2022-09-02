         MACRO
         RCPSYSOU &CLASS,&COPIES=,&FREE=,&DEST=,&FORMS=
         GBLC  &DYNP
         LCLC  &C
         AIF   ('&CLASS(1)' EQ '').TPGN
&C       SETC  '&CLASS(1)'
         SPACE
***********************************************************************
**       SYSOUT CLASS TEXT UNIT                                      **
***********************************************************************
         AIF   ('&C'(1,1) EQ '''').Q
         AIF   ('&C'(K'&C,1) EQ '/').BS
         AIF   ('&C'(1,1) EQ '(').REG
         L     R14,&C                  LOAD ADDRESS OF SYSOUT CLASS
         MVC   S99TUPAR(1),0(R14)       AND MOVE IT TO TEXT UNIT
         AGO   .SKEY
.REG     MVC   S99TUPAR(1),0&C         MOVE SYSOUT CLASS TO TEXT UNIT
.SKEY    MVI   S99TUKEY+1,DALSYSOU     SET SYSOUT KEY
         MVI   S99TUNUM+1,1            SET NUMBER FIELD
         MVI   S99TULNG+1,1            SET LENGTH FIELD
         RCPDINC 8
         AGO   .TPGN
.BS      RCPTUBFR DALSYSOU,14,&C
         AGO   .TPGN
.Q       RCPBTU DALSYSOU,1,&C
.TPGN    AIF   ('&CLASS(2)' EQ '').TCOP
         SPACE
***********************************************************************
**   SYSOUT PROGRAM NAME TEXT UNIT                                   **
***********************************************************************
&C       SETC  '&CLASS(2)'
         RCPVCHAR DALSPGNM,14,&C
.TCOP    AIF   ('&COPIES' EQ '').TFREE
         SPACE
***********************************************************************
**    SYSOUT COPIES TEXT UNIT                                        **
***********************************************************************
         RCPNTU DALCOPYS,1,&COPIES
.TFREE   AIF   ('&FREE' EQ '').TDEST
         SPACE
***********************************************************************
**     FREE = CLOSE TEXT UNIT                                        **
***********************************************************************
         AIF   ('&FREE' EQ 'CLOSE').CLOSEOK
         MNOTE 4,' **** FREE=&FREE INVALID, FREE=CLOSE USED'
.CLOSEOK MVI   S99TUKEY+1,DALCLOSE     MOVE IN TEXT UNIT KEY
         RCPDINC 4
.TDEST   AIF   ('&DEST' EQ '').TFORMS
         SPACE
***********************************************************************
**       SYSOUT DESTINATION TEXT UNIT                                **
***********************************************************************
         RCPVCHAR DALSUSER,14,&DEST
.TFORMS  AIF   ('&FORMS' EQ '').EXIT
         SPACE
***********************************************************************
**     SYSOUT FORMS NUMBER TEXT UNIT                                 **
***********************************************************************
         RCPVCHAR DALSFMNO,14,&FORMS
.EXIT    MEND
