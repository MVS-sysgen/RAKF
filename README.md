# MVS 3.8J RAKF

From RAKF documentation:

The RAKF Security System is a RACF-like MVS System Authorization
Facility (SAF). RACF Version 1.7 facilities are emulated, except for
theRACF database. Two tables, the users and the profiles table,
are kept in storage. The actual security verifications are made by
ICHSFR00, using these two tables. The formats of these users and
profiles tables are compatible with RACF database entry data.

Protection is achieved by routing all operating system or vendor
product security calls (including RACDEF, RACINIT, and RACHECK)
through the ICHSFR00 RACROUTE interface. ICHSFR00 contains the real
verification code. The RAKF Security System is designed to force
"one point of handling" for all security calls. ICHSFR00 processes
the various kinds of security calls in a standard way that is (mostly)
documented by IBM. ICHSFR00 refers to the installation-coded user
and profile in-core tables, to make its judgments. These in-core
user and resource tables are each reloadable at any time by the
execution of their special started tasks.

## Automated Install

If you are using the automated jay moseley sysgen then:

1) Make sure this repo is cloned to the `SOFTWARE` folder
2) Make sure hercules isn't running
3) Launch `./install_rakf.sh`

The install script will install the following users:

| Username | Password |
|:--------:|:--------:|
| IBMUSER  | SYS1     |
| HMVS01*  | CUL8TR*  |
| HMVS02   | PASS4U   |

\* You can replace this username/password by passing a username and password to
`rakf_install.sh`. For example `./rakf_install.sh DA5ID PASSWORD` would replace
*HMVS01* with *DA5ID* and *CUL8TR* with *PASSWORD*. You can pass a username/password
shorter/longer than 8 chars but it will be padded/truncated to 8 characters.

For more information please read the documentation at `RAKFDOC#.pdf` or `RAKF_User_Guide.txt`

## Using RAKF

The user guide has more detail on setting up users and classes.

Usernames and passwords are located in `SYS1.SECURE.CNTL(USERS)`. :warning: if you make changes
to this file make sure it is in alphabetical order when complete. Once done with your changes
refresh RAKF by running `/s rakfuser` from the MVS console.

Profiles are located in `SYS1.SECURE.CNTL(PROFILES)`. :warning: if you make changes
to this file make sure it is in alphabetical order when complete. Once done with your changes
refresh RAKF by running `/s rakfprof` from the MVS console.

From here on out all jobs submitted using the socket reader will now requires a username= and
password= in the jobcard. If you submit from TSO you must submit with username= and password= in
the jobcard as well, unless you have a usermod like http://www.prycroft6.com.au/vs2mods/#zp60034
installed.

## Manual Install

:warning: Installing RAKF is a long process. :warning:

1) Submit the job `01_rakf_a_prep.jcl` which generates `SYSGEN.RAKF.V1R2M0.ASAMPLIB`, `SYSGEN.RAKF.V1R2M0.SAMPLIB`,
`SYSGEN.RAKF.V1R2M0.AMACLIB`, `SYSGEN.RAKF.V1R2M0.MACLIB`, `SYSGEN.RAKF.V1R2M0.ASRCLIB`, `SYSGEN.RAKF.V1R2M0.SRCLIB`,
`SYSGEN.RAKF.V1R2M0.APROCLIB`, `SYSGEN.RAKF.V1R2M0.APARMLIB` removes `ICHSFR00`, `IGC0013A`, `IGC0013B`, `IGC0013C`,
`IGC0013{`, `ICHRIN00` from `SYS1.LPALIB` and removes `ICHSEC00`, `RAKFPROF`, `RAKFUSER`,
`RAKFPWUP`, `RAKFINIT`, from `SYS1.LINKLIB`
2) Next you mount the tape `RAKF12.AWS`: `devinit 0100 ../SOFTWARE/RAKF/RAKF12.AWS`
3) And receive its contents with:

```
//RECEIVE EXEC SMPREC
//SMPPTFIN DD  DISP=(OLD,KEEP),DSN=TRKF120.F0,
//             UNIT=(TAPE,,DEFER),VOL=(,RETAIN,SER=RAKF12),
//             LABEL=(1,SL)
//SMPCNTL  DD  *
 RECEIVE S(TRKF120) .
/*
```

4) Next you apply and accept RAKF with SMP (see `03_rakf_c_apply.jcl` and `04_rakf_d_accept.jcl` for examples)
5) Shutdown you system and do a cold IPL (`/r 0,CLPA` and `/r 01,format,noreq` after IPL)
6) Use RECV370 to place `RRKF002E`, `RRKF004E`, `RRKF005E`, `RRKF006E` in SYSGEN.RAKF.RRKF00#.*ddname* (where #
is the PTFs XMI # and ddname is the name used to apply the changes )
7) Load all the PTFs to `SYSGEN.RAKF.PTFS` using `09_rakf_pdsload_ptfs.jcl`
8) Receive then apply the PTFs (using the *ddname* from step 5, see the last job step in `10_rakf_recv_ptfs` for sample)
9) Install the *ZJW0003* Usermod, this runs `RAKFUSER`, `RAKFPROF`, and `RAKFPWUP` on JES2 startup and refreshes the RAKF user
and profiles.
10) Use RECV370 to receive the XMI in `SYSGEN.RAKF.V1R2M0.SAMPLIB(AUXUTILS)`
11) And copy the auxilary utilities using this JCL:

```
//INSTALL  EXEC PGM=IEBCOPY
//AUX      DD  DISP=(OLD,DELETE),DSN=&&AUX
//LINKLIB  DD  DISP=SHR,DSN=SYS2.LINKLIB
//CMDLIB   DD  DISP=SHR,DSN=SYS2.CMDLIB
//LPALIB   DD  DISP=SHR,DSN=SYS1.LPALIB
//PARMLIB  DD  DISP=SHR,DSN=SYS1.PARMLIB
//RAKFINIT DD  DISP=(OLD,PASS),DSN=&&RAKFIN
//SYSPRINT DD  SYSOUT=*
//SYSIN    DD  *
 COPY INDD=((AUX,R)),OUTDD=LINKLIB
 SELECT MEMBER=(MAWK)
 COPY INDD=((AUX,R)),OUTDD=CMDLIB
 SELECT MEMBER=(VTOC,CDSCB)
 COPY INDD=((RAKFINIT,R)),OUTDD=PARMLIB
 SELECT MEMBER=(RAKFINIT)
/*
```

12) Create the partitioned dataset `SYS1.SECURE.CNTL`
13) Add your users to `SYS1.SECURE.CNTL(USERS)`, an example config is located in `USERS.txt`

:warning: The users must be listed in alphabetical order :warning:

:warning: The users also need to be added to TSO which can be done using this JCL :warning:

```
//NEWUSER EXEC TSONUSER,ID=IBMUSER,   This will be the logon ID
//        PW='SYS1',
//        OP='OPER',             Allow operator authority
//        AC='ACCT'              Allow ACCOUNT TSO COMMAND
```

14) Add your classes and other access to `SYS1.SECURE.CNTL(PROFILES)`, an example config is located in `PROFILES.txt`
:warning: The profiles must be listed in alphabetical order :warning:

15) Shudown your system and do one more cold IPL.

Congrats you've installed RAKF.
