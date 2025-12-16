SUMMARY = "Qt runtime package group"
LICENSE = "MIT"

inherit packagegroup

RDEPENDS:${PN} = " \
    qmllib \
    sapp \
"