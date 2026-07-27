/* ================================================================== *
 *  ADDUSER - add a RAKF user profile.                                *
 *                                                                    *
 *  Syntax (read from //SYSIN):                                       *
 *     ADDUSER userid PASSWORD(pw) DFLTGRP(grp)                       *
 *             [GROUP(g2 g3 ...)] [OPERATIONS] [SPECIAL]              *
 *                                                                    *
 *  Adds one USERS line per group (the DFLTGRP line carries the '*'   *
 *  default flag) and a SHADOW record holding salt + SHA-256(salt||pw)*
 *  Return codes: 0 ok, 8 usage/validation error, 12 I/O/auth error.  *
 * ================================================================== */
#include <stdio.h>
#include <string.h>
#include "rakfadm.h"

static void make_uline(char *line, const char *uid, const char *grp,
                       int is_dflt, int oper, int spec)
{
    memset(line, ' ', UREC);                 /* EBCDIC blanks (0x40) */
    fld_set(line, U_ID,  U_ID_L,  uid);
    line[U_DFLT] = (char)(is_dflt ? '*' : ' ');
    fld_set(line, U_GRP, U_GRP_L, grp);
    line[U_PW]   = ' ';                       /* password is in the shadow */
    line[U_OPER] = (char)(oper ? 'Y' : 'N');
    line[U_SPEC] = (char)(spec ? 'Y' : 'N');
}

int main(int argc, char **argv)
{
    USERS_T  users;
    SHADOW_T shadow;
    CMD_T    c;
    char     line[256], err[128];
    int      oper, spec, k;

    if (read_command(argc, argv, line, sizeof(line)) != 0) {
        printf("ADDUSER: no command supplied.\n");
        return 12;
    }
    if (cmd_parse(line, "ADDUSER", &c, err) != 0) {
        printf("ADDUSER: %s\n", err);
        return 8;
    }
    if (!c.have_password || !c.have_dfltgrp) {
        printf("ADDUSER: PASSWORD(...) and DFLTGRP(...) are required.\n");
        return 8;
    }

    printf("ADDUSER: USERS=%s  SHADOW=%s\n", users_dsn(), shadow_dsn());
    if (users_load(&users) != 0)  { printf("ADDUSER: cannot open USERS.\n");  return 12; }
    if (shadow_load(&shadow) != 0){ printf("ADDUSER: cannot open SHADOW.\n"); return 12; }

    if (user_first(&users, c.userid) >= 0) {
        printf("ADDUSER: user %s already defined.\n", c.userid);
        return 8;
    }
    if (users.n + 1 + c.ngrp > MAXUREC) {
        printf("ADDUSER: USERS table full.\n");
        return 12;
    }

    oper = (c.oper == 1);
    spec = (c.spec == 1);

    /* default-group line (carries '*') */
    make_uline(users.rec[users.n++], c.userid, c.dfltgrp, 1, oper, spec);
    /* extra connect groups (skip one equal to the default) */
    for (k = 0; k < c.ngrp; k++) {
        if (strcmp(c.grp[k], c.dfltgrp) == 0) continue;
        make_uline(users.rec[users.n++], c.userid, c.grp[k], 0, oper, spec);
    }

    if (set_password(&shadow, c.userid, c.password) != 0) {
        printf("ADDUSER: cannot set password (shadow full?).\n");
        return 12;
    }

    if (users_save(&users)   != 0) { printf("ADDUSER: cannot write USERS (not authorized?).\n");  return 12; }
    if (shadow_save(&shadow) != 0) { printf("ADDUSER: cannot write SHADOW (not authorized?).\n"); return 12; }

    printf("ADDUSER: user %s added (dfltgrp %s, oper %c, special %c).\n",
           c.userid, c.dfltgrp, oper ? 'Y' : 'N', spec ? 'Y' : 'N');
    reload_table();
    return 0;
}
