//VSAMLRAC JOB (RACIND),
//             'Set RACF Indicator',
//             CLASS=A,REGION=4M,
//             MSGCLASS=A,
//             MSGLEVEL=(1,1)
//********************************************************************
//*
//* Name: VSAMLRAC
//*
//* Desc: List RACF Indicator Status of all VSAM Objects
//* Requires BREXX V2R5M2 or greater
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
say ''
say '******************************************'
say '* REXX Script to generate CDSCB commands *'
say '******************************************'
say ''
say '*** Processing LISTCAT UCAT Output'

"EXECIO * DISKR INDD (FINIS STEM indata."
if rc > 0 then do
    say "(T_T) Error reading SYSUT1:" rc
    exit 1
end
say '*** Number of entries' indata.0

outdd.1 = " LISTCAT ALL"

j = 2
do i = 1 to indata.0
    parse var indata.i . . cat .
    if index(indata.i,'0USERCATALOG') > 0 then do
        outdd.j = " LISTCAT ALL CAT("||cat||")"
        j = j + 1
    end
end
outdd.0 = j -1
say "*** Commands:"
do i=1 to outdd.0
    say outdd.i
end

"EXECIO * DISKW OUTDD (STEM outdd. FINIS"

say "*** Done"
say ''
/*
//SYSUT2   DD DSN=&&RXCAT,DISP=(,PASS),UNIT=VIO,
//            SPACE=(TRK,(5,5))
//********************************************************************
//LISTREXL EXEC PGM=IEBGENER
//SYSPRINT DD SYSOUT=*
//SYSIN DD DUMMY
//SYSUT1    DD *
say ''
say '******************************************'
say '* Printing Catalog and VSAM dataset RACF *'
say '******************************************'
say ''
say '*** Processing LISTCAT Output'

"EXECIO * DISKR INDD (FINIS STEM indata."
if rc > 0 then do
    say "(T_T) Error reading INDD:" rc
    exit 1
end
say '*** Number of lines' indata.0

do i=1 to indata.0
    parse var indata.i . . entry1 entry2 . cat
    if index(indata.i, 'LISTING FROM CATALOG --') > 0 then do
        if cat = catalog then iterate
        say ''
        say cat
        catalog = cat
    end
    if index(indata.i, 'CLUSTER ') > 0 then do
        type = "Cluster";   entry = entry1
    end
    if index(indata.i, '0   DATA ') > 0 then do
        type = "Data";   entry = entry2
    end
    if index(indata.i, '0   INDEX ') > 0 then do
        type = "Index";   entry = entry2
    end
    if index(indata.i, 'PAGESPACE ') > 0 then do
        type = "Pagespace";   entry = entry1
    end
    if index(indata.i, 'PATH ') > 0 then do
        type = "Path";   entry = entry1
    end
    if index(indata.i, 'RACF') > 0 then do
        if index(indata.i, 'YES') > 0 then
            racf = 'YES'
        else
            racf = 'NO'
        say left(type,9) "-" "RACF:" left(racf,3) left(entry, 44)
    end
end

 /* "EXECIO * DISKW OUTDD (STEM outdd. FINIS"*/

say "*** Done"
say ''
/*
//SYSUT2   DD DSN=&&RXPRSE,DISP=(,PASS),UNIT=VIO,
//            SPACE=(TRK,(5,5))
//* **********************************************************
//* CHANGE RACF BELOW TO NORACF TO REMOVE RACF INDICATOR
//EXECCTL  EXEC PGM=BREXX,PARM='RXRUN',REGION=8192K
//RXRUN    DD   DSN=&&RXCAT,DISP=SHR
//RXLIB    DD   DSN=BREXX.V2R5M2.RXLIB,DISP=SHR
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
//RXLIB    DD   DSN=BREXX.V2R5M2.RXLIB,DISP=SHR
//STDIN    DD   DUMMY
//INDD     DD   DSN=&&LIST,DISP=SHR
//* OUTDD    DD   DSN=&&CATS,DISP=(,PASS),UNIT=VIO,SPACE=(TRK,(5,5)),
//*         DCB=(LRECL=80,BLKSIZE=800,RECFM=FB)
//STDOUT   DD   SYSOUT=*,DCB=(RECFM=FB,LRECL=140,BLKSIZE=5600)
//STDERR   DD   SYSOUT=*,DCB=(RECFM=FB,LRECL=140,BLKSIZE=5600)
