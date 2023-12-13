#!/bin/bash

set -euo pipefail;

WINDOWS_CONFIGURE_ROOT=/toolchain/windows-configure-root
WINDOWS_BUILD_ROOT=/toolchain/windows-build-root
WINDOWS_OUTPUT_ROOT=/toolchain/windows-output-root

CPUS="$(grep -c processor /proc/cpuinfo )";

OBJCOPY="arm-none-eabi-objcopy";

STRIP="x86_64-w64-mingw32-strip";

LIBS=( \
	$(find "$WINDOWS_OUTPUT_ROOT/arm-none-eabi/lib" -name \*.a -or -name \*.o) \
	$(find "$WINDOWS_OUTPUT_ROOT/lib/gcc/arm-none-eabi/12.3.1" -name \*.a -or -name \*.o)
);
BINNARIES=( \
	$(find "$WINDOWS_OUTPUT_ROOT/bin" -name arm-none-eabi-\*.exe) \
	$(find "$WINDOWS_OUTPUT_ROOT/arm-none-eabi/bin/" -maxdepth 1 -mindepth 1 -name \*.exe) \
	$(find "$WINDOWS_OUTPUT_ROOT/libexec/gcc/arm-none-eabi") \
	$(find "$WINDOWS_OUTPUT_ROOT/lib/gcc/arm-none-eabi/12.3.1/" -maxdepth 1 -name \*.exe -perm /111 -and ! -type d)
);

find "$WINDOWS_OUTPUT_ROOT" -name '*.la' -delete;

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
