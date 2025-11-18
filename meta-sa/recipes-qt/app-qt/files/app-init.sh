#!/bin/sh

# base fs
mount -t proc proc /proc
mount -t sysfs sysfs /sys
mount -t devtmpfs devtmpfs /dev
mount -t tmpfs tmpfs /run
mkdir -p /dev/pts
mount -t devpts devpts /dev/pts
mkdir -p /var/run

# rete
ip link set lo up
ip link set eth0 up 2>/dev/null
ip addr add 10.0.2.15/24 dev eth0 2>/dev/null
ip route add default via 10.0.2.2 2>/dev/null

# root senza password
passwd -d root

# sshd config (solo se non c'è già)
grep -q "PermitRootLogin yes" /etc/ssh/sshd_config || echo "PermitRootLogin yes" >> /etc/ssh/sshd_config
grep -q "PasswordAuthentication yes" /etc/ssh/sshd_config || echo "PasswordAuthentication yes" >> /etc/ssh/sshd_config
grep -q "PermitEmptyPasswords yes" /etc/ssh/sshd_config || echo "PermitEmptyPasswords yes" >> /etc/ssh/sshd_config

mkdir -p /var/run/sshd
ssh-keygen -A
/usr/sbin/sshd

# app
/usr/bin/app-qt

# se l'app termina, lasciamo una shell
exec /bin/sh
