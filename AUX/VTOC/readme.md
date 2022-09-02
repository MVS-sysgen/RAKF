# VTOC
VTOC is a TSO command to list DSCB information for selected datasets.

The version used here is an adaption of CBT File 112, modified by Phil Roberts. It extends the functionality of the VTOC version distributed with the Tur(n)key 3 MVS system by the ability to display the RACF indicator of the listed datasets and to use the RACF indicator.

## Building

To install run `./make_JCL.sh > vtoc.jcl` and submit the jobstream `vtoc.jcl`