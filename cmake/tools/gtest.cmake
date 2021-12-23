option(GTEST "use google Gtest testing platform" OFF)
option(GTEST_DOWNLOAD_IF_MISSING "download & build google Gtest if no existing build has been found" OFF)

if (GTEST)
    enable_testing()
    include(${PROJECT_SOURCE_DIR}/cmake/tools/test_helper.cmake)
    message(STATUS "Using Gtest")

    macro(gtest_add_test)
        set(options NO_MAIN)
        set(oneValueArgs NAME)
        set(multiValueArgs SOURCES)
        cmake_parse_arguments(GTEST_ADD_TEST "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN} )

        set(find_gtest_cond "REQUIRED")
        if (GTEST_DOWNLOAD_IF_MISSING)
            set(find_gtest_cond "QUIET")
        endif()

        find_package(GTest CONFIG QUIET)
        if(NOT GTEST_FOUND)
            find_package(GTest ${find_gtest_cond})
        endif()

        # if we can't find it with find_package, then we download a known version and populate it if the user has set GTEST_DOWNLOAD_IF_MISSING
        if(NOT GTEST_FOUND)
            message(STATUS "Could not find an existing build of google Gtest. Downloading & building sources...")

            Include(FetchContent)
            FetchContent_Declare(
                googletest
                URL https://github.com/google/googletest/archive/609281088cfefc76f9d0ce82e1ff6c30cc3591e5.zip
            )

            # For Windows: Prevent overriding the parent project's compiler/linker settings
            set(gtest_force_shared_crt ON CACHE BOOL "" FORCE)

            FetchContent_MakeAvailable(googletest)

            # Alias the target names, as an installed Gtest lib is not named the same way as a subdir Gtest lib...
            add_library(GTest::GTest ALIAS gtest)
            add_library(GTest::Main ALIAS gtest_main)

            # avoid compiling if not testing
            set_target_properties(gtest PROPERTIES EXCLUDE_FROM_ALL TRUE)
            set_target_properties(gtest_main PROPERTIES EXCLUDE_FROM_ALL TRUE)
            set_target_properties(gmock PROPERTIES EXCLUDE_FROM_ALL TRUE)
            set_target_properties(gmock_main PROPERTIES EXCLUDE_FROM_ALL TRUE)
        endif()

        # add GTest main if the user has not requested NO_MAIN
        set(lib_main_gtest "GTest::Main")
        if (GTEST_ADD_TEST_NO_MAIN)
            set(lib_main_gtest "")
        endif()

        message(STATUS "Added Gtest test: ${GTEST_ADD_TEST_NAME}")
        add_executable(${GTEST_ADD_TEST_NAME} EXCLUDE_FROM_ALL ${GTEST_ADD_TEST_SOURCES})
        add_dependencies(build_tests ${GTEST_ADD_TEST_NAME})
        target_link_libraries(${GTEST_ADD_TEST_NAME} GTest::GTest ${lib_main_gtest})
        add_test(${GTEST_ADD_TEST_NAME} ${GTEST_ADD_TEST_NAME})
    endmacro()

else()
    macro(gtest_add_test)
    endmacro()
endif()
