option(GTEST "use google Gtest testing platform" OFF)

if (GTEST)
    enable_testing()
    message(STATUS "Using Gtest")

    macro(gtest_add_test)
        set(oneValueArgs NAME)
        set(multiValueArgs SOURCES)
        cmake_parse_arguments(GTEST_ADD_TEST "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN} )

        find_package(GTest CONFIG QUIET)
        if(NOT GTEST_FOUND)
            find_package(GTest QUIET)
        endif()

        message(STATUS "Added Gtest test ${GTEST_ADD_TEST_NAME}")
        add_executable(${GTEST_ADD_TEST_NAME} ${GTEST_ADD_TEST_SOURCES})
        target_link_libraries(${GTEST_ADD_TEST_NAME} GTest::GTest GTest::Main)
        add_test(${GTEST_ADD_TEST_NAME} ${GTEST_ADD_TEST_NAME})
    endmacro()
endif()
