/* ================================================================== *
 *  rakfadm.c - shared logic for the RAKF administration commands.    *
 *  See DESIGN.md.  Built with the MVS C compiler (mbt / cc370).      *
 * ================================================================== */
#include <stdio.h>
#include <string.h>
#include <ctype.h>
#include <stdlib.h>
#include "rakfadm.h"

/* ------------------------------------------------------------------ *
 *  Small string helpers                                              *
 * ------------------------------------------------------------------ */
void upcase(char *s)
{
    for (; *s; s++) *s = (char)toupper((unsigned char)*s);
}

void trim(char *s)
{
    int n = (int)strlen(s);
    while (n > 0 && (s[n-1] == ' ' || s[n-1] == '\n' || s[n-1] == '\r'))
        s[--n] = '\0';
}

/* copy val into rec[off..off+len), blank-padded (EBCDIC 0x40 == ' ') */
void fld_set(char *rec, int off, int len, const char *val)
{
    int i, vl = (int)strlen(val);
    for (i = 0; i < len; i++)
        rec[off + i] = (i < vl) ? val[i] : ' ';
}

/* 1 if rec field equals val (blank-padded), else 0 */
int fld_eq(const char *rec, int off, int len, const char *val)
{
    int i, vl = (int)strlen(val);
    for (i = 0; i < len; i++) {
        char c = (i < vl) ? val[i] : ' ';
        if (rec[off + i] != c) return 0;
    }
    return 1;
}

/* ================================================================== *
 *  Control-dataset discovery.                                        *
 *                                                                    *
 *  Rather than hard-code where USERS / SHADOW / PROFILES live, the    *
 *  tools read the RAKF proc members and parse their DD statements at  *
 *  run time, so they always target whatever the running system uses.  *
 *  Change the proc members, DDNAMEs, or fallbacks here.              *
 * ================================================================== */
/* Quoted DSN, no leading slashes -- see open_ds() below. The IBM C
 * "//'dsn'" form makes libc370's fopen() take its unquoted-name branch,
 * which prepends the TSO prefix; invoked as a TSO command processor that
 * dereferences the CPPL for the prefix and takes an S0C4. Under CALL the
 * prefix lookup is skipped, fopen just fails, and dd_dsn() quietly falls
 * back to the compiled defaults -- which is why CALL appeared to work. */
#define PROC_USERS  "'SYS1.PROCLIB(RAKFUSER)'"    /* has the USERS + SHADOW DDs */
#define PROC_PROF   "'SYS1.PROCLIB(RAKFPROF)'"    /* has the PROFILES DD        */
#define DD_USERS    "RAKFUSER"      /* DDNAME whose DSN is the USERS table    */
#define DD_SHADOW   "RAKFSHAD"      /* DDNAME whose DSN is the shadow file    */
#define DD_PROF     "RAKFPROF"      /* DDNAME whose DSN is the PROFILES table */
#define SFX_SHADOW  ".SHADOW"       /* fallback: DD whose DSN ends like this  */
/* Fallbacks used only if a proc member / DD statement can't be read: */
#define DFLT_USERS  "SYS1.SECURE.CNTL(USERS)"
#define DFLT_SHADOW "SYS1.SECURE.SHADOW"
#define DFLT_PROF   "SYS1.SECURE.CNTL(PROFILES)"

static int  g_resolved = 0;
static char g_users_dsn [52];       /* bare DSNs, e.g. SYS1.SECURE.SHADOW */
static char g_shadow_dsn[52];
static char g_prof_dsn  [52];

/* Scan proc member `proc` for a DD statement and copy its DSN= value
 * (bare, no quotes) into `dsn`.  A line matches if its DDNAME equals
 * `ddname` (//<ddname> b DD ...) OR, when `dsnsfx` is non-NULL, if its
 * DSN ends with `dsnsfx` (covers oddly-labelled DDs).  Single-line DD
 * statements only.  Returns 0 if found, -1 otherwise. */
static int dd_dsn(const char *proc, const char *ddname, const char *dsnsfx,
                  char *dsn, size_t dsz)
{
    FILE   *fp;
    char    line[128], cand[60];
    size_t  nl = strlen(ddname);
    int     found = -1;

    fp = fopen(proc, "r");
    if (fp == NULL) return -1;
    while (found < 0 && fgets(line, sizeof(line), fp) != NULL) {
        char  *p, *d, *e;
        if (line[0] != '/' || line[1] != '/') continue;
        d = strstr(line, "DSN=");                /* pull the DSN= value  */
        if (d) d += 4;
        else { d = strstr(line, "DSNAME="); if (d) d += 7; }
        if (d == NULL) continue;                 /* e.g. the EXEC card   */
        e = cand;
        while (*d && *d != ',' && *d != ' ' && *d != '\n' && *d != '\r'
               && (size_t)(e - cand) < sizeof(cand) - 1)
            *e++ = *d++;
        *e = '\0';
        if (cand[0] == '\0') continue;
        /* match by DDNAME: //<ddname> then blank then DD */
        p = line + 2;
        if (strncmp(p, ddname, nl) == 0 && (p[nl] == ' ' || p[nl] == '\t')) {
            p += nl;
            while (*p == ' ' || *p == '\t') p++;
            if (strncmp(p, "DD", 2) == 0 && (p[2] == ' ' || p[2] == '\t'))
                found = 0;
        }
        /* or by DSN suffix (fallback for a DD not named as expected) */
        if (found < 0 && dsnsfx != NULL) {
            size_t cl = strlen(cand), sl = strlen(dsnsfx);
            if (cl >= sl && strcmp(cand + cl - sl, dsnsfx) == 0) found = 0;
        }
        if (found == 0) { strncpy(dsn, cand, dsz - 1); dsn[dsz - 1] = '\0'; }
    }
    fclose(fp);
    return found;
}

/* Resolve USERS / SHADOW / PROFILES once, from the proc members.
 * Falls back to the compiled defaults for anything not found. */
/* Set by the -TRACE operand: prints a checkpoint before each step that
 * touches a dataset, so an abend can be located from the console. Off by
 * default; nothing is printed in normal use. */
int g_trace = 0;

void rakf_trace(const char *what)
{
    if (!g_trace) return;
    printf("RAKF TRACE: %s\n", what);
    /* Flush rather than running stdout unbuffered: setbuf(stdout, NULL)
       stops output reaching the terminal entirely when the command is
       entered at READY, while the buffered path works. */
    fflush(stdout);
}

void resolve_datasets(void)
{
    if (g_resolved) return;
    rakf_trace("resolve: reading " PROC_USERS " for USERS");
    if (dd_dsn(PROC_USERS, DD_USERS, NULL, g_users_dsn, sizeof(g_users_dsn)) != 0)
        strcpy(g_users_dsn, DFLT_USERS);
    rakf_trace("resolve: reading " PROC_USERS " for SHADOW");
    if (dd_dsn(PROC_USERS, DD_SHADOW, SFX_SHADOW, g_shadow_dsn, sizeof(g_shadow_dsn)) != 0)
        strcpy(g_shadow_dsn, DFLT_SHADOW);
    rakf_trace("resolve: reading " PROC_PROF " for PROFILES");
    if (dd_dsn(PROC_PROF, DD_PROF, NULL, g_prof_dsn, sizeof(g_prof_dsn)) != 0)
        strcpy(g_prof_dsn, DFLT_PROF);
    rakf_trace("resolve: done");
    g_resolved = 1;
}

const char *users_dsn(void)    { resolve_datasets(); return g_users_dsn;  }
const char *shadow_dsn(void)   { resolve_datasets(); return g_shadow_dsn; }
const char *profiles_dsn(void) { resolve_datasets(); return g_prof_dsn;   }

/* ------------------------------------------------------------------ *
 *  Dataset I/O.  Datasets are resolved (above) then opened by DSN:    *
 *  USERS is a PDS member (FB 80), SHADOW a sequential dataset (FB 48).*
 *  Binary mode: FB records are a contiguous byte stream.            *
 * ------------------------------------------------------------------ */
/* Open a control dataset.  Prefer a pre-allocated DD (ddname): the
 * SYS1.SECURE.* datasets are held allocated by the master address
 * space (the RAKFUSER / RAKFSHAD DDs in MSTRJCL that let ICHSEC00 load
 * the tables at IPL), and that hold blocks our own dynamic SVC 99
 * allocation.  An initiator-allocated DD (DISP=SHR in the job JCL)
 * coexists with the master's hold, so try that first; fall back to a
 * dynamic DSN allocation for anything not held (e.g. a fresh install). */
static FILE *open_ds(const char *ddname, const char *dsn, const char *mode)
{
    char  path[64];
    FILE *fp;
    sprintf(path, "DD:%s", ddname);         /* libc370 wants DD:ddname, no // */
    fp = fopen(path, mode);
    if (fp != NULL) return fp;
    /* libc370 wants a quoted DSN with NO leading slashes -- the IBM C
       "//'dsn'" form is not recognised. fopen() checks for "DD:", then "*",
       then a leading quote; anything else is treated as an unquoted name and
       gets the TSO prefix prepended, so "//'SYS1.SECURE.CNTL(USERS)'" became
       "IBMUSER.//'SYS1.SECURE.CNTL" and the allocation failed. With the
       correct form fopen dynamically allocates it (SVC 99, DISP=SHR via
       __fpshr), so no //USERS or //SHADOW DD is needed in TSO or in batch. */
    sprintf(path, "'%s'", dsn);
    return fopen(path, mode);
}

int users_load(USERS_T *u)
{
    FILE *fp;
    u->n = 0;
    resolve_datasets();
    rakf_trace("open USERS for read");
    fp = open_ds("USERS", g_users_dsn, "rb");
    if (fp == NULL) return -1;
    while (u->n < MAXUREC && fread(u->rec[u->n], 1, UREC, fp) == UREC)
        u->n++;
    fclose(fp);
    return 0;
}

int users_save(USERS_T *u)
{
    FILE *fp;
    int i;
    resolve_datasets();
    rakf_trace("open USERS for write");
    fp = open_ds("USERS", g_users_dsn, "wb");
    if (fp == NULL) return -1;              /* S913 here = not authorized */
    for (i = 0; i < u->n; i++)
        if (fwrite(u->rec[i], 1, UREC, fp) != UREC) { fclose(fp); return -1; }
    fclose(fp);
    return 0;
}

int shadow_load(SHADOW_T *s)
{
    FILE *fp;
    s->n = 0;
    resolve_datasets();
    rakf_trace("open SHADOW for read");
    fp = open_ds("SHADOW", g_shadow_dsn, "rb");
    if (fp == NULL) return -1;
    while (s->n < MAXSREC && fread(s->rec[s->n], 1, SREC, fp) == SREC)
        s->n++;
    fclose(fp);
    return 0;
}

int shadow_save(SHADOW_T *s)
{
    FILE *fp;
    int i;
    resolve_datasets();
    rakf_trace("open SHADOW for write");
    fp = open_ds("SHADOW", g_shadow_dsn, "wb");
    if (fp == NULL) return -1;
    for (i = 0; i < s->n; i++)
        if (fwrite(s->rec[i], 1, SREC, fp) != SREC) { fclose(fp); return -1; }
    fclose(fp);
    return 0;
}

/* ------------------------------------------------------------------ *
 *  User / shadow lookups and mutation                                *
 * ------------------------------------------------------------------ */
int user_first(USERS_T *u, const char *userid)
{
    int i;
    for (i = 0; i < u->n; i++)
        if (fld_eq(u->rec[i], U_ID, U_ID_L, userid)) return i;
    return -1;
}

int shadow_find(SHADOW_T *s, const char *userid)
{
    int i;
    for (i = 0; i < s->n; i++)
        if (fld_eq((char *)s->rec[i], S_ID, S_ID_L, userid)) return i;
    return -1;
}

/* Salt + hash the password and add/replace this user's SHADOW record.
 * Uses the SAME RAKFPWH -> RAKFHASH the login path uses (no local SHA). */
int set_password(SHADOW_T *s, const char *userid, const char *pw)
{
    unsigned char salt[S_SALT_L];
    unsigned char out[S_HASH_L];
    unsigned char work[RAKFPWH_WORK];
    int len = (int)strlen(pw);
    int idx;

    getstck(salt);                              /* 8-byte salt from TOD  */
    rakfpwh(salt, (void *)pw, &len, out, work); /* SHA256(salt || pw)    */

    idx = shadow_find(s, userid);
    if (idx < 0) {
        if (s->n >= MAXSREC) return -1;
        idx = s->n++;
    }
    fld_set((char *)s->rec[idx], S_ID, S_ID_L, userid); /* EBCDIC, 0x40 pad */
    memcpy(s->rec[idx] + S_SALT, salt, S_SALT_L);
    memcpy(s->rec[idx] + S_HASH, out,  S_HASH_L);
    return 0;
}

int del_shadow(SHADOW_T *s, const char *userid)
{
    int idx = shadow_find(s, userid), i;
    if (idx < 0) return -1;
    for (i = idx; i < s->n - 1; i++)
        memcpy(s->rec[i], s->rec[i + 1], SREC);
    s->n--;
    return 0;
}

/* ------------------------------------------------------------------ *
 *  Command parsing.  Accepts  "[VERB] userid KEY(val) ... FLAG ..."   *
 *  Values may contain spaces:  GROUP(SYS1 ADMIN).                     *
 *  Everything is folded to upper case (RACF folds passwords too, and  *
 *  RAKF login uppercases the typed password, so this keeps them in    *
 *  step).                                                             *
 * ------------------------------------------------------------------ */
static const char *scan(const char *p, char *key, char *val)
{
    char *k;
    while (*p == ' ') p++;
    if (*p == '\0') return NULL;
    key[0] = val[0] = '\0';
    k = key;
    while (*p && *p != ' ' && *p != '(') *k++ = *p++;
    *k = '\0';
    if (*p == '(') {
        char *v = val;
        p++;
        while (*p && *p != ')') *v++ = *p++;
        *v = '\0';
        if (*p == ')') p++;
    }
    return p;
}

int cmd_parse(const char *line0, const char *verb, CMD_T *c, char *err)
{
    char line[256];
    char key[64], val[256];
    const char *p;

    memset(c, 0, sizeof(*c));
    c->oper = c->spec = -1;
    err[0] = '\0';

    strncpy(line, line0, sizeof(line) - 1);
    line[sizeof(line) - 1] = '\0';
    trim(line);
    upcase(line);

    p = scan(line, key, val);
    if (p == NULL) { strcpy(err, "empty command"); return -1; }
    if (strcmp(key, verb) == 0) {           /* leading verb - skip it */
        p = scan(p, key, val);
        if (p == NULL) { strcpy(err, "missing userid"); return -1; }
    }
    if (val[0] != '\0' || strlen(key) == 0 || strlen(key) > 8) {
        sprintf(err, "invalid userid '%s'", key);
        return -1;
    }
    strcpy(c->userid, key);

    while ((p = scan(p, key, val)) != NULL) {
        if      (strcmp(key, "PASSWORD") == 0) {
            if (strlen(val) == 0 || strlen(val) > PW_MAX) {
                sprintf(err, "PASSWORD must be 1-%d chars", PW_MAX); return -1;
            }
            strcpy(c->password, val); c->have_password = 1;
        }
        else if (strcmp(key, "DFLTGRP") == 0) {
            if (strlen(val) == 0 || strlen(val) > 8) { strcpy(err,"bad DFLTGRP"); return -1; }
            strcpy(c->dfltgrp, val); c->have_dfltgrp = 1;
        }
        else if (strcmp(key, "GROUP") == 0) {
            char *t = strtok(val, " ");
            while (t && c->ngrp < 8) {
                if (strlen(t) <= 8) strcpy(c->grp[c->ngrp++], t);
                t = strtok(NULL, " ");
            }
        }
        else if (strcmp(key, "OPERATIONS")   == 0) c->oper = 1;
        else if (strcmp(key, "NOOPERATIONS") == 0) c->oper = 0;
        else if (strcmp(key, "SPECIAL")      == 0) c->spec = 1;
        else if (strcmp(key, "NOSPECIAL")    == 0) c->spec = 0;
        else if (strcmp(key, "-TRACE") == 0 || strcmp(key, "TRACE") == 0)
            g_trace = 1;                /* checkpoint each dataset open */
        else { sprintf(err, "unsupported operand '%s'", key); return -1; }
    }
    return 0;
}

/* Rebuild the command line from the argv the C runtime handed us.
 *
 * libc370's startup (@@start.c) already did the TSO work: it followed
 * R1 -> CPPL -> command buffer and split the text into argc/argv (for
 * batch it splits PARM= the same way).  It splits on blanks, so
 * rejoining with single blanks reproduces the original line - and an
 * operand that contained blanks, e.g. GROUP(SYS1 ADMIN), comes back
 * whole because cmd_parse() reads to the closing ')'.  argv[0] is the
 * command/verb; cmd_parse() skips it if it matches.
 *
 * This one function serves all three entry paths:
 *   - interactive TSO command   (READY/CLIST/ISPF)
 *   - batch under IKJEFT01       (command in //SYSTSIN)
 *   - plain batch PGM=,PARM='...'
 */
int read_command(int argc, char **argv, char *buf, size_t max)
{
    size_t len = 0;
    int i;

    buf[0] = '\0';
    for (i = 0; i < argc; i++) {
        size_t al = strlen(argv[i]);
        if (i > 0 && len + 1 < max) buf[len++] = ' ';
        if (len + al > max - 1) al = max - 1 - len;
        memcpy(buf + len, argv[i], al);
        len += al;
        if (len >= max - 1) break;
    }
    buf[len] = '\0';
    return (len > 0) ? 0 : -1;
}

/* Activation.  v1 is manual: the datasets are updated on disk, but the
 * in-storage table is refreshed by running RAKFUSER.  (A later revision
 * can LINK to RAKFUSER from an APF-authorized copy of this tool, or
 * submit a reload job to an internal-reader DD.) */
int reload_table(void)
{
    printf("RAKF: control datasets updated. "
           "Run RAKFUSER to activate the change.\n");
    return 0;
}
