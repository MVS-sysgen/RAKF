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
  DEL LMOD(LISTUSER) .                                                  00004801
  DEL LMOD(ADDSD)    .                                                  00004901
  DEL LMOD(PERMIT)   .                                                  00005003
  DEL LMOD(RDELETE)  .                                                  00005103
  DEL  MOD(CJYRCVT)  .                                                  00005200
  DEL  MOD(ICHRIN00) .                                                  00005300
  DEL  MOD(ICHSEC00) .                                                  00005400
  DEL  MOD(ICHSFR00) .                                                  00005500
  DEL  MOD(IGC0013A) .                                                  00005600
  DEL  MOD(IGC0013C) .                                                  00005700
  DEL  MOD(IGC00130) .                                                  00005800
  DEL  MOD(RAKFPSAV) .                                                  00005900
  DEL  MOD(RACIND)   .                                                  00006000
  DEL  MOD(CJYRPROF) .                                                  00006101
  DEL  MOD(CJYRPWUP) .                                                  00006201
  DEL  MOD(CJYFUSER) .                                                  00006301
  DEL  MOD(RAKFPWH)  .                                                  00006400
  DEL  MOD(RAKFHASH) .                                                  00006500
  DEL  MOD(ADDUSER)  .                                                  00006600
  DEL  MOD(ALTUSER)  .                                                  00006700
  DEL  MOD(DELUSER)  .                                                  00006801
  DEL  MOD(LISTUSER) .                                                  00006901
  DEL  MOD(ADDSD)    .                                                  00007001
  DEL  MOD(PERMIT)   .                                                  00007103
  DEL  MOD(RDELETE)  .                                                  00007203
  DEL  SRC(ICHRIN00) .                                                  00007300
  DEL  SRC(ICHSEC00) .                                                  00007400
  DEL  SRC(ICHSFR00) .                                                  00007500
  DEL  SRC(IGC0013A) .                                                  00007600
  DEL  SRC(IGC0013C) .                                                  00007700
  DEL  SRC(IGC00130) .                                                  00007800
  DEL  SRC(CJYRCVT)  .                                                  00007900
  DEL  SRC(ADDUSER)  .                                                  00008000
  DEL  SRC(ALTUSER)  .                                                  00008100
  DEL  SRC(DELUSER)  .                                                  00008201
  DEL  SRC(LISTUSER) .                                                  00008301
  DEL  SRC(ADDSD)    .                                                  00008401
  DEL  SRC(PERMIT)   .                                                  00008503
  DEL  SRC(RDELETE)  .                                                  00008603
  DEL  SRC(RACIND)   .                                                  00008700
  DEL  SRC(CJYRPROF) .                                                  00008801
  DEL  SRC(CJYRPWUP) .                                                  00008901
  DEL  SRC(CJYRUIDS) .                                                  00009001
  DEL  SRC(RAKFPSAV) .                                                  00009100
  DEL  SRC(RAKFPWH)  .                                                  00009200
  DEL  SRC(RAKFHASH) .                                                  00009300
  DEL  MAC($$$$$DOC) .                                                  00009400
  DEL  MAC($$$$INFO) .                                                  00009500
  DEL  MAC($$COPYRT) .                                                  00009600
  DEL  MAC($$NOTICE) .                                                  00009700
  DEL  MAC($DOC$ZIP) .                                                  00009800
  DEL  MAC(LPABACK)  .                                                  00009900
  DEL  MAC(LPAREST)  .                                                  00010000
  DEL  MAC(JRACIND)  .                                                  00010100
  DEL  MAC(SPECIAL)  .                                                  00010201
  DEL  MAC(RAKFRMV)  .                                                  00010300
  DEL  MAC(RAKF2MVS) .                                                  00010400
  DEL  MAC(CJYPCBLK) .                                                  00010500
  DEL  MAC(CJYRCVTD) .                                                  00010600
  DEL  MAC(CJYUCBLK) .                                                  00010700
  DEL  MAC(IEZCTGFL) .                                                  00010800
  DEL  MAC(INITPWUP) .                                                  00010900
  DEL  MAC(INITSHAD) .                                                  00011000
  DEL  MAC(INITTBLS) .                                                  00011100
  DEL  MAC(YREGS)    .                                                  00011200
  DEL  MAC(RAKF)     .                                                  00011300
  DEL  MAC(RAKFPROF) .                                                  00011400
  DEL  MAC(RAKFPWUP) .                                                  00011500
  DEL  MAC(RAKFUSER) .                                                  00011600
  DEL  MAC(RAKFINIT) .                                                  00011700
  DEL  MAC(VSAMLRAC) .                                                  00011800
  DEL  MAC(VSAMSRAC) .                                                  00011900
  DEL  MAC(VTOCLRAC) .                                                  00012000
  DEL  MAC(VTOCSRAC) .                                                  00012100
  DEL  MAC(ZAPMVS38) .                                                  00012200
  DEL  SYSMOD(RRKF006) .                                                00012300
  DEL  SYSMOD(RRKF007) .                                                00012400
  DEL  SYSMOD(RRKF008) .                                                00012500
  DEL  SYSMOD(RRKF009) .                                                00012600
  DEL  SYSMOD(TRKF200) .                                                00012700
 ENDUCL .                                                               00012800
 UCLIN ACDS .                                                           00012900
  DEL  SRC(CJYRCVT)  .                                                  00013000
  DEL  SRC(ICHRIN00) .                                                  00013100
  DEL  SRC(ICHSEC00) .                                                  00013200
  DEL  SRC(ICHSFR00) .                                                  00013300
  DEL  SRC(IGC0013A) .                                                  00013400
  DEL  SRC(IGC0013C) .                                                  00013500
  DEL  SRC(IGC00130) .                                                  00013600
  DEL  SRC(ADDUSER)  .                                                  00013701
  DEL  SRC(ALTUSER)  .                                                  00013801
  DEL  SRC(DELUSER)  .                                                  00013901
  DEL  SRC(LISTUSER) .                                                  00014001
  DEL  SRC(ADDSD)    .                                                  00014101
  DEL  SRC(PERMIT)   .                                                  00014203
  DEL  SRC(RDELETE)  .                                                  00014303
  DEL  SRC(RACIND)   .                                                  00014400
  DEL  SRC(RAKFPSAV) .                                                  00014500
  DEL  SRC(CJYRPROF) .                                                  00014601
  DEL  SRC(CJYRPWUP) .                                                  00014701
  DEL  SRC(CJYRUIDS) .                                                  00014801
  DEL  SRC(RAKFPWH)  .                                                  00014900
  DEL  SRC(RAKFHASH) .                                                  00015000
  DEL  MAC($$$$$DOC) .                                                  00015100
  DEL  MAC($$$$INFO) .                                                  00015200
  DEL  MAC($$COPYRT) .                                                  00015300
  DEL  MAC($$NOTICE) .                                                  00015400
  DEL  MAC($DOC$ZIP) .                                                  00015500
  DEL  MAC(LPABACK)  .                                                  00015600
  DEL  MAC(LPAREST)  .                                                  00015700
  DEL  MAC(JRACIND)  .                                                  00015800
  DEL  MAC(SPECIAL)  .                                                  00015901
  DEL  MAC(RAKFRMV)  .                                                  00016000
  DEL  MAC(RAKF2MVS) .                                                  00016100
  DEL  MAC(CJYPCBLK) .                                                  00016200
  DEL  MAC(CJYRCVTD) .                                                  00016300
  DEL  MAC(CJYUCBLK) .                                                  00016400
  DEL  MAC(IEZCTGFL) .                                                  00016500
  DEL  MAC(INITPWUP) .                                                  00016600
  DEL  MAC(INITSHAD) .                                                  00016700
  DEL  MAC(INITTBLS) .                                                  00016800
  DEL  MAC(YREGS)    .                                                  00016900
  DEL  MAC(RAKF)     .                                                  00017000
  DEL  MAC(RAKFPROF) .                                                  00017100
  DEL  MAC(RAKFPWUP) .                                                  00017200
  DEL  MAC(RAKFUSER) .                                                  00017300
  DEL  MAC(RAKFINIT) .                                                  00017400
  DEL  MAC(VSAMLRAC) .                                                  00017500
  DEL  MAC(VSAMSRAC) .                                                  00017600
  DEL  MAC(VTOCLRAC) .                                                  00017700
  DEL  MAC(VTOCSRAC) .                                                  00017800
  DEL  MAC(ZAPMVS38) .                                                  00017900
  DEL  SYSMOD(RRKF006) .                                                00018000
  DEL  SYSMOD(RRKF007) .                                                00018100
  DEL  SYSMOD(RRKF008) .                                                00018200
  DEL  SYSMOD(RRKF009) .                                                00018300
  DEL  SYSMOD(TRKF200) .                                                00018400
 ENDUCL .                                                               00018500
/*                                                                      00018600
//* ------------------------------------------------------------------* 00018700
//* Remove RAKF elements from LINKLIB, LPALIB, PARMLIB and PROCLIB    * 00018800
//* ------------------------------------------------------------------* 00018900
//SCRATCH EXEC PGM=IEHPROGM                                             00019000
//SYSPRINT DD  SYSOUT=*                                                 00019100
//DD1      DD  VOL=SER=rrrrrr,DISP=OLD,UNIT=tttt                        00019200
//SYSIN    DD  *                                                        00019300
   SCRATCH VOL=tttt=rrrrrr,DSNAME=SYS1.LPALIB,MEMBER=ICHSFR00           00019400
   SCRATCH VOL=tttt=rrrrrr,DSNAME=SYS1.LPALIB,MEMBER=IGC0013A           00019500
   SCRATCH VOL=tttt=rrrrrr,DSNAME=SYS1.LPALIB,MEMBER=IGC0013B           00019600
   SCRATCH VOL=tttt=rrrrrr,DSNAME=SYS1.LPALIB,MEMBER=IGC0013C           00019700
   SCRATCH VOL=tttt=rrrrrr,DSNAME=SYS1.LPALIB,MEMBER=IGC0013{           00019800
   SCRATCH VOL=tttt=rrrrrr,DSNAME=SYS1.LPALIB,MEMBER=ICHRIN00           00019900
   SCRATCH VOL=tttt=rrrrrr,DSNAME=SYS1.LINKLIB,MEMBER=ICHSEC00          00020000
   SCRATCH VOL=tttt=rrrrrr,DSNAME=SYS1.LINKLIB,MEMBER=RACIND            00020100
   SCRATCH VOL=tttt=rrrrrr,DSNAME=SYS1.LINKLIB,MEMBER=CJYRPROF          00020201
   SCRATCH VOL=tttt=rrrrrr,DSNAME=SYS1.LINKLIB,MEMBER=RAKFPROF          00020301
   SCRATCH VOL=tttt=rrrrrr,DSNAME=SYS1.LINKLIB,MEMBER=CJYRUIDS          00020401
   SCRATCH VOL=tttt=rrrrrr,DSNAME=SYS1.LINKLIB,MEMBER=RAKFUSER          00020501
   SCRATCH VOL=tttt=rrrrrr,DSNAME=SYS1.LINKLIB,MEMBER=CJYRPWUP          00020601
   SCRATCH VOL=tttt=rrrrrr,DSNAME=SYS1.LINKLIB,MEMBER=RAKFPWUP          00020701
   SCRATCH VOL=tttt=rrrrrr,DSNAME=SYS1.CMDLIB,MEMBER=ADDUSER            00020801
   SCRATCH VOL=tttt=rrrrrr,DSNAME=SYS1.CMDLIB,MEMBER=AU                 00020901
   SCRATCH VOL=tttt=rrrrrr,DSNAME=SYS1.CMDLIB,MEMBER=ALTUSER            00021001
   SCRATCH VOL=tttt=rrrrrr,DSNAME=SYS1.CMDLIB,MEMBER=ALU                00021101
   SCRATCH VOL=tttt=rrrrrr,DSNAME=SYS1.CMDLIB,MEMBER=DELUSER            00021201
   SCRATCH VOL=tttt=rrrrrr,DSNAME=SYS1.CMDLIB,MEMBER=LISTUSER           00021301
   SCRATCH VOL=tttt=rrrrrr,DSNAME=SYS1.CMDLIB,MEMBER=LU                 00021401
   SCRATCH VOL=tttt=rrrrrr,DSNAME=SYS1.CMDLIB,MEMBER=ADDSD              00021501
   SCRATCH VOL=tttt=rrrrrr,DSNAME=SYS1.CMDLIB,MEMBER=AD                 00021601
   SCRATCH VOL=tttt=rrrrrr,DSNAME=SYS1.CMDLIB,MEMBER=RDEFINE            00021701
   SCRATCH VOL=tttt=rrrrrr,DSNAME=SYS1.CMDLIB,MEMBER=PERMIT             00021801
   SCRATCH VOL=tttt=rrrrrr,DSNAME=SYS1.CMDLIB,MEMBER=PE                 00021901
   SCRATCH VOL=tttt=rrrrrr,DSNAME=SYS1.CMDLIB,MEMBER=RDELETE            00022001
   SCRATCH VOL=tttt=rrrrrr,DSNAME=SYS1.PROCLIB,MEMBER=RAKF              00022100
   SCRATCH VOL=tttt=rrrrrr,DSNAME=SYS1.PROCLIB,MEMBER=RAKFPROF          00022200
   SCRATCH VOL=tttt=rrrrrr,DSNAME=SYS1.PROCLIB,MEMBER=RAKFPWUP          00022300
   SCRATCH VOL=tttt=rrrrrr,DSNAME=SYS1.PROCLIB,MEMBER=RAKFUSER          00022400
   SCRATCH VOL=tttt=rrrrrr,DSNAME=SYS1.PARMLIB,MEMBER=RAKFINIT          00022500
/*                                                                      00022600
//                                                                      00022700
