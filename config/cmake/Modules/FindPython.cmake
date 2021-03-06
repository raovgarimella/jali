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


# ############################################################################ #
#
# CMake FindPython module
#
# ############################################################################ #

include(FindPackageHandleStandardArgs)

# Search for the Python executable
if ( NOT PYTHON_EXECUTABLE )

  # Call PythonInterp to find the python executable
  find_package(PythonInterp)

endif()

# Define the version
if (PYTHON_EXECUTABLE AND (NOT PYTHON_VERSION_STRING) )
  execute_process(COMMAND ${PYTHON_EXECUTABLE} -c "import sys; print('%s.%s.%s' % sys.version_info[0:3])"
                  OUTPUT_VARIABLE PYTHON_VERSION_STRING
                  RESULT_VARIABLE ret
                  OUTPUT_STRIP_TRAILING_WHITESPACE)
  
  if(ret)
    message(SEND_ERROR "Failed to define PYTHON_VERSION_STRING")
  endif()

  execute_process(COMMAND ${PYTHON_EXECUTABLE} -c "import sys; print('%s' % sys.version_info[0])"
    OUTPUT_VARIABLE PYTHON_VERSION_MAJOR
                  RESULT_VARIABLE ret
                  OUTPUT_STRIP_TRAILING_WHITESPACE)
  
  if(ret)
    message(SEND_ERROR "Failed to define PYTHON_VERSION_MAJOR")
  endif()

  execute_process(COMMAND ${PYTHON_EXECUTABLE} -c "import sys; print('%s' % sys.version_info[1])"
    OUTPUT_VARIABLE PYTHON_VERSION_MINOR
                  RESULT_VARIABLE ret
                  OUTPUT_STRIP_TRAILING_WHITESPACE)
  
  if(ret)
    message(SEND_ERROR "Failed to define PYTHON_VERSION_MINOR")
  endif()

  execute_process(COMMAND ${PYTHON_EXECUTABLE} -c "import sys; print('%s' % sys.version_info[2])"
    OUTPUT_VARIABLE PYTHON_VERSION_PATCH
                  RESULT_VARIABLE ret
                  OUTPUT_STRIP_TRAILING_WHITESPACE)
  
  if(ret)
    message(SEND_ERROR "Failed to define PYTHON_VERSION_PATCH")
  endif()


endif()

# Search for the PYTHON_INCLUDE_DIRS and PYTHON_LIBRARIES
if ( PYTHON_EXECUTABLE AND (NOT PYTHON_INCLUDE_DIRS) )

  execute_process(COMMAND ${PYTHON_EXECUTABLE} -c "import sys; print(sys.prefix)"
                  OUTPUT_VARIABLE PYTHON_PREFIX
                  RESULT_VARIABLE ret
                  OUTPUT_STRIP_TRAILING_WHITESPACE)
  
  if ( ret )
    message(SEND_ERROR "Failed to locate Python install prefix")
  endif()

  if(PYTHON_PREFIX)
    set(_python_search_paths ${PYTHON_PREFIX}/include)
    set(_python_suffixes  ${PYTHON_VERSION_MAJOR}.${PYTHON_VERSION_MINOR})

    find_path(PYTHON_INCLUDE_DIRS
              Python.h
              PATHS ${PYTHON_PREFIX}/include
              PATH_SUFFIXES python${PYTHON_VERSION_MAJOR}.${PYTHON_VERSION_MINOR}
              NO_DEFAULT_PATH)
  endif()
                
                  



endif()

FIND_PACKAGE_HANDLE_STANDARD_ARGS(Python DEFAULT_MSG 
                                  PYTHON_EXECUTABLE)



