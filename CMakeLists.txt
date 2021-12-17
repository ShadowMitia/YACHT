cmake_minimum_required(VERSION 3.4)

# A ... written in C++,
# for ...
project(Cpp_base_project
    VERSION 1.0.0
    LANGUAGES CXX C)
set(CMAKE_CXX_STANDARD 11)
include(${PROJECT_SOURCE_DIR}/cmake/flags.cmake) # will containe most default flags
include(${PROJECT_SOURCE_DIR}/cmake/asan.cmake) 
include(${PROJECT_SOURCE_DIR}/cmake/cppcheck.cmake)

# customizable flags for each build and compiler.
#set_flag(COMPILER clang gnu intel TARGET release relwithdebinfo FLAGS -O3 -march=native)
#set_flag(COMPILER clang gnu intel FLAGS -fexceptions -fopenmp)
#set_flag(COMPILER msvc FLAGS /openmp)
#set_flag(COMPILER clang FLAGS -stdlib=libc++)

include_directories("${PROJECT_SOURCE_DIR}/src")
#add_subdirectory("${PROJECT_SOURCE_DIR}/src")

add_executable(main "src/main.cpp")
#target_link_libraries(main PUBLIC [LIB])
#target_include_directories(main PUBLIC "${PROJECT_SOURCE_DIR}/external/utils")
#target_include_directories(main SYSTEM PUBLIC "${PROJECT_SOURCE_DIR}/external/[NAME]"
#                                       PUBLIC "${PROJECT_SOURCE_DIR}/external/[NAME]")
