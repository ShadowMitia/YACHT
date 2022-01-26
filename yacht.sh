#!/bin/bash

build_path="./build"
build_type=RelWithDebInfo
be_verbose="false"


compile() {
    if [ -f unix_compile.config ]; then
	source unix_compile.config
    fi
    build_type=$1 # Debug or Release
    target_name=$2

    target_arg=""
    if [ -n "$2" ]; then
	target_arg="--target ${target_name}"
    fi

    # define build_path, but append Docker_ if it is run in a docker container
    build_full_path="${build_path}/"
    if [ -n "${DOCKER}" ]; then
        build_full_path="${build_full_path}Docker_"
    fi
    build_full_path="${build_full_path}${build_type}${3}"

    mkdir -p "${build_path}"
    mkdir -p "${build_full_path}"
    
    n_jobs=$(grep -c ^processor /proc/cpuinfo) # get cpu count  
    if [ -z "$max_jobs" ]; then
	max_jobs="$n_jobs"
    fi
    if [ "$n_jobs" -gt "$max_jobs" ]; then # clip the cpu count, otherwise compilation memory might explode
	n_jobs="$max_jobs"
    fi

    builder="make"
    cmake_builder_flag=""
    if [ -n "$build_system" ]; then
	if ! hash "$build_system" 2>/dev/null; then
	    echo "ERROR: the requested build system $build_system was not found. Halting..."
	    exit 1
	fi
	if [ "$build_system" == "ninja" ]; then
	    cmake_builder_flag="-GNinja"
	fi
	builder="$build_system"
    fi

    # if we ask for test, we need to build first, then we can run tests
    run_tests=""
    if [ "$target_name" == "test" ]; then
	target_name="build_tests"
	target_arg=""
	run_tests="echo && echo '=========== Tests ============' &&  ${builder} run_tests"
    fi
    
    cmake_cov_flag=""
    if [ "$target_name" == "coverage" ]; then
	target_name="build_tests all"
	target_arg=""
	cmake_cov_flag="-DCOVERAGE_FLAGS=ON"
	run_tests="echo && echo '========= ${builder} tests =========' &&  ${builder} run_coverage"
    fi

    echo "============================="
    echo "Building ${build_type} target"
    echo "============================="
    echo

    timestamp_file="${build_path}/.yacht_cmakelists_timestamp"
    filetime=$(ls --time-style=+%s%N -l "CMakeLists.txt" | awk "{print(\$6)}")
    
    rerun="false"
    
    if [[ ! -f $timestamp_file ]]; then
	echo "$filetime" > $timestamp_file
	rerun="true"
    fi

    filetime2=$(cat $timestamp_file)
    
    if [[ "$filetime2" -gt "$filetime" ]]; then
	rerun="true"
	echo "${filetime}" > $timestamp_file
    fi
    source_dir=$(pwd)

    args=""

    if [ "$be_verbose" = "true" ]; then
       args="$args --verbose"
    fi
    
    if [ $rerun == "true" ]; then
	echo "=========== CMake ==========="
	CC="${c_compiler}" CXX="${cpp_compiler}" cmake -S "${source_dir}" -B"${build_full_path}" "${cmake_builder_flag}" "${target_arg}" "${cmake_cov_flag}" -DCMAKE_BUILD_TYPE="${build_type}"
	echo
    fi       
    echo "=========== ${builder} ============"    
    cmake --build "${build_full_path}" --parallel "${n_jobs}" "$args"
    # "${builder}" -j"${n_jobs}" "${target_name}" && eval "${run_tests}"
    # save the error code if one occured.
    error_code=$?

    # propagate the error out if an error code occured.
    if [ $error_code -ne 0 ]; then
	exit $error_code
    fi
}


usage() {
    help_text="yacht.sh - Build your project with style!

./yacht.sh COMMAND [OPTIONS] [TARGET]

COMMAND:
	clean
	build 
	format	

OPTIONS:
      -h, --help                Show this help
      -v, --verbose             use verbose output
      -r, --release             use the Release build type    
      -d, --debug               use the Debug build type      
      -m, --minsizerel          use the MinSizeRel build type 
      -w, --reldebug            use the RelWithDebInfo build type

TARGET:                         specify a compile target (build only)
 "
    echo "$help_text";
}

format() {
    if ! hash clang-format 2>/dev/null; then
	echo "'clang-format' is not installed on this machine, cannot use it to format code."
	echo "It can be installed from you package manager or from https://releases.llvm.org/download.html"
	exit 1
    fi

    format_command="clang-format"
    format_args="-i"
    if [ "$be_verbose" = "true" ]; then
        format_args="--Werror --verbose ${format_args}"
    fi

    for dir in "src/" "include/" "libs/" "tests/"; do
	if [ -d "${dir}" ]; then
	    pushd "${dir}" &>/dev/null || exit 1
	    # shellcheck disable=SC2086
	    find . \
		 \( -name '*.c' \
		 -o -name '*.cc' \
		 -o -name '*.cpp' \
		 -o -name '*.h' \
		 -o -name '*.hh' \
		 -o -name '*.hpp' \) \
		 -exec ${format_command} ${format_args} '{}' + 
	    popd &>/dev/null || exit 1
	fi
    done
    
}


COMMAND=""

if [ -n "$1" ]; then
    COMMAND=$1
else
    usage
    exit 0;
fi

case "$COMMAND" in
    build | format | clean)
    ;;
    *)
	usage
	exit 1
	;;
esac
shift

while test -n "$1"; do
    case "$1" in
	-h | --help)
	    usage
	    exit 0
	    ;;
	-v | --verbose)
	    be_verbose="true"
	    shift
	    ;;
	-r | --release)
	    build_type=Release
	    shift
	    ;;
	-d | --debug)
	    build_type=Debug
	    shift
	    ;;
	-m | --minsizerel)
	    build_type=MinSizeRel
	    shift
	    ;;
	-w | --release-with-debug)
	    build_type=RelWithDebInfo
	    shift
	    ;;
	*)
	    target=$1
	    shift
	    ;;
    esac
done


case "$COMMAND" in
    "clean")
	# if you asked for clean, then remove all the files
	if [ -d "${build_path}" ]; then
	    rm -rf "${build_path}"
	fi
	
	if [ "$be_verbose" = "true" ]; then
	    echo "Cleaned build directory."
	    echo " "
	fi
	;;
    "build")
	compile ${build_type} "${target}"
	;;
    "format")
	format
	;;
    
esac
