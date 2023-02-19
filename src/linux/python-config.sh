#!/bin/bash

# MacOS's readline has no -f option
readlink_f()
{
    REAL_PATH="$(cd "$(dirname "$1")" && pwd)/$(basename "$1")";
    while [ -L "$REAL_PATH" ]; do
        REAL_PATH="$(readlink "$REAL_PATH")";
        REAL_PATH="$(cd "$(dirname "$REAL_PATH")" && pwd)/$(basename "$REAL_PATH")";
    done
    echo "$REAL_PATH";
}

SCRIPT_PATH="$(dirname -- "$(readlink_f "$0")")";
PYTHON_PATH="$(cd "$SCRIPT_PATH/../python" && pwd)";

while [ $# -ge 1 ]; do
    OP="$1"
    case $OP in
        --libs|--ldflags)
            echo "$("$PYTHON_PATH/bin/python3.11-config" "$OP" --embed) -L$PYTHON_PATH/lib";;
        --*)
            echo "$("$PYTHON_PATH/bin/python3.11-config" "$OP")";;
        *)
            ;;
    esac
    shift
done
