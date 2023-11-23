#!/bin/bash

set -euo pipefail;

MAC_X86_64_CONFIGURE_ROOT=/toolchain/mac-x86_64-configure-root
MAC_ARM64_CONFIGURE_ROOT=/toolchain/mac-arm64-configure-root
MAC_X86_64_BUILD_ROOT=/toolchain/mac-x86_64-build-root
MAC_ARM64_BUILD_ROOT=/toolchain/mac-arm64-build-root
MAC_X86_64_OUTPUT_ROOT=/toolchain/mac-x86_64-output-root
MAC_ARM64_OUTPUT_ROOT=/toolchain/mac-arm64-output-root

MAC_X86_64_FLAGS="-mmacosx-version-min=11.3 -arch x86_64"
MAC_ARM64_FLAGS="-mmacosx-version-min=11.3 -arch arm64"

CPUS="$(sysctl -n hw.ncpu)";

function build_gmp_x86_64() {
    mkdir -p "$MAC_X86_64_CONFIGURE_ROOT/gmp";
    pushd "$MAC_X86_64_CONFIGURE_ROOT/gmp";
    CPPFLAGS="$MAC_X86_64_FLAGS" \
        CFLAGS="$MAC_X86_64_FLAGS" \
        LDFLAGS="$MAC_X86_64_FLAGS" \
        DYLD_LIBRARY_PATH="$MAC_X86_64_OUTPUT_ROOT/lib" \
        /toolchain/src/src/gmp/configure \
            --prefix="$MAC_X86_64_BUILD_ROOT" \
            --disable-shared \
            CPPFLAGS="$MAC_X86_64_FLAGS" \
            CFLAGS="$MAC_X86_64_FLAGS" \
            LDFLAGS="$MAC_X86_64_FLAGS" \
            --host=x86_64-apple-darwin \
            --build=x86_64-apple-darwin \
            CC=clang;
    CPPFLAGS="$MAC_X86_64_FLAGS" \
        CFLAGS="$MAC_X86_64_FLAGS" \
        LDFLAGS="$MAC_X86_64_FLAGS" \
        DYLD_LIBRARY_PATH="$MAC_X86_64_OUTPUT_ROOT/lib" \
        make "-j$CPUS";
    make install;
    popd;
}

function build_gmp_arm64() {
    mkdir -p "$MAC_ARM64_CONFIGURE_ROOT/gmp";
    pushd "$MAC_ARM64_CONFIGURE_ROOT/gmp";
    CPPFLAGS="$MAC_ARM64_FLAGS" \
        CFLAGS="$MAC_ARM64_FLAGS" \
        LDFLAGS="$MAC_ARM64_FLAGS" \
        DYLD_LIBRARY_PATH="$MAC_ARM64_OUTPUT_ROOT/lib" \
        /toolchain/src/src/gmp/configure \
            --prefix="$MAC_ARM64_BUILD_ROOT" \
            --disable-shared \
            CPPFLAGS="$MAC_ARM64_FLAGS" \
            CFLAGS="$MAC_ARM64_FLAGS" \
            LDFLAGS="$MAC_ARM64_FLAGS" \
            --host=aarch64-apple-darwin \
            --build=aarch64-apple-darwin \
            CC=clang;
    CPPFLAGS="$MAC_ARM64_FLAGS" \
        CFLAGS="$MAC_ARM64_FLAGS" \
        LDFLAGS="$MAC_ARM64_FLAGS" \
        DYLD_LIBRARY_PATH="$MAC_ARM64_OUTPUT_ROOT/lib" \
        make "-j$CPUS";
    make install;
    popd;
}

function build_mpfr_x86_64() {
    mkdir -p "$MAC_X86_64_CONFIGURE_ROOT/mpfr";
    pushd "$MAC_X86_64_CONFIGURE_ROOT/mpfr";
    CPPFLAGS="$MAC_X86_64_FLAGS" \
        CFLAGS="$MAC_X86_64_FLAGS" \
        LDFLAGS="$MAC_X86_64_FLAGS" \
        DYLD_LIBRARY_PATH="$MAC_X86_64_OUTPUT_ROOT/lib" \
        /toolchain/src/src/mpfr/configure \
            --prefix="$MAC_X86_64_BUILD_ROOT" \
            --disable-shared \
            --with-gmp="$MAC_X86_64_BUILD_ROOT" \
            CPPFLAGS="$MAC_X86_64_FLAGS" \
            CFLAGS="$MAC_X86_64_FLAGS" \
            LDFLAGS="$MAC_X86_64_FLAGS" \
            --host=x86_64-apple-darwin \
            --build=x86_64-apple-darwin \
            CC=clang;
    CPPFLAGS="$MAC_X86_64_FLAGS" \
        CFLAGS="$MAC_X86_64_FLAGS" \
        LDFLAGS="$MAC_X86_64_FLAGS" \
        DYLD_LIBRARY_PATH="$MAC_X86_64_OUTPUT_ROOT/lib" \
        make "-j$CPUS";
    make install;
    popd;
}

function build_mpfr_arm64() {
    mkdir -p "$MAC_ARM64_CONFIGURE_ROOT/mpfr";
    pushd "$MAC_ARM64_CONFIGURE_ROOT/mpfr";
    CPPFLAGS="$MAC_ARM64_FLAGS" \
        CFLAGS="$MAC_ARM64_FLAGS" \
        LDFLAGS="$MAC_ARM64_FLAGS" \
        DYLD_LIBRARY_PATH="$MAC_ARM64_OUTPUT_ROOT/lib" \
        /toolchain/src/src/mpfr/configure \
            --prefix="$MAC_ARM64_BUILD_ROOT" \
            --with-gmp="$MAC_ARM64_BUILD_ROOT" \
            --disable-shared \
            CPPFLAGS="$MAC_ARM64_FLAGS" \
            CFLAGS="$MAC_ARM64_FLAGS" \
            LDFLAGS="$MAC_ARM64_FLAGS" \
            --host=aarch64-apple-darwin \
            --build=aarch64-apple-darwin \
            CC=clang;
    CPPFLAGS="$MAC_ARM64_FLAGS" \
        CFLAGS="$MAC_ARM64_FLAGS" \
        LDFLAGS="$MAC_ARM64_FLAGS" \
        DYLD_LIBRARY_PATH="$MAC_ARM64_OUTPUT_ROOT/lib" \
        make "-j$CPUS";
    make install;
    popd;
}

function build_mpc_x86_64() {
    mkdir -p "$MAC_X86_64_CONFIGURE_ROOT/mpc";
    pushd "$MAC_X86_64_CONFIGURE_ROOT/mpc";
    CPPFLAGS="$MAC_X86_64_FLAGS" \
        CFLAGS="$MAC_X86_64_FLAGS" \
        LDFLAGS="$MAC_X86_64_FLAGS" \
        DYLD_LIBRARY_PATH="$MAC_X86_64_OUTPUT_ROOT/lib" \
        /toolchain/src/src/mpc/configure \
            --prefix="$MAC_X86_64_BUILD_ROOT" \
            --disable-shared \
            --with-gmp="$MAC_X86_64_BUILD_ROOT" \
            --with-mpfr="$MAC_X86_64_BUILD_ROOT" \
            CPPFLAGS="$MAC_X86_64_FLAGS" \
            CFLAGS="$MAC_X86_64_FLAGS" \
            LDFLAGS="$MAC_X86_64_FLAGS" \
            --host=x86_64-apple-darwin \
            --build=x86_64-apple-darwin \
            CC=clang;
    CPPFLAGS="$MAC_X86_64_FLAGS" \
        CFLAGS="$MAC_X86_64_FLAGS" \
        LDFLAGS="$MAC_X86_64_FLAGS" \
        DYLD_LIBRARY_PATH="$MAC_X86_64_OUTPUT_ROOT/lib" \
        make "-j$CPUS";
    make install;
    popd;
}

function build_mpc_arm64() {
    mkdir -p "$MAC_ARM64_CONFIGURE_ROOT/mpc";
    pushd "$MAC_ARM64_CONFIGURE_ROOT/mpc";
    CPPFLAGS="$MAC_ARM64_FLAGS" \
        CFLAGS="$MAC_ARM64_FLAGS" \
        LDFLAGS="$MAC_ARM64_FLAGS" \
        DYLD_LIBRARY_PATH="$MAC_ARM64_OUTPUT_ROOT/lib" \
        /toolchain/src/src/mpc/configure \
            --prefix="$MAC_ARM64_BUILD_ROOT" \
            --with-gmp="$MAC_ARM64_BUILD_ROOT" \
            --with-mpfr="$MAC_ARM64_BUILD_ROOT" \
            --disable-shared \
            CPPFLAGS="$MAC_ARM64_FLAGS" \
            CFLAGS="$MAC_ARM64_FLAGS" \
            LDFLAGS="$MAC_ARM64_FLAGS" \
            --host=aarch64-apple-darwin \
            --build=aarch64-apple-darwin \
            CC=clang;
    CPPFLAGS="$MAC_ARM64_FLAGS" \
        CFLAGS="$MAC_ARM64_FLAGS" \
        LDFLAGS="$MAC_ARM64_FLAGS" \
        DYLD_LIBRARY_PATH="$MAC_ARM64_OUTPUT_ROOT/lib" \
        make "-j$CPUS";
    make install;
    popd;
}

function build_isl_x86_64() {
    mkdir -p "$MAC_X86_64_CONFIGURE_ROOT/isl";
    pushd "$MAC_X86_64_CONFIGURE_ROOT/isl";
    CPPFLAGS="$MAC_X86_64_FLAGS" \
        CFLAGS="$MAC_X86_64_FLAGS" \
        LDFLAGS="$MAC_X86_64_FLAGS" \
        DYLD_LIBRARY_PATH="$MAC_X86_64_OUTPUT_ROOT/lib" \
        /toolchain/src/src/isl/configure \
            --prefix="$MAC_X86_64_BUILD_ROOT" \
            --disable-shared \
            --with-gmp-prefix="$MAC_X86_64_BUILD_ROOT" \
            CPPFLAGS="$MAC_X86_64_FLAGS" \
            CFLAGS="$MAC_X86_64_FLAGS" \
            LDFLAGS="$MAC_X86_64_FLAGS" \
            --host=x86_64-apple-darwin \
            --build=x86_64-apple-darwin \
            CC=clang;
    CPPFLAGS="$MAC_X86_64_FLAGS" \
        CFLAGS="$MAC_X86_64_FLAGS" \
        LDFLAGS="$MAC_X86_64_FLAGS" \
        DYLD_LIBRARY_PATH="$MAC_X86_64_OUTPUT_ROOT/lib" \
        make "-j$CPUS";
    make install;
    popd;
}

function build_isl_arm64() {
    mkdir -p "$MAC_ARM64_CONFIGURE_ROOT/isl";
    pushd "$MAC_ARM64_CONFIGURE_ROOT/isl";
    CPPFLAGS="$MAC_ARM64_FLAGS" \
        CFLAGS="$MAC_ARM64_FLAGS" \
        LDFLAGS="$MAC_ARM64_FLAGS" \
        DYLD_LIBRARY_PATH="$MAC_ARM64_OUTPUT_ROOT/lib" \
        /toolchain/src/src/isl/configure \
            --prefix="$MAC_ARM64_BUILD_ROOT" \
            --with-gmp-prefix="$MAC_ARM64_BUILD_ROOT" \
            --disable-shared \
            CPPFLAGS="$MAC_ARM64_FLAGS" \
            CFLAGS="$MAC_ARM64_FLAGS" \
            LDFLAGS="$MAC_ARM64_FLAGS" \
            --host=aarch64-apple-darwin \
            --build=aarch64-apple-darwin \
            CC=clang;
    CPPFLAGS="$MAC_ARM64_FLAGS" \
        CFLAGS="$MAC_ARM64_FLAGS" \
        LDFLAGS="$MAC_ARM64_FLAGS" \
        DYLD_LIBRARY_PATH="$MAC_ARM64_OUTPUT_ROOT/lib" \
        make "-j$CPUS";
    make install;
    popd;
}

function build_libexpat_x86_64() {
    mkdir -p "$MAC_X86_64_CONFIGURE_ROOT/libexpat";
    pushd "$MAC_X86_64_CONFIGURE_ROOT/libexpat";
    CPPFLAGS="$MAC_X86_64_FLAGS" \
        CFLAGS="$MAC_X86_64_FLAGS" \
        LDFLAGS="$MAC_X86_64_FLAGS" \
        DYLD_LIBRARY_PATH="$MAC_X86_64_OUTPUT_ROOT/lib" \
        /toolchain/src/src/libexpat/expat/configure \
            --prefix="$MAC_X86_64_BUILD_ROOT" \
            --without-docbook \
            --without-xmlwf \
            --disable-shared \
            CPPFLAGS="$MAC_X86_64_FLAGS" \
            CFLAGS="$MAC_X86_64_FLAGS" \
            LDFLAGS="$MAC_X86_64_FLAGS" \
            --host=x86_64-apple-darwin \
            --build=x86_64-apple-darwin \
            CC=clang;
    CPPFLAGS="$MAC_X86_64_FLAGS" \
        CFLAGS="$MAC_X86_64_FLAGS" \
        LDFLAGS="$MAC_X86_64_FLAGS" \
        DYLD_LIBRARY_PATH="$MAC_X86_64_OUTPUT_ROOT/lib" \
        make "-j$CPUS";
    make install;
    popd;
}

function build_libexpat_arm64() {
    mkdir -p "$MAC_ARM64_CONFIGURE_ROOT/libexpat";
    pushd "$MAC_ARM64_CONFIGURE_ROOT/libexpat";
    CPPFLAGS="$MAC_ARM64_FLAGS" \
        CFLAGS="$MAC_ARM64_FLAGS" \
        LDFLAGS="$MAC_ARM64_FLAGS" \
        DYLD_LIBRARY_PATH="$MAC_ARM64_OUTPUT_ROOT/lib" \
        /toolchain/src/src/libexpat/expat/configure \
            --prefix="$MAC_ARM64_BUILD_ROOT" \
            --without-docbook \
            --without-xmlwf \
            --disable-shared \
            CPPFLAGS="$MAC_ARM64_FLAGS" \
            CFLAGS="$MAC_ARM64_FLAGS" \
            LDFLAGS="$MAC_ARM64_FLAGS" \
            --host=aarch64-apple-darwin \
            --build=aarch64-apple-darwin \
            CC=clang;
    CPPFLAGS="$MAC_ARM64_FLAGS" \
        CFLAGS="$MAC_ARM64_FLAGS" \
        LDFLAGS="$MAC_ARM64_FLAGS" \
        DYLD_LIBRARY_PATH="$MAC_ARM64_OUTPUT_ROOT/lib" \
        make "-j$CPUS";
    make install;
    popd;
}

build_gmp_x86_64;
build_gmp_arm64;
build_mpfr_x86_64;
build_mpfr_arm64;
build_mpc_x86_64;
build_mpc_arm64;
build_isl_x86_64;
build_isl_arm64;
build_libexpat_x86_64;
build_libexpat_arm64;
