//RAKFXMI4 JOB (TSO),
//             'Recieve XMI',
//             CLASS=A,
//             MSGCLASS=A,
//             MSGLEVEL=(1,1)
//* RECV370 DDNAMEs:
//* ----------------
//*
//*     RECVLOG    RECV370 output messages (required)
//*
//*     RECVDBUG   Optional, specifies debugging options.
//*
//*     XMITIN     input XMIT file to be received (required)
//*
//*     SYSPRINT   IEBCOPY output messages (required for DSORG=PO
//*                input datasets on SYSUT1)
//*
//*     SYSUT1     Work dataset for IEBCOPY (not needed for sequential
//*                XMITs; required for partitioned XMITs)
//*
//*     SYSUT2     Output dataset - sequential or partitioned
//*
//*     SYSIN      IEBCOPY input dataset (required for DSORG=PO XMITs)
//*                A DUMMY dataset.
//*
//RECV370 EXEC PGM=RECV370
//STEPLIB  DD  DISP=SHR,DSN=SYSC.LINKLIB
//XMITIN   DD  UNIT=01C,DCB=(RECFM=FB,LRECL=80,BLKSIZE=80)
//RECVLOG  DD  SYSOUT=*
//SYSPRINT DD  SYSOUT=*
//SYSIN    DD  DUMMY
//* SYSUDUMP DD SYSOUT=*
//* Work temp dataset
//SYSUT1   DD  DSN=&&SYSUT1,
//             UNIT=VIO,
//             SPACE=(CYL,(10,5)),
//             DISP=(NEW,DELETE,DELETE)
//* Output dataset
//SYSUT2    DD DSN=SYSGEN.RAKF.RRKF006E,
//             DISP=(,CATLG),SPACE=(CYL,(5,3,10),RLSE),
//             DCB=(LRECL=80,BLKSIZE=5600,RECFM=FB),
//             UNIT=SYSDA