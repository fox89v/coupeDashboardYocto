SUMMARY = "Sa.Graphics QML components"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${WORKDIR}/LICENSE.txt;md5=ff01eebe6e035daabcce5c42b577ce65"

FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI = " \
    file://LICENSE.txt \
    file://Sa/Graphics/qmldir \
    file://Sa/Graphics/MyCircularGauge.qml \
"

S = "${WORKDIR}"

# QML-only module, no build step required
do_configure[noexec] = "1"
do_compile[noexec] = "1"

do_install() {
    install -d ${D}${libdir}/qt6/qml/Sa/Graphics
    install -m 0644 ${WORKDIR}/Sa/Graphics/qmldir ${D}${libdir}/qt6/qml/Sa/Graphics/
    install -m 0644 ${WORKDIR}/Sa/Graphics/MyCircularGauge.qml ${D}${libdir}/qt6/qml/Sa/Graphics/
}

FILES:${PN} += "${libdir}/qt6/qml/Sa"
