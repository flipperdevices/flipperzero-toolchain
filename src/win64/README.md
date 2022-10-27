# Some win32 stuff

To compile win32 toolchain we need pre-compiled python and pre-downloaded libs..

1. python.tar.gz - clean pre-compiled win64 Python 3.9.9.
    Way to create under Linux:
    ```bash
    wget https://sourceforge.net/projects/portable-python/files/Portable%20Python%203.9/Portable%20Python-3.9.9%20x64.exe -O python.exe
    7z x -opy_temp python.exe
    mv py_temp/Portable\ Python-3.9.9\ x64/App/Python python
    tar cvf python.tar.gz python
    rm -rf python.exe py_temp python
    ```
2. python-libs.tar.gz - pre-downloaded Python3 libs needed by Flipper Toolchain
    Worst way to create under Windows:
    1. Open Git Bash and unpack python.tar.gz
    2. `cd python git init && git add . && git commit -m "init"`
    3. `Python\python.exe -m pip install pyserial==3.5 heatshrink2==0.11.0 Pillow==9.1.1 protobuf==3.20.1 python3-protobuf==2.5.0`
    4. Add all files from `git diff` output to archive

3. python-config.sh - custom script for GDB configure
4. protoc-21.7-win64.zip - pre-compiled win64 Protobuf, downloaded from https://github.com/protocolbuffers/protobuf/releases/download/v21.7/protoc-21.7-win64.zip
5. pre-compiled win64 xpack-openocd-0.11.0-5, downloaded from https://github.com/xpack-dev-tools/openocd-xpack/releases/download/v0.11.0-5/xpack-openocd-0.11.0-5-win32-x64.zip
6. pre-compiled win64 clang-format 14.0.6, downloaded from https://github.com/llvm/llvm-project/releases/download/llvmorg-14.0.6/LLVM-14.0.6-win64.exe
