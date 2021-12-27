#!/bin/bash

format_command="clang-format -i -style=file %"
verbose_command="clang-format --dry-run --Werror --verbose -style=file %"

while test $# -gt 0; do
  case "$1" in
    -h|--help)
      echo "format.sh - Formats the source with clang-format."
      echo " "
      echo "./format.sh [-h|--help] [-v|--verbose]"
      echo " "
      echo "options:"
      echo "  -h, --help                show brief help"
      echo "  -v, --verbose             show the formating errors, and the progress of the formatting"
      echo " "
      exit 0
      ;;
    -v|--verbose)
      format_command="${verbose_command} ; ${format_command}"
      shift
      ;;
    *)
      shift
      ;;
  esac
done

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

for path in "./src/" "./include/" "./libs/"
do
   if [ -d "${path}" ]; then
       find "${path}" \( -name "*.c" -o -name "*.cc" -o -name "*.cpp"  -o -name "*.h" -o -name "*.hpp" -o -name "*.ipp" \) -print | \
       xargs -I % sh -c "${format_command}"
   fi
done
