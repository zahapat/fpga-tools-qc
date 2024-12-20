## Description

This module contains the RTL hardware architecture of a feedforward controller project and a testbench. It contains lower level modules and information about how they are interconnected in the design.

The source file, located in 'hdl' directory, is a structural hardware description file with three clock domains: 

1. 600 MHz clock domain for analog pulse sampling from single photon detectors and delay compensation of horizontal and vertical photons.
2. 300 MHz clock domain for performing feedforward, photon counting and probing signals for readout.
3. 200 MHz clock domain for readout using 32-bit csv_readout module, which allows to write to multiple '.csv' files and group multidimensional data together.

The ./hdl folder also consists of 'top_feedforward_ok_wrapper.vhd', which wraps up the 'top_feedforward.vhd' module, and instantiates Opal Kelly Frontpanel Host for high-speed USB 3.0 communication with the FPGA and PC. Once all required source files are loaded in Vivado, the 'top_feedforward_ok_wrapper.vhd' can be dragged-and-dropped into the schematic board designer.

