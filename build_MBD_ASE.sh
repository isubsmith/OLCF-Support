#!/bin/bash

## Build a Python3 virtual environment with MBD and ASE packages installed.

################# POINT ME TO ASEMBD.tar.gz ##################
ASEMBD=/lustre/atlas/proj-shared/gen107/morrison/ASEMBD.tar.gz
##############################################################

printf "\n\n Building a Python3 virtual environment with MBD + ASE... \n\n"

VENV_NAME=MBD_ASE_venv_py3
TOP_DIR=$(pwd)
VENV_DIR=$TOP_DIR/$VENV_NAME
PYTHON_VERSION=3.6.5

mkdir -p $TOP_DIR/ASEMBD
tar -zxvf $ASEMBD -C $TOP_DIR/ASEMBD

module swap PrgEnv-pgi PrgEnv-gnu
module swap craype-interlagos craype-istanbul
module load python/$PYTHON_VERSION

printf "\n ==> USING PYTHON: $PYTHON_VERSION "
printf "\n ==> VIRTUAL ENVIRONENT NAME: $VENV_NAME "
printf "\n ==> VIRTUAL ENVIRONMENT PATH: $VENV_DIR \n"

python3 -m venv $VENV_NAME
cd $VENV_DIR
source bin/activate

CC=cc CXX=CC MPICC=cc MPICXX=CC pip install -v --no-binary :all: mpi4py
pip install numpy

git clone https://github.com/martinst0/mbd.git
cd ./mbd
cp system.example.mk system.mk

## Edits to system.mk specific to Titan system at ORNL
sed -i "/CFLAGS/c\CFLAGS = \$(addprefix -Wno-,\${c_warnings_off}) -I\${CRAY_LIBSCI_PREFIX_DIR}/include" system.mk
sed -i "/FFLAGS/c\FFLAGS = \$(addprefix -Wno-,\${f_warnings_off}) -I\${CRAY_LIBSCI_PREFIX_DIR}/include" system.mk
sed -i "/FVENDOR/c\FVENDOR = gnu95" system.mk
sed -i "/CVENDOR/c\CVENDOR = unix" system.mk
sed -i "/FC/c\FC = ftn" system.mk
sed -i "/LDFLAGS/c\LDFLAGS = -L\${CRAY_LIBSCI_PREFIX_DIR}/lib -lsci_gnu_mpi_mp -lpthread -lm -ldl" system.mk

make clean
CC=cc CXX=CC FC=ftn make mbd_scalapack

cd $VENV_DIR
git clone https://gitlab.com/ase/ase.git
cd ase
cp -R $TOP_DIR/ASEMBD/alpha_FI_refdata $VENV_DIR/ase/ase/calculators
cp $TOP_DIR/ASEMBD/ase_mbd.py $VENV_DIR/ase/ase/calculators
cp $TOP_DIR/ASEMBD/AlphaModel.py $VENV_DIR/ase/ase/calculators

python3 setup.py install

printf "\n\n ***************** done ***************** \n\n"
