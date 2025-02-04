#!/bin/bash

set -euo pipefail;

. /toolchain/src/buildvars.sh


BUILD="${ARCH_BUILD}-linux-gnu";
HOST="x86_64-w64-mingw32";

# Copy target libraries from each multilib directories.
# Usage copy_multi_libs dst_prefix=... src_prefix=... target_gcc=...
copy_multi_libs() {
    local -a multilibs
    local multilib
    local multi_dir
    local src_prefix
    local dst_prefix
    local src_dir
    local dst_dir
    local target_gcc

    for arg in "$@" ; do
        eval "${arg// /\\ }"
    done

    multilibs=( $("${target_gcc}" -print-multi-lib 2>/dev/null) )
    for multilib in "${multilibs[@]}" ; do
        multi_dir="${multilib%%;*}"
        src_dir=${src_prefix}/${multi_dir}
        dst_dir=${dst_prefix}/${multi_dir}

        mkdir -p "${dst_dir}"

        cp -f "${src_dir}/libstdc++.a" "${dst_dir}/libstdc++_nano.a"
        cp -f "${src_dir}/libsupc++.a" "${dst_dir}/libsupc++_nano.a"
        cp -f "${src_dir}/libc.a" "${dst_dir}/libc_nano.a"
        cp -f "${src_dir}/libg.a" "${dst_dir}/libg_nano.a"
        cp -f "${src_dir}/librdimon.a" "${dst_dir}/librdimon_nano.a"
        cp -f "${src_dir}/nano.specs" "${dst_dir}/"
        cp -f "${src_dir}/rdimon.specs" "${dst_dir}/"
        cp -f "${src_dir}/nosys.specs" "${dst_dir}/"
        cp -f "${src_dir}/"*crt0.o "${dst_dir}/"
    done
}

function build_gmp() {
    rm -rf "$WINDOWS_CONFIGURE_ROOT/gmp";
    mkdir -p "$WINDOWS_CONFIGURE_ROOT/gmp";
    pushd "$WINDOWS_CONFIGURE_ROOT/gmp";
    /toolchain/src/src/gmp/configure \
        --enable-static \
        --disable-shared \
        --disable-maintainer-mode \
        --prefix="$WINDOWS_BUILD_ROOT" \
        --host=x86_64-w64-mingw32;
    make "-j$CPUS";
    make install;
    popd;
}

function build_mpfr() {
    rm -rf "$WINDOWS_CONFIGURE_ROOT/mpfr";
    mkdir -p "$WINDOWS_CONFIGURE_ROOT/mpfr";
    pushd "$WINDOWS_CONFIGURE_ROOT/mpfr";
    /toolchain/src/src/mpfr/configure \
        --enable-static \
        --disable-shared \
        --disable-maintainer-mode \
        --prefix="$WINDOWS_BUILD_ROOT" \
        --with-gmp="$WINDOWS_BUILD_ROOT" \
        --host=x86_64-w64-mingw32;
    make "-j$CPUS";
    make install;
    popd;
}

function build_mpc() {
    rm -rf "$WINDOWS_CONFIGURE_ROOT/mpc";
    mkdir -p "$WINDOWS_CONFIGURE_ROOT/mpc";
    pushd "$WINDOWS_CONFIGURE_ROOT/mpc";
    /toolchain/src/src/mpc/configure \
        --enable-static \
        --disable-shared \
        --disable-maintainer-mode \
        --prefix="$WINDOWS_BUILD_ROOT" \
        --with-gmp="$WINDOWS_BUILD_ROOT" \
        --with-mpfr="$WINDOWS_BUILD_ROOT" \
        --host=x86_64-w64-mingw32;
    make "-j$CPUS";
    make install;
    popd;
}

function build_isl() {
    rm -rf "$WINDOWS_CONFIGURE_ROOT/isl";
    mkdir -p "$WINDOWS_CONFIGURE_ROOT/isl";
    pushd "$WINDOWS_CONFIGURE_ROOT/isl";
    /toolchain/src/src/isl/configure \
        --enable-static \
        --disable-shared \
        --prefix="$WINDOWS_BUILD_ROOT" \
        --with-gmp-prefix="$WINDOWS_BUILD_ROOT" \
        --host=x86_64-w64-mingw32;
    make "-j$CPUS";
    make install;
    popd;
}

function build_libexpat() {
    rm -rf "$WINDOWS_CONFIGURE_ROOT/libexpat";
    mkdir -p "$WINDOWS_CONFIGURE_ROOT/libexpat";
    pushd "$WINDOWS_CONFIGURE_ROOT/libexpat";
    /toolchain/src/src/libexpat/expat/configure \
        --enable-static \
        --disable-shared \
        --prefix="$WINDOWS_BUILD_ROOT" \
        --host=x86_64-w64-mingw32 \
        --without-docbook \
        --disable-nls \
        --without-xmlwf;
    make "-j$CPUS";
    make install;
    popd;
}


function build_gcc_newlib() {
    rm -rf "$WINDOWS_CONFIGURE_ROOT/newlib";
    rm -rf "$NEWLIB_ROOT";
    mkdir -p "$WINDOWS_CONFIGURE_ROOT/newlib";
    pushd "$WINDOWS_CONFIGURE_ROOT/newlib";
    CFLAGS_FOR_TARGET="-g -Os -ffunction-sections -fdata-sections" /toolchain/src/src/newlib-cygwin/configure \
        "--prefix=$NEWLIB_ROOT" \
        --target=arm-none-eabi \
        --disable-newlib-supplied-syscalls \
        --enable-newlib-retargetable-locking \
        --enable-newlib-reent-check-verify \
        --enable-newlib-io-long-long \
        --enable-newlib-io-c99-formats \
        --enable-newlib-register-fini \
        --enable-newlib-mb;
    make "-j$CPUS";
    make install;
    popd;
}

function copy_newlib() {
    rsync -av "$NEWLIB_ROOT/" "$WINDOWS_OUTPUT_ROOT";
}


function build_linux_gcc() {
    rm -rf "$WINDOWS_CONFIGURE_ROOT/gcc";
    mkdir -p "$WINDOWS_CONFIGURE_ROOT/gcc";
    pushd "$WINDOWS_CONFIGURE_ROOT/gcc";
    LDFLAGS="-L$WINDOWS_BUILD_ROOT/lib -L$WINDOWS_OUTPUT_ROOT/lib" CPPFLAGS="-I$WINDOWS_BUILD_ROOT/include -I$WINDOWS_OUTPUT_ROOT/include -I$WINDOWS_OUTPUT_ROOT/include/readline" "/toolchain/src/src/arm-gnu-toolchain-src-snapshot-12.3.rel1/configure" \
        "--prefix=$WINDOWS_OUTPUT_ROOT" \
        --target=arm-none-eabi \
        --host=x86_64-w64-mingw32 \
        --with-mpfr=$WINDOWS_BUILD_ROOT \
        --with-gmp=$WINDOWS_BUILD_ROOT \
        --with-mpc=$WINDOWS_BUILD_ROOT \
        --with-isl=$WINDOWS_BUILD_ROOT \
        --disable-shared \
        --disable-nls \
        --disable-threads \
        --disable-tls \
        --enable-checking=release \
        --enable-languages=c,c++ \
        --enable-lto \
        --with-newlib \
        --with-gnu-as \
        --with-gnu-ld \
        "--with-sysroot=$WINDOWS_OUTPUT_ROOT/arm-none-eabi" \
        --with-multilib-list=rmprofile \
        "--with-host-libstdcxx=-static-libgcc -Wl,-Bstatic,-lstdc++,-Bdynamic -lm" \
        LDFLAGS="-L$WINDOWS_BUILD_ROOT/lib -L$WINDOWS_OUTPUT_ROOT/lib" \
        CPPFLAGS="-I$WINDOWS_BUILD_ROOT/include -I$WINDOWS_OUTPUT_ROOT/include -I$WINDOWS_OUTPUT_ROOT/include/readline";
    LDFLAGS="-L$WINDOWS_BUILD_ROOT/lib -L$WINDOWS_OUTPUT_ROOT/lib" CPPFLAGS="-I$WINDOWS_BUILD_ROOT/include -I$WINDOWS_OUTPUT_ROOT/include -I$WINDOWS_OUTPUT_ROOT/include/readline" make "-j$CPUS" CXXFLAGS="-g -O2";
    LDFLAGS="-L$WINDOWS_BUILD_ROOT/lib -L$WINDOWS_OUTPUT_ROOT/lib" CPPFLAGS="-I$WINDOWS_BUILD_ROOT/include -I$WINDOWS_OUTPUT_ROOT/include -I$WINDOWS_OUTPUT_ROOT/include/readline" make install;
    popd;
}


function build_gcc_newlib_nano() {
    rm -rf "$WINDOWS_CONFIGURE_ROOT/newlib-nano";
    rm -rf "$NEWLIB_NANO_ROOT";
    mkdir -p "$WINDOWS_CONFIGURE_ROOT/newlib-nano";
    pushd "$WINDOWS_CONFIGURE_ROOT/newlib-nano";
    CFLAGS_FOR_TARGET="-g -Os -ffunction-sections -fdata-sections" /toolchain/src/src/newlib-cygwin/configure \
        "--prefix=$NEWLIB_NANO_ROOT" \
        --target=arm-none-eabi \
        --disable-newlib-supplied-syscalls \
        --enable-newlib-retargetable-locking \
        --enable-newlib-reent-check-verify \
        --enable-newlib-nano-malloc \
        --disable-newlib-unbuf-stream-opt \
        --enable-newlib-reent-small \
        --disable-newlib-fseek-optimization \
        --enable-newlib-nano-formatted-io \
        --disable-newlib-fvwrite-in-streamio \
        --disable-newlib-wide-orient \
        --enable-lite-exit \
        --enable-newlib-global-atexit
    make "-j$CPUS";
    make install;
    popd;
}


function build_linux_gcc_nano() {
    rm -rf "$WINDOWS_CONFIGURE_ROOT/gcc-nano";
    mkdir -p "$WINDOWS_CONFIGURE_ROOT/gcc-nano";
    pushd "$WINDOWS_CONFIGURE_ROOT/gcc-nano";
    LDFLAGS="-L$WINDOWS_BUILD_ROOT/lib -L$WINDOWS_OUTPUT_ROOT/lib" CPPFLAGS="-I$WINDOWS_BUILD_ROOT/include -I$WINDOWS_OUTPUT_ROOT/include -I$WINDOWS_OUTPUT_ROOT/include/readline" "/toolchain/src/src/arm-gnu-toolchain-src-snapshot-12.3.rel1/configure" \
        "--prefix=$NEWLIB_NANO_ROOT" \
        "--with-sysroot=$NEWLIB_NANO_ROOT/arm-none-eabi" \
        --target=arm-none-eabi \
        "--disable-libssp" \
        "--build=$BUILD" \
        --host=$HOST \
        --with-mpfr=$WINDOWS_BUILD_ROOT \
        --with-gmp=$WINDOWS_BUILD_ROOT \
        --with-mpc=$WINDOWS_BUILD_ROOT \
        --with-isl=$WINDOWS_BUILD_ROOT \
        --disable-shared \
        --disable-nls \
        --disable-threads \
        --disable-tls \
        --enable-checking=release \
        --enable-languages=c,c++ \
        --enable-lto \
        --with-newlib \
        --with-gnu-as \
        --with-gnu-ld \
        --with-multilib-list=rmprofile \
        LDFLAGS="-L$WINDOWS_BUILD_ROOT/lib -L$WINDOWS_OUTPUT_ROOT/lib" \
        CPPFLAGS="-I$WINDOWS_BUILD_ROOT/include -I$WINDOWS_OUTPUT_ROOT/include -I$WINDOWS_OUTPUT_ROOT/include/readline";
    LDFLAGS="-L$WINDOWS_BUILD_ROOT/lib -L$WINDOWS_OUTPUT_ROOT/lib" CPPFLAGS="-I$WINDOWS_BUILD_ROOT/include -I$WINDOWS_OUTPUT_ROOT/include -I$WINDOWS_OUTPUT_ROOT/include/readline" make "-j$CPUS" CXXFLAGS_FOR_TARGET="-g -Os -ffunction-sections -fdata-sections -fno-exceptions" CXXFLAGS="-g -O2";
    LDFLAGS="-L$WINDOWS_BUILD_ROOT/lib -L$WINDOWS_OUTPUT_ROOT/lib" CPPFLAGS="-I$WINDOWS_BUILD_ROOT/include -I$WINDOWS_OUTPUT_ROOT/include -I$WINDOWS_OUTPUT_ROOT/include/readline" make install;
    popd;
}


case "${CMD}" in
    gcc-libs)
        build_gmp;
        build_mpfr;
        build_mpc;
        build_isl;
        build_libexpat;
        ;;
    gcc)
        build_gcc_newlib 
        copy_newlib
        build_linux_gcc
        ;;
    gcc-nano)
        build_gcc_newlib_nano
        build_linux_gcc_nano
        ;;
    copy-libs)
        copy_multi_libs src_prefix="$NEWLIB_NANO_ROOT/arm-none-eabi/lib" \
            dst_prefix="$WINDOWS_OUTPUT_ROOT/arm-none-eabi/lib" \
            target_gcc="/usr/bin/arm-none-eabi-gcc";

        mkdir -p "$WINDOWS_OUTPUT_ROOT/arm-none-eabi/include/newlib-nano";
        mv "$NEWLIB_NANO_ROOT/arm-none-eabi/include/newlib.h" \
            "$WINDOWS_OUTPUT_ROOT/arm-none-eabi/include/newlib-nano/newlib.h";
        ;;

    *)
        die "$0: error build target ${CMD}"
        ;;
esac
