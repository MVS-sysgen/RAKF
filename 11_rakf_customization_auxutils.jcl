//RAKFCUST JOB (TSO),
//             'Customizations',
//             CLASS=S,
//             MSGCLASS=A,
//             REGION=8192K,
//             MSGLEVEL=(1,1),
//             USER=IBMUSER,PASSWORD=SYS1
//*-------------------------------------------------------------------*
//*                                                                   *
//* Name: ZJW0003                                                     *
//*                                                                   *
//* DESC: Install USERMOD ZJW0003 to modify generation of MSTRJCL     *
//*       RAKF DD statements added for early initialization           *
//*                                                                   *
//*-------------------------------------------------------------------*
//RECEIVE EXEC SMPREC
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
 REJECT  SELECT(ZJW0003)
 .
 RESETRC
 .
 RECEIVE SELECT(ZJW0003)
 .
/*
//APPLY   EXEC SMPAPP
//AMODGEN  DD  DISP=SHR,DSN=SYS1.AMODGEN
//SMPCNTL  DD  *
 APPLY   SELECT(ZJW0003)
         DIS(WRITE)
 .
//* ------------------------------------------------------------------*
//* Allocate the RAKF password queue dataset SYS1.SECURE.PWUP         *
//*                                                                   *
//* Expected return codes: Step DELETE:  00                           *
//*                        Step SCRATCH: 08 or lower                  *
//*                        Step ALLOC:   00                           *
//* ------------------------------------------------------------------*
//*
//* ------------------------------------------------------------------*
//* Delete SYS1.SECURE.PWUP,SYS1.SECURE.CNTL                          *
//* ------------------------------------------------------------------*
//LISTCAT  EXEC PGM=IDCAMS
//SYSPRINT DD SYSOUT=*
//SYSIN    DD *
 DELETE SYS1.SECURE.PWUP
 DELETE SYS1.SECURE.CNTL
 SET MAXCC=0
/*
//* ------------------------------------------------------------------*
//* Scratch SYS1.SECURE.PWUP                                          *
//* ------------------------------------------------------------------*
//SCRATCH EXEC PGM=IEHPROGM
//SYSPRINT DD  SYSOUT=*
//DD1      DD  VOL=SER=MVS000,DISP=OLD,UNIT=3350
//SYSIN    DD  *
   SCRATCH VOL=3350=MVS000,DSNAME=SYS1.SECURE.PWUP
/*
//IBMUSER EXEC TSODUSER,ID=IBMUSER
//* ------------------------------------------------------------------*
//* Allocate SYS1.SECURE.PWUP                                         *
//* ------------------------------------------------------------------*
//ALLOC   EXEC PGM=IEFBR14
//PWUP     DD  DISP=(,CATLG),DSN=SYS1.SECURE.PWUP,VOL=SER=MVS000,
//             UNIT=3350,DCB=(RECFM=F,LRECL=18,BLKSIZE=18),
//             SPACE=(TRK,(1,1))
//* ------------------------------------------------------------------*
//* Install auxiliary utilities needed by sample RACF-indication jobs *
//*                                                                   *
//* Expected return codes: Step RECEIVE: 00                           *
//*                        Step INSTALL: 00                           *
//* ------------------------------------------------------------------*
//*
//* ------------------------------------------------------------------*
//* Receive distribution library                                      *
//* ------------------------------------------------------------------*
//*
//RECEIVE  EXEC PGM=RECV370
//STEPLIB  DD  DISP=SHR,DSN=SYSC.LINKLIB
//XMITIN    DD DSN=SYSGEN.RAKF.V1R2M0.SAMPLIB(AUXUTILS),DISP=SHR
//RECVLOG  DD  SYSOUT=*
//SYSPRINT DD  SYSOUT=*
//SYSIN    DD  DUMMY
//SYSUT1    DD DSN=&&SYSUT1,UNIT=SYSDA,SPACE=(CYL,(100,50)),
//             DISP=(,DELETE,DELETE)
//SYSUT2    DD DSN=&&AUX,DISP=(,PASS),SPACE=(TRK,(50,0,1),RLSE),
//             DCB=(LRECL=0,BLKSIZE=19069,RECFM=U),UNIT=SYSDA
//SYSIN     DD DUMMY
//*
//* ------------------------------------------------------------------*
//* Copy utilities to system libraries                                *
//* ------------------------------------------------------------------*
//*
//* Replace RAKFINIT
//*
//RKFINIT1 EXEC PGM=IEBGENER
//SYSIN    DD *
    GENERATE  MAXNAME=1,MAXGPS=1
    MEMBER  NAME=RAKFINIT
/*
//SYSPRINT DD SYSOUT=*
//SYSUT2   DD DSN=&&RAKFIN,
//             UNIT=SYSDA,
//             SPACE=(CYL,(1,1,1)),
//             DISP=(,PASS)
//SYSUT1   DD *
YES
/*
//INSTALL  EXEC PGM=IEBCOPY
//AUX      DD  DISP=(OLD,DELETE),DSN=&&AUX
//LINKLIB  DD  DISP=SHR,DSN=SYS2.LINKLIB
//CMDLIB   DD  DISP=SHR,DSN=SYS2.CMDLIB
//LPALIB   DD  DISP=SHR,DSN=SYS1.LPALIB
//PARMLIB  DD  DISP=SHR,DSN=SYS1.PARMLIB
//RAKFINIT DD  DISP=(OLD,PASS),DSN=&&RAKFIN
//SYSPRINT DD  SYSOUT=*
//SYSIN    DD  *
 COPY INDD=((AUX,R)),OUTDD=LINKLIB
 SELECT MEMBER=(MAWK)
 COPY INDD=((AUX,R)),OUTDD=CMDLIB
 SELECT MEMBER=(VTOC,CDSCB)
 COPY INDD=((RAKFINIT,R)),OUTDD=PARMLIB
 SELECT MEMBER=(RAKFINIT)
/*
//* ----------------------------------------------------------------- *
//* This step adds the IBMUSER TSO USER ID and allocates default      *
//* datasets for that user.                                           *
//* ----------------------------------------------------------------- *
//IBMUSER EXEC TSONUSER,ID=IBMUSER,   This will be the logon ID
//        PW='SYS1',
//        OP='OPER',             Allow operator authority
//        AC='ACCT'              Allow ACCOUNT TSO COMMAND
//*
//* Add RAKF User and Profiles
//* -----------------------------------------------------------------
//RAKFCNTL EXEC PGM=PDSLOAD
//STEPLIB  DD  DSN=SYSC.LINKLIB,DISP=SHR
//SYSPRINT DD  SYSOUT=*
//SYSUT2   DD  DISP=(,CATLG),DSN=SYS1.SECURE.CNTL,VOL=SER=MVS000,
//             UNIT=SYSDA,DCB=(RECFM=FB,LRECL=80,BLKSIZE=19040),
//             SPACE=(TRK,(10,3,3))
//SYSUT1   DD  DATA,DLM=@@
./ ADD NAME=$$README
RAKF USERS/PROFILES
-------------------

This PDS contains three members:

- $$README - This document
- USERS - User definitions
- PROFILES - Profiles

:warning: **The rules must be listed in alphabetical order when adding
removing users/rules. RFE command `sort` works just fine. **

USERS
-----

This controls user access. Each line is a user, group, password, and
operations:

| Column  | Description                                               |
|:-------:|:----------------------------------------------------------|
|  1 -  8 | USERID (TSO, CICS, or whatever application)               |
| 10 - 17 | User Group (Installation defined)                         |
| 18      | Asterisk '*' multiple user groups exist for this userid.  |
| 19 - 26 | Password                                                  |
| 28      | Operations Authority (Y or N). Always allow access(n1)    |
| 31 - 50 | Comment field (used by "IBM RACF").                       |

**n1** Unless explicitly denied access via a rule

```
UUUUUUUU GGGGGGGGSPPPPPPPP A  CCCCCCCCCCCCCCCCCCC
Username Group   *Password O  Comment
```

Userids in the users table that were set up with multiple group
entries will get the highest authority for all protected objects in
all the groups. As a practical example, multiple groups are used for
managers who oversee the work of several programming groups.  The
multiple group arrangement gives these managers access to everything
done by all the groups under them.

PROFILES
--------

This controls access to "classes".

| Column  | Description                                               |
|:-------:|:----------------------------------------------------------|
|  1 -  8 | Facility title: (DASDVOL, DATASET, FACILITY, etc(n2)      |
|  9 - 52 | Dataset Name, or Generic Name (using asterisk '*'),       |
| 53 - 60 | User Group Id (Installation defined)(n3).                 |
| 61 - 66 | Permission Level (NONE, READ, UPDATE, ALTER)              |
| 67 - 72 | Blank                                                     |

**n2** See the RACF Administrator's Guide. You need to know the
different facility types used by the operating system, CICS,
TP products, and vendor products.

**n3** Blanks in this field denote universal access rules for this
resource.

To protect products other than MVS 3.8j, they must have an interface
to the security system, typically through the use of specific profiles
in the FACILITY class.

```
FFFFFFFFDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDGGGGGGGGPPPPPP
Facility Dataset/Generic name                       Group   Perms
```

See RAKF documentation PDF for more information

@@
