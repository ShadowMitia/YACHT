option(CCACHE "use Ccache while compiling, if available" OFF)

if (CCACHE)
    find_program(CCACHE_EXEC "ccache")
    if(CCACHE_EXEC)
        message(STATUS "Using Ccache")
        set(CMAKE_CXX_COMPILER_LAUNCHER ${CCACHE_EXEC})
    else()
        find_program(HAS_APT "apt" NO_CACHE)
        if(HAS_APT)
            message(WARNING "Requested Ccache, but it was not found. Continuing without it. You can install it using:\nsudo apt install ccache\n")
        else()
            message(WARNING "Requested Ccache, but it was not found. Continuing without it. You can install it from here:\nhttps://ccache.dev/download.html")
        endif()
    endif()
endif()