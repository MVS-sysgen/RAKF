//RAKFTST  JOB (TSO),'TEST ADDUSER',
//             CLASS=A,
//             MSGCLASS=A,
//             MSGLEVEL=(1,1),USER=IBMUSER,PASSWORD=SYS1
//* Which of libc370's three startup opens is failing?
//*
//* @@start.c does this before main() ever runs:
//*     stdout = fopen("*SYSPRINT","w");  if (!stdout) __exita(FAILURE);
//*     stderr = fopen("*SYSTERM","w");   if (!stderr) __exita(FAILURE);
//*     stdin  = fopen("dd:SYSIN","r");
//*     if (!stdin) stdin = fopen("'NULLFILE'","r");
//*     if (!stdin) __exita(FAILURE);
//*
//* The "*name" form opens a DD of that name when one exists, and only
//* falls back to allocating a SYSOUT dataset (SVC 99) when it does
//* not. Supplying the DDs therefore keeps startup away from SVC 99.
//*
//* IBMUSER already exists, so ADDUSER reads and then stops with
//* "already defined" RC=8 -- it never writes anything.
//*
//* --- 1. DDs supplied: startup never reaches SVC 99 ----------------
//WITHDD  EXEC PGM=IKJEFT01,REGION=4096K
//SYSPRINT DD SYSOUT=*
//SYSTERM  DD SYSOUT=*
//SYSIN    DD DUMMY
//SYSTSPRT DD SYSOUT=*
//SYSTSIN  DD *
  CALL 'SYS2.CMDLIB(ADDUSER)' +
'IBMUSER PASSWORD(TEST) DFLTGRP(ADMIN) -TRACE'
//* --- 2. no DDs: startup falls back to SVC 99 (the failing case) ---
//NODD    EXEC PGM=IKJEFT01,REGION=4096K
//SYSTSPRT DD SYSOUT=*
//SYSTSIN  DD *
  CALL 'SYS2.CMDLIB(ADDUSER)' +
'IBMUSER PASSWORD(TEST) DFLTGRP(ADMIN) -TRACE'
