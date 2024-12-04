#include <iostream>
#include <string>
#include <thread>
#include <mutex>
#include <condition_variable>

#include <stdlib.h>
#include <unordered_set>
#include <iomanip>
#include <stdexcept>
#include <errno.h> 

#include <fstream>
#include <stdio.h>
#include <time.h>

#include <bitset>
#include <algorithm>
#include <cmath>

#if defined(__QNX__)
    #include <stdint.h>
    #include <sys/syspage.h>
    #include <sys/neutrino.h>
    #include <sys/types.h>
    #include <sys/usbdi.h>
#elif defined(__linux__)
    #include <sys/time.h>
#elif defined(__APPLE__)
    #include <sys/time.h>
#endif

#include "./lib/okFrontPanel.h"
#include "./lib/guiBackendObj.h"



#if defined(_WIN32)
    // #define sscanf  sscanf_s
    // #define sscanf
#elif defined(__linux__) || defined(__APPLE__)
#endif
#if defined(__QNX__)
    #define clock_t   uint64_t
    #define clock()   ClockCycles()
    #define NUM_CPS   ((SYSPAGE_ENTRY(qtime)->cycles_per_sec))
#else
    #define NUM_CPS   CLOCKS_PER_SEC
#endif

typedef unsigned int UINT32;


#define MIN(a,b)              (((a)<(b)) ? (a) : (b))
// #define PATTERN_READ_ONLY     0

using ms = std::chrono::milliseconds;




// Configure the FPGA with the given configuration bitfile.
bool guiBackendObj::initializeFPGA(okCFrontPanel* okDevice, char* bitfile_name)
{
    try {
        okDevice->GetDeviceInfo(&m_devInfo);
        std::cout << "Found an FPGA device:" << m_devInfo.productName << std::endl;
    }
    catch (...) {
        std::cout << "Catch all: Unable to get device information. Return false." << std::endl;
        return false;
    }

    okDevice->LoadDefaultPLLConfiguration();

    // Get some general information about the OK XEM Board.
    std::cout << "Device firmware version:" << m_devInfo.productName << std::endl;
    std::cout << "Device okBoardOnSerial number:" << m_devInfo.serialNumber << std::endl;
    std::cout << "Device device ID:" << m_devInfo.productID << std::endl;

    if (strcmp("nobit", bitfile_name) != 0) {
        // Download the configuration file.
        if (okCFrontPanel::NoError != okDevice->ConfigureFPGA(bitfile_name)) {
            std::cout << "FPGA configuration failed." << std::endl;
            return false;
        }
    }
    else {
        std::cout << "Skipping FPGA configuration." << std::endl;
    }

    // Check for FrontPanel support in the FPGA configuration.
    if (okDevice->IsFrontPanelEnabled()){
        std::cout << "FrontPanel support is enabled." << std::endl;
    }
    else {
        std::cout << "FrontPanel support is not enabled." << std::endl;
        return false;
    }

    return true;
}


std::tuple<int, int> guiBackendObj::processReceivedData(std::tuple<int, int> col_and_file_id, unsigned char* pucBuffer, UINT32 bufferSize)
{

    // CSV file line creation plan (corresponds with file ./modules/csv_readout/hdl/csv_readout.vhd)
    // readout_data_32b(3 downto 0) = x"F"    : Print out the line buffer
    // readout_data_32b(3 downto 0) = x"E"    : Extra Comma Delimiter
    // readout_data_32b(3 downto 0) = x"1"    : Event-based data group 1/5 (Photons H/V)
    // readout_data_32b(3 downto 0) = x"2"    : Event-based data group 2/5 (Alpha)
    // readout_data_32b(3 downto 0) = x"3"    : Event-based data group 3/5 (Modulo)
    // readout_data_32b(3 downto 0) = x"4"    : Event-based data group 4/5 (Random bit)
    // readout_data_32b(3 downto 0) = x"5"    : Event-based data group 5/5 (Timestamps)
    // readout_data_32b(3 downto 0) = x"6"    : Regular reporting group 1/1 (Coincidence patterns)
    // readout_data_32b(3 downto 0) = x"7"    : Regular reporting group 1/2 (Photon Counting per channel)
    // readout_data_32b(3 downto 0) = x"8"    : Regular reporting group 2/2 (Photon Losses in coincidence window)
    // readout_data_32b(3 downto 0) = x"9"    : Regular reporting 4 (Available)
    // readout_data_32b(3 downto 0) = x"A"    : Regular reporting 5 (Available)
    // readout_data_32b(3 downto 0) = x"B"    : Regular reporting 6 (Available)
    // readout_data_32b(3 downto 0) = x"C"    : Regular reporting 7 (Available)
    // readout_data_32b(3 downto 0) = x"D"    : Regular reporting 8 (Available)
    // readout_data_32b(3 downto 0) = x"0"    : Forbidden: it can mean data loss or unwanted behaviour


    UINT32* pu32Buffer = (UINT32*)pucBuffer;

    // Data Processing: Divide by number of bytes in the total number of bits
    for (i_iter = 0; i_iter < bufferSize/4; i_iter++) {
        uns32b = std::bitset<32>(pu32Buffer[i_iter]);

        // Parse the received command on bits (3 downto 0)
        for(j_iter = 0; j_iter < 4; j_iter++){
            uns4b_cmd.set(j_iter, uns32b[j_iter]);
        }
        command = (UINT32)(uns4b_cmd.to_ulong());

        // Parse the received data on bits (31 downto 4)
        for(j_iter = 0; j_iter < 28; j_iter++){
            uns28b_data.set(j_iter, uns32b[j_iter+4]);
        }
        data = (UINT32)(uns28b_data.to_ulong());

        // Create the CSV line based on the received lower 4 bits stored in 'command_parsed'
        switch(command) {
            case 15: // x"F" Print out the line buffer to outFile1/2
                if (actual_file_csv3){
                    outFile3 << "," << std::to_string(data) << std::endl;
                    actual_file_csv3 = false; // NEW
                }

                if (actual_file_csv2){
                    outFile2 << "," << std::to_string(data) << std::endl;
                    actual_file_csv2 = false; // NEW
                }

                if (actual_file_csv1){
                    outFile1 << "," << std::to_string(data) << std::endl;
                    actual_file_csv1 = false; // NEW
                }
                break;

            case 14: // x"E" Extra Comma Delimiter to outFile1/2/..
                if (actual_file_csv1){
                    outFile1 << ",";
                }
                else if (actual_file_csv2){
                    outFile2 << ",";
                }
                else if (actual_file_csv3){
                    outFile3 << ",";
                }
                break;

            case 1:  // x"1" Event-based data group (Photons H/V) to outFile1
                outFile1 << std::to_string(data) << ",";
                actual_column_cntr_csv1++;
                actual_file_csv1 = true; // NEW
                break;

            case 2:  // x"2" Event-based data group (Alpha) to outFile1
                outFile1 << std::to_string(data) << ",";
                actual_column_cntr_csv1++;
                actual_file_csv1 = true; // NEW
                break;

            case 3:  // x"3" Event-based data group (Modulo) to outFile1
                outFile1 << std::to_string(data) << ",";
                actual_column_cntr_csv1++;
                actual_file_csv1 = true; // NEW
                break;

            case 4:  // x"4" Event-based data group (Random bit) to outFile1
                outFile1 << std::to_string(data) << ",";
                actual_column_cntr_csv1++;
                actual_file_csv1 = true; // NEW
                break;

            case 5:  // x"5" Event-based data group (Timestamps) to outFile1
                outFile1 << std::to_string(data) << ",";
                actual_column_cntr_csv1++;
                actual_file_csv1 = true; // NEW
                break;

            case 6:  // x"6" Regular reporting group (Coincidence patterns) to outFile2
                outFile2 << std::to_string(data) << ",";
                actual_column_cntr_csv2++;
                actual_file_csv2 = true; // NEW
                break;

            case 7:  // x"7" Regular reporting (Photon Channel Counting)
                outFile3 << std::to_string(data) << ",";
                actual_file_csv3 = true; // NEW
                break;

            case 8:  // x"8" Regular reporting (Photon Losses)
                outFile3 << std::to_string(data) << ",";
                actual_column_cntr_csv3++;
                actual_file_csv3 = true; // NEW
                break;
            
            default:
                // Regular reporting 4 (Available)
                // Regular reporting 5 (Available)
                // Regular reporting 6 (Available)
                // Regular reporting 7 (Available)
                // Regular reporting 8 (Available)
                std::cout << "Udefined behaviour: cmd out of range (0 to 2^4). Detected cmd: " << command << std::endl;
                break;
        }
    }

    return {0, 0};
}



void guiBackendObj::printEntireTransaction(std::bitset<32> uns32b)
{
    std::cout 
        << int(uns32b[31])
        << int(uns32b[30])
        << int(uns32b[29])
        << int(uns32b[28])
        << int(uns32b[27])
        << int(uns32b[26])
        << int(uns32b[25])
        << int(uns32b[24])
        << int(uns32b[23])
        << int(uns32b[22])
        << int(uns32b[21])
        << int(uns32b[20])
        << int(uns32b[19])
        << int(uns32b[18])
        << int(uns32b[17])
        << int(uns32b[16])
        << int(uns32b[15])
        << int(uns32b[14])
        << int(uns32b[13])
        << int(uns32b[12])
        << int(uns32b[11])
        << int(uns32b[10])
        << int(uns32b[9])
        << int(uns32b[8])
        << int(uns32b[7])
        << int(uns32b[6])
        << int(uns32b[5])
        << int(uns32b[4])
        << int(uns32b[3])
        << int(uns32b[2])
        << int(uns32b[1])
        << int(uns32b[0])
        << std::endl;
}




bool guiBackendObj::Read(unsigned char* dataBufferRead_thread1, okCFrontPanel* okDevice, UINT32 m_u32TransferSizeCount)
{

    // unsigned char* dataBufferRead_thread1;
    UINT32 i;
    UINT32 u32SegmentSize;
    UINT32 u32Remaining;


    // This contains some I/O processed_data value (long integer)
    long value_tx_or_rx;


    // Get m_u32TransferSize m_u32TransferSizeCount-times
    for (i=0; i<m_u32TransferSizeCount; i++) {

        // Start one m_u32TransferSize
        u32Remaining = m_u32TransferSize;
        while (u32Remaining > 0) {

            // How many bits is going to be sent/retrieved in this cycle
            u32SegmentSize = MIN(m_u32SegmentSize, u32Remaining);
            u32Remaining -= u32SegmentSize;

            // Perform Reading from Pipe Out at address 0xA0
            if (0 == m_u32BlockSize) {
                value_tx_or_rx = okDevice->ReadFromPipeOut(0xA0, u32SegmentSize, dataBufferRead_thread1);
            } else {
                value_tx_or_rx = okDevice->ReadFromBlockPipeOut(0xA0, m_u32BlockSize, u32SegmentSize, dataBufferRead_thread1);
            }

            // Check for invalid values
            if (value_tx_or_rx < 0) {
                switch (value_tx_or_rx) {
                    case okCFrontPanel::InvalidBlockSize:
                        std::cout << "Block Size Not Supported" << std::endl;
                        break;
                    case okCFrontPanel::UnsupportedFeature:
                        std::cout << "Unsupported Feature" << std::endl;
                        break;
                    default:
                        std::cout << std::setw(64) << "Transfer Failed with Error: " << value_tx_or_rx << std::endl;
                        break;
                }

                if (okDevice->IsOpen() == false) {
                    std::cout << "Device disconnected" << std::endl;

                    // Largest possible exit code as "unknown error" or "abort" (it's unlikely to ever conflict with a meaningful status value)
                    // exit(-1);
                }

                // Unsuccessful data transfer
                return true;
            }
        }
    }

    return false;
}



// This thread reads processed_data from the FPGA
int guiBackendObj::thread1_acquire()
{

    std::cout << "thread1_acquire: Entered" << std::endl;

    // Initialize timer
    std::chrono::duration<double> float_time_difference = std::chrono::duration<double>(0.0);
    const auto time_start = std::chrono::high_resolution_clock::now();

    // Verify Command Line Arguments (for debugging)
    std::cout << "thread1_acquire: Verification: program_only = " << program_only << std::endl;
    std::cout << "thread1_acquire: Verification: qubits_count = " << qubits_count << std::endl;
    std::cout << "thread1_acquire: Verification: float_run_time_seconds = " << float_run_time_seconds << std::endl;
    std::cout << "thread1_acquire: Verification: bitfile_name = " << bitfile_name << std::endl;

    // Initilize temrination request for switching it later
    bool thread1_stop_request = false;


    // Establish connection with the device given by okBoardOnSerial (if "", then gets one device)
    okDevicePtr = allOkDevices.Open(okBoardOnSerial);
    okCFrontPanel* const okDevice = okDevicePtr.get();
    for (int i = 1; i <= 5; i++) {
        if (!okDevice) {
            if (!allOkDevices.GetCount()) {
                std::cout << "thread1_acquire: No connected devices detected." << std::endl;
            }
            else {
                // Device(s) detected, but not with the target okBoardOnSerial specified.
                std::cout << "thread1_acquire: Devices detected but the board on specified serial '" << okBoardOnSerial << "' is missing or could not be accessed." << std::endl;
            }
            thread1_stop_request = true;
            std::cout << "thread1_acquire: Waiting for connection. (Attempt " << i << "/5)." << std::endl;
            std::this_thread::sleep_for(ms(1000));
            okDevicePtr = allOkDevices.Open(okBoardOnSerial);
            okCFrontPanel* const okDevice = okDevicePtr.get();
        }
        else {
            thread1_stop_request = false;
            std::cout << "thread1_acquire: An FPGA device has been successfully detected." << std::endl;
            break;
        }
    }


    // Program the FPGA, gracefully terminate the program if initializeFPGA is unsuccessful
    if (!thread1_stop_request){
        try {
            if (false == initializeFPGA(okDevice, bitfile_name)) {
                std::cout << "thread1_acquire: Target FPGA '" << okDevice << "' could not be initialized with the given bitfile: '" << bitfile_name << "'" << std::endl;
                throw std::runtime_error("thread1_acquire: RUNTIME ERROR: An error occurred while programming the FPGA.");
                thread1_stop_request = true;
            } 
            else {
                std::cout << "thread1_acquire: Target FPGA '" << okDevice << "' has been programmed successfully with bitfile: '" << bitfile_name << "'" << std::endl;
            }
        }
        catch (const std::runtime_error &e) {
            std::cout << "thread1_acquire: runtime_error handler: " << e.what() << " Bitfile used: '" << bitfile_name << "'" << std::endl;
            thread1_stop_request = true;
        }
        catch (...) {
            std::cout << "thread1_acquire: Exception handler: FPGA initialization was unsuccessful using the bitfile: '" << bitfile_name << "'" << std::endl;
            thread1_stop_request = true;
        }
    }
    else {
        std::cout << "thread1_acquire: Skipping FPGA programming due to device access." << std::endl;
    }


    // Allocate memory of one transfer size
    // unsigned char* dataBufferRead;
    #if defined(__QNX__)
        dataBufferRead_thread1 = (unsigned char*)usbd_alloc((size_t)m_u32SegmentSize);
    #else
        // Contains raw processed_data to/from the FPGA
        // + 1 = additional data slot returns error value
        dataBufferRead = new unsigned char[m_u32SegmentSize];
    #endif

    // Skip readout if program_only flag is set to true
    if (program_only == true) {
        thread1_stop_request = true;
        std::cout << "thread1_acquire: Skipping readout on request." << std::endl;
    }

    // Acquire processed_data (only if program_only flag is false)
    for(;;){

        std::unique_lock<std::mutex> lock(mtx);

        // release the lock and wait until ready_new_value has been consumed [ready_new_value should be FALSE to proceed after wait]
        cv.wait(lock, [this]{ return !ready_new_value; });

        // Stop Condition 1: Break the loop on timeout and notify thread 2 later if stop condition is asserted
        float_time_difference = std::chrono::high_resolution_clock::now() - time_start;
        if (float_time_difference >= std::chrono::duration<double>(float_run_time_seconds)) {
            std::cout << "thread1_acquire: [timer]: Readout timeout @" << std::chrono::duration_cast<std::chrono::nanoseconds>(float_time_difference).count()/1e9 << " sec." << std::endl;
            thread1_stop_request = true;
        }

        // Stop Condition 2: Perform Read and scan for errors
        if (!thread1_stop_request) {
            // Read per 1x TransferSize blocks of processed_data, scan for errors and notify thread 2 later if stop condition is asserted
            // Note: The FIFO must not be empty while performing this operation
            thread1_stop_request = Read(dataBufferRead, okDevice, 1);

            if (thread1_stop_request)
                std::cout << "thread1_acquire: [Read]: An error occurred while performing Read operation. Exit." << std::endl;
        }

        // Update OK/NOK status
        thr1_to_thr2_stop_request = thread1_stop_request;

        // Handshake
        ready_new_value = true;

        // Wake up thread2_process_data
        cv.notify_one();

        // Condition to stop the infinite loop
        if (thread1_stop_request == true){
            std::cout << "thread1_acquire: Exit Thread" << std::endl;
            break;
        }
    }


    // Deallocate memory
    std::cout << "thread1_acquire: Deallocate." << std::endl;
    #if defined(__QNX__)
        usbd_free(dataBufferRead);
    #else
        delete [] dataBufferRead;
    #endif

    return(0);
}



// This thread processes data from the FPGA
void guiBackendObj::thread2_process_data()
{

    std::cout << "thread2_process_data: Entered" << std::endl;

    // Initilize temrination request for switching it later
    bool thread2_stop_request = false;

    // Initialize tuple pointer
    std::tuple<int, int> col_and_file_id = {0, 0};

    // Data to be transferred from thread 1 to thread 2
    unsigned char* thread2_dataBufferRead = new unsigned char[m_u32SegmentSize];

    for(;;){

        // Add some delay to get new values
        // std::this_thread::sleep_for(ms(10));

        std::unique_lock<std::mutex> lock(mtx);

        // Release the lock and wait until ready_new_value has been produced
        cv.wait(lock, [this]{ return ready_new_value; });

        // Condition to stop the infinite loop
        if (thread2_stop_request == true){
            std::cout << "thread2_process_data: Exit Thread" << std::endl;
            break;
        }

        // Process data, break on error
        thread2_stop_request = thr1_to_thr2_stop_request;

        if (!thread2_stop_request) {

            std::copy(&dataBufferRead[0], &dataBufferRead[0] + m_u32SegmentSize, &thread2_dataBufferRead[0]);

            // Wake up thread1_acquire
            ready_new_value = false;
            cv.notify_one();

            col_and_file_id = processReceivedData(col_and_file_id, thread2_dataBufferRead, m_u32TransferSize);
        }
    }
}


// Linkage with other languages: functions to be linked - declaration
extern "C" {

    // guiBackendObj - Constructor
    guiBackendObj *linked_ObjectConstructor() {
        return new guiBackendObj();
    }

    // guiBackendObj - Destructor
    void linked_ObjectDestructor(guiBackendObj* ptrLinkedObject) {
        delete ptrLinkedObject;
    }

}


int main(int argc, char** argv)
{
    // Parse Command Line Arguments
    std::vector<std::string> all_args;
    bool parsing_error = false;

    int qubits_count = 6;
    double float_run_time_seconds = 0;
    char* bitfile_name;
    bool program_only = false;

    // Load Command Line Arguments as a list
    all_args.assign(argv, argv + argc);

    for (int i = 1; i < argc; ++i) {
        std::cout << "Parsing argument: " << all_args[i] << std::endl;

        if (strcmp(argv[i], "-h") == 0 || strcmp(argv[i], "--help") == 0) {
            std::cout << "Usage: " << argv[0] << " [options]" << std::endl;
            std::cout << "Options:" << std::endl;
            std::cout << "  -h, --help                     : to show this help message." << std::endl;
            std::cout << "  -q, --qubits_count <int>       : for accurate csv headers." << std::endl;
            std::cout << "  -t, --run_for_seconds <int>    : stop readout after the given number of seconds." << std::endl;
            std::cout << "  -b, --bitfile_name <file_name> : to specify the target bitfile to program the FPGA with." << std::endl;
            std::cout << "  -p, --program_only <file_name> : only program FPGA if 'true', otherwise perform readout if 'false'." << std::endl;
        }

        else if (strcmp(argv[i], "-q") == 0 || strcmp(argv[i], "--qubits_count") == 0) {
            qubits_count = atoi(argv[++i]);
            std::cout << "Number of qubits: " << qubits_count << std::endl;
        }

        else if (strcmp(argv[i], "-t") == 0 || strcmp(argv[i], "--float_run_time_seconds") == 0) {
            float_run_time_seconds = atof(argv[++i]);
            std::cout << "Run for " << float_run_time_seconds << " seconds." << std::endl;
        }

        else if (strcmp(argv[i], "-b") == 0 || strcmp(argv[i], "--bitfile_name") == 0) {
            bitfile_name = argv[++i];
            std::cout << "Bitfile name: " << bitfile_name << std::endl;
        }

        else if (strcmp(argv[i], "-p") == 0 || strcmp(argv[i], "--program_only") == 0) {
            // String to bool conversion
            std::string arg_str = argv[++i];
            std::transform(arg_str.begin(), arg_str.end(), arg_str.begin(),
                   [](unsigned char ch){ return std::tolower(ch); }
            );

            if (!(arg_str.compare("true"))) {
                program_only = true;
            }
            else if (!(arg_str.compare("false"))) {
                program_only = false;
            } 
            else {
                std::cout << "Invalid parameter '" << arg_str << "' detected when parsing '-p' or '--program_only' CLI argument." << std::endl;
                parsing_error = true;
            }
            std::cout << "Program FPGA only switch: " << program_only << std::endl;
        }

        else {
            std::cout << "Unrecognised argument." << std::endl;
            parsing_error = true;
        }
    }

    if (parsing_error == true) {
        std::cout << "Invalid use of command line arguments." << std::endl;
        std::cout << "Launch: " << argv[0] << " -h" << std::endl;
        std::cout << "     for more details about how to use this file." << std::endl;
        return 0;
    }


    // Declare the Opal Kelly csv_readout class
    guiBackendObj f(
        program_only=program_only,
        qubits_count=qubits_count,
        float_run_time_seconds=float_run_time_seconds,
        bitfile_name=bitfile_name
    );


    std::thread t1(&guiBackendObj::thread1_acquire, &f);
    std::thread t2(&guiBackendObj::thread2_process_data, &f);

    
    std::cout << "DEBUG: Waiting for t1 to join" << std::endl;
    t1.join();
    std::cout << "DEBUG: Waiting for t2 to join" << std::endl;
    t2.join();
    return 0;
}