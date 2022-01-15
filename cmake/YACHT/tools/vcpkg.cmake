option(VCPKG_VERBOSE "Make vcpkg verbose when downloading and installing packages" OFF)
option(VCPKG_LOCATION "The path to an existing VCPKG directory" "")
option(VCPKG_LOCAL_DOWNLOAD "Download local version of vcpkg into the build directory" OFF)

macro(vcpkg_find)
    if (NOT vcpkg_was_found)
        message(STATUS "vcpkg was requested. Setting up...")

        # if asked for local download, set the directory
        if (VCPKG_LOCAL_DOWNLOAD)
            set(VCPKG_LOCATION ${PROJECT_SOURCE_DIR}/build/vcpkg)
        endif()

        # download if asked too, but only if it does not exist
        if (VCPKG_LOCAL_DOWNLOAD AND (NOT EXISTS "${PROJECT_SOURCE_DIR}/build/vcpkg"))
            MESSAGE(STATUS "Downloading vcpkg into ./build/...")
            file(DOWNLOAD "https://github.com/microsoft/vcpkg/archive/refs/heads/master.zip"
                          "${PROJECT_SOURCE_DIR}/build/vcpkg.zip"
                          TLS_VERIFY ON)

            MESSAGE(STATUS "Extracting vcpkg into ./build/... (can be slow)")
            execute_process(COMMAND ${CMAKE_COMMAND} -E tar xzf "${PROJECT_SOURCE_DIR}/build/vcpkg.zip"
                    WORKING_DIRECTORY "${PROJECT_SOURCE_DIR}/build/"
                    RESULT_VARIABLE ret)
            file(REMOVE "${PROJECT_SOURCE_DIR}/build/vcpkg.zip")
            if (NOT (ret EQUAL 0))
                file(REMOVE_RECURSE "${PROJECT_SOURCE_DIR}/build/vcpkg-master")
                MESSAGE(FATAL_ERROR "Extracting vcpkg failed. Halting...")
            endif()
            file(RENAME "${PROJECT_SOURCE_DIR}/build/vcpkg-master/" "${PROJECT_SOURCE_DIR}/build/vcpkg/")

            MESSAGE(STATUS "Installing vcpkg...")
            if (msvc)
                execute_process(COMMAND ./bootstrap-vcpkg.bat -disableMetrics
                                WORKING_DIRECTORY "${PROJECT_SOURCE_DIR}/build/vcpkg/"
                                RESULT_VARIABLE ret)
            else()
                execute_process(COMMAND ./bootstrap-vcpkg.sh -disableMetrics
                                WORKING_DIRECTORY "${PROJECT_SOURCE_DIR}/build/vcpkg/"
                                RESULT_VARIABLE ret)
            endif()
            if (NOT (ret EQUAL 0))
                file(REMOVE_RECURSE "${PROJECT_SOURCE_DIR}/build/vcpkg")
                MESSAGE(FATAL_ERROR "bootstrapping vcpkg failed. Halting...")
            endif()
        endif()

        # make sure the address for vcpkg is sane
        find_program(VCPKG_CMD "vcpkg" HINTS "${VCPKG_LOCATION}")
        if (NOT VCPKG_CMD)
            MESSAGE(FATAL_ERROR "Could not find vcpkg in the directory \"${VCPKG_LOCATION}\". Halting...")
        endif()
        message(STATUS "Found vcpkg.")

        # include scripting stuff for vcpkg
        include("${VCPKG_LOCATION}/scripts/buildsystems/vcpkg.cmake")

        message(STATUS "Using vcpkg.")

        set(vcpkg_was_found ON)
    endif()
endmacro()

# add function to download pkgs from cmake
macro(vcpkg_get_package)
    set(multiValueArgs PACKAGE)
    cmake_parse_arguments(VCPKG_GET_PACKAGE "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN} )

    vcpkg_find()

    set(is_quiet "OUTPUT_QUIET")
    if(VCPKG_VERBOSE)
        set(is_quiet "")
    endif()

    foreach(pkg ${VCPKG_GET_PACKAGE_PACKAGE})
        MESSAGE(STATUS "Getting package ${pkg} from vcpkg...")
        execute_process(COMMAND ${VCPKG_CMD} install ${pkg}
                        WORKING_DIRECTORY "${PROJECT_SOURCE_DIR}/build/vcpkg/"
                        RESULT_VARIABLE ret
                        ${is_quiet})

        if (NOT (ret EQUAL 0))
            MESSAGE(FATAL_ERROR "Failed to install package ${pkg}. Halting...")
        endif()
    endforeach()
endmacro()
