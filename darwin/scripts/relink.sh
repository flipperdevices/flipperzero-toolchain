#!/bin/bash

# shellcheck disable=SC2207

set -euo pipefail;

DIRECTORY="${1:-""}";

if [[ -z "$DIRECTORY" ]]; then
    echo "Usage: $0 [directory]";
    exit 1;
fi

DIRECTORY="$(realpath "$DIRECTORY")";  # removing trailing backslash

function check_library() {
    local LIB_CURRENT_FULL_PATH;
    local OBJECT;
    LIB_CURRENT_FULL_PATH="$1";
    OBJECT="$2";
    # excluding paths
    if grep -qE "^@loader_path" <<< "$LIB_CURRENT_FULL_PATH"; then
        return 0;
    fi
    # bazel-out - is a prefix to protobuf shared libaries id, id name isn't match lib name, there is no way to catch it
    if grep -qE "^/usr/lib|^/System|^bazel-out" <<< "$LIB_CURRENT_FULL_PATH"; then
        return 0;
    fi
    return 1;
}

function check_object() {
    local OBJECT;
    local LIBS;
    OBJECT="$1";
    echo "Checking '$OBJECT'..";
    IFS=$'\n' LIBS=( $(otool -L "$OBJECT" | grep -v "statically linked" | grep -E "^\t") )
    for CUR in "${LIBS[@]}"; do
        LIB_CURRENT_FULL_PATH="$(awk '{print $1}' <<< "$CUR")";
        if ! check_library "$LIB_CURRENT_FULL_PATH" "$OBJECT"; then
            relink_object "$OBJECT" "$LIB_CURRENT_FULL_PATH";
        fi
    done
    return 0;
}

function relink_object() {
    local OBJECT;
    local LIB_CURRENT_FULL_PATH;
    local LIB_NAME;
    local LIB_PATH;
    local LIB_NEW_PATH;
    local LIB_FIND_PATH;
    local LIB_REL_PATH;
    OBJECT="$1";
    LIB_CURRENT_FULL_PATH="$2";
    LIB_FIND_PATH="$DIRECTORY";
    LIB_NAME="$(basename "$LIB_CURRENT_FULL_PATH")";
    echo -e "\tINSTALL_NAME_TOOL\t$OBJECT\t$LIB_NAME";
    LIB_PATH=$(find -L "$LIB_FIND_PATH" -type f ! -size 0 -name "$LIB_NAME" | head -n 1);
    if [[ ! -f "$LIB_PATH" ]]; then
        echo "ERROR: librarry $LIB_NAME for $OBJECT not found in $LIB_FIND_PATH";
        exit 1;
    fi
    if [[ "$LIB_NAME" == "$(basename "$OBJECT")" ]]; then
        #install_name_tool -id "@loader_path/$LIB_NAME" "$OBJECT";
        echo "WARNING: id of librarry $LIB_NAME doesn't changed!";
    else
        LIB_REL_PATH="$(grealpath -s "--relative-to=$(dirname "$OBJECT")" "$LIB_PATH")";
        LIB_NEW_PATH="@loader_path/$LIB_REL_PATH";
        install_name_tool -change "$LIB_CURRENT_FULL_PATH" "$LIB_NEW_PATH" "$OBJECT";
    fi
}

OBJECTS=( $(find "$DIRECTORY" -type f ! -size 0 ! -name "*.a" -and ! -name "*.o" -exec file {} \; | grep Mach-O | awk -F ': Mach-O' '{print $1}' | awk '{print $1}' | sort -u) );
for CUR in "${OBJECTS[@]}"; do
    if ! check_object "$CUR"; then
        relink_object "$CUR";
    fi
done
