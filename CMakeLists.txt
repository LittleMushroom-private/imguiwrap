# imguiwrap provides a cmakelists for incorporating imgui into other projects.
#
# Currently, it assumes an opengl implementation using the vendored glfw library.
#
# This has been the only backend I've had reason to use, and I didn't want to
# do a half-baked job of introducing support for other backends.
#
# Pull-requests that introduce support for selecting one or more alternate backend
# are welcome.
#
cmake_minimum_required(VERSION 3.16)

if (NOT DEFINED CMAKE_CXX_STANDARD)
set (IMGUIWRAP_CXX_STANDARD "20" CACHE STRING "Specify the C++ standard to use (must be 17 or higher")

set (CMAKE_CXX_STANDARD "${IMGUIWRAP_CXX_STANDARD}")
endif()

# strongly encouraged to enable this globally to avoid conflicts between
# -Wpedantic being enabled and -std=c++20 and -std=gnu++20 for example
# when compiling with PCH enabled
set(CMAKE_CXX_EXTENSIONS on)

set (IMGUIWRAP_BACKEND "GL3W" CACHE STRING "Specify the imgui backend")
if (IMGUIWRAP_BACKEND STREQUAL "GL3W")
	add_compile_definitions(IMGUI_IMPL_OPENGL_LOADER_GL3W)
endif ()

set (IMGUI_PLATFORM_BACKEND "glfw" CACHE STRING "Specify which imgui platform backend to use")
set (IMGUI_RENDERER_BACKEND "opengl3" CACHE STRING "Specify which imgui renderer backend to use")

project ("imguiwrap")

include(cmake/PreventInSourceBuilds.cmake)
include(ProjectOptions.cmake)


imguiwrap_setup_options()

imguiwrap_global_options()
include(Dependencies.cmake)
imguiwrap_setup_dependencies()

imguiwrap_local_options()

# Are we standalone?
if ("${CMAKE_SOURCE_DIR}" STREQUAL "${CMAKE_CURRENT_SOURCE_DIR}")
	set(IMGUIWRAP_STANDALONE TRUE)
endif()

add_subdirectory(src)
