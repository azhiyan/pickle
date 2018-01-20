#!/bin/sh

PYTHON_VERSION=2.7.14
PYTHON_DIR=Python-${PYTHON_VERSION}
PYTHON_TAR=${PYTHON_DIR}.tar.xz

SETUPTOOLS_VERSION=38.4.0
SETUPTOOLS_DIR=setuptools-${SETUPTOOLS_VERSION}
SETUPTOOLS_ZIP=${SETUPTOOLS_DIR}.zip

VIRTUALENV_VERSION=15.1.0
VIRTUALENV_DIR=virtualenv-${VIRTUALENV_VERSION}
VIRTUALENV_TAR=${VIRTUALENV_DIR}.tar.gz

PIP_VERSION=9.0.1
PIP_DIR=pip-${PIP_VERSION}
PIP_TAR=${PIP_DIR}.tar.gz

ZC_BUILDOUT_VERSION=2.10.0
ZC_BUILDOUT_DIR=zc.buildout-${ZC_BUILDOUT_VERSION}
ZC_BUILDOUT_TAR=${ZC_BUILDOUT_DIR}.tar.gz

HOME_DIR=`pwd`
DEP_DIR=${HOME_DIR}/dependencies

cd_home() {
    cd ${HOME_DIR}
}

rm_dir_if_exists() {
    if [ -d $1 ]; then
        echo "cleaning up" $1
        rm -rf $1
    fi
}

install_python() {
    rm_dir_if_exists ${DEP_DIR}/${PYTHON_DIR}

    tar -xJf ${DEP_DIR}/${PYTHON_TAR} --directory=${DEP_DIR}

    cd ${DEP_DIR}/${PYTHON_DIR}

    if [ -f "${HOME_DIR}/bin/python" ]; then
        echo "WARN: Python is already installed as ./bin/python"
    else
        # "make clean" may be necessary here for earlier versions
        ./configure --prefix=`pwd`/../../ --enable-unicode=ucs4
        make
        make install

        echo "INFO: Python is successfully installed as ./bin/python"
    fi

    rm_dir_if_exists ${DEP_DIR}/${PYTHON_DIR}

    cd_home
}

install_setuptools() {
    rm_dir_if_exists ${DEP_DIR}/${SETUPTOOLS_DIR}

    cd ${DEP_DIR}

    unzip ${SETUPTOOLS_ZIP}

    cd ${SETUPTOOLS_DIR}

    ${HOME_DIR}/bin/python setup.py install

    cd_home

    rm_dir_if_exists ${DEP_DIR}/${SETUPTOOLS_DIR}

}

install_virtualenv() {
    rm_dir_if_exists ${DEP_DIR}/${VIRTUALENV_DIR}

    tar -xzf ${DEP_DIR}/${VIRTUALENV_TAR} --directory=${DEP_DIR}

    cd ${DEP_DIR}/${VIRTUALENV_DIR}

    ${HOME_DIR}/bin/python setup.py install

    rm_dir_if_exists ${DEP_DIR}/${VIRTUALENV_DIR}

    cd_home
}

install_pip() {
    rm_dir_if_exists ${DEP_DIR}/${PIP_DIR}

    ${HOME_DIR}/bin/python ${DEP_DIR}/get-pip.py

    rm_dir_if_exists ${DEP_DIR}/${PIP_DIR}
}

install_zc_buildout() {
    rm_dir_if_exists ${DEP_DIR}/${ZC_BUILDOUT_DIR}

    tar -xzf ${DEP_DIR}/${ZC_BUILDOUT_TAR} --directory=${DEP_DIR}

    cd ${DEP_DIR}/${ZC_BUILDOUT_DIR}

    ${HOME_DIR}/bin/python setup.py install

    rm_dir_if_exists ${DEP_DIR}/${ZC_BUILDOUT_DIR}

    cd_home
}

install_python
install_setuptools
install_virtualenv
install_pip
install_zc_buildout
