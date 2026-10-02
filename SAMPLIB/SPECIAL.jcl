//SPECIAL JOB 01,'SET SPECIAL',CLASS=A,MSGCLASS=X,NOTIFY=&SYSUID                
//*                                                                             
//* Name: SPECIAL                                                               
//* Last update:                                                                
//*                                                                             
//* Desc: set the SPECIAL authority of certain users.                           
//*       This is a one time job to migrate from                                
//*       RAKF V1 to RAKF V2.                                                   
//*       The SPECIAL authority is needed in RAKF V2.                           
//*       UPDATE authorization is needed on SYS1.SECURE.CNTL                    
//*       Mostly HERC01 or HMVS01 has this authorization.                       
//*                                                                             
//*                                                                             
//STEP01  EXEC ASMFCLG                                                          
//ASM.SYSIN DD *                                                                
SPECIAL  CSECT                                                                  
*---------------------------------------------------------------------*         
*        Set SPECIAL attribute of certain users                       *         
*---------------------------------------------------------------------*         
         SAVE  (14,12)                                                          
         LR    R12,R15                                                          
         USING SPECIAL,R12             Base register                            
         LR    R2,R1                   Save parm (CPPL)                         
         LA    R3,SAVEAREA                                                      
         ST    R3,8(,R13)              Forward pointer                          
         ST    R13,4(,R3)              Backward pointer                         
         LR    R13,R3                  This is our save area                    
*---------------------------------------------------------------------*         
*        Open SYS1.SECURE.CNTL(USERS) with DDNAME RAKUSER             *         
*---------------------------------------------------------------------*         
         OPEN  (RAKFUSER,(UPDAT))                                               
         XR    R5,R5                   Count updates                            
*---------------------------------------------------------------------*         
*        Read the USERS records and add special attribute of          *         
*        selected users.                                              *         
*---------------------------------------------------------------------*         
READUSR  DS    0H                                                               
         GET   RAKFUSER                Read a record                            
         USING USERREC,R1                                                       
         CLC   =C'HERC01 ',USERUID     Match found of UserID?                   
         BE    READUSR1                No: good                                 
         CLC   =C'HMVS01 ',USERUID     Match found of UserID?                   
         BE    READUSR1                No: good                                 
         CLC   =C'MVSCE1 ',USERUID     Match found of UserID?                   
         BNE   READUSR                 No: good                                 
READUSR1 DS    0H                                                               
         MVI   USERSPE,C'Y'            Set SPECIAL authority                    
         PUTX  RAKFUSER                Write record                             
         LA    R5,1(,R5)               Count this update                        
         B     READUSR                 Process them all                         
USEREOF  DS    0H                      EOF RACFUSER                             
         CLOSE RAKFUSER                Close the data set                       
         DROP  R1                                                               
*---------------------------------------------------------------------*         
*        Return to TSO TMP.                                           *         
*---------------------------------------------------------------------*         
RETURN   DS    0H                                                               
         CVD   R5,DOUBLE               Update counter                           
         UNPK  WTO+8(4),DOUBLE                                                  
         OI    WTO+11,X'F0'            Remove sign                              
WTO      WTO   'XXXX RECORDS UPDATED',ROUTCDE=(2,11)                            
         L     R13,4(,R13)             Load caller's save area                  
         RETURN (14,12),RC=0           Return                                   
*                                                                               
         TITLE 'CONSTANTS'                                                      
RAKFUSER DCB   DSORG=PS,LRECL=80,DDNAME=RAKFUSER,EODAD=USEREOF,        *        
               MACRF=(GL,PL)                                                    
*                                                                               
DOUBLE   DS    D                                                                
SAVEAREA DS    18F                                                              
         LTORG ,                                                                
         DROP                                                                   
*                                                                               
R0       EQU   0                                                                
R1       EQU   1                                                                
R2       EQU   2                                                                
R3       EQU   3                                                                
R4       EQU   4                                                                
R5       EQU   5                       Counter number of USER records           
R6       EQU   6                       Address of USER entry in table           
R7       EQU   7                                                                
R8       EQU   8                       Address of IKJPARS PDL                   
R9       EQU   9                                                                
R10      EQU   10                                                               
R11      EQU   11                                                               
R12      EQU   12                      Base register                            
R13      EQU   13                      Address of working storage               
R14      EQU   14                                                               
R15      EQU   15                                                               
*                                                                               
USERREC  DSECT                         User record                              
USERUID  DS    CL8                     Contains UserID                          
         DS    C                                                                
USERGRP  DS    CL8                     Group                                    
USERDFT  DS    C                       * for default group                      
USERPWD  DS    CL8                     Password is blanked out                  
         DS    C                                                                
USEROPR  DS    C                       Operations / Nooperations                
         DS    C                                                                
USERSPE  DS    C                       Special / Nospecial                      
         END                                                                    
/*                                                                              
//GO.RAKFUSER DD DSN=SYS1.SECURE.CNTL(USERS),DISP=SHR                           
