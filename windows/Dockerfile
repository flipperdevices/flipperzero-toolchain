FROM debian:11 as flipperzero-toolchain-windows-src
ADD https://developer.arm.com/-/media/Files/downloads/gnu/12.3.rel1/srcrel/arm-gnu-toolchain-src-snapshot-12.3.rel1.tar.xz /toolchain/src/src/archives/
RUN DEBIAN_FRONTEND=noninteractive apt update && apt -y install build-essential xz-utils m4 bison flex texinfo file patchelf
ADD https://github.com/xpack-dev-tools/mingw-w64-gcc-xpack/releases/download/v12.3.0-1/xpack-mingw-w64-gcc-12.3.0-1-linux-x64.tar.gz /toolchain/src/src/archives/
RUN tar -xvf /toolchain/src/src/archives/xpack-mingw-w64-gcc-12.3.0-1-linux-x64.tar.gz --strip-components=1 -C /usr/
RUN tar -xvf /toolchain/src/src/archives/arm-gnu-toolchain-src-snapshot-12.3.rel1.tar.xz -C /toolchain/src/src/
WORKDIR /toolchain/src/

FROM flipperzero-toolchain-windows-src AS flipperzero-toolchain-windows-build-deps
ADD scripts/build-windows-gcc-build-libs.sh /toolchain/src/
RUN bash /toolchain/src/build-windows-gcc-build-libs.sh

FROM flipperzero-toolchain-windows-build-deps AS flipperzero-toolchain-windows-binutils
ADD scripts/build-windows-binutils.sh /toolchain/src/
RUN bash /toolchain/src/build-windows-binutils.sh

FROM flipperzero-toolchain-windows-binutils AS flipperzero-toolchain-windows-gcc
RUN DEBIAN_FRONTEND=noninteractive apt update && apt -y install git patch
ADD patch/DEFINE-WIN32_LEAN_AND_MEAN.patch /toolchain/src/
RUN cd /toolchain/src/src/arm-gnu-toolchain-src-snapshot-12.3.rel1 && git apply /toolchain/src/DEFINE-WIN32_LEAN_AND_MEAN.patch
COPY --from=flipperzero-toolchain-linux /toolchain/linux-output-root/arm-none-eabi/lib /toolchain/windows-output-root/arm-none-eabi/lib
COPY --from=flipperzero-toolchain-linux /toolchain/linux-output-root/arm-none-eabi/include /toolchain/windows-output-root/arm-none-eabi/include
COPY --from=flipperzero-toolchain-linux /toolchain/linux-output-root/arm-none-eabi/include/c++ /toolchain/windows-output-root/arm-none-eabi/include/c++
COPY --from=flipperzero-toolchain-linux /toolchain/linux-output-root/lib/gcc/arm-none-eabi /toolchain/windows-output-root/lib/gcc/arm-none-eabi
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
ADD https://ftp.gnu.org/gnu/gdb/gdb-13.2.tar.gz /toolchain/src/src/archives
RUN tar -xvf /toolchain/src/src/archives/gdb-13.2.tar.gz -C /toolchain/src/src/
COPY --from=flipperzero-toolchain-windows-python /toolchain/windows-output-root/python /toolchain/windows-output-root/python
ADD scripts/python3-config-windows-x86_64.sh /toolchain/src/
ADD scripts/build-windows-gdb.sh /toolchain/src/
RUN bash /toolchain/src/build-windows-gdb.sh

FROM flipperzero-toolchain-windows-build-deps AS flipperzero-toolchain-windows-tools
RUN DEBIAN_FRONTEND=noninteractive apt update && apt -y install rsync git python3 unzip automake autoconf libtool pkg-config
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

ADD https://github.com/libusb/libusb/releases/download/v1.0.24/libusb-1.0.24.tar.bz2 /toolchain/src/src/archives/
RUN tar -xvf /toolchain/src/src/archives/libusb-1.0.24.tar.bz2 -C /toolchain/src/src/
RUN mv /toolchain/src/src/libusb-1.0.24 /toolchain/src/src/libusb

ADD https://github.com/libusb/hidapi/archive/refs/tags/hidapi-0.14.0.tar.gz /toolchain/src/src/archives/
RUN tar -xvf /toolchain/src/src/archives/hidapi-0.14.0.tar.gz -C /toolchain/src/src/
RUN mv /toolchain/src/src/hidapi-hidapi-0.14.0 /toolchain/src/src/hidapi

RUN git clone https://github.com/flipperdevices/openocd.git /toolchain/src/src/openocd

ADD scripts/build-windows-flipper-tools.sh /toolchain/src/
RUN bash /toolchain/src/build-windows-flipper-tools.sh

FROM debian:11 AS flipperzero-toolchain-windows
RUN DEBIAN_FRONTEND=noninteractive apt update && apt -y install wine gcc-mingw-w64-x86-64 g++-mingw-w64-x86-64 xz-utils curl zip
ADD https://developer.arm.com/-/media/Files/downloads/gnu/12.2.rel1/binrel/arm-gnu-toolchain-12.2.rel1-x86_64-arm-none-eabi.tar.xz /toolchain/src/src/archives/
RUN tar -xvf /toolchain/src/src/archives/arm-gnu-toolchain-12.2.rel1-x86_64-arm-none-eabi.tar.xz -C /toolchain/src/src/
RUN rm -rf /toolchain/src/src/arm-gnu-toolchain-12.2.rel1-x86_64-arm-none-eabi/usr/share/doc
RUN cp -fr /toolchain/src/src/arm-gnu-toolchain-12.2.rel1-x86_64-arm-none-eabi/* /usr/
COPY --from=flipperzero-toolchain-windows-binutils /toolchain/windows-output-root /toolchain/windows-output-root
COPY --from=flipperzero-toolchain-windows-gdb /toolchain/windows-output-root /toolchain/windows-output-root
COPY --from=flipperzero-toolchain-windows-gcc /toolchain/windows-output-root /toolchain/windows-output-root
COPY --from=flipperzero-toolchain-windows-tools /toolchain/windows-output-root /toolchain/windows-output-root
ADD requirements.txt /toolchain/
RUN wine /toolchain/windows-output-root/python/python.exe -m pip install --upgrade pip
RUN wine /toolchain/windows-output-root/python/python.exe -m pip install -r /toolchain/requirements.txt
ADD scripts/strip.sh /usr/bin/
ADD scripts/bundle_upload.sh /usr/bin/
RUN strip.sh
COPY --from=flipperzero-toolchain-windows-src /usr/x86_64-w64-mingw32/lib /tmp/lib/
RUN cp /tmp/lib/*.dll /toolchain/windows-output-root/bin/
RUN cp /toolchain/windows-output-root/python/python311.dll /toolchain/windows-output-root/bin/
ADD patch/python311._pth /toolchain/windows-output-root/bin/
