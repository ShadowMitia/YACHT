# A general set of flags. Feel free to edit this
if (CMAKE_CXX_COMPILER_ID MATCHES "GNU|Clang|Intel")
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wall -Wextra -pedantic -Wno-unknown-pragmas -Wconversion -Wno-unused-function -Wenum-compare")
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -foptimize-sibling-calls -Wold-style-cast")
elseif (CMAKE_CXX_COMPILER_ID STREQUAL "MSVC")
    # /wd5045 is the warning for specter mitigation, as for some reason it is not manditory in windows...
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /Wall /permissive- /wd5045 /w14661")
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /Ot /EHsc /utf-8 /bigobj")
    # remove some warning flags, since MSCV is very pedantic (it even produces warnings for it's own codebase)
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /wd26451 /wd26495 /wd26812 /wd4820 /wd4365 /wd4464 /wd5031 /wd4623 /wd4626 \
                         /wd5027 /wd4625 /wd5026 /wd4127 /wd4514 /wd4710 /wd26454 /wd4668 /wd4711 /wd4996")
endif()

# special cases for GCC or clang
if (CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
    if (CMAKE_CXX_COMPILER_VERSION VERSION_GREATER 7.0)
        set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wshadow-compatible-local -faligned-new")
    endif()
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wno-deprecated-copy -finput-charset=UTF-8 -fextended-identifiers")
elseif (CMAKE_CXX_COMPILER_ID STREQUAL "Clang")
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wshadow-uncaptured-local -faligned-new")
	if (CMAKE_CXX_COMPILER_VERSION VERSION_GREATER 9.0)
		set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -ftime-trace")
	endif()
endif()

# debug flags
if (CMAKE_CXX_COMPILER_ID MATCHES "GNU|Clang|Intel")
    set(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} -Og -g -ggdb -fstack-protector -ftrapv -fno-omit-frame-pointer")
elseif (CMAKE_CXX_COMPILER_ID STREQUAL "MSVC")
    set(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} /MDd")
endif()

# release with debug info flags
if (CMAKE_CXX_COMPILER_ID MATCHES "GNU|Clang|Intel")
    set(CMAKE_CXX_FLAGS_RELWITHDEBINFO "${CMAKE_CXX_FLAGS_RELWITHDEBINFO} -g -ggdb -fstack-protector -ftrapv -fno-omit-frame-pointer")
elseif (CMAKE_CXX_COMPILER_ID STREQUAL "MSVC")
    set(CMAKE_CXX_FLAGS_RELWITHDEBINFO "${CMAKE_CXX_FLAGS_RELWITHDEBINFO} /MD")
endif()

# release flags
if (CMAKE_CXX_COMPILER_ID MATCHES "GNU|Clang|Intel")
    set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} -Wl,-O1 -DNDEBUG")
elseif (CMAKE_CXX_COMPILER_ID STREQUAL "MSVC")
    set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} /O2 /GL /Gw /Gy /Oy /MD /DNDEBUG")
endif()

macro(set_flag)
    set(multiValueArgs COMPILER TARGET FLAGS)
    cmake_parse_arguments(SET_FLAG "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN} )

    if(NOT SET_FLAG_TARGET)
        set(target_flag "CMAKE_CXX_FLAGS")
    else()
        set(target_flag "")
        foreach(target ${SET_FLAG_TARGET})
            string(TOUPPER ${target} target_str)
            set(target_flag "${target_flag};CMAKE_CXX_FLAGS_${target_str}")
        endforeach()
    endif()

    string (REPLACE ";" " " SET_FLAG_FLAGS_STR "${SET_FLAG_FLAGS}")

    # either you selected a compiler, and it is the right one. Or you chose none, and so it is applied in every case.
    foreach(target ${target_flag})
        string(TOLOWER ${CMAKE_CXX_COMPILER_ID} compiler_str)
        if((NOT SET_FLAG_COMPILER) OR (compiler_str IN_LIST SET_FLAG_COMPILER))
            set(${target} "${${target}} ${SET_FLAG_FLAGS_STR}")
        endif()
    endforeach()
endmacro()

