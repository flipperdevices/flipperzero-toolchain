#!/bin/bash

mkdir arch
git init
git add .
git commit -m "init"
./python.exe -m pip install --upgrade pip
./python.exe -m pip install protobuf==3.20.1 pyserial==3.5 heatshrink2==0.11.0 Pillow==9.1.1 python3-protobuf==2.5.0 black==22.6.0 ansi==0.3.6 SCons==4.4.0 colorlog==6.7.0
cp --parents -r $(git status | grep -v " " | awk '{print $1}') arch/
cd arch
tar -cvf ../python-libs.tar.gz *
cd ..
rm -rf arch

