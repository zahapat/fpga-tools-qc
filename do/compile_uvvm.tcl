# This script compiles all UVVM files

puts "TCL: Compiling UVVM libraries."

if {![file exists $proj_root_dir/simulator/uvvm]} {

    # Delete UVVM precompiled libraries (if they exist)
    set uvvm_precomp_libs [glob -nocomplain -directory "$proj_root_dir/packages/uvvm/" type d */sim]

    foreach d $uvvm_precomp_libs {
        puts "TCL: Removing found UVVM precompiled dir: $d"
        file delete -force $d
    }

    # Re/Compile all libraries
    source $proj_root_dir/packages/uvvm/script/compile_all.do

    # Create the UVVM lib dir after completion
    file mkdir $proj_root_dir/simulator/uvvm

    # Create a file with instructions how to recompile the library, if needed
    set uvvm_path "$proj_root_dir/simulator/uvvm/where_compiled.txt"
    set new_uvvm_lib [open $uvvm_path "w"]
    puts "TCL: New file: $uvvm_path"
    puts $new_uvvm_lib "The UVVM library has been compiled to UVVM subdirectories in the 'packages' folder. Example dir:"
    puts $new_uvvm_lib "./packages/uvvm/uvvm_util/sim/uvvm_util"
    puts $new_uvvm_lib "By deleting the folder './simulator/uvvm/', after running 'make sim' or 'make sim_gui'"
    puts $new_uvvm_lib "the UVVM library will be recompiled. This applies to other libraries as well."
    close $new_uvvm_lib
}