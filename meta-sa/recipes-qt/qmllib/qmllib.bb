SUMMARY = "Sa.Graphics QML-only module providing the MyCircularGauge component"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI = "file://qmldir \
           file://MyCircularGauge.qml \
"

S = "${WORKDIR}"

inherit allarch

DEPENDS += "qtdeclarative"
RDEPENDS:${PN} += "qtdeclarative-qmlplugins"

do_install() {
    install -d ${D}${libdir}/qml/Sa/Graphics
    install -m 0644 ${WORKDIR}/qmldir ${D}${libdir}/qml/Sa/Graphics/qmldir
    install -m 0644 ${WORKDIR}/MyCircularGauge.qml ${D}${libdir}/qml/Sa/Graphics/MyCircularGauge.qml
}

FILES:${PN} += "${libdir}/qml/Sa"
