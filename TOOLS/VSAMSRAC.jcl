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
//*
//********************************************************************
//LISTUCAT EXEC PGM=IDCAMS
//SYSPRINT DD DSN=&&UCAT,DISP=(,PASS),UNIT=VIO,SPACE=(TRK,(1,1))
//SYSIN    DD *
 LISTCAT UCAT
/*
//********************************************************************
//UCATREXX EXEC PGM=IEBGENER
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
//LISTREXX EXEC PGM=IEBGENER
//SYSPRINT DD SYSOUT=*
//SYSIN DD DUMMY
//SYSUT1    DD *
parse arg racf .
bad_data = "VSAM.CATALOG.BASE.DATA.RECORD"
bad_index = "VSAM.CATALOG.BASE.INDEX.RECORD"
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

e = 1

do i=1 to indata.0
    parse var indata.i . . entry1 entry2 . cat
    if index(indata.i, 'LISTING FROM CATALOG --') > 0 then do
        if cat = catalog then iterate
        say "CATALOG   " cat
        catalog = cat
        entries.e = "CATALOG   "||cat
        e = e + 1
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
        if index(indata.i, 'NO') > 0 then do
            if entry \= bad_data & entry \= bad_index THEN DO
                if racf = 'ON' then r = "RACON     "
                else r = "RACOFF    "
                say r entry
                entries.e = r||entry
                e = e + 1
            end
        end
    end
end

e = e - 1
entries.0 = e

"EXECIO * DISKW OUTDD (STEM entries. FINIS"

if rc > 0 then do
    say "(T_T) Error writting OUTDD:" rc
    exit 1
end

say "*** Done"
say ''
/*
//SYSUT2   DD DSN=&&RXPRSE,DISP=(,PASS),UNIT=VIO,
//            SPACE=(TRK,(5,5))
//* **********************************************************
//* CHANGE RACF BELOW TO NORACF TO REMOVE RACF INDICATOR
//EXECCAT  EXEC PGM=BREXX,PARM='RXRUN',REGION=8192K
//RXRUN    DD   DSN=&&RXCAT,DISP=SHR
//RXLIB    DD   DSN=BREXX.V2R5M2.RXLIB,DISP=SHR
//STDIN    DD   DUMMY
//INDD     DD   DSN=&&UCAT,DISP=SHR
//OUTDD    DD   DSN=&&CATS,DISP=(,PASS),UNIT=VIO,SPACE=(TRK,(5,5)),
//         DCB=(LRECL=80,BLKSIZE=800,RECFM=FB)
//STDOUT   DD   SYSOUT=*,DCB=(RECFM=FB,LRECL=140,BLKSIZE=5600)
//STDERR   DD   SYSOUT=*,DCB=(RECFM=FB,LRECL=140,BLKSIZE=5600)
//* **********************************************************
//LISTCAT  EXEC PGM=IDCAMS
//SYSIN    DD DSN=&&CATS,DISP=(OLD,DELETE)
//* SYSPRINT DD SYSOUT=*
//SYSPRINT DD DSN=&&LIST,DISP=(,PASS),UNIT=VIO,SPACE=(TRK,(5,5))
//* **********************************************************
//* CHANGE ON BELOW TO OFF TO REMOVE RACF INDICATOR
//EXECCAT2 EXEC PGM=BREXX,PARM='RXRUN ON',REGION=8192K
//RXRUN    DD   DSN=&&RXPRSE,DISP=SHR
//RXLIB    DD   DSN=BREXX.V2R5M2.RXLIB,DISP=SHR
//STDIN    DD   DUMMY
//INDD     DD   DSN=&&LIST,DISP=SHR
//OUTDD    DD   DSN=&&RACIND,DISP=(,PASS),UNIT=VIO,SPACE=(TRK,(5,5)),
//        DCB=(LRECL=80,BLKSIZE=800,RECFM=FB)
//STDOUT   DD   SYSOUT=*,DCB=(RECFM=FB,LRECL=140,BLKSIZE=5600)
//STDERR   DD   SYSOUT=*,DCB=(RECFM=FB,LRECL=140,BLKSIZE=5600)
//* **********************************************************
//LISTRACI EXEC PGM=IEBGENER
//SYSPRINT DD SYSOUT=*
//SYSIN    DD DUMMY
//SYSUT1   DD DSN=&&RACIND,DISP=SHR
//SYSUT2   DD SYSOUT=*
//* **********************************************************
//* execute RACIND utility to set or unset RACF indicators
//*
//RACIND  EXEC PGM=RACIND
//SYSPRINT DD  SYSOUT=*
//SYSIN    DD  DSN=&&RACIND,DISP=(OLD,DELETE)