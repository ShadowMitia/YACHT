# Cpp base project
## A template for c++ projects.

[![Language](https://img.shields.io/badge/language-C++-blue.svg)](https://isocpp.org/)

Dev setup:

You need to change the name of the project in:
* CMakeLists.txt:L.5
* tools/run_docker.sh:L.2

The folders are arranged in the following way (following the [pitchfork template](https://api.csswg.org/bikeshed/?force=1&url=https://raw.githubusercontent.com/vector-of-bool/pitchfork/develop/data/spec.bs)):
* **./data/**: Is for data used in the program, i.e. images or configs.
* **./docs/**: Is for documentation or for images used in markdown files.
* **./external/**: Is for external code, i.e. external libs.
* **./src/**: The sources and includes for the code.

Be advised:
The docker container in this template is not secure due to the use of volumes, etc... 
It is intended to be used as a cleanroom environment, to make sure it works in well known and defined environment.

GL&HF.

# Windows setup
The code was written to work with Visual Studio 2019, but it could be made to work with Visual Studio 2015 (earliest version of visual studio that supports c++11 fully).

For this, simply open Visual Studio 2019, and select the "clone from repository" option when asked which project to open.
Then, give it the HTTPS url from this repository (use the clone button above), and a destination path (it might ask you to login to the repository).

Once it is downloaded, you can then open the CMakeLists.txt, so that Visual Studio notices the cmake file. And then select the Profiling compilation option on the compilation bar, with the desired executable (drop down arrow, then choose: `simulate.exe`, `train_cmaes.exe`, ...), and press the play button.

This will then compile the code for the desired executable, and then start said executable.

# Unix (Ubuntu) setup
The code is written to work in cmake, this means it is rather trivial to export to a Unix platform.

### Prerequisites
To use this in ubuntu 16.04, the following prerequisites are needed before you can ```git clone``` and compile:
```bash
sudo apt-get install -y build-essential cmake git
```

### Clone & compile
Start in the desired directory, with a ```git clone``` command, followed by the HTTPS url from this repository (use the clone button above), and press enter. Then once the clone is complete, enter the new directory created by git.

The compilation is done using the **./debug.sh** & **./release.sh** scripts, which compiles the code in the **./src/** folder, to the **./build/** folder.

* **./debug.sh** is used when trying to debug errors in the program. It calls the compilation with the Debug target, designed for optimal debugging and safe guards, at the cost of higher compute time.
* **./release.sh** is used when training and normal usage. It calls the compilation with the Release target, designed for minimum computation time, at the cost of harder debugging and no safe guards.

To compile the code run the desired script. e.g.:
```bash
./release.sh
```

Additionally you may add the target name, in order to only compile a single executable of the code. e.g.:
```bash
./debug.sh train
```

If needed, you may also call the clean target, to make clean and recreate Cmake configs. e.g.:
```bash
./profiling.sh clean
```

The number of CPUs used in the compilation is determined automatically, but limited by default to 8 threads. This is to avoid out of memory issues when running on low memory machines. This can be increased in the `unix_compile.config` file:
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
