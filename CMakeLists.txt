cmake_minimum_required(VERSION 3.21)
project(sa LANGUAGES CXX)


# SOLO codice, niente Yocto
add_subdirectory(meta-sa/recipes-qt/qmllib/files)
add_subdirectory(meta-sa/recipes-qt/sapp/files)
