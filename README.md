# YACHT: Yet Another Cpp Helper Template
## A template for c++ projects.

[![Language](https://img.shields.io/badge/language-C++-blue.svg)](https://isocpp.org/) ![GitHub repo size](https://img.shields.io/github/repo-size/ShadowMitia/YACHT)

Welcome to your YACHT! Because why build a boat from scratch, when you can enjoy a more comfortable and stylish way of sailing, with a YACHT.

YACHT is a C/C++ project template based on CMake. It's goal is to avoid boilerplate CMake code, when trying to add extra features to your project. It uses a "pay for what you use" style of implementation, meaning it has a very small file size and does not generate file for features you didn't ask for.

It has support for:
* Easy compiler flag & feature configuration
* Linters and formatting tools: `clang-tidy`, `cppcheck`, `include-what-you-use`, & `clang-format`
* Testing libraries: `GTest` & `Catch2`
* Package managers: `Conan` & `vcpkg`
* Multiplatform "get up and go" support for: Unix `Make`, `Ninja`, & Windows `Visual Studio` 2015 and up
* Dev perks: `Docker`, a fully featured `./build.sh` script, a predefined `.gitignore`, & a pre setup folder structure.

Being based on CMake, it also allows you to continue to use your custom `.cmake` scripts and to alter any parts of the `CMakeLists.txt` with little interference.

### Dev setup:

You need to change the name of the project in:
* CMakeLists.txt:L.5
* tools/run_docker.sh:L.2

The folders are arranged in the following way (following the [pitchfork template](https://api.csswg.org/bikeshed/?force=1&url=https://raw.githubusercontent.com/vector-of-bool/pitchfork/develop/data/spec.bs)):
* **./data/**: Is for data used in the program, i.e. images or configs.
* **./docs/**: Is for documentation or for images used in markdown files.
* **./external/**: Is for external code, i.e. external libs.
* **./src/**: The sources and includes for the code.
* **./tests/**: The sources and includes for the tests.

### Dev Readme:

Be advised:
The docker container in this template is not secure due to the use of volumes, etc...
It is intended to be used as a cleanroom environment, to make sure it works in well known and defined environment.

This template also has `clang-tidy`, `cppcheck`, `include-what-you-use`, & `clang-format` scripts and configs.
If you wish to use them, you can enable `clang-tidy`, `cppcheck`, & `include-what-you-use` in the `./Config.cmake` file in the root directory, but they will only work if they are installed on your machine (otherwise, a warning will be emitted). A word of caution, enabling or disabling these features might cause CMake to recompile the entire project.
`clang-format` however is used with the `./format.sh` script in the root directory, when executed it will run `clang-format` over all the files in the **./src/**, **./lib/**, & **./include/** directories, which will format them in place using the included format file `./.clang-format`.

If you wish to use the [Conan package manager](https://conan.io/center/) with this template, you need to have python installed with pip (`apt-get install python3 python3-pip` in ubuntu, or from [the python website](https://www.python.org/) for windows and set 'add python to PATH' during the installation), and then run `pip3 install conan` in your terminal.
In addition vcpkg is available and is compatible with Conan. You will need to [install vcpkg manually](https://vcpkg.io/en/getting-started.html), then set the install directory in by setting `VCPKG_LOCATION` in `./Config.cmake` (RECOMMENDED), or you can let cmake download into build folder by setting `VCPKG_LOCAL_DOWNLOAD` to `ON` in `./Config.cmake` (slower than preinstalling, needs zip in linux and git in linux and windows).

For tests, you can use the included `Catch2` and/or `GTest` library interfaces. For this, configure your `./Config.cmake` file to enable them, and then you can modify `CMakeLists.txt` to add you test sources to the desired testing library. The tests can be compiled and run using the make target `run_test` (or `./build.sh test`). If you do not have `Catch2` and/or `GTest` installed (either using a package manager, or on your machine), you can set the flag `{NAME}_DOWNLOAD_IF_MISSING`, which lets the builder download a local version of the library.

GL&HF.

# Windows setup
The code was written to work with Visual Studio 2019, but it could be made to work with Visual Studio 2015 (earliest version of visual studio that supports c++11 fully).

For this, simply open Visual Studio 2019, and select the "clone from repository" option when asked which project to open.
Then, give it the HTTPS url from this repository (use the clone button above), and a destination path (it might ask you to login to the repository).

Once it is downloaded, you can then open the CMakeLists.txt, so that Visual Studio notices the cmake file. And then select the Profiling compilation option on the compilation bar, with the desired executable, and press the play button.

This will then compile the code for the desired executable, and then start said executable.

# Unix (Ubuntu) setup
The code is written to work in cmake, this means it can be compiled on a Unix platform.

### Prerequisites
To use this in ubuntu 16.04, the following prerequisites are needed before you can ```git clone``` and compile:
```bash
sudo apt-get install -y build-essential cmake git
```

### Clone & compile
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

# Docker
There is a docker file for this code. Assuming you have docker install, you can run this using:
```bash
./run_docker.sh
```
Which will give you a bash terminal with the compiled code, in a controlled environment.


# Usage
DESCRIBED YOUR PROGRAMS AND HOW TO START THEM IN UNIX
### PROG1
...

### PROG2
...
