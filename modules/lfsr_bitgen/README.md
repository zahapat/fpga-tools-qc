## Description

This module performs pseudorandom bit generator using a linear feedback shift register (LFSR).

First, symbols of a user-defined Galois Field (GF) are being generated. Second, each of these bits is being transmitted one by one. Third, after the last bit is successfully outputted, new symbol is generated and the process repeats.

This module can serve as a pseudorandom input emulator and operates at frequencies above 300 MHz on a commercial FPGA. It is envisaged that the larger Galois Fields will reduce the maximum frequency.