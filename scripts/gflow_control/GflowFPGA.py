# Prerequisites:
#     pip install pywin32

from win32event import CreateSemaphore, ReleaseSemaphore, WaitForSingleObject
from multiprocessing import Process, shared_memory, Semaphore
from os import system, path

class GflowFPGA:

    # Constructor
    def __init__(
        self, 
        qubits_cnt:int = 4, 
        run_seconds:float = 10.0, 
        bitfile_name:str = "bitfile.bit"
    ) -> None:

        # *** C++ API Variables ***
        self.qubits_cnt = qubits_cnt
        self.run_seconds = run_seconds
        self.bitfile_name = bitfile_name
        self.program_only = False

        # *** Handshaking Variables ***
        self.timeout_ms = 2000

        # Clean existing shared memory instances
        self.remove_shared_mem(shm_name="Global/runff_sharedmem")
        self.remove_shared_mem(shm_name="Global/rand_sharedmem")

        # Feedforward Start/Pause: Create shared memory 
        # handle and semaphores for producer and consumer 
        # only once, otherwise link them
        self.shared_mem_handle_runff = \
            shared_memory.SharedMemory(
                name = "Global/runff_sharedmem",
                create = True, # Set to false to attach existing shared memory, else create a new one
                size = 1       # No. of bytes
            )
        self.producer_semaphore_handle_runff = \
            CreateSemaphore(
                None, 0, 1, "Global/producer_semaphore_runff")
        self.consumer_semaphore_handle_runff = \
            CreateSemaphore(
                None, 0, 1, "Global/consumer_semaphore_runff")

        # Random Bit: Create shared memory handle and 
        # semaphores for producer and consumer only once, 
        # otherwise link them
        self.shared_mem_handle_int = \
            shared_memory.SharedMemory(
                name = "Global/rand_sharedmem",
                create = True, # Set to false to attach existing shared memory, else create a new one
                size = 1       # No. of bytes
            )
        self.producer_semaphore_handle_int = \
            CreateSemaphore(
                None, 0, 1, "Global/producer_semaphore_rand")
        self.consumer_semaphore_handle_int = \
            CreateSemaphore(
                None, 0, 1, "Global/consumer_semaphore_rand")



    # Remove existing shared memory with the same name as the one to be created
    def remove_shared_mem(self, shm_name):
        try:
            shm = shared_memory.SharedMemory(name=shm_name, create=False)
        except FileNotFoundError:
            print(f"Shared memory block '{shm_name}' not found.")
            return

        shm.close()  # Close the handle
        shm.unlink()  # Remove the shared memory block



    # Launch C++ Opal Kelly API
    def launch_api(self, RAWSTRING_path_to_exe:str="") -> int:
        if RAWSTRING_path_to_exe == r"":
            RAWSTRING_path_to_exe = r".\csv_readout.exe"
        elif RAWSTRING_path_to_exe == None:
            RAWSTRING_path_to_exe = r".\csv_readout.exe"
        else:
            path_to_exe = path.normpath(RAWSTRING_path_to_exe)
            print("path_to_exe = ", path_to_exe)

        if path.exists(path_to_exe):
            print("path_to_exe exists. Proceed to launch the executable.")
            pass
        else:
            print("path_to_exe does NOT exist. Return.")
            return None

        keep_window_open = f"/k "
        command_cmd_window = f"start /wait cmd " + keep_window_open

        arg_qubits_cnt = f" --qubits_count {self.qubits_cnt} "
        arg_run_seconds = f" --float_run_time_seconds {self.run_seconds} "
        arg_bitfile_name = f" --bitfile_name {self.bitfile_name} "
        arg_program_only = f" --program_only {self.program_only} "

        launch_api_cmd = path_to_exe \
            + arg_qubits_cnt \
            + arg_run_seconds \
            + arg_bitfile_name \
            + arg_program_only

        full_command = command_cmd_window + launch_api_cmd

        # Launch the .exe file in a separate process
        proc = Process(target=system, args=(full_command,))
        proc.start()

        # Return Process ID
        return proc



    # Send real-time feedforward start(=true) / pause(=false) command to the FPGA through C++ API via shared memory
    def run(self, command: bool) -> int:

        try:
            # 1. Feedforward Start(True)  /  Pause(False)
            # Signal to consumer that feedforward control bit is ready
            self.shared_mem_handle_runff.buf[0] = 1 if command else 0  # Store the boolean
            print(f"Producer: Feedforward enabled {command}")
            ReleaseSemaphore(self.consumer_semaphore_handle_runff, 1)

            # Wait for consumer to get the transmitted data
            # Returns 0 on success, 258 on timeout (should never happen, this most likely means data loss)
            return WaitForSingleObject(self.producer_semaphore_handle_runff, self.timeout_ms)

        except:
            print(f"feedforward_active: Consumer did not capture data within the expected {self.timeout_ms} ms. The consumer has finished or has not started yet.")
            raise TimeoutError(f"feedforward_active: Consumer did not capture data within the expected {self.timeout_ms} ms. The consumer has finished or has not started yet.")


    # Send real-time integer number to the FPGA through C++ API via shared memory
    def update_int(self, send_int: int) -> int:

        try:
            # 1. Feedforward Start(True)  /  Pause(False)
            # Signal to consumer that feedforward control bit is ready
            self.shared_mem_handle_int.buf[0] = send_int  # Send the random integer
            print(f"Producer: Send random number: {send_int}")
            ReleaseSemaphore(self.consumer_semaphore_handle_int, 1)

            # Wait for consumer to get the transmitted data
            # Returns 0 on success, 258 on timeout (should never happen, this most likely means data loss)
            return WaitForSingleObject(self.producer_semaphore_handle_int, self.timeout_ms)

        except:
            print(f"update_int: Consumer did not capture data within the expected {self.timeout_ms} ms. This may result in data loss or unexpected behavior of the code.")
            raise TimeoutError(f"update_int: Consumer did not capture data within the expected {self.timeout_ms} ms. This may result in data loss or unexpected behavior of the code.")


    # Destructor
    def __del__(self):
        self.shared_mem_handle_runff.close()
        self.shared_mem_handle_runff.unlink()
        self.shared_mem_handle_int.close()
        self.shared_mem_handle_int.unlink()