FROM debian:11 as flipperzero-toolchain-linux-src
ADD https://developer.arm.com/-/media/Files/downloads/gnu/12.3.rel1/srcrel/arm-gnu-toolchain-src-snapshot-12.3.rel1.tar.xz /toolchain/src/src/archives/
RUN DEBIAN_FRONTEND=noninteractive apt update && apt -y install build-essential xz-utils m4 bison flex texinfo file patchelf
RUN tar -xvf /toolchain/src/src/archives/arm-gnu-toolchain-src-snapshot-12.3.rel1.tar.xz -C /toolchain/src/src/
WORKDIR /toolchain/src/

FROM flipperzero-toolchain-linux-src AS flipperzero-toolchain-linux-build-deps
ADD https://ftp.gnu.org/pub/gnu/ncurses/ncurses-6.2.tar.gz /toolchain/src/src/archives/
RUN tar -xvf /toolchain/src/src/archives/ncurses-6.2.tar.gz -C /toolchain/src/src/
RUN rm -rf /toolchain/src/src/ncurses
RUN mv /toolchain/src/src/ncurses-6.2 /toolchain/src/src/ncurses
ADD scripts/build-linux-gcc-build-libs.sh /toolchain/src/
RUN bash /toolchain/src/build-linux-gcc-build-libs.sh

FROM flipperzero-toolchain-linux-build-deps AS flipperzero-toolchain-linux-python-build-libs
ADD https://www.python.org/ftp/python/3.11.2/Python-3.11.2.tgz /toolchain/src/src/archives/
RUN tar -xvf /toolchain/src/src/archives/Python-3.11.2.tgz -C /toolchain/src/src/
RUN mv /toolchain/src/src/Python-3.11.2 /toolchain/src/src/python
ADD https://www.openssl.org/source/openssl-1.1.1w.tar.gz /toolchain/src/src/archives/
RUN tar -xvf /toolchain/src/src/archives/openssl-1.1.1w.tar.gz -C /toolchain/src/src/
RUN mv /toolchain/src/src/openssl-1.1.1w /toolchain/src/src/openssl
ADD https://github.com/libffi/libffi/releases/download/v3.4.4/libffi-3.4.4.tar.gz /toolchain/src/src/archives/
RUN tar -xvf /toolchain/src/src/archives/libffi-3.4.4.tar.gz -C /toolchain/src/src/
RUN mv /toolchain/src/src/libffi-3.4.4 /toolchain/src/src/libffi
ADD https://zlib.net/zlib-1.3.tar.gz /toolchain/src/src/archives/
RUN tar -xvf /toolchain/src/src/archives/zlib-1.3.tar.gz -C /toolchain/src/src/
RUN mv /toolchain/src/src/zlib-1.3 /toolchain/src/src/zlib
ADD scripts/build-linux-python-libs.sh /toolchain/src/
ADD https://ftp.gnu.org/gnu/readline/readline-8.1.tar.gz /toolchain/src/src/archives/
RUN tar -xvf /toolchain/src/src/archives/readline-8.1.tar.gz -C /toolchain/src/src/
RUN mv /toolchain/src/src/readline-8.1 /toolchain/src/src/readline
ADD scripts/relink.sh /usr/bin/
RUN bash /toolchain/src/build-linux-python-libs.sh

FROM flipperzero-toolchain-linux-python-build-libs AS flipperzero-toolchain-linux-python
ADD scripts/build-linux-python.sh /toolchain/src/
RUN bash /toolchain/src/build-linux-python.sh

FROM flipperzero-toolchain-linux-build-deps AS flipperzero-toolchain-linux-binutils
ADD scripts/build-linux-binutils.sh /toolchain/src/
RUN bash /toolchain/src/build-linux-binutils.sh

FROM flipperzero-toolchain-linux-build-deps AS flipperzero-toolchain-linux-gdb
COPY --from=flipperzero-toolchain-linux-python /toolchain/linux-output-root /toolchain/linux-output-root
ADD scripts/relink.sh /usr/bin/
ADD patch/gdb_curses.h /toolchain/srcsrc/binutils-gdb/gdb/
ADD scripts/build-linux-gdb.sh /toolchain/src/
RUN bash /toolchain/src/build-linux-gdb.sh

FROM flipperzero-toolchain-linux-build-deps AS flipperzero-toolchain-linux-newlib-nano
ADD https://developer.arm.com/-/media/Files/downloads/gnu/12.2.rel1/binrel/arm-gnu-toolchain-12.2.rel1-x86_64-arm-none-eabi.tar.xz /toolchain/src/src/archives
RUN tar -xvf /toolchain/src/src/archives/arm-gnu-toolchain-12.2.rel1-x86_64-arm-none-eabi.tar.xz -C /toolchain/src/src/
RUN rm -rf /usr/share/doc/gcc
RUN cp -fr /toolchain/src/src/arm-gnu-toolchain-12.2.rel1-x86_64-arm-none-eabi/* /usr/
ADD scripts/build-linux-newlib.sh /toolchain/src/
RUN bash /toolchain/src/build-linux-newlib.sh

FROM flipperzero-toolchain-linux-build-deps AS flipperzero-toolchain-linux-gcc
ADD https://developer.arm.com/-/media/Files/downloads/gnu/12.2.rel1/binrel/arm-gnu-toolchain-12.2.rel1-x86_64-arm-none-eabi.tar.xz /toolchain/src/src/archives
RUN tar -xvf /toolchain/src/src/archives/arm-gnu-toolchain-12.2.rel1-x86_64-arm-none-eabi.tar.xz -C /toolchain/src/src/
RUN rm -rf /usr/share/doc/gcc
RUN cp -rf /toolchain/src/src/arm-gnu-toolchain-12.2.rel1-x86_64-arm-none-eabi/* /usr/
COPY --from=flipperzero-toolchain-linux-python /toolchain/linux-output-root /toolchain/linux-output-root
COPY --from=flipperzero-toolchain-linux-newlib-nano /toolchain/linux-output-root /toolchain/linux-output-root
COPY --from=flipperzero-toolchain-linux-newlib-nano /toolchain/newlib-nano-temp /toolchain/newlib-nano-temp
ADD scripts/relink.sh /usr/bin/
ADD scripts/build-linux-gcc.sh /toolchain/src/
RUN bash /toolchain/src/build-linux-gcc.sh
ADD scripts/move_newlib_to_nano.sh /toolchain
RUN bash /toolchain/move_newlib_to_nano.sh

FROM flipperzero-toolchain-linux-build-deps AS flipperzero-toolchain-linux-tools
ADD https://github.com/protocolbuffers/protobuf/releases/download/v21.7/protobuf-cpp-3.21.7.tar.gz /toolchain/src/src/archives/
ADD https://github.com/xpack-dev-tools/openocd-xpack/releases/download/v0.12.0-2/xpack-openocd-0.12.0-2-linux-x64.tar.gz /toolchain/src/src/archives/
RUN tar -xvf /toolchain/src/src/archives/protobuf-cpp-3.21.7.tar.gz -C /toolchain/src/src/
RUN tar -xvf /toolchain/src/src/archives/xpack-openocd-0.12.0-2-linux-x64.tar.gz -C /toolchain/src/src/
RUN mv /toolchain/src/src/protobuf-3.21.7 /toolchain/src/src/protobuf
ADD scripts/relink.sh /usr/bin/
ADD scripts/build-linux-flipper-tools.sh /toolchain/src/
RUN bash /toolchain/src/build-linux-flipper-tools.sh
RUN cp -r /toolchain/src/src/xpack-openocd-0.12.0-2/*  /toolchain/linux-output-root/

FROM debian:11 as flipperzero-toolchain
COPY --from=flipperzero-toolchain-linux-binutils /toolchain/linux-output-root /toolchain/linux-output-root
COPY --from=flipperzero-toolchain-linux-gdb /toolchain/linux-output-root /toolchain/linux-output-root
COPY --from=flipperzero-toolchain-linux-gcc /toolchain/linux-output-root /toolchain/linux-output-root
COPY --from=flipperzero-toolchain-linux-tools /toolchain/linux-output-root /toolchain/linux-output-root
RUN DEBIAN_FRONTEND=noninteractive apt update && apt -y install build-essential file patchelf
ADD requirements.txt /toolchain/requirements.txt
RUN /toolchain/linux-output-root/bin/python3 -m pip install --upgrade pip
RUN /toolchain/linux-output-root/bin/python3 -m pip install -r /toolchain/requirements.txt
ADD scripts/relink.sh /usr/bin/
RUN relink.sh /toolchain/linux-output-root
ADD scripts/strip.sh /usr/bin/
RUN strip.sh /toolchain/linux-output-root
ADD scripts/bundle_upload.sh /usr/bin/
WORKDIR /toolchain
