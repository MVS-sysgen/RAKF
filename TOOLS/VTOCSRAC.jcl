//VTOCSRAC JOB (RACIND),
//             'SET RACF INDICATOR',
//             CLASS=A,REGION=4M,
//             MSGCLASS=A,USER=IBMUSER,PASSWORD=SYS1,
//             MSGLEVEL=(0,0)
//********************************************************************
//*
//* NAME: VTOCSRAC
//*
//* DESC: SET RACF INDICATOR IN VTOC ON OR OFF FOR ALL DATASETS
//*       ON ALL ONLINE DASDS EXCEPT:
//*       - ALL VSAM DATASPACES
//*       - ALL TEMPORARY DATASETS SYSNNNNN.TNNNNNN.RANNN
//*       - THE PASSWORD DATASET
//*
//* NOTE: IF DASD VOLUMES ARE PRESENT IN YOUR SYSTEM THAT SHOULD NOT
//* ----- BE MODIFIED (I.E. IPL AND SPOOL VOLUMES FOR OTHER SYSTEMS
//*       LIKE START1 AND SPOOL0 IN TK3 SYSTEMS), THESE SHOULD BE
//*       VARIED OFFLINE BEFORE SUBMITTING THIS JOB.
//*
//* REQUIREMENTS: BREXX V2R5M2 OR GREATER MUST BE INSTALLED
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
PARSE ARG RACF .
SAY ''
SAY '******************************************'
SAY '* REXX SCRIPT TO GENERATE CDSCB COMMANDS *'
SAY '******************************************'
SAY ''
SAY '*** SETTING RACF INDICATOR TO' RACF
SAY '*** PROCESSING VTOC OUTPUT'

"EXECIO * DISKR INDD (FINIS STEM INDATA."
IF RC > 0 THEN DO
    SAY "(T_T) ERROR READING SYSUT1:" RC
    EXIT 1
END
SAY '*** NUMBER OF ENTRIES' INDATA.0 - 2
TOTAL = 1
DO I = 2 TO INDATA.0
    IF INDATA.I = 'END' THEN ITERATE

    IF SUBSTR(INDATA.I,3,6) = 'TOTALS' & INDEX(INDATA.I,'.') = 0 THEN
        ITERATE

    PARSE VAR INDATA.I DATASET VOLUME

    /* DO NOT RACF INDICATE TEMP DATASET */

    PARSE VAR DATASET FIRST '.' SECOND '.' THIRD '.' .

    SYS = DATATYPE(SUBSTR(FIRST,4),W)
    T = DATATYPE(SUBSTR(SECOND,2),W)
    RA = DATATYPE(SUBSTR(THIRD,3),W)

    IF SYS & T & RA THEN DO
        SAY '*** SKIPPING TEMP DATA SET' DATASET '('STRIP(VOLUME)')'
        ITERATE
    END
    IF DATASET = 'PASSWORD' THEN DO
        SAY '*** SKIPPING TEMP DATA SET' DATASET '('STRIP(VOLUME)')'
        ITERATE
    END

    IF SUBSTR(DATASET,1,1) = "1" THEN
        DATASET = SUBSTR(DATASET,2)

    VOL = STRIP(VOLUME)
    OUTCDSCB.TOTAL = "CDSCB '"DATASET"' VOL("VOL") UNIT(SYSALLDA) SHR" RACF

    DROP INDATA.I

    TOTAL = TOTAL + 1
END

DROP INDATA.0

SAY "***" TOTAL "AVAILABLE DATASETS"

OUTCDSCB.0 = TOTAL - 1

"EXECIO * DISKW OUTDD (STEM OUTCDSCB. FINIS"

SAY "*** DONE"
SAY ''
/*
//SYSUT2   DD DSN=&&RACIND,DISP=(,PASS),UNIT=VIO,
//            SPACE=(TRK,(5,5))
//* **********************************************************
//* CHANGE RACF BELOW TO NORACF TO REMOVE RACF INDICATOR
//EXEC     EXEC PGM=BREXX,PARM='RXRUN RACF',REGION=8192K
//RXRUN    DD   DSN=&&RACIND,DISP=SHR
//RXLIB    DD   DSN=BREXX.CURRENT.RXLIB,DISP=SHR
//STDIN    DD   DUMMY
//INDD     DD   DSN=&&LISTCC,DISP=SHR
//OUTDD    DD   DSN=&&CDRAW,DISP=(,PASS),UNIT=VIO,SPACE=(TRK,(5,5)),
//         DCB=(LRECL=128,BLKSIZE=1280,RECFM=FB)
//STDOUT   DD   SYSOUT=*,DCB=(RECFM=FB,LRECL=140,BLKSIZE=5600)
//STDERR   DD   SYSOUT=*,DCB=(RECFM=FB,LRECL=140,BLKSIZE=5600)
//* **********************************************************
//*******************************************************************
//* Filter and compact CDSCB commands before batch TSO executes them.
//*******************************************************************
//CDSCBF  EXEC PGM=BREXX,PARM='RXRUN',REGION=8192K
//RXRUN   DD *
/* Filter/compact VTOCSRAC CDSCB commands for batch TSO */
address mvs
"EXECIO * DISKR STATDD (STEM ST. FINIS"
"EXECIO * DISKR CMDIN (STEM CM. FINIS"
n=0
skip=0
bad=0
do i=1 to cm.0
  cmd=strip(cm.i)
  if left(cmd,6)<>'CDSCB' then iterate
  q1=pos("'",cmd)
  q2=pos("'",cmd,q1+1)
  vp=pos('VOL(',cmd)
  ve=pos(')',cmd,vp+4)
  if q1=0 | q2=0 | vp=0 | ve=0 then do
    say '*** BAD CDSCB COMMAND:' cmd
    bad=bad+1
    iterate
  end
  dsn=substr(cmd,q1+1,q2-q1-1)
  vol=substr(cmd,vp+4,ve-vp-4)
  action=translate(word(cmd,words(cmd)))
  cur=''
  do j=1 to st.0
    sdsn=strip(substr(st.j,1,44))
    svol=strip(substr(st.j,46,6))
    sind=strip(substr(st.j,55,1))
    if sdsn=dsn & svol=vol then do
      if sind='Y' | sind='N' then cur=sind
      leave
    end
  end
  if action='RACF' & cur='Y' then do
    skip=skip+1
    iterate
  end
  if action='NORACF' & cur='N' then do
    skip=skip+1
    iterate
  end
  if action<>'RACF' & action<>'NORACF' then do
    say '*** BAD CDSCB ACTION:' cmd
    bad=bad+1
    iterate
  end
  short="CDSCB '"||dsn||"' V("||vol||") SHR "||action
  if length(short)>72 then do
    say '*** CDSCB COMMAND STILL TOO LONG:' short
    bad=bad+1
    iterate
  end
  n=n+1
  out.n=short
end
out.0=n
"EXECIO * DISKW CMDOUT (STEM OUT. FINIS"
say '*** VTOCSRAC:' n 'COMMANDS,' skip 'ALREADY CORRECT'
if bad>0 then do
  say '*** VTOCSRAC FILTER ERRORS:' bad
  exit 8
end
exit 0
/*
//RXLIB   DD DSN=BREXX.CURRENT.RXLIB,DISP=SHR
//STATDD  DD DSN=&&LISTCC,DISP=SHR
//CMDIN   DD DSN=&&CDRAW,DISP=(OLD,DELETE)
//CMDOUT  DD DSN=&&CDSCB,DISP=(,PASS),UNIT=VIO,SPACE=(TRK,(5,5)),
//            DCB=(LRECL=80,BLKSIZE=800,RECFM=FB)
//STDIN   DD DUMMY
//STDOUT  DD SYSOUT=*,DCB=(RECFM=FB,LRECL=140,BLKSIZE=5600)
//STDERR  DD SYSOUT=*,DCB=(RECFM=FB,LRECL=140,BLKSIZE=5600)
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
