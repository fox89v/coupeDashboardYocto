SUMMARY = "Minimal image (Qt + fonts, QEMU virt)"
LICENSE = "MIT"

inherit core-image

# --- Base minimale ---
IMAGE_FEATURES = ""
IMAGE_FEATURES:remove = "splash package-management debug-tweaks"

IMAGE_INSTALL = " \
    busybox base-files base-passwd netbase udev dropbear \
    mesa \
"

# --- Rimozioni inutili ---
IMAGE_INSTALL:remove = "qtquick3d qtquick3d-dev qtquick3d-native qtquick3d-qmlplugins openssl"

IMAGE_LINGUAS = "en-us"

# --- Qt (runtime + dev + static) + font ---
IMAGE_INSTALL:append = " \
    qtbase qtdeclarative \
    fontconfig \
    ttf-dejavu-sans ttf-dejavu-sans-mono ttf-dejavu-serif \
    qtbase-dev \
    qtdeclarative-dev \
    qtdeclarative-staticdev \
    qtmultimedia-dev \
"

# --- QEMU (virt emulation) ---
QB_SYSTEM_NAME  = "qemu-system-aarch64"
QB_MACHINE      = "virt"
QB_CPU          = "cortex-a72"
QB_MEM          = "1024"
QB_DISPLAY_OPT  = "-device virtio-gpu-pci -display sdl"
QB_USB_OPT      = "-device qemu-xhci -device usb-tablet -device usb-kbd"
QB_NETWORK_DEVICE = "virtio-net-pci"
QB_NET_OPT      = "-netdev user,id=net0,hostfwd=tcp::2222-:22 -device virtio-net-pci,netdev=net0"
QB_DRIVE_TYPE   = "virtio"
QB_KERNEL_CMDLINE_APPEND = "console=ttyAMA0 console=tty0 root=/dev/vda rw mem=1024M net.ifnames=0 quiet loglevel=0 vt.global_cursor_default=0"

# --- Qt tools per SDK (host: moc, rcc, qmlcachegen, ecc.) ---
TOOLCHAIN_HOST_TASK:append = " \
    nativesdk-packagegroup-qt6-toolchain-host \
"

