project(circlecitest)


cmake_minimum_required(VERSION 3.1)

# Fix behavior of CMAKE_CXX_STANDARD when targeting macOS.
if (POLICY CMP0025)
  cmake_policy(SET CMP0025 NEW)
endif ()


set(MAJOR_VERSION 0)
set(MINOR_VERSION 0)
set(PATCH_VERSION 1)

set(VERSION ${MAJOR_VERSION}.${MINOR_VERSION}.${PATCH_VERSION})

set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

set(CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/CMakeModules")

include(Macros)
include(CTest)

if ("${CMAKE_CXX_COMPILER_ID}" STREQUAL "Clang")
    set(CMAKE_CXX_FLAGS  "${CMAKE_CXX_FLAGS} -Wno-gnu-anonymous-struct")
endif()

# native stuff
if(NOT DEFINED EMSCRIPTEN)
    find_package(OpenGL REQUIRED)
    find_package(glfw3 REQUIRED)
    set(CLANG_FORMAT_EXCLUDE_PATTERNS "build/" "deps/")
    include("${CMAKE_MODULE_PATH}/ClangFormat.cmake")
endif(NOT DEFINED EMSCRIPTEN)

add_subdirectory(src)

if(BUILD_TESTING)
    add_subdirectory(test)
endif()
