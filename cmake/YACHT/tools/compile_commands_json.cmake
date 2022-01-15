macro(add_compile_commands_json)
    if(NOT compile_commands_json_is_set)
        message(STATUS "Requested compile_commands.json, adding to root directory")
        set(CMAKE_EXPORT_COMPILE_COMMANDS ON)
        add_custom_target(
            copy-compile-commands ALL
            ${CMAKE_COMMAND} -E copy_if_different
                ${CMAKE_BINARY_DIR}/compile_commands.json
                ${PROJECT_SOURCE_DIR}
            )
        set(compile_commands_json_is_set ON)
    endif()
endmacro()
