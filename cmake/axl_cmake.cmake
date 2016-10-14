# to make use of AXL cmake build infrastructure, copy this file into
# your project directory and include it in master CMakeLists.txt like this:

# include (axl_cmake.cmake NO_POLICY_SCOPE)

#..............................................................................

# excerpt from axl_utils.cmake

macro (
axl_calc_max_string_length
	_RESULT
	# ...
	)

	set (_STRING_LIST ${ARGN})

	set (_MAX_LENGTH 0)
	foreach (_STRING ${_STRING_LIST})
		string (LENGTH ${_STRING} _LENGTH)
		if (${_LENGTH} GREATER ${_MAX_LENGTH})
			set (_MAX_LENGTH ${_LENGTH})
		endif ()
	endforeach ()

	set (${_RESULT} ${_MAX_LENGTH})
endmacro ()

macro (
axl_create_space_padding
	_RESULT
	_STRING
	_MAX_LENGTH
	)

	string (LENGTH ${_STRING} _LENGTH)
	math (EXPR _PADDING_LENGTH "${_MAX_LENGTH} - ${_LENGTH} + 1")
	string (RANDOM LENGTH ${_PADDING_LENGTH} ALPHABET " " ${_RESULT})
endmacro ()

macro (
	axl_create_empty_setting_file
	_FILE_NAME
	# ...
	)

	set (_SETTING_LIST ${ARGN})

	axl_calc_max_string_length (_MAX_LENGTH ${_SETTING_LIST})

	set (_CONTENTS "#\n")
	set (_CONTENTS "${_CONTENTS}# This is an auto-generated setting file\n")
	set (_CONTENTS "${_CONTENTS}# Fill it by hand with proper settings\n")
	set (_CONTENTS "${_CONTENTS}#\n\n")

	foreach (_SETTING ${_SETTING_LIST})
		axl_create_space_padding (_PADDING ${_SETTING} ${_MAX_LENGTH})
		set (_CONTENTS "${_CONTENTS}set (${_SETTING}${_PADDING}${_SETTING}-NOTFOUND)\n")
	endforeach ()

	file (WRITE ${_FILE_NAME} ${_CONTENTS})
endmacro ()

macro (
axl_find_file
	_RESULT
	_FILE_NAME
	# ...
	)

	set (_DIR_LIST ${ARGN})

	set (_FILE_PATH ${_FILE_NAME}-NOTFOUND)

	foreach (_DIR ${_DIR_LIST})
		if (EXISTS ${_DIR}/${_FILE_NAME})
			set (_FILE_PATH ${_DIR}/${_FILE_NAME})
			break ()
		endif ()
	endforeach ()

	set (${_RESULT} ${_FILE_PATH})
endmacro ()

macro (
axl_find_file_recurse_parent_dirs
	_RESULT
	_FILE_NAME
	_START_DIR
	)

	set (_DIR ${_START_DIR})

	while (TRUE)
		if (EXISTS ${_DIR}/${_FILE_NAME})
			set (_FILE_PATH ${_DIR}/${_FILE_NAME})
			break ()
		endif ()

		get_filename_component (_PARENT_DIR "${_DIR}/.." ABSOLUTE)

		if (${_DIR} STREQUAL ${_PARENT_DIR})
			set (_FILE_PATH ${_FILE_NAME}-NOTFOUND)
			break ()
		endif ()

		set (_DIR ${_PARENT_DIR})
	endwhile ()

	set (${_RESULT} ${_FILE_PATH})
endmacro ()

#..............................................................................

# make sure dependencies.cmake is where it's supposed to be

if (NOT EXISTS ${CMAKE_SOURCE_DIR}/dependencies.cmake)
	message (FATAL_ERROR "dependencies.cmake not found (must be in the root dir)")
endif ()

# find paths.cmake; if not found, generate a new one based on AXL_PATH_LIST from dependencies.cmake

axl_find_file_recurse_parent_dirs (_PATHS_CMAKE paths.cmake ${CMAKE_CURRENT_LIST_DIR})

if (NOT _PATHS_CMAKE)
	include (${CMAKE_SOURCE_DIR}/dependencies.cmake)

	axl_create_empty_setting_file (
		${CMAKE_SOURCE_DIR}/paths.cmake
		${AXL_PATH_LIST}
		)

	message (FATAL_ERROR "please fill the newly generated ${CMAKE_SOURCE_DIR}/paths.cmake")
endif ()

# include paths.cmake to get AXL_CMAKE_DIR; then find and include axl_init.cmake

include (${_PATHS_CMAKE})

if (NOT AXL_CMAKE_DIR)
	message (FATAL_ERROR "AXL_CMAKE_DIR not found (check your paths.cmake)")
endif ()

axl_find_file (_AXL_INIT_CMAKE axl_init.cmake ${AXL_CMAKE_DIR})

if (NOT _AXL_INIT_CMAKE)
	message (FATAL_ERROR "axl_init.cmake not found (check AXL_CMAKE_DIR in your paths.cmake)")
endif ()

# include axl_init.cmake, paths.cmake, and dependencies.cmake
# this time ${CONFIGURATION_SUFFIX} and all the other settings are defined

include (${_AXL_INIT_CMAKE} NO_POLICY_SCOPE)
include (${_PATHS_CMAKE})
include (${CMAKE_SOURCE_DIR}/dependencies.cmake)

# find and include settings.cmake

axl_find_file_recurse_parent_dirs (_SETTINGS_CMAKE settings.cmake ${CMAKE_CURRENT_LIST_DIR})

if (_SETTINGS_CMAKE)
	include (${_SETTINGS_CMAKE})
endif ()

# diagnostic printing

axl_print_std_settings ()

get_cmake_property (_VARIABLE_LIST VARIABLES)

string (REPLACE ";" "\$|^" _FILTER "^${AXL_PATH_LIST}\$")
axl_filter_list (_FILTERED_VARIABLE_LIST ${_FILTER} ${_VARIABLE_LIST})

message(STATUS "Path defintions in ${_PATHS_CMAKE}:")

axl_print_variable_list ("    " ${_FILTERED_VARIABLE_LIST})

# import modules (if dependencies.cmake defines any imports)

if (AXL_IMPORT_LIST)
	axl_import (${AXL_IMPORT_LIST})
endif ()

#..............................................................................
