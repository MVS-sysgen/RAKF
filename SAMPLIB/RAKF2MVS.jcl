//RAKF2MVS JOB (RAKF),                                                 
//             'back to MVS Security',                                 
//             CLASS=A,                                                
//             MSGCLASS=X,                                             
//             REGION=8192K,                                           
//             MSGLEVEL=(1,1)                                          
//* ------------------------------------------------------------------*
//* Reinstate MVS security stub modules                               *
//*                                                                   *
//*   /\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\      *
//*   Danger!!! Danger!!! Danger!!! Danger!!! Danger!!! Danger!!!     *
//*   \/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/      *
//*                                                                   *
//*  Prior to running this job RAKF has to be removed completely from *
//*  SMP and system libraries PARMLIB, PROCLIB, LPALIB and LINKLIB.   *
//*  If RAKF is ACCEPTed use job RAFKRMV to achieve this, if RAKF is  *
//*  APPLIed but not ACCEPTed run SMP command "RESTORE S(TRKF120)" to *
//*  remove RAKF from the system.                                     *
//*                                                                   *
//*  After running RAKF2MVS RACF indicated files will no longer be    *
//*  accessible. This may lead to a not IPLable or not accessible     *
//*  system. Removing RAKF and reinstating native MVS security        *
//*  behavior is NOT RECOMMENDED unless in preparation the RACF       *
//*  indicator of all non VSAM datasets, VSAM catalogs and VSAM       *
//*  objects has been turned off.                                     *
//*                                                                   *
//*                                                                   *
//*   /\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\      *
//*   Danger!!! Danger!!! Danger!!! Danger!!! Danger!!! Danger!!!     *
//*   \/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/      *
//*                                                                   *
//*                                                                   *
//* Expected return codes: Step UCLIN:    00                          *
//*                        Step SCRATCH:  00                          *
//*                        Step ICHSEC00: 00                          *
//*                        Step ICHRIN00: 00                          *
//* ------------------------------------------------------------------*
//*                                                                    
//* ------------------------------------------------------------------*
//* Restore MVS stub modules to SMP                                   *
//* ------------------------------------------------------------------*
//UCLIN   EXEC SMPAPP                                                  
//SMPCNTL  DD  *                                                       
 UCLIN CDS .                                                           
  ADD LMOD(ICHSEC00) STD SYSLIB(LINKLIB)                               
                     LASTUPD(JCLIN) LASTUPDTYPE(ADD) .                 
  ADD LMOD(IGC0013{) RENT SYSLIB(LPALIB)                               
++LMODIN.                                                              
 ALIAS IGC0013A,IGC0013B,IGC0013C                                      
 ENTRY ICHRIN00                                                        
++ENDLMODIN.                                                           
  ADD  MOD(IEFBR14)  LMOD(ICHSEC00) .                                  
  ADD  MOD(ICHRIN00) LMOD(IGC0013{)                                    
                     DISTLIB(AOSBN) FMID(EBB1102) RMID(UZ90283)        
                     LASTUPD(JCLIN) LASTUPDTYPE(UPD) .                 
  ADD SYSMOD(EBB1102) MOD(ICHRIN00) .                                  
 ENDUCL .                                                              
 UCLIN ACDS .                                                          
  ADD  MOD(ICHRIN00) DISTLIB(AOSBN)   FMID(EBB1102) RMID(UZ90283)      
                     LASTUPD(EBB1102) LASTUPDTYPE(ADD) .               
  ADD SYSMOD(EBB1102) MOD(ICHRIN00) .                                  
 ENDUCL .                                                              
/*                                                                     
//* ------------------------------------------------------------------*
//* Delete target und and distribution libraries                      *
//* ------------------------------------------------------------------*
//SCRATCH EXEC PGM=IEFBR14                                             
//ASAMPLIB DD  DISP=(OLD,DELETE),DSN=HLQ.ASAMPLIB                      
//SAMPLIB  DD  DISP=(OLD,DELETE),DSN=HLQ.SAMPLIB                       
//AMACLIB  DD  DISP=(OLD,DELETE),DSN=HLQ.AMACLIB                       
//MACLIB   DD  DISP=(OLD,DELETE),DSN=HLQ.MACLIB                        
//ASRCLIB  DD  DISP=(OLD,DELETE),DSN=HLQ.ASRCLIB                       
//SRCLIB   DD  DISP=(OLD,DELETE),DSN=HLQ.SRCLIB                        
//APROCLIB DD  DISP=(OLD,DELETE),DSN=HLQ.APROCLIB                      
//APARMLIB DD  DISP=(OLD,DELETE),DSN=HLQ.APARMLIB                      
//* ------------------------------------------------------------------*
//* Reinstate MVS stub modules in LINKLIB and LPALIB                  *
//* ------------------------------------------------------------------*
//ICHSEC00 EXEC  PGM=IEWL                                              
//SYSUT1   DD  UNIT=SYSDA,SPACE=(2048,(200,20))                         
//SYSPRINT DD  SYSOUT=*                                                 
//SYSLMOD  DD  DISP=SHR,DSN=SYS1.LINKLIB                                
//AOSB3    DD  DISP=SHR,DSN=SYS1.AOSB3                                  
//SYSLIN   DD  *                                                        
 INCLUDE AOSB3(IEFBR14)                                                 
 ENTRY   IEFBR14                                                        
 NAME    ICHSEC00(R)                                                    
/*                                                                      
//ICHRIN00 EXEC  PGM=IEWL,PARM='RENT'                                   
//SYSUT1   DD  UNIT=SYSDA,SPACE=(2048,(200,20))                         
//SYSPRINT DD  SYSOUT=*                                                 
//SYSLMOD  DD  DISP=SHR,DSN=SYS1.LPALIB                                 
//AOSBN    DD  DISP=SHR,DSN=SYS1.AOSBN                                  
//SYSLIN   DD  *                                                        
 INCLUDE AOSBN(ICHRIN00)                                                
 ALIAS   IGC0013A,IGC0013B,IGC0013C                                     
 ENTRY   ICHRIN00                                                       
 NAME    IGC0013{(R)                                                    
/*                                                                      
//                                                                      
