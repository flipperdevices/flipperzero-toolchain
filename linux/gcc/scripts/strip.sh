#!/bin/bash

set -euo pipefail;

LINUX_BUILD_ROOT=/toolchain/linux-build-root
LINUX_OUTPUT_ROOT=/toolchain/linux-output-root

OBJCOPY="$LINUX_OUTPUT_ROOT/bin/arm-none-eabi-objcopy";
STRIP="strip";

LIBS=( \
	$(find "$LINUX_OUTPUT_ROOT/arm-none-eabi/lib" -name \*.a -or -name \*.o) \
	$(find "$LINUX_OUTPUT_ROOT/lib/gcc/arm-none-eabi/12.3.1" -name \*.a -or -name \*.o)
);
BINNARIES=( \
	$(find "$LINUX_OUTPUT_ROOT/bin" -name arm-none-eabi-\*) \
	$(find "$LINUX_OUTPUT_ROOT/arm-none-eabi/bin/" -maxdepth 1 -mindepth 1 -name \*) \
	$(find "$LINUX_OUTPUT_ROOT/libexec/gcc/arm-none-eabi") \
	$(find "$LINUX_OUTPUT_ROOT/lib/gcc/arm-none-eabi/12.3.1/" -maxdepth 1 -name \* -perm /111 -and ! -type d)
);

find "$LINUX_OUTPUT_ROOT" -name '*.la' -delete;

for CUR in "${LIBS[@]}"; do
	"$OBJCOPY" \
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

for CUR in "${BINNARIES[@]}"; do
	"$STRIP" "$CUR" || true;
done
