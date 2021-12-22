option(ASAN "build with address sanitizer" OFF)

if (ASAN)
    message(STATUS "Compiling with sanitizers")
	# sanitizers when debugging
	if ((CMAKE_CXX_COMPILER_ID STREQUAL "GNU") AND (CMAKE_CXX_COMPILER_VERSION VERSION_GREATER 8.0))
		# we cannot use this wit GCC7 due to https://stackoverflow.com/q/50024731
	    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fsanitize=address,leak,undefined")
	elseif ((CMAKE_CXX_COMPILER_ID STREQUAL "GNU") AND (CMAKE_CXX_COMPILER_VERSION VERSION_GREATER 5.0))
	    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fsanitize=address,leak")
	elseif (CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
	    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fsanitize=address")
	elseif (CMAKE_CXX_COMPILER_ID MATCHES "Clang|Intel")
		set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fsanitize=address,leak,undefined")
	endif()

	# special cases for GCC or clang
	if (CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
	    if (CMAKE_CXX_COMPILER_VERSION VERSION_GREATER 7.0)
	        set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fsanitize-address-use-after-scope")
	    endif()
	elseif (CMAKE_CXX_COMPILER_ID MATCHES "Clang|Intel")
	    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fsanitize-address-use-after-scope")
	endif()
endif()
