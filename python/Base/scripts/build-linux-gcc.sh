#!/bin/bash

set -euo pipefail;

LINUX_BUILD_ROOT=/toolchain/linux-build-root
LINUX_OUTPUT_ROOT=/toolchain/linux-output-root
LINUX_BUILD_TEMP=/toolchain/linux-build-temp
NEWLIB_NANO_TEMP_ROOT=/toolchain/newlib-nano-temp

ARCH="$(uname -m | sed 'y/XI/xi/')";
BUILD="$ARCH-linux-gnu";
HOST="$ARCH-linux-gnu";

CPUS="$(grep -c processor /proc/cpuinfo )";

function cleanup_relink() {
    local DIRECTORY;
    DIRECTORY="$1";
    rm -rf "$DIRECTORY/share/man"
    relink.sh "$DIRECTORY";
}

function build_linux_gcc() {
    rm -rf "$LINUX_BUILD_TEMP";
    mkdir -p "$LINUX_BUILD_TEMP";
    pushd "$LINUX_BUILD_TEMP";
    LDFLAGS="-L$LINUX_BUILD_ROOT/lib -L$LINUX_OUTPUT_ROOT/lib" CPPFLAGS="-I$LINUX_BUILD_ROOT/include -I$LINUX_OUTPUT_ROOT/include -I$LINUX_OUTPUT_ROOT/include/readline" LD_LIBRARY_PATH="LINUX_OUTPUT_ROOT/lib" "/toolchain/src/src/arm-gnu-toolchain-src-snapshot-12.3.rel1/configure" \
        "--prefix=$LINUX_OUTPUT_ROOT" \
        --target=arm-none-eabi \
        "--build=$BUILD" \
        "--host=$HOST" \
        --with-mpfr=$LINUX_BUILD_ROOT \
        --with-gmp=$LINUX_BUILD_ROOT \
        --with-mpc=$LINUX_BUILD_ROOT \
        --with-isl=$LINUX_BUILD_ROOT \
        --disable-shared \
        --disable-nls \
        --disable-threads \
        --disable-tls \
        --enable-checking=release \
        --enable-languages=c,c++ \
        --enable-lto \
        --with-newlib \
        --with-gnu-as \
        --with-gnu-ld \
        "--with-sysroot=$LINUX_OUTPUT_ROOT/arm-none-eabi" \
        --with-multilib-list=rmprofile \
        LDFLAGS="-L$LINUX_BUILD_ROOT/lib -L$LINUX_OUTPUT_ROOT/lib" \
        CPPFLAGS="-I$LINUX_BUILD_ROOT/include -I$LINUX_OUTPUT_ROOT/include -I$LINUX_OUTPUT_ROOT/include/readline";
    LDFLAGS="-L$LINUX_BUILD_ROOT/lib -L$LINUX_OUTPUT_ROOT/lib" CPPFLAGS="-I$LINUX_BUILD_ROOT/include -I$LINUX_OUTPUT_ROOT/include -I$LINUX_OUTPUT_ROOT/include/readline" LD_LIBRARY_PATH="LINUX_OUTPUT_ROOT/lib" make "-j$CPUS";
    LDFLAGS="-L$LINUX_BUILD_ROOT/lib -L$LINUX_OUTPUT_ROOT/lib" CPPFLAGS="-I$LINUX_BUILD_ROOT/include -I$LINUX_OUTPUT_ROOT/include -I$LINUX_OUTPUT_ROOT/include/readline" LD_LIBRARY_PATH="LINUX_OUTPUT_ROOT/lib" make install;
    popd;
    cleanup_relink "$LINUX_OUTPUT_ROOT";
}

function build_linux_gcc_newlib() {
    rm -rf "$LINUX_BUILD_TEMP";
    mkdir -p "$LINUX_BUILD_TEMP";
    pushd "$LINUX_BUILD_TEMP";
    LDFLAGS="-L$LINUX_BUILD_ROOT/lib -L$LINUX_OUTPUT_ROOT/lib" CPPFLAGS="-I$LINUX_BUILD_ROOT/include -I$LINUX_OUTPUT_ROOT/include -I$LINUX_OUTPUT_ROOT/include/readline" LD_LIBRARY_PATH="LINUX_OUTPUT_ROOT/lib" "/toolchain/src/src/arm-gnu-toolchain-src-snapshot-12.3.rel1/configure" \
        "--prefix=$NEWLIB_NANO_TEMP_ROOT" \
        --target=arm-none-eabi \
        "--build=$BUILD" \
        "--host=$HOST" \
        --with-mpfr=$LINUX_BUILD_ROOT \
        --with-gmp=$LINUX_BUILD_ROOT \
        --with-mpc=$LINUX_BUILD_ROOT \
        --with-isl=$LINUX_BUILD_ROOT \
        --disable-shared \
        --disable-nls \
        --disable-threads \
        --disable-tls \
        --enable-checking=release \
        --enable-languages=c,c++ \
        --enable-lto \
        --with-newlib \
        --with-gnu-as \
        --with-gnu-ld \
        "--with-sysroot=$NEWLIB_NANO_TEMP_ROOT/arm-none-eabi" \
        --with-multilib-list=rmprofile \
        LDFLAGS="-L$LINUX_BUILD_ROOT/lib -L$LINUX_OUTPUT_ROOT/lib" \
        CPPFLAGS="-I$LINUX_BUILD_ROOT/include -I$LINUX_OUTPUT_ROOT/include -I$LINUX_OUTPUT_ROOT/include/readline";
    LDFLAGS="-L$LINUX_BUILD_ROOT/lib -L$LINUX_OUTPUT_ROOT/lib" CPPFLAGS="-I$LINUX_BUILD_ROOT/include -I$LINUX_OUTPUT_ROOT/include -I$LINUX_OUTPUT_ROOT/include/readline" LD_LIBRARY_PATH="LINUX_OUTPUT_ROOT/lib" make "-j$CPUS";
    LDFLAGS="-L$LINUX_BUILD_ROOT/lib -L$LINUX_OUTPUT_ROOT/lib" CPPFLAGS="-I$LINUX_BUILD_ROOT/include -I$LINUX_OUTPUT_ROOT/include -I$LINUX_OUTPUT_ROOT/include/readline" LD_LIBRARY_PATH="LINUX_OUTPUT_ROOT/lib" make install;
    popd;
}

build_linux_gcc;
build_linux_gcc_newlib;
