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
  DEL LMOD(CONNECT)  .                                                  00004901
  DEL LMOD(ADDSD)    .                                                  00005001
  DEL LMOD(PERMIT)   .                                                  00005103
  DEL LMOD(RDELETE)  .                                                  00005203
  DEL LMOD(LISTP)    .                                                  00005301
  DEL  MOD(CJYRCVT)  .                                                  00005400
  DEL  MOD(ICHRIN00) .                                                  00005500
  DEL  MOD(ICHSEC00) .                                                  00005600
  DEL  MOD(ICHSFR00) .                                                  00005700
  DEL  MOD(IGC0013A) .                                                  00005800
  DEL  MOD(IGC0013C) .                                                  00005900
  DEL  MOD(IGC00130) .                                                  00006000
  DEL  MOD(RAKFPSAV) .                                                  00006100
  DEL  MOD(RACIND)   .                                                  00006200
  DEL  MOD(CJYRPROF) .                                                  00006301
  DEL  MOD(CJYRPWUP) .                                                  00006401
  DEL  MOD(CJYFUSER) .                                                  00006501
  DEL  MOD(RAKFPWH)  .                                                  00006600
  DEL  MOD(RAKFHASH) .                                                  00006700
  DEL  MOD(ADDUSER)  .                                                  00006800
  DEL  MOD(ALTUSER)  .                                                  00006900
  DEL  MOD(DELUSER)  .                                                  00007001
  DEL  MOD(LISTUSER) .                                                  00007101
  DEL  MOD(CONNECT)  .                                                  00007201
  DEL  MOD(ADDSD)    .                                                  00007301
  DEL  MOD(PERMIT)   .                                                  00007403
  DEL  MOD(RDELETE)  .                                                  00007503
  DEL  MOD(LISTP)    .                                                  00007601
  DEL  SRC(ICHRIN00) .                                                  00007700
  DEL  SRC(ICHSEC00) .                                                  00007800
  DEL  SRC(ICHSFR00) .                                                  00007900
  DEL  SRC(IGC0013A) .                                                  00008000
  DEL  SRC(IGC0013C) .                                                  00008100
  DEL  SRC(IGC00130) .                                                  00008200
  DEL  SRC(CJYRCVT)  .                                                  00008300
  DEL  SRC(ADDUSER)  .                                                  00008400
  DEL  SRC(ALTUSER)  .                                                  00008500
  DEL  SRC(DELUSER)  .                                                  00008601
  DEL  SRC(LISTUSER) .                                                  00008701
  DEL  SRC(CONNECT)  .                                                  00008801
  DEL  SRC(ADDSD)    .                                                  00008901
  DEL  SRC(PERMIT)   .                                                  00009003
  DEL  SRC(RDELETE)  .                                                  00009103
  DEL  SRC(LISTP)    .                                                  00009201
  DEL  SRC(RACIND)   .                                                  00009300
  DEL  SRC(CJYRPROF) .                                                  00009401
  DEL  SRC(CJYRPWUP) .                                                  00009501
  DEL  SRC(CJYRUIDS) .                                                  00009601
  DEL  SRC(RAKFPSAV) .                                                  00009700
  DEL  SRC(RAKFPWH)  .                                                  00009800
  DEL  SRC(RAKFHASH) .                                                  00009900
  DEL  MAC($$$$$DOC) .                                                  00010000
  DEL  MAC($$$$INFO) .                                                  00010100
  DEL  MAC($$COPYRT) .                                                  00010200
  DEL  MAC($$NOTICE) .                                                  00010300
  DEL  MAC($DOC$ZIP) .                                                  00010400
  DEL  MAC(LPABACK)  .                                                  00010500
  DEL  MAC(LPAREST)  .                                                  00010600
  DEL  MAC(JRACIND)  .                                                  00010700
  DEL  MAC(SPECIAL)  .                                                  00010801
  DEL  MAC(RAKFRMV)  .                                                  00010900
  DEL  MAC(RAKF2MVS) .                                                  00011000
  DEL  MAC(CJYPCBLK) .                                                  00011100
  DEL  MAC(CJYRCVTD) .                                                  00011200
  DEL  MAC(CJYUCBLK) .                                                  00011300
  DEL  MAC(IEZCTGFL) .                                                  00011400
  DEL  MAC(INITPWUP) .                                                  00011500
  DEL  MAC(INITSHAD) .                                                  00011600
  DEL  MAC(INITTBLS) .                                                  00011700
  DEL  MAC(YREGS)    .                                                  00011800
  DEL  MAC(RAKF)     .                                                  00011900
  DEL  MAC(RAKFPROF) .                                                  00012000
  DEL  MAC(RAKFPWUP) .                                                  00012100
  DEL  MAC(RAKFUSER) .                                                  00012200
  DEL  MAC(RAKFINIT) .                                                  00012300
  DEL  MAC(VSAMLRAC) .                                                  00012400
  DEL  MAC(VSAMSRAC) .                                                  00012500
  DEL  MAC(VTOCLRAC) .                                                  00012600
  DEL  MAC(VTOCSRAC) .                                                  00012700
  DEL  MAC(ZAPMVS38) .                                                  00012800
  DEL  SYSMOD(RRKF006) .                                                00012900
  DEL  SYSMOD(RRKF007) .                                                00013000
  DEL  SYSMOD(RRKF008) .                                                00013100
  DEL  SYSMOD(RRKF009) .                                                00013200
  DEL  SYSMOD(TRKF200) .                                                00013300
 ENDUCL .                                                               00013400
 UCLIN ACDS .                                                           00013500
  DEL  SRC(CJYRCVT)  .                                                  00013600
  DEL  SRC(ICHRIN00) .                                                  00013700
  DEL  SRC(ICHSEC00) .                                                  00013800
  DEL  SRC(ICHSFR00) .                                                  00013900
  DEL  SRC(IGC0013A) .                                                  00014000
  DEL  SRC(IGC0013C) .                                                  00014100
  DEL  SRC(IGC00130) .                                                  00014200
  DEL  SRC(ADDUSER)  .                                                  00014301
  DEL  SRC(ALTUSER)  .                                                  00014401
  DEL  SRC(DELUSER)  .                                                  00014501
  DEL  SRC(LISTUSER) .                                                  00014601
  DEL  SRC(CONNECT)  .                                                  00014701
  DEL  SRC(ADDSD)    .                                                  00014801
  DEL  SRC(PERMIT)   .                                                  00014903
  DEL  SRC(RDELETE)  .                                                  00015003
  DEL  SRC(LISTP)    .                                                  00015101
  DEL  SRC(RACIND)   .                                                  00015200
  DEL  SRC(RAKFPSAV) .                                                  00015300
  DEL  SRC(CJYRPROF) .                                                  00015401
  DEL  SRC(CJYRPWUP) .                                                  00015501
  DEL  SRC(CJYRUIDS) .                                                  00015601
  DEL  SRC(RAKFPWH)  .                                                  00015700
  DEL  SRC(RAKFHASH) .                                                  00015800
  DEL  MAC($$$$$DOC) .                                                  00015900
  DEL  MAC($$$$INFO) .                                                  00016000
  DEL  MAC($$COPYRT) .                                                  00016100
  DEL  MAC($$NOTICE) .                                                  00016200
  DEL  MAC($DOC$ZIP) .                                                  00016300
  DEL  MAC(LPABACK)  .                                                  00016400
  DEL  MAC(LPAREST)  .                                                  00016500
  DEL  MAC(JRACIND)  .                                                  00016600
  DEL  MAC(SPECIAL)  .                                                  00016701
  DEL  MAC(RAKFRMV)  .                                                  00016800
  DEL  MAC(RAKF2MVS) .                                                  00016900
  DEL  MAC(CJYPCBLK) .                                                  00017000
  DEL  MAC(CJYRCVTD) .                                                  00017100
  DEL  MAC(CJYUCBLK) .                                                  00017200
  DEL  MAC(IEZCTGFL) .                                                  00017300
  DEL  MAC(INITPWUP) .                                                  00017400
  DEL  MAC(INITSHAD) .                                                  00017500
  DEL  MAC(INITTBLS) .                                                  00017600
  DEL  MAC(YREGS)    .                                                  00017700
  DEL  MAC(RAKF)     .                                                  00017800
  DEL  MAC(RAKFPROF) .                                                  00017900
  DEL  MAC(RAKFPWUP) .                                                  00018000
  DEL  MAC(RAKFUSER) .                                                  00018100
  DEL  MAC(RAKFINIT) .                                                  00018200
  DEL  MAC(VSAMLRAC) .                                                  00018300
  DEL  MAC(VSAMSRAC) .                                                  00018400
  DEL  MAC(VTOCLRAC) .                                                  00018500
  DEL  MAC(VTOCSRAC) .                                                  00018600
  DEL  MAC(ZAPMVS38) .                                                  00018700
  DEL  SYSMOD(RRKF006) .                                                00018800
  DEL  SYSMOD(RRKF007) .                                                00018900
  DEL  SYSMOD(RRKF008) .                                                00019000
  DEL  SYSMOD(RRKF009) .                                                00019100
  DEL  SYSMOD(TRKF200) .                                                00019200
 ENDUCL .                                                               00019300
/*                                                                      00019400
//* ------------------------------------------------------------------* 00019500
//* Remove RAKF elements from LINKLIB, LPALIB, PARMLIB and PROCLIB    * 00019600
//* ------------------------------------------------------------------* 00019700
//SCRATCH EXEC PGM=IEHPROGM                                             00019800
//SYSPRINT DD  SYSOUT=*                                                 00019900
//DD1      DD  VOL=SER=rrrrrr,DISP=OLD,UNIT=tttt                        00020000
//SYSIN    DD  *                                                        00020100
   SCRATCH VOL=tttt=rrrrrr,DSNAME=SYS1.LPALIB,MEMBER=ICHSFR00           00020200
   SCRATCH VOL=tttt=rrrrrr,DSNAME=SYS1.LPALIB,MEMBER=IGC0013A           00020300
   SCRATCH VOL=tttt=rrrrrr,DSNAME=SYS1.LPALIB,MEMBER=IGC0013B           00020400
   SCRATCH VOL=tttt=rrrrrr,DSNAME=SYS1.LPALIB,MEMBER=IGC0013C           00020500
   SCRATCH VOL=tttt=rrrrrr,DSNAME=SYS1.LPALIB,MEMBER=IGC0013{           00020600
   SCRATCH VOL=tttt=rrrrrr,DSNAME=SYS1.LPALIB,MEMBER=ICHRIN00           00020700
   SCRATCH VOL=tttt=rrrrrr,DSNAME=SYS1.LINKLIB,MEMBER=ICHSEC00          00020800
   SCRATCH VOL=tttt=rrrrrr,DSNAME=SYS1.LINKLIB,MEMBER=RACIND            00020900
   SCRATCH VOL=tttt=rrrrrr,DSNAME=SYS1.LINKLIB,MEMBER=CJYRPROF          00021001
   SCRATCH VOL=tttt=rrrrrr,DSNAME=SYS1.LINKLIB,MEMBER=RAKFPROF          00021101
   SCRATCH VOL=tttt=rrrrrr,DSNAME=SYS1.LINKLIB,MEMBER=CJYRUIDS          00021201
   SCRATCH VOL=tttt=rrrrrr,DSNAME=SYS1.LINKLIB,MEMBER=RAKFUSER          00021301
   SCRATCH VOL=tttt=rrrrrr,DSNAME=SYS1.LINKLIB,MEMBER=CJYRPWUP          00021401
   SCRATCH VOL=tttt=rrrrrr,DSNAME=SYS1.LINKLIB,MEMBER=RAKFPWUP          00021501
   SCRATCH VOL=tttt=rrrrrr,DSNAME=SYS1.CMDLIB,MEMBER=ADDUSER            00021601
   SCRATCH VOL=tttt=rrrrrr,DSNAME=SYS1.CMDLIB,MEMBER=AU                 00021701
   SCRATCH VOL=tttt=rrrrrr,DSNAME=SYS1.CMDLIB,MEMBER=ALTUSER            00021801
   SCRATCH VOL=tttt=rrrrrr,DSNAME=SYS1.CMDLIB,MEMBER=ALU                00021901
   SCRATCH VOL=tttt=rrrrrr,DSNAME=SYS1.CMDLIB,MEMBER=DELUSER            00022001
   SCRATCH VOL=tttt=rrrrrr,DSNAME=SYS1.CMDLIB,MEMBER=LISTUSER           00022101
   SCRATCH VOL=tttt=rrrrrr,DSNAME=SYS1.CMDLIB,MEMBER=CONNECT            00022201
   SCRATCH VOL=tttt=rrrrrr,DSNAME=SYS1.CMDLIB,MEMBER=LU                 00022301
   SCRATCH VOL=tttt=rrrrrr,DSNAME=SYS1.CMDLIB,MEMBER=ADDSD              00022401
   SCRATCH VOL=tttt=rrrrrr,DSNAME=SYS1.CMDLIB,MEMBER=AD                 00022501
   SCRATCH VOL=tttt=rrrrrr,DSNAME=SYS1.CMDLIB,MEMBER=RDEFINE            00022601
   SCRATCH VOL=tttt=rrrrrr,DSNAME=SYS1.CMDLIB,MEMBER=PERMIT             00022701
   SCRATCH VOL=tttt=rrrrrr,DSNAME=SYS1.CMDLIB,MEMBER=PE                 00022801
   SCRATCH VOL=tttt=rrrrrr,DSNAME=SYS1.CMDLIB,MEMBER=RDELETE            00022901
   SCRATCH VOL=tttt=rrrrrr,DSNAME=SYS1.CMDLIB,MEMBER=LISTP              00023001
   SCRATCH VOL=tttt=rrrrrr,DSNAME=SYS1.PROCLIB,MEMBER=RAKF              00023100
   SCRATCH VOL=tttt=rrrrrr,DSNAME=SYS1.PROCLIB,MEMBER=RAKFPROF          00023200
   SCRATCH VOL=tttt=rrrrrr,DSNAME=SYS1.PROCLIB,MEMBER=RAKFPWUP          00023300
   SCRATCH VOL=tttt=rrrrrr,DSNAME=SYS1.PROCLIB,MEMBER=RAKFUSER          00023400
   SCRATCH VOL=tttt=rrrrrr,DSNAME=SYS1.PARMLIB,MEMBER=RAKFINIT          00023500
/*                                                                      00023600
//                                                                      00023700
