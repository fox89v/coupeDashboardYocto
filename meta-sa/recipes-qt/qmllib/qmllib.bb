SUMMARY = "Sa.Graphics QML module (QML + C++ plugin + utils)"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI = " \
    file://CMakeLists.txt \
    file://Sa/Graphics/qmldir \
    file://Sa/Graphics/MyCircularGauge.qml \
    file://Sa/Graphics/GraphicsUtils.h \
    file://Sa/Graphics/GraphicsUtils.cpp \
"

S = "${WORKDIR}"

inherit qt6-cmake

DEPENDS += "qtbase qtdeclarative qtbase-native qtdeclarative-native"
RDEPENDS:${PN} += "qtdeclarative-qmlplugins"


FILES:${PN} += "${libdir}/qml/Sa"
FILES:${PN}-dev += "${includedir}/Sa"

# opzionale: silenzia il warning "buildpaths" nel pacchetto -src
INSANE_SKIP:${PN}-src += "buildpaths"
