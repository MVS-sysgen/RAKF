//RAKFAPLY JOB (RAKF),
//             'RAKF Installation',
//             CLASS=A,
//             MSGCLASS=A,
//             REGION=8192K,
//             MSGLEVEL=(1,1)
//* ------------------------------------------------------------------*
//* SMP apply of RAKF 1.2.0                                           *
//* Expected APPLY step return code: 04 or lower                      *
//*                                   |                               *
//*                                    --> resulting from RC=8 in SMP *
//*                                        generated LINKEDITs.       *
//*                                                                   *
//* After successful APPLY continue as outlined in member $$$$INST    *
//* of the installation JCL-Library, step 5 (Run Job D_ACCPT) to      *
//* SMP ACCEPT RAKF or step 6 (IPL CLPA) if you want to skip the      *
//* SMP ACCEPT for now.                                               *
//* ------------------------------------------------------------------*
//APPLY   EXEC SMPAPP
//SYSLIB   DD
//         DD
//         DD
//         DD
//         DD
//         DD
//         DD
//         DD  DISP=SHR,DSN=SYSGEN.RAKF.V1R2M0.MACLIB
//MACLIB   DD  DISP=SHR,DSN=SYSGEN.RAKF.V1R2M0.MACLIB
//SAMPLIB  DD  DISP=SHR,DSN=SYSGEN.RAKF.V1R2M0.SAMPLIB
//SRCLIB   DD  DISP=SHR,DSN=SYSGEN.RAKF.V1R2M0.SRCLIB
//SMPCNTL  DD  *
 APPLY S(TRKF120) DIS(WRITE) .
/*
//
