#!/bin/sh

###############################################################################
# 1) Base filesystem
###############################################################################
mount -t proc      proc      /proc
mount -t sysfs     sysfs     /sys
mount -t devtmpfs  devtmpfs  /dev
mount -t tmpfs     tmpfs     /run

mkdir -p /dev/pts
mount -t devpts    devpts    /dev/pts
mkdir -p /var/run

###############################################################################
# 2) Legge modalità da QEMU cmdline
#    DEV → SA_MODE=dev
###############################################################################
if grep -q "SA_MODE=dev" /proc/cmdline; then
    SA_MODE="dev"
else
    SA_MODE="prod"
fi

echo "[INIT] Mode: $SA_MODE"

###############################################################################
# 3) DEV MODE → debug, ssh, rete, permessi, niente autostart
###############################################################################
if [ "$SA_MODE" = "dev" ]; then
    echo "[INIT] DEV mode → enabling network + ssh + debug perms"

    # rete
    ip link set lo up
    ip link set eth0 up 2>/dev/null
    ip addr add 10.0.2.15/24 dev eth0 2>/dev/null
    ip route add default via 10.0.2.2 2>/dev/null

    # root senza password
    passwd -d root 2>/dev/null

    # ssh config
    grep -q "PermitRootLogin yes"       /etc/ssh/sshd_config || echo "PermitRootLogin yes" >> /etc/ssh/sshd_config
    grep -q "PasswordAuthentication yes" /etc/ssh/sshd_config || echo "PasswordAuthentication yes" >> /etc/ssh/sshd_config
    grep -q "PermitEmptyPasswords yes"   /etc/ssh/sshd_config || echo "PermitEmptyPasswords yes" >> /etc/ssh/sshd_config

    mkdir -p /var/run/sshd
    ssh-keygen -A 2>/dev/null
    /usr/sbin/sshd

    # drm/fb perms (comodità dev)
    chmod 666 /dev/dri/card0       2>/dev/null
    chmod 666 /dev/dri/renderD128  2>/dev/null
    chmod 666 /dev/fb0             2>/dev/null

    echo "[INIT] DEV mode → NOT starting sapp"
    exec /bin/sh
fi

###############################################################################
# 4) PROD MODE → avvio minimale
###############################################################################
echo "[INIT] PROD mode → starting sapp"

/usr/bin/sapp

# se l'app termina, fallback shell
exec /bin/sh
