
#!/bin/bash

set -euo pipefail;

LINUX_OUTPUT_ROOT=/toolchain/linux-output-root

CPUS="$(grep -c processor /proc/cpuinfo)";

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

function build_openssl() {
    pushd /toolchain/src/src/openssl;
    ./config \
        --prefix="$LINUX_OUTPUT_ROOT";
    make "-j$CPUS";
    make install_sw;
    popd;
    cleanup_relink "$LINUX_OUTPUT_ROOT";
}

function build_libffi() {
    pushd /toolchain/src/src/libffi;
    ./configure \
        --disable-docs \
        --enable-shared=yes \
        --enable-static=no \
        --prefix="$LINUX_OUTPUT_ROOT";
    make "-j$CPUS";
    make install;
    popd;
    cleanup_relink "$LINUX_OUTPUT_ROOT";
}

function build_ncurses() {
    pushd /toolchain/src/src/ncurses;
    ./configure \
        --enable-widec \
        --with-shared \
        --without-termlib \
        --without-ticlib \
        --prefix="$LINUX_OUTPUT_ROOT";
    make "-j$CPUS";
    make install;
    popd;
    cleanup_relink "$LINUX_OUTPUT_ROOT";
}

function build_zlib() {
    pushd /toolchain/src/src/zlib;
    ./configure \
        --prefix="$LINUX_OUTPUT_ROOT";
    make "-j$CPUS";
    make install;
    popd;
    cleanup_relink "$LINUX_OUTPUT_ROOT";
}

function build_readline() {
    pushd /toolchain/src/src/readline;
    ./configure \
        --prefix="$LINUX_OUTPUT_ROOT" \
        --enable-shared=yes \
        --enable-static=no;
    make "-j$CPUS";
    make install;
    popd;
    cleanup_relink "$LINUX_OUTPUT_ROOT";
}

build_openssl;
build_libffi;
build_ncurses;
build_zlib;
build_readline;
