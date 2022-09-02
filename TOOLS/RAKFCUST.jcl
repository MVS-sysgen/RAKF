//RAKFCUST JOB (TSO),
//             'Customizations',
//             CLASS=S,
//             MSGCLASS=A,
//             REGION=8192K,
//             MSGLEVEL=(1,1)
//* ******************************************************************
//* If you are generating this file with generate_release.py
//* Edit the files users.txt and profiles.txt this file
//* gets replaced by that script with the contents of those
//* files
//* ******************************************************************
//USERSIEB EXEC PGM=IEBGENER
//SYSPRINT DD SYSOUT=*
//SYSIN DD DUMMY
//SYSUT2   DD DSN=&&USERS,DISP=(,PASS),UNIT=VIO,
//            SPACE=(TRK,(5,5))
//SYSUT1 DD *
HMVS01   ADMIN   *CUL8TR   Y
HMVS01   RAKFADM  CUL8TR   Y
HMVS02   USER     PASS4U   N
IBMUSER  ADMIN   *SYS1     Y
IBMUSER  RAKFADM *SYS1     Y
/*
//* ******************************************************************
//PROFSIEB EXEC PGM=IEBGENER
//SYSPRINT DD SYSOUT=*
//SYSIN DD DUMMY
//SYSUT2   DD DSN=&&PROF,DISP=(,PASS),UNIT=VIO,
//            SPACE=(TRK,(5,5))
//SYSUT1 DD *
DASDVOL *                                                   READ
DASDVOL *                                           ADMIN   ALTER
DASDVOL *                                           STCGROUPALTER
DATASET *                                                   READ
DATASET *                                           ADMIN   ALTER
DATASET *                                           STCGROUPALTER
DATASET RPF.V1R5M3.SRPFPROF                                 UPDATE
DATASET SYS1.BRODCAST                                       UPDATE
DATASET SYS1.DUPLEX                                         NONE
DATASET SYS1.PAGECSA                                        NONE
DATASET SYS1.PAGELPA                                        NONE
DATASET SYS1.PAGEL01                                        NONE
DATASET SYS1.PAGEL02                                        NONE
DATASET SYS1.PAGES01                                        NONE
DATASET SYS1.SECURE.*                                       NONE
DATASET SYS1.SECURE.*                               ADMIN   NONE
DATASET SYS1.SECURE.*                               RAKFADM UPDATE
DATASET SYS1.STGINDEX                                       NONE
DATASET SYS1.UCAT.TSO                                       UPDATE
FACILITYDIAG8                                               NONE
FACILITYDIAG8                                       ADMIN   READ
FACILITYDIAG8                                       STCGROUPREAD
FACILITYRAKFADM                                             NONE
FACILITYRAKFADM                                     ADMIN   NONE
FACILITYRAKFADM                                     RAKFADM READ
FACILITYRAKFADM                                     STCGROUPREAD
FACILITYSVC244                                              NONE
FACILITYSVC244                                      ADMIN   READ
FACILITYSVC244                                      STCGROUPREAD
TAPEVOL *                                                   READ
TAPEVOL *                                           ADMIN   ALTER
TAPEVOL *                                           STCGROUPALTER
TERMINAL*                                                   READ
/*
//* ******************************************************************
//ALLOC   EXEC PGM=IEFBR14
//PWUP     DD  DISP=(,CATLG),DSN=SYS1.SECURE.PWUP,VOL=SER=MVS000,
//             UNIT=SYSDA,DCB=(RECFM=F,LRECL=18,BLKSIZE=18),
//             SPACE=(TRK,(1,1))
//RAKF    DD DISP=(,CATLG),DSN=SYS1.SECURE.CNTL,VOL=SER=MVS000,
//           UNIT=SYSDA,DCB=(RECFM=FB,LRECL=80,BLKSIZE=19040),
//           SPACE=(TRK,(10,3,3))
//********************************************************************
//SORTREXX EXEC PGM=IEBGENER
//SYSPRINT DD SYSOUT=*
//SYSIN DD DUMMY
//SYSUT1    DD *
say ''
say '******************************************'
say '* REXX Sort USERS and PROFILES           *'
say '******************************************'
say ''
say '*** Processing LISTCAT UCAT Output'

"EXECIO * DISKR USERS (FINIS STEM sortin."
if rc > 0 then do
    say "(T_T) Error reading INDD:" rc
    exit 1
end
say '*** Number of user entries' sortin.0
say '*** Sorting'
call rxsort
say '*** done'

do i=1 to sortin.0
    say sortin.i
    users.i = sortin.i
end

users.0 = sortin.0

"EXECIO * DISKR PROFILES (FINIS STEM sortin."

say '*** Number of profile entries' sortin.0
say '*** Sorting'
call rxsort
say '*** done'


do i=1 to sortin.0
    say sortin.i
    profiles.i = sortin.i
end
profiles.0 = sortin.0

say "*** Generating PDSLOAD statements"

outdd.1 = './ ADD NAME=USERS'

do i=1 to users.0
    x = i + 1
    outdd.x = users.i
end
x = x + 1
outdd.x = "./ ADD NAME=PROFILES"
do i=1 to profiles.0
    x = i + 2 + users.0
    outdd.x = profiles.i
end
say users.0  profiles.0
outdd.0 = 2 + users.0 + profiles.0


"EXECIO * DISKW OUTDD (STEM outdd. FINIS"
if rc > 0 then do
    say "(T_T) Error reading OUTDD:" rc
    exit 1
end
say "*** Done"
say ''
/*
//SYSUT2   DD DSN=&&RXSORT,DISP=(,PASS),UNIT=VIO,
//            SPACE=(TRK,(5,5))
//* **********************************************************
//EXECSORT EXEC PGM=BREXX,PARM='RXRUN',REGION=8192K
//RXRUN    DD   DSN=&&RXSORT,DISP=SHR
//RXLIB    DD   DSN=BREXX.V2R5M0.RXLIB,DISP=SHR
//STDIN    DD   DUMMY
//USERS    DD   DSN=&&USERS,DISP=SHR
//PROFILES DD   DSN=&&PROF,DISP=SHR
//OUTDD    DD DSN=&&STAGIN,DISP=(,PASS),UNIT=VIO,SPACE=(TRK,(5,5)),
//         DCB=(LRECL=80,BLKSIZE=800,RECFM=FB)
//STDOUT   DD   SYSOUT=*,DCB=(RECFM=FB,LRECL=140,BLKSIZE=5600)
//STDERR   DD   SYSOUT=*,DCB=(RECFM=FB,LRECL=140,BLKSIZE=5600)
//* **********************************************************
//PRTSORT EXEC PGM=IEBGENER
//SYSPRINT DD SYSOUT=*
//SYSIN    DD DUMMY
//SYSUT1   DD DSN=&&STAGIN,DISP=SHR
//SYSUT2   DD SYSOUT=*
//* **********************************************************
//RAKFCNTL EXEC PGM=PDSLOAD
//STEPLIB  DD  DSN=SYSC.LINKLIB,DISP=SHR
//SYSPRINT DD  SYSOUT=*
//SYSUT2   DD  DISP=SHR,DSN=SYS1.SECURE.CNTL
//SYSUT1   DD  DSN=&&STAGIN,DISP=SHR








