cmake_minimum_required(VERSION 3.21)

find_package(Qt6 REQUIRED COMPONENTS Qml Quick)
qt_standard_project_setup()

set(QT_QML_ENABLE_QMLLINT OFF)

qt_add_library(sa_graphics_module SHARED)

qt_add_qml_module(sa_graphics_module
    URI Sa.Graphics
    VERSION 1.0
    QML_FILES
        Sa/Graphics/MyCircularGauge.qml
    SOURCES
        Sa/Graphics/graphicsplugin.cpp
        Sa/Graphics/graphicsplugin.h
)

include(GNUInstallDirs)

install(TARGETS sa_graphics_module
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}/qml/Sa/Graphics
)

install(FILES
    ${CMAKE_CURRENT_SOURCE_DIR}/Sa/Graphics/qmldir
    ${CMAKE_CURRENT_SOURCE_DIR}/Sa/Graphics/MyCircularGauge.qml
    DESTINATION ${CMAKE_INSTALL_LIBDIR}/qml/Sa/Graphics
)
