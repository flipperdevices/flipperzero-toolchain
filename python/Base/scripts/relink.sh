#!/bin/bash

set -euo pipefail;

DIRECTORY="${1:-""}";

if [[ -z "$DIRECTORY" ]]; then
    echo "Usage: $0 [directory]";
    exit 1;
fi

function check_library() {
    local LIB;
    local SEPARATOR;
    local LIB_PATH;
    local OBJECT;
    local OBJECT_RPATH;
    LIB="$1";
    SEPARATOR="$2";
    LIB_PATH="$3"
    OBJECT="$4";
    OBJECT_RPATH="$5";
    if [[ "$SEPARATOR" != "=>" ]]; then
        return 0;
    fi
    LIB_ABS_PATH="$(realpath "$LIB_PATH")";
    # excluding paths
    if grep -qE "^/lib64|^/lib|libstdc\+\+" <<< "$LIB_ABS_PATH"; then
        # Force relink
        if ! grep -qE "ncurses" <<< "$LIB"; then
            return 0;
        fi
    fi
    if [[ "$LIB_ABS_PATH" != "$LIB_PATH" ]]; then
        if [[ -n "$OBJECT_RPATH" ]]; then
            if [[ -f "$LIB_ABS_PATH" ]]; then
                return 0;
            fi
        fi
    fi
    return 1;
}

function check_object() {
    local OBJECT;
    local OBJECT_RPATH;
    local LIBS;
    local LIB;
    local SEPARATOR;
    local LIB_PATH;
    OBJECT="$1";
    echo "Checking '$OBJECT'..";
    if grep -q "nis.cpython" <<< "$OBJECT"; then
        return 0;
    fi
    OBJECT_RPATH="$(patchelf --print-rpath "$OBJECT")";
    IFS=$'\n' LIBS=( $(ldd "$OBJECT" | grep -v "statically linked") )
    for CUR in "${LIBS[@]}"; do
        LIB="$(awk '{print $1}' <<< "$CUR")";
        SEPARATOR="$(awk '{print $2}' <<< "$CUR")";
        LIB_PATH="$(awk '{print $3}' <<< "$CUR")"
        if ! check_library "$LIB" "$SEPARATOR" "$LIB_PATH" "$OBJECT" "$OBJECT_RPATH"; then
            relink_object "$OBJECT" "$LIB";
        fi
    done
    return 0;
}

function relink_object() {
    local OBJECT;
    local LIB;
    local LIB_PATH;
    local LIB_FIND_PATH;
    local LIB_REL_PATH;
    OBJECT="$1";
    LIB="$2";
    LIB_FIND_PATH="$DIRECTORY";
    echo -e "\tPATCHELF\t$OBJECT\t$LIB";
    LIB_PATH=$(find -L "$LIB_FIND_PATH" -type f ! -size 0 -name "$LIB" | head -n 1);
    if [[ ! -f "$LIB_PATH" ]]; then
        echo "ERROR: librarry $LIB for $OBJECT not found in $LIB_FIND_PATH";
        exit 1;
    fi
    LIB_REL_PATH="$(dirname "$(realpath -s "--relative-to=$(dirname "$OBJECT")" "$LIB_PATH")")";
    patchelf --remove-needed "$LIB" "$OBJECT";
    patchelf --set-rpath "\$ORIGIN/$LIB_REL_PATH" "$OBJECT";
    patchelf --add-needed "$LIB" "$OBJECT";
}

OBJECTS=( $(find "$DIRECTORY" -type f ! -size 0 ! -name "*.a" -and ! -name "*.o" -exec file {} \; | grep ELF | awk -F ': ELF' '{print $1}') );
for CUR in "${OBJECTS[@]}"; do
    if ! check_object "$CUR"; then
        relink_object "$CUR";
    fi
done
