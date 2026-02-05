SUMMARY = "Qt runtime package group"
LICENSE = "MIT"

inherit packagegroup

PACKAGE_ARCH = "${MACHINE_ARCH}"

RDEPENDS:${PN} = " \
    qmllib \
    sapp \
"