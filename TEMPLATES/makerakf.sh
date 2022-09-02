#!/binbash

# Bash script to create the SMP4 job stream for RAKF
# This will install RAKF only

cat 01_header.template

cat ../JCLIN/*.jcl

for i in ../MACLIB/*; do
    #++MAC(CJYPCBLK) DISTLIB(AMACLIB)  SYSLIB(MACLIB)
    filename=$(basename -- "$i")
    filename="${filename%.*}"
    echo "++MAC($filename) DISTLIB(AMACLIB)  SYSLIB(MACLIB)."
    cat $i
done

for i in ../SRCLIB/*; do
    filename=$(basename -- "$i")
    filename="${filename%.*}"
    echo "++SRC($filename) DISTLIB(ASRCLIB)  SYSLIB(SRCLIB)."
    cat $i
done

for i in ../PROCLIB/*; do
    filename=$(basename -- "$i")
    filename="${filename%.*}"
    echo "++MAC($filename) DISTLIB(APROCLIB) SYSLIB(PROCLIB)."
    cat $i
done

for i in ../PARMLIB/*; do
    filename=$(basename -- "$i")
    filename="${filename%.*}"
    echo "++MAC($filename) DISTLIB(APARMLIB) SYSLIB(PARMLIB)."
    cat $i
done

cat 02_smp4.template