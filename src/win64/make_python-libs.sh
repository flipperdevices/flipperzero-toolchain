#!/bin/bash

mkdir arch
git init
git add .
git commit -m "init"
./python.exe -m pip install --upgrade pip
./python.exe -m pip install ansi==0.3.6 bitstring==3.1.9 black==23.1.0 certifi==2022.12.7 cffi==1.15.1 charset-normalizer==3.0.1 click==8.1.3 colorlog==6.7.0 contextlib2==21.6.0 cryptography==39.0.1 dataclass-wizard==0.22.2 ecdsa==0.18.0 esptool==4.4 gitdb==4.0.10 GitPython==3.1.29 heatshrink2==0.12.0 idna==3.4 lxml==4.9.2 mypy-extensions==1.0.0 packaging==23.0 pathspec==0.11.0 Pillow==9.4.0 platformdirs==3.0.0 protobuf==4.21.12 pycparser==2.21 pyserial==3.5 python3-protobuf==2.5.0 PyYAML==6.0 reedsolo==1.5.4 requests==2.28.2 schema==0.7.5 SCons==4.5.2 pyelftools==0.29 six==1.16.0 smmap==5.0.0 urllib3==1.26.14
cp --parents -r $(git status | grep -v " " | awk '{print $1}') arch/
cd arch
tar -cvf ../python-libs.tar.gz *
cd ..
rm -rf arch

