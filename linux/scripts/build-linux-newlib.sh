#!/bin/bash

set -euo pipefail;

LINUX_BUILD_ROOT=/toolchain/linux-build-root
LINUX_OUTPUT_ROOT=/toolchain/linux-output-root
LINUX_CONFIGURE_ROOT=/toolchain/linux-configure-root

NEWLIB_ROOT=/toolchain/newlib-root
NEWLIB_NANO_ROOT=/toolchain/newlib-nano-root

CPUS="$(grep -c processor /proc/cpuinfo )";

function build_gcc_newlib() {
    rm -rf "$LINUX_CONFIGURE_ROOT/newlib";
    rm -rf "$NEWLIB_ROOT";
    mkdir -p "$LINUX_CONFIGURE_ROOT/newlib";
    pushd "$LINUX_CONFIGURE_ROOT/newlib";
    CFLAGS_FOR_TARGET="-g -Os -ffunction-sections -fdata-sections" /toolchain/src/src/newlib-cygwin/configure \
        "--prefix=$NEWLIB_ROOT" \
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

function build_gcc_newlib_nano() {
    rm -rf "$LINUX_CONFIGURE_ROOT/newlib-nano";
    rm -rf "$NEWLIB_NANO_ROOT";
    mkdir -p "$LINUX_CONFIGURE_ROOT/newlib-nano";
    pushd "$LINUX_CONFIGURE_ROOT/newlib-nano";
    CFLAGS_FOR_TARGET="-g -Os -ffunction-sections -fdata-sections" /toolchain/src/src/newlib-cygwin/configure \
        "--prefix=$NEWLIB_NANO_ROOT" \
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

build_gcc_newlib;
build_gcc_newlib_nano;
