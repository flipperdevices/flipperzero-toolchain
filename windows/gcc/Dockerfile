FROM debian:11 as flipperzero-toolchain-src
ADD https://developer.arm.com/-/media/Files/downloads/gnu/12.3.rel1/srcrel/arm-gnu-toolchain-src-snapshot-12.3.rel1.tar.xz /toolchain/src/src/archives/
RUN DEBIAN_FRONTEND=noninteractive apt update && apt -y install build-essential gcc-mingw-w64-x86-64 xz-utils g++-mingw-w64-x86-64 m4 bison flex texinfo file patchelf
RUN tar -xvf /toolchain/src/src/archives/arm-gnu-toolchain-src-snapshot-12.3.rel1.tar.xz -C /toolchain/src/src/
WORKDIR /toolchain/src/

FROM flipperzero-toolchain-src AS flipperzero-toolchain-windows-build-deps
ADD scripts/build-windows-gcc-build-libs.sh /toolchain/src/
RUN bash /toolchain/src/build-windows-gcc-build-libs.sh

FROM flipperzero-toolchain-windows-build-deps AS flipperzero-toolchain-windows-binutils
ADD scripts/build-windows-binutils.sh /toolchain/src/
RUN bash /toolchain/src/build-windows-binutils.sh

FROM flipperzero-toolchain-windows-binutils AS flipperzero-toolchain-windows-gcc
COPY --from=flipperzero-toolchain /toolchain/linux-output-root/arm-none-eabi/lib /toolchain/windows-output-root/arm-none-eabi/lib
COPY --from=flipperzero-toolchain /toolchain/linux-output-root/arm-none-eabi/include /toolchain/windows-output-root/arm-none-eabi/include
COPY --from=flipperzero-toolchain /toolchain/linux-output-root/arm-none-eabi/include/c++ /toolchain/windows-output-root/arm-none-eabi/include/c++
COPY --from=flipperzero-toolchain /toolchain/linux-output-root/lib/gcc/arm-none-eabi /toolchain/windows-output-root/lib/gcc/arm-none-eabi
ADD https://developer.arm.com/-/media/Files/downloads/gnu/12.2.rel1/binrel/arm-gnu-toolchain-12.2.rel1-x86_64-arm-none-eabi.tar.xz /toolchain/src/src/archives
RUN tar -xvf /toolchain/src/src/archives/arm-gnu-toolchain-12.2.rel1-x86_64-arm-none-eabi.tar.xz -C /toolchain/src/src/
RUN rm -rf /usr/share/doc/gcc
RUN cp -rf /toolchain/src/src/arm-gnu-toolchain-12.2.rel1-x86_64-arm-none-eabi/* /usr/
ADD scripts/build-windows-gcc.sh /toolchain/src/
RUN bash /toolchain/src/build-windows-gcc.sh

FROM flipperzero-toolchain-windows-build-deps AS flipperzero-toolchain-windows-python
RUN DEBIAN_FRONTEND=noninteractive dpkg --add-architecture i386 && apt update && apt -y install xvfb wine wine32 wine64 unzip
ADD https://www.python.org/ftp/python/3.11.2/python-3.11.2-amd64.exe /toolchain/src/src/archives
ADD scripts/unpack-windows-python-wine.sh /toolchain/src/
RUN bash /toolchain/src/unpack-windows-python-wine.sh

FROM flipperzero-toolchain-windows-binutils AS flipperzero-toolchain-windows-gdb
COPY --from=flipperzero-toolchain-windows-python /toolchain/windows-output-root/python /toolchain/windows-output-root/python
ADD scripts/python3-config-windows-x86_64.sh /toolchain/src/
ADD scripts/build-windows-gdb.sh /toolchain/src/
RUN bash /toolchain/src/build-windows-gdb.sh

FROM flipperzero-toolchain-windows-build-deps AS flipperzero-toolchain-windows-tools
RUN DEBIAN_FRONTEND=noninteractive apt update && apt -y install rsync git python3 unzip
ADD https://github.com/Kitware/CMake/releases/download/v3.28.0/cmake-3.28.0-linux-x86_64.tar.gz /toolchain/src/src/archives/
RUN tar -xvf /toolchain/src/src/archives/cmake-3.28.0-linux-x86_64.tar.gz -C /tmp
RUN rsync -azv /tmp/cmake-3.28.0-linux-x86_64/ /usr
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
ADD https://github.com/xpack-dev-tools/openocd-xpack/releases/download/v0.12.0-2/xpack-openocd-0.12.0-2-win32-x64.zip /toolchain/src/src/archives/
RUN unzip /toolchain/src/src/archives/xpack-openocd-0.12.0-2-win32-x64.zip -d /tmp
RUN rm -rf /tmp/xpack-openocd-0.12.0-2/README.md
RUN rm -rf /tmp/xpack-openocd-0.12.0-2/distro-info
RUN rsync -azv /tmp/xpack-openocd-0.12.0-2/ /toolchain/windows-output-root
ADD scripts/build-windows-flipper-tools.sh /toolchain/src/
RUN bash /toolchain/src/build-windows-flipper-tools.sh

FROM debian:11 as flipperzero-toolchain-windows
COPY --from=flipperzero-toolchain-windows-binutils /toolchain/windows-output-root /toolchain/windows-output-root
COPY --from=flipperzero-toolchain-windows-gdb /toolchain/windows-output-root /toolchain/windows-output-root
COPY --from=flipperzero-toolchain-windows-gcc /toolchain/windows-output-root /toolchain/windows-output-root
COPY --from=flipperzero-toolchain-windows-tools /toolchain/windows-output-root /toolchain/windows-output-root
