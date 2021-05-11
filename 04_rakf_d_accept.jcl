//RAKFACPT JOB (RAKF),
//             'RAKF Installation',
//             CLASS=A,
//             MSGCLASS=A,
//             REGION=8192K,
//             MSGLEVEL=(1,1)
//* ------------------------------------------------------------------*
//* SMP accept of RAKF 1.2.0                                          *
//* Expected return code: 00                                          *
//* ------------------------------------------------------------------*
//ACCEPT  EXEC SMPAPP
//SYSLIB   DD
//         DD
//         DD
//         DD
//         DD
//         DD
//         DD
//         DD  DISP=SHR,DSN=SYSGEN.RAKF.V1R2M0.AMACLIB
//AMACLIB  DD  DISP=SHR,DSN=SYSGEN.RAKF.V1R2M0.AMACLIB
//APARMLIB DD  DISP=SHR,DSN=SYSGEN.RAKF.V1R2M0.APARMLIB
//APROCLIB DD  DISP=SHR,DSN=SYSGEN.RAKF.V1R2M0.APROCLIB
//ASAMPLIB DD  DISP=SHR,DSN=SYSGEN.RAKF.V1R2M0.ASAMPLIB
//MACLIB   DD  DISP=SHR,DSN=SYSGEN.RAKF.V1R2M0.MACLIB
//SAMPLIB  DD  DISP=SHR,DSN=SYSGEN.RAKF.V1R2M0.SAMPLIB
//ASRCLIB  DD  DISP=SHR,DSN=SYSGEN.RAKF.V1R2M0.ASRCLIB
//SRCLIB   DD  DISP=SHR,DSN=SYSGEN.RAKF.V1R2M0.SRCLIB
//SMPCNTL  DD  *
 ACCEPT S(TRKF120) DIS(WRITE) .
/*
//
