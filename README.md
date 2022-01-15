# YACHT: Yet Another C++ Helper Template
## A template for C++ projects.

[![Language](https://img.shields.io/badge/language-C++-blue.svg)](https://isocpp.org/) ![GitHub repo size](https://img.shields.io/github/repo-size/ShadowMitia/YACHT)

Welcome to your YACHT! Because why build a boat from scratch, when you can enjoy a more comfortable and stylish way of sailing, with a YACHT.

YACHT is a C/C++ project template based on CMake. It's goal is to avoid boilerplate CMake code, when trying to add extra features to your project. It uses a "pay for what you use" style of implementation, meaning it has a very small file size and does not generate file for features you didn't ask for.

It has support for:
* Easy compiler flags & feature configuration
* Linters and formatting tools: `clang-tidy`, `cppcheck`, `include-what-you-use`, & `clang-format`
* Integrated testing libraries: `GTest` & `Catch2`
* Package managers: `conan` & `vcpkg`
* Crossplatform support: Unix `Make`, `Ninja`, & Windows `Visual Studio` 2015 and up
* Dev perks: `Docker`, a fully featured `./build.sh` script, a predefined `.gitignore`, & a pre setup folder structure.

Being based on CMake, it also allows you to continue to use your custom `*.cmake` scripts and to alter any parts of the `CMakeLists.txt` with little 
interference.


## Setup

### Windows
The code was written to work with Visual Studio 2019, but it could be made to work with Visual Studio 2015 (earliest version of visual studio that supports C++11 fully).

Open the CMakeLists.txt, so that Visual Studio notices the cmake file. And then select the Profiling compilation option on the compilation bar, with the desired executable, and press the play button. This will then compile the code for the desired executable, and then start said executable.

### Unix (Ubuntu) setup
The code is written to work in cmake, this means it can be compiled on a Unix platform.

To use this in Ubuntu 16.04 (and above), the following prerequisites are needed:
```bash
sudo apt-get install -y build-essential cmake git
```

## Clone & compile

### YACHT scripts

Start in the desired directory, with a ```git clone``` command, followed by the HTTPS url from this repository (use the clone button above), and press enter. Then once the clone is complete, enter the new directory created by git.

The compilation is done using the **./build.sh** script, which compiles the code in the **./src/** folder, to the **./build/** folder.

* **./build.sh -h** will show a help page.
* **./build.sh** is used in dev environment. It calls the compilation with the RelWithDebInfo target, designed for minimum computation time, while preserving debug information and safe guards.
* **./build.sh -d** is used when trying to debug errors in the program. It calls the compilation with the Debug target, designed for optimal debugging and safe guards, at the cost of higher compute time.
* **./build.sh -m** is used to generate the smallest executable possible. It calls the compilation with the MinSizeRel target, designed for minimum size.
* **./build.sh -r** is used in normal usage. It calls the compilation with the Release target, designed for minimum computation time, at the cost of harder debugging and no safe guards.
* **./build.sh -c** will clean the build folder for the desired target, and the compile the target.
* **./build.sh TARGET** will only compile the given target. If the target is "clean" then it will only clean the build folder, and exit.

If needed, you may also chain some flags. e.g. clean the folder, then compile in release mode, the target called MyExec:
```bash
./build.sh -r -c MyExec
```

The number of CPUs used in the compilation is determined automatically, but can be limited. This is to avoid out of memory issues when running on low memory machines. This can be enabled in the `unix_compile.config` file:
```
# Define the max number of jobs. Care must be taken, a too high value could
#   cause an out of memory error.
max_jobs=8
```

### CMake commmands

Alternatively, especially if you are using more recent versions of CMake (3.13+), you can do the following:

At the root of the directory:

`cmake -S . -B build -DCMAKE_BUILD_TYPE=Debug -DCMAKE_EXPORT_COMPILE_COMMANDS=1`

Then to compile you can simply do (regardless of build system):

`cmake --build build --parallel {num_jobs}`


## Development setup:

You need to change the name of the project in:
* CMakeLists.txt:L.5
* tools/run_docker.sh:L.2

The folders are arranged in the following way (following the [pitchfork template](https://api.csswg.org/bikeshed/?force=1&url=https://raw.githubusercontent.com/vector-of-bool/pitchfork/develop/data/spec.bs)):
* **./data/**: Is for data used in the program, i.e. images or configs.
* **./docs/**: Is for documentation or for images used in markdown files.
* **./external/**: Is for external code, i.e. external libs.
* **./src/**: The sources and includes for the code.
* **./tests/**: The sources and includes for the tests.

### Recommended troubleshooting tools
* [valgrind](https://valgrind.org/)
* [rr](https://rr-project.org/)
* gdb (with [pwndbg](https://github.com/pwndbg/pwndbg) or [gef](https://gef.readthedocs.io/en/master/))

# Documentation:

## Tools for code checking:
This template also has `clang-tidy`, `cppcheck`, `include-what-you-use`, & `clang-format` scripts and configs.
If you wish to use them, you can enable `clang-tidy`, `cppcheck`, & `include-what-you-use` in the `./Config.cmake` file in the root directory, but they will only work if they are installed on your machine (otherwise, a warning will be emitted). A word of caution, enabling or disabling these features might cause CMake to recompile the entire project.
`clang-format` however is used with the `./format.sh` script in the root directory, when executed it will run `clang-format` over all the files in the **./src/**, **./lib/**, & **./include/** directories, which will format them in place using the included format file `./.clang-format`.

## Package managers:
If you wish to use the [Conan package manager](https://conan.io/center/) with this template, you need to have python installed with pip (`apt-get install python3 python3-pip` in ubuntu, or from [the python website](https://www.python.org/) for windows and set 'add python to PATH' during the installation), and then run `pip3 install conan` in your terminal.
In addition vcpkg is available and is compatible with Conan. You will need to [install vcpkg manually](https://vcpkg.io/en/getting-started.html), then set the install directory in by setting `VCPKG_LOCATION` in `./Config.cmake` (RECOMMENDED), or you can let cmake download into build folder by setting `VCPKG_LOCAL_DOWNLOAD` to `ON` in `./Config.cmake` (slower than preinstalling, needs zip in linux and git in linux and windows).

## Testing:
For tests, you can use the included `Catch2` and/or `GTest` library interfaces. For this you can modify `CMakeLists.txt` to add you test sources to the desired testing library. The tests can be compiled and run using the make target `run_test` (or `./build.sh test`). If you do not have `Catch2` and/or `GTest` installed (either using a package manager, or on your machine), you can set the flag `{NAME}_DOWNLOAD_IF_MISSING`, which lets the builder download a local version of the library.

## Fuzzing:
To use [AFL](https://github.com/google/AFL)/[AFL++](https://github.com/AFLplusplus/AFLplusplus) (Unix and MacOS only) fuzzing, you will need to change the compiler in `unix_compile.config` to `/path/to/afl-cc` and `/path/to/afl-c++`. Then you can follow the [AFL instructions here](https://github.com/AFLplusplus/AFLplusplus#quick-start-fuzzing-with-afl) in order to fuzz with AFL.
Fuzzing with [LLVM's libfuzz](https://llvm.org/docs/LibFuzzer.html) requires `Clang>=6.0.0` but is easier to use with YATCH. For this you can modify `CMakeLists.txt` to add you test fuzzing sources to the `libfuzz_add_test` function call.
Both approaches have pros and cons. A significant difference between them is AFL uses stdin and files to fuzz, where as libfuzz uses `uint_8` arrays to fuzz (as show in `tests\fuzz_examples\libfuzz_example.cpp`).

## Code coverage:
In Unix/MacOS, you can use [gcovr](https://gcovr.com/en/stable/) or [lcov](https://github.com/linux-test-project/lcov) for code coverage. Once installed (`pip3 install gcovr` and `sudo apt install lcov` respectively), simply enable either (or both) of them in your `./Config.cmake` file. This will generate a folder with html file in your build directory where a full report of code coverage can be seen.
For windows, if `mingw` or a similar method is used, you can use gcovr or lcov. If visual studio is used, we recommend OpenCppCoverage plugin for visual studio, as it will be much simpler and nicer to use. In order to build and run the tests with gcovr or lcov, run the build script with `coverage` as target (E.G. `./build.sh -d coverage`).

## Docker

Be advised:
The docker container in this template is not secure due to the use of volumes, etc...
It is intended to be used as a cleanroom environment, to make sure it works in well known and defined environment.


There is a docker file for this code. Assuming you have docker install, you can run this using:
```bash
./run_docker.sh
```
Which will give you a bash terminal with the compiled code, in a controlled environment.


