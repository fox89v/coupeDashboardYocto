# 🧰 Configurazione Kit Qt Creator (QEMU ARM64 – Yocto SDK)

## 1. Compiler

**C Compiler**

/opt/youngtimer-sdk/oecore-meta-toolchain-x86_64-cortexa57-qemuarm64-toolchain-nodistro.0/sysroots/x86_64-oesdk-linux/usr/bin/aarch64-oe-linux-musl/aarch64-oe-linux-musl-gcc

**C++ Compiler**

/opt/youngtimer-sdk/oecore-meta-toolchain-x86_64-cortexa57-qemuarm64-toolchain-nodistro.0/sysroots/x86_64-oesdk-linux/usr/bin/aarch64-oe-linux-musl/aarch64-oe-linux-musl-g++

---

## 2. Debugger

/opt/youngtimer-sdk/oecore-meta-toolchain-x86_64-cortexa57-qemuarm64-toolchain-nodistro.0/sysroots/x86_64-oesdk-linux/usr/bin/aarch64-oe-linux-musl/aarch64-oe-linux-musl-gdb

---

## 3. CMake

/opt/youngtimer-sdk/oecore-meta-toolchain-x86_64-cortexa57-qemuarm64-toolchain-nodistro.0/sysroots/x86_64-oesdk-linux/usr/bin/cmake

---

## 4. CMake Configuration  
*(Project → Build Settings → CMake → CMake Configuration)*

Aggiungi queste voci:

CMAKE_TOOLCHAIN_FILE:FILEPATH=/opt/youngtimer-sdk/oecore-meta-toolchain-x86_64-cortexa57-qemuarm64-toolchain-nodistro.0/sysroots/x86_64-oesdk-linux/usr/share/cmake/OEToolchainConfig.cmake
CMAKE_PREFIX_PATH:PATH=/opt/youngtimer-sdk/oecore-meta-toolchain-x86_64-cortexa57-qemuarm64-toolchain-nodistro.0/sysroots/cortexa57-oe-linux-musl/usr/lib/cmake

---

## 5. Environment del Kit  
*(Tools → Options → Kits → Environment → Batch Edit)*

CC=aarch64-oe-linux-musl-gcc  -mcpu=cortex-a57+crc -mbranch-protection=standard --sysroot=/opt/youngtimer-sdk/oecore-meta-toolchain-x86_64-cortexa57-qemuarm64-toolchain-nodistro.0/sysroots/cortexa57-oe-linux-musl
CXX=aarch64-oe-linux-musl-g++  -mcpu=cortex-a57+crc -mbranch-protection=standard --sysroot=/opt/youngtimer-sdk/oecore-meta-toolchain-x86_64-cortexa57-qemuarm64-toolchain-nodistro.0/sysroots/cortexa57-oe-linux-musl
AR=/opt/youngtimer-sdk/oecore-meta-toolchain-x86_64-cortexa57-qemuarm64-toolchain-nodistro.0/sysroots/x86_64-oesdk-linux/usr/bin/aarch64-oe-linux-musl/aarch64-oe-linux-musl-ar
RANLIB=/opt/youngtimer-sdk/oecore-meta-toolchain-x86_64-cortexa57-qemuarm64-toolchain-nodistro.0/sysroots/x86_64-oesdk-linux/usr/bin/aarch64-oe-linux-musl/aarch64-oe-linux-musl-ranlib
STRIP=/opt/youngtimer-sdk/oecore-meta-toolchain-x86_64-cortexa57-qemuarm64-toolchain-nodistro.0/sysroots/x86_64-oesdk-linux/usr/bin/aarch64-oe-linux-musl/aarch64-oe-linux-musl-strip
OBJCOPY=/opt/youngtimer-sdk/oecore-meta-toolchain-x86_64-cortexa57-qemuarm64-toolchain-nodistro.0/sysroots/x86_64-oesdk-linux/usr/bin/aarch64-oe-linux-musl/aarch64-oe-linux-musl-objcopy
OBJDUMP=/opt/youngtimer-sdk/oecore-meta-toolchain-x86_64-cortexa57-qemuarm64-toolchain-nodistro.0/sysroots/x86_64-oesdk-linux/usr/bin/aarch64-oe-linux-musl/aarch64-oe-linux-musl-objdump
READELF=/opt/youngtimer-sdk/oecore-meta-toolchain-x86_64-cortexa57-qemuarm64-toolchain-nodistro.0/sysroots/x86_64-oesdk-linux/usr/bin/aarch64-oe-linux-musl/aarch64-oe-linux-musl-readelf
NM=/opt/youngtimer-sdk/oecore-meta-toolchain-x86_64-cortexa57-qemuarm64-toolchain-nodistro.0/sysroots/x86_64-oesdk-linux/usr/bin/aarch64-oe-linux-musl/aarch64-oe-linux-musl-nm
OECORE_TARGET_SYSROOT=/opt/youngtimer-sdk/oecore-meta-toolchain-x86_64-cortexa57-qemuarm64-toolchain-nodistro.0/sysroots/cortexa57-oe-linux-musl
OECORE_NATIVE_SYSROOT=
PKG_CONFIG_PATH=/opt/youngtimer-sdk/oecore-meta-toolchain-x86_64-cortexa57-qemuarm64-toolchain-nodistro.0/sysroots/cortexa57-oe-linux-musl/usr/lib/pkgconfig:/opt/youngtimer-sdk/oecore-meta-toolchain-x86_64-cortexa57-qemuarm64-toolchain-nodistro.0/sysroots/cortexa57-oe-linux-musl/usr/share/pkgconfig
PKG_CONFIG_SYSROOT_DIR=/opt/youngtimer-sdk/oecore-meta-toolchain-x86_64-cortexa57-qemuarm64-toolchain-nodistro.0/sysroots/cortexa57-oe-linux-musl
CMAKE_PREFIX_PATH=
PATH=/opt/youngtimer-sdk/x86_64-buildtools-extended-nativesdk-standalone-nodistro.0/sysroots/x86_64-oesdk-linux/usr/bin:/opt/youngtimer-sdk/x86_64-buildtools-extended-nativesdk-standalone-nodistro.0/sysroots/x86_64-oesdk-linux/usr/sbin:/opt/youngtimer-sdk/x86_64-buildtools-extended-nativesdk-standalone-nodistro.0/sysroots/x86_64-oesdk-linux/bin:/opt/youngtimer-sdk/x86_64-buildtools-extended-nativesdk-standalone-nodistro.0/sysroots/x86_64-oesdk-linux/sbin:/opt/youngtimer-sdk/oecore-meta-toolchain-x86_64-cortexa57-qemuarm64-toolchain-nodistro.0/sysroots/x86_64-oesdk-linux/usr/bin:/opt/youngtimer-sdk/oecore-meta-toolchain-x86_64-cortexa57-qemuarm64-toolchain-nodistro.0/sysroots/x86_64-oesdk-linux/usr/sbin:/opt/youngtimer-sdk/oecore-meta-toolchain-x86_64-cortexa57-qemuarm64-toolchain-nodistro.0/sysroots/x86_64-oesdk-linux/bin:/opt/youngtimer-sdk/oecore-meta-toolchain-x86_64-cortexa57-qemuarm64-toolchain-nodistro.0/sysroots/x86_64-oesdk-linux/sbin:/opt/youngtimer-sdk/oecore-meta-toolchain-x86_64-cortexa57-qemuarm64-toolchain-nodistro.0/sysroots/x86_64-oesdk-linux/usr/bin/../x86_64-oesdk-linux/bin:/opt/youngtimer-sdk/oecore-meta-toolchain-x86_64-cortexa57-qemuarm64-toolchain-nodistro.0/sysroots/x86_64-oesdk-linux/usr/bin/aarch64-oe-linux-musl:/opt/youngtimer-sdk/oecore-meta-toolchain-x86_64-cortexa57-qemuarm64-toolchain-nodistro.0/sysroots/x86_64-oesdk-linux/usr/bin/aarch64-oe-linux-musl:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin
QT_HOST_PATH=/home/fox/Qt/6.7.3/gcc_64
QT_HOST_PATH_CMAKE_DIR=/home/fox/Qt/6.7.3/gcc_64/lib/cmake

