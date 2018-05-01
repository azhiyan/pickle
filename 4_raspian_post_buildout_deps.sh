#!/bin/sh

BUILD_DIR=`pwd`

echo ${BUILD_DIR}

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

echo
echo "------------------------ Configuring NGINX: STARTED --------------------------"
/etc/init.d/nginx stop
sleep 2

rm -rvf /etc/nginx-config-backup
mv -fv /etc/nginx/ /etc/nginx-config-backup
mkdir /etc/nginx/

cp -fv ${BUILD_DIR}/cfg/nginx.conf /etc/nginx/

/etc/init.d/nginx start
sleep 2
echo "------------------------ Configuring NGINX: COMPLETED --------------------------"
echo


rabbitmqctl add_user test test
rabbitmqctl authenticate_user test test
rabbitmqctl list_users
rabbitmqctl  set_user_tags test administrator
rabbitmqctl list_users
