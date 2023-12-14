#!/bin/bash

set -euo pipefail;

MAC_X86_64_CONFIGURE_ROOT=/toolchain/mac-x86_64-configure-root
MAC_ARM64_CONFIGURE_ROOT=/toolchain/mac-arm64-configure-root
MAC_X86_64_BUILD_ROOT=/toolchain/mac-x86_64-build-root
MAC_ARM64_BUILD_ROOT=/toolchain/mac-arm64-build-root
MAC_X86_64_OUTPUT_ROOT=/toolchain/mac-x86_64-output-root
MAC_ARM64_OUTPUT_ROOT=/toolchain/mac-arm64-output-root

NEWLIB_ROOT=/toolchain/newlib-root
NEWLIB_NANO_ROOT=/toolchain/newlib-nano-root

MAC_X86_64_FLAGS="-mmacosx-version-min=11.3 -arch x86_64"
MAC_ARM64_FLAGS="-mmacosx-version-min=11.3 -arch arm64"

CPUS="$(sysctl -n hw.ncpu)";

function copy_newlib() {
    rsync -av "$NEWLIB_ROOT/" "$MAC_X86_64_OUTPUT_ROOT";
    rsync -av "$NEWLIB_ROOT/" "$MAC_ARM64_OUTPUT_ROOT";
}

function build_gcc_x86_64() {
    rm -rf "$MAC_X86_64_CONFIGURE_ROOT/gcc-first";
    mkdir -p "$MAC_X86_64_CONFIGURE_ROOT/gcc-first";
    pushd "$MAC_X86_64_CONFIGURE_ROOT/gcc-first";
    CPPFLAGS="$MAC_X86_64_FLAGS" \
        CXXFLAGS="$MAC_X86_64_FLAGS" \
        CFLAGS="$MAC_X86_64_FLAGS" \
        LDFLAGS="$MAC_X86_64_FLAGS" \
        DYLD_LIBRARY_PATH="$MAC_X86_64_OUTPUT_ROOT/lib" \
        PATH="$MAC_X86_64_OUTPUT_ROOT/bin:$PATH" \
        /toolchain/src/src/arm-gnu-toolchain-src-snapshot-12.3.rel1/configure \
            "--disable-libssp" \
            "--with-gnu-as" \
            "--with-gnu-ld" \
            "--disable-shared" \
            "--disable-nls" \
            "--disable-threads" \
            "--disable-tls" \
            "--enable-checking=release" \
            "--enable-languages=c,c++" \
            "--with-system-zlib" \
            "--without-cloog" \
            "--without-isl" \
            "--with-newlib" \
            "--with-headers=yes" \
            "--with-multilib-list=rmprofile" \
            "--with-expat" \
            "--with-libexpat-prefix=$MAC_X86_64_BUILD_ROOT" \
            "--with-libexpat-type=static" \
            "--with-libmpfr-prefix=$MAC_X86_64_BUILD_ROOT" \
            "--with-libmpfr-type=static" \
            "--with-mpfr=$MAC_X86_64_BUILD_ROOT" \
            "--with-libgmp-prefix=$MAC_X86_64_BUILD_ROOT" \
            "--with-libgmp-type=static" \
            "--with-gmp=$MAC_X86_64_BUILD_ROOT" \
            "--with-python=no" \
            "--enable-lto" \
            "--target=arm-none-eabi" \
            "--prefix=$MAC_X86_64_OUTPUT_ROOT" \
            "--with-sysroot=$MAC_X86_64_OUTPUT_ROOT/arm-none-eabi" \
            CPPFLAGS="$MAC_X86_64_FLAGS" \
            CXXFLAGS="$MAC_X86_64_FLAGS" \
            CFLAGS="$MAC_X86_64_FLAGS" \
            LDFLAGS="$MAC_X86_64_FLAGS" \
            --host=x86_64-apple-darwin \
            --build=x86_64-apple-darwin \
            CC=clang;
    CPPFLAGS="$MAC_X86_64_FLAGS" \
        CXXFLAGS="$MAC_X86_64_FLAGS" \
        CFLAGS="$MAC_X86_64_FLAGS" \
        LDFLAGS="$MAC_X86_64_FLAGS" \
        DYLD_LIBRARY_PATH="$MAC_X86_64_OUTPUT_ROOT/lib" \
        PATH="$MAC_X86_64_OUTPUT_ROOT/bin:$PATH" \
        make "-j$CPUS";
    PATH="$MAC_X86_64_OUTPUT_ROOT/bin:$PATH" \
    	make install;
    popd;
}

function build_gcc_arm64() {
    rm -rf "$MAC_ARM64_CONFIGURE_ROOT/gcc";
    mkdir -p "$MAC_ARM64_CONFIGURE_ROOT/gcc";
    pushd "$MAC_ARM64_CONFIGURE_ROOT/gcc";
    CPPFLAGS="$MAC_ARM64_FLAGS" \
        CXXFLAGS="$MAC_ARM64_FLAGS" \
        CFLAGS="$MAC_ARM64_FLAGS" \
        LDFLAGS="$MAC_ARM64_FLAGS" \
        DYLD_LIBRARY_PATH="$MAC_ARM64_OUTPUT_ROOT/lib" \
        PATH="$MAC_ARM64_OUTPUT_ROOT/bin:$PATH" \
        /toolchain/src/src/arm-gnu-toolchain-src-snapshot-12.3.rel1/configure \
            "--enable-lto" \
            "--disable-libssp" \
            "--disable-shared" \
            "--disable-nls" \
            "--disable-threads" \
            "--disable-tls" \
            "--with-gnu-as" \
            "--with-gnu-ld" \
            "--with-system-zlib" \
            "--with-headers=yes" \
            "--enable-checking=release" \
            "--enable-languages=c,c++" \
            "--without-cloog" \
            "--without-isl" \
            "--with-multilib-list=rmprofile" \
            "--with-newlib" \
            "--with-expat" \
            "--with-libexpat-prefix=$MAC_ARM64_BUILD_ROOT" \
            "--with-libexpat-type=static" \
            "--with-libmpfr-prefix=$MAC_ARM64_BUILD_ROOT" \
            "--with-libmpfr-type=static" \
            "--with-mpfr=$MAC_ARM64_BUILD_ROOT" \
            "--with-libgmp-prefix=$MAC_ARM64_BUILD_ROOT" \
            "--with-libgmp-type=static" \
            "--with-gmp=$MAC_ARM64_BUILD_ROOT" \
            "--with-python=no" \
            "--target=arm-none-eabi" \
            "--prefix=$MAC_ARM64_OUTPUT_ROOT" \
            "--with-sysroot=$MAC_ARM64_OUTPUT_ROOT/arm-none-eabi" \
            CPPFLAGS="$MAC_ARM64_FLAGS" \
            CXXFLAGS="$MAC_ARM64_FLAGS" \
            CFLAGS="$MAC_ARM64_FLAGS" \
            LDFLAGS="$MAC_ARM64_FLAGS" \
            --host=aarch64-apple-darwin \
            --build=aarch64-apple-darwin \
            CC=clang;
    CPPFLAGS="$MAC_ARM64_FLAGS" \
        CXXFLAGS="$MAC_ARM64_FLAGS" \
        CFLAGS="$MAC_ARM64_FLAGS" \
        LDFLAGS="$MAC_ARM64_FLAGS" \
        DYLD_LIBRARY_PATH="$MAC_ARM64_OUTPUT_ROOT/lib" \
        PATH="$MAC_ARM64_OUTPUT_ROOT/bin:$PATH" \
        make "-j$CPUS";
    PATH="$MAC_ARM64_OUTPUT_ROOT/bin:$PATH" \
    	make install;
    popd;
}

function build_gcc_arm64_nano() {
    rm -rf "$MAC_ARM64_CONFIGURE_ROOT/gcc-nano";
    mkdir -p "$MAC_ARM64_CONFIGURE_ROOT/gcc-nano";
    pushd "$MAC_ARM64_CONFIGURE_ROOT/gcc-nano";
    CPPFLAGS="$MAC_ARM64_FLAGS" \
        CXXFLAGS="$MAC_ARM64_FLAGS" \
        CFLAGS="$MAC_ARM64_FLAGS" \
        LDFLAGS="$MAC_ARM64_FLAGS" \
        DYLD_LIBRARY_PATH="$MAC_ARM64_OUTPUT_ROOT/lib" \
        PATH="$MAC_ARM64_OUTPUT_ROOT/bin:$PATH" \
        /toolchain/src/src/arm-gnu-toolchain-src-snapshot-12.3.rel1/configure \
            "--enable-lto" \
            "--disable-libssp" \
            "--disable-shared" \
            "--disable-nls" \
            "--disable-threads" \
            "--disable-tls" \
            "--with-gnu-as" \
            "--with-gnu-ld" \
            "--with-system-zlib" \
            "--with-headers=yes" \
            "--enable-checking=release" \
            "--enable-languages=c,c++" \
            "--without-cloog" \
            "--without-isl" \
            "--with-multilib-list=rmprofile" \
            "--with-newlib" \
            "--with-expat" \
            "--with-libexpat-prefix=$MAC_ARM64_BUILD_ROOT" \
            "--with-libexpat-type=static" \
            "--with-libmpfr-prefix=$MAC_ARM64_BUILD_ROOT" \
            "--with-libmpfr-type=static" \
            "--with-mpfr=$MAC_ARM64_BUILD_ROOT" \
            "--with-libgmp-prefix=$MAC_ARM64_BUILD_ROOT" \
            "--with-libgmp-type=static" \
            "--with-gmp=$MAC_ARM64_BUILD_ROOT" \
            "--with-python=no" \
            "--target=arm-none-eabi" \
            "--prefix=$NEWLIB_NANO_ROOT" \
            "--with-sysroot=$NEWLIB_NANO_ROOT/arm-none-eabi" \
            CPPFLAGS="$MAC_ARM64_FLAGS" \
            CXXFLAGS="$MAC_ARM64_FLAGS" \
            CFLAGS="$MAC_ARM64_FLAGS" \
            LDFLAGS="$MAC_ARM64_FLAGS" \
            --host=aarch64-apple-darwin \
            --build=aarch64-apple-darwin \
            CC=clang;
    CPPFLAGS="$MAC_ARM64_FLAGS" \
        CXXFLAGS="$MAC_ARM64_FLAGS" \
        CFLAGS="$MAC_ARM64_FLAGS" \
        LDFLAGS="$MAC_ARM64_FLAGS" \
        DYLD_LIBRARY_PATH="$MAC_ARM64_OUTPUT_ROOT/lib" \
        PATH="$MAC_ARM64_OUTPUT_ROOT/bin:$PATH" \
        make "-j$CPUS";
    PATH="$MAC_ARM64_OUTPUT_ROOT/bin:$PATH" \
    	make install;
    popd;
}

copy_newlib;
build_gcc_x86_64;
build_gcc_arm64;
build_gcc_arm64_nano;
