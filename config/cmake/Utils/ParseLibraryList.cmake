# Copyright (c) 2017, Los Alamos National Security, LLC
# All rights reserved.

# Copyright 2017. Los Alamos National Security, LLC. This software was
# produced under U.S. Government contract DE-AC52-06NA25396 for Los
# Alamos National Laboratory (LANL), which is operated by Los Alamos
# National Security, LLC for the U.S. Department of Energy. The
# U.S. Government has rights to use, reproduce, and distribute this
# software.  NEITHER THE GOVERNMENT NOR LOS ALAMOS NATIONAL SECURITY,
# LLC MAKES ANY WARRANTY, EXPRESS OR IMPLIED, OR ASSUMES ANY LIABILITY
# FOR THE USE OF THIS SOFTWARE.  If software is modified to produce
# derivative works, such modified software should be clearly marked, so
# as not to confuse it with the version available from LANL.
 
# Additionally, redistribution and use in source and binary forms, with
# or without modification, are permitted provided that the following
# conditions are met:

# 1.  Redistributions of source code must retain the above copyright
# notice, this list of conditions and the following disclaimer.
# 2.  Redistributions in binary form must reproduce the above copyright
# notice, this list of conditions and the following disclaimer in the
# documentation and/or other materials provided with the distribution.
# 3.  Neither the name of Los Alamos National Security, LLC, Los Alamos
# National Laboratory, LANL, the U.S. Government, nor the names of its
# contributors may be used to endorse or promote products derived from
# this software without specific prior written permission.
 
# THIS SOFTWARE IS PROVIDED BY LOS ALAMOS NATIONAL SECURITY, LLC AND
# CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING,
# BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
# FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL LOS
# ALAMOS NATIONAL SECURITY, LLC OR CONTRIBUTORS BE LIABLE FOR ANY
# DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE
# GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER
# IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
# OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
# ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.



#
# Jali 
#      
#      PARSE_LIBRARY_LIST( <lib_list>
#                         DEBUG   <out_debug_list>
#                         OPT     <out_opt_list>
#                         GENERAL <out_gen_list> )

# CMake module
include(CMakeParseArguments)

# Jali modules
include(PrintVariable)

function(PARSE_LIBRARY_LIST)

    # Macro: _print_usage
    macro(_print_usage)
        message("PARSE_LIBRARY_LIST <lib_list>\n"
                "         FOUND   <out_flag>\n"
                "         DEBUG   <out_debug_list>\n"
                "         OPT     <out_opt_list>\n"
                "         GENERAL <out_gen_list>\n" 
                "lib_list string to parse\n"
                "FOUND    flag to indicate if keywords were found\n"
                "DEBUG    variable containing debug libraries\n"
                "OPT      variable containing optimized libraries\n" 
                "GENERAL  variable containing debug libraries\n")

    endmacro()     

    # Read in args
    cmake_parse_arguments(PARSE_ARGS "" "FOUND;DEBUG;OPT;GENERAL" "" ${ARGN}) 
    set(_parse_list "${PARSE_ARGS_UNPARSED_ARGUMENTS}")
    if ( (NOT PARSE_ARGS_FOUND) OR
         (NOT PARSE_ARGS_DEBUG)  OR
         (NOT PARSE_ARGS_OPT)  OR
         (NOT PARSE_ARGS_GENERAL) OR
         (NOT _parse_list )
       )  
        _print_usage()
        message(FATAL_ERROR "Invalid arguments")
    endif() 

    # Now split the list
    set(_debug_libs "") 
    set(_opt_libs "") 
    set(_gen_libs "") 
    foreach( item ${_parse_list} )
        if( ${item} MATCHES debug     OR 
            ${item} MATCHES optimized OR 
            ${item} MATCHES general )

            if( ${item} STREQUAL "debug" )
                set( mylist "_debug_libs" )
            elseif( ${item} STREQUAL "optimized" )
                set( mylist "_opt_libs" )
            elseif( ${item} STREQUAL "general" )
                set( mylist "_gen_libs" )
            endif()
        else()
            list( APPEND ${mylist} ${item} )
        endif()
    endforeach()


    # Now set output vairables
    set(${PARSE_ARGS_DEBUG}     "${_debug_libs}" PARENT_SCOPE)
    set(${PARSE_ARGS_OPT}       "${_opt_libs}"   PARENT_SCOPE)
    set(${PARSE_ARGS_GENERAL}   "${_gen_libs}"   PARENT_SCOPE)

    # If any of the lib lists are defined set flag to TRUE
    if ( (_debug_libs) OR (_opt_libs) OR (_gen_libs) )
        set(${PARSE_ARGS_FOUND} TRUE PARENT_SCOPE)
    else()
        set(${PARSE_ARGS_FOUND} FALSE PARENT_SCOPE)
    endif()    

endfunction(PARSE_LIBRARY_LIST)

