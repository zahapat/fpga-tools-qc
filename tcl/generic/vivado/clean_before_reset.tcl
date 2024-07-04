# Find files to delete
set files_to_delete [glob -type f -nocomplain -directory ${origin_dir} \
    simulator/modules.tcl \
    *.str \
    *.tmp \
    *.debug \
    *.zip \
    *.log \
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