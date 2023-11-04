# Remove files
file delete [glob -type f -nocomplain -directory \
    ${origin_dir}/*.str \
    ${origin_dir}/*.tmp \
    ${origin_dir}/*.tmp \
    ${origin_dir}/simulator/modules.tcl
]

# Remove directories
file delete -force -- ${origin_dir}/.Xil
file delete -force -- ${origin_dir}/vivado

# Re/Create new directories if they don't exist
if {![file exist "${origin_dir}/ip"]} {
    file mkdir "${origin_dir}/ip"
}