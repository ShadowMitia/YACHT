option(GOOLE_BENCHMARK_DOWNLOAD_IF_MISSING "download & build google benchmark if no existing build has been found" OFF)

macro(google_benchmark_find)
    if (NOT google_benchmark_was_found)
        message(STATUS "Google benchmark was requested. Setting up...")
        enable_testing()
        include(${PROJECT_SOURCE_DIR}/cmake/tools/test_helper.cmake)

        set(find_google_benchmark_cond "REQUIRED")
        if (GOOLE_BENCHMARK_DOWNLOAD_IF_MISSING)
            set(find_google_benchmark_cond "QUIET")
        endif()
        find_package(benchmark ${find_google_benchmark_cond} HINTS ${CMAKE_BINARY_DIR})

        # if we can't find it with find_package, then we download a known version and populate it if the user has set GOOLE_BENCHMARK_DOWNLOAD_IF_MISSING
        if(NOT benchmark_FOUND)
            message(STATUS "Could not find an existing build of google benchmark. Downloading & building sources...")

            Include(FetchContent)
            FetchContent_Declare(
                benchmark
                GIT_REPOSITORY https://github.com/google/benchmark
                GIT_TAG        v1.6.0
            )

            set(BENCHMARK_ENABLE_TESTING OFF)
            FetchContent_MakeAvailable(benchmark)

            # ignore warnings when compiling benchmark
            target_compile_options(benchmark PRIVATE -w)

            # Alias the target names, as an installed benchmark lib is not named the same way as a subdir benchmark lib...
            add_library(benchmark::benchmark ALIAS benchmark)

            # avoid compiling if not testing
            set_target_properties(benchmark PROPERTIES EXCLUDE_FROM_ALL TRUE)
        endif()

        message(STATUS "Using Google benchmark")

        set(google_benchmark_was_found ON)
    endif()
endmacro()

macro(google_benchmark_add_test)
    set(options ADD_PERF_STAT)
    set(oneValueArgs NAME)
    set(multiValueArgs SOURCES ARGS)
    cmake_parse_arguments(GOOGLE_BENCHMARK_ADD_TEST "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN} )

    google_benchmark_find()

    # call with perf stat if requested
    set(perf_stat_call "")
    if (GOOGLE_BENCHMARK_ADD_TEST_ADD_PERF_STAT)
        find_program(PERF_EXEC "perf")
        if(PERF_EXEC)
            set(perf_stat_call "${PERF_EXEC} stat")
        else()
            find_program(HAS_APT "apt" NO_CACHE)
            if(HAS_APT)
                message(WARNING "Requested perf with benchmark, but it was not found. Continuing without it. You can install it using:\nsudo apt install linux-tools-common\n")
            else()
                message(WARNING "Requested Ccache, but it was not found. Continuing without it.")
            endif()
        endif()
    endif()


    message(STATUS "Added Google benchmark: ${GOOGLE_BENCHMARK_ADD_TEST_NAME}")
    add_executable(${GOOGLE_BENCHMARK_ADD_TEST_NAME} EXCLUDE_FROM_ALL ${GOOGLE_BENCHMARK_ADD_TEST_SOURCES})
    add_dependencies(build_tests ${GOOGLE_BENCHMARK_ADD_TEST_NAME})
    target_link_libraries(${GOOGLE_BENCHMARK_ADD_TEST_NAME} benchmark::benchmark)
    add_test(${GOOGLE_BENCHMARK_ADD_TEST_NAME} ${perf_stat_call} ${GOOGLE_BENCHMARK_ADD_TEST_NAME} --benchmark_color=true ${GOOGLE_BENCHMARK_ADD_TEST_ARGS})
endmacro()
