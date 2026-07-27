         TITLE 'RAKFHASH - SHA-256 Message Digest (S/370, 24-bit)'
***********************************************************************
*  as370 port of ../../SRCLIB/RAKFHASH.hlasm.  Logic is byte-for-byte *
*  identical; the only change is assembler-dependent linkage so it    *
*  builds on the cc370 toolchain:                                     *
*      SAVE (14,12)  -> STM 14,12,12(13)                              *
*      YREGS         -> COPY CLIBREGS                                 *
*  (the RHRET epilogue was already hand-coded L/LM/BR - unchanged.)   *
*  Validated against the NIST vectors on the SRCLIB side; KEEP THIS   *
*  COPY IN SYNC with the original (login path assembles that one).    *
***********************************************************************
         COPY  CLIBREGS           R0..R15 equates (libc370 maclib)
RAKFHASH CSECT
*
* SHA-256 (FIPS 180-4).  Pure register math, no SVCs, reentrant: all
* working storage is in the caller-provided work area, so it is
* callable from ICHSFR00's key-0 login path and from problem-state
* tooling alike.  SINGLE source of truth for RAKF password hashing.
*
* LINKAGE: R1 -> 4 addresses:
*   PLIST+0  A(INPUT)   message bytes
*   PLIST+4  A(INLEN)   fullword input length in bytes (0..RHMAXIN)
*   PLIST+8  A(OUTPUT)  32-byte raw digest area (H0..H7, big-endian)
*   PLIST+12 A(WORK)    work area >= RHWORKL bytes
*   R13 -> caller's 18-word save area.
* RETURN: R15=0 digest produced; R15=8 input too long (OUTPUT kept).
*
RHMAXIN  EQU   119                max input bytes (fits 2 blocks)
*
* --- Prologue: save caller regs (we call out to nothing, so no new
* --- save area is chained).
*
         STM   14,12,12(13)       save caller's R14-R12 in HIS area
         LR    R10,R15            program base
         USING RAKFHASH,R10
         LR    R9,R1              keep parameter-list pointer
         L     R11,12(,R9)        R11 -> caller work area
         USING RHWORKD,R11
         L     R2,0(,R9)          A(INPUT)
         ST    R2,RHINA           save input address
         L     R2,4(,R9)          A(INLEN)
         L     R2,0(,R2)          INLEN value
         ST    R2,RHINLEN         save input length
         L     R2,8(,R9)          A(OUTPUT)
         ST    R2,RHOUTA          save output address
*
* --- Validate length --------------------------------------------- *
*
         L     R3,RHINLEN
         C     R3,=A(RHMAXIN)
         BH    RHTOOLNG           too long - RC=8
*
* --- Seed running hash state H0..H7 with the SHA-256 IV ----------- *
*
         MVC   RHH(32),RHIV
*
* --- Build the padded message in RHMSG (128 bytes) --------------- *
* ---   clear, copy input, append X'80', then the 64-bit length.    *
*
         XC    RHMSG(128),RHMSG   clear both blocks (auto zero-pad)
         L     R3,RHINLEN
         LTR   R3,R3
         BZ    RHNOCPY            empty input - nothing to copy
         BCTR  R3,0               length-1 for EX
         L     R2,RHINA
         EX    R3,RHMVCIN         MVC RHMSG(len),0(R2)
RHNOCPY  DS    0H
         LA    R1,RHMSG           append the X'80' terminator ..
         A     R1,RHINLEN         .. at offset INLEN
         MVI   0(R1),X'80'
*        one block if INLEN <= 55 (room for X'80' + 8-byte length),
*        otherwise two blocks.
         L     R6,RHINLEN
         C     R6,=F'55'
         BH    RHTWO
         LA    R7,64              total padded length = 1 block
         B     RHSETLN
RHTWO    LA    R7,128             total padded length = 2 blocks
RHSETLN  ST    R7,RHTOTL          remember total bytes
         SRL   R7,6               total / 64 = number of blocks
         ST    R7,RHBLKC          block count
*        low 32 bits of the bit-length go at (total-4); the high
*        word stays zero (buffer was cleared) since INLEN is small.
         L     R3,RHINLEN
         SLL   R3,3               bit length = INLEN * 8
         LA    R1,RHMSG
         A     R1,RHTOTL
         S     R1,=F'4'
         ST    R3,0(,R1)          store bit length (big-endian)
*
         LA    R0,RHMSG           BLKPTR -> first block
         ST    R0,RHBLKP
**********************************************************************
* Process each 512-bit block                                        *
**********************************************************************
RHBLOCK  DS    0H
*
* --- Load W[0..15] from the current block (big-endian, direct) --- *
*
         L     R5,RHBLKP          -> current 64-byte block
         LA    R4,RHW             -> W[0]
         LA    R3,16
RHWLD    L     R0,0(,R5)
         ST    R0,0(,R4)
         LA    R5,4(,R5)
         LA    R4,4(,R4)
         BCT   R3,RHWLD
*
* --- Extend the schedule W[16..63] ------------------------------- *
* ---   R4 walks a window whose base is W[t-16]:                    *
* ---     W[t-16]=0(R4) W[t-15]=4(R4) W[t-7]=36(R4)                 *
* ---     W[t-2]=56(R4) W[t]=64(R4)                                 *
*
         LA    R4,RHW
         LA    R3,48              t = 16..63
RHEXT    DS    0H
*        s0 = ror(W[t-15],7) X ror(W[t-15],18) X (W[t-15] >> 3)
         L     R6,4(,R4)          W[t-15]
         LR    R0,R6
         SRL   R0,7
         LR    R1,R6
         SLL   R1,25
         OR    R0,R1              ror7
         LR    R7,R6
         SRL   R7,18
         LR    R1,R6
         SLL   R1,14
         OR    R7,R1              ror18
         XR    R0,R7
         LR    R7,R6
         SRL   R7,3               shr3
         XR    R0,R7              R0 = s0
*        s1 = ror(W[t-2],17) X ror(W[t-2],19) X (W[t-2] >> 10)
         L     R6,56(,R4)         W[t-2]
         LR    R7,R6
         SRL   R7,17
         LR    R1,R6
         SLL   R1,15
         OR    R7,R1              ror17
         LR    R8,R6
         SRL   R8,19
         LR    R1,R6
         SLL   R1,13
         OR    R8,R1              ror19
         XR    R7,R8
         LR    R8,R6
         SRL   R8,10              shr10
         XR    R7,R8              R7 = s1
*        W[t] = W[t-16] + s0 + W[t-7] + s1
         L     R1,0(,R4)          W[t-16]
         ALR   R1,R0              + s0
         AL    R1,36(,R4)         + W[t-7]
         ALR   R1,R7              + s1
         ST    R1,64(,R4)         -> W[t]
         LA    R4,4(,R4)
         BCT   R3,RHEXT
*
* --- Initialise working vars a..h from the running hash ---------- *
*
         MVC   RHA(32),RHH        a,b,c,d,e,f,g,h := H0..H7
*
* --- 64 compression rounds --------------------------------------- *
* ---   R4 -> W[t]   R5 -> K[t]   R3 = round counter                *
*
         LA    R4,RHW
         LA    R5,RHK
         LA    R3,64
RHROUND  DS    0H
*        S1 = ror(e,6) X ror(e,11) X ror(e,25)
         L     R6,RHE
         LR    R0,R6
         SRL   R0,6
         LR    R1,R6
         SLL   R1,26
         OR    R0,R1              ror6
         LR    R7,R6
         SRL   R7,11
         LR    R1,R6
         SLL   R1,21
         OR    R7,R1              ror11
         XR    R0,R7
         LR    R7,R6
         SRL   R7,25
         LR    R1,R6
         SLL   R1,7
         OR    R7,R1              ror25
         XR    R0,R7              R0 = S1
*        ch = (e AND f) X ((NOT e) AND g)
         L     R7,RHF
         NR    R7,R6              e AND f
         L     R8,RHG
         L     R1,RHE
         X     R1,=X'FFFFFFFF'    NOT e
         NR    R8,R1              (NOT e) AND g
         XR    R7,R8              R7 = ch
*        temp1 = h + S1 + ch + K[t] + W[t]
         L     R9,RHHH            h
         ALR   R9,R0              + S1
         ALR   R9,R7              + ch
         AL    R9,0(,R5)          + K[t]
         AL    R9,0(,R4)          + W[t]      R9 = temp1
*        S0 = ror(a,2) X ror(a,13) X ror(a,22)
         L     R6,RHA
         LR    R0,R6
         SRL   R0,2
         LR    R1,R6
         SLL   R1,30
         OR    R0,R1              ror2
         LR    R7,R6
         SRL   R7,13
         LR    R1,R6
         SLL   R1,19
         OR    R7,R1              ror13
         XR    R0,R7
         LR    R7,R6
         SRL   R7,22
         LR    R1,R6
         SLL   R1,10
         OR    R7,R1              ror22
         XR    R0,R7              R0 = S0
*        maj = (a AND b) X (a AND c) X (b AND c)
         L     R7,RHB
         L     R8,RHC
         LR    R1,R6
         NR    R1,R7              a AND b
         LR    R2,R6
         NR    R2,R8              a AND c
         XR    R1,R2
         LR    R2,R7
         NR    R2,R8              b AND c
         XR    R1,R2              R1 = maj
*        temp2 = S0 + maj
         ALR   R0,R1              R0 = temp2
*        h=g; g=f; f=e; e=d+temp1; d=c; c=b; b=a; a=temp1+temp2
         L     R1,RHG
         ST    R1,RHHH            h := g
         L     R1,RHF
         ST    R1,RHG             g := f
         L     R1,RHE
         ST    R1,RHF             f := e
         L     R1,RHD
         ALR   R1,R9
         ST    R1,RHE             e := d + temp1
         L     R1,RHC
         ST    R1,RHD             d := c
         L     R1,RHB
         ST    R1,RHC             c := b
         L     R1,RHA
         ST    R1,RHB             b := a
         LR    R1,R9
         ALR   R1,R0
         ST    R1,RHA             a := temp1 + temp2
*        advance to next W[t] / K[t]
         LA    R4,4(,R4)
         LA    R5,4(,R5)
         BCT   R3,RHROUND
*
* --- Fold working vars back into the running hash ---------------- *
*
         L     R0,RHH+0
         AL    R0,RHA
         ST    R0,RHH+0
         L     R0,RHH+4
         AL    R0,RHB
         ST    R0,RHH+4
         L     R0,RHH+8
         AL    R0,RHC
         ST    R0,RHH+8
         L     R0,RHH+12
         AL    R0,RHD
         ST    R0,RHH+12
         L     R0,RHH+16
         AL    R0,RHE
         ST    R0,RHH+16
         L     R0,RHH+20
         AL    R0,RHF
         ST    R0,RHH+20
         L     R0,RHH+24
         AL    R0,RHG
         ST    R0,RHH+24
         L     R0,RHH+28
         AL    R0,RHHH
         ST    R0,RHH+28
*
* --- Next block, if any ------------------------------------------ *
*
         L     R1,RHBLKP          R0 cannot be a base reg (reads as 0),
         LA    R1,64(,R1)         so advance the block pointer in R1
         ST    R1,RHBLKP
         L     R0,RHBLKC
         S     R0,=F'1'
         ST    R0,RHBLKC
         LTR   R0,R0
         BP    RHBLOCK
*
* --- Emit the digest and return RC=0 ----------------------------- *
*
         L     R1,RHOUTA
         MVC   0(32,R1),RHH       raw 32-byte big-endian digest
         SR    R15,R15
         B     RHRET
*
RHTOOLNG DS    0H
         LA    R15,8
*
* --- Restore R0-R12 and R14, preserve our R15 (RC) and R13 ------- *
*
RHRET    DS    0H
         L     R14,12(,R13)       restore return address
         LM    R0,R12,20(R13)     restore R0-R12 (leave R13,R15)
         BR    R14
*
* --- Executed MVC (length filled in by EX) ----------------------- *
*
RHMVCIN  MVC   RHMSG(0),0(R2)
**********************************************************************
* Constants (read-only - safe for a reentrant module)              *
**********************************************************************
         DS    0F
RHIV     DC    X'6A09E667',X'BB67AE85',X'3C6EF372',X'A54FF53A'
         DC    X'510E527F',X'9B05688C',X'1F83D9AB',X'5BE0CD19'
         DS    0F
RHK      DC    X'428A2F98',X'71374491',X'B5C0FBCF',X'E9B5DBA5'
         DC    X'3956C25B',X'59F111F1',X'923F82A4',X'AB1C5ED5'
         DC    X'D807AA98',X'12835B01',X'243185BE',X'550C7DC3'
         DC    X'72BE5D74',X'80DEB1FE',X'9BDC06A7',X'C19BF174'
         DC    X'E49B69C1',X'EFBE4786',X'0FC19DC6',X'240CA1CC'
         DC    X'2DE92C6F',X'4A7484AA',X'5CB0A9DC',X'76F988DA'
         DC    X'983E5152',X'A831C66D',X'B00327C8',X'BF597FC7'
         DC    X'C6E00BF3',X'D5A79147',X'06CA6351',X'14292967'
         DC    X'27B70A85',X'2E1B2138',X'4D2C6DFC',X'53380D13'
         DC    X'650A7354',X'766A0ABB',X'81C2C92E',X'92722C85'
         DC    X'A2BFE8A1',X'A81A664B',X'C24B8B70',X'C76C51A3'
         DC    X'D192E819',X'D6990624',X'F40E3585',X'106AA070'
         DC    X'19A4C116',X'1E376C08',X'2748774C',X'34B0BCB5'
         DC    X'391C0CB3',X'4ED8AA4A',X'5B9CCA4F',X'682E6FF3'
         DC    X'748F82EE',X'78A5636F',X'84C87814',X'8CC70208'
         DC    X'90BEFFFA',X'A4506CEB',X'BEF9A3F7',X'C67178F2'
         LTORG
**********************************************************************
* Caller-provided work area (mapped, not allocated here)             *
**********************************************************************
RHWORKD  DSECT
RHH      DS    8F                 running hash state H0..H7
RHA      DS    F                  working var a
RHB      DS    F                  working var b
RHC      DS    F                  working var c
RHD      DS    F                  working var d
RHE      DS    F                  working var e
RHF      DS    F                  working var f
RHG      DS    F                  working var g
RHHH     DS    F                  working var h
RHW      DS    64F                message schedule W[0..63]
RHMSG    DS    CL128              padded message (max two blocks)
RHINA    DS    F                  A(input)
RHINLEN  DS    F                  input length in bytes
RHOUTA   DS    F                  A(output digest)
RHTOTL   DS    F                  padded length in bytes
RHBLKP   DS    F                  -> current block
RHBLKC   DS    F                  remaining block count
RHWORKL  EQU   *-RHWORKD          required work-area size
         END   RAKFHASH
