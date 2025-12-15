cmake_minimum_required(VERSION 3.16)
project(app-qt LANGUAGES CXX)

set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_AUTOUIC ON)

find_package(Qt6 REQUIRED COMPONENTS Gui Qml Quick)

if(NOT TARGET sa_graphics)
    add_library(sa_graphics INTERFACE)
    set_target_properties(sa_graphics PROPERTIES
        INTERFACE_SA_GRAPHICS_QML_DIR "${QT6_INSTALL_QMLDIR}")
endif()

add_executable(app-qt
    main.cpp
    datahub.cpp
    measure.cpp
    resources.qrc
)

target_link_libraries(app-qt
    PRIVATE Qt6::Gui Qt6::Qml Qt6::Quick sa_graphics
)

get_target_property(SA_GRAPHICS_QML_DIR sa_graphics INTERFACE_SA_GRAPHICS_QML_DIR)
if(NOT SA_GRAPHICS_QML_DIR)
    set(SA_GRAPHICS_QML_DIR "${QT6_INSTALL_QMLDIR}")
endif()

target_compile_definitions(app-qt
    PRIVATE SA_GRAPHICS_QML_IMPORT_PATH="${SA_GRAPHICS_QML_DIR}"
)
install(TARGETS app-qt RUNTIME DESTINATION /usr/bin)

