#!/bin/bash

set -euo pipefail;

# external required variables:
#   TOOLCHAIN_VERSION
#   INDEXER_URl
#   INDEXER_TOKEN
echo "Bundling toolchain version: $TOOLCHAIN_VERSION";

WINDOWS_OUTPUT_ROOT=/toolchain/windows-output-root
GCC_VERSION="12.3";
ARCH="x86_64";

WINDOWS_OUTPUT_ROOT_BASE_DIR="$(dirname "$WINDOWS_OUTPUT_ROOT")";
WINDOWS_TOOLCHAIN_DIR_NAME="gcc-arm-none-eabi-$GCC_VERSION-$ARCH-windows-flipper";
WINDOWS_OUTPUT_ROOT_NEW="$WINDOWS_OUTPUT_ROOT_BASE_DIR/$WINDOWS_TOOLCHAIN_DIR_NAME";
WINDOWS_OUTPUT_FILE="$WINDOWS_OUTPUT_ROOT_NEW-$TOOLCHAIN_VERSION.zip";

function prepare_dir() {
	mv "$WINDOWS_OUTPUT_ROOT" "$WINDOWS_OUTPUT_ROOT_NEW";
	printf "$TOOLCHAIN_VERSION" > "$WINDOWS_OUTPUT_ROOT_NEW/VERSION";
}

function make_bundle() {
	pushd "$WINDOWS_OUTPUT_ROOT_BASE_DIR";
	zip -r \
		"$WINDOWS_OUTPUT_FILE" \
		"$WINDOWS_TOOLCHAIN_DIR_NAME";
	popd;
}

function upload_bundle() {
    curl --fail --http1.1 -L -H "Token: $INDEXER_TOKEN" \
        -F "files=@$WINDOWS_OUTPUT_FILE" \
        "$INDEXER_URL"/toolchain/uploadfilesraw;
}

prepare_dir;
make_bundle;
upload_bundle;
