
################################################################
# This is a generated script based on design: modelock_2lasers
#
# Though there are limitations about the generated script,
# the main purpose of this utility is to make learning
# IP Integrator Tcl commands easier.
################################################################

namespace eval _tcl {
proc get_script_folder {} {
   set script_path [file normalize [info script]]
   set script_folder [file dirname $script_path]
   return $script_folder
}
}
variable script_folder
set script_folder [_tcl::get_script_folder]

################################################################
# Check if script is running in correct Vivado version.
################################################################
set scripts_vivado_version 2020.2
set current_vivado_version [version -short]

if { [string first $scripts_vivado_version $current_vivado_version] == -1 } {
   puts ""
   catch {common::send_gid_msg -ssname BD::TCL -id 2041 -severity "ERROR" "This script was generated using Vivado <$scripts_vivado_version> and is being run in <$current_vivado_version> of Vivado. Please run the script in Vivado <$scripts_vivado_version> then open the design in Vivado <$current_vivado_version>. Upgrade the design by running \"Tools => Report => Report IP Status...\", then run write_bd_tcl to create an updated script."}

   return 1
}

################################################################
# START
################################################################

# To test this script, run the following commands from Vivado Tcl console:
# source modelock_2lasers_script.tcl

# If there is no project opened, this script will create a
# project, but make sure you do not have an existing project
# <./myproj/project_1.xpr> in the current working folder.

set list_projs [get_projects -quiet]
if { $list_projs eq "" } {
   create_project project_1 myproj -part xc7k160tffg676-1
}


# CHANGE DESIGN NAME HERE
variable design_name
set design_name modelock_2lasers

# This script was generated for a remote BD. To create a non-remote design,
# change the variable <run_remote_bd_flow> to <0>.

set run_remote_bd_flow 1
if { $run_remote_bd_flow == 1 } {
  # Set the reference directory for source file relative paths (by default 
  # the value is script directory path)
  set origin_dir ./modelock_2lasers

  # Use origin directory path location variable, if specified in the tcl shell
  if { [info exists ::origin_dir_loc] } {
     set origin_dir $::origin_dir_loc
  }

  set str_bd_folder [file normalize ${origin_dir}]
  set str_bd_filepath ${str_bd_folder}/${design_name}/${design_name}.bd

  # Check if remote design exists on disk
  if { [file exists $str_bd_filepath ] == 1 } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2030 -severity "ERROR" "The remote BD file path <$str_bd_filepath> already exists!"}
     common::send_gid_msg -ssname BD::TCL -id 2031 -severity "INFO" "To create a non-remote BD, change the variable <run_remote_bd_flow> to <0>."
     common::send_gid_msg -ssname BD::TCL -id 2032 -severity "INFO" "Also make sure there is no design <$design_name> existing in your current project."

     return 1
  }

  # Check if design exists in memory
  set list_existing_designs [get_bd_designs -quiet $design_name]
  if { $list_existing_designs ne "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2033 -severity "ERROR" "The design <$design_name> already exists in this project! Will not create the remote BD <$design_name> at the folder <$str_bd_folder>."}

     common::send_gid_msg -ssname BD::TCL -id 2034 -severity "INFO" "To create a non-remote BD, change the variable <run_remote_bd_flow> to <0> or please set a different value to variable <design_name>."

     return 1
  }

  # Check if design exists on disk within project
  set list_existing_designs [get_files -quiet */${design_name}.bd]
  if { $list_existing_designs ne "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2035 -severity "ERROR" "The design <$design_name> already exists in this project at location:
    $list_existing_designs"}
     catch {common::send_gid_msg -ssname BD::TCL -id 2036 -severity "ERROR" "Will not create the remote BD <$design_name> at the folder <$str_bd_folder>."}

     common::send_gid_msg -ssname BD::TCL -id 2037 -severity "INFO" "To create a non-remote BD, change the variable <run_remote_bd_flow> to <0> or please set a different value to variable <design_name>."

     return 1
  }

  # Now can create the remote BD
  # NOTE - usage of <-dir> will create <$str_bd_folder/$design_name/$design_name.bd>
  create_bd_design -dir $str_bd_folder $design_name
} else {

  # Create regular design
  if { [catch {create_bd_design $design_name} errmsg] } {
     common::send_gid_msg -ssname BD::TCL -id 2038 -severity "INFO" "Please set a different value to variable <design_name>."

     return 1
  }
}

current_bd_design $design_name

##################################################################
# DESIGN PROCs
##################################################################



# Procedure to create entire design; Provide argument to make
# procedure reusable. If parentCell is "", will use root.
proc create_root_design { parentCell } {

  variable script_folder
  variable design_name

  if { $parentCell eq "" } {
     set parentCell [get_bd_cells /]
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2090 -severity "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2091 -severity "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj


  # Create interface ports

  # Create ports
  set clk_in1_0_LaserClk [ create_bd_port -dir I -type clk -freq_hz 75960000 clk_in1_0_LaserClk ]
  set clk_in1_1_LaserClk [ create_bd_port -dir I -type clk -freq_hz 80000000 clk_in1_1_LaserClk ]
  set clk_out1_0_PassThrough_0deg [ create_bd_port -dir O -type clk clk_out1_0_PassThrough_0deg ]
  set_property -dict [ list \
   CONFIG.FREQ_HZ {75960000} \
 ] $clk_out1_0_PassThrough_0deg
  set clk_out1_1_10MHz [ create_bd_port -dir O -type clk clk_out1_1_10MHz ]
  set_property -dict [ list \
   CONFIG.FREQ_HZ {10000000} \
 ] $clk_out1_1_10MHz
  set clk_out2_0_PassThrough_180deg [ create_bd_port -dir O -type clk clk_out2_0_PassThrough_180deg ]
  set_property -dict [ list \
   CONFIG.FREQ_HZ {75960000} \
 ] $clk_out2_0_PassThrough_180deg
  set clk_out2_1_PassThrough_0deg [ create_bd_port -dir O -type clk clk_out2_1_PassThrough_0deg ]
  set_property -dict [ list \
   CONFIG.FREQ_HZ {80000000} \
 ] $clk_out2_1_PassThrough_0deg
  set clk_out3_0_10MHz [ create_bd_port -dir O -type clk clk_out3_0_10MHz ]
  set_property -dict [ list \
   CONFIG.FREQ_HZ {9994736} \
 ] $clk_out3_0_10MHz
  set clk_out3_1_100MHz [ create_bd_port -dir O -type clk clk_out3_1_100MHz ]

  # Create instance: clk_wiz_0, and set properties
  set clk_wiz_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:clk_wiz:6.0 clk_wiz_0 ]
  set_property -dict [ list \
   CONFIG.CLKIN1_JITTER_PS {131.64000000000001} \
   CONFIG.CLKOUT1_JITTER {132.830} \
   CONFIG.CLKOUT1_PHASE_ERROR {96.095} \
   CONFIG.CLKOUT1_REQUESTED_DUTY_CYCLE {6.7000} \
   CONFIG.CLKOUT1_REQUESTED_OUT_FREQ {75.96} \
   CONFIG.CLKOUT2_JITTER {132.830} \
   CONFIG.CLKOUT2_PHASE_ERROR {96.095} \
   CONFIG.CLKOUT2_REQUESTED_DUTY_CYCLE {6.7000} \
   CONFIG.CLKOUT2_REQUESTED_OUT_FREQ {75.96} \
   CONFIG.CLKOUT2_REQUESTED_PHASE {180.000} \
   CONFIG.CLKOUT2_USED {true} \
   CONFIG.CLKOUT3_JITTER {211.588} \
   CONFIG.CLKOUT3_PHASE_ERROR {96.095} \
   CONFIG.CLKOUT3_REQUESTED_DUTY_CYCLE {43.9} \
   CONFIG.CLKOUT3_REQUESTED_OUT_FREQ {9.99474} \
   CONFIG.CLKOUT3_USED {true} \
   CONFIG.MMCM_CLKFBOUT_MULT_F {15.000} \
   CONFIG.MMCM_CLKIN1_PERIOD {13.165} \
   CONFIG.MMCM_CLKIN2_PERIOD {10.0} \
   CONFIG.MMCM_CLKOUT0_DIVIDE_F {15.000} \
   CONFIG.MMCM_CLKOUT0_DUTY_CYCLE {0.067} \
   CONFIG.MMCM_CLKOUT1_DIVIDE {15} \
   CONFIG.MMCM_CLKOUT1_DUTY_CYCLE {0.067} \
   CONFIG.MMCM_CLKOUT1_PHASE {180.000} \
   CONFIG.MMCM_CLKOUT2_DIVIDE {114} \
   CONFIG.MMCM_CLKOUT2_DUTY_CYCLE {0.439} \
   CONFIG.NUM_OUT_CLKS {3} \
   CONFIG.PRIM_IN_FREQ {75.960} \
   CONFIG.USE_LOCKED {false} \
   CONFIG.USE_RESET {false} \
 ] $clk_wiz_0

  # Create instance: clk_wiz_1, and set properties
  set clk_wiz_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:clk_wiz:6.0 clk_wiz_1 ]
  set_property -dict [ list \
   CONFIG.CLKIN1_JITTER_PS {125.0} \
   CONFIG.CLKOUT1_JITTER {249.573} \
   CONFIG.CLKOUT1_PHASE_ERROR {117.521} \
   CONFIG.CLKOUT1_REQUESTED_OUT_FREQ {10.000} \
   CONFIG.CLKOUT2_JITTER {164.206} \
   CONFIG.CLKOUT2_PHASE_ERROR {117.521} \
   CONFIG.CLKOUT2_REQUESTED_OUT_FREQ {80.000} \
   CONFIG.CLKOUT2_USED {true} \
   CONFIG.CLKOUT3_JITTER {156.437} \
   CONFIG.CLKOUT3_PHASE_ERROR {117.521} \
   CONFIG.CLKOUT3_USED {true} \
   CONFIG.MMCM_CLKFBOUT_MULT_F {10.000} \
   CONFIG.MMCM_CLKIN1_PERIOD {12.500} \
   CONFIG.MMCM_CLKIN2_PERIOD {10.000} \
   CONFIG.MMCM_CLKOUT0_DIVIDE_F {80.000} \
   CONFIG.MMCM_CLKOUT1_DIVIDE {10} \
   CONFIG.MMCM_CLKOUT2_DIVIDE {8} \
   CONFIG.NUM_OUT_CLKS {3} \
   CONFIG.PRIM_IN_FREQ {80.000} \
   CONFIG.USE_LOCKED {false} \
   CONFIG.USE_RESET {false} \
 ] $clk_wiz_1

  # Create port connections
  connect_bd_net -net clk_in1_0_1 [get_bd_ports clk_in1_0_LaserClk] [get_bd_pins clk_wiz_0/clk_in1]
  connect_bd_net -net clk_in1_1_1 [get_bd_ports clk_in1_1_LaserClk] [get_bd_pins clk_wiz_1/clk_in1]
  connect_bd_net -net clk_wiz_0_clk_out1 [get_bd_ports clk_out1_0_PassThrough_0deg] [get_bd_pins clk_wiz_0/clk_out1]
  connect_bd_net -net clk_wiz_0_clk_out2 [get_bd_ports clk_out2_0_PassThrough_180deg] [get_bd_pins clk_wiz_0/clk_out2]
  connect_bd_net -net clk_wiz_0_clk_out3 [get_bd_ports clk_out3_0_10MHz] [get_bd_pins clk_wiz_0/clk_out3]
  connect_bd_net -net clk_wiz_1_clk_out1 [get_bd_ports clk_out1_1_10MHz] [get_bd_pins clk_wiz_1/clk_out1]
  connect_bd_net -net clk_wiz_1_clk_out2 [get_bd_ports clk_out2_1_PassThrough_0deg] [get_bd_pins clk_wiz_1/clk_out2]
  connect_bd_net -net clk_wiz_1_clk_out3 [get_bd_ports clk_out3_1_100MHz] [get_bd_pins clk_wiz_1/clk_out3]

  # Create address segments


  # Restore current instance
  current_bd_instance $oldCurInst

  validate_bd_design
  save_bd_design
}
# End of create_root_design()


##################################################################
# MAIN FLOW
##################################################################

create_root_design ""


