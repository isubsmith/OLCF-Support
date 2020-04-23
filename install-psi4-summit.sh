#!/bin/bash

set -e

module purge
module load gcc/6.4.0 spectrum-mpi cuda cmake openblas python

## SET OLCF PROJECT ID
OLCF_PROJECT="ABC123"

SRCDIR="${SRCDIR:-$HOME/psi4}"
BUILDDIR="${BUILDDIR:-$MEMBERWORK/${OLCF_PROJECT}/tmp/psi4-build}"
MYCONDAENV="${MYCONDAENV:-/ccs/proj/${OLCF_PROJECT}/$USER/summit/opt/psi4_conda}"
INSTALLDIR="${INSTALLDIR:-/ccs/proj/${OLCF_PROJECT}/$USER/summit/opt/psi4}"

rm -rf "${INSTALLDIR}"
rm -rf "${BUILDDIR}"
mkdir -p "${BUILDDIR}"


USE_MYCONDAENV=true
if [ "$USE_MYCONDAENV" = true ]; then
  # Setup conda env
  if [ ! -f "${MYCONDAENV}/bin/python" ]; then
    conda create -p "${MYCONDAENV}" python=3.6 numpy scipy matplotlib setuptools
    . activate "${MYCONDAENV}"
    pip install networkx
    pip install pint
    pip install pydantic
    pip install qcelemental
    pip install pytest
  fi

  # Activate conda env
  if [ -z "${CONDA_PREFIX:-}" ]; then
    . activate "${MYCONDAENV}"
  elif [ "${CONDA_PREFIX}" != "${MYCONDAENV}" ]; then
    conda deactivate
    . activate "${MYCONDAENV}"
  fi
fi

PYTHON_BIN="$(which python3)"
echo "Using python from '${PYTHON_BIN}'"

cd "${BUILDDIR}"

cmake -B. -DCMAKE_INSTALL_PREFIX="${INSTALLDIR}" \
   -DCMAKE_C_COMPILER="${OLCF_GCC_ROOT}/bin/gcc" \
   -DCMAKE_CXX_COMPILER="${OLCF_GCC_ROOT}/bin/g++" \
   -DCMAKE_Fortran_COMPILER="${OLCF_GCC_ROOT}/bin/gfortran" \
   -DPYTHON_EXECUTABLE="${PYTHON_BIN}" \
   -DPYTHON_LIBRARY="${PYTHON_BIN}/../lib/libpython3.6m.so" \
   -DPYTHON_INCLUDE_DIR="${PYTHON_BIN}/../include/python3.6m" \
   "${SRCDIR}"| tee build.log

make -j8 | tee -a build.log
make install | tee -a build.log
