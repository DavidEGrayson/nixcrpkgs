cmake_minimum_required (VERSION 2.8)
project (p-load)

message("hello cxx11 = ${CMAKE_CXX11_EXTENSION_COMPILE_OPTION}")

find_package(PkgConfig)

# Make 'Release' be the default build type.
if (NOT CMAKE_BUILD_TYPE)
  set (CMAKE_BUILD_TYPE "Release" CACHE STRING
    "Options are Debug Release RelWithDebInfo MinSizeRel" FORCE)
endif ()

set(USE_SYSTEM_TINYXML2 FALSE CACHE BOOL
  "True if you want to use TinyXML-2 from the system instead of the bundled one.")

# Our C++ code uses features from the C++11 standard.
macro(use_cxx11)
    set (CMAKE_CXX_STANDARD 14)
endmacro(use_cxx11)

set (P_LOAD_VERSION_MAJOR 2)
set (P_LOAD_VERSION_MINOR 1)
set (P_LOAD_VERSION_PATCH 0)

set (P_LOAD_VERSION ${P_LOAD_VERSION_MAJOR}.${P_LOAD_VERSION_MINOR}.${P_LOAD_VERSION_PATCH})

# Don't use -rdynamic since it causes musl static linking to not work.
cmake_policy(SET CMP0065 NEW)

if (CMAKE_VERSION VERSION_GREATER "2.8.10")
  string(TIMESTAMP YEAR "%Y")
endif ()

# Put libraries and executables in the top level of the build directory.
set (CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR})
set (CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR})

# Warn about everything.
set (CMAKE_C_FLAGS "-Wall -Wextra ${CMAKE_C_FLAGS}")
set (CMAKE_CXX_FLAGS "-Wall -Wextra ${CMAKE_CXX_FLAGS}")

if (WIN32)

  # Enable correct behavior for the return value of vsnprintf.
  add_definitions (-D__USE_MINGW_ANSI_STDIO=1)

endif ()

# Detect Linux.
if (CMAKE_SYSTEM_NAME STREQUAL "Linux")
  set (LINUX 1)
endif ()

file(WRITE "${CMAKE_BINARY_DIR}/version.txt" "${P_LOAD_VERSION}")

add_subdirectory (src)

if (APPLE)
  add_subdirectory (mac-installer)
endif ()

if (WIN32)
  add_subdirectory (windows-installer)
endif ()

if (NOT USE_SYSTEM_TINYXML2)
  add_subdirectory (tinyxml2)
endif ()

