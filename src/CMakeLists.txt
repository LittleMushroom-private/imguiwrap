cmake_minimum_required (VERSION 3.16)

option (USE_CLANG_TIDY "Enable clang-tidy at build time" ON)
if (USE_CLANG_TIDY)
	find_program (CLANG_TIDY 
			NAMES
				"clang-tidy"
				"clang-tidy-9"
				"clang-tidy-10" 
				"clang-tidy-11" 
				"clang-tidy-12" 
				"clang-tidy-13" 
				"clang-tidy-14"
				"clang-tidy-19"
	)
	if (NOT CLANG_TIDY)
		MESSAGE(WARNING "USE_CLANG_TIDY is ON but no clang-tidy executable found.")
		SET (CMAKE_CXX_CLANG_TIDY "")
	else ()
		# '-checks' will be sourced from the .clang-tidy file
		set (CMAKE_CXX_CLANG_TIDY
			"${CLANG_TIDY}"
			-header-filter=imguiwrap*.h
			-format-style=file
		)
		MESSAGE(STATUS "USE_CLANG_TIDY is on and CLANG_TIDY is ${CLANG_TIDY}, command line is ${CMAKE_CXX_CLANG_TIDY}")
	endif ()
endif ()

project(imguiwrap
	VERSION 0.1.0
	DESCRIPTION ""
	HOMEPAGE_URL "https://github.com/LittleMushroom-private/imguiwrap.git"
	LANGUAGES CXX C
)


add_library(
	imguiwrap

	imguiwrap.cpp
	imguiwrap.h
	imguiwrap.helpers.h
	imguiwrap.dear.h
)

add_library(imguiwrap::imguiwrap ALIAS imguiwrap)

target_link_libraries(
	imguiwrap

	PUBLIC

	imguiwrap_options
	imguiwrap_warnings
	imgui
)

target_include_directories(
	imguiwrap

	SYSTEM PUBLIC

	${CMAKE_CURRENT_SOURCE_DIR}
)

target_include_directories(
	imguiwrap

	PRIVATE

	${CMAKE_CURRENT_SOURCE_DIR}
)



target_compile_options(imguiwrap PRIVATE ${IMGW_NO_RTTI} ${IMGW_NO_EXCEPTIONS} ${IMGW_ALL_WARNINGS})

if (IMGUIWRAP_STANDALONE)
	add_subdirectory(example)
endif ()
