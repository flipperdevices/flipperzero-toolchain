#!/bin/bash

set -euo pipefail;

. /toolchain/src/buildvars.sh

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

function build_llvm() {
    rm -rf "$WINDOWS_CONFIGURE_ROOT/llvm";
    mkdir -p "$WINDOWS_CONFIGURE_ROOT/llvm";
    pushd "$WINDOWS_CONFIGURE_ROOT/llvm";
    cmake -S \
        /toolchain/src/src/llvm/llvm-18.1.8.src \
        -B build \
        -DLLVM_INCLUDE_BENCHMARKS=OFF \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX="$WINDOWS_OUTPUT_ROOT" \
        "-DLLVM_EXTERNAL_PROJECTS=clang;clang-tools-extra" \
        "-DLLVM_TARGETS_TO_BUILD=ARM" \
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
    cp -r "$WINDOWS_CONFIGURE_ROOT/llvm/build/lib/clang" "$WINDOWS_OUTPUT_ROOT/lib/";
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

function build_doxygen() {
    rm -rf "$WINDOWS_CONFIGURE_ROOT/doxygen";
    mkdir -p "$WINDOWS_CONFIGURE_ROOT/doxygen";
    pushd "$WINDOWS_CONFIGURE_ROOT/doxygen";

    rm -rf /toolchain/src/src/doxygen/deps/iconv_winbuild/*
    find /toolchain/src/src/libiconv_winbuild \( -wholename "*x64/Release/*" -o -wholename "*.h" \) -type f -exec cp -f "{}" /toolchain/src/src/doxygen/deps/iconv_winbuild/ \;

    cmake \
        -S /toolchain/src/src/doxygen \
        -DCMAKE_SYSTEM_NAME=Windows \
        -DCMAKE_RC_COMPILER=x86_64-w64-mingw32-windres \
        -DCMAKE_C_COMPILER=x86_64-w64-mingw32-gcc \
        -DCMAKE_CXX_COMPILER=x86_64-w64-mingw32-g++ \
        -DCMAKE_PREFIX_PATH="/toolchain/src/src/doxygen/deps/iconv_winbuild" \
        -B build \
        -G "Unix Makefiles" \
        -DCMAKE_BUILD_TYPE=Release;

    cmake --build build --parallel $(nproc);
    mkdir -p "$WINDOWS_OUTPUT_ROOT/bin/"
    cp "$WINDOWS_CONFIGURE_ROOT/doxygen/build/bin/doxygen.exe" "$WINDOWS_OUTPUT_ROOT/bin/"
    cp /toolchain/src/src/doxygen/deps/iconv_winbuild/libiconv.dll "$WINDOWS_OUTPUT_ROOT/bin/"

    popd;
}


function cleanup() {
    find "$WINDOWS_OUTPUT_ROOT" \( -name "*.a" -or -name "*.la" \) -delete;
}




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
        build_libusb
        ;;
    "libhidapi")
        build_hidapi
        ;;
    "openocd")
        build_openocd
        ;;
    "cleanup")
        cleanup
        ;;
    *)
        die "$0: wrong build module ${CMD}"
        ;;
esac

