## Description

This directory contains Tcl scripts for various purposes. For example, tools for automizing building designs, cleaning repository, generating compile order, controlling Xilinx tools from command line.

# How to Use

Tcl scripts can be called from Tcl console in Vivado or using make commands in command line.

In Vivado Tcl shell, a Tcl script can be executed by typing the following syntax:
"source './tcl/project_specific/vivado/add_ip_cores.tcl'"

A make command can be executed from the root directory:
make src TOP=top_gflow.vhd

Which will launch make_src.tcl script, which finds all submodules of the top_gflow.vhd HDL module and adds them to the project and simulator.

## TODO

There are some redundant and unused scripts. For example, make_new_module was created to save time, however, it is significantly buggy and I don't recommend to use it. But it is a good source for some inspiration.