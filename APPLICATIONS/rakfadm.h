/* ================================================================== *
 *  rakfadm.h - shared definitions for the RAKF administration        *
 *              commands (ADDUSER, ALTUSER, ... ).                     *
 *                                                                    *
 *  Target: MVS 3.8J C (cc370 / mbt).  EBCDIC host - all character    *
 *  constants and comparisons are native EBCDIC, which is why we can  *
 *  pad userids with a plain ' ' (0x40) and match RAKFUSER directly.  *
 * ================================================================== */
#ifndef RAKFADM_H
#define RAKFADM_H

#include <stddef.h>

/* ---- control datasets --------------------------------------------*
 *  The tools do NOT hard-code the USERS / SHADOW / PROFILES dataset  *
 *  names.  resolve_datasets() reads the RAKF proc members and parses *
 *  their DD statements at run time, so the tools always target the   *
 *  same datasets the running system uses.  See rakfadm.c for the     *
 *  proc-member / DDNAME configuration (defined at the top).          */

/* ---- record sizes ------------------------------------------------ */
#define UREC     80          /* USERS  record length (FB 80)          */
#define SREC     48          /* SHADOW record length (FB 48)          */
#define MAXUREC  1000        /* max USERS  lines held in core         */
#define MAXSREC  500         /* max SHADOW records held in core       */

/* ---- USERS column offsets (0-based), see DESIGN.md --------------- */
#define U_ID       0         /* userid          cols 1-8   */
#define U_ID_L     8
#define U_DFLT     8         /* default flag '*' col 9      */
#define U_GRP      9         /* group           cols 10-17  */
#define U_GRP_L    8
#define U_PW      18         /* password        cols 19-26  (kept blank) */
#define U_PW_L     8
#define U_OPER    27         /* operations Y/N  col 28      */
#define U_SPEC    29         /* special    Y/N  col 30 (reserved)  */

/* ---- SHADOW field offsets --------------------------------------- */
#define S_ID       0         /* userid  (8, EBCDIC)  */
#define S_ID_L     8
#define S_SALT     8         /* salt    (8, binary)  */
#define S_SALT_L   8
#define S_HASH    16         /* hash    (32, binary) */
#define S_HASH_L  32

#define PW_MAX     8         /* max password length RAKF stores */

/* ---- in-core tables --------------------------------------------- */
typedef struct {
    char rec[MAXUREC][UREC];
    int  n;
} USERS_T;

typedef struct {
    unsigned char rec[MAXSREC][SREC];
    int  n;
} SHADOW_T;

/* ---- parsed command operands (superset for ADDUSER/ALTUSER) ------ */
typedef struct {
    char userid[9];
    char password[PW_MAX + 1];
    char dfltgrp[9];
    char grp[8][9];          /* extra GROUP() connections */
    int  ngrp;
    int  have_password;
    int  have_dfltgrp;
    int  oper;               /* -1 unset, 0 NOOPERATIONS, 1 OPERATIONS */
    int  spec;               /* -1 unset, 0 NOSPECIAL,     1 SPECIAL    */
} CMD_T;

/* ---- control-dataset discovery (reads the RAKF proc members) ----- */
void        resolve_datasets(void);  /* parse procs -> USERS/SHADOW/PROFILES */
const char *users_dsn(void);         /* resolved bare DSNs (for display)     */
const char *shadow_dsn(void);
const char *profiles_dsn(void);
extern int  g_trace;                 /* -TRACE: checkpoint each open */
void        rakf_trace(const char *what);

/* ---- dataset I/O (datasets resolved by resolve_datasets) --------- */
int  users_load (USERS_T  *u);
int  users_save (USERS_T  *u);
int  shadow_load(SHADOW_T *s);
int  shadow_save(SHADOW_T *s);

/* ---- record helpers --------------------------------------------- */
void fld_set(char *rec, int off, int len, const char *val); /* blank-pad copy */
int  fld_eq (const char *rec, int off, int len, const char *val);
void upcase (char *s);
void trim   (char *s);       /* strip trailing blanks */

/* ---- user / shadow operations ----------------------------------- */
int  user_first(USERS_T *u, const char *userid);   /* first line idx or -1 */
int  shadow_find(SHADOW_T *s, const char *userid);  /* idx or -1 */
int  set_password(SHADOW_T *s, const char *userid, const char *pw);
int  del_shadow (SHADOW_T *s, const char *userid);

/* ---- command parsing / activation ------------------------------- */
int  cmd_parse(const char *line, const char *verb, CMD_T *c, char *err);
int  reload_table(void);     /* trigger RAKFUSER reload (activation) */
int  read_command(int argc, char **argv, char *buf, size_t max);
                             /* rebuild the command line from argv (CPPL/PARM) */

/* ---- HLASM primitives (assembled by as370, autocalled from the      *
 *      [internal] archive) ---------------------------------------- *
 *  cc370 (gccmvs/PDPCLIB) passes  R1 -> a list of argument VALUES,    *
 *  one fullword each.  So a plain extern with no #pragma already      *
 *  produces the register contract these routines expect:             *
 *  RAKFPWH: R1 -> A(salt), A(pw), A(pwlen fullword), A(out32), A(work)*
 *           (note set_password passes &len, so its slot is A(pwlen))  *
 *  getstck: R1 -> A(8-byte buffer) ; stores the TOD clock (salt).     */
void rakfpwh(void *salt, void *pw, void *pwlen, void *out32, void *work);
void getstck(void *buf8);

#define RAKFPWH_WORK 700     /* >= RPWWORKL; sized generously */

#endif /* RAKFADM_H */
