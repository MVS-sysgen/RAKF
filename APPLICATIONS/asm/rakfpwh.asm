         TITLE 'RAKFPWH - Salted password hash (SHA-256 of SALT||PW)'
***********************************************************************
*  as370 port of ../../SRCLIB/RAKFPWH.hlasm.  Logic is identical;     *
*  only the assembler-dependent bits differ so it builds on the       *
*  cc370 toolchain:                                                   *
*      SAVE  (14,12)        -> STM 14,12,12(13)                       *
*      RETURN (14,12),RC=0  -> LM 14,12,12(13) / SR 15,15 / BR 14     *
*      YREGS                -> COPY CLIBREGS                          *
*  KEEP IN SYNC WITH THE SRCLIB ORIGINAL (the MVS/RAKF login path     *
*  assembles that one; both must compute the same digest).           *
***********************************************************************
         COPY  CLIBREGS           R0..R15 equates (libc370 maclib)
RAKFPWH  CSECT
*
* NAME: RAKFPWH  -  digest = SHA-256( SALT(8) || PASSWORD(pwlen) )
*
* This is the SINGLE definition of the hashing convention: the login
* path (ICHSFR00) and the ADDUSER/ALTUSER tools both call it so they
* agree byte-for-byte.  Pure computation, no SVCs, reentrant.
*
* LINKAGE: R1 -> 5 addresses:
*   PLIST+0  A(SALT)      8-byte salt
*   PLIST+4  A(PASSWORD)  password bytes
*   PLIST+8  A(PWLEN)     fullword password length (1..8)
*   PLIST+12 A(OUTPUT)    32-byte digest area
*   PLIST+16 A(WORK)      work area >= RPWWORKL bytes
*   R13 -> caller's 18-word save area.   RETURN: R15 = 0.
*
         STM   14,12,12(13)       save caller's regs in HIS area
         LR    R12,R15            program base
         USING RAKFPWH,R12
         LR    R9,R1              keep parameter-list pointer
         L     R11,16(,R9)        R11 -> caller work area
         USING RPWWORKD,R11
*
* --- chain our own save area (we call out to RAKFHASH) ------------- *
*
         LA    R2,RPWSAVE
         ST    R13,4(,R2)         back chain -> caller save area
         ST    R2,8(,R13)         forward chain
         LR    R13,R2             R13 -> our save area
*
* --- build SALT(8) || PASSWORD(pwlen) in PWBUF -------------------- *
*
         L     R3,0(,R9)          A(salt)
         MVC   PWBUF(8),0(R3)     salt into first 8 bytes
         L     R4,8(,R9)          A(pwlen)
         L     R4,0(,R4)          pwlen value
         L     R5,4(,R9)          A(password)
         LR    R6,R4              pwlen
         BCTR  R6,0               pwlen-1 for EX
         EX    R6,PWMVC           MVC PWBUF+8(pwlen),0(R5)
         LA    R6,8               hash length = 8 + pwlen
         AR    R6,R4
         ST    R6,PWHLEN
*
* --- call RAKFHASH(A(PWBUF),A(PWHLEN),A(OUTPUT),A(PWHWK)) ---------- *
*
         LA    R0,PWBUF
         ST    R0,RPWPL+0
         LA    R0,PWHLEN
         ST    R0,RPWPL+4
         L     R0,12(,R9)         caller's A(OUTPUT)
         ST    R0,RPWPL+8
         LA    R0,PWHWK
         ST    R0,RPWPL+12
         LA    R1,RPWPL
         L     R15,=V(RAKFHASH)
         BALR  R14,R15
*
* --- return ------------------------------------------------------- *
*
         L     R13,4(,R13)        restore caller save area
         LM    14,12,12(13)       restore caller's registers
         SR    15,15              return code 0
         BR    14                 return to caller
*
* --- Executed MVC (length filled in by EX) ------------------------ *
*
PWMVC    MVC   PWBUF+8(0),0(R5)
         LTORG
***********************************************************************
* Caller-provided work area (mapped, not allocated here)             *
***********************************************************************
RPWWORKD DSECT
RPWSAVE  DS    18F                save area for calling RAKFHASH
RPWPL    DS    4F                 parameter list to RAKFHASH
PWBUF    DS    CL16               SALT(8) || PASSWORD(<=8)
PWHLEN   DS    F                  hash input length (8+pwlen)
PWHWK    DS    CL512              RAKFHASH work area (>= RHWORKL)
RPWWORKL EQU   *-RPWWORKD         required work-area size
         END   RAKFPWH
