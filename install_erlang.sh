#!/bin/bash

BUILD_DIR=`pwd`

echo ${BUILD_DIR}

echo "Checking the current user permissions... "
if ! [ $(id -u) = 0 ]; then
   echo "Permission denied !"
   echo
   echo "CRITICAL: This script must be run as root"
   exit 1
fi
echo
echo

if [ -z "$1" ]; then
   echo "argument 1 is not passed!"
   echo "sudo ./install_erlang.sh IP:PORT"
   exit
fi

echo "Checking erlang availablity..."
if [ -f /usr/bin/erl ];then
   eslerlang=`dpkg-query -W esl-erlang`
   if [[ ${eslerlang} = *"esl-erlang"* ]]; then
      echo "Erlang is installed! ${eslerlang}"
      echo "Running Hello world to check if erlang is working..."
      erl -noshell -eval 'io:fwrite("Hello, World!\n"), init:stop().'
   fi
   echo 
else 
   echo "Erlang NOT found in the SYSTEM. INstalling freshly!"
   wget $1/esl-erlang_20.1.7-1_raspbian_stretch_armhf.deb
   dpkg -i esl-erlang_20.1.7-1_raspbian_stretch_armhf.deb
   rm esl-erlang_20.1.7-1_raspbian_stretch_armhf.deb
   echo 
   eslerlang=`dpkg-query -W esl-erlang`
   if [[ ${eslerlang} = *"esl-erlang"* ]]; then
      echo "Erlang is installed! ${eslerlang}"
      echo "Running Hello world to check if erlang is working..."
      erl -noshell -eval 'io:fwrite("Hello, World!\n"), init:stop().'
   fi
   echo
fi
echo "Done!"

