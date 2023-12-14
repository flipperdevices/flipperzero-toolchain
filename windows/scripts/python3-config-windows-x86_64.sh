#!/bin/bash

# Windows Python configuration script
# As per comment regarding --with-python in gdb/configure.ac, this script
# follows the interface of gdb/python/python-config.py but return path
# related to Windows Python.

WINDOWS_CONFIGURE_ROOT=/toolchain/windows-configure-root
WINDOWS_BUILD_ROOT=/toolchain/windows-build-root
WINDOWS_OUTPUT_ROOT=/toolchain/windows-output-root
PYTHON_PATH="$WINDOWS_OUTPUT_ROOT/python";

while [ $# -ge 1 ]; do
  OP="$1"
  case $OP in
    --prefix)
      echo "$PYTHON_PATH";;
    --exec-prefix)
      echo "$PYTHON_PATH";;
    --includes|--cflags)
      CF="-I$PYTHON_PATH/include"
      if [[ "$OP" == "--cflags" ]]; then
        CF="$CF $CFLAGS"
      fi
      echo "$CF";;
    --libs|--ldflags)
      echo "-L$PYTHON_PATH/libs -lpython311";;
    --*)
      echo "Unknown option: $OP" >&2
      exit 1;;
    *)
      ;;
  esac
  shift
done
