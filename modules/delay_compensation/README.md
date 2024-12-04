## Description

This module performs delay compensation of two 1-bit wide channels with a known delay.

If the delay in one of the two channels is lower, the module will implement an extra delay line to match the delay with the second channel "as close as possible".

"As close as possible" means that the number of clock cycles of the delay is such a number that will achieve the least error in the produced delay (difference between the given delay difference and the created digital delay difference). While ceil function is used in calculating the number of clock periods of delay, this delay is corrected by the "correct_periods" function for lowering the error.

This module operates at ~600 MHz on a commercial FPGA with constrained domain crossing boundaries.