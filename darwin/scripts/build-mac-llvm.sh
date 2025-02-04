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

function build_llvm_x86_64() {
    rm -rf "$MAC_X86_64_CONFIGURE_ROOT/llvm";
    mkdir -p "$MAC_X86_64_CONFIGURE_ROOT/llvm";
    pushd "$MAC_X86_64_CONFIGURE_ROOT/llvm";
    CPPFLAGS="$MAC_X86_64_FLAGS" \
        CXXFLAGS="$MAC_X86_64_FLAGS" \
        CFLAGS="$MAC_X86_64_FLAGS" \
        LDFLAGS="$MAC_X86_64_FLAGS" \
        cmake \
            -S /toolchain/src/src/llvm/llvm-18.1.8.src \
            -B build \
            -DLLVM_INCLUDE_BENCHMARKS=OFF \
            -DCMAKE_BUILD_TYPE=Release \
            "-DCMAKE_INSTALL_PREFIX=$MAC_X86_64_OUTPUT_ROOT" \
            "-DLLVM_EXTERNAL_PROJECTS=clang;clang-tools-extra" \
            -DCMAKE_OSX_ARCHITECTURES=x86_64 \
            "-DLLVM_TARGETS_TO_BUILD=ARM";
    CPPFLAGS="$MAC_X86_64_FLAGS" \
        CXXFLAGS="$MAC_X86_64_FLAGS" \
        CFLAGS="$MAC_X86_64_FLAGS" \
        LDFLAGS="$MAC_X86_64_FLAGS"\
        cmake \
            "--build" \
            "build" \
            "--target" \
            "clang-format" \
            "-j$CPUS";
    CPPFLAGS="$MAC_X86_64_FLAGS" \
        CXXFLAGS="$MAC_X86_64_FLAGS" \
        CFLAGS="$MAC_X86_64_FLAGS" \
        LDFLAGS="$MAC_X86_64_FLAGS"\
        cmake \
            "--build" \
            "build" \
            "--target" \
            "clangd" \
            "-j$CPUS";
    cmake \
        --install build \
        --strip \
        --component clang-format;
    cmake \
        --install build \
        --strip \
        --component clangd;

    # adding clangd headers
    cp -r "$MAC_X86_64_CONFIGURE_ROOT/llvm/build/lib/clang" "$MAC_X86_64_OUTPUT_ROOT/lib/";

    popd;
}

function build_llvm_arm64() {
    rm -rf "$MAC_ARM64_CONFIGURE_ROOT/llvm";
    mkdir -p "$MAC_ARM64_CONFIGURE_ROOT/llvm";
    pushd "$MAC_ARM64_CONFIGURE_ROOT/llvm";
    CPPFLAGS="$MAC_ARM64_FLAGS" \
        CXXFLAGS="$MAC_ARM64_FLAGS" \
        CFLAGS="$MAC_ARM64_FLAGS" \
        LDFLAGS="$MAC_ARM64_FLAGS" \
        cmake \
            -S /toolchain/src/src/llvm/llvm-18.1.8.src \
            -B build \
            -DLLVM_INCLUDE_BENCHMARKS=OFF \
            -DCMAKE_BUILD_TYPE=Release \
            "-DCMAKE_INSTALL_PREFIX=$MAC_ARM64_OUTPUT_ROOT" \
            "-DLLVM_EXTERNAL_PROJECTS=clang;clang-tools-extra" \
            -DCMAKE_OSX_ARCHITECTURES=arm64 \
            "-DLLVM_TARGETS_TO_BUILD=ARM";
    CPPFLAGS="$MAC_ARM64_FLAGS" \
        CXXFLAGS="$MAC_ARM64_FLAGS" \
        CFLAGS="$MAC_ARM64_FLAGS" \
        LDFLAGS="$MAC_ARM64_FLAGS"\
        cmake \
            "--build" \
            "build" \
            "--target" \
            "clang-format" \
            "-j$CPUS";
    CPPFLAGS="$MAC_ARM64_FLAGS" \
        CXXFLAGS="$MAC_ARM64_FLAGS" \
        CFLAGS="$MAC_ARM64_FLAGS" \
        LDFLAGS="$MAC_ARM64_FLAGS"\
        cmake \
            "--build" \
            "build" \
            "--target" \
            "clangd" \
            "-j$CPUS";
    cmake \
        --install build \
        --strip \
        --component clang-format;
    cmake \
        --install build \
        --strip \
        --component clangd;

    # adding clangd headers
    cp -r "$MAC_ARM64_CONFIGURE_ROOT/llvm/build/lib/clang" "$MAC_ARM64_OUTPUT_ROOT/lib/";

    popd;
}

build_llvm_x86_64;
build_llvm_arm64;

