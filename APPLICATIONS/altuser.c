/* ================================================================== *
 *  ALTUSER - alter a RAKF user profile.                              *
 *                                                                    *
 *  Syntax (read from //SYSIN):                                       *
 *     ALTUSER userid [PASSWORD(pw)] [DFLTGRP(grp)]                   *
 *             [OPERATIONS|NOOPERATIONS] [SPECIAL|NOSPECIAL]          *
 *                                                                    *
 *  Re-hashes the password (new salt), moves the default-group flag,  *
 *  and/or toggles the OPER/SPECIAL flags on every line of the user.  *
 *  Return codes: 0 ok, 8 usage/validation, 12 I/O/auth error.        *
 * ================================================================== */
#include <stdio.h>
#include <string.h>
#include "rakfadm.h"

int main(int argc, char **argv)
{
    USERS_T  users;
    SHADOW_T shadow;
    CMD_T    c;
    char     line[256], err[128];
    int      i, changed = 0, touched_users = 0;

    if (read_command(argc, argv, line, sizeof(line)) != 0) {
        printf("ALTUSER: no command supplied.\n");
        return 12;
    }
    if (cmd_parse(line, "ALTUSER", &c, err) != 0) {
        printf("ALTUSER: %s\n", err);
        return 8;
    }

    printf("ALTUSER: USERS=%s  SHADOW=%s\n", users_dsn(), shadow_dsn());
    if (users_load(&users) != 0)   { printf("ALTUSER: cannot open USERS.\n");  return 12; }
    if (shadow_load(&shadow) != 0) { printf("ALTUSER: cannot open SHADOW.\n"); return 12; }

    if (user_first(&users, c.userid) < 0) {
        printf("ALTUSER: user %s not defined.\n", c.userid);
        return 8;
    }

    /* ---- new password -> new salt + hash -> replace shadow record ---- */
    if (c.have_password) {
        if (set_password(&shadow, c.userid, c.password) != 0) {
            printf("ALTUSER: cannot set password.\n");
            return 12;
        }
        changed = 1;
    }

    /* ---- move the default-group '*' flag ---------------------------- */
    if (c.have_dfltgrp) {
        int found = -1;
        for (i = 0; i < users.n; i++)
            if (fld_eq(users.rec[i], U_ID, U_ID_L, c.userid) &&
                fld_eq(users.rec[i], U_GRP, U_GRP_L, c.dfltgrp)) { found = i; break; }
        if (found < 0) {
            printf("ALTUSER: %s is not connected to group %s "
                   "(use CONNECT first).\n", c.userid, c.dfltgrp);
            return 8;
        }
        for (i = 0; i < users.n; i++)
            if (fld_eq(users.rec[i], U_ID, U_ID_L, c.userid))
                users.rec[i][U_DFLT] = (char)((i == found) ? '*' : ' ');
        changed = 1; touched_users = 1;
    }

    /* ---- toggle OPER / SPECIAL on every line of the user ------------ */
    if (c.oper != -1 || c.spec != -1) {
        for (i = 0; i < users.n; i++) {
            if (!fld_eq(users.rec[i], U_ID, U_ID_L, c.userid)) continue;
            if (c.oper != -1) users.rec[i][U_OPER] = (char)(c.oper ? 'Y' : 'N');
            if (c.spec != -1) users.rec[i][U_SPEC] = (char)(c.spec ? 'Y' : 'N');
        }
        changed = 1; touched_users = 1;
    }

    if (!changed) {
        printf("ALTUSER: nothing to change for %s.\n", c.userid);
        return 8;
    }

    if (touched_users && users_save(&users) != 0) {
        printf("ALTUSER: cannot write USERS (not authorized?).\n");
        return 12;
    }
    if (c.have_password && shadow_save(&shadow) != 0) {
        printf("ALTUSER: cannot write SHADOW (not authorized?).\n");
        return 12;
    }

    printf("ALTUSER: user %s altered.\n", c.userid);
    reload_table();
    return 0;
}
