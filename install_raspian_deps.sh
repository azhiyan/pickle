#!/bin/sh

echo "------------------------ Updating Kernel -------------------------"
echo "Checking the current user permissions... "
if ! [ $(id -u) = 0 ]; then
   echo "Permission denied !"
   echo
   echo "CRITICAL: This script must be run as root"
   exit 1
fi
echo "\n\n"

echo "------------------------ Updating Kernel -------------------------"
apt-get update -y
echo "\n\n"

echo "------------------------ Installing Dependencies -------------------------"

PACKAGES="wget git vim tmux gcc build-essential unzip make libncurses5-dev libncursesw5-dev sqlite sqlite3 libsqlite3-dev openssl libssl-dev"

for pkg in ${PACKAGES};
do
    dpkg -l | awk '$1 == "ii" {print $2}' | grep -i $pkg >| /dev/null;
    if ! [ $? = 0 ]; then
        echo -n "--> Installing package " $pkg "... ";
        apt-get install -y $pkg >| /dev/null
        echo "Completed"
    else
        echo "--> Package" $pkg " is already installed.";
    fi;
done
