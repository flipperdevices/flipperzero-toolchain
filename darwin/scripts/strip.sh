#!/bin/bash

set -euo pipefail;

MAC_X86_64_CONFIGURE_ROOT=/toolchain/mac-x86_64-configure-root
MAC_ARM64_CONFIGURE_ROOT=/toolchain/mac-arm64-configure-root
MAC_X86_64_BUILD_ROOT=/toolchain/mac-x86_64-build-root
MAC_ARM64_BUILD_ROOT=/toolchain/mac-arm64-build-root
MAC_X86_64_OUTPUT_ROOT=/toolchain/mac-x86_64-output-root
MAC_ARM64_OUTPUT_ROOT=/toolchain/mac-arm64-output-root

X86_64_OBJCOPY="$MAC_X86_64_OUTPUT_ROOT/bin/arm-none-eabi-objcopy";
ARM64_OBJCOPY="$MAC_ARM64_OUTPUT_ROOT/bin/arm-none-eabi-objcopy";

STRIP="strip";

X86_64_LIBS=( \
	$(find "$MAC_X86_64_OUTPUT_ROOT/arm-none-eabi/lib" -name \*.a -or -name \*.o) \
	$(find "$MAC_X86_64_OUTPUT_ROOT/lib/gcc/arm-none-eabi/12.3.1" -name \*.a -or -name \*.o)
);
ARM64_LIBS=( \
	$(find "$MAC_ARM64_OUTPUT_ROOT/arm-none-eabi/lib" -name \*.a -or -name \*.o) \
	$(find "$MAC_ARM64_OUTPUT_ROOT/lib/gcc/arm-none-eabi/12.3.1" -name \*.a -or -name \*.o)
);
X86_64_BINNARIES=( \
	$(find "$MAC_X86_64_OUTPUT_ROOT/bin" -name arm-none-eabi-\*) \
	$(find "$MAC_X86_64_OUTPUT_ROOT/arm-none-eabi/bin/" -maxdepth 1 -mindepth 1 -name \*) \
	$(find "$MAC_X86_64_OUTPUT_ROOT/libexec/gcc/arm-none-eabi") \
	$(find "$MAC_X86_64_OUTPUT_ROOT/lib/gcc/arm-none-eabi/12.3.1/" -maxdepth 1 -name \* -perm +111 -and ! -type d)
);
ARM64_BINNARIES=( \
	$(find "$MAC_ARM64_OUTPUT_ROOT/bin" -name arm-none-eabi-\*) \
	$(find "$MAC_ARM64_OUTPUT_ROOT/arm-none-eabi/bin/" -maxdepth 1 -mindepth 1 -name \*) \
	$(find "$MAC_ARM64_OUTPUT_ROOT/libexec/gcc/arm-none-eabi") \
	$(find "$MAC_ARM64_OUTPUT_ROOT/lib/gcc/arm-none-eabi/12.3.1/" -maxdepth 1 -name \* -perm +111 -and ! -type d)
);


find "$MAC_X86_64_OUTPUT_ROOT" -name '*.la' -delete;
find "$MAC_ARM64_OUTPUT_ROOT" -name '*.la' -delete;

for CUR in "${X86_64_LIBS[@]}"; do
	"$X86_64_OBJCOPY" \
		-R .comment \
		-R .note \
		-R .debug_aranges \
		-R .debug_pubnames \
		-R .debug_pubtypes \
		-R .debug_ranges \
		-R .debug_loc \
		-R .debug_frame \
		-R .debug_abbrev \
		-R .debug_loclists \
		-R .debug_rnglists \
		-R .debug_line \
		-R .debug_str \
		-R .debug_info \
		"$CUR";
done
for CUR in "${ARM64_LIBS[@]}"; do
	"$ARM64_OBJCOPY" \
		-R .comment \
		-R .note \
		-R .debug_aranges \
		-R .debug_pubnames \
		-R .debug_pubtypes \
		-R .debug_ranges \
		-R .debug_loc \
		-R .debug_frame \
		-R .debug_abbrev \
		-R .debug_loclists \
		-R .debug_rnglists \
		-R .debug_line \
		-R .debug_str \
		-R .debug_info \
		"$CUR";
done

for CUR in "${X86_64_BINNARIES[@]}"; do
	"$STRIP" "$CUR" || true;
done
for CUR in "${ARM64_BINNARIES[@]}"; do
	"$STRIP" "$CUR" || true;
done
