@echo off
set "toolchainRoot=%~dp0.."
cmd /V /C "set "HOME=%USERPROFILE%" && set "PATH=%toolchainRoot%\python;%PATH%" && set "PYTHONHOME=%toolchainRoot%\python" && %~dp0arm-none-eabi-gdb-py-bin.exe %*"
