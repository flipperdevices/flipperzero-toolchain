#!/bin/bash

LINUX_BUILD_ROOT=/toolchain/linux-build-root
LINUX_OUTPUT_ROOT=/toolchain/linux-output-root
LINUX_CONFIGURE_ROOT=/toolchain/linux-configure-root

NEWLIB_ROOT=/toolchain/newlib-root
NEWLIB_NANO_ROOT=/toolchain/newlib-nano-root

CMD=${1:-}

CPUS=$(($(nproc) + 1))
ARCH_BUILD=$(uname -m | sed 'y/XI/xi/')

function cleanup_relink() {
    local DIRECTORY;
    DIRECTORY="$1";
    find "$DIRECTORY" \
        -type f \
        \( -name "*.a" -or -name "*.la" \) \
        -delete;
    rm -rf "$DIRECTORY/share/man"
    relink.sh "$DIRECTORY";
}

cmd() {
    echo "[#] $*" >&2
    "$@"
}

die() {
    echo "[!] $*" >&2
    exit 1
}

cleanup_after_build() {
    rm -rf "$LINUX_BUILD_ROOT"
    rm -rf "$LINUX_CONFIGURE_ROOT"
    rm -rf /toolchain/src
}
