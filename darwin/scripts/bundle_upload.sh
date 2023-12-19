#!/bin/bash

set -euo pipefail;

# external required variables:
#   TOOLCHAIN_VERSION
#   INDEXER_URl
#   INDEXER_TOKEN
echo "Bundling toolchain version: $TOOLCHAIN_VERSION";

MAC_X86_64_OUTPUT_ROOT=/toolchain/mac-x86_64-output-root
MAC_ARM64_OUTPUT_ROOT=/toolchain/mac-arm64-output-root
GCC_VERSION="12.3";

MAC_X86_64_OUTPUT_ROOT_BASE_DIR="$(dirname "$MAC_X86_64_OUTPUT_ROOT")";
MAC_X86_64_TOOLCHAIN_DIR_NAME="gcc-arm-none-eabi-$GCC_VERSION-x86_64-darwin-flipper";
MAC_X86_64_OUTPUT_ROOT_NEW="$MAC_X86_64_OUTPUT_ROOT_BASE_DIR/$MAC_X86_64_TOOLCHAIN_DIR_NAME";
MAC_X86_64_OUTPUT_FILE="$MAC_X86_64_OUTPUT_ROOT_NEW-$TOOLCHAIN_VERSION.tar.gz";

MAC_ARM64_OUTPUT_ROOT_BASE_DIR="$(dirname "$MAC_ARM64_OUTPUT_ROOT")";
MAC_ARM64_TOOLCHAIN_DIR_NAME="gcc-arm-none-eabi-$GCC_VERSION-arm64-darwin-flipper";
MAC_ARM64_OUTPUT_ROOT_NEW="$MAC_ARM64_OUTPUT_ROOT_BASE_DIR/$MAC_ARM64_TOOLCHAIN_DIR_NAME";
MAC_ARM64_OUTPUT_FILE="$MAC_ARM64_OUTPUT_ROOT_NEW-$TOOLCHAIN_VERSION.tar.gz";

function prepare_dir_x86_64() {
	mv "$MAC_X86_64_OUTPUT_ROOT" "$MAC_X86_64_OUTPUT_ROOT_NEW";
	printf "$TOOLCHAIN_VERSION" > "$MAC_X86_64_OUTPUT_ROOT_NEW/VERSION";
}
function prepare_dir_arm64() {
	mv "$MAC_ARM64_OUTPUT_ROOT" "$MAC_ARM64_OUTPUT_ROOT_NEW";
	printf "$TOOLCHAIN_VERSION" > "$MAC_ARM64_OUTPUT_ROOT_NEW/VERSION";
}

function make_bundle_x86_64() {
	pushd "$MAC_X86_64_OUTPUT_ROOT_BASE_DIR";
	tar -czvf \
		"$MAC_X86_64_OUTPUT_FILE" \
		"$MAC_X86_64_TOOLCHAIN_DIR_NAME";
	popd;
}
function make_bundle_arm64() {
	pushd "$MAC_ARM64_OUTPUT_ROOT_BASE_DIR";
	tar -czvf \
		"$MAC_ARM64_OUTPUT_FILE" \
		"$MAC_ARM64_TOOLCHAIN_DIR_NAME";
	popd;
}

function upload_bundle_x86_64() {
    curl --fail --http1.1 -L -H "Token: $INDEXER_TOKEN" \
        -F "files=@$MAC_X86_64_OUTPUT_FILE" \
        "$INDEXER_URL"/toolchain/uploadfilesraw;
}
function upload_bundle_arm64() {
    curl --fail --http1.1 -L -H "Token: $INDEXER_TOKEN" \
        -F "files=@$MAC_ARM64_OUTPUT_FILE" \
        "$INDEXER_URL"/toolchain/uploadfilesraw;
}

prepare_dir_x86_64;
make_bundle_x86_64;
upload_bundle_x86_64;
prepare_dir_arm64;
make_bundle_arm64;
upload_bundle_arm64;

