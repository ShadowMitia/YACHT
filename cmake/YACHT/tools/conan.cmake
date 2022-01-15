option(CONAN_VERBOSE "Make Conan verbose when downloading and installing packages" OFF)

macro(conan_find)
    if (NOT conan_was_found)
        message(STATUS "Conan was requested. Setting up...")

        if (MSVC AND CMAKE_CXX_STANDARD STREQUAL "11")
              message(WARNING "C++11 is not supported with Conan for visual studio https://docs.conan.io/en/1.7/howtos/manage_cpp_standard.html")
        endif()

        # Dectect if conan is install. And if not, figure out if python, pip are also missing, then show an appropriate install message.
        #    If apt is present, show the apt command instead.
        find_program(CONAN_CMD "conan")
        if(NOT CONAN_CMD)
            message(WARNING "Conan not found. If it is installed, please supply the path to CONAN_CMD in the CMakeCache.txt file.")
            find_program(HAS_PIP "pip3")
            if(NOT HAS_PIP)
                find_program(HAS_PYTHON "python3")
                find_program(HAS_APT "apt")
                if(HAS_APT)
                    if(NOT HAS_PYTHON)
                        message(FATAL_ERROR "Requested Conan package manager, but it was not found. Pip and python not found, you can install them with Conan using:\nsudo apt install python3 python3-pip\npip3 install conan\n")
                    else()
                        message(FATAL_ERROR "Requested Conan package manager, but it was not found. Python found, but pip not found, you can install it with Conan using:\nsudo apt install python3-pip\npip3 install conan\n")
                    endif()
                else()
                    if(NOT HAS_PYTHON)
                        message(FATAL_ERROR "Requested Conan package manager, but it was not found. Pip and python not found. You will need python:\nhttps://www.python.org/downloads/\n You can then install pip with Conan using:\ncurl -so https://bootstrap.pypa.io/get-pip.py && python get-pip.py && pip3 install conan\n")
                    else()
                        message(FATAL_ERROR "Requested Conan package manager, but it was not found. Python found, but pip not found, you can install it with Conan using:\ncurl -so https://bootstrap.pypa.io/get-pip.py && python get-pip.py && pip3 install conan\n")
                    endif()
                endif()
            else()
                message(FATAL_ERROR "Requested Conan package manager, but it was not found. Pip and python found, you can install Conan using:\npip3 install conan\n")
            endif()
        endif()
        message(STATUS "Found Conan.")

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

        set(conan_was_found ON)
    endif()
endmacro()

macro(conan_get_from_file)
    set(oneValueArgs PATH)
    cmake_parse_arguments(CONAN_GET_FROM_FILE "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN} )

    conan_find()
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

    if(EXISTS "${CMAKE_BINARY_DIR}/conanbuildinfo.cmake")
        include(${CMAKE_BINARY_DIR}/conanbuildinfo.cmake)
        conan_basic_setup(TARGETS NO_OUTPUT_DIRS)
    endif()
endmacro()

macro(conan_get_package)
    set(multiValueArgs PACKAGE)
    cmake_parse_arguments(CONAN_GET_PACKAGE "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN} )

    conan_find()

    foreach(pkg ${CONAN_GET_PACKAGE_PACKAGE})
        MESSAGE(STATUS "Getting package ${pkg} from Conan...")
    endforeach()

    conan_cmake_configure(REQUIRES ${CONAN_GET_PACKAGE_PACKAGE}
                                                GENERATORS cmake cmake_find_package_multi)

    conan_get_from_file(PATH ".")
endmacro()
