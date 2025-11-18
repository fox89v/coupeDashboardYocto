cmake_minimum_required(VERSION 3.16)
project(app-qt LANGUAGES CXX)

set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_AUTOUIC ON)

find_package(Qt6 REQUIRED COMPONENTS Gui Qml Quick)

add_executable(app-qt
    main.cpp
    resources.qrc
)

target_link_libraries(app-qt
    PRIVATE Qt6::Gui Qt6::Qml Qt6::Quick
)
install(TARGETS app-qt RUNTIME DESTINATION usr/bin)

