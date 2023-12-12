#!/bin/bash

set -euo pipefail;

WINDOWS_CONFIGURE_ROOT=/toolchain/windows-configure-root
WINDOWS_BUILD_ROOT=/toolchain/windows-build-root
WINDOWS_OUTPUT_ROOT=/toolchain/windows-output-root

CPUS="$(grep -c processor /proc/cpuinfo )";

function build_linux_gcc() {
    rm -rf "$WINDOWS_CONFIGURE_ROOT/gcc";
    mkdir -p "$WINDOWS_CONFIGURE_ROOT/gcc";
    pushd "$WINDOWS_CONFIGURE_ROOT/gcc";
    LDFLAGS="-L$WINDOWS_BUILD_ROOT/lib -L$WINDOWS_OUTPUT_ROOT/lib" CPPFLAGS="-I$WINDOWS_BUILD_ROOT/include -I$WINDOWS_OUTPUT_ROOT/include -I$WINDOWS_OUTPUT_ROOT/include/readline" "/toolchain/src/src/arm-gnu-toolchain-src-snapshot-12.3.rel1/configure" \
        "--prefix=$WINDOWS_OUTPUT_ROOT" \
        --target=arm-none-eabi \
        --host=x86_64-w64-mingw32 \
        --with-mpfr=$WINDOWS_BUILD_ROOT \
        --with-gmp=$WINDOWS_BUILD_ROOT \
        --with-mpc=$WINDOWS_BUILD_ROOT \
        --with-isl=$WINDOWS_BUILD_ROOT \
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
        "--with-sysroot=$WINDOWS_OUTPUT_ROOT/arm-none-eabi" \
        --with-multilib-list=rmprofile \
        LDFLAGS="-L$WINDOWS_BUILD_ROOT/lib -L$WINDOWS_OUTPUT_ROOT/lib" \
        CPPFLAGS="-I$WINDOWS_BUILD_ROOT/include -I$WINDOWS_OUTPUT_ROOT/include -I$WINDOWS_OUTPUT_ROOT/include/readline";
    LDFLAGS="-L$WINDOWS_BUILD_ROOT/lib -L$WINDOWS_OUTPUT_ROOT/lib" CPPFLAGS="-I$WINDOWS_BUILD_ROOT/include -I$WINDOWS_OUTPUT_ROOT/include -I$WINDOWS_OUTPUT_ROOT/include/readline" make "-j$CPUS" CXXFLAGS="-g -O2";
    LDFLAGS="-L$WINDOWS_BUILD_ROOT/lib -L$WINDOWS_OUTPUT_ROOT/lib" CPPFLAGS="-I$WINDOWS_BUILD_ROOT/include -I$WINDOWS_OUTPUT_ROOT/include -I$WINDOWS_OUTPUT_ROOT/include/readline" make install;
    popd;
}

build_linux_gcc;
