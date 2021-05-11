//RAKFRECV JOB (RAKF),
//             'RAKF Installation',
//             CLASS=A,
//             MSGCLASS=A,
//             REGION=8192K,
//             MSGLEVEL=(1,1)
//* ------------------------------------------------------------------*
//* SMP receive of RAKF 1.2.0                                         *
//* Expected return code: 00                                          *
//* ------------------------------------------------------------------*
//RECEIVE EXEC SMPREC
//SMPPTFIN DD  DISP=(OLD,KEEP),DSN=TRKF120.F0,
//             UNIT=(TAPE,,DEFER),VOL=(,RETAIN,SER=RAKF12),
//             LABEL=(1,SL)
//SMPCNTL  DD  *
 RECEIVE S(TRKF120) .
/*
//
