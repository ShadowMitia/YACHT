# only add test targets once
if(NOT added_test_target)
    message(STATUS "Adding test targets")
    set(added_test_target ON)
    add_custom_target(build_tests)
    add_custom_target(run_tests COMMAND ${CMAKE_CTEST_COMMAND})
    add_dependencies(run_tests build_tests)
endif()