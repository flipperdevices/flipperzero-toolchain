#!/bin/bash

set -euo pipefail;

WINDOWS_CONFIGURE_ROOT=/toolchain/windows-configure-root
WINDOWS_BUILD_ROOT=/toolchain/windows-build-root
WINDOWS_OUTPUT_ROOT=/toolchain/windows-output-root

CPUS="$(grep -c processor /proc/cpuinfo )";

export PKG_CONFIG_PATH="$WINDOWS_OUTPUT_ROOT/lib/pkgconfig";

function build_protobuf() {
    pushd /toolchain/src/src/protobuf;
    ./autogen.sh
    popd
    rm -rf "$WINDOWS_CONFIGURE_ROOT/protobuf";
    mkdir -p "$WINDOWS_CONFIGURE_ROOT/protobuf";
    pushd "$WINDOWS_CONFIGURE_ROOT/protobuf";
    LDFLAGS="-Wl,-Bstatic,-lstdc++,-lpthread,-Bdynamic -s" \
        CXXFLAGS="-DNDEBUG" \
        /toolchain/src/src/protobuf/configure \
            "--prefix=$WINDOWS_OUTPUT_ROOT" \
            --host=x86_64-w64-mingw32 \
            --disable-shared \
            LDFLAGS="-Wl,-Bstatic,-lstdc++,-lpthread,-Bdynamic -s" \
            CXXFLAGS="-DNDEBUG";
    make "-j$CPUS";
    make install;
    popd;
}

function build_clang_format() {
    rm -rf "$WINDOWS_CONFIGURE_ROOT/clang-format";
    mkdir -p "$WINDOWS_CONFIGURE_ROOT/clang-format";
    pushd "$WINDOWS_CONFIGURE_ROOT/clang-format";
    cmake -S \
        /toolchain/src/src/clang-format/llvm-17.0.6.src \
        -B build \
        -DLLVM_INCLUDE_BENCHMARKS=OFF \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX="$WINDOWS_OUTPUT_ROOT" \
        -DLLVM_EXTERNAL_PROJECTS=clang \
        -DCMAKE_SYSTEM_NAME=Windows \
        -DCMAKE_RC_COMPILER=x86_64-w64-mingw32-windres \
        -DCMAKE_C_COMPILER=x86_64-w64-mingw32-gcc \
        -DCMAKE_CXX_COMPILER=x86_64-w64-mingw32-g++ \
	    -DCLANG_DEFAULT_RTLIB=compiler-rt \
	    -DCLANG_DEFAULT_UNWINDLIB=libunwind \
	    -DCLANG_DEFAULT_CXX_STDLIB=libc++ \
	    -DCLANG_DEFAULT_LINKER=lld \
	    -DCMAKE_EXE_LINKER_FLAGS="-static -Wl,-Bstatic,-lstdc++,-lpthread,-Bdynamic -s" \
	    -DCMAKE_CXX_FLAGS="-static";
    cmake \
        --build build \
        --target clang-format \
        "-j$CPUS";
    cmake \
        --install build \
        --strip \
        --component clang-format;
}

function build_libusb() {
    rm -rf "$WINDOWS_CONFIGURE_ROOT/libusb";
    mkdir -p "$WINDOWS_CONFIGURE_ROOT/libusb";
    pushd "$WINDOWS_CONFIGURE_ROOT/libusb";
    LDFLAGS="-Wl,-Bstatic,-lstdc++,-lpthread,-Bdynamic -s" \
        /toolchain/src/src/libusb/configure \
            "--host=x86_64-w64-mingw32" \
            "--target=x86_64-w64-mingw32" \
            "--prefix=$WINDOWS_OUTPUT_ROOT";
    LDFLAGS="-Wl,-Bstatic,-lstdc++,-lpthread,-Bdynamic -s" \
        make "-j$CPUS";
    make install;
    popd;
}

function build_hidapi() {
    rm -rf "$WINDOWS_CONFIGURE_ROOT/hidapi";
    mkdir -p "$WINDOWS_CONFIGURE_ROOT/hidapi";
    pushd "$WINDOWS_CONFIGURE_ROOT/hidapi";
    cmake \
        -S "/toolchain/src/src/hidapi" \
        -DCMAKE_SYSTEM_NAME=Windows \
        -DCMAKE_RC_COMPILER=x86_64-w64-mingw32-windres \
        -DCMAKE_C_COMPILER=x86_64-w64-mingw32-gcc \
        -DCMAKE_CXX_COMPILER=x86_64-w64-mingw32-g++ \
	    -DCLANG_DEFAULT_RTLIB=compiler-rt \
	    -DCLANG_DEFAULT_UNWINDLIB=libunwind \
	    -DCLANG_DEFAULT_CXX_STDLIB=libc++ \
	    -DCLANG_DEFAULT_LINKER=lld \
	    -DCMAKE_CXX_FLAGS="-static" \
        "-DCMAKE_INSTALL_PREFIX=$WINDOWS_OUTPUT_ROOT";
    make "-j$CPUS";
    make install;
    popd;
}

function build_openocd() {
    rm -rf "$WINDOWS_CONFIGURE_ROOT/openocd";
    mkdir -p "$WINDOWS_CONFIGURE_ROOT/openocd";
    pushd "/toolchain/src/src/openocd";
    ./bootstrap;
    popd;
    pushd "$WINDOWS_CONFIGURE_ROOT/openocd";
    LDFLAGS="-L$WINDOWS_OUTPUT_ROOT/lib" CPPFLAGS="-I$WINDOWS_OUTPUT_ROOT/include -D__USE_MINGW_ANSI_STDIO=1" LD_LIBRARY_PATH="$WINDOWS_OUTPUT_ROOT/lib" \
        /toolchain/src/src/openocd/configure \
            "--prefix=$WINDOWS_OUTPUT_ROOT" \
            "--host=x86_64-w64-mingw32" \
            "--target=x86_64-w64-mingw32" \
            "--datarootdir=$WINDOWS_OUTPUT_ROOT" \
            "--localedir=$WINDOWS_OUTPUT_ROOT/share/locale" \
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
            "--enable-gw16012" \
            "--enable-parport" \
            "--disable-sysfsgpio" \
            "--disable-buspirate" \
            "--disable-oocd_trace" \
            "--enable-parport-giveio";
    LDFLAGS="-L$WINDOWS_OUTPUT_ROOT/lib" CPPFLAGS="-I$WINDOWS_OUTPUT_ROOT/include -D__USE_MINGW_ANSI_STDIO=1" LD_LIBRARY_PATH="$WINDOWS_OUTPUT_ROOT/lib" \
        make "-j$CPUS";
    make install-strip;
    popd;
}

function cleanup() {
    find "$WINDOWS_OUTPUT_ROOT" \( -name "*.a" -or -name "*.la" \) -delete;
}

build_protobuf;
build_clang_format;
build_libusb;
build_hidapi;
build_openocd;
cleanup;
