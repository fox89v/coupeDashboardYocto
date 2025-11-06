SUMMARY = "Minimal image (fast boot, EGL test, autostart)"
LICENSE = "MIT"

inherit core-image

# ────────────────────────────────────────────────
# 🧩 Base image — essenziale e veloce
# ────────────────────────────────────────────────
IMAGE_FEATURES = ""
IMAGE_FEATURES:remove = "splash package-management debug-tweaks"

IMAGE_INSTALL = " \
    busybox \
    base-files \
    base-passwd \
    netbase \
    udev \
    dropbear \
    egltest \
    mesa \
    kmscube \
"

IMAGE_LINGUAS = "en-us"

# ────────────────────────────────────────────────
# 🧾 Info EGL (opzionale)
# ────────────────────────────────────────────────
ROOTFS_POSTPROCESS_COMMAND += "egl_check_install; "

egl_check_install() {
    install -d ${IMAGE_ROOTFS}/etc/profile.d
    cat << 'EOF' > ${IMAGE_ROOTFS}/etc/profile.d/eglcheck.sh
#!/bin/sh
echo ""
echo "[EGL] Renderer info:"
eglinfo 2>/dev/null | grep -E "Device|Vendor|Version" || echo "EGL check failed."
echo ""
EOF
    chmod +x ${IMAGE_ROOTFS}/etc/profile.d/eglcheck.sh
}


# ────────────────────────────────────────────────
# ⚙️ QEMU tuning (emulazione Pi4)
# ────────────────────────────────────────────────
QB_SYSTEM_NAME = "qemu-system-aarch64"
QB_MACHINE = "virt"
QB_CPU = "cortex-a72"
QB_MEM = "1024"
QB_DISPLAY_OPT = "-device virtio-gpu-pci -display sdl"
QB_USB_OPT = "-device qemu-xhci -device usb-tablet -device usb-kbd"
QB_NETWORK_DEVICE = "virtio-net-pci"
QB_NET_OPT = "-netdev user,id=net0,hostfwd=tcp::2222-:22 -device virtio-net-pci,netdev=net0"
QB_DRIVE_TYPE = "virtio"
QB_KERNEL_CMDLINE_APPEND = "console=ttyAMA0 console=tty0 root=/dev/vda rw mem=1024M net.ifnames=0 quiet loglevel=0 vt.global_cursor_default=0"

# ────────────────────────────────────────────────
# 🚀 Boot diretto in kmscube (senza systemd)
# ────────────────────────────────────────────────
ROOTFS_POSTPROCESS_COMMAND += "replace_init_with_kmscube; "

replace_init_with_kmscube() {
    # rinomina systemd per sicurezza
    mv ${IMAGE_ROOTFS}/sbin/init ${IMAGE_ROOTFS}/sbin/init.orig || true

    # crea init minimale che lancia kmscube
    cat << 'EOF' > ${IMAGE_ROOTFS}/sbin/init
#!/bin/sh
mount -t proc none /proc
mount -t sysfs none /sys
mount -t devtmpfs none /dev
echo "🚀 Starting kmscube..."
/usr/bin/kmscube
echo "💀 kmscube exited, dropping to shell"
/bin/sh
EOF
    chmod +x ${IMAGE_ROOTFS}/sbin/init
}

# ────────────────────────────────────────────────
# 🧠 Qt Core base — nessuna GUI, solo fondamenti
# ────────────────────────────────────────────────
IMAGE_INSTALL:append = " qtbase"
