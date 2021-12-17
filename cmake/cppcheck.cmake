option(CPP_CHECK "use Cpp Check while compiling, if available" OFF)

if (CPP_CHECK)
	find_program(CPP_CHECK_FOUND "cppcheck")
	if(CPP_CHECK_FOUND)
	   set(CMAKE_CXX_CPPCHECK "cppcheck")
	endif()
endif()
