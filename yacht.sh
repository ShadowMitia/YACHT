#!/bin/bash

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
  build_path="./build/"
  if [ -n "${DOCKER}" ]; then
    build_path="${build_path}Docker_"
  fi
  build_path="${build_path}${build_type}${3}"

  # if you asked for clean, then remove all the files
  if [ "${target_name,,}" == "clean" ]; then
    if [ -d "${build_path}" ]; then
      rm -rf "${build_path}"
    fi
    return
  fi

  # create build path if it does not exist
  if [ ! -d "${build_path}" ]; then
    mkdir -p "${build_path}"
  fi

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
  echo "building ${build_type} target"
  echo "============================="
  echo

  source_dir=$(pwd)
  pushd "${build_path}" &>/dev/null || exit 1
  echo "=========== CMake ==========="
  CC="${c_compiler}" CXX="${cpp_compiler}" cmake "${cmake_builder_flag}" "${target_arg}" "${cmake_cov_flag}" -D CMAKE_BUILD_TYPE="${build_type}" "${source_dir}" &&
    echo &&
    echo "=========== ${builder} ============" &&
    ${builder} -j"${n_jobs}" ${target_name} && eval "${run_tests}"
  # save the error code if one occured.
  error_code=$?
  popd &>/dev/null || exit 1

  # propagate the error out if an error code occured.
  if [ $error_code -ne 0 ]; then
    exit $error_code
  fi
}

build_type=RelWithDebInfo
be_verbose="false"
do_format="false"

while test $# -gt 0; do
  case "$1" in
  -h | --help)
    echo "yacht.sh - Builds the source with cmake and make."
    echo " "
    echo "./yacht.sh [-h|--help] [-r|--release] [-d|--debug] [-c|--clean] TARGET"
    echo " "
    echo "options:"
    echo "  -h, --help                show brief help"
    echo "  -r, --release             use the Release build type    (mutually exclusive with -d,--debug,-m, and --minsizerel)"
    echo "  -d, --debug               use the Debug build type      (mutually exclusive with -r,--release,-m, and --minsizerel)"
    echo "  -m, --minsizerel          use the MinSizeRel build type (mutually exclusive with -r,--release,-d, and --debug)"
    echo "  -c, --clean               cleans the build directory before compiling"
    echo "  -f, --format              call clang-format on the whole project"
    echo "  TARGET                    specify a compile target"
    echo "  -v, --verbose             use verbose output"
    echo " "
    echo "if neither -r,--release,-d,--debug,-m, or --minsizerel are set, then the default build type used is Relwithdebinfo."
    exit 0
    ;;
  -f | --format)
    do_format="true"
    shift
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
  -c | --clean)
    clean=ON
    shift
    ;;
  *)
    target=$1
    shift
    ;;
  esac
done

if [ -n "$clean" ]; then
  compile ${build_type} clean
  echo "Cleaned build directory."
  echo " "
fi

if [ "$do_format" = "true" ]; then

  format_command="clang-format -i -style=file %"
  if [ "$be_verbose" = "true" ]; then
    verbose_command="clang-format --dry-run --Werror --verbose -style=file %"
    format_command="${verbose_command} ; ${format_command}"
  fi

  if ! hash clang-format 2>/dev/null; then
    echo "'clang-format' is not installed on this machine, cannot use it to format code. Halting..."
    if hash apt 2>/dev/null; then # if apt is install, give a suggestion about how to install clang-format
      echo "It can be installed with:"
      echo ""
      echo "sudo apt install clang-format"
      echo ""
    else
      echo "It can install it from LLVM's tools:"
      echo ""
      echo "https://releases.llvm.org/download.html"
      echo ""
    fi
    exit 1
  fi

  for path in "./src/" "./include/" "./libs/"; do
    if [ -d "${path}" ]; then
      find "${path}" \( -name "*.c" -o -name "*.cc" -o -name "*.cpp" -o -name "*.h" -o -name "*.hpp" -o -name "*.ipp" \) -print |
        xargs -I % sh -c "${format_command}"
    fi
  done
fi
compile ${build_type} "${target}"
