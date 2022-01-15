#!/bin/bash

# gets the compilation function
source tools/unix_compile.func

build_type=RelWithDebInfo

while test $# -gt 0; do
  case "$1" in
    -h|--help)
      echo "build.sh - Builds the source with cmake and make."
      echo " "
      echo "./build.sh [-h|--help] [-r|--release] [-d|--debug] [-c|--clean] TARGET"
      echo " "
      echo "options:"
      echo "  -h, --help                show brief help"
      echo "  -r, --release             use the Release build type    (mutually exclusive with -d,--debug,-m, and --minsizerel)"
      echo "  -d, --debug               use the Debug build type      (mutually exclusive with -r,--release,-m, and --minsizerel)"
      echo "  -m, --minsizerel          use the MinSizeRel build type (mutually exclusive with -r,--release,-d, and --debug)"
      echo "  -c, --clean               cleans the build directory before compiling"
      echo "  TARGET                    specify a compile target"
      echo " "
      echo "if neither -r,--release,-d,--debug,-m, or --minsizerel are set, then the default build type used is Relwithdebinfo."
      exit 0
      ;;
    -r|--release)
      build_type=Release
      shift
      ;;
    -d|--debug)
      build_type=Debug
      shift
      ;;
    -m|--minsizerel)
      build_type=MinSizeRel
      shift
      ;;
    -c|--clean)
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

compile ${build_type} "${target}"
