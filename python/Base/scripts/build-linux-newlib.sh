#!/bin/bash

set -euo pipefail;

NEWLIB_NANO_TEMP_ROOT=/toolchain/newlib-nano-temp
LINUX_OUTPUT_ROOT=/toolchain/linux-output-root

CPUS="$(grep -c processor /proc/cpuinfo )";

function build_new_lib() {
    pushd /toolchain/src/src/newlib-cygwin;
    CFLAGS_FOR_TARGET="-g -Os -ffunction-sections -fdata-sections" ./configure \
        "--prefix=$LINUX_OUTPUT_ROOT" \
        --target=arm-none-eabi \
        --disable-newlib-supplied-syscalls \
        --enable-newlib-retargetable-locking \
        --enable-newlib-reent-check-verify \
        --enable-newlib-io-long-long \
        --enable-newlib-io-c99-formats \
        --enable-newlib-register-fini \
        --enable-newlib-mb;
    make "-j$CPUS";
    make install;
    popd;
}

function build_new_lib_nano() {
    pushd /toolchain/src/src/newlib-cygwin;
    CFLAGS_FOR_TARGET="-g -Os -ffunction-sections -fdata-sections" ./configure \
        "--prefix=$NEWLIB_NANO_TEMP_ROOT" \
        --target=arm-none-eabi \
        --disable-newlib-supplied-syscalls \
        --enable-newlib-retargetable-locking \
        --enable-newlib-reent-check-verify \
        --enable-newlib-nano-malloc \
        --disable-newlib-unbuf-stream-opt \
        --enable-newlib-reent-small \
        --disable-newlib-fseek-optimization \
        --enable-newlib-nano-formatted-io \
        --disable-newlib-fvwrite-in-streamio \
        --disable-newlib-wide-orient \
        --enable-lite-exit \
        --enable-newlib-global-atexit
    make "-j$CPUS";
    make install;
    popd;
}

build_new_lib;
build_new_lib_nano;
