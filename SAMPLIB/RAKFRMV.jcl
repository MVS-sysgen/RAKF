//RAKFRMV  JOB (RAKF),                                                  00000100
//             'RAKF Removal',                                          00000200
//             CLASS=A,                                                 00000300
//             MSGCLASS=X,                                              00000400
//             REGION=8192K,                                            00000500
//             MSGLEVEL=(1,1)                                           00000600
//* ------------------------------------------------------------------* 00000700
//* Remove RAKF 2.0.0                                                 * 00000800
//*                                                                   * 00000900
//*   /\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/     * 00001000
//*   Danger!!! Danger!!! Danger!!! Danger!!! Danger!!! Danger!!!     * 00001100
//*   \/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\     * 00001200
//*                                                                   * 00001300
//*  This job is to be used for RAKF removal only if RAKF is in       * 00001400
//*  ACCEPTed state. If RAKF is APPLIed but not ACCEPTed use the      * 00001500
//*  the SMP command "RESTORE S(TRKF120)" instead of this job         * 00001600
//*  to remove it.                                                    * 00001700
//*                                                                   * 00001800
//*  After RAKF removal the system is NOT IPLable until the original  * 00001900
//*  MVS stub modules have been reinstated. Refer to job RAKF2MVS     * 00002000
//*  for reinstating these modules                                    * 00002100
//*                                                                   * 00002200
//*   /\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/     * 00002300
//*   Danger!!! Danger!!! Danger!!! Danger!!! Danger!!! Danger!!!     * 00002400
//*   \/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\     * 00002500
//*                                                                   * 00002600
//*                                                                   * 00002700
//* Expected return codes: Step UCLIN:    00                          * 00002800
//* Expected return codes: Step SCRATCH:  00                          * 00002900
//* ------------------------------------------------------------------* 00003000
//*                                                                     00003100
//* ------------------------------------------------------------------* 00003200
//* Remove RAKF elements from SMP                                     * 00003300
//* ------------------------------------------------------------------* 00003400
//UCLIN   EXEC SMPAPP                                                   00003500
//SMPCNTL  DD  *                                                        00003600
 UCLIN CDS .                                                            00003700
  DEL LMOD(ICHRIN00) .                                                  00003800
  DEL LMOD(ICHSEC00) .                                                  00003900
  DEL LMOD(ICHSFR00) .                                                  00004000
  DEL LMOD(RACIND)   .                                                  00004100
  DEL LMOD(CJYRPROF) .                                                  00004201
  DEL LMOD(CJYRPWUP) .                                                  00004301
  DEL LMOD(CJYRUIDS) .                                                  00004401
  DEL LMOD(ADDUSER)  .                                                  00004500
  DEL LMOD(ALTUSER)  .                                                  00004600
  DEL LMOD(DELUSER)  .                                                  00004701
  DEL LMOD(ADDSD)    .                                                  00004801
  DEL LMOD(PERMIT)   .                                                  00004903
  DEL LMOD(RDELETE)  .                                                  00005003
  DEL  MOD(CJYRCVT)  .                                                  00005100
  DEL  MOD(ICHRIN00) .                                                  00005200
  DEL  MOD(ICHSEC00) .                                                  00005300
  DEL  MOD(ICHSFR00) .                                                  00005400
  DEL  MOD(IGC0013A) .                                                  00005500
  DEL  MOD(IGC0013C) .                                                  00005600
  DEL  MOD(IGC00130) .                                                  00005700
  DEL  MOD(RAKFPSAV) .                                                  00005800
  DEL  MOD(RACIND)   .                                                  00005900
  DEL  MOD(CJYRPROF) .                                                  00006001
  DEL  MOD(CJYRPWUP) .                                                  00006101
  DEL  MOD(CJYFUSER) .                                                  00006201
  DEL  MOD(RAKFPWH)  .                                                  00006300
  DEL  MOD(RAKFHASH) .                                                  00006400
  DEL  MOD(ADDUSER)  .                                                  00006500
  DEL  MOD(ALTUSER)  .                                                  00006600
  DEL  MOD(DELUSER)  .                                                  00006701
  DEL  MOD(ADDSD)    .                                                  00006801
  DEL  MOD(PERMIT)   .                                                  00006903
  DEL  MOD(RDELETE)  .                                                  00007003
  DEL  SRC(ICHRIN00) .                                                  00007100
  DEL  SRC(ICHSEC00) .                                                  00007200
  DEL  SRC(ICHSFR00) .                                                  00007300
  DEL  SRC(IGC0013A) .                                                  00007400
  DEL  SRC(IGC0013C) .                                                  00007500
  DEL  SRC(IGC00130) .                                                  00007600
  DEL  SRC(CJYRCVT)  .                                                  00007700
  DEL  SRC(ADDUSER)  .                                                  00007800
  DEL  SRC(ALTUSER)  .                                                  00007900
  DEL  SRC(DELUSER)  .                                                  00008001
  DEL  SRC(ADDSD)    .                                                  00008101
  DEL  SRC(PERMIT)   .                                                  00008203
  DEL  SRC(RDELETE)  .                                                  00008303
  DEL  SRC(RACIND)   .                                                  00008400
  DEL  SRC(CJYRPROF) .                                                  00008501
  DEL  SRC(CJYRPWUP) .                                                  00008601
  DEL  SRC(CJYRUIDS) .                                                  00008701
  DEL  SRC(RAKFPSAV) .                                                  00008800
  DEL  SRC(RAKFPWH)  .                                                  00008900
  DEL  SRC(RAKFHASH) .                                                  00009000
  DEL  MAC($$$$$DOC) .                                                  00009100
  DEL  MAC($$$$INFO) .                                                  00009200
  DEL  MAC($$COPYRT) .                                                  00009300
  DEL  MAC($$NOTICE) .                                                  00009400
  DEL  MAC($DOC$ZIP) .                                                  00009500
  DEL  MAC(LPABACK)  .                                                  00009600
  DEL  MAC(LPAREST)  .                                                  00009700
  DEL  MAC(JRACIND)  .                                                  00009800
  DEL  MAC(RAKFRMV)  .                                                  00009900
  DEL  MAC(RAKF2MVS) .                                                  00010000
  DEL  MAC(CJYPCBLK) .                                                  00010100
  DEL  MAC(CJYRCVTD) .                                                  00010200
  DEL  MAC(CJYUCBLK) .                                                  00010300
  DEL  MAC(IEZCTGFL) .                                                  00010400
  DEL  MAC(INITPWUP) .                                                  00010500
  DEL  MAC(INITSHAD) .                                                  00010600
  DEL  MAC(INITTBLS) .                                                  00010700
  DEL  MAC(YREGS)    .                                                  00010800
  DEL  MAC(RAKF)     .                                                  00010900
  DEL  MAC(RAKFPROF) .                                                  00011000
  DEL  MAC(RAKFPWUP) .                                                  00011100
  DEL  MAC(RAKFUSER) .                                                  00011200
  DEL  MAC(RAKFINIT) .                                                  00011300
  DEL  MAC(VSAMLRAC) .                                                  00011400
  DEL  MAC(VSAMSRAC) .                                                  00011500
  DEL  MAC(VTOCLRAC) .                                                  00011600
  DEL  MAC(VTOCSRAC) .                                                  00011700
  DEL  MAC(ZAPMVS38) .                                                  00011800
  DEL  SYSMOD(RRKF006) .                                                00011900
  DEL  SYSMOD(RRKF007) .                                                00012000
  DEL  SYSMOD(RRKF008) .                                                00012100
  DEL  SYSMOD(RRKF009) .                                                00012200
  DEL  SYSMOD(TRKF200) .                                                00012300
 ENDUCL .                                                               00012400
 UCLIN ACDS .                                                           00012500
  DEL  SRC(CJYRCVT)  .                                                  00012600
  DEL  SRC(ICHRIN00) .                                                  00012700
  DEL  SRC(ICHSEC00) .                                                  00012800
  DEL  SRC(ICHSFR00) .                                                  00012900
  DEL  SRC(IGC0013A) .                                                  00013000
  DEL  SRC(IGC0013C) .                                                  00013100
  DEL  SRC(IGC00130) .                                                  00013200
  DEL  SRC(ADDUSER)  .                                                  00013301
  DEL  SRC(ALTUSER)  .                                                  00013401
  DEL  SRC(DELUSER)  .                                                  00013501
  DEL  SRC(ADDSD)    .                                                  00013601
  DEL  SRC(PERMIT)   .                                                  00013703
  DEL  SRC(RDELETE)  .                                                  00013803
  DEL  SRC(RACIND)   .                                                  00013900
  DEL  SRC(RAKFPSAV) .                                                  00014000
  DEL  SRC(CJYRPROF) .                                                  00014101
  DEL  SRC(CJYRPWUP) .                                                  00014201
  DEL  SRC(CJYRUIDS) .                                                  00014301
  DEL  SRC(RAKFPWH)  .                                                  00014400
  DEL  SRC(RAKFHASH) .                                                  00014500
  DEL  MAC($$$$$DOC) .                                                  00014600
  DEL  MAC($$$$INFO) .                                                  00014700
  DEL  MAC($$COPYRT) .                                                  00014800
  DEL  MAC($$NOTICE) .                                                  00014900
  DEL  MAC($DOC$ZIP) .                                                  00015000
  DEL  MAC(LPABACK)  .                                                  00015100
  DEL  MAC(LPAREST)  .                                                  00015200
  DEL  MAC(JRACIND)  .                                                  00015300
  DEL  MAC(RAKFRMV)  .                                                  00015400
  DEL  MAC(RAKF2MVS) .                                                  00015500
  DEL  MAC(CJYPCBLK) .                                                  00015600
  DEL  MAC(CJYRCVTD) .                                                  00015700
  DEL  MAC(CJYUCBLK) .                                                  00015800
  DEL  MAC(IEZCTGFL) .                                                  00015900
  DEL  MAC(INITPWUP) .                                                  00016000
  DEL  MAC(INITSHAD) .                                                  00016100
  DEL  MAC(INITTBLS) .                                                  00016200
  DEL  MAC(YREGS)    .                                                  00016300
  DEL  MAC(RAKF)     .                                                  00016400
  DEL  MAC(RAKFPROF) .                                                  00016500
  DEL  MAC(RAKFPWUP) .                                                  00016600
  DEL  MAC(RAKFUSER) .                                                  00016700
  DEL  MAC(RAKFINIT) .                                                  00016800
  DEL  MAC(VSAMLRAC) .                                                  00016900
  DEL  MAC(VSAMSRAC) .                                                  00017000
  DEL  MAC(VTOCLRAC) .                                                  00017100
  DEL  MAC(VTOCSRAC) .                                                  00017200
  DEL  MAC(ZAPMVS38) .                                                  00017300
  DEL  SYSMOD(RRKF006) .                                                00017400
  DEL  SYSMOD(RRKF007) .                                                00017500
  DEL  SYSMOD(RRKF008) .                                                00017600
  DEL  SYSMOD(RRKF009) .                                                00017700
  DEL  SYSMOD(TRKF200) .                                                00017800
 ENDUCL .                                                               00017900
/*                                                                      00018000
//* ------------------------------------------------------------------* 00018100
//* Remove RAKF elements from LINKLIB, LPALIB, PARMLIB and PROCLIB    * 00018200
//* ------------------------------------------------------------------* 00018300
//SCRATCH EXEC PGM=IEHPROGM                                             00018400
//SYSPRINT DD  SYSOUT=*                                                 00018500
//DD1      DD  VOL=SER=rrrrrr,DISP=OLD,UNIT=tttt                        00018600
//SYSIN    DD  *                                                        00018700
   SCRATCH VOL=tttt=rrrrrr,DSNAME=SYS1.LPALIB,MEMBER=ICHSFR00           00018800
   SCRATCH VOL=tttt=rrrrrr,DSNAME=SYS1.LPALIB,MEMBER=IGC0013A           00018900
   SCRATCH VOL=tttt=rrrrrr,DSNAME=SYS1.LPALIB,MEMBER=IGC0013B           00019000
   SCRATCH VOL=tttt=rrrrrr,DSNAME=SYS1.LPALIB,MEMBER=IGC0013C           00019100
   SCRATCH VOL=tttt=rrrrrr,DSNAME=SYS1.LPALIB,MEMBER=IGC0013{           00019200
   SCRATCH VOL=tttt=rrrrrr,DSNAME=SYS1.LPALIB,MEMBER=ICHRIN00           00019300
   SCRATCH VOL=tttt=rrrrrr,DSNAME=SYS1.LINKLIB,MEMBER=ICHSEC00          00019400
   SCRATCH VOL=tttt=rrrrrr,DSNAME=SYS1.LINKLIB,MEMBER=RACIND            00019500
   SCRATCH VOL=tttt=rrrrrr,DSNAME=SYS1.LINKLIB,MEMBER=CJYRPROF          00019601
   SCRATCH VOL=tttt=rrrrrr,DSNAME=SYS1.LINKLIB,MEMBER=RAKFPROF          00019701
   SCRATCH VOL=tttt=rrrrrr,DSNAME=SYS1.LINKLIB,MEMBER=CJYRUIDS          00019801
   SCRATCH VOL=tttt=rrrrrr,DSNAME=SYS1.LINKLIB,MEMBER=RAKFUSER          00019901
   SCRATCH VOL=tttt=rrrrrr,DSNAME=SYS1.LINKLIB,MEMBER=CJYRPWUP          00020001
   SCRATCH VOL=tttt=rrrrrr,DSNAME=SYS1.LINKLIB,MEMBER=RAKFPWUP          00020101
   SCRATCH VOL=tttt=rrrrrr,DSNAME=SYS1.CMDLIB,MEMBER=ADDUSER            00020201
   SCRATCH VOL=tttt=rrrrrr,DSNAME=SYS1.CMDLIB,MEMBER=AU                 00020301
   SCRATCH VOL=tttt=rrrrrr,DSNAME=SYS1.CMDLIB,MEMBER=ALTUSER            00020401
   SCRATCH VOL=tttt=rrrrrr,DSNAME=SYS1.CMDLIB,MEMBER=ALU                00020501
   SCRATCH VOL=tttt=rrrrrr,DSNAME=SYS1.CMDLIB,MEMBER=DELUSER            00020601
   SCRATCH VOL=tttt=rrrrrr,DSNAME=SYS1.CMDLIB,MEMBER=ADDSD              00020701
   SCRATCH VOL=tttt=rrrrrr,DSNAME=SYS1.CMDLIB,MEMBER=AD                 00020801
   SCRATCH VOL=tttt=rrrrrr,DSNAME=SYS1.CMDLIB,MEMBER=RDEFINE            00020901
   SCRATCH VOL=tttt=rrrrrr,DSNAME=SYS1.CMDLIB,MEMBER=PERMIT             00021001
   SCRATCH VOL=tttt=rrrrrr,DSNAME=SYS1.CMDLIB,MEMBER=PE                 00021101
   SCRATCH VOL=tttt=rrrrrr,DSNAME=SYS1.CMDLIB,MEMBER=RDELETE            00021201
   SCRATCH VOL=tttt=rrrrrr,DSNAME=SYS1.PROCLIB,MEMBER=RAKF              00021300
   SCRATCH VOL=tttt=rrrrrr,DSNAME=SYS1.PROCLIB,MEMBER=RAKFPROF          00021400
   SCRATCH VOL=tttt=rrrrrr,DSNAME=SYS1.PROCLIB,MEMBER=RAKFPWUP          00021500
   SCRATCH VOL=tttt=rrrrrr,DSNAME=SYS1.PROCLIB,MEMBER=RAKFUSER          00021600
   SCRATCH VOL=tttt=rrrrrr,DSNAME=SYS1.PARMLIB,MEMBER=RAKFINIT          00021700
/*                                                                      00021800
//                                                                      00021900
