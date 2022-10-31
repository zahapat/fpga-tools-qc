# So far is unused

puts "Compiling proj_specific_src library"
set lib_name lib_src
set dir "$proj_root_dir/packages/proj_specific_src"
set lib_dir "$proj_root_dir/simulator/proj_specific_src"

# Re/Compile all files in dir list to library
if { [file exist $lib_dir] == 0 } {
    vlib $lib_dir
    vmap sim_tools $lib_dir

    vcom -work ${lib_name}  ${dir}/const_pack.vhd
    vcom -work ${lib_name}  ${dir}/gtypes_pack.vhd
    vcom -work ${lib_name}  ${dir}/signals_pack.vhd
    #  vcom -work ${lib_name}  ${dir}/new_pack_tb.vhd
}