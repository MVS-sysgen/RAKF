//RAKFPREP JOB (RAKF),
//             'RAKF Installation',
//             CLASS=A,
//             MSGCLASS=A,
//             REGION=8192K,
//             MSGLEVEL=(1,1)
//* ------------------------------------------------------------------*
//* Prepare system for RAKF 1.2.0 installation                        *
//*                                                                   *
//* Expected return codes: Step UCLIN:  00                            *
//*                        Step LIBS:   00                            *
//*                        Step DELETE: 08 or lower                   *
//* ------------------------------------------------------------------*
//*
//* ------------------------------------------------------------------*
//* Delete MVS stub modules from SMP                                  *
//* ------------------------------------------------------------------*
//UCLIN   EXEC SMPAPP
//SMPCNTL  DD  *
 UCLIN CDS .
  DEL SYSMOD(EBB1102) MOD(ICHRIN00) .
  DEL MOD(IEFBR14) LMOD(ICHSEC00) .
  DEL MOD(ICHRIN00) .
  DEL LMOD(ICHSEC00) .
  DEL LMOD(IGC0013{) .
 ENDUCL .
 UCLIN ACDS .
  DEL SYSMOD(EBB1102) MOD(ICHRIN00) .
  DEL MOD(ICHRIN00) .
 ENDUCL .
/*
//* ------------------------------------------------------------------*
//* Allocate target und and distribution libraries                    *
//* ------------------------------------------------------------------*
//LIBS    EXEC PGM=IEFBR14
//ASAMPLIB DD  DISP=(,CATLG),DSN=SYSGEN.RAKF.V1R2M0.ASAMPLIB,
//             VOL=SER=PUB001,
//             UNIT=SYSDA,DCB=(RECFM=FB,LRECL=80,BLKSIZE=19040),
//             SPACE=(TRK,(120,40,10))
//SAMPLIB  DD  DISP=(,CATLG),DSN=SYSGEN.RAKF.V1R2M0.SAMPLIB,
//             VOL=SER=PUB001,
//             UNIT=SYSDA,DCB=(RECFM=FB,LRECL=80,BLKSIZE=19040),
//             SPACE=(TRK,(120,40,10))
//AMACLIB  DD   DISP=(,CATLG),DSN=SYSGEN.RAKF.V1R2M0.AMACLIB,
//             VOL=SER=PUB001,
//             UNIT=SYSDA,DCB=(RECFM=FB,LRECL=80,BLKSIZE=5600),
//             SPACE=(TRK,(2,1,1))
//MACLIB   DD  DISP=(,CATLG),DSN=SYSGEN.RAKF.V1R2M0.MACLIB,
//             VOL=SER=PUB001,
//             UNIT=SYSDA,DCB=(RECFM=FB,LRECL=80,BLKSIZE=5600),
//             SPACE=(TRK,(2,1,1))
//ASRCLIB  DD  DISP=(,CATLG),DSN=SYSGEN.RAKF.V1R2M0.ASRCLIB,
//             VOL=SER=PUB001,
//             UNIT=SYSDA,DCB=(RECFM=FB,LRECL=80,BLKSIZE=5600),
//             SPACE=(TRK,(30,10,4))
//SRCLIB   DD  DISP=(,CATLG),DSN=SYSGEN.RAKF.V1R2M0.SRCLIB,
//             VOL=SER=PUB001,
//             UNIT=SYSDA,DCB=(RECFM=FB,LRECL=80,BLKSIZE=5600),
//             SPACE=(TRK,(30,10,4))
//APROCLIB DD  DISP=(,CATLG),DSN=SYSGEN.RAKF.V1R2M0.APROCLIB,
//             VOL=SER=PUB001,
//             UNIT=SYSDA,DCB=(RECFM=FB,LRECL=80,BLKSIZE=19040),
//             SPACE=(TRK,(2,1,1))
//APARMLIB DD  DISP=(,CATLG),DSN=SYSGEN.RAKF.V1R2M0.APARMLIB,
//             VOL=SER=PUB001,
//             UNIT=SYSDA,DCB=(RECFM=F,LRECL=80,BLKSIZE=80),
//             SPACE=(TRK,(1,1,1))
//* ------------------------------------------------------------------*
//* Delete MVS stub modules and/or pre-SMP RAKF modules               *
//* from LINKLIB and LPALIB                                           *
//* ------------------------------------------------------------------*
//DELETE  EXEC PGM=IEHPROGM
//SYSPRINT DD  SYSOUT=*
//DD1      DD  VOL=SER=MVSRES,DISP=OLD,UNIT=3350
//SYSIN    DD  *
   SCRATCH VOL=3350=MVSRES,DSNAME=SYS1.LPALIB,MEMBER=ICHSFR00
   SCRATCH VOL=3350=MVSRES,DSNAME=SYS1.LPALIB,MEMBER=IGC0013A
   SCRATCH VOL=3350=MVSRES,DSNAME=SYS1.LPALIB,MEMBER=IGC0013B
   SCRATCH VOL=3350=MVSRES,DSNAME=SYS1.LPALIB,MEMBER=IGC0013C
   SCRATCH VOL=3350=MVSRES,DSNAME=SYS1.LPALIB,MEMBER=IGC0013{
   SCRATCH VOL=3350=MVSRES,DSNAME=SYS1.LPALIB,MEMBER=ICHRIN00
   SCRATCH VOL=3350=MVSRES,DSNAME=SYS1.LINKLIB,MEMBER=ICHSEC00
   SCRATCH VOL=3350=MVSRES,DSNAME=SYS1.LINKLIB,MEMBER=RAKFPROF
   SCRATCH VOL=3350=MVSRES,DSNAME=SYS1.LINKLIB,MEMBER=RAKFUSER
   SCRATCH VOL=3350=MVSRES,DSNAME=SYS1.LINKLIB,MEMBER=RAKFPWUP
   SCRATCH VOL=3350=MVSRES,DSNAME=SYS1.LINKLIB,MEMBER=RAKFINIT
/*
//
