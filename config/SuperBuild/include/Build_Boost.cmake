# Copyright (c) 2019, Triad National Security, LLC
# All rights reserved.

# Copyright 2019. Triad National Security, LLC. This software was
# produced under U.S. Government contract 89233218CNA000001 for Los
# Alamos National Laboratory (LANL), which is operated by Triad
# National Security, LLC for the U.S. Department of Energy. 
# All rights in the program are reserved by Triad National Security,
# LLC, and the U.S. Department of Energy/National Nuclear Security
# Administration. The Government is granted for itself and others acting
# on its behalf a nonexclusive, paid-up, irrevocable worldwide license
# in this material to reproduce, prepare derivative works, distribute
# copies to the public, perform publicly and display publicly, and to
# permit others to do so
 
# 
# This is open source software distributed under the 3-clause BSD license.
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are
# met:
# 
# 1. Redistributions of source code must retain the above copyright notice,
#    this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer in the
#    documentation and/or other materials provided with the distribution.
# 3. Neither the name of Triad National Security, LLC, Los Alamos
#    National Laboratory, LANL, the U.S. Government, nor the names of its
#    contributors may be used to endorse or promote products derived from this
#    software without specific prior written permission.

 
# THIS SOFTWARE IS PROVIDED BY TRIAD NATIONAL SECURITY, LLC AND
# CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING,
# BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
# FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL
# TRIAD NATIONAL SECURITY, LLC OR CONTRIBUTORS BE LIABLE FOR ANY
# DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE
# GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER
# IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
# OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
# ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


#
# Build TPL: Boost 
#

# --- Define all the directories and common external project flags
define_external_project_args(Boost TARGET boost)

# add Boost version to the autogenerated tpl_versions.h file
jali_tpl_version_write(FILENAME ${TPL_VERSIONS_INCLUDE_FILE}
  PREFIX Boost
  VERSION ${Boost_VERSION_MAJOR} ${Boost_VERSION_MINOR} ${Boost_VERSION_PATCH})

# -- Define build definitions

# We only build what we need, this is NOT a full Boost install
set(Boost_projects "system,filesystem,program_options,regex,graph")

# --- Define the configure command
message("  etc: BOOST FLAGS ISSUES")
set(Boost_bjam_args "cxxflags=${Jali_COMMON_CXXFLAGS}")
string(REPLACE " " "\\ " Boost_bjam_args ${Boost_bjam_args})
message("  etc: bjam args escape spaces not quote them: ${Boost_bjam_args}")

# determin link type
if (BUILD_SHARED_LIBS)
  set(Boost_libs_type "shared")
else()
  set(Boost_libs_type "static")
endif()

# determine toolset type
set(Boost_toolset)
string(TOLOWER ${CMAKE_C_COMPILER_ID} compiler_id_lc)

message(STATUS "BOOST: CMAKE_CXX_COMPILER   = ${CMAKE_CXX_COMPILER}")
message(STATUS "BOOST: Boost_bjam_args (ini): ${Boost_bjam_args}")
message(STATUS "BOOST: CMAKE_SYSTEM         = ${CMAKE_SYSTEM}")
message(STATUS "BOOST: CMAKE_SYSTEM_VERSION = ${CMAKE_SYSTEM_VERSION}")
message(STATUS "BOOST: compiler_id_lc       = ${compiler_id_lc}")

if (compiler_id_lc)
  if (APPLE)
    message(STATUS "BOOST: CMAKE_SYSTEM         = ${CMAKE_SYSTEM}")
    message(STATUS "BOOST: CMAKE_SYSTEM_VERSION = ${CMAKE_SYSTEM_VERSION}")
    message(STATUS "BOOST: compiler_id_lc       = ${compiler_id_lc}")
    # CMAKE_SYSTEM of the form Darwin-12.5.0
    # CMAKE_SYSTEM_VERSION is 12.5.0 corresponds to OSX 10.8.5
    STRING(REGEX REPLACE "\\..*" "" OS_VERSION_MAJOR ${CMAKE_SYSTEM_VERSION})
 
    if (${compiler_id_lc} STREQUAL "intel")
      set(Boost_toolset intel-darwin)
    else()  
      set(Boost_toolset clang)
    endif()  
    # some extra hints.
    if (${compiler_id_lc} STREQUAL "gnu")
      # On Mac OS 10.9, Clang has switched from using libstdc++ to libc++, so 
      # we need to tell it to do the opposite.
      if ( ${OS_VERSION_MAJOR} EQUAL 13 ) # OSX 10.9.x -> Darwin-13.x.y
        execute_process(COMMAND g++ -v ERROR_VARIABLE GXX_IS_CLANG)
        string(FIND ${GXX_IS_CLANG} "LLVM" LLVM_INDEX)
        if (NOT ${LLVM_INDEX} EQUAL -1)
          message (STATUS "BOOST: build and linking with Clang using -stdlib=libstdc++ ")
          set(Boost_bootstrap_args "cxxflags=\"-arch i386 -arch x86_84\" address-model=32_64")
          set(Boost_bjam_args "cxxflags=\"-stdlib=libstdc++\" linkflags=\"-stdlib=libstdc++\"")
        endif()
      endif()
      # On Mac OS 10.10, we don't know what to do yet
      if ( ${OS_VERSION_MAJOR} GREATER 13 ) # OSX 10.9.x -> Darwin-13.x.y
        message (STATUS "BOOST: CMAKE_CXX_COMPILER   = ${CMAKE_CXX_COMPILER}")
        # Check if it looks like an mpi wrapper
	if ( CMAKE_CXX_COMPILER MATCHES "mpi" )
          execute_process(
            COMMAND ${CMAKE_CXX_COMPILER} -show
            OUTPUT_VARIABLE  COMPILE_CMDLINE OUTPUT_STRIP_TRAILING_WHITESPACE
            ERROR_VARIABLE   COMPILE_CMDLINE ERROR_STRIP_TRAILING_WHITESPACE
            RESULT_VARIABLE  COMPILER_RETURN
            )
            # Extract the name of the compiler
	    if ( COMPILER_RETURN EQUAL 0)
	        string(REPLACE " " ";" COMPILE_CMDLINE_LIST ${COMPILE_CMDLINE})
	        list(GET COMPILE_CMDLINE_LIST 0 RAW_CXX_COMPILER)
		message (STATUS "BOOST: RAW_CXX_COMPILER     = ${RAW_CXX_COMPILER}")
	    else()
	        message (FATAL_ERROR "BOOST: Unable to determine the compiler command")
            endif()
	else()
          set(RAW_CXX_COMPILER ${CMAKE_CXX_COMPILER})
        endif()

        # Extract the version of the compiler
	execute_process(
	  COMMAND ${RAW_CXX_COMPILER} --version 
	  OUTPUT_VARIABLE  _version_string OUTPUT_STRIP_TRAILING_WHITESPACE
	  ERROR_VARIABLE   _version_string_error ERROR_STRIP_TRAILING_WHITESPACE
	  RESULT_VARIABLE  _version_return
        )

        # Test to see if it is macports or clang
        if (_version_string MATCHES "MacPorts" OR _version_string MATCHES "Homebrew")
          message(STATUS "BOOST: compiler is MacPorts or Homebrew" )
          message(STATUS "BOOST: compiler version: ${CMAKE_CXX_COMPILER_VERSION}")

          if (BUILD_SHARED_LIBS)
            set(shared_special "linkflags=\"-r ${CMAKE_INSTALL_PREFIX}/lib\"")
          else()
            set(shared_special )
          endif()
          set(Boost_user_key darwin)

          set(BOOST_using "using ${Boost_user_key} : ${CMAKE_CXX_COMPILER_VERSION} : ${RAW_CXX_COMPILER} \;")
          file (MAKE_DIRECTORY ${Boost_build_dir})
	  file (WRITE ${Boost_build_dir}/user-config.jam ${BOOST_using} \n )
          set(Boost_bootstrap_args )
          set(Boost_bjam_args "toolset=gcc-${CMAKE_CXX_COMPILER_VERSION} link=static" )
          set(Boost_toolset darwin)
        elseif( _version_string MATCHES "LLVM" )
	  message (STATUS "BOOST: compiler is Clang" )
        endif()
      endif()
    endif()

  elseif(UNIX)
    if (${compiler_id_lc} STREQUAL "gnu")
        set(Boost_toolset gcc)
    elseif(${compiler_id_lc} STREQUAL "intel")
        set(Boost_toolset intel-linux)
    elseif(${compiler_id_lc} STREQUAL "pgi")
        set(Boost_toolset pgi)
    elseif(${compiler_id_lc} STREQUAL "pathscale")
        set(Boost_toolset pathscale)
    elseif(${compiler_id_lc} STREQUAL "clang")
        set(Boost_toolset clang)
    endif()
  endif()
endif()
message(STATUS "BOOST: Boost_bjam_args (fin): ${Boost_bjam_args}")
message(STATUS "BOOST: Boost_toolset        = ${Boost_toolset}")

configure_file(${SuperBuild_TEMPLATE_FILES_DIR}/boost-configure-step.cmake.in
               ${Boost_prefix_dir}/boost-configure-step.cmake
        @ONLY)
set(Boost_CONFIGURE_COMMAND ${CMAKE_COMMAND} -P ${Boost_prefix_dir}/boost-configure-step.cmake)


# --- Define the build command
configure_file(${SuperBuild_TEMPLATE_FILES_DIR}/boost-build-step.cmake.in
               ${Boost_prefix_dir}/boost-build-step.cmake
       @ONLY)

set(Boost_BUILD_COMMAND ${CMAKE_COMMAND} -P ${Boost_prefix_dir}/boost-build-step.cmake)     

# --- Add external project build and tie to the ZLIB build target
ExternalProject_Add(${Boost_BUILD_TARGET}
                    DEPENDS   ${Boost_PACKAGE_DEPENDS}             # Package dependency target
                    TMP_DIR   ${Boost_tmp_dir}                     # Temporary files directory
                    STAMP_DIR ${Boost_stamp_dir}                   # Timestamp and log directory
                    # -- Download and URL definitions
                    DOWNLOAD_DIR ${TPL_DOWNLOAD_DIR}              # Download directory
                    URL          ${Boost_URL}                      # URL may be a web site OR a local file
                    URL_MD5      ${Boost_MD5_SUM}                  # md5sum of the archive file
                    # -- Configure
                    SOURCE_DIR       ${Boost_source_dir}           # Source directory
                    CONFIGURE_COMMAND ${Boost_CONFIGURE_COMMAND}
                    # -- Build
                    BINARY_DIR        ${Boost_build_dir}           # Build directory 
                    BUILD_COMMAND     ${Boost_BUILD_COMMAND}       # $(MAKE) enables parallel builds through make
                    BUILD_IN_SOURCE   ${Boost_BUILD_IN_SOURCE}     # Flag for in source builds
                    # -- Install
                    INSTALL_DIR      ${CMAKE_INSTALL_PREFIX}        # Install directory
                    INSTALL_COMMAND  ""
                    # -- Output control
                    ${Boost_logging_args})
