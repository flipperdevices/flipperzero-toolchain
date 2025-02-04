#!/bin/bash

set -euo pipefail;

. /toolchain/src/buildvars.sh

function build_python() {
    rm -rf "$LINUX_CONFIGURE_ROOT/python";
    mkdir -p "$LINUX_CONFIGURE_ROOT/python";
    pushd "$LINUX_CONFIGURE_ROOT/python";
    LD_LIBRARY_PATH="$LINUX_OUTPUT_ROOT/lib" /toolchain/src/src/python/configure \
        --prefix="$LINUX_OUTPUT_ROOT" \
        --with-openssl="$LINUX_OUTPUT_ROOT" \
        --with-openssl-rpath="$LINUX_OUTPUT_ROOT" \
        --with-system-ffi \
        --enable-shared \
        LDFLAGS="-L$LINUX_OUTPUT_ROOT/lib" \
        CPPFLAGS="-I$LINUX_OUTPUT_ROOT/include -I$LINUX_OUTPUT_ROOT/include/ncursesw -I$LINUX_OUTPUT_ROOT/include/readline";
    LD_LIBRARY_PATH="$LINUX_OUTPUT_ROOT/lib" make "-j$CPUS";
    LD_LIBRARY_PATH="$LINUX_OUTPUT_ROOT/lib" make install;
    popd;
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
}


case "${CMD}" in
    python-libs)
        build_openssl;
        build_libffi;
        build_ncurses;
        build_zlib;
        build_readline;
        ;;
    python)
        build_python;
        ;;
    *)
        die "$0: wrong command to build ${CMD}"
        ;;
esac
cleanup_relink "$LINUX_OUTPUT_ROOT";
