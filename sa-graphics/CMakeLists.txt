cmake_minimum_required(VERSION 3.16)
project(sa_graphics LANGUAGES NONE)

set(SA_GRAPHICS_IMPORT_ROOT "${CMAKE_CURRENT_SOURCE_DIR}")

add_library(sa_graphics INTERFACE)
set_target_properties(sa_graphics PROPERTIES
    INTERFACE_SA_GRAPHICS_QML_DIR "${SA_GRAPHICS_IMPORT_ROOT}"
)
