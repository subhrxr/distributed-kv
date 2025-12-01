cmake_minimum_required(VERSION 3.16)

# Suppress "This warning is for project developers" messages
set(CMAKE_SUPPRESS_DEVELOPER_WARNINGS TRUE CACHE BOOL "" FORCE)

# When using FetchContent with a URL, ask CMake to stamp extracted files with the extraction time
# (prevents CMP0135 warning)
set(FETCHCONTENT_DOWNLOADEXTRACTTIMESTAMP TRUE CACHE BOOL "" FORCE)

project(distributed_kv LANGUAGES CXX)

# --- Options ---
option(ENABLE_SANITIZERS "Enable ASan/TSan/UBSan (only for non-Release builds)" OFF)
option(BUILD_TESTS "Build unit tests" ON)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Default to RelWithDebInfo in CI if not set
if(NOT CMAKE_BUILD_TYPE)
  set(CMAKE_BUILD_TYPE "RelWithDebInfo" CACHE STRING "Build type" FORCE)
endif()

# Optional: show compile/link commands when building (useful for verbose builds).
# Keep default OFF in normal runs; the Makefile provided calls 'debug' for full output.
set(CMAKE_VERBOSE_MAKEFILE OFF)

# Put runtime output and libraries into the top-level binary dir (build/)
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR})
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR})
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR})

# Compiler warnings
if (MSVC)
  add_compile_options(/W4)
else()
  add_compile_options(-Wall -Wextra -Wpedantic)
endif()

# Sanitizers (optional)
if(ENABLE_SANITIZERS)
  if(NOT CMAKE_BUILD_TYPE STREQUAL "Release")
    message(STATUS "Sanitizers enabled")
    add_compile_options(-fsanitize=address,undefined,thread -fno-omit-frame-pointer)
    # link sanitizers into executables
    set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -fsanitize=address -fsanitize=undefined -fsanitize=thread")
  else()
    message(WARNING "ENABLE_SANITIZERS=ON but build type is Release. Sanitizers ignored.")
  endif()
endif()

# Add subdirectories
add_subdirectory(src)

# Tests — fetch GoogleTest if needed
if(BUILD_TESTS)
  include(FetchContent)
  FetchContent_Declare(
    googletest
    URL https://github.com/google/googletest/archive/refs/heads/main.zip
    DOWNLOAD_EXTRACT_TIMESTAMP TRUE
  )
  FetchContent_MakeAvailable(googletest)

  enable_testing()
  add_subdirectory(test)
endif()

# Install rules (optional)
include(GNUInstallDirs)
install(TARGETS kv_node
        RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR})

# run-nobuild target: execute kv_node without triggering a build
if(TARGET kv_node)
  add_custom_target(run-nobuild
    COMMAND ${CMAKE_COMMAND} -E echo "Running kv_node (no build)..."
    COMMAND ${CMAKE_COMMAND} -E chdir ${CMAKE_BINARY_DIR} $<TARGET_FILE:kv_node>
    WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
    USES_TERMINAL
  )
endif()
