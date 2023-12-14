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

# Copy target libraries from each multilib directories.
# Usage copy_multi_libs dst_prefix=... src_prefix=... target_gcc=...
copy_multi_libs() {
    local -a multilibs
    local multilib
    local multi_dir
    local src_prefix
    local dst_prefix
    local src_dir
    local dst_dir
    local target_gcc

    for arg in "$@" ; do
        eval "${arg// /\\ }"
    done

    multilibs=( $("${target_gcc}" -print-multi-lib 2>/dev/null) )
    for multilib in "${multilibs[@]}" ; do
        multi_dir="${multilib%%;*}"
        src_dir=${src_prefix}/${multi_dir}
        dst_dir=${dst_prefix}/${multi_dir}
        cp -f "${src_dir}/libstdc++.a" "${dst_dir}/libstdc++_nano.a"
        cp -f "${src_dir}/libsupc++.a" "${dst_dir}/libsupc++_nano.a"
        cp -f "${src_dir}/libc.a" "${dst_dir}/libc_nano.a"
        cp -f "${src_dir}/libg.a" "${dst_dir}/libg_nano.a"
        cp -f "${src_dir}/librdimon.a" "${dst_dir}/librdimon_nano.a"
        cp -f "${src_dir}/nano.specs" "${dst_dir}/"
        cp -f "${src_dir}/rdimon.specs" "${dst_dir}/"
        cp -f "${src_dir}/nosys.specs" "${dst_dir}/"
        cp -f "${src_dir}/"*crt0.o "${dst_dir}/"
    done
}

copy_multi_libs src_prefix="$NEWLIB_NANO_ROOT/arm-none-eabi/lib" \
		dst_prefix="$MAC_ARM64_OUTPUT_ROOT/arm-none-eabi/lib" \
		target_gcc="$MAC_ARM64_OUTPUT_ROOT/bin/arm-none-eabi-gcc";

copy_multi_libs src_prefix="$NEWLIB_NANO_ROOT/arm-none-eabi/lib" \
		dst_prefix="$MAC_X86_64_OUTPUT_ROOT/arm-none-eabi/lib" \
		target_gcc="$MAC_X86_64_OUTPUT_ROOT/bin/arm-none-eabi-gcc";

mkdir -p "$MAC_ARM64_OUTPUT_ROOT/arm-none-eabi/include/newlib-nano";
cp -f "$NEWLIB_NANO_ROOT/arm-none-eabi/include/newlib.h" \
	"$MAC_ARM64_OUTPUT_ROOT/arm-none-eabi/include/newlib-nano/newlib.h";

mkdir -p "$MAC_X86_64_OUTPUT_ROOT/arm-none-eabi/include/newlib-nano";
cp -f "$NEWLIB_NANO_ROOT/arm-none-eabi/include/newlib.h" \
	"$MAC_X86_64_OUTPUT_ROOT/arm-none-eabi/include/newlib-nano/newlib.h";
rm -rf "$NEWLIB_NANO_ROOT";
