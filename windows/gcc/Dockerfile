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
#RUN bash /toolchain/src/build-windows-gdb.sh
