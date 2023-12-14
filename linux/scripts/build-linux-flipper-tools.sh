#!/bin/bash

set -euo pipefail;

LINUX_BUILD_ROOT=/toolchain/linux-build-root
LINUX_OUTPUT_ROOT=/toolchain/linux-output-root
LINUX_CONFIGURE_ROOT=/toolchain/linux-configure-root

CPUS="$(grep -c processor /proc/cpuinfo )";

function cleanup_relink() {
    local DIRECTORY;
    DIRECTORY="$1";
    find "$DIRECTORY" \( -name "*.a" -or -name "*.la" \) -delete;
    rm -rf "$DIRECTORY/share/man"
    relink.sh "$DIRECTORY";
}

function build_protobuf() {
    rm -rf "$LINUX_CONFIGURE_ROOT/protobuf";
    mkdir -p "$LINUX_CONFIGURE_ROOT/protobuf";
    pushd "$LINUX_CONFIGURE_ROOT/protobuf";
    /toolchain/src/src/protobuf/configure \
        --prefix="$LINUX_OUTPUT_ROOT";
    make "-j$CPUS";
    make install;
    popd;
    cleanup_relink "$LINUX_OUTPUT_ROOT";
}

function build_clang_format() {
    rm -rf "$LINUX_CONFIGURE_ROOT/clang-format";
    mkdir -p "$LINUX_CONFIGURE_ROOT/clang-format";
    pushd "$LINUX_CONFIGURE_ROOT/clang-format";
    cmake -S \
        /toolchain/src/src/clang-format/llvm-17.0.6.src \
        -B build \
        -DLLVM_INCLUDE_BENCHMARKS=OFF \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX="$LINUX_OUTPUT_ROOT" \
        -DLLVM_EXTERNAL_PROJECTS=clang \
	    -DCMAKE_CXX_FLAGS="-static";
    cmake \
        --build build \
        --target clang-format \
        "-j$CPUS";
    cmake \
        --install build \
        --strip \
        --component clang-format;
    popd;
}

build_protobuf;
build_clang_format;
