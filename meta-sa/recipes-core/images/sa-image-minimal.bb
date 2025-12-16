SUMMARY = "Minimal image (Qt + OpenSSH + QEMU virt)"
LICENSE = "MIT"

inherit core-image

IMAGE_FEATURES = ""
IMAGE_FEATURES:remove = "splash package-management debug-tweaks"

IMAGE_LINGUAS = "en-us"

IMAGE_INSTALL = " \
    busybox base-files base-passwd netbase udev \
    fontconfig \
    ttf-dejavu-sans ttf-dejavu-sans-mono ttf-dejavu-serif \
    mesa \
    qtbase qtdeclarative \
    qtbase-dev qtdeclarative-dev qtdeclarative-staticdev \
    qtmultimedia-dev \
"

IMAGE_INSTALL:append = " packagegroups-sa-qt"

EXTRA_IMAGE_FEATURES += "ssh-server-openssh"
IMAGE_INSTALL:append = " openssh openssh-sftp-server openssh-keygen "
IMAGE_INSTALL:append = " rsync "

IMAGE_INSTALL:remove = "qtquick3d qtquick3d-dev qtquick3d-native qtquick3d-qmlplugins"

QB_SYSTEM_NAME  = "qemu-system-aarch64"
QB_MACHINE      = "virt"
QB_CPU          = "cortex-a72"
QB_MEM          = "1024"
QB_DISPLAY_OPT  = "-device virtio-gpu-pci -display sdl"
QB_USB_OPT      = "-device qemu-xhci -device usb-tablet -device usb-kbd"
QB_NET_OPT      = "-netdev user,id=net0,hostfwd=tcp::2222-:22 -device virtio-net-pci,netdev=net0"
QB_DRIVE_TYPE   = "virtio"
QB_KERNEL_CMDLINE_APPEND = "console=ttyAMA0 console=tty0 root=/dev/vda rw mem=1024M net.ifnames=0 quiet loglevel=0 vt.global_cursor_default=0"
