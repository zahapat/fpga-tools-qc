#================================================================================================================================
# Copyright 2020 Bitvis
# Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License.
# You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0 and in the provided LICENSE.TXT.
#
# Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on
# an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and limitations under the License.
#================================================================================================================================
# Note : Any functionality not explicitly described in the documentation is subject to change at any time
#--------------------------------------------------------------------------------------------------------------------------------

#-----------------------------------------------------------------------
# This file must be called with 3 arguments:
#
# This file can be called with three arguments:
# arg 1: Part directory of this library/module
# arg 2: Target directory
# arg 3: Path to custom component list file
#-----------------------------------------------------------------------

# Overload quietly (Modelsim specific command) to let it work in Riviera-Pro
proc quietly { args } {
  if {[llength $args] == 0} {
    puts "quietly"
  } else {
    # this works since tcl prompt only prints the last command given. list prints "".
    uplevel $args; list;
  }
}

# End the simulations if there's an error or when run from terminal.
if {[batch_mode]} {
  onerror {abort all; exit -f -code 1}
} else {
  onerror {abort all}
}

#------------------------------------------------------
# Set up vip_source_path and vip_target_path
#------------------------------------------------------
variable vip_source_path
variable vip_component_path
variable vip_target_path
variable component_list_path

# Default values
# assume we stand in script folder if no source argument is given
# quietly set vip_source_path [pwd]

# quietly set vip_source_path "$proj_root_dir/packages/uvvm/script"
# quietly set component_list_path "$vip_source_path/component_list.txt"
quietly set source_path "$proj_root_dir/packages/uvvm/script"
quietly set default_target 0
puts "CHECKPOINT 1"


# if { [info exists 1] } {
#   quietly set vip_source_path $proj_root_dir/packages/uvvm/script
#   # quietly set vip_source_path "$1"
#   # quietly set vip_source_path [pwd]
#   quietly set component_list_path "$vip_source_path/component_list.txt"
#   puts "TCL: DEBUG: compile_all.do 6"

#   if {$argc >= 2} {
#     quietly set vip_target_path "$2"
#     quietly set default_target 1
#     puts "TCL: DEBUG: compile_all.do 7"

#     if {$argc >= 3} {
#       quietly set component_list_path "$3"
#       puts "TCL: DEBUG: compile_all.do 8"
#     }
#   }
# }

#------------------------------------------------------
# Read component_list.txt
#------------------------------------------------------
# quietly set fp [open "$component_list_path" r]
# quietly set file_data [read $fp]
# close $fp

#------------------------------------------------------
# Read all folders in ./packages/vip/
#------------------------------------------------------
quietly set file_data [glob -nocomplain -directory "$proj_root_dir/packages/vip/" -type d *]
puts "TCL: DEBUG file_data = $file_data"

#------------------------------------------------------
# Compile components
#------------------------------------------------------
puts "CHECKPOINT 2"
foreach item $file_data {
  if {$default_target == 0} {
    # BEFORE:
    # quietly set vip_target_path "$vip_source_path/../$item/sim"
    quietly set target_path "$source_path/../$item/sim"

    # AFTER:
    # quietly set vip_target_path "$proj_root_dir/simulator/uvvm/$item"
    quietly set vip_target_path "$proj_root_dir/simulator/vip"
    puts "TCL: DEBUG vip_target_path = $vip_target_path"
  }
  # BEFORE:
  # quietly set vip_component_path "$vip_source_path/../$item"
  quietly set component_path "$source_path/../$item"

  # AFTER:
  quietly set vip_component_path "$item"
  puts "TCL: DEBUG vip_component_path = $vip_component_path"

  namespace eval compile_src {
    # variable local_source_path $vip_source_path
    variable vip_source_path $vip_component_path
    variable vip_target_path $vip_target_path

    variable argc -1

    # Re/Compile the source
    # source $local_source_path/compile_src.do
    source $proj_root_dir/do/compile_uvvm_user_vips/compile_src_user_vips.do
  }
  namespace delete compile_src
}