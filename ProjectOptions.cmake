include(cmake/SystemLink.cmake)
include(cmake/LibFuzzer.cmake)
include(CMakeDependentOption)
include(CheckCXXCompilerFlag)


macro(imguiwrap_supports_sanitizers)
  if((CMAKE_CXX_COMPILER_ID MATCHES ".*Clang.*" OR CMAKE_CXX_COMPILER_ID MATCHES ".*GNU.*") AND NOT WIN32)
    set(SUPPORTS_UBSAN ON)
  else()
    set(SUPPORTS_UBSAN OFF)
  endif()

  if((CMAKE_CXX_COMPILER_ID MATCHES ".*Clang.*" OR CMAKE_CXX_COMPILER_ID MATCHES ".*GNU.*") AND WIN32)
    set(SUPPORTS_ASAN OFF)
  else()
    set(SUPPORTS_ASAN ON)
  endif()
endmacro()

macro(imguiwrap_setup_options)
  option(imguiwrap_ENABLE_HARDENING "Enable hardening" ON)
  option(imguiwrap_ENABLE_COVERAGE "Enable coverage reporting" OFF)
  cmake_dependent_option(
    imguiwrap_ENABLE_GLOBAL_HARDENING
    "Attempt to push hardening options to built dependencies"
    ON
    imguiwrap_ENABLE_HARDENING
    OFF)

  imguiwrap_supports_sanitizers()

  if(NOT PROJECT_IS_TOP_LEVEL OR imguiwrap_PACKAGING_MAINTAINER_MODE)
    option(imguiwrap_ENABLE_IPO "Enable IPO/LTO" OFF)
    option(imguiwrap_WARNINGS_AS_ERRORS "Treat Warnings As Errors" OFF)
    option(imguiwrap_ENABLE_USER_LINKER "Enable user-selected linker" OFF)
    option(imguiwrap_ENABLE_SANITIZER_ADDRESS "Enable address sanitizer" OFF)
    option(imguiwrap_ENABLE_SANITIZER_LEAK "Enable leak sanitizer" OFF)
    option(imguiwrap_ENABLE_SANITIZER_UNDEFINED "Enable undefined sanitizer" OFF)
    option(imguiwrap_ENABLE_SANITIZER_THREAD "Enable thread sanitizer" OFF)
    option(imguiwrap_ENABLE_SANITIZER_MEMORY "Enable memory sanitizer" OFF)
    option(imguiwrap_ENABLE_UNITY_BUILD "Enable unity builds" OFF)
    option(imguiwrap_ENABLE_CLANG_TIDY "Enable clang-tidy" OFF)
    option(imguiwrap_ENABLE_CPPCHECK "Enable cpp-check analysis" OFF)
    option(imguiwrap_ENABLE_PCH "Enable precompiled headers" OFF)
    option(imguiwrap_ENABLE_CACHE "Enable ccache" OFF)
  else()
    option(imguiwrap_ENABLE_IPO "Enable IPO/LTO" ON)
    # produce warning: optimization flag '-fno-fat-lto-objects' is not supported
    # option(imguiwrap_ENABLE_IPO "Enable IPO/LTO" OFF)
    # option(imguiwrap_WARNINGS_AS_ERRORS "Treat Warnings As Errors" ON)
    # suppress warning as error above
    option(imguiwrap_WARNINGS_AS_ERRORS "Treat Warnings As Errors" OFF)
    option(imguiwrap_ENABLE_USER_LINKER "Enable user-selected linker" OFF)
    option(imguiwrap_ENABLE_SANITIZER_ADDRESS "Enable address sanitizer" ${SUPPORTS_ASAN})
    option(imguiwrap_ENABLE_SANITIZER_LEAK "Enable leak sanitizer" OFF)
    option(imguiwrap_ENABLE_SANITIZER_UNDEFINED "Enable undefined sanitizer" ${SUPPORTS_UBSAN})
    option(imguiwrap_ENABLE_SANITIZER_THREAD "Enable thread sanitizer" OFF)
    option(imguiwrap_ENABLE_SANITIZER_MEMORY "Enable memory sanitizer" OFF)
    option(imguiwrap_ENABLE_UNITY_BUILD "Enable unity builds" OFF)
    option(imguiwrap_ENABLE_CLANG_TIDY "Enable clang-tidy" ON)
    option(imguiwrap_ENABLE_CPPCHECK "Enable cpp-check analysis" ON)
    option(imguiwrap_ENABLE_PCH "Enable precompiled headers" OFF)
    option(imguiwrap_ENABLE_CACHE "Enable ccache" ON)
  endif()

  if(NOT PROJECT_IS_TOP_LEVEL)
    mark_as_advanced(
      imguiwrap_ENABLE_IPO
      imguiwrap_WARNINGS_AS_ERRORS
      imguiwrap_ENABLE_USER_LINKER
      imguiwrap_ENABLE_SANITIZER_ADDRESS
      imguiwrap_ENABLE_SANITIZER_LEAK
      imguiwrap_ENABLE_SANITIZER_UNDEFINED
      imguiwrap_ENABLE_SANITIZER_THREAD
      imguiwrap_ENABLE_SANITIZER_MEMORY
      imguiwrap_ENABLE_UNITY_BUILD
      imguiwrap_ENABLE_CLANG_TIDY
      imguiwrap_ENABLE_CPPCHECK
      imguiwrap_ENABLE_COVERAGE
      imguiwrap_ENABLE_PCH
      imguiwrap_ENABLE_CACHE)
  endif()

  imguiwrap_check_libfuzzer_support(LIBFUZZER_SUPPORTED)
  if(LIBFUZZER_SUPPORTED AND (imguiwrap_ENABLE_SANITIZER_ADDRESS OR imguiwrap_ENABLE_SANITIZER_THREAD OR imguiwrap_ENABLE_SANITIZER_UNDEFINED))
    set(DEFAULT_FUZZER ON)
  else()
    set(DEFAULT_FUZZER OFF)
  endif()

  option(imguiwrap_BUILD_FUZZ_TESTS "Enable fuzz testing executable" ${DEFAULT_FUZZER})

endmacro()

macro(imguiwrap_global_options)
  if(imguiwrap_ENABLE_IPO)
    include(cmake/InterproceduralOptimization.cmake)
    imguiwrap_enable_ipo()
  endif()

  imguiwrap_supports_sanitizers()

  if(imguiwrap_ENABLE_HARDENING AND imguiwrap_ENABLE_GLOBAL_HARDENING)
    include(cmake/Hardening.cmake)
    if(NOT SUPPORTS_UBSAN 
       OR imguiwrap_ENABLE_SANITIZER_UNDEFINED
       OR imguiwrap_ENABLE_SANITIZER_ADDRESS
       OR imguiwrap_ENABLE_SANITIZER_THREAD
       OR imguiwrap_ENABLE_SANITIZER_LEAK)
      set(ENABLE_UBSAN_MINIMAL_RUNTIME FALSE)
    else()
      set(ENABLE_UBSAN_MINIMAL_RUNTIME TRUE)
    endif()
    message("${imguiwrap_ENABLE_HARDENING} ${ENABLE_UBSAN_MINIMAL_RUNTIME} ${imguiwrap_ENABLE_SANITIZER_UNDEFINED}")
    imguiwrap_enable_hardening(imguiwrap_options ON ${ENABLE_UBSAN_MINIMAL_RUNTIME})
  endif()
endmacro()

macro(imguiwrap_local_options)
  if(PROJECT_IS_TOP_LEVEL)
    include(cmake/StandardProjectSettings.cmake)
  endif()

  add_library(imguiwrap_warnings INTERFACE)
  add_library(imguiwrap_options INTERFACE)

  include(cmake/CompilerWarnings.cmake)
  imguiwrap_set_project_warnings(
    imguiwrap_warnings
    ${imguiwrap_WARNINGS_AS_ERRORS}
    ""
    ""
    ""
    "")

  if(imguiwrap_ENABLE_USER_LINKER)
    include(cmake/Linker.cmake)
    imguiwrap_configure_linker(imguiwrap_options)
  endif()

  include(cmake/Sanitizers.cmake)
  imguiwrap_enable_sanitizers(
    imguiwrap_options
    ${imguiwrap_ENABLE_SANITIZER_ADDRESS}
    ${imguiwrap_ENABLE_SANITIZER_LEAK}
    ${imguiwrap_ENABLE_SANITIZER_UNDEFINED}
    ${imguiwrap_ENABLE_SANITIZER_THREAD}
    ${imguiwrap_ENABLE_SANITIZER_MEMORY})

  set_target_properties(imguiwrap_options PROPERTIES UNITY_BUILD ${imguiwrap_ENABLE_UNITY_BUILD})

  if(imguiwrap_ENABLE_PCH)
    target_precompile_headers(
      imguiwrap_options
      INTERFACE
      <vector>
      <string>
      <utility>)
  endif()

  if(imguiwrap_ENABLE_CACHE)
    include(cmake/Cache.cmake)
    imguiwrap_enable_cache()
  endif()

  include(cmake/StaticAnalyzers.cmake)
  if(imguiwrap_ENABLE_CLANG_TIDY)
    imguiwrap_enable_clang_tidy(imguiwrap_options ${imguiwrap_WARNINGS_AS_ERRORS})
  endif()

  if(imguiwrap_ENABLE_CPPCHECK)
    imguiwrap_enable_cppcheck(${imguiwrap_WARNINGS_AS_ERRORS} "" # override cppcheck options
    )
  endif()

  if(imguiwrap_ENABLE_COVERAGE)
    include(cmake/Tests.cmake)
    imguiwrap_enable_coverage(imguiwrap_options)
  endif()

  if(imguiwrap_WARNINGS_AS_ERRORS)
    check_cxx_compiler_flag("-Wl,--fatal-warnings" LINKER_FATAL_WARNINGS)
    if(LINKER_FATAL_WARNINGS)
      # This is not working consistently, so disabling for now
      # target_link_options(imguiwrap_options INTERFACE -Wl,--fatal-warnings)
    endif()
  endif()

  if(imguiwrap_ENABLE_HARDENING AND NOT imguiwrap_ENABLE_GLOBAL_HARDENING)
    include(cmake/Hardening.cmake)
    if(NOT SUPPORTS_UBSAN 
       OR imguiwrap_ENABLE_SANITIZER_UNDEFINED
       OR imguiwrap_ENABLE_SANITIZER_ADDRESS
       OR imguiwrap_ENABLE_SANITIZER_THREAD
       OR imguiwrap_ENABLE_SANITIZER_LEAK)
      set(ENABLE_UBSAN_MINIMAL_RUNTIME FALSE)
    else()
      set(ENABLE_UBSAN_MINIMAL_RUNTIME TRUE)
    endif()
    imguiwrap_enable_hardening(imguiwrap_options OFF ${ENABLE_UBSAN_MINIMAL_RUNTIME})
  endif()

endmacro()
