SUMMARY = "Qt6 app with CMake"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI = "file://CMakeLists.txt \
           file://main.cpp \
           file://main.qml \
           file://resources.qrc \
           file://app-init.sh \
"

S = "${WORKDIR}"

inherit qt6-cmake

DEPENDS += "qtbase qtdeclarative qtdeclarative-native"

EXTRA_OECMAKE += "\
 -DCMAKE_PREFIX_PATH=${STAGING_LIBDIR}/cmake:${STAGING_LIBDIR_NATIVE}/cmake \
 -DQt6_DIR=${STAGING_LIBDIR}/cmake/Qt6 \
 -DQt6Qml_DIR=${STAGING_LIBDIR}/cmake/Qt6Qml \
 -DQt6QmlTools_DIR=${STAGING_LIBDIR_NATIVE}/cmake/Qt6QmlTools \
"

do_install() {
    install -d ${D}${bindir}
    install -m 0755 ${B}/sapp ${D}${bindir}/

    install -d ${D}/sbin
    install -m 0755 ${WORKDIR}/app-init.sh ${D}/sbin/init
}
