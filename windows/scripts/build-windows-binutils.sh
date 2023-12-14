#!/bin/bash

set -euo pipefail;

WINDOWS_CONFIGURE_ROOT=/toolchain/windows-configure-root
WINDOWS_BUILD_ROOT=/toolchain/windows-build-root
WINDOWS_OUTPUT_ROOT=/toolchain/windows-output-root

CPUS="$(grep -c processor /proc/cpuinfo )";

function build_binutils() {
    rm -rf "$WINDOWS_CONFIGURE_ROOT/binutils";
    mkdir -p "$WINDOWS_CONFIGURE_ROOT/binutils";
    pushd "$WINDOWS_CONFIGURE_ROOT/binutils";
    /toolchain/src/src/binutils-gdb/configure \
        --host=x86_64-w64-mingw32 \
        --target=arm-none-eabi \
        --enable-initfini-array \
        --disable-nls \
        --without-x \
        --disable-gdbtk \
        --without-tcl \
        --without-tk \
        --enable-plugins \
        --disable-gdb \
        --without-gdb \
        --prefix="$WINDOWS_OUTPUT_ROOT" \
        --with-sysroot="$WINDOWS_OUTPUT_ROOT/arm-none-eabi";
    make "-j$CPUS";
    make install;
    popd;
}
build_binutils;
