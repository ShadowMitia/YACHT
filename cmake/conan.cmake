option(CONAN "Use Conan package manager" OFF)
option(CONAN_VERBOSE "Make Conan verbose when downloading and installing packages" OFF)

if (CONAN)
		if (MSVC AND CMAKE_CXX_STANDARD STREQUAL "11")
			  message(WARNING "C++11 is not supported with conan for visual studio https://docs.conan.io/en/1.7/howtos/manage_cpp_standard.html")
		endif()

		list(APPEND CMAKE_MODULE_PATH ${CMAKE_BINARY_DIR})
		list(APPEND CMAKE_PREFIX_PATH ${CMAKE_BINARY_DIR})
		set(ENV{CONAN_REVISIONS_ENABLED} 1)

		if(NOT EXISTS "${PROJECT_SOURCE_DIR}/build/conan.cmake")
			message(STATUS "Downloading conan.cmake from https://github.com/conan-io/cmake-conan")
			file(DOWNLOAD "https://raw.githubusercontent.com/conan-io/cmake-conan/0.17.0/conan.cmake"
		                  "${PROJECT_SOURCE_DIR}/build/conan.cmake"
		                  EXPECTED_HASH SHA256=3BEF79DA16C2E031DC429E1DAC87A08B9226418B300CE004CC125A82687BAEEF
		                  TLS_VERIFY ON)
		endif()

		include(${PROJECT_SOURCE_DIR}/build/conan.cmake)

		# adding remotes, in case the wrong ones are installed.
		conan_add_remote(NAME conancenter URL https://center.conan.io INDEX 0)
		conan_add_remote(NAME bincrafters URL https://bincrafters.jfrog.io/artifactory/api/conan/public-conan)

		message(STATUS "Using Conan")

		macro(conan_get_from_file)
			set(oneValueArgs PATH)
			cmake_parse_arguments(CONAN_GET_FROM_FILE "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN} )

			conan_cmake_autodetect(settings)

			set(is_quiet "OUTPUT_QUIET")
			if(CONAN_VERBOSE)
				set(is_quiet "")
			endif()

			if(NOT CONAN_GET_FROM_FILE_PATH)
				set(CONAN_GET_FROM_FILE_PATH "${PROJECT_SOURCE_DIR}")
			endif()

			conan_cmake_install(PATH_OR_REFERENCE "${CONAN_GET_FROM_FILE_PATH}"
													BUILD missing
													REMOTE conancenter bincrafters
													SETTINGS ${settings}
													${is_quiet})

			include(${CMAKE_BINARY_DIR}/conanbuildinfo.cmake)
			conan_basic_setup(TARGETS NO_OUTPUT_DIRS)
		endmacro()

		macro(conan_get_package)
		    set(multiValueArgs PACKAGE)
		    cmake_parse_arguments(CONAN_GET_PACKAGE "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN} )

			foreach(pkg ${CONAN_GET_PACKAGE_PACKAGE})
	            MESSAGE(STATUS "Getting package ${pkg} from Conan...")
	        endforeach()

			conan_cmake_configure(REQUIRES ${CONAN_GET_PACKAGE_PACKAGE}
														GENERATORS cmake cmake_find_package_multi)

			conan_get_from_file(PATH ".")
		endmacro()

else()
		macro(conan_get_from_file)
		endmacro()

		macro(conan_get_package)
		endmacro()
endif()
