SUMMARY = "Minimal image with root autologin + EGL test"
LICENSE = "MIT"

inherit core-image

# ────────────────────────────────────────────────
# 🧩 Base image setup
# ────────────────────────────────────────────────
IMAGE_FEATURES += "splash package-management debug-tweaks"

IMAGE_INSTALL += " \
    busybox \
    base-files \
    base-passwd \
    netbase \
    dropbear \
"

IMAGE_LINGUAS = "en-us"

# ────────────────────────────────────────────────
# 👤 Enable root autologin on serial console
# ────────────────────────────────────────────────
ROOTFS_POSTPROCESS_COMMAND += "enable_root_autologin; egl_check_install; "

enable_root_autologin() {
    mkdir -p ${IMAGE_ROOTFS}/etc/systemd/system/serial-getty@ttyAMA0.service.d
    cat << 'EOT' > ${IMAGE_ROOTFS}/etc/systemd/system/serial-getty@ttyAMA0.service.d/autologin.conf
[Service]
ExecStart=
ExecStart=-/sbin/agetty --autologin root --noclear %I $TERM
EOT
}

# ────────────────────────────────────────────────
# 🧠 Add EGL/OpenGL test tools
# ────────────────────────────────────────────────
IMAGE_INSTALL:append = " \
    egltest \
    mesa \
    mesa-dev \
    kmscube \
"
# ────────────────────────────────────────────────
# 🧾 Auto EGL info on login
# ────────────────────────────────────────────────
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
# 🧩 QEMU boot tuning — emulate Pi4-like system
# ────────────────────────────────────────────────
QB_SYSTEM_NAME = "qemu-system-aarch64"
QB_MACHINE = "virt"
QB_CPU = "cortex-a72"
QB_MEM = "1024"

# enable GPU and SDL window (software rendered)
QB_DISPLAY_OPT = "-device virtio-gpu-pci -display sdl"

# enable USB + tablet input (mouse)
QB_USB_OPT = "-device qemu-xhci -device usb-tablet -device usb-kbd"

# networking with slirp (no tap needed)
QB_NETWORK_DEVICE = "virtio-net-pci"
QB_NET_OPT = "-netdev user,id=net0,hostfwd=tcp::2222-:22 -device virtio-net-pci,netdev=net0"

# rootfs append string
QB_KERNEL_CMDLINE_APPEND = "console=ttyAMA0 root=/dev/vda rw mem=1024M net.ifnames=0"

# use virtio block for rootfs
QB_DRIVE_TYPE = "virtio"
