#!/bin/bash

set -euo pipefail;

WINDOWS_CONFIGURE_ROOT=/toolchain/windows-configure-root
WINDOWS_BUILD_ROOT=/toolchain/windows-build-root
WINDOWS_OUTPUT_ROOT=/toolchain/windows-output-root

CPUS="$(grep -c processor /proc/cpuinfo )";

build_windows_gdb() {
    rm -rf "$WINDOWS_CONFIGURE_ROOT/gdb";
    mkdir -p "$WINDOWS_CONFIGURE_ROOT/gdb";
    pushd "$WINDOWS_CONFIGURE_ROOT/gdb";
    LDFLAGS="-L$WINDOWS_BUILD_ROOT/lib -L$WINDOWS_OUTPUT_ROOT/lib" CPPFLAGS="-I$WINDOWS_BUILD_ROOT/include -I$WINDOWS_OUTPUT_ROOT/include -I$WINDOWS_OUTPUT_ROOT/include/readline" "/toolchain/src/src/binutils-gdb/configure" \
        --host=x86_64-w64-mingw32 \
        --target=arm-none-eabi \
        --enable-initfini-array \
        --disable-werror \
        --disable-nls \
        --without-x \
        --disable-gdbtk \
        --without-tcl \
        --without-tk \
        --without-libunwind-ia64 \
        --without-lzma \
        --without-babeltrace \
        --without-intel-pt \
        --without-xxhash \
        --without-debuginfod \
        --without-guile \
        --disable-source-highlight \
        --with-static-standard-libraries \
        --disable-objc-gc \
        --with-expat \
        "--with-libexpat-prefix=$WINDOWS_BUILD_ROOT" \
        --with-libexpat-type=static \
        --disable-binutils \
        --disable-sim \
        --disable-as \
        --disable-ld \
        --enable-plugins \
        "--with-libmpfr-prefix=$WINDOWS_BUILD_ROOT" \
        --with-libmpfr-type=static \
        "--with-mpfr=$WINDOWS_BUILD_ROOT" \
        "--with-libgmp-prefix=$WINDOWS_BUILD_ROOT" \
        --with-libgmp-type=static \
        "--with-gmp=$WINDOWS_BUILD_ROOT" \
        --with-python=no \
        --prefix="$WINDOWS_OUTPUT_ROOT" \
        --with-sysroot="$WINDOWS_OUTPUT_ROOT/arm-none-eabi" \
        LDFLAGS="-L$WINDOWS_BUILD_ROOT/lib -L$WINDOWS_OUTPUT_ROOT/lib" \
        CPPFLAGS="-I$WINDOWS_BUILD_ROOT/include -I$WINDOWS_OUTPUT_ROOT/include -I$WINDOWS_OUTPUT_ROOT/include/readline";
    LDFLAGS="-L$WINDOWS_BUILD_ROOT/lib -L$WINDOWS_OUTPUT_ROOT/lib" CPPFLAGS="-I$WINDOWS_BUILD_ROOT/include -I$WINDOWS_OUTPUT_ROOT/include -I$WINDOWS_OUTPUT_ROOT/include/readline" make "-j$CPUS" CXXFLAGS="-g -O2";
    LDFLAGS="-L$WINDOWS_BUILD_ROOT/lib -L$WINDOWS_OUTPUT_ROOT/lib" CPPFLAGS="-I$WINDOWS_BUILD_ROOT/include -I$WINDOWS_OUTPUT_ROOT/include -I$WINDOWS_OUTPUT_ROOT/include/readline" make install;
    popd;
}

build_windows_gdb_py() {
    rm -rf "$WINDOWS_CONFIGURE_ROOT/gdb-py";
    mkdir -p "$WINDOWS_CONFIGURE_ROOT/gdb-py";
    pushd "$WINDOWS_CONFIGURE_ROOT/gdb-py";
    LDFLAGS="-L$WINDOWS_BUILD_ROOT/lib -L$WINDOWS_OUTPUT_ROOT/lib" CPPFLAGS="-I$WINDOWS_BUILD_ROOT/include -I$WINDOWS_OUTPUT_ROOT/include -I$WINDOWS_OUTPUT_ROOT/include/readline" "/toolchain/src/src/binutils-gdb/configure" \
        --host=x86_64-w64-mingw32 \
        --target=arm-none-eabi \
        --enable-initfini-array \
        --disable-werror \
        --disable-nls \
        --without-x \
        --disable-gdbtk \
        --without-tcl \
        --without-tk \
        --without-libunwind-ia64 \
        --without-lzma \
        --without-babeltrace \
        --without-intel-pt \
        --without-xxhash \
        --without-debuginfod \
        --without-guile \
        --disable-source-highlight \
        --with-static-standard-libraries \
        --disable-objc-gc \
        --with-expat \
        "--with-libexpat-prefix=$WINDOWS_BUILD_ROOT" \
        --with-libexpat-type=static \
        --disable-binutils \
        --disable-sim \
        --disable-as \
        --disable-ld \
        --enable-plugins \
        "--with-libmpfr-prefix=$WINDOWS_BUILD_ROOT" \
        --with-libmpfr-type=static \
        "--with-mpfr=$WINDOWS_BUILD_ROOT" \
        "--with-libgmp-prefix=$WINDOWS_BUILD_ROOT" \
        --with-libgmp-type=static \
        "--with-gmp=$WINDOWS_BUILD_ROOT" \
        "--with-python=/toolchain/src/python3-config-windows-x86_64.sh" \
        "--program-prefix=arm-none-eabi-" \
        "--program-suffix=-py3" \
        --prefix="$WINDOWS_OUTPUT_ROOT" \
        --with-sysroot="$WINDOWS_OUTPUT_ROOT/arm-none-eabi" \
        LDFLAGS="-L$WINDOWS_BUILD_ROOT/lib -L$WINDOWS_OUTPUT_ROOT/lib" \
        CPPFLAGS="-I$WINDOWS_BUILD_ROOT/include -I$WINDOWS_OUTPUT_ROOT/include -I$WINDOWS_OUTPUT_ROOT/include/readline";
    LDFLAGS="-L$WINDOWS_BUILD_ROOT/lib -L$WINDOWS_OUTPUT_ROOT/lib" CPPFLAGS="-I$WINDOWS_BUILD_ROOT/include -I$WINDOWS_OUTPUT_ROOT/include -I$WINDOWS_OUTPUT_ROOT/include/readline" make "-j$CPUS" CXXFLAGS="-g -O2";
    LDFLAGS="-L$WINDOWS_BUILD_ROOT/lib -L$WINDOWS_OUTPUT_ROOT/lib" CPPFLAGS="-I$WINDOWS_BUILD_ROOT/include -I$WINDOWS_OUTPUT_ROOT/include -I$WINDOWS_OUTPUT_ROOT/include/readline" make install;
    popd;
}

build_windows_gdb;
build_windows_gdb_py;
