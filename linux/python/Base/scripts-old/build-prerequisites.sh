#! /usr/bin/env bash
# Copyright (c) 2011-2020, ARM Limited
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
#     * Redistributions of source code must retain the above copyright notice,
#       this list of conditions and the following disclaimer.
#     * Redistributions in binary form must reproduce the above copyright
#       notice, this list of conditions and the following disclaimer in the
#       documentation and/or other materials provided with the distribution.
#     * Neither the name of Arm nor the names of its contributors may be used
#       to endorse or promote products derived from this software without
#       specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
# LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.

set -e
set -x
set -u
set -o pipefail

if [[ "$(uname)" != "Darwin" ]]; then
  PS4='+$(date +%Y-%m-%d:%H:%M:%S) (${BASH_SOURCE}:${LINENO}): ${FUNCNAME[0]:+${FUNCNAME[0]}(): }'
fi

umask 022

exec < /dev/null

script_path=`cd $(dirname $0) && pwd -P`
. $script_path/build-common.sh

# This file contains the sequence of commands used to build the prerequisites
# for GNU Tools Arm Embedded toolchain.
usage ()
{
cat<<EOF
Usage: $(basename $0) [--skip_steps=...]

This script will build dependent libraries for GNU Tools Arm Embedded toolchain.

OPTIONS:
  --skip_steps=STEPS    specify which build steps you want to skip.  Concatenate
                        them with comma for skipping more than one steps.
                        Available step is:
                            howto
                            md5_checksum
                            mingw[32]
                            native
                            package_sources

EOF
}

if [ $# -gt 2 ] ; then
    usage
fi

skip_steps=
skip_mingw32=no
skip_native_build=no

for ac_arg; do
    case $ac_arg in
        --skip_steps=*)
            skip_steps=`echo $ac_arg | sed -e "s/--skip_steps=//g" -e "s/,/ /g"`
            ;;
        --help|-h)
            usage
            exit 1
            ;;
        *)
            usage
            exit 1
        ;;
    esac
done

if [ "x$skip_steps" != "x" ]; then
    for ss in $skip_steps; do
        case $ss in
            mingw|mingw32)
                skip_mingw32=yes
                ;;
            native)
                skip_native_build=yes
                ;;
            howto | package_sources | md5_checksum | strip)
                ;;
            *)
                echo "Unknown build steps: $ss" 1>&2
                usage
                exit 1
                ;;
        esac
    done
fi

if [ "x$BUILD" == "xx86_64-apple-darwin10" ]; then
  skip_mingw32=yes
fi

if [ "x$skip_native_build" != "xyes" ] ; then
    rm -rf "$BUILDDIR_NATIVE"
    mkdir -p "$BUILDDIR_NATIVE"
    rm -rf "$INSTALLDIR_NATIVE"
    mkdir -p "$INSTALLDIR_NATIVE"
fi

if [ "x$skip_mingw32" != "xyes" ] ; then
    rm -rf "$BUILDDIR_MINGW"
    mkdir -p "$BUILDDIR_MINGW"
    rm -rf "$INSTALLDIR_MINGW"
    mkdir -p "$INSTALLDIR_MINGW"
fi

cd "$SRCDIR"

if [ "x$skip_native_build" != "xyes" ] ; then
    echo Task [I-0] /$HOST_NATIVE/zlib/ | tee -a "$BUILDDIR_NATIVE/.stage"
    rm -rf $BUILDDIR_NATIVE/zlib
    copy_dir_clean $SRCDIR/$ZLIB $BUILDDIR_NATIVE/zlib
    pushd $BUILDDIR_NATIVE/zlib
    #install zlib at .../host-libs/zlib, prevent gcc from linking into this external zlib
    ./configure --static --prefix=$BUILDDIR_NATIVE/host-libs/zlib
    make
    make install
    popd

    echo Task [I-1] /$HOST_NATIVE/gmp/ | tee -a "$BUILDDIR_NATIVE/.stage"
    rm -rf $BUILDDIR_NATIVE/gmp && mkdir -p $BUILDDIR_NATIVE/gmp
    pushd $BUILDDIR_NATIVE/gmp

    CPPFLAGS="-fexceptions" $SRCDIR/$GMP/configure --build=$BUILD \
        --host=$HOST_NATIVE \
        --prefix=$BUILDDIR_NATIVE/host-libs/usr \
        --enable-cxx \
        --disable-shared \
        --disable-nls

    make -j$JOBS
    make install
    #make check
    popd

    echo Task [I-2] /$HOST_NATIVE/mpfr/ | tee -a "$BUILDDIR_NATIVE/.stage"
    rm -rf $BUILDDIR_NATIVE/mpfr && mkdir -p $BUILDDIR_NATIVE/mpfr
    pushd $BUILDDIR_NATIVE/mpfr

    $SRCDIR/$MPFR/configure --build=$BUILD \
        --host=$HOST_NATIVE \
        --target=$TARGET \
        --prefix=$BUILDDIR_NATIVE/host-libs/usr \
        --disable-shared \
        --disable-nls \
        --with-gmp=$BUILDDIR_NATIVE/host-libs/usr

    make -j$JOBS
    make install
    #make check
    popd

    echo Task [I-3] /$HOST_NATIVE/mpc/ | tee -a "$BUILDDIR_NATIVE/.stage"
    rm -rf $BUILDDIR_NATIVE/mpc && mkdir -p $BUILDDIR_NATIVE/mpc
    pushd $BUILDDIR_NATIVE/mpc

    $SRCDIR/$MPC/configure --build=$BUILD \
        --host=$HOST_NATIVE \
        --target=$TARGET \
        --prefix=$BUILDDIR_NATIVE/host-libs/usr \
        --disable-shared \
        --disable-nls \
        --with-gmp=$BUILDDIR_NATIVE/host-libs/usr \
        --with-mpfr=$BUILDDIR_NATIVE/host-libs/usr

    make -j$JOBS
    make install
    #make check
    popd

    echo Task [I-4] /$HOST_NATIVE/isl/ | tee -a "$BUILDDIR_NATIVE/.stage"
    rm -rf $BUILDDIR_NATIVE/isl && mkdir -p $BUILDDIR_NATIVE/isl
    pushd $BUILDDIR_NATIVE/isl

    $SRCDIR/$ISL/configure --build=$BUILD \
        --host=$HOST_NATIVE \
        --target=$TARGET \
        --prefix=$BUILDDIR_NATIVE/host-libs/usr \
        --disable-shared \
        --disable-nls \
        --with-gmp-prefix=$BUILDDIR_NATIVE/host-libs/usr

    make
    make install
    #make check
    popd

    #echo Task [I-5] /$HOST_NATIVE/libelf/ | tee -a "$BUILDDIR_NATIVE/.stage"
    #rm -rf $BUILDDIR_NATIVE/libelf && mkdir -p $BUILDDIR_NATIVE/libelf
    #pushd $BUILDDIR_NATIVE/libelf

    #$SRCDIR/$LIBELF/configure --build=$BUILD \
    #    --host=$HOST_NATIVE \
    #    --target=$TARGET \
    #    --prefix=$BUILDDIR_NATIVE/host-libs/usr \
    #    --disable-shared \
    #    --disable-nls

    #make -j$JOBS
    #make install
    #make check
    #popd

    echo Task [I-6] /$HOST_NATIVE/libexpat/expat/ | tee -a "$BUILDDIR_NATIVE/.stage"
    rm -rf $BUILDDIR_NATIVE/expat && mkdir -p $BUILDDIR_NATIVE/expat
    pushd $BUILDDIR_NATIVE/expat

    $SRCDIR/libexpat/$EXPAT/configure --build=$BUILD \
        --host=$HOST_NATIVE \
        --target=$TARGET \
        --prefix=$BUILDDIR_NATIVE/host-libs/usr \
        --disable-shared \
        --disable-nls \
        --with-docbook

    make -j$JOBS
    make install
    popd

    echo Task [I-7] /$HOST_NATIVE/libffi/ | tee -a "$BUILDDIR_NATIVE/.stage"
    rm -rf $BUILDDIR_NATIVE/libffi && mkdir -p $BUILDDIR_NATIVE/libffi
    pushd $BUILDDIR_NATIVE/expat

    $SRCDIR/libexpat/$EXPAT/configure --build=$BUILD \
        --host=$HOST_NATIVE \
        --target=$TARGET \
        --prefix=$BUILDDIR_NATIVE/host-libs/usr \
        --disable-shared \
        --disable-nls \
        --with-docbook

    make -j$JOBS
    make install
    popd
fi  # if [ "x$skip_native_build" != "xyes" ] ; then

# skip building mingw32 toolchain if "--skip_mingw32" specified
if [ "x$skip_mingw32" == "xyes" ] ; then
    exit 0
fi

saveenv
saveenvvar CC_FOR_BUILD gcc
saveenvvar CC $HOST_MINGW_TOOL-gcc
saveenvvar CXX $HOST_MINGW_TOOL-g++
saveenvvar AR $HOST_MINGW_TOOL-ar
saveenvvar RANLIB $HOST_MINGW_TOOL-ranlib
saveenvvar STRIP $HOST_MINGW_TOOL-strip
saveenvvar NM $HOST_MINGW_TOOL-nm
saveenvvar AS $HOST_MINGW_TOOL-as
saveenvvar OBJDUMP $HOST_MINGW_TOOL-objdump
saveenvvar RC $HOST_MINGW_TOOL-windres
saveenvvar WINDRES $HOST_MINGW_TOOL-windres

echo Task [II-0] /$HOST_MINGW/zlib/ | tee -a "$BUILDDIR_MINGW/.stage"
rm -rf $BUILDDIR_MINGW/zlib
copy_dir_clean $SRCDIR/$ZLIB $BUILDDIR_MINGW/zlib
#saveenv
#saveenvvar AR "$HOST_MINGW_TOOL-ar"
pushd $BUILDDIR_MINGW/zlib
#install zlib at .../host-libs/zlib, prevent gcc from linking into this external zlib
./configure --static --prefix=$BUILDDIR_MINGW/host-libs/zlib
make
make install
popd
#restoreenv

echo Task [II-1] /$HOST_MINGW/libiconv/ | tee -a "$BUILDDIR_MINGW/.stage"
rm -rf $BUILDDIR_MINGW/libiconv && mkdir -p $BUILDDIR_MINGW/libiconv
pushd $BUILDDIR_MINGW/libiconv

$SRCDIR/$LIBICONV/configure --build=$BUILD \
    --host=$HOST_MINGW \
    --target=$TARGET \
    --prefix=$BUILDDIR_MINGW/host-libs/usr \
    --disable-shared \
    --disable-nls

make -j$JOBS
make install
popd

echo Task [II-2] /$HOST_MINGW/gmp/ | tee -a "$BUILDDIR_MINGW/.stage"
rm -rf $BUILDDIR_MINGW/gmp && mkdir -p $BUILDDIR_MINGW/gmp
pushd $BUILDDIR_MINGW/gmp

$SRCDIR/$GMP/configure --build=$BUILD \
    --host=$HOST_MINGW \
    --prefix=$BUILDDIR_MINGW/host-libs/usr \
    --disable-shared \
    --enable-cxx \
    --disable-nls

make -j$JOBS
make install
popd

echo Task [II-3] /$HOST_MINGW/mpfr/ | tee -a "$BUILDDIR_MINGW/.stage"
rm -rf $BUILDDIR_MINGW/mpfr && mkdir -p $BUILDDIR_MINGW/mpfr
pushd $BUILDDIR_MINGW/mpfr

$SRCDIR/$MPFR/configure --build=$BUILD \
    --host=$HOST_MINGW \
    --target=$TARGET \
    --prefix=$BUILDDIR_MINGW/host-libs/usr \
    --disable-shared \
    --disable-nls \
    --with-gmp=$BUILDDIR_MINGW/host-libs/usr

make -j$JOBS
make install
popd

echo Task [II-4] /$HOST_MINGW/mpc/ | tee -a "$BUILDDIR_MINGW/.stage"
rm -rf $BUILDDIR_MINGW/mpc && mkdir -p $BUILDDIR_MINGW/mpc
pushd $BUILDDIR_MINGW/mpc

$SRCDIR/$MPC/configure --build=$BUILD \
    --host=$HOST_MINGW \
    --target=$TARGET \
    --prefix=$BUILDDIR_MINGW/host-libs/usr \
    --disable-shared \
    --disable-nls \
    --with-gmp=$BUILDDIR_MINGW/host-libs/usr \
    --with-mpfr=$BUILDDIR_MINGW/host-libs/usr

make -j$JOBS
make install
popd

echo Task [II-5] /$HOST_MINGW/isl/ | tee -a "$BUILDDIR_MINGW/.stage"
rm -rf $BUILDDIR_MINGW/isl && mkdir -p $BUILDDIR_MINGW/isl
pushd $BUILDDIR_MINGW/isl

$SRCDIR/$ISL/configure --build=$BUILD \
    --host=$HOST_MINGW \
    --target=$TARGET \
    --prefix=$BUILDDIR_MINGW/host-libs/usr  \
    --disable-shared \
    --disable-nls \
    --with-gmp-prefix=$BUILDDIR_MINGW/host-libs/usr

make
make install
popd

#sed -i 's/ac_exeext=$/ac_exeext=.exe/g' "$SRCDIR/$LIBELF/configure"

#echo Task [II-6] /$HOST_MINGW/libelf/ | tee -a "$BUILDDIR_MINGW/.stage"
#rm -rf $BUILDDIR_MINGW/libelf && mkdir -p $BUILDDIR_MINGW/libelf
#pushd $BUILDDIR_MINGW/libelf

#$SRCDIR/$LIBELF/configure --build=$BUILD \
#    --host=$HOST_MINGW \
#    --target=$TARGET \
#    --prefix=$BUILDDIR_MINGW/host-libs/usr \
#    --disable-shared \
#    --disable-nls

#make -j$JOBS
#make install
#popd

echo Task [II-7] /$HOST_MINGW/libexpat/expat/ | tee -a "$BUILDDIR_MINGW/.stage"
rm -rf $BUILDDIR_MINGW/expat && mkdir -p $BUILDDIR_MINGW/expat
pushd $BUILDDIR_MINGW/expat

$SRCDIR/libexpat/$EXPAT/configure --build=$BUILD \
    --host=$HOST_MINGW \
    --target=$TARGET \
    --prefix=$BUILDDIR_MINGW/host-libs/usr \
    --disable-shared \
    --disable-nls \
    --with-docbook

make -j$JOBS
make install
popd
restoreenv

