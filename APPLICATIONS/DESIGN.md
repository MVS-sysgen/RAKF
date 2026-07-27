# RAKF Administration Commands — Design & Build Plan

**Status:** Design; ADDUSER + ALTUSER coded first (this pass).
**Language:** C (built with `mbt` / cc370 on MVS 3.8J), sharing RAKF's HLASM crypto primitives.
**Depends on:** the Phase-2b hashing work (see `../HASHING_DESIGN.md`) — salted SHA-256, `SYS2.SECURE.SHADOW`, `RAKFPWH`/`RAKFHASH`.

---

## 1. Purpose

Give RAKF a set of RACF-syntax administration commands so users/profiles are managed with familiar
verbs (`ADDUSER FRED PASSWORD(...) ...`) instead of hand-editing flat files and reloading. The
commands are the same names an operator knows from RACF; the *implementation* is modern C over RAKF's
existing control datasets.

The goal is **muscle-memory compatibility**, not RACF feature-parity — RAKF's data model is simpler
than RACF's, so each command supports the subset of operands RAKF can actually represent (see §7).

---

## 2. Design principles

1. **Mirror RACF command/operand syntax** where RAKF has an equivalent concept; ignore/reject
   operands RAKF can't model (rather than silently pretend).
2. **Reuse, don't re-implement, the crypto.** Password hashing goes through the *same* `RAKFPWH`
   (→ `RAKFHASH`) routine the login path uses, so enrollment and verification can never drift. The C
   tools link those HLASM objects in and call them; they do **not** contain their own SHA-256.
3. **Authorization = dataset protection.** `SYS1.SECURE.CNTL` and `SYS2.SECURE.SHADOW` are already
   RAKF-protected so only the security-admin group (RAKFADM) can update them. A tool simply opens
   those datasets for update; if the caller isn't authorized, RAKF fails the OPEN (S913) and the tool
   exits. No separate privilege check is needed initially (see §7 for the SPECIAL-attribute upgrade).
4. **Batch-first, TSO-later.** v1 tools are batch programs that read one RACF-style command from
   `SYSIN` (scriptable, testable) with DD statements pointing at the RAKF datasets. A later pass can
   wrap them as TSO command processors for interactive use.
5. **Explicit activation.** Editing the datasets changes disk, not the live in-storage tables. After
   a successful change a tool triggers a table reload (run `RAKFUSER`/`RAKFPROF`) — see §4.

---

## 3. Architecture

```
   SYSIN: "ADDUSER FRED PASSWORD(xyz) DFLTGRP(SYS1) OPERATIONS"
      |
      v
  +-----------+     shared C library (rakfadm.c / rakfadm.h)
  | adduser.c | --> parse -> load USERS+SHADOW -> mutate -> save -> reload
  | altuser.c |            \                                   /
  +-----------+             \--- set_password() ---------------
        |                          |
        |                          v
        |                   RAKFPWH (HLASM)  <- salt from getstck (STCK)
        |                          |
        |                          v
        |                   RAKFHASH (HLASM, SHA-256)  [single source of truth]
        v
   return code + WTO/SYSPRINT summary
```

**Components**

| File | Role |
|---|---|
| `rakfadm.h` | shared structs (USERS/SHADOW record layouts), column constants, prototypes |
| `rakfadm.c` | shared logic: load/save USERS & SHADOW, find/add/delete user, hash wrapper, reload |
| `adduser.c` | ADDUSER command processor (`main`) |
| `altuser.c` | ALTUSER command processor (`main`) |
| `getstck.hlasm` | 8-byte salt from the TOD clock (STCK) — tiny assembler helper |
| (link) `RAKFPWH`, `RAKFHASH` | HLASM crypto, from `../SRCLIB` — linked into every tool that sets a password |

**Data model touched**

| Dataset | DD name | Content |
|---|---|---|
| `SYS1.SECURE.CNTL(USERS)` | `USERS` | userid, default-group flag, group, oper flag, (future) special flag |
| `SYS2.SECURE.SHADOW` | `SHADOW` | userid(8) + salt(8) + hash(32), 48-byte binary records |
| `SYS1.SECURE.CNTL(PROFILES)` | `PROFILES` | DATASET + general-resource profiles and permits (for the *SD/R\*/PERMIT commands) |

**Record layouts** (as parsed by the current `RAKFUSER`)

```
USERS  (80-byte, FB):  1-8 USERID | 9 DFLTFLAG('*') | 10-17 GROUP | 18 . | 19-26 PASSWORD(now blank)
                       | 27 . | 28 OPER(Y/N) | 30 SPECIAL(Y/N, reserved) | rest blank
SHADOW (48-byte, FB):  1-8 USERID(EBCDIC) | 9-16 SALT(8 raw) | 17-48 HASH(32 raw SHA-256)
```

**Password / salt flow** (ADDUSER / ALTUSER with PASSWORD):
1. `getstck()` → 8-byte salt (unique per set, from the TOD clock).
2. `rakfpwh(salt, pw, len, out32, work)` → `SHA256(salt ‖ pw)` — the exact convention the login path uses.
3. Write/replace the user's `SHADOW` record `userid+salt+out32`; the `USERS` password column stays blank.

**Activation:** on success the tool submits/starts `RAKFUSER` (reads USERS+SHADOW, rebuilds the
in-storage table) via the internal reader — the same mechanism `RAKFPWUP` uses. Configurable; a
`NORELOAD`/dry-run mode just updates the datasets and prints "run RAKFUSER to activate".

---

## 4. RACF command inventory → RAKF mapping

Status legend: **NOW** (this pass) · **P2/P3/P4** (planned phase) · **MODEL-GAP** (needs a new RAKF
concept first) · **N/A** (no RAKF equivalent).

### User commands — operate on USERS + SHADOW
| RACF cmd | RAKF action | Status |
|---|---|---|
| **ADDUSER** | add USERS line(s) + SHADOW record; hash password | **NOW** |
| **ALTUSER** | change attributes / re-hash password / add-remove groups | **NOW** |
| DELUSER | remove all USERS lines + SHADOW record for a userid | **P2** |
| LISTUSER | show userid, groups, OPER/SPECIAL (never the hash) | **P2** |
| CONNECT | add a group-connection USERS line for a user | **P2** |
| REMOVE | delete a group-connection line | **P2** |

### Dataset-profile commands — operate on PROFILES (class DATASET)
| RACF cmd | RAKF action | Status |
|---|---|---|
| ADDSD | add a DATASET profile record (entity + UACC) | **P3** |
| ALTDSD | change a DATASET profile's UACC/attrs | **P3** |
| DELDSD | delete a DATASET profile (+ its permits) | **P3** |
| LISTDSD | display a DATASET profile + access list | **P3** |

### General-resource commands — operate on PROFILES (classes FACILITY, DASDVOL, …)
| RACF cmd | RAKF action | Status |
|---|---|---|
| RDEFINE | add a general-resource profile | **P3** |
| RALTER | change one | **P3** |
| RDELETE | delete one | **P3** |
| RLIST | list one + access list | **P3** |
| **PERMIT** | add/remove access-list (permit) entries on a DATASET or general profile | **P3** (core; ADDSD/RDEFINE lean on it) |

### Group commands
| RACF cmd | RAKF action | Status |
|---|---|---|
| LISTGRP | derived: scan USERS for members, PROFILES for permits granted to the group | **P2** (no registry needed) |
| ADDGROUP | — RAKF has no group *registry*; groups exist only as names in connections/permits | **MODEL-GAP** (needs a new `GROUPS` dataset) |
| ALTGROUP | same | **MODEL-GAP** |
| DELGROUP | same (plus cleanup of connections/permits) | **MODEL-GAP** |

### System / administration
| RACF cmd | RAKF action | Status |
|---|---|---|
| RESTART | map to *reload*: run RAKFPROF + RAKFUSER to refresh in-storage tables (≈ SETROPTS REFRESH) | **P2** (easy, high value) |
| RACPRMCK | repurpose: validate USERS/SHADOW/PROFILES consistency (every user has a shadow record, every permit has a universal record, sorted, …) | **P4** (nice-to-have) |
| RACPRIV | write-down / SECLABEL privileges — RAKF has no MLS/security-label model | **N/A** |

---

## 5. What's built in this pass — ADDUSER & ALTUSER

Only the operands RAKF can represent are honored; unknown operands are reported and rejected.

### ADDUSER
```
ADDUSER userid PASSWORD(pw) DFLTGRP(grp) [GROUP(grp2 grp3 ...)] [OPERATIONS] [SPECIAL]
```
- Fails if `userid` already exists.
- Requires `PASSWORD` and `DFLTGRP` (RAKF needs at least one group + a password to log on).
- Writes a USERS line for the default group (`*` flag at col 9) and one per extra `GROUP`.
- Generates a salt (STCK), hashes `salt‖pw` via `RAKFPWH`, writes the SHADOW record.
- `OPERATIONS` → OPER flag `Y`. `SPECIAL` → SPECIAL flag `Y` (col 30, reserved until the loader/ENTYCHCK honor it — see §7).

### ALTUSER
```
ALTUSER userid [PASSWORD(pw)] [DFLTGRP(grp)] [OPERATIONS|NOOPERATIONS] [SPECIAL|NOSPECIAL]
```
- Fails if `userid` doesn't exist.
- `PASSWORD` → new salt + re-hash → replace the SHADOW record.
- `DFLTGRP` → move the `*` default flag to that group's line (must already be a connected group).
- `OPERATIONS`/`NOOPERATIONS`, `SPECIAL`/`NOSPECIAL` → toggle the flags on the user's lines.

Both share `rakfadm.c` for dataset I/O, record parsing, hashing, and reload.

---

## 6. Build & deploy (to finish with `mbt`)

1. Compile `rakfadm.c`, `adduser.c`, `altuser.c` with the MVS C compiler; assemble `getstck.hlasm`,
   `../SRCLIB/RAKFPWH.hlasm`, `../SRCLIB/RAKFHASH.hlasm`.
2. Link each command as its own load module, e.g. `ADDUSER = adduser + rakfadm + RAKFPWH + RAKFHASH +
   getstck + C runtime`, into a command library (e.g. `SYS1.CMDLIB` or a RAKF `CMDLIB`).
3. Run JCL (or, later, a TSO command) with DDs:
   `//USERS DD DSN=SYS1.SECURE.CNTL(USERS),DISP=SHR`,
   `//SHADOW DD DSN=SYS2.SECURE.SHADOW,DISP=SHR`,
   `//SYSIN DD *` with the command, `//SYSPRINT DD SYSOUT=*`.
4. Because those datasets are RAKF-protected, the executing job must run under a RAKFADM user
   (job card `USER=/PASSWORD=`); an unauthorized caller gets an S913 on OPEN.

> `mbt` note: the C↔HLASM call to `RAKFPWH` uses standard OS linkage (R1 → parm-address list). The
> declaration in `rakfadm.c` is marked accordingly; confirm the compiler's OS-linkage pragma when you
> pick this up. If linking the HLASM proves awkward under `mbt`, the fallback is a C SHA-256 that is
> unit-tested to match `RAKFHASH` against the NIST vectors — but calling the shared routine is preferred.

---

## 7. RAKF model gaps to close for fuller fidelity

These aren't blockers for ADDUSER/ALTUSER but bound how far the rest of the list can go:

- **SPECIAL attribute** — the CBLK DSECT already has `CBLKSPEC`, but `RAKFUSER` doesn't yet load it
  from a USERS column and `ENTYCHCK` doesn't yet honor it. ADDUSER/ALTUSER already *write* the column
  (col 30) so the data is ready; finishing SPECIAL = a small `RAKFUSER` parse change + an `ENTYCHCK`
  bypass (mirror the existing OPER bypass). Until then SPECIAL is inert.
- **Group registry** — needed for ADDGROUP/ALTGROUP/DELGROUP. Proposal: a new `SYS1.SECURE.CNTL(GROUPS)`
  member (group name, superior group, owner) loaded like PROFILES.
- **OWNER attribute** — RACF users/profiles have owners; RAKF has none. Add a column/field if OWNER-
  based administration is wanted.
- **Password policy** — aging/history/complexity aren't modeled; the shadow's reserved `LASTCHG`
  space (design) is the hook for aging later.
- **RACPRIV / SECLABEL / MLS** — not in RAKF's model; out of scope.

---

## 8. Roadmap

- **This pass:** ADDUSER, ALTUSER (+ shared library, salt helper).
- **P2:** DELUSER, LISTUSER, CONNECT, REMOVE, LISTGRP, RESTART(=reload). Finish SPECIAL enforcement.
- **P3:** the profile family — ADDSD/ALTDSD/DELDSD/LISTDSD, RDEFINE/RALTER/RDELETE/RLIST, PERMIT
  (all over the PROFILES dataset).
- **P4:** group registry → ADDGROUP/ALTGROUP/DELGROUP; RACPRMCK consistency checker.
- **N/A:** RACPRIV.
