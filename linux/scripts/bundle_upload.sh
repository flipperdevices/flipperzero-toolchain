#!/bin/bash

set -euo pipefail;

# external required variables:
#   TOOLCHAIN_VERSION
#   INDEXER_URl
#   INDEXER_TOKEN
echo "Bundling toolchain version: $TOOLCHAIN_VERSION";

LINUX_OUTPUT_ROOT=/toolchain/linux-output-root
GCC_VERSION="12.3";
ARCH="x86_64";

LINUX_OUTPUT_ROOT_BASE_DIR="$(dirname "$LINUX_OUTPUT_ROOT")";
LINUX_TOOLCHAIN_DIR_NAME="gcc-arm-none-eabi-$GCC_VERSION-$ARCH-linux-flipper";
LINUX_OUTPUT_ROOT_NEW="$LINUX_OUTPUT_ROOT_BASE_DIR/$LINUX_TOOLCHAIN_DIR_NAME";
LINUX_OUTPUT_FILE="$LINUX_OUTPUT_ROOT_NEW-$TOOLCHAIN_VERSION.tar.gz";

function prepare_dir() {
	mv "$LINUX_OUTPUT_ROOT" "$LINUX_OUTPUT_ROOT_NEW";
	printf "$TOOLCHAIN_VERSION" > "$LINUX_OUTPUT_ROOT_NEW/VERSION";
}

function make_bundle() {
	pushd "$LINUX_OUTPUT_ROOT_BASE_DIR";
	tar -czvf \
		"$LINUX_OUTPUT_FILE" \
		"$LINUX_TOOLCHAIN_DIR_NAME";
	popd;
}

function upload_bundle() {
    curl --fail -L -H "Token: $INDEXER_TOKEN" \
        -F "files=@$LINUX_OUTPUT_FILE" \
        "$INDEXER_URL"/toolchain/uploadfilesraw;
}

prepare_dir;
make_bundle;
upload_bundle;
