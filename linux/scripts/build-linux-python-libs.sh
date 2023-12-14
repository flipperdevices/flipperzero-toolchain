
#!/bin/bash

set -euo pipefail;

LINUX_CONFIGURE_ROOT=/toolchain/linux-configure-root
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
    rm -rf "$LINUX_CONFIGURE_ROOT/openssl";
    mkdir -p "$LINUX_CONFIGURE_ROOT/openssl";
    pushd "$LINUX_CONFIGURE_ROOT/openssl";
    /toolchain/src/src/openssl/config \
        --prefix="$LINUX_OUTPUT_ROOT";
    make "-j$CPUS";
    make install_sw;
    popd;
    cleanup_relink "$LINUX_OUTPUT_ROOT";
}

function build_libffi() {
    rm -rf "$LINUX_CONFIGURE_ROOT/libffi";
    mkdir -p "$LINUX_CONFIGURE_ROOT/libffi";
    pushd "$LINUX_CONFIGURE_ROOT/libffi";
    /toolchain/src/src/libffi/configure \
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
    rm -rf "$LINUX_CONFIGURE_ROOT/ncurses";
    mkdir -p "$LINUX_CONFIGURE_ROOT/ncurses";
    pushd "$LINUX_CONFIGURE_ROOT/ncurses";
    /toolchain/src/src/ncurses/configure \
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
    rm -rf "$LINUX_CONFIGURE_ROOT/zlib";
    mkdir -p "$LINUX_CONFIGURE_ROOT/zlib";
    pushd "$LINUX_CONFIGURE_ROOT/zlib";
    /toolchain/src/src/zlib/configure \
        --prefix="$LINUX_OUTPUT_ROOT";
    make "-j$CPUS";
    make install;
    popd;
    cleanup_relink "$LINUX_OUTPUT_ROOT";
}

function build_readline() {
    rm -rf "$LINUX_CONFIGURE_ROOT/readline";
    mkdir -p "$LINUX_CONFIGURE_ROOT/readline";
    pushd "$LINUX_CONFIGURE_ROOT/readline";
    /toolchain/src/src/readline/configure \
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
