## Description

This module is a square pulse generator allowing to define the duration of high and low levels of the pulse.

The module outputs also busy and ready signals, which are simply their inverted versions. Busy is asserted only if both high and low levels are being produced. Ready is low during this duration, otherwise high if the module is ready to receive a new pulse request throughout the pulse_trigger terminal.

An important feature of this module is that one can create pulses that are equal to the bit levels of the inputted bit array on the "in_data" terminal. If a bit, or all bits, in the array is in zero, the module will still be busy while producing "zero pulse" (high level being logical zero and low level as well, doing nothing but sending a busy flag to notify other modules).