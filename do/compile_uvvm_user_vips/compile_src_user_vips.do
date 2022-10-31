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
# This file must be called with 2 arguments:
#
#   arg 1: Part directory of this library/module
#   arg 2: Target directory
#-----------------------------------------------------------------------

# Overload quietly (simulator specific command) to let it work in Riviera-Pro
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

# Detect simulator
if {[catch {eval "vsim -version"} message] == 0} {
  quietly set simulator_version [eval "vsim -version"]
  if {[regexp -nocase {modelsim} $simulator_version]} {
    quietly set simulator "modelsim"
  } elseif {[regexp -nocase {aldec} $simulator_version]} {
    quietly set simulator "rivierapro"
  } else {
    puts "Unknown simulator. Attempting to use Modelsim commands."
    quietly set simulator "modelsim"
  }
} else {
    puts "vsim -version failed with the following message:\n $message"
    abort all
}

#------------------------------------------------------
# Set up vip_source_path and vip_target_path
#------------------------------------------------------
# if {$argc == 2} {
#   quietly set vip_source_path "$1"
#   quietly set vip_target_path "$2"
# } elseif {$argc == -1} {
#   # Called from other script
# } else {
#   error "Needs two arguments: source path and target path"
# }

#------------------------------------------------------
# Read compile_order.txt and set lib_name
#------------------------------------------------------
# quietly set fp [open "$vip_source_path/script/compile_order.txt" r]
# quietly set file_data [read $fp]
# quietly set lib_name [lindex $file_data 2]
# close $fp

#------------------------------------------------------
# Read all folders in ./packages/vip/ and set lib_name
#------------------------------------------------------
# quietly set file_data [glob -directory "$proj_root_dir/packages/vip/" -type d *]
# puts "TCL: DEBUG file_data = $file_data"
set path_vvc_cmd_pkg [glob -nocomplain -type f $vip_source_path/{vvc_cmd_pkg}*]
set path_bfm_pkg [glob -nocomplain -type f $vip_source_path/*{_bfm_pkg}*]
set path_methods_pkg [glob -nocomplain -type f $vip_source_path/*{_methods_pkg}*]
# set path_tx_vvc [glob -nocomplain -type f $vip_source_path/*{tx_vvc}*]
# set path_rx_vvc [glob -nocomplain -type f $vip_source_path/*{rx_vvc}*]
set path_vvc [glob -nocomplain -type f $vip_source_path/*{_vvc}*]
set path_context [glob -nocomplain -type f $vip_source_path/*{_context}*]

set path_td_queue "$proj_root_dir/packages/uvvm/uvvm_vvc_framework/src_target_dependent/td_queue_pkg.vhd"
set path_td_target_support "$proj_root_dir/packages/uvvm/uvvm_vvc_framework/src_target_dependent/td_target_support_pkg.vhd"
set path_td_common_methods "$proj_root_dir/packages/uvvm/uvvm_vvc_framework/src_target_dependent/td_vvc_framework_common_methods_pkg.vhd"
set path_td_entity_support "$proj_root_dir/packages/uvvm/uvvm_vvc_framework/src_target_dependent/td_vvc_entity_support_pkg.vhd"

# Compile order
quietly set file_data {}
lappend file_data [string range [lindex $path_vvc_cmd_pkg 0] 0 end]
lappend file_data $path_td_queue 
lappend file_data $path_td_target_support 
lappend file_data $path_td_common_methods 
lappend file_data [string range [lindex $path_bfm_pkg 0] 0 end]
lappend file_data [string range [lindex $path_methods_pkg 0] 0 end]
lappend file_data $path_td_entity_support 
# Append tx and rx files first
set idx 0
foreach f $path_vvc {
  if { [string first "tx_vvc." [file tail $f]] != -1} {
    lappend file_data [string range [lindex $path_vvc $idx] 0 end]
  }
  if { [string first "rx_vvc." [file tail $f]] != -1} {
    lappend file_data [string range [lindex $path_vvc $idx] 0 end]
  }
  incr idx 1
}

# Append the _vvc.vhd main file at last
set idx 0
foreach f $path_vvc {
  if { [string first "tx_vvc." [file tail $f]] == -1} {
    if { [string first "rx_vvc." [file tail $f]] == -1} {
      lappend file_data [string range [lindex $path_vvc $idx] 0 end]
    }
  }
  incr idx 1
}

# lappend file_data [string range [lindex $path_tx_vvc 0] 0 end]
# lappend file_data [string range [lindex $path_rx_vvc 0] 0 end]
# lappend file_data [string range [lindex $path_vvc 0] 0 end]
lappend file_data [string range [lindex $path_context 0] 0 end]

# file tail $vip_source_path
quietly set vip_lib_name [file tail $vip_source_path]


# puts "TCL: DEBUG: compile_src.do 15"

echo "\n\n=== Re-gen lib and compile $vip_lib_name source\n"
echo "Source path: $vip_source_path"
echo "Target path: $vip_target_path"

#------------------------------------------------------
# (Re-)Generate library and Compile source files
#------------------------------------------------------
if {[file exists $vip_target_path/$vip_lib_name]} {
  file delete -force $vip_target_path/$vip_lib_name
  # puts "TCL: DEBUG: compile_src.do 17"
}
if {![file exists $vip_target_path]} {
  file mkdir $vip_target_path/$vip_lib_name
  # puts "TCL: DEBUG: compile_src.do 18"
}

# puts "TCL: DEBUG: compile_src.do 19"
quietly vlib $vip_target_path/$vip_lib_name
quietly vmap $vip_lib_name $vip_target_path/$vip_lib_name

vlib $vip_target_path/$vip_lib_name
vmap $vip_lib_name $vip_target_path/$vip_lib_name

# set UVVM_LIB_NAME uvvm
# set UVVM_DIR "$proj_root_dir/packages/uvvm"
# set UVVM_LIB_DIR "$proj_root_dir/simulator/uvvm"

# vlib $UVVM_LIB_DIR
# vmap uvvm $UVVM_LIB_DIR

# These two core libraries are needed by every VIP (except the IRQC and UART demos),
# therefore we should map them in case they were compiled from different directories
# which would cause the references to be in a different file.
# First check if the libraries are in the specified target path, if not, then look
# in the default UVVM structure.

# if {$vip_lib_name != "uvvm_util" && $vip_lib_name != "bitvis_irqc" && $vip_lib_name != "bitvis_uart" && $vip_lib_name != "bitvis_vip_spec_cov"} {
#   echo "Mapping uvvm_util and uvvm_vvc_framework"
#   if {[file exists $target_path/uvvm_util]} {
#     # quietly vmap uvvm_util $target_path/uvvm_util
#     quietly vmap uvvm_util $target_path/uvvm_util
#   } else {
#     # quietly vmap uvvm_util $source_path/../uvvm_util/sim/uvvm_util
#     quietly vmap uvvm_util $source_path/../uvvm_util/sim/uvvm_util
#   }
#   if {[file exists $target_path/uvvm_vvc_framework]} {
#     # quietly vmap uvvm_vvc_framework $target_path/uvvm_vvc_framework
#     quietly vmap uvvm_vvc_framework $target_path/uvvm_vvc_framework
#   } else {
#     # quietly vmap uvvm_vvc_framework $source_path/../uvvm_vvc_framework/sim/uvvm_vvc_framework
#     quietly vmap uvvm_vvc_framework $source_path/../uvvm_vvc_framework/sim/uvvm_vvc_framework
#   }
# }

if { [string equal -nocase $simulator "modelsim"] } {
  quietly set compdirectives "-quiet -suppress 1346,1236,1090 -2008 -work $vip_lib_name"
} elseif { [string equal -nocase $simulator "rivierapro"] } {
  set compdirectives "-2008 -nowarn COMP96_0564 -nowarn COMP96_0048 -dbg -work $vip_lib_name"
}

#------------------------------------------------------
# Compile src files
#------------------------------------------------------
echo "\nCompiling $vip_lib_name source\n"
quietly set idx 0
foreach item $file_data {
  # if {$idx > 2} {
  #   echo "eval vcom  $compdirectives  $vip_source_path/script/$item"
  #   eval vcom  $compdirectives  $vip_source_path/script/$item
  # }

  # puts "TCL: DEBUG: item = [lindex $file_data $idx]"
  echo "eval vcom  $compdirectives  $item"
  eval vcom  $compdirectives  $item

  # echo "eval vcom -2008 -work $vip_lib_name $item"
  # vcom -2008 -work $vip_lib_name $item

  incr idx 1
}