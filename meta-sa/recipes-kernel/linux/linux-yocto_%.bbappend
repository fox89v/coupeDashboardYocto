FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI += "file://cfg/disable-md-raid.cfg \
            file://disable-md-raid.scc"

KERNEL_FEATURES:append = " disable-md-raid.scc"

do_kernel_configme:prepend() {
    bbnote "KERNEL_FEATURES=${KERNEL_FEATURES}"
}

python do_kernel_configcheck:append() {
    import re

    config_path = f"{d.getVar('B')}/.config"
    if not __import__("os").path.exists(config_path):
        bb.fatal("Kernel .config missing; cannot verify RAID6/MD settings.")

    with open(config_path, "r", encoding="utf-8") as config_file:
        config_data = config_file.read()

    if re.search(r"^CONFIG_RAID6_PQ=[my]$", config_data, re.MULTILINE):
        bb.fatal("CONFIG_RAID6_PQ is still enabled in the final kernel .config.")
}
