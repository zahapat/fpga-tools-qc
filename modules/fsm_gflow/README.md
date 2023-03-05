## Description

This module is the core of the flow ambiguity protocol. It performs waiting for data from the faster clock domain and monitoring activity on all eight channels (4 pairs of channels), to perform a 4-qubit coordination control sequence. In addition, a coarse counter has been used to sample time when a valid click has been detected. Early implementation used Finite State Machine (FSM) description using case statements. However, more scalable description was chosen to extend the lifetime of this module and improve its scalability.

This type of description has one main advantage. FSMs are usually robust and well optimized by many sinthesizers today. One can also select the desired state encoding in Vivado. However, their description is static and is thus not possible to vary the number of states (Qubits) in the FSM. Therefore, parallel description mimicking the FSM operation was chosen, which allows the module to be re-scaled for highed or lesser number of qubits to be supported by the module. This has been done by

Its operation is summarized in steps below:

1. Suppose the controller is in state 1 out of 4. The controller waits for the first qubit. Once detected, save actual time, and forward data to the next modules. Switch to state 2 out of 4. Get feedback from further modules to calculate next mathematical values. If nothing was detected, wait for longer until the first qubit is detected.

2. The controller is now in state 2. In this state, it waits predefined amount of time for the qubit 2. Once successfully detected, save actual time, pass data to the next module and set the state machine to the qubit 3 state. If not, go back to qubit 1 state.

3. The controller is now in state 3 and waiting for certain amount of time for qubit 3. Once detected, save actual time, pass data to the following module and set the state machine to the qubit 4 state. If not, go back to qubit 4 state.

4. The controller is not in state 4 waiting for specific amount of time for qubit 4. Once detected, cave actual time, pass data to the following module and set the state machine to the qubit 1 state.

5. In the qubit 1 state, the controller waits again, but this time until the kHz control pulse propagates through the circuitry. After this, the controller waits for qubit 1 again as described in point no. 1.


## TODO

Clean the code from earllier implementations.

Perform further testing with more qubits to verify scalability.