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
    echo "---"
done


echo
echo "------------------------ Post Installation Checks -------------------------"
for pkg in ${PACKAGES};
do
    echo -n "Verifying the package (with version): "
    dpkg-query -W $pkg
done

echo
echo "------------------------ Dependency Installations Complete --------------------------"
echo
