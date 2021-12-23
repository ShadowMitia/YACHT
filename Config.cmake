# Enable address sanitizer.
set_option(ASAN OFF)

# Enable Cpp Check, if available.
set_option(CPP_CHECK OFF)

# Enable Clang tidy, if available.
set_option(CLANG_TIDY OFF)

# Enable Include-what-you-use, if available.
set_option(INCLUDE_WHAT_YOU_USE OFF)

# Enable google Gtest testing platform.
set_option(GTEST OFF)
set_option(GTEST_DOWNLOAD_IF_MISSING OFF)


# Use Conan package manager
set_option(CONAN OFF)
set_option(CONAN_VERBOSE OFF)

# Use vcpkg package manager
set_option(VCPKG OFF)
set_option(VCPKG_VERBOSE OFF)
set_option(VCPKG_LOCATION "")
set_option(VCPKG_LOCAL_DOWNLOAD OFF) # will download in ./build/ directory
