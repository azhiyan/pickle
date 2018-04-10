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

# echo -ne "updating the kernel with pacman... "
# yum update -y >| /dev/null
# echo -e "completed"


echo -e "------------------------ Installing Dependencies -------------------------"
rm -rvf /var/lib/mysql*

echo -e "------------------------ Installing Dependencies -------------------------"

PACKAGES="git vimi tmux wget unzip make gcc python-virtualenv mariadb"

for pkg in PACKAGES;
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


# echo -e "------------------------ Service Setup -------------------------"
#
# systemctl enable rabbitmq
#
# systemctl enable mysqld
#
#
# systemctl disable app.service
#
# cp -f `pwd`/scripts/app.service /lib/systemd/system/app.service
# chmod 644 /lib/systemd/system/app.service
#
# systemctl daemon-reload
# systemctl enable app.service
#
# shutdown -r now
