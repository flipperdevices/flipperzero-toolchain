#!/bin/bash

set -euo pipefail;

. /toolchain/src/buildvars.sh

export PKG_CONFIG_PATH="$LINUX_OUTPUT_ROOT/lib/pkgconfig";

function copy_libudev() {
    mkdir -p "$LINUX_OUTPUT_ROOT/lib";
    cp -r /usr/lib/${ARCH_BUILD}-linux-gnu/libudev.so.1* "$LINUX_OUTPUT_ROOT/lib/";
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
            "--host=${ARCH_TARGET}-linux-gnu" \
            "--target=${ARCH_TARGET}-linux-gnu" \
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



copy_libudev

case "${CMD}" in
    "protobuf")
        build_protobuf
        ;;
    "llvm")
        build_llvm
        ;;
    "doxygen")
        build_doxygen
        ;;
    "libusb")
        build_libusb;
        ;;
    "libhidapi")
        build_hidapi;
        ;;
    "openocd")
        build_openocd;
        ;;
    *)
        die "$0: wrong build module ${CMD}"
        ;;
esac

cleanup_relink "$LINUX_OUTPUT_ROOT";
