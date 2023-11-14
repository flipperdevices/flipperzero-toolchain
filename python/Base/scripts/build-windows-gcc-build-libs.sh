#!/bin/bash

set -euo pipefail;

WIN_BUILD_ROOT=/toolchain/win-build-root
WIN_OUTPUT_ROOT=/toolchain/win-output-root

HOST_MINGW=x86_64-w64-mingw32

CPUS="$(grep -c processor /proc/cpuinfo )";

function build_gmp() {
    pushd /toolchain/src/src/gmp;
    ./configure --disable-maintainer-mode \
        --host="$HOST_MINGW" \
        --prefix="$WIN_BUILD_ROOT" \
        --disable-shared;
    make "-j$CPUS";
    make install;
    popd;
}

function build_mpfr() {
    pushd /toolchain/src/src/mpfr;
    ./configure --disable-maintainer-mode \
        --host="$HOST_MINGW" \
        --prefix="$WIN_BUILD_ROOT" \
        --with-gmp="$WIN_BUILD_ROOT" \
        --disable-shared;
    make "-j$CPUS";
    make install;
    popd;
}

function build_mpc() {
    pushd /toolchain/src/src/mpc;
    ./configure --disable-maintainer-mode \
        --host="$HOST_MINGW" \
        --prefix="$WIN_BUILD_ROOT" \
        --with-gmp="$WIN_BUILD_ROOT" \
        --with-mpfr="$WIN_BUILD_ROOT" \
        --disable-shared;
    make "-j$CPUS";
    make install;
    popd;
}

function build_isl() {
    pushd /toolchain/src/src/isl;
    ./configure \
        --host="$HOST_MINGW" \
        --prefix="$WIN_BUILD_ROOT" \
        --with-gmp-prefix="$WIN_BUILD_ROOT" \
        --disable-shared;
    make "-j$CPUS";
    make install;
    popd;
}

function build_libexpat() {
    pushd /toolchain/src/src/libexpat/expat;
    ./configure \
        --host="$HOST_MINGW" \
        --prefix="$WIN_BUILD_ROOT" \
        --without-docbook \
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
