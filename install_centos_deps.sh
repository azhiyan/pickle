#!/bin/sh

echo -e "------------------------ Updating Kernel -------------------------"

echo -ne "Checking the current user permissions... "
if ! [ $(id -u) = 0 ]; then
   echo "Permission denied !"
   echo
   echo "CRITICAL: This script must be run as root"
   exit 1
else
   echo "User, approved"
fi

echo -ne "updating the kernel with yum package manager... "
yum update -y >| /dev/null
echo -e "completed"


echo -e "------------------------ Installing Dependencies -------------------------"

echo -e "------------------------ Installing Dependencies -------------------------"

PACKAGES="git vim tmux wget unzip make gcc python-virtualenv sqlite sqlite-devel"

for pkg in ${PACKAGES};
do
    rpm -q $pkg >| /dev/null;
    if ! [ $? = 0 ]; then
        echo -ne "--> Installing package " $pkg "... ";
        yum install -y $pkg >| /dev/null
        echo -e "Completed"
    else
        echo -e "--> Package" $pkg " is already installed.";
    fi;
done
