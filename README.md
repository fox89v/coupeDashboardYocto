# 🧱 Yocto Builder

[![License](https://img.shields.io/badge/License-MIT-blue)]()  
[![Platform](https://img.shields.io/badge/Platform-Linux-lightgrey)]()  
[![Language](https://img.shields.io/badge/Written%20in-Bash-orange)]()  

Minimal interactive environment to build and run **Yocto images** for **Raspberry Pi 4** and **QEMU ARM64**.

---

## 🚀 Overview

This repository provides a **stand-alone shell script (`yocto.sh`)** that automates Yocto setup, build, and testing.  
It clones the required layers, configures the environment, builds a minimal custom image, and can directly run it in QEMU.

---

## ⚙️ Features

- ✅ Host dependency check  
- 🧩 Automatic layer setup (`poky`, `meta-openembedded`, `meta-raspberrypi`)  
- 🪄 Automatic creation of a minimal `meta-sa` layer if missing  
- 🏗️ Build of a lightweight image (`sa-image-minimal`)  
- 💽 Direct QEMU boot (ARM64, headless)  
- 🧰 SDK generation via `populate_sdk`

---

## 🧩 Requirements

Linux host (Ubuntu/Debian recommended):

```bash
sudo apt update
sudo apt install -y git gawk wget diffstat unzip texinfo gcc g++ make cmake chrpath cpio python3 python3-pip python3-pexpect xz-utils debianutils iputils-ping libsdl1.2-dev xterm qemu-system-arm qemu-user-static cpulimit
```

---

## 💡 Usage

Clone or download this repository and run:

```bash
chmod +x yocto.sh
./yocto.sh
```

### Interactive Menu

| Option | Description |
|:------:|:-------------|
| 1️⃣ | Configure project (clone & prepare layers) |
| 2️⃣ | Build custom image (`sa-image-minimal`) |
| 3️⃣ | Run QEMU (if image exists) |
| 4️⃣ | Build SDK (`populate_sdk`) |
| 5️⃣ | Exit |

---

## 📁 Directory Structure

```
yocto/
 ├── poky/
 ├── meta-openembedded/
 ├── meta-raspberrypi/
 ├── meta-sa/
 ├── downloads/
 ├── sstate-cache/
 ├── build-qemu/
 ├── build-rpi4/
 └── yocto.sh
```

---

## 🧠 Notes

- Default image: `sa-image-minimal` (BusyBox + Dropbear + basic networking)  
- The `meta-sa` layer is auto-generated if missing  
- QEMU runs in `nographic` mode using `slirp` networking (serial console only)

---

## 🧰 Roadmap

- Add `meta-qt6` integration for static Qt builds  
- Enable EGLFS/framebuffer support  
- Add Raspberry Pi 4 flash helper  
- Provide prebuilt SDK releases  

---

## 📄 License

MIT License — free to use and modify.
