#!/bin/sh
mount -t proc none /proc
mount -t sysfs none /sys
mount -t devtmpfs none /dev

echo "Starting app-qt..."
/usr/bin/app-qt

echo "App exited, entering debug shell"
/bin/sh
