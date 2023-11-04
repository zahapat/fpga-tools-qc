source ${proj_root_dir}simulator/do/tcl_functions.tcl

# Set variables for the simulation project
variable run_time "-all"

# Find wave.do file in the top tb module dir
set tb_top_abspath [string range [lindex $all_modules 0] 0 end]
set tb_top_dir_abspath [file dirname "[file normalize $tb_top_abspath]"]

# Run Testbench
set file_name ${file_name}
set file_lang ${file_lang}
set file_full_name "${file_name}.${file_lang}"
source ${proj_root_dir}simulator/do/launch_vsim.tcl

run $run_time
quit