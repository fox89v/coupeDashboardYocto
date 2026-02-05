cmake_minimum_required(VERSION 3.21)
project(sa LANGUAGES CXX)

include(GNUInstallDirs)

# Path per tooling/editor: punta al qml installato (lib o lib64, dipende dal kit)
set(QML_IMPORT_PATH
    "${CMAKE_INSTALL_FULL_LIBDIR}/qml"
    CACHE STRING "" FORCE)

set(QML2_IMPORT_PATH
    "${CMAKE_INSTALL_FULL_LIBDIR}/qml"
    CACHE STRING "" FORCE)

# SOLO codice, niente Yocto
add_subdirectory(meta-sa/recipes-qt/qmllib/files)
add_subdirectory(meta-sa/recipes-qt/sapp/files)
