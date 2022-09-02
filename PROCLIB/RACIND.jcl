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
