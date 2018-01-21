#!/bin/sh

NORMAL_USER=alarm

if [ $# = 0 ]; then
    VIRTUAL_ENV_DIR=Project
else
    VIRTUAL_ENV_DIR=$1
fi

echo -e "Virtual Environment will be created as" ${VIRTUAL_ENV_DIR}

echo -ne "Checking the current user permissions... "
if ! [ $(id -u) = 0 ]; then
   echo "not root!"
   echo "CRITICAL: This script must be run as root"
   exit 1
else
   echo "root user, approved"
fi

echo -ne "updating the kernel with pacman... "
#pacman -Suy --noconfirm >| /dev/null
echo -e "completed"

echo -ne "Installing the dependencies... "
#pacman -S --noconfirm vim git unzip make gcc python2-virtualenv >| /dev/null
echo -e "completed"

echo -e "Dependency check after the installation... initiated"
for pkg in {git,unzip,make,gcc,python2-virtualenv}; do
    pacman -Q $pkg >| /dev/null;
    if ! [ $? = 0 ]; then
        echo -e "--> failed for the package" $pkg;
        exit 1;
    else
        echo -e "--> succeeded for the package" $pkg;
    fi;
done
echo -e "Dependency check after the installation... completed"

echo
echo -ne "setting up the virtualenv as " ${VIRTUAL_ENV_DIR} "... "
su ${NORMAL_USER} -c "virtualenv2 ${VIRTUAL_ENV_DIR}"
echo -e "completed"

if ! [ -d ${VIRTUAL_ENV_DIR} ]; then
    echo -e "Virtualenv" ${VIRTUAL_ENV_DIR} "is not created"
    exit 1
fi

echo
su ${NORMAL_USER} -c "cd ${VIRTUAL_ENV_DIR}; ./bin/pip install -r requirements.txt"

