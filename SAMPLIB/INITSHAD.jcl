//SHADOW  JOB 01,SHADOW,CLASS=A,MSGCLASS=X,REGION=512K                          
//*******************************************************************           
//* Populate SYS1.SECURE.SHADOW with the salted SHA-256 password                
//* hashes (computed at release-generation time).  The 48-byte                  
//* records are shipped padded to 80-byte cards through the EBCDIC              
//* reader; IEBGENER trims each back to LRECL 48 on the way in.                 
//* This is not true, IEBGENER does not trim back, unless the                   
//* control statements are used.                                                
//*                                                                             
//* NOTE:                                                                       
//* Grant ALTER access on SYS1.SECURE.* or IPL the system with                  
//* OFF in SYS1.PARMLIB(RAKFINIT)                                               
//* Locate this statement in SYS1.SECURE.CNTL(PROFILES)                         
//* DATASET SYS1.SECURE.*                         RAKFADM UPDATE                
//* change this into:                                                           
//* DATASET SYS1.SECURE.*                         RAKFADM ALTER                 
//* start RAKFPROF to make the change in effect                                 
//*                                                                             
//* Submit this job with a UserId in GROUP RAKFADM. Default the                 
//* user HERC01 has this group.                                                 
//* After successful execution revert the change in                             
//* SYS1.SECURE.CNTL(PROFILES)                                                  
//*                                                                             
//*******************************************************************           
//ALLOC   EXEC PGM=IEFBR14                                                      
//SHADOW  DD DISP=(,CATLG),DSN=SYS1.SECURE.SHADOW,VOL=SER=TK5CAT,               
//           UNIT=3390,DCB=(RECFM=FB,LRECL=48,BLKSIZE=19008),                   
//           SPACE=(TRK,(5,1))                                                  
//*                                                                             
