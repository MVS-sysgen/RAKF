#!/bin/bash

# VTOC job stream generator using new VTOC from TK4- and
# Jay Moseley's job stream

# Script created by Phil Young aka Soldier of FORTRAN

echo "[+] Generating VTOC jobstream" >&2

cat << 'END'
//VTOC     JOB (SYS),'INSTALL VTOC',CLASS=A,MSGCLASS=A
//*
//* SOURCE: RAKF.DEVEL.VTOCPHIL.ZIP Juergen
//* TARGET: SYS2.CMDLIB   SYS2.HELP
//*
//*********************************************************************
//* This job installs the VTOC TSO modified by Phil Roberts to support
//* displaying the RACF indicator on datasets
//*********************************************************************
//*
//INSTALL PROC SOUT='*',               <=== SYSOUT CLASS
//             LIB='SYS2.CMDLIB',      <=== TARGET LOAD LIBRARY
//             HELP='SYS2.HELP',       <=== HELP LIBRARY
//             SYSTS=SYSDA,            <=== UNITNAME FOR WORK DATASETS
//             ASMBLR=IFOX00,          <=== NAME OF YOUR ASSEMBLER
//             ALIB='SYSC.LINKLIB',    <=== LOCATION OF YOUR ASSEMBLER
//             MACLIB='SYS1.MACLIB',   <=== MACLIB DATASET NAME
//             AMODGEN='SYS1.AMODGEN'  <=== AMODGEN DATASET NAME
//*
//LOADMACS EXEC PGM=IEBUPDTE,PARM=NEW
//SYSPRINT DD  SYSOUT=&SOUT
//SYSUT2   DD  DSN=&&LCLMAC,UNIT=&SYSTS,DISP=(,PASS),
//             SPACE=(TRK,(120,,5),RLSE),DCB=(SYS1.MACLIB)
//*
//IEBUPDTE EXEC PGM=IEBUPDTE,PARM=NEW
//SYSPRINT DD  SYSOUT=&SOUT
//SYSUT1   DD  DSN=&HELP,DISP=SHR
//SYSUT2   DD  DSN=&HELP,DISP=SHR
//*
//ASM1    EXEC PGM=&ASMBLR,REGION=2048K,PARM=(NOLOAD,DECK,'LINECNT=55')
//STEPLIB  DD  DSN=&ALIB,DISP=SHR
//SYSTERM  DD  SYSOUT=&SOUT
//SYSPRINT DD  SYSOUT=&SOUT
//SYSLIB   DD  DSN=&MACLIB,DISP=SHR
//         DD  DSN=&AMODGEN,DISP=SHR
//         DD  DSN=&&LCLMAC,UNIT=&SYSTS,DISP=(OLD,PASS)
//SYSUT1   DD  UNIT=&SYSTS,SPACE=(TRK,(30,15))
//SYSUT2   DD  UNIT=&SYSTS,SPACE=(TRK,(30,15))
//SYSUT3   DD  UNIT=&SYSTS,SPACE=(TRK,(30,15))
//SYSPUNCH DD  DSN=&&SYSLIN,UNIT=&SYSTS,DISP=(,PASS,DELETE),
//             SPACE=(TRK,(30,15))
//*
//ASM2    EXEC PGM=&ASMBLR,REGION=2048K,PARM=(NOLOAD,DECK,'LINECNT=55')
//STEPLIB  DD  DSN=&ALIB,DISP=SHR
//SYSTERM  DD  SYSOUT=&SOUT
//SYSPRINT DD  SYSOUT=&SOUT
//SYSLIB   DD  DSN=&MACLIB,DISP=SHR
//         DD  DSN=&AMODGEN,DISP=SHR
//         DD  DSN=&&LCLMAC,UNIT=&SYSTS,DISP=(OLD,PASS)
//SYSUT1   DD  UNIT=&SYSTS,SPACE=(TRK,(30,15))
//SYSUT2   DD  UNIT=&SYSTS,SPACE=(TRK,(30,15))
//SYSUT3   DD  UNIT=&SYSTS,SPACE=(TRK,(30,15))
//SYSPUNCH DD  DSN=&&SYSLIN,UNIT=&SYSTS,DISP=(MOD,PASS)
//*
//ASM3    EXEC PGM=&ASMBLR,REGION=2048K,PARM=(NOLOAD,DECK,'LINECNT=55')
//STEPLIB  DD  DSN=&ALIB,DISP=SHR
//SYSTERM  DD  SYSOUT=&SOUT
//SYSPRINT DD  SYSOUT=&SOUT
//SYSLIB   DD  DSN=&MACLIB,DISP=SHR
//         DD  DSN=&AMODGEN,DISP=SHR
//         DD  DSN=&&LCLMAC,UNIT=&SYSTS,DISP=(OLD,PASS)
//SYSUT1   DD  UNIT=&SYSTS,SPACE=(TRK,(30,15))
//SYSUT2   DD  UNIT=&SYSTS,SPACE=(TRK,(30,15))
//SYSUT3   DD  UNIT=&SYSTS,SPACE=(TRK,(30,15))
//SYSPUNCH DD  DSN=&&SYSLIN,UNIT=&SYSTS,DISP=(MOD,PASS)
//*
//ASM4    EXEC PGM=&ASMBLR,REGION=2048K,PARM=(NOLOAD,DECK,'LINECNT=55')
//STEPLIB  DD  DSN=&ALIB,DISP=SHR
//SYSTERM  DD  SYSOUT=&SOUT
//SYSPRINT DD  SYSOUT=&SOUT
//SYSLIB   DD  DSN=&MACLIB,DISP=SHR
//         DD  DSN=&AMODGEN,DISP=SHR
//         DD  DSN=&&LCLMAC,UNIT=&SYSTS,DISP=(OLD,PASS)
//SYSUT1   DD  UNIT=&SYSTS,SPACE=(TRK,(30,15))
//SYSUT2   DD  UNIT=&SYSTS,SPACE=(TRK,(30,15))
//SYSUT3   DD  UNIT=&SYSTS,SPACE=(TRK,(30,15))
//SYSPUNCH DD  DSN=&&SYSLIN,UNIT=&SYSTS,DISP=(MOD,PASS)
//*
//ASM5    EXEC PGM=&ASMBLR,REGION=2048K,PARM=(NOLOAD,DECK,'LINECNT=55')
//STEPLIB  DD  DSN=&ALIB,DISP=SHR
//SYSTERM  DD  SYSOUT=&SOUT
//SYSPRINT DD  SYSOUT=&SOUT
//SYSLIB   DD  DSN=&MACLIB,DISP=SHR
//         DD  DSN=&AMODGEN,DISP=SHR
//         DD  DSN=&&LCLMAC,UNIT=&SYSTS,DISP=(OLD,PASS)
//SYSUT1   DD  UNIT=&SYSTS,SPACE=(TRK,(30,15))
//SYSUT2   DD  UNIT=&SYSTS,SPACE=(TRK,(30,15))
//SYSUT3   DD  UNIT=&SYSTS,SPACE=(TRK,(30,15))
//SYSPUNCH DD  DSN=&&SYSLIN,UNIT=&SYSTS,DISP=(MOD,PASS)
//*
//ASM6    EXEC PGM=&ASMBLR,REGION=2048K,PARM=(NOLOAD,DECK,'LINECNT=55')
//STEPLIB  DD  DSN=&ALIB,DISP=SHR
//SYSTERM  DD  SYSOUT=&SOUT
//SYSPRINT DD  SYSOUT=&SOUT
//SYSLIB   DD  DSN=&MACLIB,DISP=SHR
//         DD  DSN=&AMODGEN,DISP=SHR
//         DD  DSN=&&LCLMAC,UNIT=&SYSTS,DISP=(OLD,PASS)
//SYSUT1   DD  UNIT=&SYSTS,SPACE=(TRK,(30,15))
//SYSUT2   DD  UNIT=&SYSTS,SPACE=(TRK,(30,15))
//SYSUT3   DD  UNIT=&SYSTS,SPACE=(TRK,(30,15))
//SYSPUNCH DD  DSN=&&SYSLIN,UNIT=&SYSTS,DISP=(MOD,PASS)
//*
//ASM7    EXEC PGM=&ASMBLR,REGION=2048K,PARM=(NOLOAD,DECK,'LINECNT=55')
//STEPLIB  DD  DSN=&ALIB,DISP=SHR
//SYSTERM  DD  SYSOUT=&SOUT
//SYSPRINT DD  SYSOUT=&SOUT
//SYSLIB   DD  DSN=&MACLIB,DISP=SHR
//         DD  DSN=&AMODGEN,DISP=SHR
//         DD  DSN=&&LCLMAC,UNIT=&SYSTS,DISP=(OLD,PASS)
//SYSUT1   DD  UNIT=&SYSTS,SPACE=(TRK,(30,15))
//SYSUT2   DD  UNIT=&SYSTS,SPACE=(TRK,(30,15))
//SYSUT3   DD  UNIT=&SYSTS,SPACE=(TRK,(30,15))
//SYSPUNCH DD  DSN=&&SYSLIN,UNIT=&SYSTS,DISP=(MOD,PASS)
//*
//LKED    EXEC PGM=IEWL,
//             PARM='XREF,LET,LIST,SIZE=(600K,64K)'
//SYSPRINT DD  SYSOUT=&SOUT
//SYSUT1   DD  UNIT=&SYSTS,SPACE=(TRK,10)
//SYSLMOD  DD  DSN=&LIB,DISP=SHR
//SYSLIN   DD  DSN=&&SYSLIN,DISP=(OLD,DELETE)
//         DD  DDNAME=SYSIN
//        PEND
//*
//        EXEC INSTALL
//*
//LOADMACS.SYSIN DD *
END

echo "[+] Adding Macros" >&2
for i in MACROS/*; do
    filename=$(basename -- "$i")
    filename="${filename%.*}"
    echo "./       ADD   NAME=$filename"
    cat $i
    echo "[+] Added $i" >&2
done

cat << END
/*
//*----------------------------------------------------------- LOADMACS
//*
//IEBUPDTE.SYSIN DD *
./       ADD   NAME=VTOC
END

cat DOCS/\$HELP.txt
echo "[+] Added DOCS/\$HELP.txt" >&2

cat << END
/*
//*----------------------------------------------------------- HELP
//*
//ASM1.SYSIN DD *
END

cat SRC/VTOC112.asm
echo "[+] Added SRC/VTOC112.asm" >&2

cat << END
/*
//*------------------------------------------------------ ASM: VTOC112
//*
//ASM2.SYSIN DD *
END

cat SRC/VTOCCHEK.asm

echo "[+] Added SRC/VTOCCHEK.asm" >&2
cat << END
/*
//*------------------------------------------------------ ASM: VTOCCHEK
//*
//ASM3.SYSIN DD *
END


cat SRC/VTOCEXCP.asm
echo "[+] Added SRC/VTOCEXCP.asm" >&2

cat << END
/*
//*------------------------------------------------------ ASM: VTOCCHEK
//*
//ASM4.SYSIN DD *
END


cat SRC/VTOCFORM.asm
echo "[+] Added SRC/VTOCFORM.asm" >&2

cat << END
/*
//*------------------------------------------------------ ASM: VTOCFORM
//*
//ASM5.SYSIN DD *
END


cat SRC/VTOCMSGX.asm
echo "[+] Added SRC/VTOCMSGX.asm" >&2

cat << END
/*
//*------------------------------------------------------ ASM: VTOCMSGX
//*
//ASM6.SYSIN DD *
END


cat SRC/VTOCPRNT.asm
echo "[+] Added SRC/VTOCPRNT.asm" >&2

cat << END
/*
//*------------------------------------------------------ ASM: VTOCPRNT
//*
//ASM7.SYSIN DD *
END

cat SRC/VTOCSORT.asm
echo "[+] Added SRC/VTOCSORT.asm" >&2

cat << END
/*
//*------------------------------------------------------ ASM: VTOCSORT
//*
//LKED.SYSIN DD *
  ENTRY VTOCCMD
  NAME VTOC(R)
/*
//*------------------------------------------------------ LKED
//
END

echo "[+] Done" >&2
