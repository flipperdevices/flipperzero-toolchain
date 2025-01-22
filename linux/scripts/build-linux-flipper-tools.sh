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
    cp -r /usr/lib/$ARCH-linux-gnu/libudev.so.1* "$LINUX_OUTPUT_ROOT/lib/";
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

function build_llvm() {
    rm -rf "$LINUX_CONFIGURE_ROOT/llvm";
    mkdir -p "$LINUX_CONFIGURE_ROOT/llvm";
    pushd "$LINUX_CONFIGURE_ROOT/llvm";
    cmake -S \
        /toolchain/src/src/llvm/llvm-18.1.8.src \
        -B build \
        -DLLVM_INCLUDE_BENCHMARKS=OFF \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX="$LINUX_OUTPUT_ROOT" \
        "-DLLVM_EXTERNAL_PROJECTS=clang;clang-tools-extra" \
        "-DLLVM_TARGETS_TO_BUILD=ARM";
    cmake \
        --build build \
        --target clang-format \
        "-j$CPUS";
    cmake \
        --build build \
        --target clangd \
        "-j$CPUS";
    cmake \
        --install build \
        --strip \
        --component clang-format;
    cmake \
        --install build \
        --strip \
        --component clangd;

    # adding clangd headers
    cp -r "$LINUX_CONFIGURE_ROOT/llvm/build/lib/clang" "$LINUX_OUTPUT_ROOT/lib/";

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

function build_doxygen() {
    rm -rf "$LINUX_CONFIGURE_ROOT/doxygen";
    mkdir -p "$LINUX_CONFIGURE_ROOT/doxygen";
    pushd "$LINUX_CONFIGURE_ROOT/doxygen";
    cmake -S \
        /toolchain/src/src/doxygen \
        -B build \
        -DCMAKE_BUILD_TYPE=Release \
        -G "Unix Makefiles";

    cmake --build build --parallel $(nproc);
    mkdir -p "$LINUX_OUTPUT_ROOT/bin/"
    strip --strip-all "$LINUX_CONFIGURE_ROOT/doxygen/build/bin/doxygen" -o "$LINUX_OUTPUT_ROOT/bin/doxygen"

    popd;
}

build_doxygen;
build_protobuf;
build_llvm;
copy_libudev;
build_libusb;
build_hidapi;
build_openocd;
