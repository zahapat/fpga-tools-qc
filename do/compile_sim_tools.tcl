# So far is unused

puts "Compiling sim_tools library"
set lib_name sim_tools
set dir "$proj_root_dir/packages/sim_tools"
set lib_dir "$proj_root_dir/simulator/sim_tools"

# Compile all files in dir list to library osvvm
if { [file exist $lib_dir] == 0 } {
    vlib $lib_dir
    vmap sim_tools $lib_dir

    vcom -2008 -work ${lib_name}  ${dir}/clk_pack_tb.vhd
    vcom -2008 -work ${lib_name}  ${dir}/export_pack_tb.vhd
    vcom -2008 -work ${lib_name}  ${dir}/fifo_pack_tb.vhd
    vcom -2008 -work ${lib_name}  ${dir}/list_pack_tb.vhd
    vcom -2008 -work ${lib_name}  ${dir}/print_list_pack_tb.vhd
    vcom -2008 -work ${lib_name}  ${dir}/print_pack_tb.vhd
    vcom -2008 -work ${lib_name}  ${dir}/random_pack_tb.vhd
    #  vcom -2008 -work ${lib_name}  ${dir}/new_pack_tb.vhd
}