//INITTBLS JOB (RAKF),                                                          
//             'RAKF Customization',                                            
//             CLASS=A,                                                         
//             MSGCLASS=X,                                                      
//             MSGLEVEL=(1,1)                                                   
//* ------------------------------------------------------------------*         
//* Allocate PDS SYS1.SECURE.CNTL and populate it                     *         
//* with initial users and groups tables                              *         
//* Change 'tttttt' in your volume requested.                         *         
//*                                                                   *         
//* Expected return code:  Step TABLES: 00                            *         
//* ------------------------------------------------------------------*         
//*                                                                             
//TABLES  EXEC PGM=IEBUPDTE,PARM=NEW                                            
//SYSUT2  DD DISP=(,CATLG),DSN=SYS1.SECURE.CNTL,VOL=SER=tttttt,                 
//           UNIT=SYSDA,DCB=(RECFM=FB,LRECL=80,BLKSIZE=19040),                  
//           SPACE=(TRK,(10,3,3))                                               
//SYSPRINT DD SYSOUT=*                                                          
//SYSIN    DD *                                                                 
./ ADD NAME=USERS                                                               
HERC01   RAKFADM *         Y Y                                          00005000
HERC01   ADMIN             Y Y                                          00010000
HERC02   ADMIN   *         N N                                          00020000
HERC03   USER    *         N N                                          00030000
HERC04   USER    *         N N                                          00040000
IBMUSER  ADMIN   *IBMPASS  Y Y                                          00050000
./ ADD NAME=PROFILES                                                            
DASDVOL *                                                   ALTER       00010000
DATASET *                                                   ALTER       00020000
FACILITY*                                                   ALTER       00030000
TAPEVOL *                                                   ALTER       00040000
TERMINAL*                                                   ALTER       00050000
./ ENDUP                                                                        
/*                                                                              
//                                                                              
