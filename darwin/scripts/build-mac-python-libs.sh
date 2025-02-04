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

function build_openssl_x86_64() {
    mkdir -p "$MAC_X86_64_CONFIGURE_ROOT/openssl";
    pushd "$MAC_X86_64_CONFIGURE_ROOT/openssl";
    /toolchain/src/src/openssl/Configure \
        --prefix="$MAC_X86_64_OUTPUT_ROOT" \
        darwin64-x86_64-cc \
        -mmacosx-version-min=11.3;
    make "-j$CPUS";
    make install_sw;
    popd;
}
function build_openssl_arm64() {
    mkdir -p "$MAC_ARM64_CONFIGURE_ROOT/openssl";
    pushd "$MAC_ARM64_CONFIGURE_ROOT/openssl";
    /toolchain/src/src/openssl/Configure \
        --prefix="$MAC_ARM64_OUTPUT_ROOT" \
        darwin64-arm64-cc \
        -mmacosx-version-min=11.3;
    make "-j$CPUS";
    make install_sw;
    popd;
}

build_openssl_x86_64;
build_openssl_arm64;
