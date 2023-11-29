#!/bin/bash

set -euo pipefail;

LINUX_BUILD_ROOT=/toolchain/linux-build-root
LINUX_OUTPUT_ROOT=/toolchain/linux-output-root

CPUS="$(grep -c processor /proc/cpuinfo )";

function cleanup_relink() {
    local DIRECTORY;
    DIRECTORY="$1";
    find "$DIRECTORY" \
        -type f \
        -name "*.a" \
        -delete;
    rm -rf "$DIRECTORY/share/man"
    relink.sh "$DIRECTORY";
}

function build_protobuf() {
    pushd /toolchain/src/src/protobuf;
    ./configure \
        --prefix="$LINUX_OUTPUT_ROOT";
    make "-j$CPUS";
    make install;
    popd;
    cleanup_relink "$LINUX_OUTPUT_ROOT";
}

build_protobuf;
