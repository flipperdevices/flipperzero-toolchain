FROM debian:11 as flipperzero-toolchain-src
ADD https://developer.arm.com/-/media/Files/downloads/gnu/12.3.rel1/srcrel/arm-gnu-toolchain-src-snapshot-12.3.rel1.tar.xz /toolchain/src/src/archives/
RUN DEBIAN_FRONTEND=noninteractive apt update && apt -y install build-essential gcc-mingw-w64-x86-64 xz-utils g++-mingw-w64-x86-64 m4 bison flex texinfo file patchelf
RUN tar -xvf /toolchain/src/src/archives/arm-gnu-toolchain-src-snapshot-12.3.rel1.tar.xz -C /toolchain/src/src/
WORKDIR /toolchain/src/

FROM flipperzero-toolchain-src AS flipperzero-toolchain-build-deps
ADD https://ftp.gnu.org/pub/gnu/ncurses/ncurses-6.2.tar.gz /toolchain/src/src/archives/
RUN tar -xvf /toolchain/src/src/archives/ncurses-6.2.tar.gz -C /toolchain/src/src/
RUN rm -rf /toolchain/src/src/ncurses
RUN mv /toolchain/src/src/ncurses-6.2 /toolchain/src/src/ncurses
ADD scripts/build-linux-gcc-build-libs.sh /toolchain/src/
RUN bash /toolchain/src/build-linux-gcc-build-libs.sh

FROM flipperzero-toolchain-build-deps AS flipperzero-toolchain-binutils
ADD scripts/build-linux-binutils.sh /toolchain/src/
RUN bash /toolchain/src/build-linux-binutils.sh

FROM flipperzero-toolchain-build-deps AS flipperzero-toolchain-gdb
COPY --from=flipperzero-toolchain-python /toolchain/linux-output-root /toolchain/linux-output-root
ADD scripts/relink.sh /usr/bin/
ADD patch/gdb_curses.h /toolchain/srcsrc/binutils-gdb/gdb/
ADD scripts/build-linux-gdb.sh /toolchain/src/
RUN bash /toolchain/src/build-linux-gdb.sh

FROM flipperzero-toolchain-build-deps AS flipperzero-toolchain-gdb-py
COPY --from=flipperzero-toolchain-python /toolchain/linux-output-root /toolchain/linux-output-root
ADD scripts/relink.sh /usr/bin/
ADD patch/gdb_curses.h /toolchain/src/src/binutils-gdb/gdb/
ADD scripts/build-linux-gdb-py.sh /toolchain/src/
RUN bash /toolchain/src/build-linux-gdb-py.sh

FROM flipperzero-toolchain-build-deps AS flipperzero-toolchain-newlib-nano
RUN DEBIAN_FRONTEND=noninteractive apt update && apt -y install gcc-arm-none-eabi
ADD scripts/build-linux-newlib.sh /toolchain/src/
RUN bash /toolchain/src/build-linux-newlib.sh

FROM flipperzero-toolchain-build-deps AS flipperzero-toolchain-gcc
RUN DEBIAN_FRONTEND=noninteractive apt update && apt -y install gcc-arm-none-eabi
COPY --from=flipperzero-toolchain-python /toolchain/linux-output-root /toolchain/linux-output-root
COPY --from=flipperzero-toolchain-newlib-nano /toolchain/linux-output-root /toolchain/linux-output-root
ADD scripts/relink.sh /usr/bin/
ADD scripts/build-linux-gcc.sh /toolchain/src/
RUN bash /toolchain/src/build-linux-gcc.sh

FROM flipperzero-toolchain-build-deps AS flipperzero-toolchain-tools
ADD https://github.com/protocolbuffers/protobuf/releases/download/v21.7/protobuf-cpp-3.21.7.tar.gz /toolchain/src/src/archives/
RUN tar -xvf /toolchain/src/src/archives/protobuf-cpp-3.21.7.tar.gz -C /toolchain/src/src/
RUN mv /toolchain/src/src/protobuf-3.21.7 /toolchain/src/src/protobuf
ADD scripts/relink.sh /usr/bin/
ADD scripts/build-linux-flipper-tools.sh /toolchain/src/
RUN bash /toolchain/src/build-linux-flipper-tools.sh

FROM debian:11 as flipperzero-toolchain
COPY --from=flipperzero-toolchain-binutils /toolchain/linux-output-root /toolchain/linux-output-root
COPY --from=flipperzero-toolchain-gdb /toolchain/linux-output-root /toolchain/linux-output-root
COPY --from=flipperzero-toolchain-gdb-py /toolchain/linux-output-root /toolchain/linux-output-root
COPY --from=flipperzero-toolchain-gcc /toolchain/linux-output-root /toolchain/linux-output-root
COPY --from=flipperzero-toolchain-tools /toolchain/linux-output-root /toolchain/linux-output-root
RUN DEBIAN_FRONTEND=noninteractive apt update && apt -y install build-essential
ADD requirements.txt /toolchain/requirements.txt
ADD scripts/move_newlib_to_nano.sh /toolchain
RUN /toolchain/linux-output-root/bin/python3 -m pip install --upgrade pip
RUN /toolchain/linux-output-root/bin/python3 -m pip install -r /toolchain/requirements.txt
#RUN bash /toolchain/move_newlib_to_nano.sh
