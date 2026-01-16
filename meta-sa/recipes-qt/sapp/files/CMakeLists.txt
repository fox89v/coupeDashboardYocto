cmake_minimum_required(VERSION 3.16)
project(sapp LANGUAGES CXX)

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
)

qt_import_qml_plugins(sapp)

install(TARGETS sapp RUNTIME DESTINATION bin)
