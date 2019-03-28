#!/bin/bash

## Build Global Arrays and DHSVM on Rhea at the OLCF

printf "\n\n Building DHSVM in $(pwd)/DHSVM \n\n"
mkdir -p ./DHSVM
cd ./DHSVM
TOP_DIR=$(pwd)

# Get Global Arrays
git clone https://github.com/GlobalArrays/ga.git
echo ""
# Get DHSVM
git clone -b parallel https://github.com/wperkins/dhsvm-1.git

# Build Global Arrays
GA_TOP=$TOP_DIR/ga/
mkdir -p $GA_TOP/build
GA_BUILD=$GA_TOP/build

cd $GA_TOP
./autogen.sh

printf "\n\n Configuring Global Arrays \n\n"
./configure CC=icc CXX=icpc --prefix="$GA_BUILD"

printf "\n\n Building Global Arrays \n\n"
make
make install

printf "\n\n Building DHSVM \n\n"
DHSVM_TOP=$TOP_DIR/dhsvm-1
mkdir -p $DHSVM_TOP/build
cd $DHSVM_TOP/build

CC=icc
CXX=icpc
LDFLAGS="-L$OLCF_INTEL_ROOT/lib/intel64 -lifcore"
export CC CXX LDFLAGS

# from DHSVM example_configuration.sh
OPTIONS="-Wdev --debug-trycompile"
TIMING="OFF"
BUILD="RelWithDebInfo"
COMMON_FLAGS="\
        -D CMAKE_BUILD_TYPE:STRING=$BUILD \
        -D DHSVM_SNOW_ONLY:BOOL=ON \
        -D DHSVM_BUILD_TESTS:BOOL=OFF \
        -D DHSVM_USE_RBM:BOOL=OFF \
        -D DHSVM_DUMP_TOPO:BOOL=ON \
        -D DHSVM_USE_GPTL:BOOL=$TIMING \
        -D CMAKE_VERBOSE_MAKEFILE:BOOL=TRUE \
"

cmake $OPTIONS \
    -D GA_DIR:STRING="$GA_BUILD" \
    -D GA_EXTRA_LIBS:STRING="-lm" \
    -D GA_TEST_RUNS:STRING="$GA_TOP" \
    -D DHSVM_USE_X11:BOOL=OFF \
    -D DHSVM_USE_NETCDF:BOOL=OFF \
    -D DHSVM_BUILD_TESTS:BOOL=OFF \
    $COMMON_FLAGS \
    ..

cmake --build .
