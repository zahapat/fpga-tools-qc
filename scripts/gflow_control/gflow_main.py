# Prerequisites:
#     pip install pywin32

from multiprocessing import Process
from time import sleep
from random import randrange
from GflowFPGA import GflowFPGA


# Main Program
if __name__ == "__main__":

    # Main Loop: This is the master script that 
    # controls FPGA feedforward signals on the fly
    try:

        # Create an instance of the FPGA control C++ API 
        # that allows to control the FPGA in real time
        gflow = GflowFPGA(
            qubits_cnt = 4,               # Set the number of qubits of the desired feedforward operation
            run_seconds = 10.0,           # Run the experiment for ... seconds
            bitfile_name = f"bitfile_top_gflow_all.bit" # Name of the FPGA configuration file
        )

        # Do not touch
        wait_for_consumer_response_ms = 2000 # Change handshaking time

        # Set initial feedforward control variables
        feedforward_active = False           # At the beginning, turn off the feedforward
        rand_int = 0                         # This initial random number will be overriden in the main loop
        run_feedforward_sec = 1              # Run feedforward for ... sec
        rotate_waveplate_sec = 1             # Simulate waveplate rotation delay

        # Set an absolute path where the 'csv_readout.exe' is stored
        # Important: Ensure that it is a RAW r"" string
        path_to_csv_readout_exe = r".\csv_readout.exe"

        # Launch the C++ API and program the FPGA
        # Use run() and update_int() methods to control the FPGA
        process = gflow.launch_api(path_to_csv_readout_exe)



        # Main gflow duty cycle loop
        while True:
            try:
                # Enable/disable FPGA feedforward based on 'feedforward_active' boolean
                # False = pause feedforward
                # True = resume feedforward
                gflow.run(feedforward_active)
            except:
                print(f"Loop: No response from consumer while executing run().")
                break

            # If feedforward is enabled, run for 1 sec
            if feedforward_active == True:
                # Do nothing = record data
                sleep(run_feedforward_sec)

            # If feedforward is disabled, immediately prepare a new random bit string
            # Also, rotate the motoric waveplate
            if feedforward_active == False:
                # Prepare a new 4-bit random number (integer from 0 to 2^4-1)
                rand_int = randrange(0, pow(2,4)-1)
                try:
                    # Send the random bits to the FPGA
                    gflow.update_int(rand_int)
                except:
                    print(f"Loop: No response from consumer while executing update_int().")
                    break

                # TODO
                # Simulate motoric waveplate rotation delay
                sleep(rotate_waveplate_sec)

            # Switch feedforward state from enable -> disable and vice versa
            feedforward_active = not feedforward_active


    # CTRL+C interrupt handling
    except KeyboardInterrupt:
        print("Except: KeyboardInterrupt: Producer stopped on CTRL+C interrupt. Finally block will unlink all shared memory instances.")

    # When both try and except branches are completed
    finally:
        # Deliberately close the API and wait until the command prompt window is closed
        if process is not None:
            process.join()
        del gflow
        print("Finally: All shared memory instances have been unlinked.")