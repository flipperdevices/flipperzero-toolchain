FROM debian:11 AS flipperzero-toolchain-python-build-libs

RUN DEBIAN_FRONTEND=noninteractive apt update && apt -y install file build-essential xz-utils patchelf
ADD https://www.python.org/ftp/python/3.11.2/Python-3.11.2.tgz /toolchain/src/src/archives/
RUN tar -xvf /toolchain/src/src/archives/Python-3.11.2.tgz -C /toolchain/src/src/
RUN mv /toolchain/src/src/Python-3.11.2 /toolchain/src/src/python
ADD https://www.openssl.org/source/openssl-1.1.1w.tar.gz /toolchain/src/src/archives/
RUN tar -xvf /toolchain/src/src/archives/openssl-1.1.1w.tar.gz -C /toolchain/src/src/
RUN mv /toolchain/src/src/openssl-1.1.1w /toolchain/src/src/openssl
ADD https://github.com/libffi/libffi/releases/download/v3.4.4/libffi-3.4.4.tar.gz /toolchain/src/src/archives/
RUN tar -xvf /toolchain/src/src/archives/libffi-3.4.4.tar.gz -C /toolchain/src/src/
RUN mv /toolchain/src/src/libffi-3.4.4 /toolchain/src/src/libffi
ADD https://ftp.gnu.org/pub/gnu/ncurses/ncurses-6.2.tar.gz /toolchain/src/src/archives/
RUN tar -xvf /toolchain/src/src/archives/ncurses-6.2.tar.gz -C /toolchain/src/src/
RUN rm -rf /toolchain/src/src/ncurses
RUN mv /toolchain/src/src/ncurses-6.2 /toolchain/src/src/ncurses
ADD https://zlib.net/zlib-1.3.tar.gz /toolchain/src/src/archives/
RUN tar -xvf /toolchain/src/src/archives/zlib-1.3.tar.gz -C /toolchain/src/src/
RUN mv /toolchain/src/src/zlib-1.3 /toolchain/src/src/zlib
ADD scripts/build-linux-python-libs.sh /toolchain/src/
ADD https://ftp.gnu.org/gnu/readline/readline-8.1.tar.gz /toolchain/src/src/archives/
RUN tar -xvf /toolchain/src/src/archives/readline-8.1.tar.gz -C /toolchain/src/src/
RUN mv /toolchain/src/src/readline-8.1 /toolchain/src/src/readline
ADD scripts/relink.sh /usr/bin/
RUN bash /toolchain/src/build-linux-python-libs.sh
WORKDIR /toolchain/src/

FROM flipperzero-toolchain-python-build-libs AS flipperzero-toolchain-python
ADD scripts/build-linux-python.sh /toolchain/src/
RUN bash /toolchain/src/build-linux-python.sh
