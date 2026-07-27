         TITLE 'GETSTCK - 8-BYTE SALT FROM THE TOD CLOCK (STCK)'
* GETSTCK - cc370-callable assembler function.
* Stores the 64-bit TOD clock into the caller's 8-byte buffer, used
* as a per-password salt.  STCK is problem-state, so the cc370 admin
* tools can call it.
* Convention (gccmvs/PDPCLIB, verified from cc370 codegen):
*   R1  -> list of argument VALUES; R1+0 = the buffer address
*   R13 -> save area, R14 = return, R15 = entry.
* as370 has no SAVE/RETURN macros, so linkage is hand-coded (STM/LM),
* like the mbt hello370 'mywto' sample.
GETSTCK  CSECT
         STM   14,12,12(13)     save caller's registers
         LR    12,15            establish base register
         USING GETSTCK,12
         L     2,0(,1)          R2 = buffer address (arg 0)
         STCK  TODVAL           TOD clock -> aligned doubleword
         MVC   0(8,2),TODVAL    copy 8 salt bytes to the buffer
         LM    14,12,12(13)     restore caller's registers
         SR    15,15            return code 0
         BR    14               return to caller
         DS    0D
TODVAL   DS    D                aligned target required by STCK
         LTORG
         END   GETSTCK
