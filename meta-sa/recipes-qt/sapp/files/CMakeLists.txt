cmake_minimum_required(VERSION 3.21)
project(sapp LANGUAGES CXX)

include(GNUInstallDirs)

set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_AUTOUIC ON)

find_package(Qt6 REQUIRED COMPONENTS Gui Qml Quick)

add_executable(sapp
    main.cpp
    resources.qrc
)

target_link_libraries(sapp
    PRIVATE
        Qt6::Gui
        Qt6::Qml
        Qt6::Quick
        sa_graphics_module
)

qt_import_qml_plugins(sapp)

set_target_properties(sapp PROPERTIES
  INSTALL_RPATH "\$ORIGIN/../lib"
)

install(TARGETS sapp RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR})
