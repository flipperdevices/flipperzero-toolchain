#!/bin/bash

set -euo pipefail;

WINDOWS_CONFIGURE_ROOT=/toolchain/windows-configure-root
WINDOWS_BUILD_ROOT=/toolchain/windows-build-root
WINDOWS_OUTPUT_ROOT=/toolchain/windows-output-root

CPUS="$(grep -c processor /proc/cpuinfo )";

function build_protobuf() {
    pushd /toolchain/src/src/protobuf;
    ./autogen.sh
    popd
    rm -rf "$WINDOWS_CONFIGURE_ROOT/protobuf";
    mkdir -p "$WINDOWS_CONFIGURE_ROOT/protobuf";
    pushd "$WINDOWS_CONFIGURE_ROOT/protobuf";
    CC="x86_64-w64-mingw32-gcc-posix" \
        CXX="x86_64-w64-mingw32-g++-posix" \
        LDFLAGS="-static-libgcc -static-libstdc++ -Wl,-Bstatic -lstdc++ -lpthread -s" \
        CXXFLAGS="-DNDEBUG" \
        /toolchain/src/src/protobuf/configure \
            "--prefix=$WINDOWS_OUTPUT_ROOT" \
            --host=x86_64-w64-mingw32 \
            --disable-shared \
            LDFLAGS="-static-libgcc -static-libstdc++ -Wl,-Bstatic -lstdc++ -lpthread -s" \
            CXXFLAGS="-DNDEBUG" \
            CC="x86_64-w64-mingw32-gcc-posix" \
            CXX="x86_64-w64-mingw32-g++-posix";
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
        -DCMAKE_C_COMPILER=x86_64-w64-mingw32-gcc-posix \
        -DCMAKE_CXX_COMPILER=x86_64-w64-mingw32-g++-posix \
	    -DCLANG_DEFAULT_RTLIB=compiler-rt \
	    -DCLANG_DEFAULT_UNWINDLIB=libunwind \
	    -DCLANG_DEFAULT_CXX_STDLIB=libc++ \
	    -DCLANG_DEFAULT_LINKER=lld \
	    -DCMAKE_EXE_LINKER_FLAGS="-static -static-libgcc -static-libstdc++ -Wl,-Bstatic -lstdc++ -lpthread -s" \
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

function cleanup() {
    find "$WINDOWS_OUTPUT_ROOT" \( -name "*.a" -or -name "*.la" \) -delete;
}

build_protobuf;
build_clang_format;
cleanup;
