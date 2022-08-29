#!/bin/bash

set -euo pipefail;

TOOLCHAIN_DIR="temp/unpack/gcc-arm-none-eabi-10.3-x86_64-darwin-flipper";

cd "$TOOLCHAIN_DIR";

WRONG_LIBS=( $(find . -mindepth 1 -type f -perm +111 -exec otool -L {} \; \
    | grep "/usr/local\|/Users" \
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
        REGEX="[[:space:]](\/[^[:space:]]+${LIB//./\\.})";
        if [[ $OTOOL_OUT =~ $REGEX ]]; then
            WRONG_LIB_PATH="${BASH_REMATCH[1]}";
        else
            continue;
        fi
        LIB_PATH="$(find . -mindepth 1 -name "$LIB")";
        if [ -z "$LIB_PATH" ]; then
            echo "Library $LIB not found, skipping file $FILE..";
            continue;
        fi
        REL_LIB_PATH="$(realpath --relative-to="$(dirname "$FILE")" "$LIB_PATH")";
        install_name_tool -change "$WRONG_LIB_PATH" "@executable_path/$REL_LIB_PATH" "$FILE";
    done
done
