# Find directories to delete in project origin directory
set dirs_to_delete [glob -type d -nocomplain -directory ${origin_dir} \
    NA \
    .cxl.ip \
]

# Delete the found directories
foreach dir $dirs_to_delete {
    file delete -force $dir
}


# Find files to delete in project origin directory
# NOTE: modelsim.ini will be recreated by running "make sim" or "make sim_gui"
set files_to_delete [glob -type f -nocomplain -directory ${origin_dir} \
    simulator/modules.tcl \
    tight_setup_hold_pins.txt\
    *.str \
    *.tmp \
    *.debug \
    *.zip \
    *.log \
    .cxl.modelsim.version \
    compile_simlib.log \
    modelsim.ini.bak \
    modelsim.ini \
]

# Delete the found files
foreach file $files_to_delete {
    file delete -force $file
}

# Remove directories
file delete -force -- ${origin_dir}/.Xil
file delete -force -- ${origin_dir}/vivado

# Re/Create new directories if they don't exist
if {![file exist "${origin_dir}/ip"]} {
    file mkdir "${origin_dir}/ip"
}