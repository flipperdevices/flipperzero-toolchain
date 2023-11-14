#!/bin/bash

set -euo pipefail;

LINUX_BUILD_ROOT=/toolchain/linux-build-root
LINUX_OUTPUT_ROOT=/toolchain/linux-output-root

CPUS="$(grep -c processor /proc/cpuinfo )";

function build_binutils() {
    pushd /toolchain/src/src/binutils-gdb;
    ./configure \
        --enable-initfini-array \
        --disable-nls \
        --without-x \
        --disable-gdbtk \
        --without-tcl \
        --without-tk \
        --enable-plugins \
        --disable-gdb \
        --without-gdb \
        --target=arm-none-eabi \
        --prefix="$LINUX_OUTPUT_ROOT" \
        --with-sysroot="$LINUX_OUTPUT_ROOT/arm-none-eabi";
    make "-j$CPUS";
    make install;
    popd;
}
build_binutils;
