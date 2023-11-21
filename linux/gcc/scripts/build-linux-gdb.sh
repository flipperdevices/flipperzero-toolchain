#!/bin/bash

set -euo pipefail;

LINUX_BUILD_ROOT=/toolchain/linux-build-root
LINUX_OUTPUT_ROOT=/toolchain/linux-output-root

CPUS="$(grep -c processor /proc/cpuinfo )";

function cleanup_relink() {
    local DIRECTORY;
    DIRECTORY="$1";
    find "$DIRECTORY" \
        -type f \
        -name "*.a" \
        -delete;
    rm -rf "$DIRECTORY/share/man"
    relink.sh "$DIRECTORY";
}

function build_linux_gdb() {
    pushd /toolchain/src/src/binutils-gdb
    LDFLAGS="-L$LINUX_BUILD_ROOT/lib -L$LINUX_OUTPUT_ROOT/lib" CPPFLAGS="-I$LINUX_BUILD_ROOT/include -I$LINUX_OUTPUT_ROOT/include -I$LINUX_OUTPUT_ROOT/include/readline" LD_LIBRARY_PATH="LINUX_OUTPUT_ROOT/lib" ./configure \
        --enable-initfini-array \
        --enable-tui \
        --disable-nls \
        --without-x \
        --disable-gdbtk \
        --without-tcl \
        --without-tk \
        --without-libunwind-ia64 \
        --without-lzma \
        --without-babeltrace \
        --without-intel-pt \
        --without-xxhash \
        --without-debuginfod \
        --without-guile \
        --disable-source-highlight \
        --disable-objc-gc \
        --with-expat \
        "--with-libexpat-prefix=$LINUX_BUILD_ROOT" \
        --with-libexpat-type=static \
        --disable-binutils \
        --disable-sim \
        --disable-as \
        --disable-ld \
        --enable-plugins \
        --target=arm-none-eabi \
        "--prefix=$LINUX_OUTPUT_ROOT" \
        "--with-libmpfr-prefix=$LINUX_BUILD_ROOT" \
        --with-libmpfr-type=static \
        "--with-mpfr=$LINUX_BUILD_ROOT" \
        "--with-libgmp-prefix=$LINUX_BUILD_ROOT" \
        --with-libgmp-type=static \
        "--with-gmp=$LINUX_BUILD_ROOT" \
        "--with-curses=$LINUX_OUTPUT_ROOT" \
        LDFLAGS="-L$LINUX_BUILD_ROOT/lib -L$LINUX_OUTPUT_ROOT/lib" \
        CPPFLAGS="-I$LINUX_BUILD_ROOT/include -I$LINUX_OUTPUT_ROOT/include -I$LINUX_OUTPUT_ROOT/include/readline";
    LDFLAGS="-L$LINUX_BUILD_ROOT/lib -L$LINUX_OUTPUT_ROOT/lib" CPPFLAGS="-I$LINUX_BUILD_ROOT/include -I$LINUX_OUTPUT_ROOT/include -I$LINUX_OUTPUT_ROOT/include/readline" LD_LIBRARY_PATH="LINUX_OUTPUT_ROOT/lib" make "-j$CPUS";
    LDFLAGS="-L$LINUX_BUILD_ROOT/lib -L$LINUX_OUTPUT_ROOT/lib" CPPFLAGS="-I$LINUX_BUILD_ROOT/include -I$LINUX_OUTPUT_ROOT/include -I$LINUX_OUTPUT_ROOT/include/readline" LD_LIBRARY_PATH="LINUX_OUTPUT_ROOT/lib" make install;
    popd;
    cleanup_relink "$LINUX_OUTPUT_ROOT";
}
build_linux_gdb;
