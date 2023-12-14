#!/bin/bash

MAC_X86_64_OUTPUT_ROOT=/toolchain/mac-x86_64-output-root
MAC_ARM64_OUTPUT_ROOT=/toolchain/mac-arm64-output-root

while [ $# -ge 1 ]; do
    OP="$1"
    case $OP in
        --libs|--ldflags)
            echo "$("$MAC_ARM64_OUTPUT_ROOT/bin/python3.11-config" "$OP" --embed) -L$MAC_ARM64_OUTPUT_ROOT/lib";;
        --*)
            echo "$("$MAC_ARM64_OUTPUT_ROOT/bin/python3.11-config" "$OP")";;
        *)
            ;;
    esac
    shift
done
