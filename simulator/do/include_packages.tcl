# Compile & Link Independent OSVVM packages
source "${proj_root_dir}simulator/do/compile_osvvm.tcl"
vlib "${proj_root_dir}simulator/osvvm"
vmap osvvm "${proj_root_dir}simulator/osvvm"


# Compile & Link Independent UVVM packages
source "${proj_root_dir}simulator/do/compile_uvvm.tcl"
vlib "${proj_root_dir}packages/uvvm/uvvm_util/sim/uvvm_util"
vlib "${proj_root_dir}packages/uvvm/uvvm_vvc_framework/sim/uvvm_vvc_framework"
vmap uvvm_util "${proj_root_dir}packages/uvvm/uvvm_util/sim/uvvm_util"
vmap uvvm_vvc_framework "${proj_root_dir}packages/uvvm/uvvm_vvc_framework/sim/uvvm_vvc_framework"


# Find & add generated Xilinx Cores
# Compile & Link Independent Xilinx UNISIM libraries and VCOMPONENTS package
source "${proj_root_dir}simulator/do/compile_xilinx_cores.tcl"