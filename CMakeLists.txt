cmake_minimum_required(VERSION 3.4)

# A ... written in C++,
# for ...
project(Cpp_base_project
    VERSION 1.0.0
    LANGUAGES CXX C)
set(CMAKE_CXX_STANDARD 11)

### TOOLS ###
include(${PROJECT_SOURCE_DIR}/cmake/load_config.cmake)
include(${PROJECT_SOURCE_DIR}/cmake/load_tools.cmake)

### COMPILER FLAG MANAGER ###
include(${PROJECT_SOURCE_DIR}/cmake/flags.cmake) # will containe most default flags
# customizable flags for each build and compiler.
# set_flag(COMPILER clang gnu intel TARGET release relwithdebinfo FLAGS -O3 -march=native)
# set_flag(COMPILER clang gnu intel FLAGS -fexceptions -fopenmp)
# set_flag(COMPILER msvc FLAGS /openmp)
# set_flag(COMPILER clang FLAGS -stdlib=libc++)

### CONAN PACKAGE MANAGER ###
include(${PROJECT_SOURCE_DIR}/cmake/conan.cmake)
# conan_get_from_file() # you can load from a conanfile.txt or conanfile.py in the root directory.
conan_get_package(PACKAGE gtest/1.11.0 eigen/3.4.0 catch2/2.13.7) # or directly from cmake

### VCPKG PACKAGE MANAGER ###
include(${PROJECT_SOURCE_DIR}/cmake/vcpkg.cmake)
vcpkg_get_package(PACKAGE Gtest Eigen3 Catch2) # you can load packages directly from cmake.

### LIBS ###
# find_package(Eigen3 CONFIG REQUIRED)

### SOURCE & INCLUDES ###
include_directories("${PROJECT_SOURCE_DIR}/src")
# add_subdirectory("${PROJECT_SOURCE_DIR}/src")

add_executable(main "src/main.cpp")
# target_link_libraries(main Eigen3::Eigen)
# target_include_directories(main PUBLIC "${PROJECT_SOURCE_DIR}/external/utils")
# target_include_directories(main SYSTEM PUBLIC "${PROJECT_SOURCE_DIR}/external/[NAME]"
#                                        PUBLIC "${PROJECT_SOURCE_DIR}/external/[NAME]")

### TESTS ###
gtest_add_test(NAME gtest_example SOURCES ./tests/gtest_example.cpp)
catch2_add_test(NAME catch2_example SOURCES ./tests/catch2_example.cpp)
# target_link_libraries(gtest_example Eigen3::Eigen) # you can link targets from the {NAME}_add_test functions
