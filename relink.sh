#!/bin/bash

set -euo pipefail;

TOOLCHAIN_DIR="temp/unpack/gcc-arm-none-eabi-10.3-x86_64-darwin-flipper";

cd "$TOOLCHAIN_DIR";

WRONG_LIBS=( $(find . -mindepth 1 -type f -perm +111 -exec otool -L {} \; \
    | grep "/usr/local" \
    | awk '{print $1}' \
    | sort -u \
    | xargs basename) );

ALL_FILES=( $(find . -mindepth 1 -type f -perm +111) );

for FILE in "${ALL_FILES[@]}"; do
    for LIB in "${WRONG_LIBS[@]}"; do
        OTOOL_OUT=$(otool -L "$FILE");
        if ! grep -q "$LIB" <<< "$OTOOL_OUT"; then
            continue;
        fi
        echo "File $FILE linked to $LIB";
        LIB_PATH="$(find . -mindepth 1 -name "$LIB")";
        if [ -z "$LIB_PATH" ]; then
            echo "Library $LIB not found, skipping..";
            continue;
        fi
        echo "Lib found at: $LIB_PATH";
        REL_LIB_PATH="$(realpath --relative-to="$(dirname "$FILE")" "$LIB_PATH")";
        echo "For $FILE lib exist in $REL_LIB_PATH";
    done
done

# realpath --relative-to="./bin" ./gettext/lib/libintl.8.dylib
