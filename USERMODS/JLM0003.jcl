//JLM0003  JOB SYS,'JLM0003',CLASS=A,REGION=4096K,              
//             MSGLEVEL=(1,1),MSGCLASS=X                                        
//*                                                                                                                        
//* Last update: 2026/10/17 17:19                                               
//*                                                                             
//* Desc: install the TSO authorized command table for                          
//*       TSO command processors LISTUSER, LU and LISTP                         
//*       This job is based on a TK4 or TK5 system but                          
//*       can also be user for an RYO system.                                   
//*                                                                             
//* Note: Skip the RESTORE step if JLM0003 is not applied.                      
//*                                                                             
//*                                                                             
//RESTORE EXEC SMPACC                                                           
//SMPCNTL  DD  *                                                                
 RESTORE S(NJE0001,JLM0003) DIS(WRITE).
 RESETRC.
 RESTORE S(JLM0003) DIS(WRITE).
 RESETRC.
/*                                                                              
//*                                                                             
//ASM     EXEC PGM=IFOX00,PARM='OBJECT,NODECK,NOTERM,XREF(SHORT)'               
//SYSPRINT DD  SYSOUT=*                                                         
//SYSUT1   DD  UNIT=SYSDA,SPACE=(CYL,10)                                        
//SYSUT2   DD  UNIT=SYSDA,SPACE=(CYL,10)                                        
//SYSUT3   DD  UNIT=SYSDA,SPACE=(CYL,10)                                        
//SYSLIB   DD  DSN=SYS1.MACLIB,DISP=SHR                                         
//SYSGO    DD  DSN=&&OBJ,UNIT=SYSALLDA,SPACE=(TRK,(1,1)),                       
//             DISP=(,PASS),                                                    
//             DCB=(DSORG=PS,RECFM=FB,LRECL=80,BLKSIZE=3200)                    
//SYSIN    DD  *                                                                
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
*                                                                     *
* SOURCE -- MVS 3.8 OPTIONAL MATERIALS; SYM1-3                        *
*                                                                     *
* STATUS --                                                           *
*                                                                     *
*    CHANGE LEVEL  040  000                                           *
*                                                                     *
* FUNCTION --                                                         *
*                                                                     *
*    THIS MODULE COMPRISES THE CSECT FOR THE COMMAND NAMES WHICH ARE  *
*    TO BE ATTACHED BY THE TMP AS ELIGIBLE FOR AUTHORIZATION          *
*                                                                     *
* ENTRY POINTS --                                                     *
*                                                                     *
*    NONE                                                             *
*                                                                     *
* INPUT --                                                            *
*                                                                     *
*    NONE                                                             *
*                                                                     *
* OUTPUT --                                                           *
*                                                                     *
*    NONE                                                             *
*                                                                     *
* EXTERNAL REFERENCES --                                              *
*                                                                     *
*     NONE                                                            *
*                                                                     *
* EXITS, NORMAL --                                                    *
*                                                                     *
*    NONE                                                             *
*                                                                     *
* EXITS, ERROR --                                                     *
*                                                                     *
*    NONE                                                             *
*                                                                     *
* TABLES/WORK AREA --                                                 *
*                                                                     *
*    NONE                                                             *
*                                                                     *
* ATTRIBUTE --                                                        *
*                                                                     *
*    REFRESHABLE                                                      *
*                                                                     *
* NOTES --                                                            *
*                                                                     *
*    THIS MODULE IS CHARACTER CODE DEPENDENT UPON AN INTERNAL REPRE-  *
*    SENTATION OF THE EXTERNAL CHARACTER SET EQUIVALENT TO THE ONE IN *
*    USE AT ASSEMBLY TIME                                             *
*                                                                     *
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
         EJECT
* /* START OF SPECIFICATIONS ****
*
*1MODULE-NAME = IKJEFTE2
*
*1DESCRIPTIVE-NAME = APF-ELIGIBLE-COMMAND-NAME TABLE
*
*1DESCRIPTION = CONTAINS THE COMMAND-NAMES WHICH ARE TO BE ATTACHED
*           BY THE TMP AS ELIGIBLE FOR AUTHORIZATION
*
*1MODULE TYPE = TABLE
*  2FIELD = BLANKS
*    3TYPE = CHARACTER STRING
*  2FIELD = BLANKS
*    3TYPE = CHARACTER STRING
*  2FIELD = BLANKS
*    3TYPE = CHARACTER STRING
*  2FIELD = BLANKS
*    3TYPE = CHARACTER STRING
*  2FIELD = BLANKS
*    3TYPE = CHARACTER STRING
*  2FIELD = BLANKS
*    3TYPE = CHARACTER STRING
*  2FIELD = BLANKS
*    3TYPE = CHARACTER STRING
*  2FIELD = BLANKS
*    3TYPE = CHARACTER STRING
*  2FIELD = BLANKS
*    3TYPE = CHARACTER STRING
*  2FIELD = BLANKS
*    3TYPE = CHARACTER STRING
*
**** END OF SPECIFICATIONS ***/
         EJECT
         SPACE 3
         ENTRY APFCTABL
         SPACE 1
IKJEFTE2 CSECT
         DC    C'IKJEFTE2'             MODULE NAME
         DC    C'&SYSDATE'             RELEASE LEVEL
APFCTABL DS    0D                      ALIGNMENT
         SPACE 2
         DC    C'#       '             CMDSBSYS
         DC    C'CMDSBSYS'             CMDSBSYS
         DC    C'CDSCB   '
         DC    C'IM      '             IMON/370
         DC    C'LISTD   '             TSO LIST DATASET
         DC    C'LISTDS  '             TSO LIST DATASET
         DC    C'LISTP   '             TSO LIST RAKF PROFILE(S)
         DC    C'LISTUSER'             TSO LIST RAKF USER(S)
         DC    C'LU      '             SAME AS LISTUSER
         DC    C'IKJEHDS1'             TSO LIST DATASET
         DC    C'ISPF    '             ISPF
         DC    C'ISPFLINK'             ISPF
         DC    C'ISPFMAIN'             ISPF
         DC    C'PDS     '             PDS UTILITY
         DC    C'PDS86   '             PDS UTILITY
         DC    C'QUEUE   '             QUEUE
         DC    C'QUE     '             QUEUE
         DC    C'Q       '             QUEUE
         DC    C'RFE     '             REVIEW FRONT END
         DC    C'RPF     '             RPF
         DC    C'RPFMAIN '             RPF
         DC    C'SPY     '             SPY CONSOLE MONITOR
         DC    C'BREXX   '             BREXX/370
         DC    C'REXX    '             BREXX/370
         DC    C'RX      '             BREXX/370
         DC    C'NJE38   '             NJE38 Command
         DC    C'RECEIVE '             NJE38 RECEIVE
         DC    C'RECV    '             NJE38 RECEIVE Alias
         DC    C'TRANSMIT'             NJE38 TRANSMIT
         DC    C'XMIT    '             NJE38 TRANSMIT Alias
         DC    C'        '             TERMINATOR
         SPACE 2
               END
//GENER   EXEC PGM=IEBGENER                                                     
//SYSPRINT DD  DUMMY                                                            
//SYSIN    DD  DUMMY                                                            
/*                                                                              
//SYSUT1   DD  DSN=&&OBJ,DISP=(OLD,DELETE)                                      
//         DD  *                                                                
    IDENTIFY IKJEFTE2('JLM0003')                                                
/*                                                                              
//SYSUT2   DD  DSN=&&OBJ2(IKJEFTE2),UNIT=SYSALLDA,                              
//             DCB=(DSORG=PS,RECFM=FB,LRECL=80,BLKSIZE=3200),                   
//             SPACE=(TRK,(1,1,1)),DISP=(,PASS)                                 
//*                                                                             
//*        RECEIVE JLM0003                                                      
//*                                                                             
//RECEIVE EXEC SMPREC                                                           
//SMPPTFIN DD  *                                                                
++ USERMOD(JLM0003) REWORK(20261008)      .                                     
++ VER(Z038)                                                                    
   FMID(EBB1102)                                                                
   .                                                                            
++ MOD(IKJEFTE2)                                                                
   DISTLIB(AOST4)                                                               
   TXLIB(IKJEFTE2)                                                              
   .                                                                            
/*                                                                              
//IKJEFTE2 DD  DSN=&&OBJ2(IKJEFTE2),DISP=(OLD,PASS)                             
//SMPCNTL  DD  *                                                                
  REJECT SELECT(JLM0003).
  RESETRC.
  RECEIVE SELECT(JLM0003).                                                      
/*                                                                              
//*       APPLY JLM0003                                                         
//*                                                                             
//APPLY   EXEC SMPACC                                                           
//IKJEFTE2 DD  DSN=&&OBJ2(IKJEFTE2),DISP=(OLD,DELETE)                           
//SMPCNTL  DD  *                                                                
  APPLY SELECT(JLM0003) DIS(WRITE).                                             
/*                                                                              
//                                                                              
