# CHANGE DESIGN NAME HERE
variable design_name
set design_name top

set origin_dir "."

# Use origin directory path location variable, if specified in the tcl shell
if { [info exists ::origin_dir_loc] } {
    set origin_dir $::origin_dir_loc
}

set str_bd_folder [file normalize ${origin_dir}/boards]
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




  # Create instance -> (+ set properties if needed) -> (+ run connection automation if needed)
  puts "TCL: Instance microblaze_0"
  create_bd_cell -type ip -vlnv xilinx.com:ip:microblaze:11.0 microblaze_0
  apply_bd_automation -rule xilinx.com:bd_rule:microblaze -config { axi_intc {0} axi_periph {Enabled} cache {None} clk {New Clocking Wizard} cores {1} debug_module {Debug Only} ecc {None} local_mem {64KB} preset {None}}  [get_bd_cells microblaze_0]
  regenerate_bd_layout
  apply_bd_automation -rule xilinx.com:bd_rule:board -config { Manual_Source {Auto}}  [get_bd_intf_pins clk_wiz_1/CLK_IN1_D]
  apply_bd_automation -rule xilinx.com:bd_rule:board -config { Board_Interface {reset ( System Reset ) } Manual_Source {Auto}}  [get_bd_pins clk_wiz_1/reset]
  apply_bd_automation -rule xilinx.com:bd_rule:board -config { Board_Interface {reset ( System Reset ) } Manual_Source {Auto}}  [get_bd_pins rst_clk_wiz_1_100M/ext_reset_in]
  regenerate_bd_layout

    # Corrections after "run connection automation"
    delete_bd_objs [get_bd_nets reset_0_1] [get_bd_ports reset_0]
    connect_bd_net [get_bd_ports reset] [get_bd_pins rst_clk_wiz_1_100M/ext_reset_in]

    delete_bd_objs [get_bd_intf_nets diff_clock_rtl_1] [get_bd_intf_ports diff_clock_rtl]
    delete_bd_objs [get_bd_nets reset_inv_0_Res] [get_bd_nets clk_wiz_1_locked] [get_bd_cells clk_wiz_1]
    delete_bd_objs [get_bd_cells reset_inv_0]

  # Create instance -> (+ set properties if needed) -> (+ run connection automation if needed)
  puts "TCL: Instance clk_wiz_0"
  create_bd_cell -type ip -vlnv xilinx.com:ip:clk_wiz:6.0 clk_wiz_0
  apply_board_connection -board_interface "ddr_clock" -ip_intf "clk_wiz_0/clock_CLK_IN1" -diagram "top" 
  apply_bd_automation -rule xilinx.com:bd_rule:board -config { Board_Interface {reset ( System Reset ) } Manual_Source {Auto}}  [get_bd_pins clk_wiz_0/reset]
  apply_bd_automation -rule xilinx.com:bd_rule:clkrst -config { Clk {/clk_wiz_0/clk_out1 (100 MHz)} Freq {100} Ref_Clk0 {} Ref_Clk1 {} Ref_Clk2 {}}  [get_bd_pins rst_clk_wiz_1_100M/slowest_sync_clk]

    # Corrections after "run connection automation"
    connect_bd_net [get_bd_pins clk_wiz_0/locked] [get_bd_pins rst_clk_wiz_1_100M/dcm_locked]
    delete_bd_objs [get_bd_nets reset_inv_0_Res] [get_bd_cells reset_inv_0]
    set_property -dict [list CONFIG.RESET_TYPE {ACTIVE_LOW} CONFIG.RESET_PORT {resetn}] [get_bd_cells clk_wiz_0]
    connect_bd_net [get_bd_ports reset] [get_bd_pins clk_wiz_0/resetn]
    regenerate_bd_layout
    validate_bd_design

  # Create instance -> (+ set properties if needed) -> (+ run connection automation if needed)
  puts "TCL: Instance axi_uartlite_0"
  startgroup
  create_bd_cell -type ip -vlnv xilinx.com:ip:axi_uartlite:2.0 axi_uartlite_0
  apply_board_connection -board_interface "usb_uart" -ip_intf "axi_uartlite_0/UART" -diagram "top" 
  endgroup
    # Always when we are connecting an AXI Slave to AXI Master, signals must go through AXI Interconnect/Smart Connect:
  apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config { Clk_master {/clk_wiz_0/clk_out1 (100 MHz)} Clk_slave {Auto} Clk_xbar {Auto} Master {/microblaze_0 (Periph)} Slave {/axi_uartlite_0/S_AXI} ddr_seg {Auto} intc_ip {New AXI Interconnect} master_apm {0}}  [get_bd_intf_pins axi_uartlite_0/S_AXI]
  validate_bd_design

    # Corrections after "run connection automation"
    set_property -dict [list CONFIG.C_BAUDRATE {115200}] [get_bd_cells axi_uartlite_0]

  # Create external interface ports
  # ...
  
  # Connect ports
  # ...

  assign_bd_address

  # Restore current instance
  current_bd_instance $oldCurInst

  validate_bd_design
  save_bd_design
}
# End of create_root_design()


##################################################################
# MAIN FLOW
##################################################################
proc readd_found_file {abs_path_to_file} {
    set file_full_name [file tail $abs_path_to_file]
    puts "TCL: file_full_name = $file_full_name"

        puts "TCL: Sorting source file to fileset \"sources_1\": ${abs_path_to_file}"
        add_files -force -norecurse -fileset [get_filesets "sources_1"] ${abs_path_to_file}

        if { [string first ".vhd" ${file_full_name}] != -1} {
            read_vhdl -library "xil_defaultlib" ${abs_path_to_file}
            # puts "TCL: VHDL HERE '[string first ".vhd" ${file_full_name}]'"
        } elseif { [string first ".sv" ${file_full_name}] != -1} {
            read_verilog -library "xil_defaultlib" -sv ${abs_path_to_file}
        } elseif { [string first ".v" ${file_full_name}] != -1} {
            read_verilog -library "xil_defaultlib" ${abs_path_to_file}
        }

        set_property "library" "xil_defaultlib" [get_files ${abs_path_to_file}]
        set_property "used_in" {simulation synthesis out_of_context} [get_files ${abs_path_to_file}]

}


create_root_design ""

make_wrapper -files [get_files "[file normalize ./boards/${design_name}/${design_name}.bd]"] -top

set boardWrapperFound [glob ./boards/${design_name}/hdl/*{_wrapper.}*]
readd_found_file "[file normalize $boardWrapperFound]"

set_property top ${design_name}_wrapper [current_fileset]