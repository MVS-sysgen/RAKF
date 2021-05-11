# Installs RAKF
# For use with Jay Moseley sysgen MVS only

source ../../00_sysgen_functions.sh
trap 'check_return' 0

echo_step "Building User and profiles DB"

# Users
# If someone edited the users file before hand but didn't sort it we gotchu
users=$(cat USERS.txt)
profiles=$(cat PROFILES.txt)

set -e

IFS=$'\n'

x=100
u=''

if [[ ! -z "${RAKFUSER}" ]]; then
#                                   UUUUUUUU
    users=$(echo -n "$users"|sed "s/HMVS01  /$(printf "%-8s" ${RAKFUSER})/")
fi

if [[ ! -z "${RAKFPASS}" ]]; then
#                                   PPPPPPPP
    users=$(echo -n "$users"|sed "s/CUL8TR  /$(printf "%-8s" ${RAKFPASS})/")
fi

users=$(echo -n "$users")

x=100
u=''

for i in $users
do
    u="${u}""$(printf "%-72s%08d" $i $x)"$'\n'
    x=$((x+100))
done

x=100
p=''
for i in $profiles
do
    p="${p}""$(printf "%-72s%08d" $i $x)"$'\n'
    x=$((x+100))
done

ESCAPED_DATA="$(echo -n "${u}" | sed ':a;N;$!ba;s/\n/\\n/g' )"
sed 's/###### USERS REPLACED BY install_rakf.sh/'"${ESCAPED_DATA}"'/' 12_rakf_users_profiles.template > 12_rakf_users_profiles.jcl

ESCAPED_DATA="$(echo -n "${p}" | sed ':a;N;$!ba;s/\n/\\n/g' )"
sed -i 's/###### PROFILES REPLACED BY install_rakf.sh/'"${ESCAPED_DATA}"'/' 12_rakf_users_profiles.jcl

cd ../../sysgen
echo_step "Starting Hercules: hercules -f conf/local.cnf -r ../SOFTWARE/RAKF/install.rc"
hercules -f conf/local.cnf -r ../SOFTWARE/RAKF/install.rc > hercules.log

check_failure

echo_step "Backing up hercules.log to hercules_log.rakf.$date_time.log"
mv hercules.log hercules_log.rakf.$date_time.log
echo_step "Backing up prt00e.txt to prt00e.rakf.$date_time.txt"
cp prt00e.txt prt00e.rakf.$date_time.txt

echo_step "backing up DASD folder to dasd.rakf.$date_time.tar"
tar cvf dasd.rakf.$date_time.tar ./dasd
cd ../..

trap : 0