cmake_minimum_required(VERSION 3.21)

find_package(Qt6 REQUIRED COMPONENTS Qml Quick)
qt_standard_project_setup()

set(QT_QML_ENABLE_QMLLINT OFF)

include(GNUInstallDirs)

qt_add_library(sa_graphics_module SHARED)

set_target_properties(sa_graphics_module PROPERTIES
  VERSION 1.0.0
  SOVERSION 1
)

qt_add_qml_module(sa_graphics_module
    URI Sa.Graphics
    VERSION 1.0
    QML_FILES
        Sa/Graphics/MyCircularGauge.qml
    SOURCES
        Sa/Graphics/GraphicsUtils.h
        Sa/Graphics/GraphicsUtils.cpp
)

target_include_directories(sa_graphics_module
  PUBLIC
    ${CMAKE_CURRENT_SOURCE_DIR}
  PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}/Sa/Graphics
)

# Lib linkabile (per C++)
install(TARGETS sa_graphics_module
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
)

# Plugin QML (deve stare nel modulo QML)
install(TARGETS sa_graphics_moduleplugin
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}/qml/Sa/Graphics
)

# QML module files
install(FILES
    ${CMAKE_CURRENT_SOURCE_DIR}/Sa/Graphics/qmldir
    ${CMAKE_CURRENT_SOURCE_DIR}/Sa/Graphics/MyCircularGauge.qml
    DESTINATION ${CMAKE_INSTALL_LIBDIR}/qml/Sa/Graphics
)

# Header per uso C++ da altre app/recipe (es. sapp)
install(FILES
    ${CMAKE_CURRENT_SOURCE_DIR}/Sa/Graphics/GraphicsUtils.h
    DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/Sa/Graphics
)
