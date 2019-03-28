# These macros come from src/corelib/Qt5CoreMacros.cmake originally.

#=============================================================================
# Copyright 2005-2011 Kitware, Inc.
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
#
# * Redistributions of source code must retain the above copyright
#   notice, this list of conditions and the following disclaimer.
#
# * Redistributions in binary form must reproduce the above copyright
#   notice, this list of conditions and the following disclaimer in the
#   documentation and/or other materials provided with the distribution.
#
# * Neither the name of Kitware, Inc. nor the names of its
#   contributors may be used to endorse or promote products derived
#   from this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
# "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
# LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
# A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
# HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
# SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
# LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
# DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
# THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#=============================================================================

macro(QT5_MAKE_OUTPUT_FILE infile prefix ext outfile )
  string(LENGTH ${CMAKE_CURRENT_BINARY_DIR} _binlength)
  string(LENGTH ${infile} _infileLength)
  set(_checkinfile ${CMAKE_CURRENT_SOURCE_DIR})
  if(_infileLength GREATER _binlength)
    string(SUBSTRING "${infile}" 0 ${_binlength} _checkinfile)
    if(_checkinfile STREQUAL "${CMAKE_CURRENT_BINARY_DIR}")
      file(RELATIVE_PATH rel ${CMAKE_CURRENT_BINARY_DIR} ${infile})
    else()
      file(RELATIVE_PATH rel ${CMAKE_CURRENT_SOURCE_DIR} ${infile})
    endif()
  else()
    file(RELATIVE_PATH rel ${CMAKE_CURRENT_SOURCE_DIR} ${infile})
  endif()
  if(WIN32 AND rel MATCHES "^([a-zA-Z]):(.*)$") # absolute path
    set(rel "${CMAKE_MATCH_1}_${CMAKE_MATCH_2}")
  endif()
  set(_outfile "${CMAKE_CURRENT_BINARY_DIR}/${rel}")
  string(REPLACE ".." "__" _outfile ${_outfile})
  get_filename_component(outpath ${_outfile} PATH)
  get_filename_component(_outfile ${_outfile} NAME_WE)
  file(MAKE_DIRECTORY ${outpath})
  set(${outfile} ${outpath}/${prefix}${_outfile}.${ext})
endmacro()

function(_QT5_PARSE_QRC_FILE infile _out_depends _rc_depends)
  get_filename_component(rc_path ${infile} PATH)
  if(EXISTS "${infile}")
    file(READ "${infile}" RC_FILE_CONTENTS)
    string(REGEX MATCHALL "<file[^<]+" RC_FILES "${RC_FILE_CONTENTS}")
    foreach(RC_FILE ${RC_FILES})
      string(REGEX REPLACE "^<file[^>]*>" "" RC_FILE "${RC_FILE}")
      if(NOT IS_ABSOLUTE "${RC_FILE}")
        set(RC_FILE "${rc_path}/${RC_FILE}")
      endif()
      set(RC_DEPENDS ${RC_DEPENDS} "${RC_FILE}")
    endforeach()
    qt5_make_output_file("${infile}" "" "qrc.depends" out_depends)
    configure_file("${infile}" "${out_depends}" COPYONLY)
  else()
    set(out_depends)
  endif()
  set(${_out_depends} ${out_depends} PARENT_SCOPE)
  set(${_rc_depends} ${RC_DEPENDS} PARENT_SCOPE)
endfunction()

function(QT5_ADD_RESOURCES outfiles )
  set(options)
  set(oneValueArgs)
  set(multiValueArgs OPTIONS)
  cmake_parse_arguments(_RCC "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})
  set(rcc_files ${_RCC_UNPARSED_ARGUMENTS})
  set(rcc_options ${_RCC_OPTIONS})

  if("${rcc_options}" MATCHES "-binary")
    message(WARNING "Use qt5_add_binary_resources for binary option")
  endif()

  foreach(it ${rcc_files})
    get_filename_component(outfilename ${it} NAME_WE)
    get_filename_component(infile ${it} ABSOLUTE)
    set(outfile ${CMAKE_CURRENT_BINARY_DIR}/qrc_${outfilename}.cpp)
    _QT5_PARSE_QRC_FILE(${infile} _out_depends _rc_depends)
    add_custom_command(OUTPUT ${outfile}
                       COMMAND ${Qt5Core_RCC_EXECUTABLE}
                       ARGS ${rcc_options} --name ${outfilename} --output ${outfile} ${infile}
                       MAIN_DEPENDENCY ${infile}
                       DEPENDS ${_rc_depends} "${out_depends}" VERBATIM)
    list(APPEND ${outfiles} ${outfile})
  endforeach()
  set(${outfiles} ${${outfiles}} PARENT_SCOPE)
endfunction()

# qt5_create_moc_command
function(QT5_CREATE_MOC_COMMAND infile outfile moc_flags moc_options moc_target moc_depends)
    get_filename_component(_moc_outfile_name "${outfile}" NAME)
    get_filename_component(_moc_outfile_dir "${outfile}" PATH)
    if(_moc_outfile_dir)
        set(_moc_working_dir WORKING_DIRECTORY ${_moc_outfile_dir})
    endif()
    set (_moc_parameters_file ${outfile}_parameters)
    set (_moc_parameters ${moc_flags} ${moc_options} -o "${outfile}" "${infile}")
    string (REPLACE ";" "\n" _moc_parameters "${_moc_parameters}")

    if(moc_target)
        set(_moc_parameters_file ${_moc_parameters_file}$<$<BOOL:$<CONFIGURATION>>:_$<CONFIGURATION>>)
        set(targetincludes "$<TARGET_PROPERTY:${moc_target},INCLUDE_DIRECTORIES>")
        set(targetdefines "$<TARGET_PROPERTY:${moc_target},COMPILE_DEFINITIONS>")

        set(targetincludes "$<$<BOOL:${targetincludes}>:-I$<JOIN:${targetincludes},\n-I>\n>")
        set(targetdefines "$<$<BOOL:${targetdefines}>:-D$<JOIN:${targetdefines},\n-D>\n>")

        file (GENERATE
            OUTPUT ${_moc_parameters_file}
            CONTENT "${targetdefines}${targetincludes}${_moc_parameters}\n"
        )

        set(targetincludes)
        set(targetdefines)
    else()
        file(WRITE ${_moc_parameters_file} "${_moc_parameters}\n")
    endif()

    set(_moc_extra_parameters_file @${_moc_parameters_file})
    add_custom_command(OUTPUT ${outfile}
                       COMMAND ${Qt5Core_MOC_EXECUTABLE} ${_moc_extra_parameters_file}
                       DEPENDS ${infile} ${moc_depends}
                       ${_moc_working_dir}
                       VERBATIM)
    set_source_files_properties(${infile} PROPERTIES SKIP_AUTOMOC ON)
    set_source_files_properties(${outfile} PROPERTIES SKIP_AUTOMOC ON)
    set_source_files_properties(${outfile} PROPERTIES SKIP_AUTOUIC ON)
endfunction()

# qt5_get_moc_flags
macro(QT5_GET_MOC_FLAGS _moc_flags)
  set(${_moc_flags})
  get_directory_property(_inc_DIRS INCLUDE_DIRECTORIES)

  if(CMAKE_INCLUDE_CURRENT_DIR)
    list(APPEND _inc_DIRS ${CMAKE_CURRENT_SOURCE_DIR} ${CMAKE_CURRENT_BINARY_DIR})
  endif()

  foreach(_current ${_inc_DIRS})
    if("${_current}" MATCHES "\\.framework/?$")
      string(REGEX REPLACE "/[^/]+\\.framework" "" framework_path "${_current}")
      set(${_moc_flags} ${${_moc_flags}} "-F${framework_path}")
     else()
      set(${_moc_flags} ${${_moc_flags}} "-I${_current}")
    endif()
  endforeach()

  get_directory_property(_defines COMPILE_DEFINITIONS)
  foreach(_current ${_defines})
    set(${_moc_flags} ${${_moc_flags}} "-D${_current}")
  endforeach()

  if(WIN32)
    set(${_moc_flags} ${${_moc_flags}} -DWIN32)
  endif()
endmacro()

# qt5_wrap_cpp
function(QT5_WRAP_CPP outfiles )
    qt5_get_moc_flags(moc_flags)

    set(options)
    set(oneValueArgs TARGET)
    set(multiValueArgs OPTIONS DEPENDS)

    cmake_parse_arguments(_WRAP_CPP "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    set(moc_files ${_WRAP_CPP_UNPARSED_ARGUMENTS})
    set(moc_options ${_WRAP_CPP_OPTIONS})
    set(moc_target ${_WRAP_CPP_TARGET})
    set(moc_depends ${_WRAP_CPP_DEPENDS})

    foreach(it ${moc_files})
        get_filename_component(it ${it} ABSOLUTE)
        qt5_make_output_file(${it} moc_ cpp outfile)
        qt5_create_moc_command(${it} ${outfile} "${moc_flags}" "${moc_options}" "${moc_target}" "${moc_depends}")
        list(APPEND ${outfiles} ${outfile})
    endforeach()
    set(${outfiles} ${${outfiles}} PARENT_SCOPE)
endfunction()
