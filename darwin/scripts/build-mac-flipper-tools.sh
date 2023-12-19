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

function build_protobuf_x86_64() {
    rm -rf "$MAC_X86_64_CONFIGURE_ROOT/protobuf";
    mkdir -p "$MAC_X86_64_CONFIGURE_ROOT/protobuf";
    pushd "$MAC_X86_64_CONFIGURE_ROOT/protobuf";
    CPPFLAGS="$MAC_X86_64_FLAGS" \
        CXXFLAGS="$MAC_X86_64_FLAGS" \
        CFLAGS="$MAC_X86_64_FLAGS" \
        LDFLAGS="$MAC_X86_64_FLAGS" \
        DYLD_LIBRARY_PATH="$MAC_X86_64_OUTPUT_ROOT/lib" \
        PATH="$MAC_X86_64_OUTPUT_ROOT/bin:$PATH" \
        /toolchain/src/src/protobuf/configure \
            "--prefix=$MAC_X86_64_OUTPUT_ROOT" \
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

function build_protobuf_arm64() {
    rm -rf "$MAC_ARM64_CONFIGURE_ROOT/protobuf";
    mkdir -p "$MAC_ARM64_CONFIGURE_ROOT/protobuf";
    pushd "$MAC_ARM64_CONFIGURE_ROOT/protobuf";
    CPPFLAGS="$MAC_ARM64_FLAGS" \
        CXXFLAGS="$MAC_ARM64_FLAGS" \
        CFLAGS="$MAC_ARM64_FLAGS" \
        LDFLAGS="$MAC_ARM64_FLAGS" \
        DYLD_LIBRARY_PATH="$MAC_ARM64_OUTPUT_ROOT/lib" \
        PATH="$MAC_ARM64_OUTPUT_ROOT/bin:$PATH" \
        /toolchain/src/src/protobuf/configure \
            "--prefix=$MAC_ARM64_OUTPUT_ROOT" \
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

function build_clang_format_x86_64() {
    rm -rf "$MAC_X86_64_CONFIGURE_ROOT/clang-format";
    mkdir -p "$MAC_X86_64_CONFIGURE_ROOT/clang-format";
    pushd "$MAC_X86_64_CONFIGURE_ROOT/clang-format";
    CPPFLAGS="$MAC_X86_64_FLAGS" \
        CXXFLAGS="$MAC_X86_64_FLAGS" \
        CFLAGS="$MAC_X86_64_FLAGS" \
        LDFLAGS="$MAC_X86_64_FLAGS" \
        cmake \
            -S /toolchain/src/src/clang-format/llvm-17.0.6.src \
            -B build \
            -DLLVM_INCLUDE_BENCHMARKS=OFF \
            -DCMAKE_BUILD_TYPE=Release \
            "-DCMAKE_INSTALL_PREFIX=$MAC_X86_64_OUTPUT_ROOT" \
            -DLLVM_EXTERNAL_PROJECTS=clang \
            -DCMAKE_OSX_ARCHITECTURES=x86_64;
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
    cmake \
        --install build \
        --strip \
        --component clang-format;
    popd;
}

function build_clang_format_arm64() {
    rm -rf "$MAC_ARM64_CONFIGURE_ROOT/clang-format";
    mkdir -p "$MAC_ARM64_CONFIGURE_ROOT/clang-format";
    pushd "$MAC_ARM64_CONFIGURE_ROOT/clang-format";
    CPPFLAGS="$MAC_ARM64_FLAGS" \
        CXXFLAGS="$MAC_ARM64_FLAGS" \
        CFLAGS="$MAC_ARM64_FLAGS" \
        LDFLAGS="$MAC_ARM64_FLAGS" \
        cmake \
            -S /toolchain/src/src/clang-format/llvm-17.0.6.src \
            -B build \
            -DLLVM_INCLUDE_BENCHMARKS=OFF \
            -DCMAKE_BUILD_TYPE=Release \
            "-DCMAKE_INSTALL_PREFIX=$MAC_ARM64_OUTPUT_ROOT" \
            -DLLVM_EXTERNAL_PROJECTS=clang \
            -DCMAKE_OSX_ARCHITECTURES=arm64;
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
    cmake \
        --install build \
        --strip \
        --component clang-format;
    popd;
}
build_protobuf_x86_64;
build_protobuf_arm64;
build_clang_format_x86_64;
build_clang_format_arm64;
