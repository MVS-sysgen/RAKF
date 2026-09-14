//TRKF200  JOB 1,'RAKF 2.0',MSGLEVEL=1,CLASS=A
//*
//* JCLIN for RAKF 2.0
//*
//ASMSEC   EXEC PGM=IFOX00,PARM=(NOOBJ,DECK)                                    
//SYSLIB   DD  DISP=SHR,DSN=SYS1.MACLIB                                         
//         DD  DISP=SHR,DSN=SYS1.AMODGEN                                        
//         DD  DISP=SHR,DSN=RAKF.MACLIB                                         
//SYSIN    DD  DISP=SHR,DSN=RAKF.SRCLIB(ICHSEC00)                               
//SYSPUNCH DD  DISP=(,PASS),DSN=&&OBJ(ICHSEC00)                                 
//ASMRCVT  EXEC PGM=IFOX00,PARM=(NOOBJ,DECK)                                    
//SYSLIB   DD  DISP=SHR,DSN=SYS1.MACLIB                                         
//         DD  DISP=SHR,DSN=SYS1.AMODGEN                                        
//         DD  DISP=SHR,DSN=RAKF.MACLIB                                         
//SYSIN    DD  DISP=SHR,DSN=RAKF.SRCLIB(CJYRCVT)                                
//SYSPUNCH DD  DISP=(OLD,PASS),DSN=&&OBJ(CJYRCVT)                               
//ICHSEC00 EXEC  PGM=IEWL,PARM='MAP,LIST,LET,NCAL,AC=1'                         
//SYSLMOD  DD  DISP=SHR,DSN=SYS1.LINKLIB                                        
//SYSPUNCH DD  DISP=(OLD,PASS),DSN=&&OBJ                                        
//SYSLIN   DD  *                                                                
 INCLUDE SYSPUNCH(ICHSEC00)                                                     
 INCLUDE SYSPUNCH(CJYRCVT)                                                      
 ENTRY   ICHSEC00                                                               
 NAME    ICHSEC00(R)                                                            
/*                                                                              
//*                                                                             
//* JCLIN for RAKF 2.0 PTF RRKF002                                              
//*                                                                             
//ASMUSER  EXEC PGM=IFOX00,PARM=(NOOBJ,DECK)                                    
//SYSLIB   DD  DISP=SHR,DSN=SYS1.MACLIB                                         
//         DD  DISP=SHR,DSN=SYS1.AMODGEN                                        
//         DD  DISP=SHR,DSN=RAKF.MACLIB                                         
//SYSIN    DD  DISP=SHR,DSN=RAKF.SRCLIB(RAKFUSER)                               
//SYSPUNCH DD  DISP=(OLD,PASS),DSN=&&OBJ(RAKFUSER)                              
//ASMPSAV  EXEC PGM=IFOX00,PARM=(NOOBJ,DECK)                                    
//SYSLIB   DD  DISP=SHR,DSN=SYS1.MACLIB                                         
//         DD  DISP=SHR,DSN=SYS1.AMODGEN                                        
//         DD  DISP=SHR,DSN=RAKF.MACLIB                                         
//SYSIN    DD  DISP=SHR,DSN=RAKF.SRCLIB(RAKFPSAV)                               
//SYSPUNCH DD  DISP=(OLD,PASS),DSN=&&OBJ(RAKFPSAV)                              
//* --- salted SHA-256 password hashing, called from ICHSFR00 -------           
//ASMHASH  EXEC PGM=IFOX00,PARM=(NOOBJ,DECK)                                    
//SYSLIB   DD  DISP=SHR,DSN=SYS1.MACLIB                                         
//         DD  DISP=SHR,DSN=SYS1.AMODGEN                                        
//         DD  DISP=SHR,DSN=RAKF.MACLIB                                         
//SYSIN    DD  DISP=SHR,DSN=RAKF.SRCLIB(RAKFHASH)                               
//SYSPUNCH DD  DISP=(OLD,PASS),DSN=&&OBJ(RAKFHASH)                              
//ASMPWH   EXEC PGM=IFOX00,PARM=(NOOBJ,DECK)                                    
//SYSLIB   DD  DISP=SHR,DSN=SYS1.MACLIB                                         
//         DD  DISP=SHR,DSN=SYS1.AMODGEN                                        
//         DD  DISP=SHR,DSN=RAKF.MACLIB                                         
//SYSIN    DD  DISP=SHR,DSN=RAKF.SRCLIB(RAKFPWH)                                
//SYSPUNCH DD  DISP=(OLD,PASS),DSN=&&OBJ(RAKFPWH)                               
//RAKFUSER EXEC  PGM=IEWL,PARM='MAP,LIST,LET,NCAL,AC=1'                         
//SYSLMOD  DD  DISP=SHR,DSN=SYS1.LINKLIB                                        
//SYSPUNCH DD  DISP=(OLD,PASS),DSN=&&OBJ                                        
//SYSLIN   DD  *                                                                
 INCLUDE SYSPUNCH(RAKFUSER)                                                     
 INCLUDE SYSPUNCH(RAKFPSAV)                                                     
 INCLUDE SYSPUNCH(RAKFHASH)                                                     
 INCLUDE SYSPUNCH(RAKFPWH)                                                      
 ENTRY   CJYRUIDS                                                               
 NAME    RAKFUSER(R)                                                            
/*                                                                              
//*                                                                             
//ASMPROF  EXEC PGM=IFOX00,PARM=(NOOBJ,DECK)                                    
//SYSLIB   DD  DISP=SHR,DSN=SYS1.MACLIB                                         
//         DD  DISP=SHR,DSN=SYS1.AMODGEN                                        
//         DD  DISP=SHR,DSN=RAKF.MACLIB                                         
//SYSIN    DD  DISP=SHR,DSN=RAKF.SRCLIB(RAKFPROF)                               
//SYSPUNCH DD  DISP=(OLD,PASS),DSN=&&OBJ(RAKFPROF)                              
//RAKFPROF EXEC  PGM=IEWL,PARM='MAP,LIST,LET,NCAL,AC=1'                         
//SYSLMOD  DD  DISP=SHR,DSN=SYS1.LINKLIB                                        
//SYSPUNCH DD  DISP=(OLD,PASS),DSN=&&OBJ                                        
//SYSLIN   DD  *                                                                
 INCLUDE SYSPUNCH(RAKFPROF)                                                     
 ENTRY   CJYRPROF                                                               
 NAME    RAKFPROF(R)                                                            
/*                                                                              
//*                                                                             
//ASMPWUP  EXEC PGM=IFOX00,PARM=(NOOBJ,DECK)                                    
//SYSLIB   DD  DISP=SHR,DSN=SYS1.MACLIB                                         
//         DD  DISP=SHR,DSN=SYS1.AMODGEN                                        
//         DD  DISP=SHR,DSN=RAKF.MACLIB                                         
//SYSIN    DD  DISP=SHR,DSN=RAKF.SRCLIB(RAKFPWUP)                               
//SYSPUNCH DD  DISP=(OLD,PASS),DSN=&&OBJ(RAKFPWUP)                              
//RAKFPWUP EXEC  PGM=IEWL,PARM='MAP,LIST,LET,NCAL,AC=1'                         
//SYSLMOD  DD  DISP=SHR,DSN=SYS1.LINKLIB                                        
//SYSPUNCH DD  DISP=(OLD,PASS),DSN=&&OBJ                                        
//SYSLIN   DD  *                                                                
 INCLUDE SYSPUNCH(RAKFPWUP)                                                     
 ENTRY   RAKFPWUP                                                               
 NAME    RAKFPWUP(R)                                                            
/*                                                                              
//*                                                                             
//ASMSFR   EXEC PGM=IFOX00,PARM=(NOOBJ,DECK)                                    
//SYSLIB   DD  DISP=SHR,DSN=SYS1.MACLIB                                         
//         DD  DISP=SHR,DSN=SYS1.AMODGEN                                        
//         DD  DISP=SHR,DSN=RAKF.MACLIB                                         
//SYSIN    DD  DISP=SHR,DSN=RAKF.SRCLIB(ICHSFR00)                               
//SYSPUNCH DD  DISP=(OLD,PASS),DSN=&&OBJ(ICHSFR00)                              
//ICHSFR00 EXEC  PGM=IEWL,PARM='MAP,LIST,NCAL,LET,RENT,REFR,REUS,AC=1'          
//SYSLMOD  DD  DISP=SHR,DSN=SYS1.LPALIB                                         
//SYSPUNCH DD  DISP=(OLD,PASS),DSN=&&OBJ                                        
//SYSLIN   DD  *                                                                
 INCLUDE SYSPUNCH(ICHSFR00)                                                     
 INCLUDE SYSPUNCH(RAKFHASH)                                                     
 INCLUDE SYSPUNCH(RAKFPWH)                                                      
 ENTRY   ICHSFR00                                                               
 NAME    ICHSFR00(R)                                                            
/*                                                                              
//*                                                                             
//ASMRIN   EXEC PGM=IFOX00,PARM=(NOOBJ,DECK)                                    
//SYSLIB   DD  DISP=SHR,DSN=SYS1.MACLIB                                         
//         DD  DISP=SHR,DSN=SYS1.AMODGEN                                        
//         DD  DISP=SHR,DSN=RAKF.MACLIB                                         
//SYSIN    DD  DISP=SHR,DSN=RAKF.SRCLIB(ICHRIN00)                               
//SYSPUNCH DD  DISP=(OLD,PASS),DSN=&&OBJ(ICHRIN00)                              
//ASM130   EXEC PGM=IFOX00,PARM=(NOOBJ,DECK)                                    
//SYSLIB   DD  DISP=SHR,DSN=SYS1.MACLIB                                         
//         DD  DISP=SHR,DSN=SYS1.AMODGEN                                        
//         DD  DISP=SHR,DSN=RAKF.MACLIB                                         
//SYSIN    DD  DISP=SHR,DSN=RAKF.SRCLIB(IGC00130)                               
//SYSPUNCH DD  DISP=(OLD,PASS),DSN=&&OBJ(IGC00130)                              
//ASM13A   EXEC PGM=IFOX00,PARM=(NOOBJ,DECK)                                    
//SYSLIB   DD  DISP=SHR,DSN=SYS1.MACLIB                                         
//         DD  DISP=SHR,DSN=SYS1.AMODGEN                                        
//         DD  DISP=SHR,DSN=RAKF.MACLIB                                         
//SYSIN    DD  DISP=SHR,DSN=RAKF.SRCLIB(IGC0013A)                               
//SYSPUNCH DD  DISP=(OLD,PASS),DSN=&&OBJ(IGC0013A)                              
//ASM13C   EXEC PGM=IFOX00,PARM=(NOOBJ,DECK)                                    
//SYSLIB   DD  DISP=SHR,DSN=SYS1.MACLIB                                         
//         DD  DISP=SHR,DSN=SYS1.AMODGEN                                        
//         DD  DISP=SHR,DSN=RAKF.MACLIB                                         
//SYSIN    DD  DISP=SHR,DSN=RAKF.SRCLIB(IGC0013C)                               
//SYSPUNCH DD  DISP=(OLD,PASS),DSN=&&OBJ(IGC0013C)                              
//ASMADD   EXEC PGM=IFOX00,PARM=(NOOBJ,DECK)                                    
//SYSLIB   DD  DISP=SHR,DSN=SYS1.MACLIB                                         
//         DD  DISP=SHR,DSN=SYS1.AMODGEN                                        
//         DD  DISP=SHR,DSN=RAKF.MACLIB                                         
//SYSIN    DD  DISP=SHR,DSN=RAKF.SRCLIB(ADDUSER)                                
//SYSPUNCH DD  DISP=(OLD,PASS),DSN=&&OBJ(ADDUSER)                               
//ASMALT   EXEC PGM=IFOX00,PARM=(NOOBJ,DECK)                                    
//SYSLIB   DD  DISP=SHR,DSN=SYS1.MACLIB                                         
//         DD  DISP=SHR,DSN=SYS1.AMODGEN                                        
//         DD  DISP=SHR,DSN=RAKF.MACLIB                                         
//SYSIN    DD  DISP=SHR,DSN=RAKF.SRCLIB(ALTUSER)                                
//ASMDSD   EXEC PGM=IFOX00,PARM=(NOOBJ,DECK)                                    
//SYSLIB   DD  DISP=SHR,DSN=SYS1.MACLIB                                         
//         DD  DISP=SHR,DSN=SYS1.AMODGEN                                        
//         DD  DISP=SHR,DSN=RAKF.MACLIB                                         
//SYSIN    DD  DISP=SHR,DSN=RAKF.SRCLIB(ADDSD)                                  
//SYSPUNCH DD  DISP=(OLD,PASS),DSN=&&OBJ(ADDSD)                                 
//ASMDEL   EXEC PGM=IFOX00,PARM=(NOOBJ,DECK)                                    
//SYSLIB   DD  DISP=SHR,DSN=SYS1.MACLIB                                         
//         DD  DISP=SHR,DSN=SYS1.AMODGEN                                        
//         DD  DISP=SHR,DSN=RAKF.MACLIB                                         
//SYSIN    DD  DISP=SHR,DSN=RAKF.SRCLIB(DELUSER)                                
//SYSPUNCH DD  DISP=(OLD,PASS),DSN=&&OBJ(DELUSER)                               
//ADDUSER  EXEC  PGM=IEWL,PARM='MAP,LIST,NCAL,LET,RENT,REUS'                    
//SYSLMOD  DD  DISP=SHR,DSN=SYS1.CMDLIB                                         
//SYSPUNCH DD  DISP=(OLD,PASS),DSN=&&OBJ                                        
//SYSLIN   DD  *                                                                
 INCLUDE SYSPUNCH(ADDUSER)                                                      
 INCLUDE SYSPUNCH(RAKFHASH)                                                     
 INCLUDE SYSPUNCH(RAKFPWH)                                                      
 ENTRY   ADDUSER                                                                
 NAME    ADDUSER(R)                                                             
 INCLUDE SYSPUNCH(ALTUSER)                                                      
 INCLUDE SYSPUNCH(RAKFHASH)                                                     
 INCLUDE SYSPUNCH(RAKFPWH)                                                      
 ENTRY   ALTUSER                                                                
 NAME    ALTUSER(R)                                                             
 INCLUDE SYSPUNCH(DELUSER)                                                      
 ENTRY   DELUSER                                                                
 NAME    DELUSER(R)                                                             
/*                                                                              
//ADDDSD   EXEC  PGM=IEWL,PARM='MAP,LIST,NCAL,LET,RENT,REUS'                    
//SYSLMOD  DD  DISP=SHR,DSN=SYS1.CMDLIB                                         
//SYSPUNCH DD  DISP=(OLD,PASS),DSN=&&OBJ                                        
//SYSLIN   DD  *                                                                
 INCLUDE SYSPUNCH(ADDSD)                                                        
 ALIAS AD                                                                       
 ALIAS RDEFINE                                                                  
 NAME ADDSD(R)                                                                  
/*                                                                              
//ICHRIN00 EXEC  PGM=IEWL,PARM='MAP,LIST,NCAL,LET,RENT,REFR,REUS,AC=1'          
//SYSLMOD  DD  DISP=SHR,DSN=SYS1.LPALIB                                         
//SYSPUNCH DD  DISP=(OLD,DELETE),DSN=&&OBJ                                      
//SYSLIN   DD  *                                                                
 INCLUDE SYSPUNCH(ICHRIN00)                                                     
 INCLUDE SYSPUNCH(IGC00130)                                                     
 INCLUDE SYSPUNCH(IGC0013A)                                                     
 INCLUDE SYSPUNCH(IGC0013C)                                                     
 ENTRY   ICHRIN00                                                               
 ALIAS   IGC0013{                                                               
 ALIAS   IGC0013A                                                               
 ALIAS   IGC0013B                                                               
 ALIAS   IGC0013C                                                               
 NAME    ICHRIN00(R)                                                            
/*                                                                              
//*                                                                             
//* JCLIN for RAKF 2.0 PTF RRKF005                                              
//*                                                                             
//ASMIND   EXEC PGM=IFOX00,PARM=(NOOBJ,DECK)                                    
//SYSLIB   DD  DISP=SHR,DSN=SYS1.MACLIB                                         
//         DD  DISP=SHR,DSN=SYS1.AMODGEN                                        
//         DD  DISP=SHR,DSN=RAKF.MACLIB                                         
//SYSIN    DD  DISP=SHR,DSN=RAKF.SRCLIB(RACIND)                                 
//SYSPUNCH DD  DISP=(OLD,PASS),DSN=&&OBJ(RACIND)                                
//RACIND   EXEC  PGM=IEWL,PARM='MAP,LIST,LET,NCAL,AC=1'                         
//SYSLMOD  DD  DISP=SHR,DSN=SYS1.LINKLIB                                        
//SYSPUNCH DD  DISP=(OLD,PASS),DSN=&&OBJ                                        
//SYSLIN   DD  *                                                                
 INCLUDE SYSPUNCH(RACIND)                                                       
 ENTRY   RACIND                                                                 
 NAME    RACIND(R)                                                              
/*                                                                              
