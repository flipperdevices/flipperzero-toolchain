FROM MacOSVenturaWithBrew

ADD https://www.python.org/ftp/python/3.11.2/Python-3.11.2.tgz /toolchain/src/src/archives/
RUN tar -xvf /toolchain/src/src/archives/Python-3.11.2.tgz -C /toolchain/src/src/
RUN mv /toolchain/src/src/Python-3.11.2 /toolchain/src/src/python
ADD https://www.openssl.org/source/openssl-1.1.1w.tar.gz /toolchain/src/src/archives/
RUN tar -xvf /toolchain/src/src/archives/openssl-1.1.1w.tar.gz -C /toolchain/src/src/
RUN mv /toolchain/src/src/openssl-1.1.1w /toolchain/src/src/openssl
ADD scripts/build-mac-python-libs.sh /toolchain/src/
#RUN bash /toolchain/src/build-mac-python-libs.sh
