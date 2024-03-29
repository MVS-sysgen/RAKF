//VSAMLRAC JOB (RACIND),
//             'SET RACF INDICATOR',
//             CLASS=A,REGION=4M,
//             MSGCLASS=A,
//             MSGLEVEL=(1,1)
//********************************************************************
//*
//* NAME: VSAMLRAC
//*
//* DESC: LIST RACF INDICATOR STATUS OF ALL VSAM OBJECTS
//* REQUIRES BREXX V2R5M2 OR GREATER
//*
//********************************************************************
//LISTUCTL EXEC PGM=IDCAMS
//SYSPRINT DD DSN=&&UCAT,DISP=(,PASS),UNIT=VIO,SPACE=(TRK,(1,1))
//SYSIN    DD *
 LISTCAT UCAT
/*
//********************************************************************
//UCTREXXL EXEC PGM=IEBGENER
//SYSPRINT DD SYSOUT=*
//SYSIN DD DUMMY
//SYSUT1    DD *
SAY ''
SAY '******************************************'
SAY '* REXX SCRIPT TO GENERATE CDSCB COMMANDS *'
SAY '******************************************'
SAY ''
SAY '*** PROCESSING LISTCAT UCAT OUTPUT'

"EXECIO * DISKR INDD (FINIS STEM INDATA."
IF RC > 0 THEN DO
    SAY "(T_T) ERROR READING SYSUT1:" RC
    EXIT 1
END
SAY '*** NUMBER OF ENTRIES' INDATA.0

OUTDD.1 = " LISTCAT ALL"

J = 2
DO I = 1 TO INDATA.0
    PARSE VAR INDATA.I . . CAT .
    IF INDEX(INDATA.I,'0USERCATALOG') > 0 THEN DO
        OUTDD.J = " LISTCAT ALL CAT("||CAT||")"
        J = J + 1
    END
END
OUTDD.0 = J -1
SAY "*** COMMANDS:"
DO I=1 TO OUTDD.0
    SAY OUTDD.I
END

"EXECIO * DISKW OUTDD (STEM OUTDD. FINIS"

SAY "*** DONE"
SAY ''
/*
//SYSUT2   DD DSN=&&RXCAT,DISP=(,PASS),UNIT=VIO,
//            SPACE=(TRK,(5,5))
//********************************************************************
//LISTREXL EXEC PGM=IEBGENER
//SYSPRINT DD SYSOUT=*
//SYSIN DD DUMMY
//SYSUT1    DD *
SAY ''
SAY '******************************************'
SAY '* PRINTING CATALOG AND VSAM DATASET RACF *'
SAY '******************************************'
SAY ''
SAY '*** PROCESSING LISTCAT OUTPUT'

"EXECIO * DISKR INDD (FINIS STEM INDATA."
IF RC > 0 THEN DO
    SAY "(T_T) ERROR READING INDD:" RC
    EXIT 1
END
SAY '*** NUMBER OF LINES' INDATA.0

DO I=1 TO INDATA.0
    PARSE VAR INDATA.I . . ENTRY1 ENTRY2 . CAT
    IF INDEX(INDATA.I, 'LISTING FROM CATALOG --') > 0 THEN DO
        IF CAT = CATALOG THEN ITERATE
        SAY ''
        SAY CAT
        CATALOG = CAT
    END
    IF INDEX(INDATA.I, 'CLUSTER ') > 0 THEN DO
        TYPE = "CLUSTER";   ENTRY = ENTRY1
    END
    IF INDEX(INDATA.I, '0   DATA ') > 0 THEN DO
        TYPE = "DATA";   ENTRY = ENTRY2
    END
    IF INDEX(INDATA.I, '0   INDEX ') > 0 THEN DO
        TYPE = "INDEX";   ENTRY = ENTRY2
    END
    IF INDEX(INDATA.I, 'PAGESPACE ') > 0 THEN DO
        TYPE = "PAGESPACE";   ENTRY = ENTRY1
    END
    IF INDEX(INDATA.I, 'PATH ') > 0 THEN DO
        TYPE = "PATH";   ENTRY = ENTRY1
    END
    IF INDEX(INDATA.I, 'RACF') > 0 THEN DO
        IF INDEX(INDATA.I, 'YES') > 0 THEN
            RACF = 'YES'
        ELSE
            RACF = 'NO'
        SAY LEFT(TYPE,9) "-" "RACF:" LEFT(RACF,3) LEFT(ENTRY, 44)
    END
END

 /* "EXECIO * DISKW OUTDD (STEM OUTDD. FINIS"*/

SAY "*** DONE"
SAY ''
/*
//SYSUT2   DD DSN=&&RXPRSE,DISP=(,PASS),UNIT=VIO,
//            SPACE=(TRK,(5,5))
//* **********************************************************
//* CHANGE RACF BELOW TO NORACF TO REMOVE RACF INDICATOR
//EXECCTL  EXEC PGM=BREXX,PARM='RXRUN',REGION=8192K
//RXRUN    DD   DSN=&&RXCAT,DISP=SHR
//RXLIB    DD   DSN=BREXX.CURRENT.RXLIB,DISP=SHR
//STDIN    DD   DUMMY
//INDD     DD   DSN=&&UCAT,DISP=SHR
//OUTDD    DD   DSN=&&CATS,DISP=(,PASS),UNIT=VIO,SPACE=(TRK,(5,5)),
//         DCB=(LRECL=80,BLKSIZE=800,RECFM=FB)
//STDOUT   DD   SYSOUT=*,DCB=(RECFM=FB,LRECL=140,BLKSIZE=5600)
//STDERR   DD   SYSOUT=*,DCB=(RECFM=FB,LRECL=140,BLKSIZE=5600)
//* **********************************************************
//LISTCTL  EXEC PGM=IDCAMS
//SYSIN    DD DSN=&&CATS,DISP=(OLD,DELETE)
//* SYSPRINT DD SYSOUT=*
//SYSPRINT DD DSN=&&LIST,DISP=(,PASS),UNIT=VIO,SPACE=(TRK,(5,5))
//* **********************************************************
//* CHANGE RACF BELOW TO NORACF TO REMOVE RACF INDICATOR
//EXCCTL2  EXEC PGM=BREXX,PARM='RXRUN',REGION=8192K
//RXRUN    DD   DSN=&&RXPRSE,DISP=SHR
//RXLIB    DD   DSN=BREXX.CURRENT.RXLIB,DISP=SHR
//STDIN    DD   DUMMY
//INDD     DD   DSN=&&LIST,DISP=SHR
//* OUTDD    DD   DSN=&&CATS,DISP=(,PASS),UNIT=VIO,SPACE=(TRK,(5,5)),
//*         DCB=(LRECL=80,BLKSIZE=800,RECFM=FB)
//STDOUT   DD   SYSOUT=*,DCB=(RECFM=FB,LRECL=140,BLKSIZE=5600)
//STDERR   DD   SYSOUT=*,DCB=(RECFM=FB,LRECL=140,BLKSIZE=5600)
