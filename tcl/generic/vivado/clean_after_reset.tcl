# Remove files
file delete [glob -type f -nocomplain -directory \
    ${origin_dir}/*.ip \
    ${origin_dir}/*.modelsim.version \
    ${origin_dir}/.cxl.modelsim.version \
    ${origin_dir}/*.log \
    ${origin_dir}/*.bak \
    ${origin_dir}/*.ini \
]

# Remove directories
file delete -force -- ${origin_dir}/.cxl.ip
file delete -force -- ${origin_dir}/.Xil