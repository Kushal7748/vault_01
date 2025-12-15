# The Flutter tooling requires that developers have a version of Visual Studio
# installed that includes CMake 3.14 or later. You should not increase this
# version, as doing so will cause the plugin to fail to compile for some
# customers of the plugin.
cmake_minimum_required(VERSION 3.14)

# Project-level configuration.
set(PROJECT_NAME "rust_lib_vault_01")
project(${PROJECT_NAME} LANGUAGES CXX)

include("../cargokit/cmake/cargokit.cmake")
set(PREBUILT_DLL "${CMAKE_CURRENT_SOURCE_DIR}/../../../../../../rust/target/debug/rust_lib_vault_01.dll")

# Prefer a prebuilt DLL if it exists. This helps avoid Windows-specific
# issues where the cargokit custom build step fails to create or rename
# temporary build-script executables (commonly caused by AV or file locks).
if(EXISTS "${PREBUILT_DLL}")
  message(STATUS "Found prebuilt Rust DLL at ${PREBUILT_DLL}; using it instead of invoking cargokit.")
  set(rust_lib_vault_01_bundled_libraries
    "${PREBUILT_DLL}"
    PARENT_SCOPE
  )
elseif(DEFINED ENV{CARGOKIT_USE_PREBUILT})
  message(FATAL_ERROR "CARGOKIT_USE_PREBUILT is set but prebuilt DLL not found at: ${PREBUILT_DLL}")
else()
  apply_cargokit(${PROJECT_NAME} ../../../../../../rust rust_lib_vault_01 "")

  # List of absolute paths to libraries that should be bundled with the plugin.
  # This list could contain prebuilt libraries, or libraries created by an
  # external build triggered from this build file.
  set(rust_lib_vault_01_bundled_libraries
    "${${PROJECT_NAME}_cargokit_lib}"
    PARENT_SCOPE
  )
endif()
