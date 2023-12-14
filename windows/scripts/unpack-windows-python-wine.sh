#!/bin/bash

set -euo pipefail;

WINDOWS_CONFIGURE_ROOT=/toolchain/windows-configure-root
WINDOWS_BUILD_ROOT=/toolchain/windows-build-root
WINDOWS_OUTPUT_ROOT=/toolchain/windows-output-root

CPUS="$(grep -c processor /proc/cpuinfo )";
DUMMY_FB_PID=0;

function stop_dummy_fb() {
    if [[ "$DUMMY_FB_PID" != 0 ]]; then
        kill -9 "$DUMMY_FB_PID";
    fi
}
function init_dummy_fb() {
    Xvfb :0 -screen 0 1024x768x16 &
    DUMMY_FB_PID=$!;
    trap stop_dummy_fb EXIT;
}
function setup_wine() {
    DISPLAY=:0.0 WINEARCH=win64 winecfg /v win81;
}
function unpack_python() {
    pushd /toolchain/src/src/archives;
    DISPLAY=:0.0 WINEARCH=win64 wine cmd /c python-3.11.2-amd64.exe /quiet PrependPath=1 InstallAllUsers=1 TargetDir=C:\\Python
    popd;
}
function move_python_files() {
    mkdir -p "$WINDOWS_OUTPUT_ROOT";
    mv /root/.wine/drive_c/Python "$WINDOWS_OUTPUT_ROOT/python";
}

init_dummy_fb;
setup_wine;
unpack_python;
move_python_files;
