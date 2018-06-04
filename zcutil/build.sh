#!/bin/bash

set -eu -o pipefail

if [ "x$*" = 'x--help' ]
then
    cat <<EOF
Usage:

$0 --help
  Show this help message and exit.

$0 [ --enable-lcov ] [ MAKEARGS... ]
  Build Zcash and most of its transitive dependencies from
  source. MAKEARGS are applied to both dependencies and Zcash itself. If
  --enable-lcov is passed, Zcash is configured to add coverage
  instrumentation, thus enabling "make cov" to work.
EOF
    exit 0
fi

set -x
cd "$(dirname "$(readlink -f "$0")")/.."

# If --enable-lcov is the first argument, enable lcov coverage support:
LCOV_ARG=''
HARDENING_ARG='--enable-hardening'
if [ "x${1:-}" = 'x--enable-lcov' ]
then
    LCOV_ARG='--enable-lcov'
    HARDENING_ARG='--disable-hardening'
    shift
fi

# BUG: parameterize the platform/host directory:
PREFIX="$(pwd)/depends/x86_64-unknown-linux-gnu/"

#cat src/cl_zogminer_kernel.cl | ./zcutil/stringify_ocl.sh > src/cl_zogminer_kernel.h

# This is a simpler solution. It doesn't strip comments however. I think most linux machines have xxd. 
xxd -i src/libzogminer/kernels/cl_zogminer_kernel.cl \
|  sed 's/unsigned/const unsigned/;s/unsigned int/size_t/;s/src_libzogminer_kernels_cl_zogminer_kernel_cl/CL_MINER_KERNEL/;s/_len/_SIZE/'> \
src/libzogminer/kernels/cl_zogminer_kernel.h



make "$@" -C ./depends/ V=1 NO_QT=1
./autogen.sh
#./configure --prefix="${PREFIX}" --with-gui=no "$HARDENING_ARG" "$LCOV_ARG" CXXFLAGS='-fwrapv -fno-strict-aliasing -g' 
./configure --prefix=/home/aguha/zcash/zogminer/depends/x86_64-unknown-linux-gnu/ --with-gui=no --enable-hardening '' CXXFLAGS='-I/home/aguha/intelFPGA_pro/17.1/hld/host/include -fwrapv -fno-strict-aliasing -g' LDFLAGS='-L/home/aguha/intelFPGA_pro/17.1/hld/board/a10_ref/linux64/lib -L/home/aguha/intelFPGA_pro/17.1/hld/host/linux64/lib -Wl,--no-as-needed -lalteracl -laltera_a10_ref_mmd -lelf'
make "$@" V=1
