## Destription

The "boards" directory consists of board file generators for Vivado written in Tcl accompanied by XDC constraint files to physically or virtually implement a board project.

Each board project created for specific FPGA will be, most likely, incompatible with other FPGAs or FPGA boards. Therefore, these board generators are present in respective directories named after  the compatible FPGA part number.

## How to Use

General workflow with the use of a board file generator with make:

0. Make sure you are in the project root directory and entered your desired FPGA Part number in "./vivado.mk":
Example: PART = xc7k160tffg676-1

1. Reset the project by typing the following to the command line:
Example 1: make reset
Example 2: make reset PART=genesys2

2. Add all HDL files under the top HDL module to the Vivado project by typing the following to the command line:
Example: make src TOP=top_memristor.vhd

2. 1. Open Vivado in mode GUI to verify these modules were added to Vivado successfully:
Example: make gui

3. Close Vivado. Generate the desired board file for your FPGA using a Tcl script:
Example: make board BOARD=memristor.tcl

3. 1. Open Vivado in mode GUI to verify these modules were added to Vivado successfully. Tghen close Vivado.

4. Run synthesis, implementation and bitstream generation:
Example: run all

5. Program your FPGA


## TODO

1. It would make more sense to rename FPGA part ID directories to FPGA board ID directories for readability