# Flipper Zero Embedded Toolchain

Scripts to build gcc-arm-none-eabi-10.3 with with all accompanying tools needed by FBT.

Building Linux(x64) and Windows(x86) toolchain under Linux:
```bash
ansible-playbook build-linux-x86_64-windows-i686.yml
```

Building MacOS(x64) toolchain under MacOS:
```bash
ansible-playbook build-darwin-x86_64.yml
```

List of tools:
- Python 3.9
- XPack OpenOCD 0.11.0-3
- Protobuf 3.20.1
- clang-format TODO

List of Python libraries:
- Pillow 9.1.1
- pyserial 3.5
- heatshrink2 0.11.0
- python3-protobuf 2.5.0

List of Linux libraries:
- Ncurses 6.2
- Libtool 2.4.6
- libffi 3.3

List of MacOS libraries:
- Gettext 0.21
- Readline 8.1
- OpenSSL 3.0.4
