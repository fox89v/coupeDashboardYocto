SUMMARY = "Qt6 app with CMake"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI = "file://CMakeLists.txt \
           file://main.cpp \
           file://main.qml \
           file://resources.qrc"

S = "${WORKDIR}"

inherit qt6-cmake

# 🔧 dipendenze necessarie per Quick e QuickTools
DEPENDS += "qtbase qtdeclarative qtshadertools qtmultimedia"

# 🔍 forza il path cmake nel sysroot corretto
EXTRA_OECMAKE += "-DCMAKE_PREFIX_PATH=${STAGING_DIR_TARGET}/usr/lib/cmake"

do_install() {
    install -d ${D}${bindir}
    install -m 0755 ${B}/app-qt ${D}${bindir}/
}
