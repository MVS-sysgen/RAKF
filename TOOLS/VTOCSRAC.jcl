//VTOCSRAC JOB (RACIND),
//             'Set RACF Indicator',
//             CLASS=A,REGION=4M,
//             MSGCLASS=A,
//             MSGLEVEL=(0,0)
//********************************************************************
//*
//* Name: VTOCSRAC
//*
//* Desc: Set RACF Indicator in VTOC ON or OFF for all datasets
//*       on all online DASDs except:
//*       - all VSAM dataspaces
//*       - all temporary datasets SYSnnnnn.Tnnnnnn.RAnnn
//*       - the PASSWORD dataset
//*
//* Note: If DASD volumes are present in your system that should not
//* ----- be modified (i.e. IPL and SPOOL volumes for other systems
//*       like START1 and SPOOL0 in TK3 systems), these should be
//*       varied offline before submitting this job.
//*
//* Requirements: BREXX V2R5M0 or greater must be installed
//*
//********************************************************************
//VTOCB4   EXEC PGM=IKJEFT01,DYNAMNBR=20
//VTOCOUT  DD SYSOUT=*
//SYSTSPRT DD DUMMY
//SYSTSIN  DD *
VTOC ALL LIM(DSO NE VS) P(NEW (DSN V RA)) S(RA,D,DSN,A) -
  LIN(66) H('1RACF STATUS BEFORE CHANGE')
/*
//* **********************************************************
//LSTVTOC EXEC PGM=IKJEFT01,DYNAMNBR=20
//SYSTSPRT DD DSN=&&LISTCC,DISP=(,PASS),UNIT=VIO,SPACE=(TRK,(5,5))
//SYSTSIN  DD *
VTOC ALL LIM(DSO NE VS) P(NEW (DSN V)) S(DSN A) NOH
/*
//* **********************************************************
//MAKEREXX EXEC PGM=IEBGENER
//SYSPRINT DD SYSOUT=*
//SYSIN DD DUMMY
//SYSUT1    DD *
parse arg racf .
say ''
say '******************************************'
say '* REXX Script to generate CDSCB commands *'
say '******************************************'
say ''
say '*** Setting RACF indicator to' racf
say '*** Processing VTOC Output'

"EXECIO * DISKR INDD (FINIS STEM indata."
if rc > 0 then do
    say "(T_T) Error reading SYSUT1:" rc
    exit 1
end
say '*** Number of entries' indata.0 - 2
total = 1
do i = 2 to indata.0
    if indata.i = 'END' then iterate

    if substr(indata.i,3,6) = 'TOTALS' & index(indata.i,'.') = 0 THEN
        iterate

    parse var indata.i dataset volume

    /* Do not racf indicate temp dataset */

    parse var dataset first '.' second '.' third '.' .

    sys = datatype(SUBSTR(first,4),W)
    t = datatype(SUBSTR(second,2),W)
    ra = datatype(SUBSTR(third,3),W)

    if (sys &  t & ra) | 'PASSWORD' = dataset THEN DO
        say '*** Skipping temp data set' dataset '('||strip(volume)||')'
        ITERATE
    end

    if substr(dataset,1,1) = "1" then
        dataset = substr(dataset,2)

    outcdscb.total = "CDSCB '"||dataset||"' VOL("||,
         strip(volume)        ||,
         ") UNIT(SYSALLDA) SHR" racf

    drop indata.i

    total = total + 1
end

drop indata.0

say "***" total "available datasets"

outcdscb.0 = total - 1

"EXECIO * DISKW OUTDD (STEM outcdscb. FINIS"

say "*** Done"
say ''
/*
//SYSUT2   DD DSN=&&RACIND,DISP=(,PASS),UNIT=VIO,
//            SPACE=(TRK,(5,5))
//* **********************************************************
//* CHANGE RACF BELOW TO NORACF TO REMOVE RACF INDICATOR
//EXEC     EXEC PGM=BREXX,PARM='RXRUN RACF',REGION=8192K
//RXRUN    DD   DSN=&&RACIND,DISP=SHR
//RXLIB    DD   DSN=BREXX.V2R5M0.RXLIB,DISP=SHR
//STDIN    DD   DUMMY
//INDD     DD   DSN=&&LISTCC,DISP=SHR
//OUTDD    DD   DSN=&&CDSCB,DISP=(,PASS),UNIT=VIO,SPACE=(TRK,(5,5)),
//         DCB=(LRECL=80,BLKSIZE=800,RECFM=FB)
//STDOUT   DD   SYSOUT=*,DCB=(RECFM=FB,LRECL=140,BLKSIZE=5600)
//STDERR   DD   SYSOUT=*,DCB=(RECFM=FB,LRECL=140,BLKSIZE=5600)
//* **********************************************************
//RACINDVT EXEC PGM=IKJEFT01,DYNAMNBR=20
//SYSTSPRT DD SYSOUT=*
//SYSTSIN  DD DSN=&&CDSCB,DISP=(OLD,DELETE)
//* **********************************************************
//VTOCAFTR EXEC PGM=IKJEFT01,DYNAMNBR=20
//VTOCOUT  DD SYSOUT=*
//SYSTSPRT DD DUMMY
//SYSTSIN  DD *
VTOC ALL LIM(DSO NE VS) P(NEW (DSN V RA)) S(RA,D,DSN,A) -
  LIN(66) H('1RACF STATUS AFTER CHANGE')
/*