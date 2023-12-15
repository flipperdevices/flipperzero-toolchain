#!/bin/bash

set -euo pipefail;

TOOLCHAIN_VERSION="24";
GCC_VERSION="12.3";

LINUX_ROOT="/toolchain";
LINUX_OUTPUT_ROOT="linux-output-root";
LINUX_OUTPUT_DIR="gcc-arm-none-eabi-$GCC_VERSION-x86_64-linux-flipper";

function prepare_dir() {
	mv "$LINUX_ROOT/$LINUX_OUTPUT_ROOT" "$LINUX_ROOT/$LINUX_OUTPUT_DIR";
	printf "$TOOLCHAIN_VERSION" > "$LINUX_ROOT/$LINUX_OUTPUT_DIR/VERSION";
}

function make_bundle() {
	pushd "$LINUX_ROOT";
	tar -czvf \
		"$LINUX_ROOT/gcc-arm-none-eabi-$GCC_VERSION-x86_64-linux-flipper-$TOOLCHAIN_VERSION.tar.gz" \
		"$LINUX_OUTPUT_DIR";
	popd;
}

prepare_dir;
make_bundle;
