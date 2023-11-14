#!/bin/bash

set -euo pipefail;

LINUX_OUTPUT_ROOT=/toolchain/linux-output-root
NEWLIB_NANO_TEMP_ROOT=/toolchain/newlib-nano-temp

CPUS="$(grep -c processor /proc/cpuinfo )";

function move_newlib_to_nano() {
    mv "$NEWLIB_NANO_TEMP_ROOT/arm-none-eabi/lib/libstdc++.a" "$LINUX_OUTPUT_ROOT/arm-none-eabi/lib/libstdc++_nano.a";
    mv "$NEWLIB_NANO_TEMP_ROOT/arm-none-eabi/lib/libsupc++.a" "$LINUX_OUTPUT_ROOT/arm-none-eabi/lib/libsupc++_nano.a";
    mv "$NEWLIB_NANO_TEMP_ROOT/arm-none-eabi/lib/libc.a" "$LINUX_OUTPUT_ROOT/arm-none-eabi/lib/libc_nano.a";
    mv "$NEWLIB_NANO_TEMP_ROOT/arm-none-eabi/lib/libg.a" "$LINUX_OUTPUT_ROOT/arm-none-eabi/lib/libg_nano.a";
    mv "$NEWLIB_NANO_TEMP_ROOT/arm-none-eabi/lib/librdimon.a" "$LINUX_OUTPUT_ROOT/arm-none-eabi/lib/librdimon_nano.a";
    mv "$NEWLIB_NANO_TEMP_ROOT/arm-none-eabi/lib/nano.specs" "$LINUX_OUTPUT_ROOT/arm-none-eabi/lib/nano.specs";
    mv "$NEWLIB_NANO_TEMP_ROOT/arm-none-eabi/lib/rdimon.specs" "$LINUX_OUTPUT_ROOT/arm-none-eabi/lib/rdimon.specs";
    mv "$NEWLIB_NANO_TEMP_ROOT/arm-none-eabi/lib/nosys.specs" "$LINUX_OUTPUT_ROOT/arm-none-eabi/lib/nosys.specs";
    mv "$NEWLIB_NANO_TEMP_ROOT/arm-none-eabi/lib"/*crt0.o "$LINUX_OUTPUT_ROOT/arm-none-eabi/lib/";

    mkdir -p "$LINUX_OUTPUT_ROOT/arm-none-eabi/include/newlib-nano";
    mv "$NEWLIB_NANO_TEMP_ROOT/arm-none-eabi/include/newlib.h" "$LINUX_OUTPUT_ROOT/arm-none-eabi/include/newlib-nano/newlib.h";
}

move_newlib_to_nano;
