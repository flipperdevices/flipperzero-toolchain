@echo off
set "toolchainRoot=%~dp0.."
cmd /V /C "set "HOME=%USERPROFILE%" && set "PATH=%PATH%;%toolchainRoot%\python" && set "PYTHONHOME=%PATH%;%toolchainRoot%\python" && %~dp0arm-none-eabi-gdb-py-bin.exe %*"
