# TCL Commands for creating a new Vitis platform project
# https://docs.xilinx.com/r/en-US/ug1400-vitis-embedded/setws
# https://xilinx-wiki.atlassian.net/wiki/spaces/A/pages/2173435938/Vitis+Debug+Development+with+VS+Code
# https://www.xilinx.com/htmldocs/xilinx2018_1/SDK_Doc/xsct/use_cases/xsct_create_app_project.html

# Set the reference directory for source file relative paths (by default the value is script directory path)
set origin_dir "."
puts "TCL: origin_dir = $origin_dir"

# Set the project name
set _xil_proj_name_ [file tail [file dirname "[file normalize ./Makefile]"]]
puts "TCL: _xil_proj_name_: $_xil_proj_name_"

variable script_file
set script_file "[file tail [info script]]"
puts "TCL: Running $script_file for project $_xil_proj_name_."

# Set the directory path for the original project from where this script was exported
set orig_proj_dir "[file normalize "$origin_dir/"]"
puts "TCL: orig_proj_dir: $orig_proj_dir"

set vitis_proj_dir "$origin_dir/vitis/"
puts "TCL: vitis_proj_dir: $vitis_proj_dir"



# Get TCL Command-line arguments: Target FPGA part
# set workspace_name "workspace1"
# set platform_name "platform1"
# set xsa_path "./vivado/4_hw_platform_${_xil_proj_name_}.xsa"
# set domain_name "domain1"
# set processor_name "microblaze"
# set processor_instance "0"
# set domain_os "standalone"
# set system_name "system1"

puts "TCL: Get TCL Command-line arguments"
set max_args 10
if { $::argc == $max_args } {
    for {set i 0} {$i < $::argc} {incr i} {
        if {$i == 0} {
            set target_part [ string trim [lindex $::argv $i] ]
            puts "TCL: target_part = $target_part"
        }
        if {$i == 1} {
            set target_board [ string trim [lindex $::argv $i] ]
            puts "TCL: target_board = $target_board"
        }
        if {$i == 2} {
            set workspace_name [ string trim [lindex $::argv $i] ]
            puts "TCL: workspace_name = $workspace_name"
        }
        if {$i == 3} {
            set platform_name [ string trim [lindex $::argv $i] ]
            puts "TCL: platform_name = $platform_name"
        }
        if {$i == 4} {
            set xsa_path [ string trim [lindex $::argv $i] ]
            puts "TCL: xsa_path = $xsa_path"
        }
        if {$i == 5} {
            set domain_name [ string trim [lindex $::argv $i] ]
            puts "TCL: domain_name = $domain_name"
        }
        if {$i == 6} {
            set processor_name [ string trim [lindex $::argv $i] ]
            puts "TCL: processor_name = $processor_name"
        }
        if {$i == 7} {
            set processor_instance [ string trim [lindex $::argv $i] ]
            puts "TCL: processor_instance = $processor_instance"
        }
        if {$i == 8} {
            set domain_os [ string trim [lindex $::argv $i] ]
            puts "TCL: domain_os = $domain_os"
        }
        if {$i == 9} {
            set system_name [ string trim [lindex $::argv $i] ]
            puts "TCL: system_name = $system_name"
        }
    }
} else {
    puts "TCL: ERROR: There must be $max_args Command-line argument/s passed to the TCL script. Total arguments found:  $::argc"
    return 1
}


# ---------------------------------
# - Create Vitis platform project -
# ---------------------------------
# platform create -name {blah} \
#     -hw {C:\Users\Patrik\VHDL\whiz_membership\microblaze_soc_design\vivado\4_hw_platform_microblaze_soc_design.xsa} \
#     -proc {microblaze_0} \
#     -os {standalone} \
#     -fsbl-target {psu_cortexa53_0} \
#     -out {C:/Users/Patrik/VHDL/whiz_membership/microblaze_soc_design/vitis};platform write
# platform create -name {blah} -hw {C:\Users\Patrik\VHDL\whiz_membership\microblaze_soc_design\vivado\4_hw_platform_microblaze_soc_design.xsa} -proc {microblaze_0} -os {standalone} -fsbl-target {psu_cortexa53_0} -out {C:/Users/Patrik/VHDL/whiz_membership/microblaze_soc_design/vitis};platform write
# platform read {C:\Users\Patrik\VHDL\whiz_membership\microblaze_soc_design\vitis\blah\platform.spr}
# platform active {blah}

# ::scw::get_hw_path
# ::scw::regenerate_psinit C:/Users/Patrik/VHDL/whiz_membership/microblaze_soc_design/vitis/bla/hw/4_hw_platform_microblaze_soc_design.xsa
# ::scw::get_mss_path
# bsp reload

# READ THIS:  https://support.xilinx.com/s/question/0D52E00006hpQl4SAE/vitis?language=en_US --->
# ::scw::generate_bif -xpfm /root/vitisWorkspace/eclypse_0/export/eclypse_0/eclypse_0.xpfm -domains standalone_domain -bifpath /root/vitisWorkspace/hello_zmo18.04ds_system/Debug/system.bif' on XSCT
# sdcard_gen --xpfm /root/vitisWorkspace/eclypse_0/export/eclypse_0/eclypse_0.xpfm --sys_config eclypse_0 --bif /root/vitisWorkspace/hello_zmods_system/Debug/system.bif --bitstream /root/vitisWorkspace/hello_zmods/_ide/bitstream/design_1_wrapper.bit --elf /root/vitisWorkspace/hello_zmods/Debug/hello_zmods.elf,ps7_cortexa9_0
# ELF does not exist: /root/vitisWorkspace/hello_zmods/Debug/hello_zmods.elf
# makefile:39: recipe for target 'package' failed

# !!!!!!!! READ: https://xilinx-wiki.atlassian.net/wiki/spaces/A/pages/2173435938/Vitis+Debug+Development+with+VS+Code !!!!!

# TO DO: MAKE THE SCRIPT GENERATE AN "XPFM" FILE

# platform write
# platform generate -domains 
# platform active {blah}
# platform generate
# platform active {blah}

# Delete previous content in the folder ./vivado/
# file delete -force "$origin_dir/vitis/{*}"

# # Set Vitis Workspace
puts "TCL: Creating a new Workspace: $vitis_proj_dir/$workspace_name"
setws $vitis_proj_dir/$workspace_name
# getws
# setws -switch $vitis_proj_dir/workspace_1

# # Create a new platform project
puts "TCL: Creating new Vitis Platform Project: ${platform_name}"
# set platform_name "$_xil_proj_name_"
# set platform_name "platform1"
platform create -name ${platform_name} -hw ${xsa_path}

# Set parameters for creating a new domain in active platform
  # e.g. instance_processor = "ps7_cortexa9_0 ps7_cortexa9_1" ... use names from Vivado board file or .tcl that generates it
# set processor_cores "microblaze_0"
  # e.g. -domain_name "ZUdomain" or "a9_standalone" or "a53_0_Standalone " ...
# set domain_name "domain1"
  # e.g. -domain_os "standalone" or "linux" ...
# set domain_os "standalone"
puts "TCL: Creating new domain in active platform"
if {$processor_name eq "microblaze"} {
  if {$processor_instance eq "0"} {
    domain create -name ${domain_name} -os ${domain_os} -proc {microblaze_0}
  }
  if {$processor_instance eq "1"} {
    domain create -name ${domain_name} -os ${domain_os} -proc {microblaze_1}
  }
  if {$processor_instance eq "2"} {
    domain create -name ${domain_name} -os ${domain_os} -proc {microblaze_2}
  }
}
platform generate
platform active ${platform_name}
# projects -build
# domain list


# # Create an application
# set application_name "app1"
# puts "TCL: Creating new application template: Hello World"
# setws -switch $vitis_proj_dir/workspace1
# app create -name ${application_name} -platform ${platform_name} -domain ${domain_name} -template {Hello World}


# # List all applications in the current workspace
# puts "TCL: List of all applications in the current workspace:"
# # app list

# # Configure C/C++ build settings of the application
# # (include-path, libraries, linker-script ...)
# # (-add, -set, -remove...)
# # e.g. app config -name test define-compiler-symbols FSBL_DEBUG_INFO
# # e.g. app config -name test -remove define-compiler-symbols FSBL_DEBUG_INFO
# # app config -name -add
# # app config -name -set

# Build the application
# puts "TCL: Building application: ${application_name}"
# app build -name ${application_name}

# # Cleaning application
# puts "TCL: Cleaning application: application1"
# # app clean -name application1