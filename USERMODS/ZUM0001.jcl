//ZUM0001  JOB SYS,'ZUM0001',CLASS=A,REGION=4096K,              
//             MSGLEVEL=(1,1),MSGCLASS=X                                        
//*                                                                             
//* Name: USERMOD.TRKF200(ZUM0001)                                              
//* Last update: 2026/10/17 17:19                                               
//*                                                                             
//* Desc: install the TSO authorized command table for                          
//*       TSO command processors LISTUSER, LU and LISTP                         
//*       This job is based on a TK4 or TK5 system but                          
//*       can also be user for an RYO system.                                   
//*                                                                             
//* Note: Skip the RESTORE step if ZUM0001 is not applied.                      
//*                                                                             
//*                                                                             
//RESTORE EXEC SMPACC                                                           
//SMPCNTL  DD  *                                                                
 RESTORE S(ZUM0001) DIS(WRITE). 
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
         ENTRY APFCTABL                                                         
IKJEFTE2 CSECT                                                                  
         DC    CL8'IKJEFTE2'                                                    
         DC    CL8'&SYSDATE'                                                    
APFCTABL DS    0D                  alignment                                    
         DC    CL8'#       '       CMDSBSYS TSO interface                       
         DC    CL8'AUPGM   '       Run programs authorized                      
         DC    CL8'CMDSBTSO'       CMDSBSYS TSO interface                       
         DC    CL8'DDT     '       MVS dynamic debug tool                       
         DC    CL8'DT      '       Display TSO Users                            
         DC    CL8'ETPSTSO '       ETPS TSO frontend                            
         DC    CL8'IM      '       IMON/370                                     
         DC    CL8'LISTD   '       TSO List Dataset commands                    
         DC    CL8'LISTDS  '       ditto                                        
         DC    CL8'LISTP   '       List one or more RAKF profiles               
         DC    CL8'IKJEHDS1'       ditto                                        
         DC    CL8'ISPF    '       ISPF                                         
         DC    CL8'LISTUSER'       RAKF list UserId                             
         DC    CL8'LU      '       Alias of LISTUSER                            
         DC    CL8'NJE38   '       NJE38 command                                
         DC    CL8'PDS     '       PDS Utility                                  
         DC    CL8'PDS86   '       PDS Utility (Alias)                          
         DC    CL8'QUEUE   '       QUEUE COMMAND                                
         DC    CL8'Q       '       ALIAS                                        
         DC    CL8'QUE     '       ALIAS                                        
         DC    CL8'RECEIVE '       NJE38 RECEIVE command alias                  
         DC    CL8'RELOGON '       Re logon without password                    
         DC    CL8'RPF     '       RPF                                          
         DC    CL8'RPFMAIN '       RPF                                          
         DC    CL8'RPFV    '       RPF DSLIST command processor                 
         DC    CL8'SPFCOPY '       Copy under TSO                               
         DC    CL8'SPY     '       Console Monitor                              
         DC    CL8'RFE     '       Review Front End                             
         DC    CL8'SHOWSS  '       Display and manipulate subsystems            
         DC    CL8'STEPLIB '       Dynamic STEPLIB modification                 
         DC    CL8'TRANSMIT'       NJE38 TRANSMIT                               
         DC    CL8'TSOU    '       Alias of TSOUSER                             
         DC    CL8'TSOUSER '       Display TSO users                            
         DC    CL8'WHO     '       Alias of TSOUSER                             
         DC    CL8'XMIT    '       NJE38 XMIT command alias                     
         DC    CL8'        '       8 BLANKS patch area                          
         DC    CL8'        '       8 BLANKS patch area                          
         DC    CL8'        '       8 BLANKS patch area                          
         DC    CL8'        '       8 BLANKS patch area                          
         DC    CL8'        '       8 BLANKS patch area                          
         DC    CL8'        '       8 BLANKS patch area                          
         DC    CL8'        '       8 BLANKS patch area                          
         DC    CL8'        '       8 BLANKS patch area                          
         DC    CL8'        '       8 BLANKS patch area                          
         DC    CL8'        '       8 BLANKS patch area                          
         DC    CL8'        '       8 BLANKS patch area                          
         DC    CL8'        '       8 BLANKS patch area                          
         DC    CL8'        '       8 BLANKS patch area                          
         DC    CL8'        '       8 BLANKS patch area                          
         DC    CL8'        '       8 BLANKS patch area                          
         DC    CL8'        '       8 BLANKS patch area                          
         DC    CL8'        '       8 BLANKS patch area                          
         DC    CL8'        '       8 BLANKS patch area                          
         DC    CL8'        '       8 BLANKS patch area                          
         DC    CL8'        '       8 BLANKS patch area                          
         DC    CL8'        '       8 BLANKS patch area                          
         END                                                                    
//GENER   EXEC PGM=IEBGENER                                                     
//SYSPRINT DD  DUMMY                                                            
//SYSIN    DD  DUMMY                                                            
/*                                                                              
//SYSUT1   DD  DSN=&&OBJ,DISP=(OLD,DELETE)                                      
//         DD  *                                                                
    IDENTIFY IKJEFTE2('ZUM0001')                                                
/*                                                                              
//SYSUT2   DD  DSN=&&OBJ2(IKJEFTE2),UNIT=SYSALLDA,                              
//             DCB=(DSORG=PS,RECFM=FB,LRECL=80,BLKSIZE=3200),                   
//             SPACE=(TRK,(1,1,1)),DISP=(,PASS)                                 
//*                                                                             
//*        RECEIVE ZUM0001                                                      
//*                                                                             
//RECEIVE EXEC SMPREC                                                           
//SMPPTFIN DD  *                                                                
++ USERMOD(ZUM0001) REWORK(20261008)      .                                     
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
  RECEIVE SELECT(ZUM0001).                                                      
/*                                                                              
//*       APPLY ZUM0001                                                         
//*                                                                             
//APPLY   EXEC SMPACC                                                           
//IKJEFTE2 DD  DSN=&&OBJ2(IKJEFTE2),DISP=(OLD,DELETE)                           
//SMPCNTL  DD  *                                                                
  APPLY SELECT(ZUM0001) DIS(WRITE).                                             
/*                                                                              
//                                                                              
