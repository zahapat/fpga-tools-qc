## Description

This module performs the calculation of the equation below where inputs are max 2 bits
and Pi is represented as 2 since (mod 2Pi) has been substituted by (mod 4) for the feasibility of bitwise operations in FPGAs. 

The mathematical operation performed by the module is:

alpha_prime = ((-1)**s_x * alpha) + ((s_z + r)*Pi)

This modules calculates the alpha_prime for every input value at every time instant. Therefore, qubit_valid signal does not work as an enable signal, but is only passed to the next module through one intermediate register. Calculation takes in total 3 tacts.

1. tact: Calculate separate factors of the equation
2. tact: Calculate modulo
3. tact: Modulo is ready

The module supports also asynchrnous regime to calculate separate factors of the equation by setting SYNCH_FACTORS_CALCULATION generic to false to save one clock cycle.

The module also samples intermediate values, such as alpha, random bit and also modulo (alpha_prime) and sends them to the temporary buffer and then to TX USB3 FIFO once qubit_valid is asserted.