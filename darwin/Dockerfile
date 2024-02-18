FROM MacOSVenturaWithBrew AS flipperzero-toolchain-binutils
RUN brew update-reset
RUN brew install gettext texinfo coreutils bison flex m4 xz || true
RUN brew link bison --force
ADD https://developer.arm.com/-/media/Files/downloads/gnu/12.3.rel1/srcrel/arm-gnu-toolchain-src-snapshot-12.3.rel1.tar.xz /toolchain/src/src/archives/
RUN tar -xvf /toolchain/src/src/archives/arm-gnu-toolchain-src-snapshot-12.3.rel1.tar.xz -C /toolchain/src/src/
ADD scripts/build-mac-build-libs.sh /toolchain/src/
RUN bash /toolchain/src/build-mac-build-libs.sh
ADD scripts/build-mac-binutils.sh /toolchain/src/
RUN bash /toolchain/src/build-mac-binutils.sh

FROM MacOSVenturaWithBrew AS flipperzero-toolchain-python
RUN brew install coreutils
ADD https://www.python.org/ftp/python/3.11.2/Python-3.11.2.tgz /toolchain/src/src/archives/
RUN tar -xvf /toolchain/src/src/archives/Python-3.11.2.tgz -C /toolchain/src/src/
RUN mv /toolchain/src/src/Python-3.11.2 /toolchain/src/src/python
ADD https://www.openssl.org/source/openssl-1.1.1w.tar.gz /toolchain/src/src/archives/
RUN tar -xvf /toolchain/src/src/archives/openssl-1.1.1w.tar.gz -C /toolchain/src/src/
RUN mv /toolchain/src/src/openssl-1.1.1w /toolchain/src/src/openssl
ADD scripts/build-mac-python-libs.sh /toolchain/src/
ADD scripts/build-mac-python.sh /toolchain/src/
ADD scripts/relink.sh /usr/bin
RUN bash /toolchain/src/build-mac-python-libs.sh
RUN bash /toolchain/src/build-mac-python.sh
RUN relink.sh /toolchain/mac-x86_64-output-root
RUN relink.sh /toolchain/mac-arm64-output-root

FROM flipperzero-toolchain-binutils AS flipperzero-toolchain-gdb
ADD https://ftp.gnu.org/gnu/gdb/gdb-13.2.tar.gz /toolchain/src/src/archives
RUN tar -xvf /toolchain/src/src/archives/gdb-13.2.tar.gz -C /toolchain/src/src/
COPY --from=flipperzero-toolchain-python /toolchain/mac-x86_64-output-root /toolchain/mac-x86_64-output-root
COPY --from=flipperzero-toolchain-python /toolchain/mac-arm64-output-root /toolchain/mac-arm64-output-root
ADD scripts/build-mac-gdb.sh /toolchain/src/
ADD scripts/python3-config-x86_64.sh /toolchain/src/
ADD scripts/python3-config-arm64.sh /toolchain/src/
ADD scripts/relink.sh /usr/bin
RUN bash /toolchain/src/build-mac-gdb.sh
RUN relink.sh /toolchain/mac-x86_64-output-root
RUN relink.sh /toolchain/mac-arm64-output-root

FROM flipperzero-toolchain-binutils AS flipperzero-toolchain-gcc-first
ADD scripts/build-mac-gcc-first.sh /toolchain/src/
RUN bash /toolchain/src/build-mac-gcc-first.sh

FROM flipperzero-toolchain-gcc-first AS flipperzero-toolchain-newlib
ADD scripts/build-mac-newlib.sh /toolchain/src/
RUN bash /toolchain/src/build-mac-newlib.sh

FROM flipperzero-toolchain-newlib AS flipperzero-toolchain-gcc
ADD scripts/build-mac-gcc.sh /toolchain/src/
ADD scripts/move_newlib_to_nano.sh /toolchain/src/
RUN bash /toolchain/src/build-mac-gcc.sh
RUN bash /toolchain/src/move_newlib_to_nano.sh

FROM flipperzero-toolchain-binutils AS flipperzero-toolchain-tools
RUN brew install cmake automake autoconf
ADD https://github.com/protocolbuffers/protobuf/releases/download/v21.7/protobuf-cpp-3.21.7.tar.gz /toolchain/src/src/archives/
RUN tar -xvf /toolchain/src/src/archives/protobuf-cpp-3.21.7.tar.gz -C /toolchain/src/src/
RUN mv /toolchain/src/src/protobuf-3.21.7 /toolchain/src/src/protobuf
ADD https://github.com/llvm/llvm-project/releases/download/llvmorg-17.0.6/llvm-17.0.6.src.tar.xz /toolchain/src/src/archives/
RUN mkdir -p /toolchain/src/src/clang-format
RUN tar -xvf /toolchain/src/src/archives/llvm-17.0.6.src.tar.xz -C /toolchain/src/src/clang-format
ADD https://github.com/llvm/llvm-project/releases/download/llvmorg-17.0.6/clang-17.0.6.src.tar.xz /toolchain/src/src/archives/
RUN tar -xvf /toolchain/src/src/archives/clang-17.0.6.src.tar.xz -C /toolchain/src/src/clang-format/llvm-17.0.6.src/tools/
RUN mv /toolchain/src/src/clang-format/llvm-17.0.6.src/tools/clang-17.0.6.src /toolchain/src/src/clang-format/llvm-17.0.6.src/tools/clang
ADD https://github.com/llvm/llvm-project/releases/download/llvmorg-17.0.6/cmake-17.0.6.src.tar.xz /toolchain/src/src/archives/
RUN tar -xvf /toolchain/src/src/archives/cmake-17.0.6.src.tar.xz -C /toolchain/src/src/clang-format/
RUN mv /toolchain/src/src/clang-format/cmake-17.0.6.src /toolchain/src/src/clang-format/cmake
ADD https://github.com/llvm/llvm-project/releases/download/llvmorg-17.0.6/third-party-17.0.6.src.tar.xz /toolchain/src/src/archives/
RUN tar -xvf /toolchain/src/src/archives/third-party-17.0.6.src.tar.xz -C /toolchain/src/src/clang-format/
RUN mv /toolchain/src/src/clang-format/third-party-17.0.6.src /toolchain/src/src/clang-format/third-party
ADD scripts/build-mac-flipper-tools.sh /toolchain/src/
RUN bash /toolchain/src/build-mac-flipper-tools.sh
ADD https://github.com/xpack-dev-tools/openocd-xpack/releases/download/v0.12.0-2/xpack-openocd-0.12.0-2-darwin-arm64.tar.gz /toolchain/src/src/archives/
ADD https://github.com/xpack-dev-tools/openocd-xpack/releases/download/v0.12.0-2/xpack-openocd-0.12.0-2-darwin-x64.tar.gz /toolchain/src/src/archives/
RUN tar -xvf /toolchain/src/src/archives/xpack-openocd-0.12.0-2-darwin-arm64.tar.gz -C /toolchain/src/src/
RUN mv /toolchain/src/src/xpack-openocd-0.12.0-2 /toolchain/src/src/xpack-openocd-0.12.0-2-arm64
RUN tar -xvf /toolchain/src/src/archives/xpack-openocd-0.12.0-2-darwin-x64.tar.gz -C /toolchain/src/src/
RUN mv /toolchain/src/src/xpack-openocd-0.12.0-2 /toolchain/src/src/xpack-openocd-0.12.0-2-x86_64
RUN rm -rf /toolchain/src/src/xpack-openocd-0.12.0-2-arm64/distro-info
RUN rm -rf /toolchain/src/src/xpack-openocd-0.12.0-2-x86_64/distro-info
RUN rm -rf /toolchain/src/src/xpack-openocd-0.12.0-2-arm64/README.md
RUN rm -rf /toolchain/src/src/xpack-openocd-0.12.0-2-x86_64/README.md
RUN rsync -av /toolchain/src/src/xpack-openocd-0.12.0-2-arm64/ /toolchain/mac-arm64-output-root
RUN rsync -av /toolchain/src/src/xpack-openocd-0.12.0-2-x86_64/ /toolchain/mac-x86_64-output-root
ADD scripts/relink.sh /usr/bin/
RUN relink.sh /toolchain/mac-x86_64-output-root
RUN relink.sh /toolchain/mac-arm64-output-root

FROM MacOSVenturaWithBrew AS flipperzero-toolchain-mac
RUN brew install coreutils bison
RUN brew link bison --force
COPY --from=flipperzero-toolchain-gdb /toolchain/mac-x86_64-output-root /toolchain/mac-x86_64-output-root
COPY --from=flipperzero-toolchain-gdb /toolchain/mac-arm64-output-root /toolchain/mac-arm64-output-root
COPY --from=flipperzero-toolchain-gcc /toolchain/mac-x86_64-output-root /toolchain/mac-x86_64-output-root
COPY --from=flipperzero-toolchain-gcc /toolchain/mac-arm64-output-root /toolchain/mac-arm64-output-root
COPY --from=flipperzero-toolchain-tools /toolchain/mac-x86_64-output-root /toolchain/mac-x86_64-output-root
COPY --from=flipperzero-toolchain-tools /toolchain/mac-arm64-output-root /toolchain/mac-arm64-output-root
ADD requirements.txt /toolchain/
RUN /toolchain/mac-x86_64-output-root/bin/python3 -m pip install --upgrade pip
RUN /toolchain/mac-x86_64-output-root/bin/python3 -m pip install -r /toolchain/requirements.txt
RUN /toolchain/mac-arm64-output-root/bin/python3 -m pip install --upgrade pip
RUN /toolchain/mac-arm64-output-root/bin/python3 -m pip install -r /toolchain/requirements.txt
ADD scripts/strip.sh /usr/bin/
ADD scripts/relink.sh /usr/bin/
RUN relink.sh /toolchain/mac-x86_64-output-root
RUN relink.sh /toolchain/mac-arm64-output-root
RUN strip.sh
ADD scripts/bundle_upload.sh /usr/bin/
