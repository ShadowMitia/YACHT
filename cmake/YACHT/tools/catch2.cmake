option(CATCH2_DOWNLOAD_IF_MISSING "download & build Catch2 if no existing build has been found" OFF)

macro(catch2_find)
    if (NOT catch2_was_found)
        message(STATUS "Catch2 was requested. Setting up...")

        enable_testing()
        include(${PROJECT_SOURCE_DIR}/cmake/tools/test_helper.cmake)

        set(find_catch2_cond "REQUIRED")
        if (CATCH2_DOWNLOAD_IF_MISSING)
            set(find_catch2_cond "QUIET")
        endif()
        find_package(Catch2 ${find_catch2_cond} HINTS ${CMAKE_BINARY_DIR})

        set(catch2_v3 OFF)
        if(Catch2_VERSION_MAJOR GREATER 2)
            set(catch2_v3 ON)
        endif()

        # if we can't find it with find_package, then we download a known version and populate it if the user has set CATCH2_DOWNLOAD_IF_MISSING
        if(NOT Catch2_FOUND)
            message(STATUS "Could not find an existing build of Catch2. Downloading & building sources...")

            Include(FetchContent)
            FetchContent_Declare(
              Catch2
              GIT_REPOSITORY https://github.com/catchorg/Catch2.git
              GIT_TAG        v3.0.0-preview3
            )
            set(catch2_v3 ON)

            # no docs please
            set(CATCH_INSTALL_DOCS CACHE INTERNAL OFF)
            FetchContent_MakeAvailable(Catch2)

            # ignore warnings when compiling catch2
            target_compile_options(Catch2WithMain PRIVATE -w)
            target_compile_options(Catch2 PRIVATE -w)

            # avoid compiling if not testing
            set_target_properties(Catch2 PROPERTIES EXCLUDE_FROM_ALL TRUE)
            set_target_properties(Catch2WithMain PROPERTIES EXCLUDE_FROM_ALL TRUE)
        else()
            message(STATUS "Found existing build of Catch2.")
        endif()

        message(STATUS "Using Catch2")

        set(catch2_was_found ON)
    endif()
endmacro()

macro(catch2_add_test)
    set(options NO_MAIN)
    set(oneValueArgs NAME)
    set(multiValueArgs SOURCES)
    cmake_parse_arguments(CATCH2_ADD_TEST "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN} )

    catch2_find()

    # add Catch2 main if the user has not requested NO_MAIN
    set(lib_catch2 "Catch2::Catch2WithMain")
    if (CATCH2_ADD_TEST_NO_MAIN OR NOT catch2_v3)
        set(lib_catch2 "Catch2::Catch2")
    endif()

    message(STATUS "Added Catch2 test: ${CATCH2_ADD_TEST_NAME}")
    add_executable(${CATCH2_ADD_TEST_NAME} EXCLUDE_FROM_ALL ${CATCH2_ADD_TEST_SOURCES})
    add_dependencies(build_tests ${CATCH2_ADD_TEST_NAME})
    target_link_libraries(${CATCH2_ADD_TEST_NAME} PRIVATE ${lib_catch2})
    add_test(${CATCH2_ADD_TEST_NAME} ${CATCH2_ADD_TEST_NAME} --use-colour yes)

    # helper define, as at the time of writing, Conan and vcpkg return catch2_v2, but FetchContent returns catch2_v3
    if (catch2_v3)
        target_compile_definitions(${CATCH2_ADD_TEST_NAME} PRIVATE CATCH3)
    endif()
endmacro()
