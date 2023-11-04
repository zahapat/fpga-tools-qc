# Compile & Link Independent OSVVM packages
vlib "${proj_root_dir}simulator/osvvm"
source "${proj_root_dir}simulator/do/compile_osvvm.tcl"
vmap osvvm "${proj_root_dir}simulator/osvvm"


# Compile & Link Independent UVVM packages
vlib "${proj_root_dir}packages/uvvm/uvvm_util/sim/uvvm_util"
vlib "${proj_root_dir}packages/uvvm/uvvm_vvc_framework/sim/uvvm_vvc_framework"
source "${proj_root_dir}simulator/do/compile_uvvm.tcl"
vmap uvvm_util "${proj_root_dir}packages/uvvm/uvvm_util/sim/uvvm_util"
vmap uvvm_vvc_framework "${proj_root_dir}packages/uvvm/uvvm_vvc_framework/sim/uvvm_vvc_framework"


# Find & add generated Xilinx Cores
# Compile & Link Independent Xilinx UNISIM libraries and VCOMPONENTS package
source "${proj_root_dir}simulator/do/compile_xilinx_cores.tcl"