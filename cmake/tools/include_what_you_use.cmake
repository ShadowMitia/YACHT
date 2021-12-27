option(INCLUDE_WHAT_YOU_USE "use Include-what-you-use while compiling, if available" OFF)

if (INCLUDE_WHAT_YOU_USE)
    find_program(INCLUDE_WHAT_YOU_USE_EXEC "include-what-you-use")
    if(INCLUDE_WHAT_YOU_USE_EXEC)
        message(STATUS "Using Include-what-you-use")
        set(CMAKE_CXX_INCLUDE_WHAT_YOU_USE ${INCLUDE_WHAT_YOU_USE_EXEC})
    else() # I would suggest apt install, but unfortunatly it will break IWYU as it cannot find basic stdc++ includes. So you need to follow the build guide.
        message(WARNING "Requested Include-what-you-use, but it was not found. Continuing without it. You can install it using this:\nhttps://github.com/include-what-you-use/include-what-you-use#how-to-build\n")
    endif()
endif()
