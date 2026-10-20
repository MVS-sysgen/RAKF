//INITTBLS JOB (RAKF),                                                          
//             'RAKF Customization',                                            
//             CLASS=A,                                                         
//             MSGCLASS=X,                                                      
//             MSGLEVEL=(1,1)                                                   
//* ------------------------------------------------------------------*         
//* Allocate PDS SYS1.SECURE.CNTL and populate it                     *         
//* with initial users and groups tables                              *         
//* Change 'TK5CAT' in your volume requested.                         *         
//*                                                                   *         
//* Expected return code:  Step TABLES: 00                            *         
//* ------------------------------------------------------------------*         
//*                                                                             
//TABLES  EXEC PGM=IEBUPDTE,PARM=NEW                                            
//SYSUT2  DD DISP=(,CATLG),DSN=SYS1.SECURE.CNTL,VOL=SER=TK5CAT,                 
//           UNIT=SYSDA,DCB=(RECFM=FB,LRECL=80,BLKSIZE=19040),                  
//           SPACE=(TRK,(10,3,3))                                               
//SYSPRINT DD SYSOUT=*                                                          
//SYSIN    DD *                                                                 
./ ADD NAME=USERS                                                               
BSPPILOT STARTED *         N N                                                  
BSPSETPF STARTED *         N N                                                  
FTPD     STARTED *         N N                                                  
HERC01   ADMIN   *         Y Y                                                  
HERC01   RAKFADM           Y Y                                                  
HERC02   ADMIN   *         N N                                                  
HERC03   USER    *         N N                                                  
HERC04   USER    *         N N                                                  
HTTPD    STARTED *         N N                                                  
IBMUSER  ADMIN   *         N N                                                  
UFSD     STARTED *         N N                                                  
./ ADD NAME=PROFILES                                                            
DASDVOL *                                                   READ                
DASDVOL *                                           ADMIN   ALTER               
DASDVOL *                                           STCGROUPALTER               
DATASET *                                                   READ                
DATASET *                                           ADMIN   ALTER               
DATASET *                                           STCGROUPALTER               
DATASET HTTPD.*                                             READ                
DATASET HTTPD.*                                     UFSD    UPDATE              
DATASET IPCS.DATA.SET.DIRECTRY                              UPDATE              
DATASET IPCS.PROBLEM.DIRECTRY                               UPDATE              
DATASET RAKF.*                                              NONE                
DATASET RAKF.*                                      ADMIN   ALTER               
DATASET SYS1.BRODCAST                                       UPDATE              
DATASET SYS1.MCAT.*                                         READ                
DATASET SYS1.MCAT.*                                 ADMIN   UPDATE              
DATASET SYS1.MCAT.*                                 RAKFADM UPDATE              
DATASET SYS1.PAGE.*                                         NONE                
DATASET SYS1.SECURE.*                                       NONE                
DATASET SYS1.SECURE.*                               RAKFADM UPDATE              
DATASET SYS1.STGINDEX                                       NONE                
DATASET SYS1.UCAT.TK5                                       UPDATE              
DATASET SYS1.UCAT.TSO                                       UPDATE              
DATASET TK5MIG.*                                            READ                
DATASET TK5MIG.*                                    ADMIN   UPDATE              
DATASET TK5MIG.*                                    RAKFADM UPDATE              
DATASET USERMOD.*                                           NONE                
DATASET USERMOD.*                                   ADMIN   ALTER               
FACILITY$STF.*                                              NONE                
FACILITY$STF.*                                      ADMIN   READ                
FACILITY$STF.*                                      STCGROUPREAD                
FACILITY$STF.STFCMD2                                        NONE                
FACILITY$STF.STFCMD2                                ADMIN   READ                
FACILITY$STF.STFCMD2                                RAKFADM READ                
FACILITY$STF.STFCMD2                                STCGROUPREAD                
FACILITY$STF.STFCMD3                                        NONE                
FACILITY$STF.STFCMD3                                ADMIN   READ                
FACILITY$STF.STFCMD3                                RAKFADM READ                
FACILITY$STF.STFCMD3                                STCGROUPREAD                
FACILITY$TSTVS                                              NONE                
FACILITY$TSTVS                                      ADMIN   READ                
FACILITY$TSTVS                                      STCGROUPREAD                
FACILITYDDTAPFAUTH                                          NONE                
FACILITYDDTAPFAUTH                                  ADMIN   READ                
FACILITYDDTAPFAUTH                                  STCGROUPREAD                
FACILITYDIAG8CMD                                            NONE                
FACILITYDIAG8CMD                                    ADMIN   READ                
FACILITYDIAG8CMD                                    STCGROUPREAD                
FACILITYDSSAUTH                                             NONE                
FACILITYDSSAUTH                                     ADMIN   READ                
FACILITYDSSAUTH                                     STCGROUPREAD                
FACILITYETPSAUTH                                            NONE                
FACILITYETPSAUTH                                    ADMIN   READ                
FACILITYETPSAUTH                                    STCGROUPREAD                
FACILITYFTPAUTH                                             NONE                
FACILITYFTPAUTH                                     ADMIN   READ                
FACILITYJRPAUTH                                             NONE                
FACILITYJRPAUTH                                     ADMIN   READ                
FACILITYJRPAUTH                                     STCGROUPREAD                
FACILITYNONQAUTH                                            NONE                
FACILITYNONQAUTH                                    ADMIN   READ                
FACILITYNONQAUTH                                    STCGROUPREAD                
FACILITYPGMAUTH                                             NONE                
FACILITYPGMAUTH                                     ADMIN   READ                
FACILITYPGMAUTH                                     STCGROUPREAD                
FACILITYRAKFADM                                             NONE                
FACILITYRAKFADM                                     ADMIN   NONE                
FACILITYRAKFADM                                     RAKFADM READ                
FACILITYRAKFADM                                     STCGROUPREAD                
FACILITYSHOWAUTH                                            NONE                
FACILITYSHOWAUTH                                    ADMIN   READ                
FACILITYSHOWAUTH                                    STCGROUPREAD                
FACILITYSTEPAUTH                                            NONE                
FACILITYSTEPAUTH                                    ADMIN   READ                
FACILITYSTEPAUTH                                    STCGROUPREAD                
FACILITYSVC244                                              NONE                
FACILITYSVC244                                      ADMIN   READ                
FACILITYSVC244                                      STARTED READ                
FACILITYZOSMF                                               READ                
TAPEVOL *                                                   READ                
TAPEVOL *                                           ADMIN   ALTER               
TAPEVOL *                                           STCGROUPALTER               
TERMINAL*                                                   READ                
./ ENDUP                                                                        
/*                                                                              
//                                                                              
