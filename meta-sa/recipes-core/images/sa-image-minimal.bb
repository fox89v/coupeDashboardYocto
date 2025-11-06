SUMMARY = "Minimal image with root autologin"
LICENSE = "MIT"

inherit core-image

IMAGE_FEATURES += "splash package-management debug-tweaks"

IMAGE_INSTALL += " \
    busybox \
    base-files \
    base-passwd \
    netbase \
    dropbear \
"

# Enable root autologin on serial console
ROOTFS_POSTPROCESS_COMMAND += "enable_root_autologin; "

enable_root_autologin() {
    mkdir -p ${IMAGE_ROOTFS}/etc/systemd/system/serial-getty@ttyAMA0.service.d
    cat << 'EOT' > ${IMAGE_ROOTFS}/etc/systemd/system/serial-getty@ttyAMA0.service.d/autologin.conf
[Service]
ExecStart=
ExecStart=-/sbin/agetty --autologin root --noclear %I $TERM
EOT
}

IMAGE_LINGUAS = "en-us"
