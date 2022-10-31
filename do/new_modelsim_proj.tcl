# Create a new simulator project, delete the previous one

if {[file exists "./simulator/project.mpf"]} {
    # Re/create a new project
    if [batch_mode] {
        project delete $proj_root_dir/simulator/project.mpf
        project new $proj_root_dir/simulator project work $proj_root_dir/modelsim.ini 0
    }

    # Open project
    project open $proj_root_dir/simulator/project.mpf

    # Add & compile all
    source "$proj_root_dir/do/compile_all.tcl"

    # Return the absolute pathnames of all files in the current open project
    project filenames

    # Return compile order list
    project compileorder

} else {
    # Re/create a new project, nocomplain
    project delete $proj_root_dir/simulator/project.mpf
    project new $proj_root_dir/simulator project work $proj_root_dir/modelsim.ini 0

    # Open project
    project open $proj_root_dir/simulator/project.mpf

    # Add & compile all
    source "$proj_root_dir/do/compile_all.tcl"

    # Return the absolute pathnames of all files in the current open project
    project filenames

    # Return compile order list
    project compileorder
}