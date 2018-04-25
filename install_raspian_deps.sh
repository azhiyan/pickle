#!/bin/sh

echo "------------------------ Updating Kernel -------------------------"
echo "Checking the current user permissions... "
if ! [ $(id -u) = 0 ]; then
   echo "Permission denied !"
   echo
   echo "CRITICAL: This script must be run as root"
   exit 1
fi
echo
echo

echo "------------------------ Updating Kernel -------------------------"
apt-get update -y
echo
echo

echo "------------------------ Installing Dependencies -------------------------"

PACKAGES="wget git vim tmux gcc build-essential unzip make libncurses5-dev libncursesw5-dev sqlite sqlite3 libsqlite3-dev openssl libssl-dev"

for pkg in ${PACKAGES};
do
    apt-get install -y $pkg
done


echo
echo "------------------------ Post Installation Checks -------------------------"
for pkg in ${PACKAGES};
do
    echo -n "Checking the package " $pkg " ... "
    dpkg -l | awk -v pkg=$pkg -v status="ii" -F' ' '($2 == pkg) {print}' | awk -F' ' '{if($1 == "ii") {print "SUCCESS"} else {print "FAILED"}}';
    echo
done
