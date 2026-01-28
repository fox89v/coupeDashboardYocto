FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI += "file://disable-md-raid.cfg \
            file://disable-md-raid.scc"

KERNEL_FEATURES:append = " cfg/disable-md-raid.scc"

do_kernel_configme:prepend() {
    bbnote "KERNEL_FEATURES=${KERNEL_FEATURES}"
}

do_kernel_configcheck:append() {
    if [ ! -e ${B}/.config ]; then
        bbfatal "Kernel .config missing; cannot verify RAID6/MD settings."
    fi

    if grep -qE "^CONFIG_RAID6_PQ=[my]" ${B}/.config; then
        bbfatal "CONFIG_RAID6_PQ is still enabled in the final kernel .config."
    fi
}
