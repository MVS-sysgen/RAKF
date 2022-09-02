//RAKUMOD JOB (SYSGEN),'ZJW0003',
//             CLASS=A,
//             MSGCLASS=A,
//             MSGLEVEL=(1,1),
//             REGION=4096K
/*JOBPARM LINES=100
//ZJW00031 EXEC SMPREC
//SMPPTFIN DD  *
++USERMOD (ZJW0003).
++VER (Z038) FMID(EBB1102).
++MACUPD(SGIEE0MS).
./ CHANGE NAME=SGIEE0MS
         DC    CL80'//RAKFPROF DD DSN=SYS1.SECURE.CNTL(PROFILES),'      04870010
         DC    CL80'//            DISP=SHR'                             04870011
         DC    CL80'//RAKFUSER DD DSN=SYS1.SECURE.CNTL(USERS),'         04870012
         DC    CL80'//            DISP=SHR'                             04870013
         DC    CL80'//RAKFPWUP DD DSN=SYS1.SECURE.PWUP,'                04870014
         DC    CL80'//            DISP=SHR'                             04870015
/*
//SMPCNTL  DD  *
 /* REJECT  SELECT(ZJW0003). */
 RESETRC
 .
 RECEIVE SELECT(ZJW0003)
 .
/*
//ZJW00032   EXEC SMPAPP
//AMODGEN  DD  DISP=SHR,DSN=SYS1.AMODGEN
//SMPCNTL  DD  *
 APPLY   SELECT(ZJW0003)
         DIS(WRITE)
 .
/*
