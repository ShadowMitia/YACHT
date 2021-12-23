option(CLANG_TIDY "use Clang Tidy while compiling, if available" OFF)

if (CLANG_TIDY)
	find_program(CLANG_TIDY_EXEC "clang-tidy")
	if(CLANG_TIDY_EXEC)
		message(STATUS "Using clang-tidy")
    set(CMAKE_CXX_CLANG_TIDY
			${CLANG_TIDY_EXEC};
			--use-color;
			-header-filter=.;)
	else()
		message(WARNING "Requested Clang Tidy, but it was not found. Continuing without it.")
	endif()
endif()
