//RAKFPTF1 JOB (TSO),
//             'PDSLOAD RAKF PTFs',
//             CLASS=A,
//             MSGCLASS=A,
//             MSGLEVEL=(1,1)
//*
//*  Add missing macro
//*
//STEP1   EXEC PGM=PDSLOAD
//STEPLIB  DD  DSN=SYSC.LINKLIB,DISP=SHR
//SYSPRINT DD  SYSOUT=*
//SYSUT2   DD  DSN=SYSGEN.RAKF.RRKF005.RACIND,DISP=SHR
//SYSUT1   DD  DATA,DLM=@@
./ ADD NAME=IEZCTGPL
* %GOTO CTGPLX01; /*                                                    00050000
         MACRO                                                          00100000
         IEZCTGPL ,                                                     00150000
         DSECT ,                        */                              00160000
* %CTGPLX01:;                                                           00200000
*/********************************************************************/ 03000000
*/*                                                                  */ 03001000
*/*   MACRO NAME = IEZCTGPL                                          */ 03002000
*/*                                                                  */ 03003000
*/*   DESCRIPTIVE NAME = CATALOG PARAMETER LIST                      */ 03004000
*/*                                                                  */ 03005000
*/*   FUNCTION = THE CATALOG PARAMETER LIST (CTGPL) DEFINES THE      */ 03006000
*/*              CATALOG MANAGEMENT REQUEST AND ITS OPTIONS, THE     */ 03007000
*/*              CATALOG RECORD TO BE PROCESSED, AND THE VSAM        */ 03008000
*/*              CATALOG THAT CONTAINES THE RECORD.  THE CTGPL IS    */ 03009000
*/*              BUILT BEFORE AN OS/VS COMPONENT ISSUES THE CATLG    */ 03010000
*/*              MACRO INSTRUCTION (SVC 26) TO PROCESS A CATALOG     */ 03011000
*/*              RECORD.  WHEN THE CATALOG MANAGEMENT ROUTINES       */ 03012000
*/*              BUILD A CCA TO SUPPORT THE REQUEST, THE ADDRESS     */ 03013000
*/*              OF THE CTGPL IS PUT INTO THE CCA (CCACPL).          */ 03014000
*/*                                                                  */ 03015000
*/*   CONTROL BLOCK STRUCTURE = THE CTGPL IS POINTED TO BY           */ 03016000
*/*                             REGISTER 1.                          */ 03017000
*/*                                                                  */ 03018000
*/*   INCLUDED MACROS = NONE                                         */ 03019000
*/*                                                                  */ 03020000
*/*   METHOD OF ACCESS = PL/S - NO DECLARES NECESSARY                */ 03021000
*/*                                                                  */ 03022000
*/*   STATUS = VS/2 RELEASE 4   (CHANGE FLAG @Z40WSXX)       @Z40WSSG*/ 03023000
*/*   A 343000 A 346000                                      @ZA18274*/ 03024000
*/*                                                                  */ 03024600
*/*   DATE OF LAST CHANGE = 03 DEC 76                        @ZA18274*/ 03025200
*/*   JES3 SUPPORT - I 850084,892500,895500                          */ 03025300
*/*                                                              @HES*/ 03026000
*/********************************************************************/ 03027000
*%GOTO CTGPLX03;                                                        03077000
*/*                                                                     03200000
         AGO   .CTGPL01                 */                              03250000
*%CTGPLX03:;                                                            03300000
*%DECLARE (CTGPLLEN, CTGPL999, CTGPLLVL) CHAR;                          04000000
*%CTGPLLEN = 'LENGTH(CTGPL)';       /* LENGTH OF CTGPL               */ 04500000
*%IF CTGPL999 ^= ','                /* IF BLOCK NOT CONTINUED,       */ 05000000
*   %THEN %CTGPL999 = ';';          /*   THEN CLOSE DCL STATEMENT    */ 06000000
*%IF CTGPLLVL  = ''                 /* IF BLOCK NOT CONCATENATED,    */ 07000000
*   %THEN %GOTO CTGPL001;           /*   THEN GENERATE DCL           */ 08000000
*%CTGPLDUM = CTGPLLVL||' CTGPL';    /* SET MINOR LEVEL NUMBER        */ 09000000
*        CTGPLDUM                   /* CTGPL CONCATENATED LEVEL      */ 10000000
*%GOTO CTGPL002;                    /* SKIP DECLARE                  */ 11000000
*%CTGPL001:;                        /* DECLARE                       */ 12000000
*   DECLARE                                                             12500000
*     1 CTGPL BASED(CTGPLPTR)       /* DECLARE CTGPL LEVEL ONE       */ 13000000
*%CTGPL002:;                        /* SKIP DECLARE                  */ 14000000
*        BDY(WORD),                 /* WORD BOUNDARY                 */ 15000000
*       5 CTGOPTN1 BIT(8),          /* FIRST OPTION INDICATOR        */ 16000000
*         10 CTGBYPSS BIT(1),       /* BYPASS                        */ 17000000
*         10 CTGMAST  BIT(1),       /* VERIFY MASTER PASSWORD        */ 18000000
*         10 CTGCI    BIT(1),       /* VERIFY CONTROL INTERVAL       */ 19000000
*         10 CTGUPD   BIT(1),       /* VERIFY UPDATE                 */ 20000000
*         10 CTGREAD  BIT(1),       /* VERIFY READ                   */ 21000000
*         10 CTGNAME  BIT(1),       /* 1 = 44-BYTE NAME OR VOL SER,  */ 22000000
*                                   /* 0 = ENTRY ID NUMBER           */ 23000000
*         10 CTGCNAME BIT(1),       /* 1 = 44-BYTE NAME,             */ 24000000
*                                   /* 0 = ACB ADDRESS               */ 25000000
*         10 CTGGENLD BIT(1),       /* GENERIC LOCATE REQUEST  Y02020*/ 26000000
*       5 CTGOPTN2 BIT(8),          /* SECOND OPTION INDICATOR       */ 27000000
*         10 CTGEXT   BIT(1),       /* EXTEND       (UPDATE)         */ 28000000
*            15 CTGNSVS BIT(1),     /* CATLG CLEANUP REQUEST @ZA00605*/ 28050000
*         10 CTGERASE BIT(1),       /* ERASE        (DELETE)         */ 29000000
*            15 CTGSMF   BIT(1),    /* WRITE SMF    (LSPACE)         */ 30000000
*               20 CTGREL   BIT(1), /* RELEASE      (UPDATE)         */ 31000000
*                  25 CTGGTALL BIT(1),/* CONCAT SEARCH  FOR    Y02020*/ 31050000
*                                   /* (LISTCAT)               Y02020*/ 31100000
*         10 CTGPURG  BIT(1),       /* PURGE        (DELETE)         */ 32000000
*           15 CTGVMNT BIT(1),      /* VOLUME MOUNT CALLER           */ 33000000
*              20 CTGRCATN BIT(1),  /* RTN CATLG NAME(GLOC)    Y02020*/ 33010000
*                 25 CTGSWAP BIT(1),/* SWAPSPACE (DEFINE)    @Z40WSSG*/ 33050000
*         10 CTGGTNXT BIT(1),       /* GET NEXT     (LIST CATALOG)   */ 34000000
*           15 CTGUCRAX BIT(1),     /* UCRA EXTEND OPTION    @ZA18274*/ 34300000
*                                   /* (WITH UPDATE)                 */ 34600000
*         10 CTGDISC BIT(1),        /* DISCONNECT   (DELETE)         */ 35000000
*         10 CTGOVRID BIT(1),       /* ERASE OVERRIDE (DELETE)       */ 36000000
*         10 CTGSCR   BIT(1),       /* SCRATCH SPACE (DELETE)        */ 37000000
*         10 *        BIT(1),       /* RESERVED                      */ 38000000
*       5 CTGOPTN3 BIT(8),          /* THIRD OPTION INDICATOR        */ 39000000
*         10 CTGFUNC  BIT(3),       /* CATALOG FUNCTION              */ 40000000
*         10 CTGSUPLT BIT(1),       /* SUPER LOCATE                  */ 45000000
*         10 CTGGDGL  BIT(1),       /* GDG LOCATE REQUEST      Y02020*/ 46000000
*                                   /* WITH BASE LEVEL GIVEN   Y02020*/ 46100000
*                                   /* (CTGWAGB IN CTGWA)      Y02020*/ 46150000
*         10 CTGSRH   BIT(1),       /* 0 = SEARCH MASTER CATLG Y02020*/ 47000000
*                                   /*     ONLY                Y02020*/ 47050000
*                                   /* 1 = SEARCH OS CATALOG FIRST   */ 48000000
*         10 CTGNUM   BIT(1),       /* 0 = SEARCH BOTH CATALOGS,     */ 49000000
*                                   /* 1 = SEARCH ONE CATALOG        */ 50000000
*         10 CTGAM0   BIT(1),       /* VSAM REQ VERSUS NONVSAM       */ 51000000
*       5 CTGOPTN4 BIT(8),          /* GDG FLAGS                     */ 52000000
*         10 CTGLBASE BIT(1),       /* LOCATE GDG BASE ONLY Y02020   */ 52050000
*         10 CTGDOCAT BIT(1),       /* DO NOT OPEN NEEDED CATALOG    */ 52100000
*         10 CTGNPROF BIT(1),       /* NO (RAC) PROFILE SHOULD BE       52150000
*                                      DEFINED OR DELETED    @Z40RSRC*/ 52170000
*         10 CTGCOIN  BIT(1),       /* CONTROLLER INTERCEPT REQUESTED   52190000
*                                                            @ZA20773*/ 52250000
*         10 CTGBYPMT BIT(1),       /* BYPASS SECURITY PROMPTING        52300000
*                                       TO SYSTEM OPERATOR   @ZA07531*/ 52350000
*         10 CTGTIOT  BIT(1),       /* CALLER OWNS SYSZTIOT EXCLUSIVE   52400000
*                                                            @ZA20773*/ 52410000
*         10 *        BIT(2),       /* RESERVED              @ZA20773*/ 52460000
*       5 CTGENT   PTR(31),         /* USER ENTRY ADDR OR PTR TO VOLUME 53000000
*                                        SERIAL NUMBER (LSPACE)      */ 54000000
*         10 CTGFVT   PTR(31),      /* FVT ADDRESS (DEFINE, ALTER)   */ 55000000
*       5 CTGCAT   PTR(31),         /* CATALOG POINTER               */ 56000000
*         10 CTGCVOL PTR(31),       /* CVOL PTR (SUPER LOCATE)       */ 57000000
*       5 CTGWKA  PTR(31),          /* WORKAREA ADDR                 */ 58000000
*       5 CTGDSORG CHAR(2),         /* DATA SET ORG - SUPERLOCATE    */ 59000000
*         10 CTGOPTNS BIT(5),       /* CMS OPTIONS                   */ 60000000
*         10 *        BIT(4),       /* RESERVED                  @HES*/ 60050000
*         10 CTGHDLET BIT(1),       /* HSM HAS DELETED A MIGRATED       60100000
*                                      DATA SET                  @HES*/ 60150000
*         10 *        BIT(6),       /* RESERVED                  @HES*/ 60200000
*       5 CTGTYPE  CHAR(1),         /* ENTRY TYPE - LISTCAT, DELETE  */ 66000000
*       5 CTGNOFLD PTR(8),          /* NUMBER OF FIELD POINTERS      */ 74000000
*       5 CTGDDNM PTR(31),          /* DD NAME ADDR                  */ 75000000
*         10 CTGNEWNM PTR(31),      /* NEWNAME ADDRESS - ALTER       */ 76000000
*            15 CTGFDBK  PTR(16),   /* SUPER LOCATE FEEDBACK         */ 77000000
*            15 CTGFBFLG BIT(16),   /* SUPER LOCATE FLAGS            */ 78000000
*               20 CTGPAR   BIT(1), /* PARALLEL MOUNT -SUPERLOCATE   */ 79000000
*               20 CTGKEEP  BIT(1), /* FORCED KEEP - SUPERLOCATE     */ 80000000
*               20 CTGGDGB  BIT(1), /* GDG BASE LOCATE         Y02020*/ 81000000
*               20 CTGNGDSN BIT(1), /* GDG NAME GENERATED      Y02020*/ 81050000
*               20 CTGCLV   BIT(1), /* CANDIDATE VOLUME LIST @ZA76423*/ 81100000
*               20 *        BIT(11), /* RESERVED             @ZA76423*/ 81150000
*       5 CTGJSCB  PTR(31),         /* JSCB ADDR                     */ 82000000
*         10 CTGPSWD  PTR(31),      /* PASSWORD ADDR                 */ 83000000
*       5 CTGFIELD(*) PTR(31) CTGPL999 /* FIELD POINTERS             */ 84000000
*/********************************************************************/ 85000000
*/*     CONSTANTS USED TO SET AND/OR TEST FIELDS DECLARED ABOVE      */ 85000200
*/********************************************************************/ 85000400
*   DECLARE                         /* CATALOG FUNCTION - CTGFUNC    */ 85000600
*     CTGLOC   BIT(3) CONSTANT('001'B), /* LOCATE                    */ 85000900
*     CTGLSP   BIT(3) CONSTANT('010'B), /* LSPACE                    */ 85001200
*     CTGUPDAT BIT(3) CONSTANT('011'B), /* UPDATE                    */ 85001500
*     CTGCMS   BIT(3) CONSTANT('100'B); /* CMS FUNCTION              */ 85001800
*   DECLARE                         /* CMS OPTIONS - CTGOPTNS        */ 85002100
*     CTGDEFIN BIT(5) CONSTANT('00001'B), /* DEFINE                  */ 85002400
*     CTGALTER BIT(5) CONSTANT('00010'B), /* ALTER                   */ 85002700
*     CTGDELET BIT(5) CONSTANT('00011'B), /* DELETE                  */ 85003000
*     CTGLTCAT BIT(5) CONSTANT('00100'B), /* LIST CATALOG            */ 85003300
*     CTGCNVTV BIT(5) CONSTANT('00110'B); /* CONVERTV        @Y30LSPS*/ 85003600
*   DECLARE                           /* RECORD ENTRY TYPE - CTGTYPE */ 85003900
*     CTGTDATA CHAR(1) CONSTANT('D'), /* DATA                        */ 85004200
*     CTGTINDX CHAR(1) CONSTANT('I'), /* INDEX                       */ 85004500
*     CTGTALIN CHAR(1) CONSTANT('A'), /* ALIEN                       */ 85004800
*     CTGTUCAT CHAR(1) CONSTANT('U'), /* USER CATALOG                */ 85005100
*     CTGTVOL  CHAR(1) CONSTANT('V'), /* VOLUME                      */ 85005400
*     CTGTCL   CHAR(1) CONSTANT('C'), /* CLUSTER                     */ 85005700
*     CTGTAIX  CHAR(1) CONSTANT('G'), /* ALTERNATE INDEX     @Y30SSPJ*/ 85006000
*     CTGTPATH CHAR(1) CONSTANT('R'), /* PATH                @Y30SSPJ*/ 85006300
*     CTGTFREE CHAR(1) CONSTANT('F'), /* FREE                @Y30SSPJ*/ 85006600
*     CTGTPTH  CHAR(1) CONSTANT('R'), /* PATH                @Y30SSSB*/ 85006900
*     CTGTUPG  CHAR(1) CONSTANT('Y'), /* UPGRADE             @Y30SSSB*/ 85007200
*     CTGTGBS  CHAR(1) CONSTANT('B'), /* GDG BASE              Y02020*/ 85007500
*     CTGTANM  CHAR(1) CONSTANT('X'), /* ALIAS NAME            Y02020*/ 85007800
*     CTGTPGSP CHAR(1) CONSTANT('P'), /* PAGE SPACE            Y02020*/ 85008100
*     CTGTMCAT CHAR(1) CONSTANT('M'), /* MASTER CATALOG              */ 85008400
*     CTGTJES3 BIT(8) CONSTANT('01'X);/* JES3 ORIGINATED, SUPERLOCATE   85008500
*                                        REQUEST                     */ 85008600
*/********************************************************************/ 85008900
*/*                 PROBLEM  DETERMINATION  FIELDS                   */ 85009000
*/********************************************************************/ 85009300
*   DECLARE                                                             85012000
*     1 * DEF(CTGDDNM),             /* PROBLEM DETERMINATION @Y30SSJG*/ 85013000
*       2 CTGPROB CHAR(4),          /* PROBLEM DETERMINATION @Y30SSJG*/ 85014000
*         3 CTGMODID CHAR(2),       /* MODULE IDENTIFICATION @Y30SSJG*/ 85015000
*         3 CTGREASN CHAR(2),       /* REASON CODE           @Y30SSJG*/ 85016000
*           4 CTGREAS1 CHAR(1),     /* HIGH ORDER BYTE ZERO  @Y30SSJG*/ 85017000
*           4 CTGREAS2 CHAR(1);     /* REASON CODE LOW BYTE  @Y30SSJG*/ 85018000
* %GOTO CTGPLX02;                                                   /*  85050000
.CTGPL01 ANOP                                                           85100000
*                                                                       85150000
CTGPL    DS    0H                                                       85250000
*                                                                       85260000
CTGOPTN1 DS    XL1                      FIRST OPTION INDICATOR          85300000
CTGBYPSS EQU   X'80'                    BYPASS                          85350000
CTGMAST  EQU   X'40'                    VERIFY MASTER PASSWORD          85400000
CTGCI    EQU   X'20'                    VERIFY CONTROL INDICATOR        85450000
CTGUPD   EQU   X'10'                    VERIFY UPDATE                   85500000
CTGREAD  EQU   X'08'                    VERIFY READ                     85550000
CTGNAME  EQU   X'04'                    1 - 44-BYTE NAME OR VOLSER      85600000
*                                       0 - ENTRY ID NUMBER             85650000
CTGCNAME EQU   X'02'                    1 - 44-BYTE NAME                85700000
*                                       0 - ACB ADDRESS                 85750000
CTGGENLD EQU   X'01'                    GENERIC LOCATE REQUEST          85800000
*                                                                       85850000
CTGOPTN2 DS    XL1                      SECOND OPTION INDICATOR         85900000
CTGEXT   EQU   X'80'                    EXTEND(UPDATE)                  85950000
CTGERASE EQU   X'40'                    ERASE(DELETE)                   86000000
CTGSMF   EQU   X'40'                    WRITE SMF(LSPACE)               86050000
CTGREL   EQU   X'40'                    RELEASE(UPDATE)                 86100000
CTGGTALL EQU   X'40'                    CONCAT SEARCH (LISTCAT) Y02020  86150000
CTGPURG  EQU   X'20'                    PURGE (DELETE)                  86200000
CTGVMNT  EQU   X'20'                    VOLUME MOUNT CALLER             86250000
CTGRCATN EQU   X'20'                    RTN CAT NAME(GLOC)      Y02020  86300000
CTGGTNXT EQU   X'10'                    GET NEXT (LIST CTLG)            86350000
CTGDISC  EQU   X'08'                    DISCONNECT (DELETE)             86400000
CTGOVRID EQU   X'04'                    ERASE OVERRIDE (DELETE)         86450000
CTGSCR   EQU   X'02'                    SCRATCH SPACE (DELETE)          86500000
*    X'01' - RESERVED                                                   86550000
*                                                                       86600000
CTGOPTN3 DS    XL1                      THIRD OPTION INDICATOR          86650000
CTGFUNC  EQU   X'E0'                    HIGH ORDER THREE BITS DEFINE    86700000
*                                       FUNCTION                        86710000
*   LOCATE     -   001* ****                                            86760000
CTGLOC   EQU   X'20'                    LOCATE - BITS ON                86800000
*   LSPACE     -   010* ****                                            86900000
CTGLSP   EQU   X'40'                    LSPACE - BITS ON                86910000
*   UPDATE     -   011* ****                                            86950000
CTGUPDAT EQU   X'60'                    UPDATE - BITS ON                86960000
*   CMS FUNCTION - 100* ****                                            87000000
CTGCMS   EQU   X'80'                    CMS FUNCTION - BITS ON          87050000
*                                                                       87150000
CTGSUPLT EQU   X'10'                    SUPER LOCATE                    87200000
CTGGDGL  EQU   X'08'                    GDG LOCATE FUNCTION (CTGWAGB IN 87250000
*                                       CTGWA)                          87300000
CTGSRH   EQU   X'04'                    0 - SEARCH MASTER CAT ONLY      87350000
*                                       1 - SEARCH OS CAT FIRST         87400000
CTGNUM   EQU   X'02'                    0 - SEARCH BOTH CATALOGS        87450000
*                                       1 - SEARCH ONE CATALOG          87500000
CTGAM0   EQU   X'01'                    VSAM REQ VERSUS NONVSAM         87550000
*                                                                       87600000
CTGOPTN4 DS    XL1                      FOURTH OPTION INDICATOR  Y02020 87650000
CTGLBASE EQU   X'80'                    LOCATE GDG BASE ONLY            87750000
CTGDOCAT EQU   X'40'                    DO NOT OPEN NEEDED CATLG        87800000
CTGNPROF EQU   X'20'                    NO (RAC) PROFILE SHOULD BE      87810000
*                                       DEFINED OR DELETED     @Z40RSRC 87820000
CTGCOIN  EQU   X'10'                    CONTROLLER INTERCEPT REQUESTED  87860000
*                                                              @ZA20773 87870000
CTGBYPMT EQU   X'08'                    BYPASS SECURITY PROMPTING TO    87880000
*                                       SYSTEM OPERATOR        @ZA07531 87890000
CTGTIOT  EQU   X'04'                    CALLER OWNS SYSZTIOT EXCLUSIVE  87900000
*                                                              @ZA20773 87910000
*        BITS 7-8 RESERVED                                     @ZA20773 87920000
CTGENT   DS    0A                       USER ENTRY ADDRESS OR POINTER   87950000
*                                       TO VOLUME SERIAL NUMBER(LSPACE) 88000000
CTGFVT   DS    A                        FVT ADDRESS (DEFINE, ALTER)     88050000
CTGCAT   DS    0A                       CATALOG POINTER                 88100000
*                                                                       88110000
CTGCVOL  DS    A                        CVOL PTR (SUPER LOCATE)         88150000
*                                                                       88160000
CTGWKA   DS    A                        WORKAREA ADDRESS                88200000
*                                                                       88210000
CTGDSORG DS    CL2                      DATA SET ORG (SUPER LOCATE)     88250000
*   BITS 0-4 DEFINE ORGANIZATION                                        88300000
CTGOPTNS EQU   X'F8'                    TOP 5 BITS                      88310000
*   DEFINE          - 0000 1*** **** ****                               88350000
CTGDEFIN EQU   X'08'                    DEFINE                          88360000
*   ALTER           - 0001 0*** **** ****                               88400000
CTGALTER EQU   X'10'                    ALTER                           88410000
*   DELETE          - 0001 1*** **** ****                               88450000
CTGDELET EQU   X'18'                    DELETE                          88460000
*   LIST CATALOG    - 0010 0*** **** ****                               88500000
CTGLTCAT EQU   X'20'                    LIST CATALOG                    88550000
*   CONVERTV        - 0011 0*** **** ****                               88600000
CTGCNVTV EQU   X'30'                    CONVERTV                        88610000
*   BITS 6-16 RESERVED                                                  88650000
*                                                                       88700000
CTGTYPE  DS    CL1                      ENTRY TYPE-LISTCAT,DELETE       88750000
CTGTDATA EQU   C'D'                     DATA - D                        88800000
CTGTINDX EQU   C'I'                     INDEX - I                       88850000
CTGTALIN EQU   C'A'                     ALIEN - A                       88900000
CTGTUCAT EQU   C'U'                     USER CATALOG - U                88950000
CTGTVOL  EQU   C'V'                     VOLUME - V                      89000000
CTGTCL   EQU   C'C'                     CLUSTER - C                     89050000
CTGTMCAT EQU   C'M'                     MASTER CATALOG - M              89100000
CTGTGBS  EQU   C'B'                     GDG BASE - B                    89150000
CTGTANM  EQU   C'X'                     ALIAS BASE -X                   89200000
CTGTPGSP EQU   C'P'                     PAGE SPACE - P                  89250000
CTGTJES3 EQU   X'01'                    JES3 SUPERLOCATE REQUEST        89270000
*                                                                       89300000
CTGNOFLD DS    XL1                      NUMBER FIELD POINTERS           89350000
CTGDDNM  DS    0A                       DD NAME ADDRESS                 89400000
CTGNEWNM DS    0A                       NEWNAME ADDRESS - ALTER         89450000
CTGFDBK  DS    XL2                      SUPER LOCATE FEEDBACK           89500000
CTGFBFLG DS    0XL2                     SUPER LOCATE FLAGS              89550000
CTGREAS1 DS    XL1                      HIGH ORDER BYTE ZERO            89560000
CTGPAR   EQU   X'80'                    PARALLEL MOUNT - SUPER LOC      89600000
CTGKEEP  EQU   X'40'                    FORCED KEEP = SUPER LOCATE      89650000
CTGGDGB  EQU   X'20'                    GDG BASE LOCATED                89700000
CTGNGDSN EQU   X'10'                    GDG NAME GENERATED              89750000
CTGCLV   EQU   X'08'                    CANDIDATE VOLUME LIST  @ZA76423 89770000
*        6-8  RESERVED                                         @ZA76423 89790000
CTGREAS2 DS    XL1                      REASON CODE LOW BYTE            89810000
*                                                                       89850000
CTGJSCB  DS    0A                       JSCB ADDRESS                    89900000
CTGPSWD  DS    A                        PASSWORD ADDRESS                89950000
CTGFIELD DS    A                        FIELD POINTERS - MAY BE MORE    90000000
*                                       THAN ONE                        90050000
CTGPLLEN EQU   *-CTGPL                  LENGTH OF CTG WITH ONE FIELD    90100000
*                                       POINTER                         90150000
         MEND                                                           90200000
* */ %CTGPLX02:;                                                        90250000
//*
//*  Installs RAKF.PTFS
//*
//STEP1   EXEC PGM=PDSLOAD,PARM='UPDTE(><)'
//STEPLIB  DD  DSN=SYSC.LINKLIB,DISP=SHR
//SYSPRINT DD  SYSOUT=*
//SYSUT2   DD  DSN=SYSGEN.RAKF.PTFS,DISP=(NEW,CATLG),
//             VOL=SER=PUB000,
//             UNIT=3380,SPACE=(TRK,(7,5,17)),
//             DCB=(RECFM=FB,LRECL=80,BLKSIZE=19040)
//SYSUT1   DD  DATA,DLM=@@
./ ADD NAME=RRKF001  0201-11111-11111-1415-00051-00051-00000-PTF     32
++PTF(RRKF001) /*
 Enhancements and Fixes to RAKFUSER and RAKFPROF */ .
++VER(Z038) FMID(TRKF120)
 /*
 + introduce change history to source members RAKFUSER and RAKFPROF
 + enable comment lines in RAKF users and profiles tables
 + consistently don't highlight error messages on MVS console
 + fix S378 abend after syntax/sequencing error in first line of UDATA
 + add missing DEQ for SECURITY,USERS
 */ .
++SRCUPD(RAKFPROF) .
><  CHANGE NAME=RAKFPROF,SSI=02010000
*                                                                   @01 00260301
*    Change History                                                 @01 00260601
*                                                                   @01 00260901
*    2011/04/03 TRKF120 base version                                @01 00261201
*    2011/04/18 RRKF001 introduce change history                    @01 00261501
*                       enable comment lines in UDATA and PDATA     @01 00261801
*                                                                   @01 00262101
********************************************************************@01 00262401
         CLI   CLASS,C'*'              Comment?                     @01 00493001
         BE    READLOOP                 read next record            @01 00497001
>< ENDUP
++SRCUPD(RAKFUSER) .
><  CHANGE NAME=RAKFUSER,SSI=02010000
*                                                                   @01 00220301
*    Change History                                                 @01 00220601
*                                                                   @01 00220901
*    2011/04/03 TRKF120 base version                                @01 00221201
*    2011/04/18 RRKF001 introduce change history                    @01 00221501
*                       enable comment lines in UDATA and PDATA     @01 00221801
*                       consistently don't specify msg descriptor   @01 00222101
*                       fix S378 after error in first line of UDATA @01 00222401
*                       add missing DEQ for SECURITY,USERS          @01 00222701
*                                                                   @01 00223001
********************************************************************@01 00223301
         ENQ    (SECURITY,USERS,E,,SYSTEM),RET=HAVE serialization   @01 00370000
         XR     R5,R5               initialize GM chain             @01 00395001
         CLI    USERID,C'*'         Comment?                        @01 00413001
         BE     READLOOP             read next record               @01 00417001
         BE     NEWGROUP             same USER, check for new group @01 00430000
         BNH    ABEND2               not in sort seq, tell about it @01 00435001
         DEQ   (SECURITY,USERS,,SYSTEM) release ENQ                 @01 01355001
ABEND100 WTO    'RAKFUIDS1  RCVT NOT PROPERLY INITIALIZED'          @01 01400000
         WTO    'RAKFUIDSX  ** PROGRAM TERMINATED **'               @01 01410000
ABEND2   WTO    'RAKFUIDS2  INPUT DATA INVALID OR OUT OF SEQ.'      @01 01440000
                                           '                        @01 01480000
         WTO    'RAKFUIDSX  ** PROGRAM TERMINATED **'               @01 01490000
ABEND300 WTO    'RAKFUIDS3  EMPTY INPUT FILE ?!?!'                  @01 01560000
         WTO    'RAKFUIDSX  ** PROGRAM TERMINATED **'               @01 01570000
>< ENDUP
./ ADD NAME=RRKF002  0202-11118-11116-1800-00336-00336-00000-PTF     00
++PTF(RRKF002) /*
 Make RACINIT Password Changes permanent */ .
++VER(Z038) FMID(TRKF120) PRE(RRKF001)
 /*
 Summary of Changes:
 -------------------

 + Make RACINIT Password Changes permanent:

   Before application of this PTF a new password supplied as NEWPASS
   parameter of a RACINIT macro was updated in the in-core users table
   only and thus lived until the in-core table was replaced by the
   contents of the source users table at RAKF intialization time or by
   running RAKFUSER. Thus users were able to change their passwords
   only temporary. Permanent password changes required an RAKF
   administrator to edit the RAKF users table manually.

   This PTF changes processing of the NEWPASS parameter to queue the
   new password for update in the source users table in addition to
   updating the in-core users table. The password changes queue is
   applied during RAKFUSER processing to the source users table before
   the new in-core users table is created from the source table. This
   makes all password changes initiated by end users through using the
   password change facility of an application permanent and thus
   fully functional (for example changing the password at TSO logon
   time by entering currentpw/newpw at the "ENTER PASSWORD" prompt).

 + introduce change history to source member ICHSFR00

 Special Installation Instructions:
 ----------------------------------

 1. This PTF modifies elements that are not provided inline. These
    elements will be read during APPLY and ACCEPT processing from
    a PDS pointed to by ddname ELEMENTS. File RRKF002.elements.zip
    contains this PDS in XMIT370 format. Before the PTF can be APPLIed
    or ACCEPTed the PDS needs to be RECEIVed with an arbitrary name and
    a //ELEMENTS DD DSN=.... statement pointing to the PDS needs to
    be added to the SMP jobs used for APPLYing or ACCEPTing PTFs. After
    the PTF has been APPLIed (and ACCEPTed if desired) the PDS can be
    deleted and the //ELEMENTS DD statement can be removed from the
    SMP jobs.

    The following steps can be used to RECEIVE the PDS from file
    RRKF002.elements.zip:

    o Unzip rrkf002.elements.xmi from RRKF002.elements.zip and upload
      it to dataset RAKF.RRKF002.ELEMENTS.XMI (LRECL=80,RECFM=FB) on
      your MVS system using your standard unzip utility and upload
      software.

    o Submit the following job (requires the RECV370 utility to be
      installed, of course):

      //RCVELEMS JOB ...
      //RECV370  EXEC PGM=RECV370
      //RECVLOG   DD SYSOUT=*
      //XMITIN    DD DSN=RAKF.RRKF002.ELEMENTS.XMI,DISP=SHR
      //SYSPRINT  DD SYSOUT=*
      //SYSUT1    DD DSN=&&SYSUT1,
      //             UNIT=SYSDA,
      //             SPACE=(CYL,(10,5)),
      //             DISP=(,DELETE,DELETE)
      //SYSUT2    DD DSN=RAKF.RRKF002.ELEMENTS,
      //             DISP=(,CATLG),SPACE=(TRK,(6,2,1),RLSE),
      //             DCB=(LRECL=80,BLKSIZE=5600,RECFM=FB),
      //             UNIT=SYSDA
      //SYSIN     DD DUMMY
      //SYSUDUMP  DD SYSOUT=*

    The dataset names used in this example can be changed to anything
    you like as long as the //ELEMENT DD statement in the SMP APPLY
    and ACCEPT jobs points to the dataset created by //SYSUT2 DD of
    the RCVELEMS job.

 2. RECEIVE and APPLY the PTF as usual. Don't IPL the system!

 3. Perform step 1. b) from member $$$$CUST in HLQ.SAMPLIB (HLQ = high
    level qualifier of the RAKF libraries) to define the RAKF
    password changes queue dataset.

 4. Perform step 4 from member $$$$CUST in HLQ.SAMPLIB to add the RAKF
    password changes queue dataset DD statement to MSTRJCL. The sample
    usermod ZJW0003 provided in HLQ.SAMPLIB has been adapted by this
    PTF and can be rerun without changes if the original version had
    been used at RAKF installation time.

 5. IPL the system using the CLPA option.

 6. ACCEPT the PTF according to your preferences after sufficient
    testing.
 */ .
++JCLIN .
//RRKF002  JOB 1,'RAKF 1.2',MSGLEVEL=1,CLASS=A
//*
//* JCLIN for RAKF 1.2 PTF RRKF002
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
//RAKFUSER EXEC  PGM=IEWL,PARM='MAP,LIST,LET,NCAL,AC=1'
//SYSLMOD  DD  DISP=SHR,DSN=SYS1.LINKLIB
//SYSPUNCH DD  DISP=(OLD,PASS),DSN=&&OBJ
//SYSLIN   DD  *
 INCLUDE SYSPUNCH(RAKFUSER)
 INCLUDE SYSPUNCH(RAKFPSAV)
 ENTRY   CJYRUIDS
 NAME    RAKFUSER(R)
/*
++SRCUPD(ICHSFR00) .
><  CHANGE NAME=ICHSFR00,SSI=02020000
*                                                                   @02 00220302
*    Change History                                                 @02 00220502
*                                                                   @02 00220702
*    2011/04/03 TRKF120 base version                                @02 00222002
*    2011/04/26 RRKF002 introduce change history                    @02 00222302
*                       enable end users to change their passwords  @02 00222502
*                       permanently: store user's password change   @02 00222702
*                       request in fetch protected CSA and pass the @02 00224002
*                       request address to RAKFPWUP which queues it @02 00224302
*                       for replacement in the RAKF users table     @02 00224502
*                       at next run of RAKFUSER                     @02 00224702
*                                                                   @02 00226002
********************************************************************@02 00226302
         GETMAIN RU,LV=PWUPL,SP=227 get fetch protected CSA         @02 03702002
         MVC   0(PWUPCMDL,R1),PWUPSTRT move SVC 34 plist to CSA area@02 03704002
         L     R3,PWUPXTBA         get translate table address      @02 03706002
         USING PWUPSTRT,R1         address CSA area now             @02 03708002
         ST    R1,PWUPADDR         store CSA area address for unpack@02 03710000
         UNPK  PWUPUNPK(9),PWUPADDR(5) unpack CSA area address      @02 03712002
         MVC   PWUPAHEX(8),PWUPUNPK unpacked address to SVC 34 plist@02 03714002
         TR    PWUPAHEX(8),0(R3)   translate address to printable   @02 03716002
         DROP  R1                  revert to standard addressability@02 03718002
         MVC   PWUPCMDL(PWUPRECL,R1),PWUP initialize change record  @02 03720000
         IC    R3,0(,R5)           length of user                   @02 03722002
         BCTR  R3,0                subtract 1 for MVC               @02 03724002
         EX    R3,PWUPMVCU         copy user                        @02 03726002
         IC    R3,WORKPASS         length of new password           @02 03728002
         BCTR  R3,0                subtract 1 for MVC               @02 03730000
         EX    R3,PWUPMVCP         copy new password                @02 03732002
         XR    R0,R0               set R0 = 0 for SVC 34            @02 03734002
         SVC   34                  S RAKFPWUP,PARM='PWUPAHEX'       @02 03736002
         XC    WORKPASS+1(8),=C'SECURITY' encrypt                       03740000
         IC    R1,WORKPASS         length of new password               03750000
         EX    R1,RACIRPWD         replace password                     03760000
PWUPSTRT DC    AL2(PWUPCMDL)       parameter list to start RAKFPWUP>@02 03780000
         DC    X'0000'              >is copied to CSA subpool 227  >@02 03790000
         DC    C'S RAKFPWUP,PARM=''' >fetch protected storage with >@02 03790302
PWUPAHEX DS    CL8                  >address passed in PARM field  >@02 03790502
         DC    C''''                >in hexadecimal printable format@02 03790702
PWUPCMDL EQU   *-PWUPSTRT          length of parameter list         @02 03792002
PWUP     DS    0C                  changes queue record             @02 03792302
PWUPUSER DC    CL8' '              userid                           @02 03792502
         DC    C' '                filler                           @02 03792702
PWUPPSWD DC    CL8' '              new password                     @02 03794002
         DC    C' '                filler                           @02 03794302
PWUPRECL EQU   *-PWUP              record length of changes queue   @02 03794502
PWUPL    EQU   *-PWUPSTRT          total length of CSA area         @02 03794702
         ORG   PWUP                changes queue record is >        @02 03796002
PWUPADDR DS    F                      > temporarily used   >        @02 03796302
         DS    X                      > for conversion of  >        @02 03796502
PWUPUNPK DS    CL8                    > CSA area to        >        @02 03796702
         DS    X                      > unpacked format             @02 03798002
         ORG   PWUP+PWUPRECL       restore program counter          @02 03798302
         USING PWUPSTRT,R1         address CSA area now             @02 03798502
PWUPMVCU MVC   PWUPUSER(1),1(R5)   get user and new password >      @02 03798702
PWUPMVCP MVC   PWUPPSWD(1),WORKPASS+1  > into change queue record   @02 03799002
         DROP  R1                  revert to standard addressability@02 03799302
*                                  spaceholder blanks removed       @02 08000000
         DC    CL23' '             rest of spaceholder blanks       @02 08010000
PWUPHXTB DC    C'0123456789ABCDEF' translate RAKFPWUP address to >  @02 08020000
PWUPXTBA DC    A(PWUPHXTB-240)      > hex printable format          @02 08030000
>< ENDUP
++SRCUPD(RAKFPWUP) .
><  CHANGE NAME=RAKFPWUP,SSI=02020000
         PRINT NOGEN                                                    00030000
*                                                                       00040000
**********************************************************************  00050000
*                                                                    *  00060000
* NAME: RAKFPWUP                                                     *  00070000
*                                                                    *  00080000
* TYPE: Assembler Source                                             *  00090000
*                                                                    *  00100000
* DESC: Process Password Update Requests                             *  00110000
*                                                                    *  00120000
* FUNCTION: - retrieve username and new password from CSA area       *  00130000
*             allocated by ICHSFR00 in subpool 227 (fetch protected) *  00140000
*           - clear and free CSA area                                *  00150000
*           - append username and new password to the RAKF password  *  00160000
*             change queue, a sequential dataset with LRECL=18,      *  00170000
*             RECFM=F containing one line per password change in the *  00180000
*             following format:                                      *  00190000
*                                                                    *  00200000
*             ----+----1----+---                                     *  00210000
*             uuuuuuuu pppppppp                                      *  00220000
*                                                                    *  00230000
*             where uuuuuuuu is the username and pppppppp is the new *  00240000
*             password, each padded to the right with blanks to 8    *  00250000
*             characters.                                            *  00260000
*                                                                    *  00270000
* REQUIREMENTS: - RAKF password change queue pointed to by ddname    *  00280000
*                 RAKFPWUP using DISP=MOD in the DD statement.       *  00290000
*                                                                    *  00300000
**********************************************************************  00310000
*                                                                       00320000
* initialize                                                            00330000
*                                                                       00340000
         SAVE  (14,12),,RAKFPWUP_&SYSDATE._&SYSTIME                     00350000
         USING RAKFPWUP,R15        establish => program EP              00360000
         ST    R13,SAVEAREA+4      save HSA                             00370000
         LA    R11,SAVEAREA        establish => savearea                00380000
         ST    R11,8(R13)          save LSA                             00390000
         LR    R13,R11             setup => our savearea                00400000
         USING SAVEAREA,R13        new addressability                   00410000
         DROP  R15                 program EP no longer needed          00420000
         B     CONTINUE            branch around savearea               00430000
SAVEAREA DS    18F                 savearea                             00440000
*                                                                       00450000
* Begin of code                                                         00460000
*                                                                       00470000
CONTINUE LR    R5,R1               remember PARM plist address          00480000
         MODESET MODE=SUP,KEY=ZERO authorize ourselves                  00490000
         L     R1,0(,R5)           address of PARM field plist          00500000
         LH    R5,0(,R1)           length of PARM field                 00510000
         CH    R5,=H'8'            is PARM field length 8 characters?   00520000
         BNE   INVPARM              talk dirrty and exit if not         00530000
         MVC   ADDRHEX,2(R1)       get PARM field in check plist        00540000
         MVC   ADDRUNPK,2(R1)      get PARM field for translate         00550000
         TR    ADDRUNPK,HEXTBL     translate PARM field to zoned        00560000
         PACK  ADDRESS(5),ADDRUNPK(9) pack PARM field                   00570000
         L     R1,ADDRESS          address storage pointed to by PARM   00580000
         CLC   0(LPWUPCMD,R1),STRTPWUP parmlist from ICHSFR00 found?    00590000
         BNE   INVPARM              talk dirrty and exit if not         00600000
         MVC   PWUPUSER(8),PWUPUSER-STRTPWUP(R1) get user               00610000
         MVC   PWUPPSWD(8),PWUPPSWD-STRTPWUP(R1) get new password       00620000
         XC    0(LPWUP,R1),0(R1)   clear ICHSFR00 parmlist storage      00630000
         FREEMAIN RU,LV=LPWUP,A=ADDRESS,SP=227 free parmlist storage    00640000
         ENQ    (SECURITY,USERS,E,,SYSTEM),RET=HAVE serialization       00650000
         OPEN  (QUEUE,(OUTPUT))    open password change queue           00660000
         PUT   QUEUE,PWUP          write entry                          00670000
         CLOSE (QUEUE)             close password change queue          00680000
         DEQ   (SECURITY,USERS,,SYSTEM) release ENQ                     00690000
         MVC   SUCCESS+38(8),PWUPUSER move user into success message    00700000
         WTO   MF=(E,SUCCESS)      tell operator                        00710000
*                                                                       00720000
* return                                                                00730000
*                                                                       00740000
RETURN   MODESET MODE=PROB,KEY=NZERO return to problem state            00750000
         L     R13,SAVEAREA+4      get caller's savearea                00760000
         RETURN (14,12),,RC=0      return                               00770000
INVPARM  WTO   'RAKF006W invalid password update request ignored'       00780000
         B     RETURN                                                   00790000
*                                                                       00800000
* data area                                                             00810000
*                                                                       00820000
STRTPWUP DC    AL2(LPWUPCMD)       parameter list that must have been.. 00830000
         DC    X'0000'               .. used to start this RAKFPWUP ..  00840000
         DC    C'S RAKFPWUP,PARM=''' .. run. This is used to perform .. 00850000
ADDRHEX  DS    CL8                   .. a validity check of the CSA ..  00860000
         DC    C''''                 .. storage addressed through ..    00870000
LPWUPCMD EQU   *-STRTPWUP            .. the PARM field                  00880000
PWUP     DS    0C                  changes queue record                 00890000
PWUPUSER DC    CL8' '              userid                               00900000
         DC    C' '                filler                               00910000
PWUPPSWD DC    CL8' '              new password                         00920000
         DC    C' '                filler                               00930000
CHGLRECL EQU   *-PWUP              record length of changes queue       00940000
LPWUP    EQU   *-STRTPWUP          total length of CSA area             00950000
ADDRUNPK DS    CL8                 unpacked address                     00960000
         DC    X'C0'               sign and dummy digit                 00970000
ADDRESS  DS    F                   packed address                       00980000
         DS    X                   dummy digit and sign after pack      00990000
SECURITY DC     CL8'CJYRCVT'       resource name for ENQ                01000000
USERS    DC     CL8'CJYUSRS'       resource name for ENQ                01010000
QUEUE    DCB   DDNAME=RAKFPWUP,MACRF=PM,DSORG=PS password change queue  01020000
SUCCESS  WTO   'RAKF007I password update for user UUUUUUUU queued',MF=L 01030000
*                 0 1 2 3 4 5 6 7 8 9 A B C D E F                       01040000
HEXTBL   DC    X'00000000000000000000000000000000' 0                    01050000
         DC    X'00000000000000000000000000000000' 1                    01060000
         DC    X'00000000000000000000000000000000' 2                    01070000
         DC    X'00000000000000000000000000000000' 3                    01080000
         DC    X'00000000000000000000000000000000' 4                    01090000
         DC    X'00000000000000000000000000000000' 5 translate table    01100000
         DC    X'00000000000000000000000000000000' 6 to convert CSA     01110000
         DC    X'00000000000000000000000000000000' 7 address from PARM  01120000
         DC    X'00000000000000000000000000000000' 8 field to zoned     01130000
         DC    X'00000000000000000000000000000000' 9 format             01140000
         DC    X'00000000000000000000000000000000' A                    01150000
         DC    X'00000000000000000000000000000000' B                    01160000
         DC    X'00FAFBFCFDFEFF000000000000000000' C                    01170000
         DC    X'00000000000000000000000000000000' D                    01180000
         DC    X'00000000000000000000000000000000' E                    01190000
         DC    X'F0F1F2F3F4F5F6F7F8F9000000000000' F                    01200000
*                                                                       01210000
* equates                                                               01220000
*                                                                       01230000
         YREGS                     register equates                     01240000
         END   RAKFPWUP            end of program                       01250000
>< ENDUP
++SRCUPD(RAKFUSER) .
><  CHANGE NAME=RAKFUSER,SSI=02020000
*    2011/04/26 RRKF002 enable end users to change their passwords  @02 00223001
*                       permanently: Before updating the incore     @02 00223301
*                       users table RAKFUSER calls RAKFPSAV to      @02 00223602
*                       update UDATA with the temporary password    @02 00223902
*                       changes queued since the previous execution @02 00224202
*                                                                   @02 00224502
********************************************************************@02 00224802
*                                                                   @02 00372002
         L      R15,RAKFPSAV        get password changer address    @02 00374002
         BALR   R14,R15             call it                         @02 00376002
*                                                                   @02 00378002
RAKFPSAV DC     V(RAKFPSAV)        password change utility          @02 01673002
*                                                                   @02 01677002
>< ENDUP
++MACUPD(RAKFPWUP) .
><  CHANGE NAME=RAKFPWUP,SSI=02020000
//RAKFPWUP  DD  DSN=SYS1.SECURE.PWUP,DISP=MOD                       @02 00020002
>< ENDUP
++MACUPD(RAKFUSER) .
><  CHANGE NAME=RAKFUSER,SSI=02020000
//RAKFPWUP DD DSN=SYS1.SECURE.PWUP,DISP=SHR                         @02 00030002
>< ENDUP
++SRC(RAKFPSAV) TXLIB(ELEMENTS) DISTLIB(ASRCLIB) SYSLIB(SRCLIB) .
++MAC($$$$CUST) TXLIB(ELEMENTS) .
++MAC(RAKFRMV)  TXLIB(ELEMENTS) .
++MAC(ZJW0003)  TXLIB(ELEMENTS) .
./ ADD NAME=RRKF003  0102-11123-11123-1056-00082-00082-00000-PTF     07
++PTF(RRKF003) /*
 Security Enhancement in Users and Profiles Tables Processing */ .
++VER(Z038) FMID(TRKF120) PRE(RRKF001,RRKF002)
 /*
 Summary of Changes:
 -------------------

 + Security Enhancement in Users and Profiles Tables Processing:

   The in-core users and profiles tables which control RAKF's access
   decisions are maintained by editing source versions of these tables
   and using the utilities RAKFUSER and RAKFPROF to replace the in-core
   tables with the current source tables to activate changes.

   Although typically access to the source tables will be restricted
   to users and/or groups responsible for security administration a
   malicious user could take over control of the security environment
   by creating private versions of the source tables and running
   RAKFUSER and RAKFPROF to replace the in-core tables from the private
   source. MVS 3.8j doesn't call the security product for access
   verification through the PROGRAM class before executing a program which
   would in later versions of MVS be the way to protect the utilities from
   unauthorized use.

   PTF RRKF003 introduces a request for READ access to profile RAKFADM
   in the FACILITY class before updating the in-core tables. To prevent
   unwanted accesses to the RAKFUSER or RAKFPROF utilities define profile
   RAKFADM in the FACILITY class with universal access NONE and grant
   only RAKF administration users or groups READ access to this profile.

 Special Installation Instructions:
 ----------------------------------

 None

 */ .
++SRCUPD(RAKFPROF) .
><  CHANGE NAME=RAKFPROF,SSI=02030000
*    2011/04/29 RRKF003 if in-core PDATA table already exists check @03 00262101
*                       for READ access to profile RAKFADM in the   @03 00262401
*                       FACILITY class to ensure that only properly @03 00262703
*                       authorized users can replace the in-core    @03 00263003
*                       PDATA table                                 @03 00263303
*                                                                   @03 00263603
********************************************************************@03 00263903
*                                                                   @03 00390303
         ICM    R5,B'0111',CJYPROFS-CJYRCVTD(R8) does PDATA exist?  @03 00390603
         BZ     OK2GO                   NO, go ahead                @03 00390903
         RACHECK ENTITY=RAKFADM,CLASS='FACILITY',ATTR=READ authorize@03 00391203
         LTR    R15,R15                RAKFADM granted?             @03 00391503
         BNZ    ABEND600                NO, abend                   @03 00391803
*                                                                   @03 02122003
ABEND600 WTO    'RAKF008W illegal operation -- access denied'       @03 02124003
         WTO    'RAKF008W   ** program terminated **'               @03 02126003
         ABEND  600,,STEP                                           @03 02128003
*                                                                   @03 02491003
RAKFADM  DC     CL39'RAKFADM'      facility name to authorize       @03 02495003
*                                                                   @03 02499003
>< ENDUP
++SRCUPD(RAKFUSER) .
><  CHANGE NAME=RAKFUSER,SSI=02030000
*    2011/04/29 RRKF003 if in-core UDATA table already exists check @03 00224502
*                       for READ access to profile RAKFADM in the   @03 00224802
*                       FACILITY class to ensure that only properly @03 00225103
*                       authorized users can replace the in-core    @03 00225403
*                       UDATA table                                 @03 00225703
*                                                                   @03 00226003
********************************************************************@03 00226303
*                                                                   @03 00360303
         ICM    R5,B'0111',CJYUSERS-CJYRCVTD(R8) does UDATA exist?  @03 00360603
         BZ     OK2GO                NO, go ahead                   @03 00360903
         RACHECK ENTITY=RAKFADM,CLASS='FACILITY',ATTR=READ authorize@03 00361203
         LTR    R15,R15             RAKFADM granted?                @03 00361503
         BNZ    ABEND600             NO, abend                      @03 00361803
*                                                                   @03 00362103
OK2GO    ENQ    (SECURITY,USERS,E,,SYSTEM),RET=HAVE serialization   @03 00370000
*                                                                   @03 01582003
ABEND600 WTO    'RAKF008W illegal operation -- access denied'       @03 01584003
         WTO    'RAKF008W   ** program terminated **'               @03 01586003
         ABEND  600,,STEP                                           @03 01588003
RAKFADM  DC     CL39'RAKFADM'      facility name to authorize       @03 01675003
>< ENDUP
./ ADD NAME=RRKF004  0204-11123-11123-1100-00149-00149-00000-PTF     00
++PTF(RRKF004) /*
 RAKF User's Guide */ .
++VER(Z038) FMID(TRKF120) PRE(RRKF001,RRKF002,RRKF003)
 /*
 Summary of Changes:
 -------------------

 + RAKF User's Guide:

   RAKF documention was widespread over 5 SAMPLIB members referencing
   each other: $$$$INST, $$$$CUST, $$$$M38J, $$$$RMVE and $$$$$DOC.
   This documentation had been written at different stages of the
   evolution from the ESG Security System to RAKF and became increasingly
   difficult to read as newer parts often invalidated parts of the
   older documentation. In addition the total amount of documentation
   materials exceeds the size that can be edited with reasonable effort
   in handcrafted text files with fixed length 80 byte records.

   With this PTF the documentation is republished as the "RAKF Version 1
   Release 2 Modifaction 0 User's Guide" which is available in two
   formats:

   o Microsoft Word 2010 .docx:        The source document ("original
                                       copy") and base for further
                                       evolutions.

   o Portable Document Format (PDF/A): Display and printer friendly
                                       format intended for reading or
                                       printing the document using
                                       publicly available no-cost
                                       software (Adobe Acrobat Reader).

   These two formats are made available as member $DOC$ZIP in SAMPLIB
   which is a zip archive containing the two files "Users_Guide.docx"
   and "Users_Guide.pdf". This member is intended to be downloaded in
   binary format to the user's PC using the 3270 terminal emulation's
   file transfer function (typically based on IND$FILE) or any other
   suitable method.

   Once downloaded, the User's Guide can be extracted in the desired
   format (.pdf or .docx) using the PC's standard unzip utility for
   reading or printing using Word, Acrobat Reader or other tools
   compatible with these formats.

   With the installation of this PTF the original documentation members
   $$$$INST, $$$$CUST, $$$$M38J and $$$$RMVE become obsolete and are
   deleted from SAMPLIB. Member $$$$$DOC, which is the original
   documentation of the ESG Security System prepared by Sam Golob in
   1991, is retained in SAMPLIB as a historical reference.

 Special Installation Instructions:
 ----------------------------------

 1. This PTF modifies elements that are not provided inline. These
    elements will be read during APPLY and ACCEPT processing from
    a PDS pointed to by ddname DOCLIB. File RRKF004.doclib.zip
    contains this PDS in XMIT370 format. Before the PTF can be APPLIed
    or ACCEPTed the PDS needs to be RECEIVed with an arbitrary name and
    a //DOCLIB DD DSN=.... statement pointing to the PDS needs to
    be added to the SMP jobs used for APPLYing or ACCEPTing PTFs. After
    the PTF has been APPLIed (and ACCEPTed if desired) the PDS can be
    deleted and the //DOCLIB DD statement can be removed from the
    SMP jobs.

    The following steps can be used to RECEIVE the PDS from file
    RRKF004.doclib.zip:

    o Unzip RRKF004.doclib.xmi from RRKF004.doclib.zip and upload
      it to dataset RAKF.RRKF004.DOCLIB.XMI (LRECL=80,RECFM=FB) on
      your MVS system using your standard unzip utility and upload
      software (use binary mode for upload!)

    o Submit the following job (requires the RECV370 utility to be
      installed, of course):

      //RCVDOCS  JOB ...
      //RECV370  EXEC PGM=RECV370
      //RECVLOG   DD SYSOUT=*
      //XMITIN    DD DSN=RAKF.RRKF004.DOCLIB.XMI,DISP=SHR
      //SYSPRINT  DD SYSOUT=*
      //SYSUT1    DD DSN=&&SYSUT1,
      //             UNIT=SYSDA,
      //             SPACE=(CYL,(10,5)),
      //             DISP=(,DELETE,DELETE)
      //SYSUT2    DD DSN=RAKF.RRKF004.DOCLIB,
      //             DISP=(,CATLG),SPACE=(TRK,(30,15,1),RLSE),
      //             DCB=(LRECL=80,BLKSIZE=5600,RECFM=FB),
      //             UNIT=SYSDA
      //SYSIN     DD DUMMY
      //SYSUDUMP  DD SYSOUT=*

    The dataset names used in this example can be changed to anything
    you like as long as the //DOCLIB DD statement in the SMP APPLY
    and ACCEPT jobs points to the dataset created by //SYSUT2 DD of
    the RCVDOCS job.

 2. RECEIVE, APPLY and ACCEPT the PTF as usual.

 */ .
++MAC($$$$INFO) SSI(02040000) .
*
*    See members $$COPYRT and $$NOTICE in this library.
*
**********************************************************************
*                                                                    *
*    RAKF is based on the ESG Security System                        *
*    written by Craig J. Yasuna               (Mar 1991)             *
*    adapted to MVS 3.8J: A. Philip Dickinson (Aug 2005)             *
*                         Phil Roberts        (Apr 2011)             *
*                         Juergen Winkelmann  (Apr 2011)             *
*                                                                    *
**********************************************************************
*
*    Member $$$$$DOC in this library is the original documentation of
*    the ESG Security System as prepared by Sam Golob in 1991. It is
*    retained here as a historic reference although it is no longer
*    current in some aspects due to the changes introduced by RAKF to
*    achieve MVS 3.8j compatibility.
*
*    The current RAKF documentation is the "RAKF Version 1 Release 2
*    Modifaction 0 User's Guide" which is available in two formats:
*
*    o Microsoft Word 2010 .docx:        The source document ("original
*                                        copy") and base for further
*                                        evolutions.
*
*    o Portable Document Format (PDF/A): Display and printer friendly
*                                        format intended for reading or
*                                        printing the document using
*                                        publicly available no-cost
*                                        software (Adobe Acrobat Reader).
*
*    These two formats are available as member $DOC$ZIP in this library
*    which is a zip archive containing the two files "Users_Guide.docx"
*    and "Users_Guide.pdf". This member is intended to be downloaded in
*    binary format to the user's PC using the 3270 terminal emulation's
*    file transfer function (typically based on IND$FILE) or any other
*    suitable method.
*
*    Once downloaded, the User's Guide can be extracted in the desired
*    format (.pdf or .docx) using the PC's standard unzip utility for
*    reading or printing using Word, Acrobat Reader or other tools
*    compatible with these formats.
*
++MAC($DOC$ZIP) TXLIB(DOCLIB) DISTLIB(ASAMPLIB) SYSLIB(SAMPLIB) .
++MAC($$$$CUST) DELETE .
++MAC($$$$INST) DELETE .
++MAC($$$$M38J) DELETE .
++MAC($$$$RMVE) DELETE .
./ ADD NAME=RRKF005  0205-11131-11130-2115-00140-00140-00000-PTF     00
++PTF(RRKF005) /*
 RACIND Utility to control VSAM RACF Indicators */ .
++VER(Z038) FMID(TRKF120) PRE(RRKF001,RRKF002,RRKF003,RRKF004)
 /*
 Summary of Changes:
 -------------------

 + RACIND Utility to control VSAM RACF Indicators

   This PTF adds a new utility named RACIND to RAKF. RACIND allows
   to switch the RACF indicator of any VSAM catalog entry on or off,
   thus enabling easy indication and unindication of the system's VSAM
   catalogs and objects.

   SAMPLIB member RACIND is a sample job stream illustrating the use
   of the RACIND utility.

 Special Installation Instructions:
 ----------------------------------

 1. This PTF adds elements that are not provided inline. These
    elements will be read during APPLY and ACCEPT processing from
    a PDS pointed to by ddname RACIND. File RRKF005.racind.zip
    contains this PDS in XMIT370 format. Before the PTF can be APPLIed
    or ACCEPTed the PDS needs to be RECEIVed with an arbitrary name and
    a //RACIND DD DSN=.... statement pointing to the PDS needs to
    be added to the SMP jobs used for APPLYing or ACCEPTing PTFs. After
    the PTF has been APPLIed (and ACCEPTed if desired) the PDS can be
    deleted and the //RACIND DD statement can be removed from the
    SMP jobs.

    The following steps can be used to RECEIVE the PDS from file
    RRKF005.racind.zip:

    o Unzip RRKF005.RACIND.XMI from RRKF005.racind.zip and upload
      it to dataset RAKF.RRKF005.RACIND.XMI (LRECL=80,RECFM=FB) on
      your MVS system using your standard unzip utility and upload
      software.

    o Submit the following job (requires the RECV370 utility to be
      installed, of course):

      //RCVIND   JOB ...
      //RECV370  EXEC PGM=RECV370
      //RECVLOG   DD SYSOUT=*
      //XMITIN    DD DSN=RAKF.RRKF005.RACIND.XMI,DISP=SHR
      //SYSPRINT  DD SYSOUT=*
      //SYSUT1    DD DSN=&&SYSUT1,
      //             UNIT=SYSDA,
      //             SPACE=(CYL,(10,5)),
      //             DISP=(,DELETE,DELETE)
      //SYSUT2    DD DSN=RAKF.RRKF005.RACIND,
      //             DISP=(,CATLG),SPACE=(TRK,(6,3,1),RLSE),
      //             DCB=(LRECL=80,BLKSIZE=5600,RECFM=FB),
      //             UNIT=SYSDA
      //SYSIN     DD DUMMY
      //SYSUDUMP  DD SYSOUT=*

    The dataset names used in this example can be changed to anything
    you like as long as the //RACIND DD statement in the SMP APPLY
    and ACCEPT jobs points to the dataset created by //SYSUT2 DD of
    the RCVIND job.

 2. RECEIVE and APPLY the PTF as usual.

 3. ACCEPT the PTF according to your preferences after sufficient
    testing.
 */ .
++JCLIN .
//RRKF005  JOB 1,'RAKF 1.2',MSGLEVEL=1,CLASS=A
//*
//* JCLIN for RAKF 1.2 PTF RRKF005
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
++SRC(RACIND)   TXLIB(RACIND) DISTLIB(ASRCLIB)  SYSLIB(SRCLIB)  .
++MAC(IEZCTGFL) TXLIB(RACIND) DISTLIB(AMACLIB)  SYSLIB(MACLIB)  .
++MAC(RAKFRMV)  TXLIB(RACIND) .
++MAC(RACIND)   SSI(02050000) DISTLIB(ASAMPLIB) SYSLIB(SAMPLIB) .
//RACIND   JOB
//********************************************************************
//*
//* Name: RACIND
//*
//* Desc: Run RACIND Utility
//*
//* FUNTION: Act upon control statements read from SYSIN to set or
//*          clear the RACF indicator of VSAM catalog entries. The
//*          following control statements are valid:
//*
//*          ----+----1----+----2----+----3----+----4----+----5----+
//*          CATALOG   name of catalog to search for entries
//*          RACON     name of entry to indicate
//*          RACOFF    name of entry to unindicate
//*          * Comment
//*
//*          Any number of control statements is allowed. The first
//*          none comment statement must be a CATALOG statement. A
//*          CATALOG statement remains active until a new CATALOG
//*          statement replaces it.
//*
//********************************************************************
//RACIND  EXEC PGM=RACIND
//SYSPRINT DD  SYSOUT=*
//SYSIN    DD  *
**********************************************************************
*
* Example: Switch on the RACF indicator for a VSAM catalog
*          and a cluster contained in that catalog.
*
* Note:    - The data and index components of a VSAM catalog
*            MUST NOT be RACF indicated.
*
*          - All other entry types MUST have either all of their
*            components RACF indicated or all components not
*            indicated.
*
*          For that reason in the example only one RACON statement
*          is coded for the catalog, but three for the cluster.
*
**********************************************************************
CATALOG   SYS1.UCAT.TST
RACON     SYS1.UCAT.TST
RACON     TSTCAT.CLUSTER
RACON     TSTCAT.CLUSTER.INDEX
RACON     TSTCAT.CLUSTER.DATA
/*
//
./ ADD NAME=RRKF006  0206-11171-11171-1423-00115-00115-00000-PTF     00
++PTF(RRKF006) /*
 Sample jobs to RACF indicate or unindicate the whole system */ .
++VER(Z038) FMID(TRKF120) PRE(RRKF001,RRKF002,RRKF003,RRKF004,RRKF005)
 /*
 Summary of Changes:
 -------------------

 + Sample jobs to RACF indicate or unindicate the whole system

   These jobs provide a fully automated way to set or clear the RACF
   indicators of all eligible datasets, VSAM objects and catalogs in
   the system.

 + OCO distribution of RAKF-external utilities

   The sample jobs for RACF indication or unindication need some
   utilities from other sources than RAKF. To ease installation of
   these utilities they are collected to an XMI file containing the
   modules needed and a sample job to install them from this XMI file
   is provided. The User's Guide describes the procedure to install
   these utilities as well as the original source from which they
   were derived.

 + Sample jobs for creation of SYS1.SECURE.CNTL and SYS1.SECURE.PWUP

   These jobs are provided to help with the initial customization
   tasks on systems not having interactive dataset allocation and
   or move/copy utilities available.

 + add missing //RAKFPWUP DD statement to the RAKF cataloged procedure

 + update the RAKF User's Guide with changes introduced since RRKF004

 Special Installation Instructions:
 ----------------------------------

 1. Due to the large amount of new sample and documentation material
    the space allocation of hlq.SAMPLIB and hlq.ASAMPLIB needs to be
    enlarged to avoid space related abends during installation of this
    PTF. Please reallocate these libraries to meet the following
    definitions (calculation based on 3350 type DASD):

    //ASAMPLIB DD  DISP=(,CATLG),DSN=hlq.ASAMPLIB,VOL=SER=dddddd,
    //             UNIT=SYSDA,DCB=(RECFM=FB,LRECL=80,BLKSIZE=19040),
    //             SPACE=(TRK,(120,40,10))
    //SAMPLIB  DD  DISP=(,CATLG),DSN=hlq.SAMPLIB,VOL=SER=ssssss,
    //             UNIT=SYSDA,DCB=(RECFM=FB,LRECL=80,BLKSIZE=19040),
    //             SPACE=(TRK,(120,40,10))

    Of course, the original contents needs to be copied into the
    newly allocated libraries!

 2. This PTF adds elements that are not provided inline. These
    elements will be read during APPLY and ACCEPT processing from
    a PDS pointed to by ddname RRKF006E. File RRKF006E.zip
    contains this PDS in XMIT370 format. Before the PTF can be APPLIed
    or ACCEPTed the PDS needs to be RECEIVed with an arbitrary name and
    an //RRKF006E DD DSN=.... statement pointing to the PDS needs to
    be added to the SMP jobs used for APPLYing or ACCEPTing PTFs. After
    the PTF has been APPLIed (and ACCEPTed if desired) the PDS can be
    deleted and the //RRKF006E DD statement can be removed from the
    SMP jobs.

    The following steps can be used to RECEIVE the PDS from file
    RRKF006E.zip:

    o Unzip RRKF006E.XMI from RRKF006E.zip and upload
      it to dataset RAKF.RRKF006E.XMI (LRECL=80,RECFM=FB) on
      your MVS system using your standard unzip utility and upload
      software.

    o Submit the following job (requires the RECV370 utility to be
      installed, of course):

      //RCVTLIB  JOB ...
      //RECV370  EXEC PGM=RECV370
      //RECVLOG   DD SYSOUT=*
      //XMITIN    DD DSN=RAKF.RRKF006E.XMI,DISP=SHR
      //SYSPRINT  DD SYSOUT=*
      //SYSUT1    DD DSN=&&SYSUT1,
      //             UNIT=SYSDA,
      //             SPACE=(CYL,(10,5)),
      //             DISP=(,DELETE,DELETE)
      //SYSUT2    DD DSN=RAKF.RRKF006E,
      //             DISP=(,CATLG),SPACE=(TRK,(6,3,1),RLSE),
      //             DCB=(LRECL=80,BLKSIZE=5600,RECFM=FB),
      //             UNIT=SYSDA
      //SYSIN     DD DUMMY
      //SYSUDUMP  DD SYSOUT=*

    The dataset names used in this example can be changed to anything
    you like as long as the //RRKF006E DD statement in the SMP APPLY
    and ACCEPT jobs points to the dataset created by //SYSUT2 DD of
    the RCVTLIB job.

 3. RECEIVE and APPLY the PTF as usual.

 4. ACCEPT the PTF according to your preferences after sufficient
    testing.
 */ .
++MACUPD(RAKF) .
><  CHANGE NAME=RAKF,SSI=02060000
//RAKFPWUP DD DSN=SYS1.SECURE.PWUP,DISP=SHR                         @06 00060006
>< ENDUP
++MAC($DOC$ZIP) TXLIB(RRKF006E) .
++MAC(RAKFRMV)  TXLIB(RRKF006E) .
++MAC(A@PREP)   TXLIB(RRKF006E) .
++MAC(AUXINST)  TXLIB(RRKF006E) DISTLIB(ASAMPLIB) SYSLIB(SAMPLIB) .
++MAC(AUXUTILS) TXLIB(RRKF006E) DISTLIB(ASAMPLIB) SYSLIB(SAMPLIB) .
++MAC(INITTBLS) TXLIB(RRKF006E) DISTLIB(ASAMPLIB) SYSLIB(SAMPLIB) .
++MAC(INITPWUP) TXLIB(RRKF006E) DISTLIB(ASAMPLIB) SYSLIB(SAMPLIB) .
++MAC(VSAMLRAC) TXLIB(RRKF006E) DISTLIB(ASAMPLIB) SYSLIB(SAMPLIB) .
++MAC(VSAMSRAC) TXLIB(RRKF006E) DISTLIB(ASAMPLIB) SYSLIB(SAMPLIB) .
++MAC(VTOCLRAC) TXLIB(RRKF006E) DISTLIB(ASAMPLIB) SYSLIB(SAMPLIB) .
++MAC(VTOCSRAC) TXLIB(RRKF006E) DISTLIB(ASAMPLIB) SYSLIB(SAMPLIB) .
