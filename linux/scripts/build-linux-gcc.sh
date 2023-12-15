#!/bin/bash

set -euo pipefail;

LINUX_BUILD_ROOT=/toolchain/linux-build-root
LINUX_OUTPUT_ROOT=/toolchain/linux-output-root
LINUX_CONFIGURE_ROOT=/toolchain/linux-configure-root

NEWLIB_ROOT=/toolchain/newlib-root
NEWLIB_NANO_ROOT=/toolchain/newlib-nano-root

ARCH="$(uname -m | sed 'y/XI/xi/')";
BUILD="$ARCH-linux-gnu";
HOST="$ARCH-linux-gnu";

CPUS="$(grep -c processor /proc/cpuinfo )";

function copy_newlib() {
    rsync -av "$NEWLIB_ROOT/" "$LINUX_OUTPUT_ROOT";
}

function build_linux_gcc() {
    rm -rf "$LINUX_CONFIGURE_ROOT/gcc";
    mkdir -p "$LINUX_CONFIGURE_ROOT/gcc";
    pushd "$LINUX_CONFIGURE_ROOT/gcc";
    LDFLAGS="-L$LINUX_BUILD_ROOT/lib -L$LINUX_OUTPUT_ROOT/lib" CPPFLAGS="-I$LINUX_BUILD_ROOT/include -I$LINUX_OUTPUT_ROOT/include -I$LINUX_OUTPUT_ROOT/include/readline" LD_LIBRARY_PATH="LINUX_OUTPUT_ROOT/lib" "/toolchain/src/src/arm-gnu-toolchain-src-snapshot-12.3.rel1/configure" \
        "--prefix=$LINUX_OUTPUT_ROOT" \
        --target=arm-none-eabi \
        "--disable-libssp" \
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
    LDFLAGS="-L$LINUX_BUILD_ROOT/lib -L$LINUX_OUTPUT_ROOT/lib" CPPFLAGS="-I$LINUX_BUILD_ROOT/include -I$LINUX_OUTPUT_ROOT/include -I$LINUX_OUTPUT_ROOT/include/readline" LD_LIBRARY_PATH="LINUX_OUTPUT_ROOT/lib" make "-j$CPUS" CXXFLAGS="-g -O2";
    LDFLAGS="-L$LINUX_BUILD_ROOT/lib -L$LINUX_OUTPUT_ROOT/lib" CPPFLAGS="-I$LINUX_BUILD_ROOT/include -I$LINUX_OUTPUT_ROOT/include -I$LINUX_OUTPUT_ROOT/include/readline" LD_LIBRARY_PATH="LINUX_OUTPUT_ROOT/lib" make install;
    popd;
}

function build_linux_gcc_nano() {
    rm -rf "$LINUX_CONFIGURE_ROOT/gcc-nano";
    mkdir -p "$LINUX_CONFIGURE_ROOT/gcc-nano";
    pushd "$LINUX_CONFIGURE_ROOT/gcc-nano";
    LDFLAGS="-L$LINUX_BUILD_ROOT/lib -L$LINUX_OUTPUT_ROOT/lib" CPPFLAGS="-I$LINUX_BUILD_ROOT/include -I$LINUX_OUTPUT_ROOT/include -I$LINUX_OUTPUT_ROOT/include/readline" LD_LIBRARY_PATH="LINUX_OUTPUT_ROOT/lib" "/toolchain/src/src/arm-gnu-toolchain-src-snapshot-12.3.rel1/configure" \
        "--prefix=$NEWLIB_NANO_ROOT" \
        "--with-sysroot=$NEWLIB_NANO_ROOT/arm-none-eabi" \
        --target=arm-none-eabi \
        "--disable-libssp" \
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
        --with-multilib-list=rmprofile \
        LDFLAGS="-L$LINUX_BUILD_ROOT/lib -L$LINUX_OUTPUT_ROOT/lib" \
        CPPFLAGS="-I$LINUX_BUILD_ROOT/include -I$LINUX_OUTPUT_ROOT/include -I$LINUX_OUTPUT_ROOT/include/readline";
    LDFLAGS="-L$LINUX_BUILD_ROOT/lib -L$LINUX_OUTPUT_ROOT/lib" CPPFLAGS="-I$LINUX_BUILD_ROOT/include -I$LINUX_OUTPUT_ROOT/include -I$LINUX_OUTPUT_ROOT/include/readline" LD_LIBRARY_PATH="LINUX_OUTPUT_ROOT/lib" make "-j$CPUS" CXXFLAGS_FOR_TARGET="-g -Os -ffunction-sections -fdata-sections -fno-exceptions" CXXFLAGS="-g -O2";
    LDFLAGS="-L$LINUX_BUILD_ROOT/lib -L$LINUX_OUTPUT_ROOT/lib" CPPFLAGS="-I$LINUX_BUILD_ROOT/include -I$LINUX_OUTPUT_ROOT/include -I$LINUX_OUTPUT_ROOT/include/readline" LD_LIBRARY_PATH="LINUX_OUTPUT_ROOT/lib" make install;
    popd;
}

copy_newlib;
build_linux_gcc;
build_linux_gcc_nano;
