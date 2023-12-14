#!/bin/bash

set -euo pipefail;

WINDOWS_CONFIGURE_ROOT=/toolchain/windows-configure-root
WINDOWS_BUILD_ROOT=/toolchain/windows-build-root
WINDOWS_OUTPUT_ROOT=/toolchain/windows-output-root

CPUS="$(grep -c processor /proc/cpuinfo)";

function build_gmp() {
    rm -rf "$WINDOWS_CONFIGURE_ROOT/gmp";
    mkdir -p "$WINDOWS_CONFIGURE_ROOT/gmp";
    pushd "$WINDOWS_CONFIGURE_ROOT/gmp";
    /toolchain/src/src/gmp/configure \
        --enable-static \
        --disable-shared \
        --disable-maintainer-mode \
        --prefix="$WINDOWS_BUILD_ROOT" \
        --host=x86_64-w64-mingw32;
    make "-j$CPUS";
    make install;
    popd;
}

function build_mpfr() {
    rm -rf "$WINDOWS_CONFIGURE_ROOT/mpfr";
    mkdir -p "$WINDOWS_CONFIGURE_ROOT/mpfr";
    pushd "$WINDOWS_CONFIGURE_ROOT/mpfr";
    /toolchain/src/src/mpfr/configure \
        --enable-static \
        --disable-shared \
        --disable-maintainer-mode \
        --prefix="$WINDOWS_BUILD_ROOT" \
        --with-gmp="$WINDOWS_BUILD_ROOT" \
        --host=x86_64-w64-mingw32;
    make "-j$CPUS";
    make install;
    popd;
}

function build_mpc() {
    rm -rf "$WINDOWS_CONFIGURE_ROOT/mpc";
    mkdir -p "$WINDOWS_CONFIGURE_ROOT/mpc";
    pushd "$WINDOWS_CONFIGURE_ROOT/mpc";
    /toolchain/src/src/mpc/configure \
        --enable-static \
        --disable-shared \
        --disable-maintainer-mode \
        --prefix="$WINDOWS_BUILD_ROOT" \
        --with-gmp="$WINDOWS_BUILD_ROOT" \
        --with-mpfr="$WINDOWS_BUILD_ROOT" \
        --host=x86_64-w64-mingw32;
    make "-j$CPUS";
    make install;
    popd;
}

function build_isl() {
    rm -rf "$WINDOWS_CONFIGURE_ROOT/isl";
    mkdir -p "$WINDOWS_CONFIGURE_ROOT/isl";
    pushd "$WINDOWS_CONFIGURE_ROOT/isl";
    /toolchain/src/src/isl/configure \
        --enable-static \
        --disable-shared \
        --prefix="$WINDOWS_BUILD_ROOT" \
        --with-gmp-prefix="$WINDOWS_BUILD_ROOT" \
        --host=x86_64-w64-mingw32;
    make "-j$CPUS";
    make install;
    popd;
}

function build_libexpat() {
    rm -rf "$WINDOWS_CONFIGURE_ROOT/libexpat";
    mkdir -p "$WINDOWS_CONFIGURE_ROOT/libexpat";
    pushd "$WINDOWS_CONFIGURE_ROOT/libexpat";
    /toolchain/src/src/libexpat/expat/configure \
        --enable-static \
        --disable-shared \
        --prefix="$WINDOWS_BUILD_ROOT" \
        --host=x86_64-w64-mingw32 \
        --without-docbook \
        --disable-nls \
        --without-xmlwf;
    make "-j$CPUS";
    make install;
    popd;
}

build_gmp;
build_mpfr;
build_mpc;
build_isl;
build_libexpat;
