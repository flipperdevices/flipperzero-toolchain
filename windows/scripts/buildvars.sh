#!/bin/bash

WINDOWS_BUILD_ROOT=/toolchain/windows-build-root
WINDOWS_OUTPUT_ROOT=/toolchain/windows-output-root
WINDOWS_CONFIGURE_ROOT=/toolchain/windows-configure-root

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
    rm -rf "$WINDOWS_BUILD_ROOT"
    rm -rf "$WINDOWS_CONFIGURE_ROOT"
    rm -rf /toolchain/src
}
