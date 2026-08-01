//RAKFTOOL JOB (SYSGEN),'DEPLOY RAKF TOOLS',
//             CLASS=A,
//             MSGCLASS=H,
//             MSGLEVEL=(1,1)
//* No USER=/PASSWORD= here: z/OSMF submits under the identity it
//* authenticated with, and a second one on the jobcard gets
//* IEF652I MUTUALLY EXCLUSIVE KEYWORDS - KEYWORD IN THE USER FIELD
//* Redeploy ADDUSER/ALTUSER from RAKF.TOOLS.XMIT (uploaded by zowe)
//* into SYS2.CMDLIB, without a full RAKF reinstall.
//DELOLD  EXEC PGM=IDCAMS
//SYSPRINT DD SYSOUT=*
//SYSIN    DD *
  DELETE RAKF.TOOLS.LINKLIB SCRATCH PURGE
  SET MAXCC=0
//* --- unXMIT into a transient load library ------------------------
//RECV    EXEC PGM=RECV370,REGION=4096K
//STEPLIB  DD DISP=SHR,DSN=SYSC.LINKLIB
//RECVLOG  DD SYSOUT=*
//XMITIN   DD DSN=RAKF.TOOLS.XMIT,DISP=SHR
//SYSPRINT DD SYSOUT=*
//SYSUT1   DD DSN=&&RECVWRK,UNIT=SYSDA,
//            SPACE=(CYL,(10,10)),DISP=(NEW,DELETE,DELETE)
//SYSUT2   DD DSN=RAKF.TOOLS.LINKLIB,DISP=(,CATLG,DELETE),
//            UNIT=SYSDA,SPACE=(CYL,(5,5,20),RLSE),
//            DCB=SYS2.CMDLIB
//SYSIN    DD DUMMY
//* --- replace the members in the command library ------------------
//* ((IN,R)) is REPLACE: ADDUSER/ALTUSER already exist there, and a
//* plain COPY would leave the old modules in place.
//INSTALL EXEC PGM=IEBCOPY
//SYSPRINT DD SYSOUT=*
//IN       DD DSN=RAKF.TOOLS.LINKLIB,DISP=SHR
//OUT      DD DSN=SYS2.CMDLIB,DISP=SHR
//SYSIN    DD *
  COPY OUTDD=OUT,INDD=((IN,R))
//* --- clean up ----------------------------------------------------
//CLEANUP EXEC PGM=IDCAMS
//SYSPRINT DD SYSOUT=*
//SYSIN    DD *
  DELETE RAKF.TOOLS.LINKLIB SCRATCH PURGE
  SET MAXCC=0
