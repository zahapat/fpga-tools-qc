# TCL Commands for creating a new Vitis platform project
# https://docs.xilinx.com/r/en-US/ug1400-vitis-embedded/setws
# https://xilinx-wiki.atlassian.net/wiki/spaces/A/pages/2173435938/Vitis+Debug+Development+with+VS+Code

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
# set domain_name "domain1"
# set system_name "system1"
# set app_name "app1"

puts "TCL: Get TCL Command-line arguments"
set max_args 5
if { $::argc == $max_args } {
    for {set i 0} {$i < $::argc} {incr i} {
        if {$i == 0} {
            set workspace_name [ string trim [lindex $::argv $i] ]
            puts "TCL: workspace_name = $workspace_name"
        }
        if {$i == 1} {
            set platform_name [ string trim [lindex $::argv $i] ]
            puts "TCL: platform_name = $platform_name"
        }
        if {$i == 2} {
            set domain_name [ string trim [lindex $::argv $i] ]
            puts "TCL: domain_name = $domain_name"
        }
        if {$i == 3} {
            set system_name [ string trim [lindex $::argv $i] ]
            puts "TCL: system_name = $system_name"
        }
        if {$i == 4} {
            set app_name [ string trim [lindex $::argv $i] ]
            puts "TCL: app_name = $app_name"
        }
    }
} else {
    puts "TCL: ERROR: There must be $max_args Command-line argument/s passed to the TCL script. Total arguments found:  $::argc"
    return 1
}


# ---------------------------------
# - Create Vitis platform project -
# ---------------------------------

# Variables
# set workspace_name "workspace1"
# set platform_name "platform1"
# set domain_name "domain1"
# set system_name "system1"
# set app_name "app1"

# Switch to workspace1
setws -switch ${vitis_proj_dir}/${workspace_name}

# Read the created environment
platform read ${vitis_proj_dir}/${workspace_name}/${platform_name}/platform.spr
platform active ${platform_name}

# Create a new application
puts "TCL: Creating application from template: Hello World"
app create -name ${app_name} -platform ${platform_name} -domain ${domain_name} -template {Hello World} -lang c

# Build the application
puts "TCL: Building application: ${app_name}"
# app build -name ${app_name}



# Import sources for appX
if {[file exist "./cxx/vitis/$app_name"]} {
    puts "TCL: Importing sources from app dir: ./cxx/vitis/$app_name/"

    # Command below deletes the source file located outside of the sdk project
    # importsources -name $app_name -path "./cxx/vitis/$app_name/" -soft-link
    # importsources -name $app_name -path "./cxx/vitis/$app_name/"
} else {
    puts "TCL: Creating app dir: ./cxx/vitis/$app_name/"
    file mkdir "./cxx/vitis/$app_name/"
}


# file link -symbolic ./vitis/workspace1/app1/src/app1 ./cxx/vitis/app1
file link -hard ./vitis/workspace1/app1/src/app1 ./cxx/vitis/app1


app build -name ${app_name}

# xsct% platform generate -domains
# xsct% platform generate
# xsct% importprojects C:/Users/Patrik/VHDL/whiz_membership/microblaze_soc_design/vitis/workspace1/app1

# xsct% app build -name app1