#!/bin/sh

NORMAL_USER=alarm

if [ $# = 0 ]; then
    VIRTUAL_ENV_DIR=`pwd`
else
    VIRTUAL_ENV_DIR=$1
fi

echo "===================== Deployment Initiated ==================="
echo -e "Virtual Environment will be created in..." ${VIRTUAL_ENV_DIR}

echo -ne "Checking the current user permissions... "
if ! [ $(id -u) = 0 ]; then
   echo "not root!"
   echo
   echo "CRITICAL: This script must be run as root"
   exit 1
else
   echo "root user, approved"
fi

echo -ne "updating the kernel with pacman... "
pacman -Suy --noconfirm >| /dev/null
echo -e "completed"

echo -ne "Installing the dependencies... "
pacman -S --noconfirm vim git unzip make gcc python2-virtualenv >| /dev/null
echo -e "completed"

echo -e "-------------------- Performing Dependency checks ---------------------"
echo
echo -e "Dependency check after the installation... initiated"
for pkg in {git,unzip,make,gcc,python2-virtualenv}; do
    pacman -Q $pkg >| /dev/null;
    if ! [ $? = 0 ]; then
        echo -e "--> Package" $pkg "not installed :-(";
        exit 1;
    else
	echo -e "--> Package" $pkg "installed and verified successfully :-).";
    fi;
done
echo -e "Dependency check after the installation... completed"

echo
echo -e "setting up the virtualenv in " ${VIRTUAL_ENV_DIR} "... "
echo
su ${NORMAL_USER} -c "virtualenv2 ${VIRTUAL_ENV_DIR}"

echo
echo -e "-------------------- Installing pip requirements ---------------------"
echo
su ${NORMAL_USER} -c "./bin/pip install -r requirements.txt"
echo
echo -e "-------------------- Installing Buildout ---------------------"
echo
su ${NORMAL_USER} -c "./bin/buildout -c buildout.cfg"
echo
echo "===================== Deployment Completed Successfully ==================="

