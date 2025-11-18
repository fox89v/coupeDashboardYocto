FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI += "file://busybox.cfg"

# forza busybox a ricompilarsi con il nuovo config
do_configure:append() {
    install -m 0644 ${WORKDIR}/busybox.cfg ${S}/.config
}
