cmake_minimum_required(VERSION 3.21)
project(sa LANGUAGES CXX)

set(QML_IMPORT_PATH
    "${CMAKE_SOURCE_DIR}/meta-sa/recipes-qt/qmllib/files"
    CACHE STRING "" FORCE
)
# SOLO codice, niente Yocto
add_subdirectory(meta-sa/recipes-qt/qmllib/files)
add_subdirectory(meta-sa/recipes-qt/sapp/files)
