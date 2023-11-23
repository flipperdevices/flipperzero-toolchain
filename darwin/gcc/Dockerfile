#FROM MacOSVenturaWithBrew

#RUN brew update-reset
#RUN brew install gettext texinfo coreutils bison flex m4 xz || true
#RUN brew link bison --force

#ADD https://developer.arm.com/-/media/Files/downloads/gnu/12.3.rel1/srcrel/arm-gnu-toolchain-src-snapshot-12.3.rel1.tar.xz /toolchain/src/src/archives/
#RUN tar -xvf /toolchain/src/src/archives/arm-gnu-toolchain-src-snapshot-12.3.rel1.tar.xz -C /toolchain/src/src/
#ADD scripts/build-mac-build-libs.sh /toolchain/src/
#RUN bash /toolchain/src/build-mac-build-libs.sh
#ADD scripts/build-mac-binutils.sh /toolchain/src/
#RUN bash /toolchain/src/build-mac-binutils.sh

FROM flipperzero-toolchain-binutils
COPY --from=flipperzero-toolchain-python /toolchain/mac-x86_64-output-root /toolchain/mac-x86_64-output-root
COPY --from=flipperzero-toolchain-python /toolchain/mac-arm64-output-root /toolchain/mac-arm64-output-root
ADD scripts/build-mac-gdb.sh /toolchain/src/
ADD scripts/build-mac-gdb-py.sh /toolchain/src/
ADD scripts/python3-config-x86_64.sh /toolchain/src/
ADD scripts/python3-config-arm64.sh /toolchain/src/
ADD scripts/relink.sh /usr/bin
RUN bash /toolchain/src/build-mac-gdb-py.sh
RUN bash /toolchain/src/build-mac-gdb.sh
RUN relink.sh /toolchain/mac-x86_64-output-root
RUN relink.sh /toolchain/mac-arm64-output-root
