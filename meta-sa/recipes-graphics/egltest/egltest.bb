SUMMARY = "Simple EGL/OpenGL ES2 test application"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

SRC_URI = "file://egltest.c"

S = "${WORKDIR}"

DEPENDS = "virtual/egl virtual/libgles2"

do_compile() {
    ${CC} ${CFLAGS} ${LDFLAGS} -o egltest egltest.c -lEGL -lGLESv2 -lm
}

do_install() {
    install -d ${D}${bindir}
    install -m 0755 egltest ${D}${bindir}/egltest
}
