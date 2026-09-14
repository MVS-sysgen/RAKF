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
  DEL LMOD(RAKFPROF) .                                                  00004200
  DEL LMOD(RAKFPWUP) .                                                  00004300
  DEL LMOD(RAKFUSER) .                                                  00004400
  DEL LMOD(ADDUSER)  .                                                  00004500
  DEL LMOD(ALTUSER)  .                                                  00004600
  DEL LMOD(DELUSER)  .                                                  00004701
  DEL LMOD(ADDSD)    .                                                  00004702
  DEL  MOD(CJYRCVT)  .                                                  00004800
  DEL  MOD(ICHRIN00) .                                                  00004900
  DEL  MOD(ICHSEC00) .                                                  00005000
  DEL  MOD(ICHSFR00) .                                                  00005100
  DEL  MOD(IGC0013A) .                                                  00005200
  DEL  MOD(IGC0013C) .                                                  00005300
  DEL  MOD(IGC00130) .                                                  00005400
  DEL  MOD(RACIND)   .                                                  00005500
  DEL  MOD(RAKFPROF) .                                                  00005600
  DEL  MOD(RAKFPSAV) .                                                  00005700
  DEL  MOD(RAKFPWUP) .                                                  00005800
  DEL  MOD(RAKFUSER) .                                                  00005900
  DEL  MOD(RAKFPWH)  .                                                  00006000
  DEL  MOD(RAKFHASH) .                                                  00006100
  DEL  MOD(ADDUSER)  .                                                  00006200
  DEL  MOD(ALTUSER)  .                                                  00006300
  DEL  MOD(DELUSER)  .                                                  00006401
  DEL  MOD(ADDSD)    .                                                  00006402
  DEL  SRC(CJYRCVT)  .                                                  00006500
  DEL  SRC(ICHRIN00) .                                                  00006600
  DEL  SRC(ICHSEC00) .                                                  00006700
  DEL  SRC(ICHSFR00) .                                                  00006800
  DEL  SRC(IGC0013A) .                                                  00006900
  DEL  SRC(IGC0013C) .                                                  00007000
  DEL  SRC(IGC00130) .                                                  00007100
  DEL  SRC(ADDUSER)  .                                                  00007200
  DEL  SRC(ALTUSER)  .                                                  00007300
  DEL  SRC(DELUSER)  .                                                  00007401
  DEL  SRC(ADDSD)    .                                                  00007412
  DEL  SRC(RACIND)   .                                                  00007500
  DEL  SRC(RAKFPROF) .                                                  00007600
  DEL  SRC(RAKFPSAV) .                                                  00007700
  DEL  SRC(RAKFPWH)  .                                                  00007800
  DEL  SRC(RAKFHASH) .                                                  00007900
  DEL  SRC(RAKFPWUP) .                                                  00008000
  DEL  SRC(RAKFUSER) .                                                  00008100
  DEL  MAC($$$$$DOC) .                                                  00008200
  DEL  MAC($$$$INFO) .                                                  00008300
  DEL  MAC($$COPYRT) .                                                  00008400
  DEL  MAC($$NOTICE) .                                                  00008500
  DEL  MAC($DOC$ZIP) .                                                  00008600
  DEL  MAC(LPABACK)  .                                                  00008700
  DEL  MAC(LPAREST)  .                                                  00008800
  DEL  MAC(JRACIND)  .                                                  00008900
  DEL  MAC(RAKFRMV)  .                                                  00009000
  DEL  MAC(RAKF2MVS) .                                                  00009100
  DEL  MAC(CJYPCBLK) .                                                  00009200
  DEL  MAC(CJYRCVTD) .                                                  00009300
  DEL  MAC(CJYUCBLK) .                                                  00009400
  DEL  MAC(IEZCTGFL) .                                                  00009500
  DEL  MAC(INITPWUP) .                                                  00009600
  DEL  MAC(INITSHAD) .                                                  00009700
  DEL  MAC(INITTBLS) .                                                  00009800
  DEL  MAC(YREGS)    .                                                  00009900
  DEL  MAC(RAKF)     .                                                  00010000
  DEL  MAC(RAKFPROF) .                                                  00010100
  DEL  MAC(RAKFPWUP) .                                                  00010200
  DEL  MAC(RAKFUSER) .                                                  00010300
  DEL  MAC(RAKFINIT) .                                                  00010400
  DEL  MAC(VSAMLRAC) .                                                  00010500
  DEL  MAC(VSAMSRAC) .                                                  00010600
  DEL  MAC(VTOCLRAC) .                                                  00010700
  DEL  MAC(VTOCSRAC) .                                                  00010800
  DEL  MAC(ZAPMVS38) .                                                  00010900
  DEL  SYSMOD(RRKF006) .                                                00011000
  DEL  SYSMOD(RRKF007) .                                                00011100
  DEL  SYSMOD(RRKF008) .                                                00011200
  DEL  SYSMOD(RRKF009) .                                                00011300
  DEL  SYSMOD(TRKF200) .                                                00011400
 ENDUCL .                                                               00011500
 UCLIN ACDS .                                                           00011600
  DEL  SRC(CJYRCVT)  .                                                  00011700
  DEL  SRC(ICHRIN00) .                                                  00011800
  DEL  SRC(ICHSEC00) .                                                  00011900
  DEL  SRC(ICHSFR00) .                                                  00012000
  DEL  SRC(IGC0013A) .                                                  00012100
  DEL  SRC(IGC0013C) .                                                  00012200
  DEL  SRC(IGC00130) .                                                  00012300
  DEL  SRC(ADDUSER)  .                                                  00012310
  DEL  SRC(ALTUSER)  .                                                  00012320
  DEL  SRC(DELUSER)  .                                                  00012330
  DEL  SRC(ADDSD)    .                                                  00012340
  DEL  SRC(RACIND)   .                                                  00012700
  DEL  SRC(RAKFPROF) .                                                  00012800
  DEL  SRC(RAKFPSAV) .                                                  00012900
  DEL  SRC(RAKFPWUP) .                                                  00013000
  DEL  SRC(RAKFUSER) .                                                  00013100
  DEL  SRC(RAKFPWH)  .                                                  00013200
  DEL  SRC(RAKFHASH) .                                                  00013300
  DEL  MAC($$$$$DOC) .                                                  00013400
  DEL  MAC($$$$INFO) .                                                  00013500
  DEL  MAC($$COPYRT) .                                                  00013600
  DEL  MAC($$NOTICE) .                                                  00013700
  DEL  MAC($DOC$ZIP) .                                                  00013800
  DEL  MAC(LPABACK)  .                                                  00013900
  DEL  MAC(LPAREST)  .                                                  00014000
  DEL  MAC(JRACIND)  .                                                  00014100
  DEL  MAC(RAKFRMV)  .                                                  00014200
  DEL  MAC(RAKF2MVS) .                                                  00014300
  DEL  MAC(CJYPCBLK) .                                                  00014400
  DEL  MAC(CJYRCVTD) .                                                  00014500
  DEL  MAC(CJYUCBLK) .                                                  00014600
  DEL  MAC(IEZCTGFL) .                                                  00014700
  DEL  MAC(INITPWUP) .                                                  00014800
  DEL  MAC(INITSHAD) .                                                  00014900
  DEL  MAC(INITTBLS) .                                                  00015000
  DEL  MAC(YREGS)    .                                                  00015100
  DEL  MAC(RAKF)     .                                                  00015200
  DEL  MAC(RAKFPROF) .                                                  00015300
  DEL  MAC(RAKFPWUP) .                                                  00015400
  DEL  MAC(RAKFUSER) .                                                  00015500
  DEL  MAC(RAKFINIT) .                                                  00015600
  DEL  MAC(VSAMLRAC) .                                                  00015700
  DEL  MAC(VSAMSRAC) .                                                  00015800
  DEL  MAC(VTOCLRAC) .                                                  00015900
  DEL  MAC(VTOCSRAC) .                                                  00016000
  DEL  MAC(ZAPMVS38) .                                                  00016100
  DEL  SYSMOD(RRKF006) .                                                00016200
  DEL  SYSMOD(RRKF007) .                                                00016300
  DEL  SYSMOD(RRKF008) .                                                00016400
  DEL  SYSMOD(RRKF009) .                                                00016500
  DEL  SYSMOD(TRKF200) .                                                00016600
 ENDUCL .                                                               00016700
/*                                                                      00016800
//* ------------------------------------------------------------------* 00016900
//* Remove RAKF elements from LINKLIB, LPALIB, PARMLIB and PROCLIB    * 00017000
//* ------------------------------------------------------------------* 00017100
//SCRATCH EXEC PGM=IEHPROGM                                             00017200
//SYSPRINT DD  SYSOUT=*                                                 00017300
//DD1      DD  VOL=SER=rrrrrr,DISP=OLD,UNIT=tttt                        00017400
//SYSIN    DD  *                                                        00017500
   SCRATCH VOL=tttt=rrrrrr,DSNAME=SYS1.LPALIB,MEMBER=ICHSFR00           00017600
   SCRATCH VOL=tttt=rrrrrr,DSNAME=SYS1.LPALIB,MEMBER=IGC0013A           00017700
   SCRATCH VOL=tttt=rrrrrr,DSNAME=SYS1.LPALIB,MEMBER=IGC0013B           00017800
   SCRATCH VOL=tttt=rrrrrr,DSNAME=SYS1.LPALIB,MEMBER=IGC0013C           00017900
   SCRATCH VOL=tttt=rrrrrr,DSNAME=SYS1.LPALIB,MEMBER=IGC0013{           00018000
   SCRATCH VOL=tttt=rrrrrr,DSNAME=SYS1.LPALIB,MEMBER=ICHRIN00           00018100
   SCRATCH VOL=tttt=rrrrrr,DSNAME=SYS1.LINKLIB,MEMBER=ICHSEC00          00018200
   SCRATCH VOL=tttt=rrrrrr,DSNAME=SYS1.LINKLIB,MEMBER=RACIND            00018300
   SCRATCH VOL=tttt=rrrrrr,DSNAME=SYS1.LINKLIB,MEMBER=RAKFPROF          00018400
   SCRATCH VOL=tttt=rrrrrr,DSNAME=SYS1.LINKLIB,MEMBER=RAKFUSER          00018500
   SCRATCH VOL=tttt=rrrrrr,DSNAME=SYS1.LINKLIB,MEMBER=RAKFPWUP          00018600
   SCRATCH VOL=tttt=rrrrrr,DSNAME=SYS1.PROCLIB,MEMBER=RAKF              00018700
   SCRATCH VOL=tttt=rrrrrr,DSNAME=SYS1.PROCLIB,MEMBER=RAKFPROF          00018800
   SCRATCH VOL=tttt=rrrrrr,DSNAME=SYS1.PROCLIB,MEMBER=RAKFPWUP          00018900
   SCRATCH VOL=tttt=rrrrrr,DSNAME=SYS1.PROCLIB,MEMBER=RAKFUSER          00019000
   SCRATCH VOL=tttt=rrrrrr,DSNAME=SYS1.PARMLIB,MEMBER=RAKFINIT          00019100
/*                                                                      00019200
//                                                                      00019300
