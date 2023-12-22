#!/bin/bash

set -euo pipefail;

LINUX_BUILD_ROOT=/toolchain/linux-build-root
LINUX_OUTPUT_ROOT=/toolchain/linux-output-root
LINUX_CONFIGURE_ROOT=/toolchain/linux-configure-root

CPUS="$(grep -c processor /proc/cpuinfo )";
ARCH="$(uname -m)";

function build_gmp() {
    rm -rf "$LINUX_CONFIGURE_ROOT/gmp";
    mkdir -p "$LINUX_CONFIGURE_ROOT/gmp";
    pushd "$LINUX_CONFIGURE_ROOT/gmp";
    /toolchain/src/src/gmp/configure \
        --disable-maintainer-mode \
        --prefix="$LINUX_BUILD_ROOT" \
        --disable-shared \
        "--host=$ARCH-none-linux-gnu";
    make "-j$CPUS";
    make install;
    popd;
}

function build_mpfr() {
    rm -rf "$LINUX_CONFIGURE_ROOT/mpfr";
    mkdir -p "$LINUX_CONFIGURE_ROOT/mpfr";
    pushd "$LINUX_CONFIGURE_ROOT/mpfr";
    /toolchain/src/src/mpfr/configure \
        --disable-maintainer-mode \
        --prefix="$LINUX_BUILD_ROOT" \
        --with-gmp="$LINUX_BUILD_ROOT" \
        --disable-shared;
    make "-j$CPUS";
    make install;
    popd;
}

function build_mpc() {
    rm -rf "$LINUX_CONFIGURE_ROOT/mpc";
    mkdir -p "$LINUX_CONFIGURE_ROOT/mpc";
    pushd "$LINUX_CONFIGURE_ROOT/mpc";
    /toolchain/src/src/mpc/configure \
        --disable-maintainer-mode \
        --prefix="$LINUX_BUILD_ROOT" \
        --with-gmp="$LINUX_BUILD_ROOT" \
        --with-mpfr="$LINUX_BUILD_ROOT" \
        --disable-shared;
    make "-j$CPUS";
    make install;
    popd;
}

function build_isl() {
    rm -rf "$LINUX_CONFIGURE_ROOT/isl";
    mkdir -p "$LINUX_CONFIGURE_ROOT/isl";
    pushd "$LINUX_CONFIGURE_ROOT/isl";
    /toolchain/src/src/isl/configure \
        --prefix="$LINUX_BUILD_ROOT" \
        --with-gmp-prefix="$LINUX_BUILD_ROOT" \
        --disable-shared;
    make "-j$CPUS";
    make install;
    popd;
}

function build_libexpat() {
    rm -rf "$LINUX_CONFIGURE_ROOT/libexpat";
    mkdir -p "$LINUX_CONFIGURE_ROOT/libexpat";
    pushd "$LINUX_CONFIGURE_ROOT/libexpat";
    /toolchain/src/src/libexpat/expat/configure \
        --prefix="$LINUX_BUILD_ROOT" \
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
