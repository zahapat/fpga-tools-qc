## Description

This module is the core of the flow ambiguity protocol. It performs waiting for data from the faster clock domain and monitoring the activity on two to six channels (3 channel pairs), to perform a 2- to 6-qubit coordination control sequence. In addition, a coarse counter has been used to sample the time of a horizontal/vertical photon detection. Early implementations itilized Finite State Machine (FSM) description using case statements. However, more scalable description was chosen to extend the lifetime of this module and ensure its scalability.

The FSM type of description has one main disadvantage. The traditional FSM-based description is static (does not allow to vary the number of states via generic variables), hence an alternative approach was chosen with parallel comparators and binary encoded states, mimicking the FSM operation. This allows the module to be re-scaled for higher or lower number of qubits, which increases the lifetime of this module.

The basic operation is summarized as follows:

1. Suppose the controller is in state 1 out of 4. The controller waits for the first qubit detection (horizontal (bit 1) or vertical photon (bit 0)). If detected, save actual time, and forward data to the next module, which calculates the functional dependence of alpha_prime on alpha. Switch to state 2 out of 4. Get feedback from further modules to calculate next mathematical values. If nothing was detected, wait for longer until the first qubit is detected.

2. The controller is now in state 2. In this state, it waits predefined amount of time for the photon 2. Once successfully detected, save actual time, pass data to functional dependence module and set the state machine to the photon 3 state. If not, go back to the photon 1 state.

3. The controller is now in state 3, waiting for the required numbed of clock periods for photon 3. Once detected, save actual time, pass data to the functional dependence module and set the state machine to the photon 4 state. Go back to photon 4 state if no horizontal or vertical photon has been detected.

4. The controller in the state 4 waits for the required number of clock periods for photon 4 H/V detection. Once detected, save actual time, pass data to the functional dependence module and set the state machine to the photon 1 state. Set successful flow flag to logical one state or leave deasserted if the photon has not been detected.

5. In the photon 1 state, before detecting photon 1, the controller waits until the pulse generation is finished. After this, the controller waits for photon 1 again as described in the point no. 1.