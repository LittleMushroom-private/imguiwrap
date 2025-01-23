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
cmake_minimum_required(VERSION 3.20)

set(IMGUIWRAP_CXX_STANDARD "23" CACHE STRING "Specify the C++ standard to use (must be 23 or higher")

set(CMAKE_CXX_STANDARD "${IMGUIWRAP_CXX_STANDARD}")
set(CMAKE_CXX_STANDARD_REQUIRED ON)

set(IMGUIWRAP_BACKEND "GL3W" CACHE STRING "Specify the imgui backend")

if(IMGUIWRAP_BACKEND STREQUAL "GL3W")
	add_compile_definitions(IMGUI_IMPL_OPENGL_LOADER_GL3W)
endif()

project(imguiwrap
	VERSION 0.1.1
	DESCRIPTION "Wrapper on Imgui with CMake support"
	HOMEPAGE_URL "https://github.com/LittleMushroom-private/imguiwrap.git"
	LANGUAGES CXX C
)

include(cmake/PreventInSourceBuilds.cmake)
include(ProjectOptions.cmake)

imguiwrap_setup_options()
imguiwrap_global_options()
add_subdirectory(vendor)

imguiwrap_local_options()

target_compile_features(imguiwrap_options INTERFACE cxx_std_${IMGUIWRAP_CXX_STANDARD})

add_library(imguiwrap::imguiwrap_options ALIAS imguiwrap_options)
add_library(imguiwrap::imguiwrap_warnings ALIAS imguiwrap_warnings)

# Are we standalone?
if("${CMAKE_SOURCE_DIR}" STREQUAL "${CMAKE_CURRENT_SOURCE_DIR}")
	set(IMGUIWRAP_STANDALONE TRUE)
endif()



add_subdirectory(src)

if(CMAKE_SKIP_INSTALL_RULES)
	return()
endif()

#include(cmake/PackageProject.cmake)
#
#imguiwrap_package_project(
#	TARGETS
#	imguiwrap
#	imguiwrap_options
#	imguiwrap_warnings
#	imgui
#	glfw
#)
