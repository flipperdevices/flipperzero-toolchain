#!/bin/bash

set -euo pipefail;

LINUX_BUILD_ROOT=/toolchain/linux-build-root
LINUX_OUTPUT_ROOT=/toolchain/linux-output-root
LINUX_CONFIGURE_ROOT=/toolchain/linux-configure-root

CPUS="$(grep -c processor /proc/cpuinfo )";
ARCH="$(uname -m)";

export PKG_CONFIG_PATH="$LINUX_OUTPUT_ROOT/lib/pkgconfig";

function cleanup_relink() {
    local DIRECTORY;
    DIRECTORY="$1";
    find "$DIRECTORY" \( -name "*.a" -or -name "*.la" \) -delete;
    rm -rf "$DIRECTORY/share/man"
    relink.sh "$DIRECTORY";
}

function copy_libudev() {
    mkdir -p "$LINUX_OUTPUT_ROOT/lib";
    cp -r /usr/lib/x86_64-linux-gnu/libudev.so.1* "$LINUX_OUTPUT_ROOT/lib/";
}

function build_protobuf() {
    rm -rf "$LINUX_CONFIGURE_ROOT/protobuf";
    mkdir -p "$LINUX_CONFIGURE_ROOT/protobuf";
    pushd "$LINUX_CONFIGURE_ROOT/protobuf";
    /toolchain/src/src/protobuf/configure \
        --prefix="$LINUX_OUTPUT_ROOT";
    make "-j$CPUS";
    make install;
    popd;
    cleanup_relink "$LINUX_OUTPUT_ROOT";
}

function build_clang_format() {
    rm -rf "$LINUX_CONFIGURE_ROOT/clang-format";
    mkdir -p "$LINUX_CONFIGURE_ROOT/clang-format";
    pushd "$LINUX_CONFIGURE_ROOT/clang-format";
    cmake -S \
        /toolchain/src/src/clang-format/llvm-17.0.6.src \
        -B build \
        -DLLVM_INCLUDE_BENCHMARKS=OFF \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX="$LINUX_OUTPUT_ROOT" \
        -DLLVM_EXTERNAL_PROJECTS=clang;
    cmake \
        --build build \
        --target clang-format \
        "-j$CPUS";
    cmake \
        --install build \
        --strip \
        --component clang-format;
    popd;
}

function build_libusb() {
    rm -rf "$LINUX_CONFIGURE_ROOT/libusb";
    mkdir -p "$LINUX_CONFIGURE_ROOT/libusb";
    pushd "$LINUX_CONFIGURE_ROOT/libusb";
    /toolchain/src/src/libusb/configure \
        --prefix="$LINUX_OUTPUT_ROOT";
    make "-j$CPUS";
    make install;
    popd;
    cleanup_relink "$LINUX_OUTPUT_ROOT";
}

function build_hidapi() {
    rm -rf "$LINUX_CONFIGURE_ROOT/hidapi";
    mkdir -p "$LINUX_CONFIGURE_ROOT/hidapi";
    pushd "$LINUX_CONFIGURE_ROOT/hidapi";
    cmake \
        -S "/toolchain/src/src/hidapi" \
        "-DCMAKE_INSTALL_PREFIX=$LINUX_OUTPUT_ROOT";
    make "-j$CPUS";
    make install;
    popd;
    cleanup_relink "$LINUX_OUTPUT_ROOT";
}

function build_openocd() {
    rm -rf "$LINUX_CONFIGURE_ROOT/openocd";
    mkdir -p "$LINUX_CONFIGURE_ROOT/openocd";
    pushd "/toolchain/src/src/openocd";
    ./bootstrap;
    popd;
    pushd "$LINUX_CONFIGURE_ROOT/openocd";
    LDFLAGS="-L$LINUX_OUTPUT_ROOT/lib" CPPFLAGS="-I$LINUX_OUTPUT_ROOT/include"  LD_LIBRARY_PATH="$LINUX_OUTPUT_ROOT/lib" \
        /toolchain/src/src/openocd/configure \
            "--prefix=$LINUX_OUTPUT_ROOT" \
            "--host=$ARCH-linux-gnu" \
            "--target=$ARCH-linux-gnu" \
            "--datarootdir=$LINUX_OUTPUT_ROOT" \
            "--localedir=$LINUX_OUTPUT_ROOT/share/locale" \
            "--disable-wextra" \
            "--disable-werror" \
            "--disable-gccwarnings" \
            "--disable-doxygen-html" \
            "--disable-doxygen-pdf" \
            "--disable-debug" \
            "--disable-dependency-tracking" \
            "--enable-cmsis-dap" \
            "--enable-dummy" \
            "--enable-stlink" \
            "--disable-zy1000-master" \
            "--disable-zy1000" \
            "--disable-ioutil" \
            "--disable-minidriver-dummy" \
            "--disable-parport-ppdev" \
            "--enable-amtjtagaccel" \
            "--enable-buspirate" \
            "--enable-gw16012" \
            "--enable-parport" \
            "--enable-parport-giveio" \
            "--enable-sysfsgpio";
    LDFLAGS="-L$LINUX_OUTPUT_ROOT/lib" CPPFLAGS="-I$LINUX_OUTPUT_ROOT/include"  LD_LIBRARY_PATH="$LINUX_OUTPUT_ROOT/lib" \
        make "-j$CPUS";
    make install-strip;
    popd;
    cleanup_relink "$LINUX_OUTPUT_ROOT";
}

build_protobuf;
build_clang_format;
copy_libudev;
build_libusb;
build_hidapi;
build_openocd;
