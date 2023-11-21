#!/bin/bash

set -euo pipefail;

LINUX_BUILD_ROOT=/toolchain/linux-build-root
LINUX_OUTPUT_ROOT=/toolchain/linux-output-root

CPUS="$(grep -c processor /proc/cpuinfo )";

function build_gmp() {
    pushd /toolchain/src/src/gmp;
    ./configure --disable-maintainer-mode \
        --prefix="$LINUX_BUILD_ROOT" \
        --disable-shared \
        --host=x86_64-none-linux-gnu;
    make "-j$CPUS";
    make install;
    popd;
}

function build_mpfr() {
    pushd /toolchain/src/src/mpfr;
    ./configure --disable-maintainer-mode \
        --prefix="$LINUX_BUILD_ROOT" \
        --with-gmp="$LINUX_BUILD_ROOT" \
        --disable-shared;
    make "-j$CPUS";
    make install;
    popd;
}

function build_mpc() {
    pushd /toolchain/src/src/mpc;
    ./configure --disable-maintainer-mode \
        --prefix="$LINUX_BUILD_ROOT" \
        --with-gmp="$LINUX_BUILD_ROOT" \
        --with-mpfr="$LINUX_BUILD_ROOT" \
        --disable-shared;
    make "-j$CPUS";
    make install;
    popd;
}

function build_isl() {
    pushd /toolchain/src/src/isl;
    ./configure \
        --prefix="$LINUX_BUILD_ROOT" \
        --with-gmp-prefix="$LINUX_BUILD_ROOT" \
        --disable-shared;
    make "-j$CPUS";
    make install;
    popd;
}

function build_libexpat() {
    pushd /toolchain/src/src/libexpat/expat;
    ./configure \
        --prefix="$LINUX_BUILD_ROOT" \
        --without-docbook \
        --without-xmlwf;
    make "-j$CPUS";
    make install;
    popd;
}

function build_newlib() {
    pushd /toolchain/src/src/newlib-cygwin;
    ./configure \
        --prefix="$LINUX_OUTPUT_ROOT" \
        --disable-newlib-supplied-syscalls \
        --enable-newlib-retargetable-locking \
        --enable-newlib-reent-check-verify \
        --enable-newlib-io-long-long \
        --enable-newlib-io-c99-formats \
        --enable-newlib-register-fini \
        --enable-newlib-mb \
        --target=arm-none-eabi;
    make "-j$CPUS";
    make install;
    popd;
}

build_gmp;
build_mpfr;
build_mpc;
build_isl;
build_libexpat;
#build_newlib;
