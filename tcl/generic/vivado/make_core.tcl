# From the TCL console type "help ipx::*" for a list of ipx:: commands
# Great source: https://gitlab.telecom-paris.fr/renaud.pacalet/hwprj/blob/efc2b982e2270303231425fadda58c782d72008e/example/hdl/axi_reg_lib/vv-syn.axi_reg_lib.top.tcl
# recreate.tcl: https://gitlab.cern.ch/adtobsbox/apecfirmware/-/blob/master/recreate.tcl
# tcl file exists/dir commands: https://wiki.tcl-lang.org/page/file+exists
# very good script: https://github.com/stiggy87/ZynqBTC/blob/master/hls/ip/run_ippack.tcl
# in the "file groups" section select the file group which is mentioned in the warning message i.e., 
#     "VHDL simulation". You can change the type to desired value in the properties tab as highlighted 
#     below. If you want to change it it MIXED type as the warning suggests specify the type to be 
#     "simulation" instead if "vhdl:simulation".
# add xml file and create custom ip: https://stackoverflow.com/questions/62157330/xilinx-vivado-read-component-xml-file-into-project-from-tcl


# Set the reference directory for source file relative paths (by default the value is script directory path)
set origin_dir "."

# Use origin directory path location variable, if specified in the tcl shell
if { [info exists ::origin_dir_loc] } {
    set origin_dir $::origin_dir_loc
}

# Set the project name
set _xil_proj_name_ [file tail [file dirname "[file normalize ./Makefile]"]]

# Use project name variable, if specified in the tcl shell
if { [info exists ::user_project_name] } {
    set _xil_proj_name_ $::user_project_name
}
variable script_file
set script_file "[file tail [info script]]"
puts "TCL: Running $script_file for project $_xil_proj_name_."


# Set the directory path for the original project from where this script was exported
set orig_proj_dir "[file normalize "$origin_dir/"]"


# Get TCL Command-line arguments
puts "TCL: Get TCL Command-line arguments"
set arguments_cnt 1
if { $::argc == $arguments_cnt } {
    for {set i 0} {$i < $::argc} {incr i} {
        set argument [ string trim [lindex $::argv $i] ]
        puts "TCL: $argument"
    }
} else {
    puts "TCL: ERROR: There must be $arguments_cnt Command-line argument(s) passed to the TCL script. Total arguments found:  $::argc"
    return 1
}
set IPname [ string trim [lindex $::argv 0] ]
set IPname_0 ${IPname}_0
# set topFile [ string trim [lindex $::argv 1] ]
puts "TCL: Argument IPname_0: $IPname_0"
# puts "TCL: Argument topFile: $topFile"


# Create a new IP directory under ${orig_proj_dir}/ip/
set IPdir "${orig_proj_dir}/ip/$IPname_0"
puts "TCL: IP directory: $IPdir"
file delete -force $IPdir
puts "TCL: Deleted IP directory: $IPdir"
file mkdir $IPdir
puts "TCL: Created IP directory: $IPdir"
file mkdir $IPdir/src
puts "TCL: Created IP subdirectory: ./ip/$IPname_0/src"
file mkdir $IPdir/sim
puts "TCL: Created IP subdirectory: ./ip/$IPname_0/sim"
file mkdir $IPdir/tcl
puts "TCL: Created IP subdirectory: ./ip/$IPname_0/tcl"
file mkdir $IPdir/const
puts "TCL: Created IP subdirectory: ./ip/$IPname_0/const"
file mkdir $IPdir/doc
puts "TCL: Created IP subdirectory: ./ip/$IPname_0/doc"


# ---------------------
# - FIND THE TOP FILE -
# ---------------------
# Search for the given file in the project
# puts "TCL: Search for the given file in the project"
# set topFileFound [glob */*{$topFile}* */*/*{$topFile}*]

# Assess that the number of occurrences of this file is 1
# puts "TCL: Assess that the number of occurrences of this file is 1"
# if { [llength $topFileFound] == 1 } {
#     puts "TCL: File $topFile exists. "
# } else {
#     puts "TCL: ERROR: File specified by the Command-line argument does not exist or there are multiple files in the project. "
#     return 2
# }


# ----------------------------------
# - CREATE NEW PROJECT (IN MEMORY) -
# ----------------------------------
create_project -ip -in_memory ${IPname_0} -dir $IPdir
# create_project ${IPname_0} . -force
set ip [ipx::create_core patrik_zahalka.com ip ${IPname_0} 1.0]
# ipx::package_project -root_dir $IPdir -vendor patrik_zahalka.com -library user_ip -force ${IPname_0} -import_files

# This does not work
# set_property vlnv {"patrik_zahalka.com:ip:"$IPname_0":1.0"} [ipx::current_core]

# Set various IP Properties
set_property vendor {patrik_zahalka.com} [ipx::current_core]
set_property library {ip} [ipx::current_core]
# set_property name {$IPname_0} [ipx::current_core]
set_property version {1.0} [ipx::current_core]
set_property display_name {Automatically Generated User IP ${IPname_0}} [ipx::current_core]
set_property vendor_display_name {patrik_zahalka.com} [ipx::current_core]
set_property display_name "User IP: ${IPname_0}" [ipx::current_core]
set_property description "Automatically generated user IP: ${IPname_0}" [ipx::current_core]
# set_property taxonomy {{/UserIP}} [ipx::current_core]
set_property taxonomy {{/$IPname_0}} [ipx::current_core]
set_property root_directory $IPdir [ipx::current_core]
set_property supported_families {{virtex7} {Pre-Production}\
                                 {qzynq} {Pre-Production}\
                                 {qvirtex7} {Pre-Production}\
                                 {qkintex7l} {Pre-Production}\
                                 {qkintex7} {Pre-Production}\
                                 {qartix7} {Pre-Production}\
                                 {kintex7l} {Pre-Production}\
                                 {kintex7} {Pre-Production}\
                                 {azynq} {Pre-Production}\
                                 {artix7l} {Pre-Production}\
                                 {aartix7} {Pre-Production}\
                                 {artix7} {Pre-Production}\
                                 {zynq} {Production}} [ipx::current_core]
puts "TCL: New IP ${IPname_0} has been created. "


# Simulator language
set_property simulator_language Mixed [current_project]


# ----------------
# - SET FILESETS -
# ----------------
# Set filesets objects
puts "TCL: Create filesets "
create_fileset -srcset ${IPname_0}_sources_1
create_fileset -simset ${IPname_0}_sim_1
create_fileset -constrset ${IPname_0}_constrs_1
set objSrc [get_filesets ${IPname_0}_sources_1]
set objSim [get_filesets ${IPname_0}_sim_1]
set objConst [get_filesets ${IPname_0}_constrs_1]


# ------------------------------------------------
# - SET NEW TOP MODULE AND ADD IT TO THE PROJECT -
# ------------------------------------------------
# Set the file graph
# https://www.xilinx.com/support/answers/63488.html
# To find the list of missing sources in a hierarchy using a Tcl script,
# you can use the command "report_compile_order" with the argument "-missing_instance".
puts "TCL: Enable automatic hierarchy creation "
set_property source_mgmt_mode All [current_project]

# Set '${IPname_0}_sources_1' fileset TOP module
# add_files -norecurse -fileset $objSrc ${origin_dir}/$topFileFound
# set_property TOP $topFile [current_fileset]

# set topFile [get_property TOP [current_fileset]]
# puts "TCL: New TOP file: $topFile"
# puts "TCL: Path to the new Top module: $topFileFound"

# report_compile_order -used_in synthesis
# get_files -compile_order ${IPname_0}_sources_1 -used_in synthesis
# }


# --------------------------------------------
# - ADD .vhd/.v/.sv RTL AND CONSTRAINT FILES -
# --------------------------------------------
puts "TCL: Adding already created sources (VHDL/Verilog/SystemVerilog). "

# Check for existing files:
if { [file exist "${origin_dir}/vivado/0_report_added_modules.rpt"] == false} {
    puts "TCL: ERROR: File not found: ${origin_dir}/vivado/0_report_added_modules.rpt"
    return 5
}
if { [file exist "${origin_dir}/vivado/0_report_added_xdc.rpt"] == false} {
    puts "TCL: ERROR: File not found: ${origin_dir}/vivado/0_report_added_xdc.rpt"
    return 6
}
if { [file exist "${origin_dir}/vivado/1_netlist_post_synth.edf"] == false} {
    puts "TCL: ERROR: File not found: ${origin_dir}/vivado/1_netlist_post_synth.edf"
}

# Copy netlist after synthesis and added sources
puts "TCL: Copy netlist EDF file"
file copy ${origin_dir}/vivado/1_netlist_post_synth.edf $IPdir
puts "TCL: Copy sources RPT to the IP dir"
file copy ${origin_dir}/vivado/0_report_added_modules.rpt $IPdir


# ---------------
# - ADD SOURCES -
#----------------
# Copy rtl synth sources to the ./ip/src folder and add them to the proj
puts "TCL: Adding sources, read them specifically as VHDL/SystemVerilog"
set slurp_file [open "$IPdir/0_report_added_modules.rpt" r]
while {-1 != [gets $slurp_file line]} {
    file copy $line $IPdir/src
}

# List all files in the /src folder and add files to the project
set listOfFiles_sources_1 [glob -directory $IPdir/src *]
foreach f $listOfFiles_sources_1 {
    set name [string range $f 0 end]
    # puts "TCL: Adding source to fileset ${IPname_0}_sources_1: $IPdir/src/$name"
    puts "TCL: Adding source to fileset ${IPname_0}_sources_1: $name"
    set file_type [lindex [split $name "."] 1]
    
    if {$file_type eq "vhd"} {
        puts "TCL: Read file type $file_type as VHDL"
        puts "TCL: File path: $name"
        # add_files -norecurse -fileset $objSrc $IPdir/src/$name
        add_files -norecurse -fileset $objSrc $name
        set_property file_type VHDL [get_files $name]
        # read_vhdl $IPdir/src/$name
        read_vhdl $name
    } elseif {$file_type eq "v"} {
        puts "TCL: Read file type $file_type as SystemVerilog"
        add_files -norecurse -fileset $objSrc $IPdir/src/$name
        set_property file_type SystemVerilog [get_files $name]
        # read_verilog $IPdir/src/$name
        read_verilog $name
    } elseif {$file_type eq "sv"} {
        puts "TCL: Read file type $file_type as SystemVerilog"
        add_files -norecurse -fileset $objSrc $IPdir/src/$name
        set_property file_type SystemVerilog [get_files $name]
        # read_verilog -sv $IPdir/src/$name
        read_verilog $name
    } else {
        puts "TCL: Invalid file suffix. $file_type"
        return 4
    }
}
close $slurp_file


# Set target language of the project based on the TOP file (Verilog, VHDL)
update_compile_order
set topFile_name [get_property TOP [current_fileset]]
set topFile_path [glob -type f $IPdir/src/{${topFile_name}.}*]
set topFile [file tail $topFile_path]
puts "TCL: Top file: $topFile"
# set_property "TOP" "$topFile" $objSrc

set ip_name [lindex [split $topFile "."] 0]
set file_type [lindex [split $topFile "."] 1]
if {$file_type eq "vhd"} {
    set_property target_language VHDL [current_project]
    puts "TCL: Target language = VHDL"
} elseif {$file_type eq "v"} {
    set_property target_language Verilog [current_project]
    puts "TCL: Target language = Verilog"
} elseif {$file_type eq "sv"} {
    set_property target_language Verilog [current_project]
    puts "TCL: Target language = SystemVerilog (=Verilog)"
} else {
    puts "TCL: Invalid TOP file suffix $file_type. Please enter full name of the TOP file."
    return 3
}


# List all missing submodules
set newTop [get_property TOP [current_fileset]]
report_compile_order -fileset ${IPname_0}_sources_1 -used_in synthesis -missing_instance -of [get_ips $newTop] -file "$IPdir/0_report_modules_missing.rpt"
set missingFiles [report_compile_order -fileset ${IPname_0}_sources_1 -used_in synthesis -missing_instance -of [get_ips $newTop]]
puts "TCL: Exporting missing modules in design here: $IPdir/0_report_modules_missing.rpt"


# Copy xdc sources to the ./ip/xdc folder and add them to the proj
file copy ${origin_dir}/vivado/0_report_added_xdc.rpt $IPdir
set slurp_file [open "$IPdir/0_report_added_xdc.rpt" r]
while {-1 != [gets $slurp_file line]} {
    file copy $line $IPdir/const
}
set listOfFiles_constr_1 [glob -directory $IPdir/const *]
foreach f $listOfFiles_constr_1 {
    set name [string range $f 0 end]
    # puts "TCL: Adding source to fileset ${IPname_0}_constrs_1: $IPdir/const/$name"
    puts "TCL: Adding source to fileset ${IPname_0}_constrs_1: $name"
    # add_files -norecurse -fileset $objConst $IPdir/const/$name
    add_files -norecurse -fileset $objConst $name
    # ipx::add_file $IPdir/const/$name
}
close $slurp_file


# ---------------
# - IP Packager -
# ---------------
# ipx::* commands; you can list them with help ipx::*
set ipx_commands [help ipx::*]
puts "TCL: ipx_commands: " 
puts "$ipx_commands"

# Set file groups: Synthesis and Simulation (VHDL/Verilog)
set grp_synth_vhd [ipx::add_file_group -type vhdl:synthesis {} [ipx::current_core]]
set grp_synth_v [ipx::add_file_group -type verilog:synthesis {} [ipx::current_core]]
set grp_sim_mixed [ipx::add_file_group -type simulation {} [ipx::current_core]]
foreach f $listOfFiles_sources_1 {
    set path [string range $f 0 end]
    set name [file tail $path]
    set file_name [lindex [split $topFile "."] 0]
    set file_type [lindex [split $topFile "."] 1]
    puts "TCL: add_file $name"
    if {$file_type eq "vhd"} {
        puts "TCL: File $name added to groups of type: vhdl synthesis; mixed simulation "
        set_property model_name $file_name $grp_synth_vhd
        ipx::add_file $path $grp_synth_vhd
        set_property model_name $file_name $grp_sim_mixed
        ipx::add_file $path $grp_sim_mixed
    } elseif {$file_type eq "v"} {
        puts "TCL: File $name added to groups of type: verilog synthesis; mixed simulation "
        set_property model_name $file_name $grp_synth_v
        ipx::add_file $path $grp_synth_v
        set_property model_name $file_name $grp_sim_mixed
        ipx::add_file $path $grp_sim_mixed
    } elseif {$file_type eq "sv"} {
        puts "TCL: File $name added to groups of type: verilog synthesis; mixed simulation "
        set_property model_name $file_name $grp_synth_v
        ipx::add_file $path $grp_synth_v
        set_property model_name $file_name $grp_sim_mixed
        ipx::add_file $path $grp_sim_mixed
    } else {
        puts "TCL: Invalid file suffix $file_type"
        return 4
    }
}
set ipx_top_file_path "[file normalize $IPdir/src/$topFile]"
set file [file tail $ipx_top_file_path]
set file_name [lindex [split $file "."] 0]
ipx::import_top_level_hdl -top_module_name $file_name -top_level_hdl_file $IPdir/src/$topFile [ipx::current_core]

# set file_grp [ipx::add_file_group -type simulation {} [ipx::current_core]]
# ipx::add_file myip1.v $file_grp

# ipx::add_file_group -type utility xilinx_utilityxitfiles [ipx::current_core]

# ipx::add_bus_interface refclk [ipx::current_core]
# ipx::reorder_bus_interface -front refclk [ipx::current_core]

# set_property abstraction_type_vlnv xilinx.com:interface:diff_clock_rtl:1.0 [ipx::get_bus_interfaces refclk -of_objects [ipx::current_core]]
# set_property bus_type_vlnv xilinx.com:interface:gt:1.0 [ipx::get_bus_interfaces refclk -of_objects [ipx::current_core]]
# set_property interface_mode slave [ipx::get_bus_interfaces refclk -of_objects [ipx::current_core]]

# ipx::add_port_map CLK_P [ipx::get_bus_interfaces refclk -of_objects [ipx::current_core]]
# set_property physical_name refclk_clk_p [ipx::get_port_maps CLK_P -of_objects [ipx::get_bus_interfaces refclk -of_objects [ipx::current_core]]]

# ipx::add_port_map CLK_N [ipx::get_bus_interfaces refclk -of_objects [ipx::current_core]]
# set_property physical_name refclk_clk_n [ipx::get_port_maps CLK_N -of_objects [ipx::get_bus_interfaces refclk -of_objects [ipx::current_core]]]




# ipx::package_project -root_dir $IPdir -vendor patrik_zahalka.com -library user_ip -force ${IPname_0} -import_files
# set_property display_name "User IP: ${IPname_0}" ${IPname_0}
# set_property description "User IP: ${IPname_0}" ${ip_name}
# set_property taxonomy {{/UserIP}} ${IPname_0}
# puts "TCL: IP ${IPname_0} has been created. "

# customize ports and interfaces:
#     Set all pins of signal "rstn" to zero
# set_property VALUE ACTIVE_LOW [ipx::get_bus_parameters -of_objects [ipx::get_bus_interfaces -of_objects [ipx::current_core] rstn] POLARITY]

# set PORT "clk"
# set interface [ipx::add_bus_interface $PORT $ip]
# set_property abstraction_type_vlnv xilinx.com:signal:clock_rtl:1.0 $interface
# set_property bus_type_vlnv xilinx.com:signal:clock:1.0 $interface
# set_property interface_mode slave $interface
# set_property physical_name clk [ipx::add_port_map CLK $interface]

#     Examples:
# ipx::add_bus_interface refclk [ipx::current_core]
# ipx::reorder_bus_interface -front refclk [ipx::current_core]

# set_property abstraction_type_vlnv xilinx.com:interface:diff_clock_rtl:1.0 [ipx::get_bus_interfaces refclk -of_objects [ipx::current_core]]
# set_property bus_type_vlnv xilinx.com:interface:gt:1.0 [ipx::get_bus_interfaces refclk -of_objects [ipx::current_core]]
# set_property interface_mode slave [ipx::get_bus_interfaces refclk -of_objects [ipx::current_core]]

# ipx::add_port_map CLK_P [ipx::get_bus_interfaces refclk -of_objects [ipx::current_core]]
# set_property physical_name refclk_clk_p [ipx::get_port_maps CLK_P -of_objects [ipx::get_bus_interfaces refclk -of_objects [ipx::current_core]]]

# ipx::add_port_map CLK_N [ipx::get_bus_interfaces refclk -of_objects [ipx::current_core]]
# set_property physical_name refclk_clk_n [ipx::get_port_maps CLK_N -of_objects [ipx::get_bus_interfaces refclk -of_objects [ipx::current_core]]]

puts "TCL: ports and interfaces of the ${IPname_0} customized. "


# ----------------------------
# - GENERATE OUTPUT IP FILES -
# ----------------------------
#IPX:
ipx::merge_project_changes files [ipx::current_core]
set_property core_revision 1 [ipx::current_core]
ipx::create_xgui_files [ipx::current_core]
ipx::update_checksums [ipx::current_core]
ipx::check_integrity [ipx::current_core]
ipx::save_core [ipx::current_core]
puts "TCL: Additional configuration of the ${IPname_0} done. "
ipx::unload_core $IPdir/component.xml
puts "TCL: Core has been unloaded here: $IPdir/comopnent.xml "

# Close project, print success
puts "TCL: Running $script_file for project $_xil_proj_name_ COMPLETED SUCCESSFULLY. "
close_project
return 0