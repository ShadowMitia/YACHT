# Enable address sanitizer.
set_option(ASAN OFF)

# Enable Cpp Check, if available.
set_option(CPP_CHECK OFF)

# Enable Clang tidy, if available.
set_option(CLANG_TIDY OFF)

# Enable Include-what-you-use, if available.
set_option(INCLUDE_WHAT_YOU_USE OFF)

# Enable Ccache, if available.
set_option(CCACHE OFF)

# Enable google Gtest testing platform.
set_option(GTEST_DOWNLOAD_IF_MISSING OFF)

# Enable Catch2 testing platform.
set_option(CATCH2_DOWNLOAD_IF_MISSING OFF)

# Use Conan package manager
set_option(CONAN_VERBOSE OFF)

# Use vcpkg package manager
set_option(VCPKG_VERBOSE OFF)
set_option_path(VCPKG_LOCATION "~/vcpkg/")
set_option(VCPKG_LOCAL_DOWNLOAD OFF) # will download in ./build/ directory
