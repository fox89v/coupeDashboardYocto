SUMMARY = "Sa.Graphics QML-only module providing the MyCircularGauge component"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI = " \
    file://CMakeLists.txt \
    file://Sa/Graphics/qmldir \
    file://Sa/Graphics/MyCircularGauge.qml \
    file://Sa/Graphics/graphicsplugin.cpp \
    file://Sa/Graphics/graphicsplugin.h \
"

S = "${WORKDIR}"

inherit qt6-cmake

DEPENDS += "qtbase qtdeclarative qtbase-native qtdeclarative-native"
RDEPENDS:${PN} += "qtdeclarative-qmlplugins"

do_install:append() {
    install -d ${D}${libdir}/qml/Sa/Graphics
    install -m 0644 ${S}/Sa/Graphics/qmldir \
        ${D}${libdir}/qml/Sa/Graphics/qmldir
    install -m 0644 ${S}/Sa/Graphics/MyCircularGauge.qml \
        ${D}${libdir}/qml/Sa/Graphics/MyCircularGauge.qml
    if [ -f ${B}/libsa_graphics_moduleplugin.so ]; then
        install -m 0755 ${B}/libsa_graphics_moduleplugin.so \
            ${D}${libdir}/qml/Sa/Graphics/libsa_graphics_moduleplugin.so
    fi
    if [ -f ${B}/libsa_graphics_module.so ]; then
        install -m 0755 ${B}/libsa_graphics_module.so \
            ${D}${libdir}/qml/Sa/Graphics/libsa_graphics_module.so
    fi
}

FILES:${PN} += "${libdir}/qml/Sa"
