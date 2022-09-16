# So far is unused

puts "Compiling proj_specific_sim library"
set lib_name lib_sim
set dir "$proj_root_dir/packages/proj_specific_sim"
set lib_dir "$proj_root_dir/modelsim/proj_specific_sim"

# Re/Compile all files in dir list to library
if { [file exist $lib_dir] == 0 } {
    vlib $lib_dir
    vmap sim_tools $lib_dir

    vcom -2008 -work ${lib_name}  ${dir}/const_pack_tb.vhd
    vcom -2008 -work ${lib_name}  ${dir}/gtypes_pack_tb.vhd
    vcom -2008 -work ${lib_name}  ${dir}/signals_pack_tb.vhd
    #  vcom -2008 -work ${lib_name}  ${dir}/new_pack_tb.vhd
}