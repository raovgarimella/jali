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
# Build TPL: NetCDF-fortran
# 

# --- Define all the directories and common external project flags
define_external_project_args(NetCDF_Fortran TARGET netcdf-fortran
                             DEPENDS NetCDF)

# add version version to the autogenerated tpl_versions.h file
Jali_tpl_version_write(FILENAME ${TPL_VERSIONS_INCLUDE_FILE}
  PREFIX NetCDF_Fortran
  VERSION ${NetCDF_Fortran_VERSION_MAJOR} ${NetCDF_Fortran_VERSION_MINOR} ${NetCDF_Fortran_VERSION_PATCH})
  
# --- Patch original code
set(NetCDF_Fortran_patch_file netcdf-fortran-osx.patch)
set(NetCDF_Fortran_sh_patch ${NetCDF_Fortran_prefix_dir}/netcdf-fortran-patch-step.sh)
configure_file(${SuperBuild_TEMPLATE_FILES_DIR}/netcdf-fortran-patch-step.sh.in
               ${NetCDF_Fortran_sh_patch}
               @ONLY)

# configure the CMake patch step
set(NetCDF_Fortran_cmake_patch ${NetCDF_Fortran_prefix_dir}/netcdf-fortran-patch-step.cmake)
configure_file(${SuperBuild_TEMPLATE_FILES_DIR}/netcdf-fortran-patch-step.cmake.in
               ${NetCDF_Fortran_cmake_patch}
               @ONLY)

set(NetCDF_Fortran_PATCH_COMMAND ${CMAKE_COMMAND} -P ${NetCDF_Fortran_cmake_patch})

# --- Define the configure command
set(NetCDF_Fortran_CMAKE_CACHE_ARGS "-DCMAKE_INSTALL_PREFIX:FILEPATH=${CMAKE_INSTALL_PREFIX}")
list(APPEND NetCDF_Fortran_CMAKE_CACHE_ARGS "-DCMAKE_BUILD_TYPE:STRING=${CMAKE_BUILD_TYPE}")
list(APPEND NetCDF_Fortran_CMAKE_CACHE_ARGS "-DBUILD_SHARED_LIBS:BOOL=${BUILD_SHARED_LIBS}")
list(APPEND NetCDF_Fortran_CMAKE_CACHE_ARGS "-DENABLE_TESTS:BOOL=FALSE")

# --- Add external project build 
ExternalProject_Add(${NetCDF_Fortran_BUILD_TARGET}
                    DEPENDS ${NetCDF_Fortran_PACKAGE_DEPENDS} # Package dependency target
                    TMP_DIR ${NetCDF_Fortran_tmp_dir}         # Temporary files directory
                    STAMP_DIR ${NetCDF_Fortran_stamp_dir}     # Timestamp and log directory
                    # -- Downloads
                    DOWNLOAD_DIR ${TPL_DOWNLOAD_DIR}
                    URL ${NetCDF_Fortran_URL}                 # URL may be a web site OR a local file
                    URL_MD5 ${NetCDF_Fortran_MD5_SUM}         # md5sum of the archive file
                    DOWNLOAD_NAME ${NetCDF_Fortran_SAVEAS_FILE}  # file name to store
                    PATCH_COMMAND ${NetCDF_Fortran_PATCH_COMMAND} 
                    # -- Configure
                    SOURCE_DIR ${NetCDF_Fortran_source_dir}
                    CMAKE_CACHE_ARGS ${JALI_CMAKE_CACHE_ARGS}   # Global definitions from root CMakeList
                                     ${NetCDF_Fortran_CMAKE_CACHE_ARGS}
                                     -DCMAKE_C_FLAGS:STRING=${Jali_COMMON_CFLAGS}  # Ensure uniform build
                                     -DCMAKE_C_COMPILER:FILEPATH=${CMAKE_C_COMPILER}
                                     -DCMAKE_CXX_FLAGS:STRING=${Jali_COMMON_CXXFLAGS}
                                     -DCMAKE_CXX_COMPILER:FILEPATH=${CMAKE_CXX_COMPILER}
                                     -DCMAKE_Fortran_FLAGS:STRING=${Jali_COMMON_FCFLAGS}
                                     -DCMAKE_Fortran_COMPILER:FILEPATH=${CMAKE_Fortran_COMPILER}
                    # -- Build
                    BINARY_DIR      ${NetCDF_Fortran_build_dir}  
                    BUILD_COMMAND   $(MAKE)                       # enables parallel builds through make
                    BUILD_IN_SOURCE ${NetCDF_Fortran_BUILD_IN_SOURCE}
                    # -- Install
                    INSTALL_DIR ${CMAKE_INSTALL_PREFIX}
                    # -- Output control
                    ${NetCDF_Fortran_logging_args})

