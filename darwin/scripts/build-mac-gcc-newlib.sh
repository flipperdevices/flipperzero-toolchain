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

function build_gcc_newlib() {
    rm -rf "$MAC_ARM64_CONFIGURE_ROOT/newlib";
    rm -rf "$NEWLIB_ROOT";
    mkdir -p "$MAC_ARM64_CONFIGURE_ROOT/newlib";
    pushd "$MAC_ARM64_CONFIGURE_ROOT/newlib";
    DYLD_LIBRARY_PATH="$MAC_ARM64_OUTPUT_ROOT/lib:$MAC_ARM64_BUILD_ROOT/lib" \
        CFLAGS_FOR_TARGET="-g -Os -ffunction-sections -fdata-sections" \
        PATH="$MAC_ARM64_OUTPUT_ROOT/bin:$MAC_ARM64_BUILD_ROOT/bin:$PATH" \
        /toolchain/src/src/newlib-cygwin/configure \
            "--prefix=$NEWLIB_ROOT" \
            "--target=arm-none-eabi" \
            "--disable-newlib-supplied-syscalls" \
            "--enable-newlib-retargetable-locking" \
            "--enable-newlib-reent-check-verify" \
            "--enable-newlib-io-long-long" \
            "--enable-newlib-io-c99-formats" \
            "--enable-newlib-register-fini" \
            "--enable-newlib-mb" \
            "--host=aarch64-apple-darwin" \
            "--build=aarch64-apple-darwin" \
            CC=clang;
    DYLD_LIBRARY_PATH="$MAC_ARM64_OUTPUT_ROOT/lib:$MAC_ARM64_BUILD_ROOT/lib" \
        PATH="$MAC_ARM64_OUTPUT_ROOT/bin:$MAC_ARM64_BUILD_ROOT/bin:$PATH" \
        make "-j$CPUS";
    PATH="$MAC_ARM64_OUTPUT_ROOT/bin:$MAC_ARM64_BUILD_ROOT/bin:$PATH" \
    	make install;
    popd;
}
function build_gcc_newlib_nano() {
    rm -rf "$MAC_ARM64_CONFIGURE_ROOT/newlib-nano";
    rm -rf "$NEWLIB_NANO_ROOT";
    mkdir -p "$MAC_ARM64_CONFIGURE_ROOT/newlib-nano";
    pushd "$MAC_ARM64_CONFIGURE_ROOT/newlib-nano";
    DYLD_LIBRARY_PATH="$MAC_ARM64_OUTPUT_ROOT/lib:$MAC_ARM64_BUILD_ROOT/lib" \
        CFLAGS_FOR_TARGET="-g -Os -ffunction-sections -fdata-sections" \
        PATH="$MAC_ARM64_OUTPUT_ROOT/bin:$MAC_ARM64_BUILD_ROOT/bin:$PATH" \
        /toolchain/src/src/newlib-cygwin/configure \
            "--prefix=$NEWLIB_NANO_ROOT" \
            "--target=arm-none-eabi" \
            "--disable-newlib-supplied-syscalls" \
            "--enable-newlib-retargetable-locking" \
            "--enable-newlib-reent-check-verify" \
            "--enable-newlib-nano-malloc" \
            "--disable-newlib-unbuf-stream-opt" \
            "--enable-newlib-reent-small" \
            "--disable-newlib-fseek-optimization" \
            "--enable-newlib-nano-formatted-io" \
            "--disable-newlib-fvwrite-in-streamio" \
            "--disable-newlib-wide-orient" \
            "--enable-lite-exit" \
            "--enable-newlib-global-atexit" \
            "--host=aarch64-apple-darwin" \
            "--build=aarch64-apple-darwin" \
            CC=clang;
    DYLD_LIBRARY_PATH="$MAC_ARM64_OUTPUT_ROOT/lib:$MAC_ARM64_BUILD_ROOT/lib" \
        PATH="$MAC_ARM64_OUTPUT_ROOT/bin:$MAC_ARM64_BUILD_ROOT/bin:$PATH" \
        make "-j$CPUS";
    PATH="$MAC_ARM64_OUTPUT_ROOT/bin:$MAC_ARM64_BUILD_ROOT/bin:$PATH" \
    	make install;
    popd;
}
build_gcc_newlib;
build_gcc_newlib_nano;
