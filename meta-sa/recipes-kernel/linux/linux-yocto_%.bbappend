FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI += "file://disable-md-raid.cfg"
KERNEL_CONFIG_FRAGMENTS += "file://disable-md-raid.cfg"
