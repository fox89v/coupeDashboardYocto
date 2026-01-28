FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI += "file://disable-md-raid.cfg"
KERNEL_CONFIG_FRAGMENTS += "file://disable-md-raid.cfg"

do_configure:append() {
    if [ ! -e ${B}/.config ]; then
        bbfatal "Kernel .config missing; cannot verify RAID6/MD settings."
    fi

    if [ -x ${S}/scripts/config ]; then
        config_updated=0

        if grep -qE "^(CONFIG_MD=|# CONFIG_MD is not set)" ${B}/.config; then
            ${S}/scripts/config --file ${B}/.config --disable MD
            config_updated=1
        fi

        if grep -qE "^(CONFIG_BLK_DEV_MD=|# CONFIG_BLK_DEV_MD is not set)" ${B}/.config; then
            ${S}/scripts/config --file ${B}/.config --disable BLK_DEV_MD
            config_updated=1
        fi

        if grep -qE "^(CONFIG_DM_RAID=|# CONFIG_DM_RAID is not set)" ${B}/.config; then
            ${S}/scripts/config --file ${B}/.config --disable DM_RAID
            config_updated=1
        fi

        if [ ${config_updated} -eq 1 ]; then
            yes "" | oe_runmake olddefconfig
        fi
    fi

    if grep -qE "^CONFIG_RAID6_PQ=[my]" ${B}/.config; then
        bbfatal "CONFIG_RAID6_PQ is still enabled in the final kernel .config."
    fi
}
