# CHANGE DESIGN NAME HERE
variable design_name
set design_name [lindex [split [file tail [info script]] "."] 0]
set fpgaPart [get_property PART [current_project]] 

set origin_dir "."

# Use origin directory path location variable, if specified in the tcl shell
if { [info exists ::origin_dir_loc] } {
    set origin_dir $::origin_dir_loc
}

set str_bd_folder [file normalize ${origin_dir}/boards/$fpgaPart/$design_name]
set str_bd_filepath ${str_bd_folder}/${design_name}.bd

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



    # -------------------------------------------------------------
    #  USER INPUT: Paste the core of the exported .tcl board
    # -------------------------------------------------------------
    # Create instance -> (+ set properties if needed) -> (+ run connection automation if needed)
    puts "TCL: Instance clk_wiz_0"
    startgroup
    create_bd_cell -type ip -vlnv xilinx.com:ip:clk_wiz:6.0 clk_wiz_0
    endgroup

    # Set instance properties
    set_property -dict [list CONFIG.PRIM_IN_FREQ.VALUE_SRC USER] [get_bd_cells clk_wiz_0]
    # 199.40476 MHz
    set_property -dict [list CONFIG.JITTER_SEL {Min_O_Jitter} CONFIG.PRIM_SOURCE {Differential_clock_capable_pin} CONFIG.PRIM_IN_FREQ {200.000} CONFIG.CLKOUT2_USED {true} CONFIG.CLKOUT3_USED {true} CONFIG.CLKOUT4_USED {true} CONFIG.CLKOUT5_USED {true} CONFIG.CLKOUT6_USED {false} CONFIG.CLKOUT1_REQUESTED_OUT_FREQ {199.40476} CONFIG.CLKOUT1_REQUESTED_DUTY_CYCLE {16.7} CONFIG.CLKOUT2_REQUESTED_OUT_FREQ {199.40476} CONFIG.CLKOUT2_REQUESTED_DUTY_CYCLE {25.0} CONFIG.CLKOUT3_REQUESTED_OUT_FREQ {199.40476} CONFIG.CLKOUT3_REQUESTED_DUTY_CYCLE {33.3} CONFIG.CLKOUT4_REQUESTED_OUT_FREQ {199.40476} CONFIG.CLKOUT4_REQUESTED_DUTY_CYCLE {41.7} CONFIG.CLKOUT5_REQUESTED_OUT_FREQ {199.40476} CONFIG.CLKOUT5_REQUESTED_DUTY_CYCLE {50.0} CONFIG.CLKOUT5_DRIVES {BUFG} CONFIG.CLKIN1_JITTER_PS {50.0} CONFIG.MMCM_DIVCLK_DIVIDE {7} CONFIG.MMCM_BANDWIDTH {HIGH} CONFIG.MMCM_CLKFBOUT_MULT_F {41.875} CONFIG.MMCM_CLKIN1_PERIOD {5.000} CONFIG.MMCM_CLKIN2_PERIOD {10.0} CONFIG.MMCM_CLKOUT0_DIVIDE_F {6.000} CONFIG.MMCM_CLKOUT0_DUTY_CYCLE {0.167} CONFIG.MMCM_CLKOUT1_DIVIDE {6} CONFIG.MMCM_CLKOUT1_DUTY_CYCLE {0.250} CONFIG.MMCM_CLKOUT2_DIVIDE {6} CONFIG.MMCM_CLKOUT2_DUTY_CYCLE {0.333} CONFIG.MMCM_CLKOUT3_DIVIDE {6} CONFIG.MMCM_CLKOUT3_DUTY_CYCLE {0.417} CONFIG.MMCM_CLKOUT4_DIVIDE {6} CONFIG.MMCM_CLKOUT4_DUTY_CYCLE {0.500} CONFIG.MMCM_CLKOUT5_DIVIDE {1} CONFIG.NUM_OUT_CLKS {5} CONFIG.CLKOUT1_JITTER {150.437} CONFIG.CLKOUT1_PHASE_ERROR {193.677} CONFIG.CLKOUT2_JITTER {150.437} CONFIG.CLKOUT2_PHASE_ERROR {193.677} CONFIG.CLKOUT3_JITTER {150.437} CONFIG.CLKOUT3_PHASE_ERROR {193.677} CONFIG.CLKOUT4_JITTER {150.437} CONFIG.CLKOUT4_PHASE_ERROR {193.677} CONFIG.CLKOUT5_JITTER {150.437} CONFIG.CLKOUT5_PHASE_ERROR {193.677} CONFIG.CLKOUT6_JITTER {127.465} CONFIG.CLKOUT6_PHASE_ERROR {193.677}] [get_bd_cells clk_wiz_0]
    startgroup
    set_property -dict [list CONFIG.CLKOUT2_USED {true} CONFIG.CLKOUT3_USED {true} CONFIG.CLKOUT4_USED {true} CONFIG.CLKOUT5_USED {true} CONFIG.CLKOUT6_USED {true} CONFIG.CLKOUT7_USED {true} CONFIG.CLKOUT1_REQUESTED_OUT_FREQ {85.20408} CONFIG.CLKOUT1_REQUESTED_DUTY_CYCLE {7.1} CONFIG.CLKOUT2_REQUESTED_OUT_FREQ {85.20408} CONFIG.CLKOUT2_REQUESTED_DUTY_CYCLE {10.7} CONFIG.CLKOUT3_REQUESTED_OUT_FREQ {85.20408} CONFIG.CLKOUT3_REQUESTED_DUTY_CYCLE {14.3} CONFIG.CLKOUT4_REQUESTED_OUT_FREQ {85.20408} CONFIG.CLKOUT4_REQUESTED_DUTY_CYCLE {17.9} CONFIG.CLKOUT5_REQUESTED_OUT_FREQ {85.20408} CONFIG.CLKOUT5_REQUESTED_DUTY_CYCLE {21.4} CONFIG.CLKOUT6_REQUESTED_OUT_FREQ {85.20408} CONFIG.CLKOUT6_REQUESTED_DUTY_CYCLE {25} CONFIG.CLKOUT7_REQUESTED_OUT_FREQ {85.20408} CONFIG.MMCM_DIVCLK_DIVIDE {7} CONFIG.MMCM_CLKFBOUT_MULT_F {41.750} CONFIG.MMCM_CLKIN1_PERIOD {5.000} CONFIG.MMCM_CLKOUT0_DIVIDE_F {14.000} CONFIG.MMCM_CLKOUT0_DUTY_CYCLE {0.071} CONFIG.MMCM_CLKOUT1_DIVIDE {14} CONFIG.MMCM_CLKOUT1_DUTY_CYCLE {0.107} CONFIG.MMCM_CLKOUT2_DIVIDE {14} CONFIG.MMCM_CLKOUT2_DUTY_CYCLE {0.143} CONFIG.MMCM_CLKOUT3_DIVIDE {14} CONFIG.MMCM_CLKOUT3_DUTY_CYCLE {0.179} CONFIG.MMCM_CLKOUT4_DIVIDE {14} CONFIG.MMCM_CLKOUT4_DUTY_CYCLE {0.214} CONFIG.MMCM_CLKOUT5_DIVIDE {14} CONFIG.MMCM_CLKOUT5_DUTY_CYCLE {0.250} CONFIG.MMCM_CLKOUT6_DIVIDE {14} CONFIG.NUM_OUT_CLKS {7} CONFIG.CLKOUT1_JITTER {171.965} CONFIG.CLKOUT1_PHASE_ERROR {194.412} CONFIG.CLKOUT2_JITTER {171.965} CONFIG.CLKOUT2_PHASE_ERROR {194.412} CONFIG.CLKOUT3_JITTER {171.965} CONFIG.CLKOUT3_PHASE_ERROR {194.412} CONFIG.CLKOUT4_JITTER {171.965} CONFIG.CLKOUT4_PHASE_ERROR {194.412} CONFIG.CLKOUT5_JITTER {171.965} CONFIG.CLKOUT5_PHASE_ERROR {194.412} CONFIG.CLKOUT6_JITTER {171.965} CONFIG.CLKOUT6_PHASE_ERROR {194.412} CONFIG.CLKOUT7_JITTER {171.965} CONFIG.CLKOUT7_PHASE_ERROR {194.412}] [get_bd_cells clk_wiz_0]
    endgroup
    startgroup
    set_property -dict [list CONFIG.USE_LOCKED {false} CONFIG.USE_RESET {false}] [get_bd_cells clk_wiz_0]
    endgroup
    startgroup
    set_property -dict [list CONFIG.CLKOUT1_REQUESTED_OUT_FREQ {85.20833} CONFIG.CLKOUT2_REQUESTED_OUT_FREQ {85.20833} CONFIG.CLKOUT3_REQUESTED_OUT_FREQ {85.20833} CONFIG.CLKOUT4_REQUESTED_OUT_FREQ {85.20833} CONFIG.CLKOUT5_REQUESTED_OUT_FREQ {85.20833} CONFIG.CLKOUT6_REQUESTED_OUT_FREQ {85.20833} CONFIG.CLKOUT7_REQUESTED_OUT_FREQ {85.20833}] [get_bd_cells clk_wiz_0]
    endgroup
    startgroup
    set_property -dict [list CONFIG.CLKOUT1_REQUESTED_OUT_FREQ {85.20833} CONFIG.CLKOUT1_REQUESTED_DUTY_CYCLE {6.7} CONFIG.CLKOUT2_REQUESTED_DUTY_CYCLE {10.0} CONFIG.CLKOUT3_REQUESTED_DUTY_CYCLE {13.3} CONFIG.CLKOUT4_REQUESTED_DUTY_CYCLE {16.7} CONFIG.CLKOUT5_REQUESTED_DUTY_CYCLE {20.0} CONFIG.CLKOUT6_REQUESTED_DUTY_CYCLE {23.3} CONFIG.MMCM_DIVCLK_DIVIDE {8} CONFIG.MMCM_CLKFBOUT_MULT_F {51.125} CONFIG.MMCM_CLKIN2_PERIOD {10.000} CONFIG.MMCM_CLKOUT0_DIVIDE_F {15.000} CONFIG.MMCM_CLKOUT0_DUTY_CYCLE {0.067} CONFIG.MMCM_CLKOUT1_DIVIDE {15} CONFIG.MMCM_CLKOUT1_DUTY_CYCLE {0.100} CONFIG.MMCM_CLKOUT2_DIVIDE {15} CONFIG.MMCM_CLKOUT2_DUTY_CYCLE {0.133} CONFIG.MMCM_CLKOUT3_DIVIDE {15} CONFIG.MMCM_CLKOUT3_DUTY_CYCLE {0.167} CONFIG.MMCM_CLKOUT4_DIVIDE {15} CONFIG.MMCM_CLKOUT4_DUTY_CYCLE {0.200} CONFIG.MMCM_CLKOUT5_DIVIDE {15} CONFIG.MMCM_CLKOUT5_DUTY_CYCLE {0.233} CONFIG.MMCM_CLKOUT6_DIVIDE {15} CONFIG.CLKOUT1_JITTER {167.768} CONFIG.CLKOUT1_PHASE_ERROR {218.571} CONFIG.CLKOUT2_JITTER {167.768} CONFIG.CLKOUT2_PHASE_ERROR {218.571} CONFIG.CLKOUT3_JITTER {167.768} CONFIG.CLKOUT3_PHASE_ERROR {218.571} CONFIG.CLKOUT4_JITTER {167.768} CONFIG.CLKOUT4_PHASE_ERROR {218.571} CONFIG.CLKOUT5_JITTER {167.768} CONFIG.CLKOUT5_PHASE_ERROR {218.571} CONFIG.CLKOUT6_JITTER {167.768} CONFIG.CLKOUT6_PHASE_ERROR {218.571} CONFIG.CLKOUT7_JITTER {167.768} CONFIG.CLKOUT7_PHASE_ERROR {218.571}] [get_bd_cells clk_wiz_0]
    endgroup

    # Create external interface ports
    startgroup
    make_bd_intf_pins_external  [get_bd_intf_pins clk_wiz_0/CLK_IN1_D]
    endgroup



    # Create instance -> (+ set properties if needed) -> (+ run connection automation if needed)
    puts "TCL: Instance top_memristor_0"
    create_bd_cell -type module -reference top_memristor top_memristor_0

    connect_bd_net [get_bd_pins clk_wiz_0/clk_out1] [get_bd_pins top_memristor_0/clk0]
    connect_bd_net [get_bd_pins clk_wiz_0/clk_out2] [get_bd_pins top_memristor_0/clk1]
    connect_bd_net [get_bd_pins clk_wiz_0/clk_out3] [get_bd_pins top_memristor_0/clk2]
    connect_bd_net [get_bd_pins clk_wiz_0/clk_out4] [get_bd_pins top_memristor_0/clk3]
    connect_bd_net [get_bd_pins clk_wiz_0/clk_out5] [get_bd_pins top_memristor_0/clk4]
    connect_bd_net [get_bd_pins clk_wiz_0/clk_out6] [get_bd_pins top_memristor_0/clk5]
    connect_bd_net [get_bd_pins clk_wiz_0/clk_out7] [get_bd_pins top_memristor_0/sys_clk]

    # Create external interface ports
    startgroup
    make_bd_pins_external  [get_bd_pins top_memristor_0/pulse_out]
    endgroup
    startgroup
    make_bd_pins_external  [get_bd_pins top_memristor_0/pulse_in]
    endgroup



    # Create instance -> (+ set properties if needed) -> (+ run connection automation if needed)
    puts "TCL: Instance clk_wiz_1"
    startgroup
    create_bd_cell -type ip -vlnv xilinx.com:ip:clk_wiz:6.0 clk_wiz_1
    endgroup
    connect_bd_net [get_bd_pins clk_wiz_0/clk_out7] [get_bd_pins clk_wiz_1/clk_in1]

    startgroup
    set_property -dict [list CONFIG.PRIM_IN_FREQ.VALUE_SRC USER] [get_bd_cells clk_wiz_1]
    set_property -dict [list CONFIG.PRIM_IN_FREQ {85.204081} CONFIG.CLKOUT1_REQUESTED_OUT_FREQ {250.00671} CONFIG.CLKIN1_JITTER_PS {117.36} CONFIG.MMCM_DIVCLK_DIVIDE {2} CONFIG.MMCM_CLKFBOUT_MULT_F {27.875} CONFIG.MMCM_CLKIN1_PERIOD {11.736} CONFIG.MMCM_CLKIN2_PERIOD {10.0} CONFIG.MMCM_CLKOUT0_DIVIDE_F {4.750} CONFIG.CLKOUT1_JITTER {124.916} CONFIG.CLKOUT1_PHASE_ERROR {163.863}] [get_bd_cells clk_wiz_1]
    endgroup

    startgroup
    set_property -dict [list CONFIG.USE_LOCKED {false} CONFIG.USE_RESET {false}] [get_bd_cells clk_wiz_1]
    endgroup

    startgroup
    set_property -dict [list CONFIG.PRIM_IN_FREQ {85.208333} CONFIG.CLKOUT1_REQUESTED_OUT_FREQ {250.04588} CONFIG.MMCM_CLKIN1_PERIOD {11.736}] [get_bd_cells clk_wiz_1]
    endgroup

    connect_bd_net [get_bd_pins clk_wiz_1/clk_out1] [get_bd_pins top_memristor_0/sampl_clk]



    puts "TCL: Saving design..."
    save_bd_design

    # -------------------------------------------------------------
    #  End of copying
    # -------------------------------------------------------------
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

make_wrapper -files [get_files "[file normalize $str_bd_folder/${design_name}/${design_name}.bd]"] -top

set boardWrapperFound [glob $str_bd_folder/${design_name}/hdl/*{_wrapper.}*]
readd_found_file "[file normalize $boardWrapperFound]"

set_property top ${design_name}_wrapper [current_fileset]