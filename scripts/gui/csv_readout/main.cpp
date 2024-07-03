#include <iostream>
#include <string>
#include <thread>
#include <mutex>
#include <condition_variable>

#include <stdlib.h>
#include <unordered_set>

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






// Configure the FPGA with the given configuration bitfile.
bool guiBackendObj::initializeFPGA(okCFrontPanel* okDevice, char* bitfile)
{
    okDevice->GetDeviceInfo(&m_devInfo);
    printf("Found a device: %s\n", m_devInfo.productName);

    okDevice->LoadDefaultPLLConfiguration();

    // Get some general information about the OK XEM Board.
    printf("Device firmware version: %d.%d\n", m_devInfo.deviceMajorVersion, m_devInfo.deviceMinorVersion);
    printf("Device okBoardOnSerial number: %s\n", m_devInfo.serialNumber);
    printf("Device device ID: %d\n", m_devInfo.productID);

    if (strcmp("nobit", bitfile) != 0) {
        // Download the configuration file.
        if (okCFrontPanel::NoError != okDevice->ConfigureFPGA(bitfile)) {
            printf("FPGA configuration failed.\n");
            return false;
        }
    }
    else {
        printf("Skipping FPGA configuration.\n");
    }

    // Check for FrontPanel support in the FPGA configuration.
    if (okDevice->IsFrontPanelEnabled()){
        printf("FrontPanel support is enabled.\n");
    }
    else {
        printf("FrontPanel support is not enabled.\n");
        return false;
    }

    return true;
}


std::tuple<int, int> guiBackendObj::processReceivedData(std::tuple<int, int> col_and_file_id, unsigned char* pucBuffer, UINT32 bufferSize)
{
    // Catch up with processing done previously
    int actual_column_cntr = std::get<0>(col_and_file_id);
    int actual_file_id = std::get<1>(col_and_file_id);

    outFile1.open("outputFile1.csv", std::ofstream::app);
    outFile2.open("outputFile2.csv", std::ofstream::app);

    // CSV file line creation plan
    // readout_data_32b(3 downto 0) = x"F"    : Print out the line buffer
    // readout_data_32b(3 downto 0) = x"E"    : Extra Comma Delimiter
    // readout_data_32b(3 downto 0) = x"1"    : Event-based data group (Photons H/V)
    // readout_data_32b(3 downto 0) = x"2"    : Event-based data group (Alpha)
    // readout_data_32b(3 downto 0) = x"3"    : Event-based data group (Modulo)
    // readout_data_32b(3 downto 0) = x"4"    : Event-based data group (Random bit)
    // readout_data_32b(3 downto 0) = x"5"    : Event-based data group (Timestamps)
    // readout_data_32b(3 downto 0) = x"6"    : Regular reporting group (Coincidence patterns)
    // readout_data_32b(3 downto 0) = x"7"    : Regular reporting 2 (Available)
    // readout_data_32b(3 downto 0) = x"8"    : Regular reporting 3 (Available)
    // readout_data_32b(3 downto 0) = x"9"    : Regular reporting 4 (Available)
    // readout_data_32b(3 downto 0) = x"A"    : Regular reporting 5 (Available)
    // readout_data_32b(3 downto 0) = x"B"    : Regular reporting 6 (Available)
    // readout_data_32b(3 downto 0) = x"C"    : Regular reporting 7 (Available)
    // readout_data_32b(3 downto 0) = x"D"    : Regular reporting 8 (Available)
    // readout_data_32b(3 downto 0) = x"0"    : Forbidden: it can mean data loss or unwanted behaviour

    UINT32 i;
    UINT32* pu32Buffer = (UINT32*)pucBuffer;
    std::bitset<32> uns32b;
    std::bitset<28> uns28b_data;
    std::bitset<4> uns4b_cmd;

    int write_max_clusters_per_process = 1;
    int written_clusters_per_process = 0;

    // Data Processing: Divide by number of bytes in the total number of bits
    for (i=0; i<bufferSize/4; i++) {

        // If data nonzero (zero is invalid transaction carrying no information, possibly unwanted behaviour)
        if (pu32Buffer[i])
            uns32b = std::bitset<32>(pu32Buffer[i]);

        // Parse the received command on bits (3 downto 0)
        for(int j = 0; j < 4; j++){
            uns4b_cmd.set(j, uns32b[j]);
        }
        UINT32 command = (UINT32)(uns4b_cmd.to_ulong());

        // Parse the received data on bits (31 downto 4)
        for(int j = 4; j < 32; j++){
            uns28b_data.set(j, uns32b[j]);
        }
        UINT32 data = (UINT32)(uns28b_data.to_ulong());

        // Create the CSV line based on the received lower 4 bits stored in 'command_parsed'
        switch (command){
            case 15: // Print out the line buffer to outFile1/2
                if (actual_file_id = 1){
                    outFile1 << std::endl;
                } else if (actual_file_id = 2){
                    outFile2 << std::endl;
                }
                actual_column_cntr = 0;

            case 14: // Extra Comma Delimiter to outFile1/2
                if (actual_file_id = 1){
                    outFile1 << ",";
                } else if (actual_file_id = 2){
                    outFile2 << ",";
                }
                actual_column_cntr++;

            case 1:  // Event-based data group (Photons H/V) to outFile1
                outFile1 << std::to_string(data) << ",";
                actual_column_cntr++;
                actual_file_id = 1;

            case 2:  // Event-based data group (Alpha) to outFile1
                outFile1 << std::to_string(data) << ",";
                actual_column_cntr++;
                actual_file_id = 1;

            case 3:  // Event-based data group (Modulo) to outFile1
                outFile1 << std::to_string(data) << ",";
                actual_column_cntr++;
                actual_file_id = 1;

            case 4:  // Event-based data group (Random bit) to outFile1
                outFile1 << std::to_string(data) << ",";
                actual_column_cntr++;
                actual_file_id = 1;

            case 5:  // Event-based data group (Timestamps) to outFile1
                outFile1 << std::to_string(data) << ",";
                actual_column_cntr++;
                actual_file_id = 1;

            case 6:  // Regular reporting group (Coincidence patterns) to outFile2
                outFile2 << std::to_string(data) << ",";
                actual_column_cntr++;
                actual_file_id = 2;

            // case 7:  // Regular reporting 2 (Available)
            // case 8:  // Regular reporting 3 (Available)
            // case 9:  // Regular reporting 4 (Available)
            // case 10: // Regular reporting 5 (Available) 
            // case 11: // Regular reporting 6 (Available) 
            // case 12: // Regular reporting 7 (Available) 
            // case 13: // Regular reporting 8 (Available) 
        }
    }

    outFile1.close();
    outFile2.close();
    return {actual_column_cntr, actual_file_id};
}



void guiBackendObj::printEntireTransaction(std::bitset<32> uns32b)
{
    printf("%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d\n",\
    int(uns32b[31]),\
    int(uns32b[30]),\
    int(uns32b[29]),\
    int(uns32b[28]),\
    int(uns32b[27]),\
    int(uns32b[26]),\
    int(uns32b[25]),\
    int(uns32b[24]),\
    int(uns32b[23]),\
    int(uns32b[22]),\
    int(uns32b[21]),\
    int(uns32b[20]),\
    int(uns32b[19]),\
    int(uns32b[18]),\
    int(uns32b[17]),\
    int(uns32b[16]),\
    int(uns32b[15]),\
    int(uns32b[14]),\
    int(uns32b[13]),\
    int(uns32b[12]),\
    int(uns32b[11]),\
    int(uns32b[10]),\
    int(uns32b[9]),\
    int(uns32b[8]),\
    int(uns32b[7]),\
    int(uns32b[6]),\
    int(uns32b[5]),\
    int(uns32b[4]),\
    int(uns32b[3]),\
    int(uns32b[2]),\
    int(uns32b[1]),\
    int(uns32b[0])\
    );
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
                        printf("Block Size Not Supported\n");
                        break;
                    case okCFrontPanel::UnsupportedFeature:
                        printf("Unsupported Feature\n");
                        break;
                    default:
                        // printf("Transfer Failed with Error: %ld\n", value_tx_or_rx);
                        break;
                }

                if (okDevice->IsOpen() == false) {
                    printf("Device disconnected\n");
                    exit(-1);
                }

                // Unsuccessful data transfer
                return true;
            }
        }
    }

    // Successful data transfer, append NULL as without error
    // printf("dataBufferRead_thread1 Returned Correctly\n");
    return false;
}



// This thread reads processed_data from the FPGA
int guiBackendObj::thread1_acquire()
{

    printf("thread1_acquire: Entered\n");
    bool thread1_fpga_error = false;


    // Establish connection with the device given by okBoardOnSerial (if "", then gets one device)
    okDevicePtr = allOkDevices.Open(okBoardOnSerial);
    okCFrontPanel* const okDevice = okDevicePtr.get();
    if (!okDevice) {
        if (!allOkDevices.GetCount()) {
            printf("No connected devices detected.\n");
        } else {
            // Device(s) detected, but not with the specified okBoardOnSerial.
            printf("Device \"%s\" could not be opened.\n", okBoardOnSerial);
        }
        thread1_fpga_error = true;
    }


    // Program the FPGA
    if (false == initializeFPGA(okDevice, bitfile)) {
        printf("FPGA could not be initialized with the given bitfile.\n");
        thread1_fpga_error = true;
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


    // Acquire processed_data
    for(;;){

        std::unique_lock<std::mutex> lock(mtx);

        // release the lock and wait until ready_new_value has been consumed
        cv.wait(lock, [this]{ return !ready_new_value; });
        {
            if (!thread1_fpga_error) {
                ++data_transmissions_cnt;

                // Read per 1x TransferSize blocks of processed_data
                thread1_fpga_error = Read(dataBufferRead, okDevice, 1);
            }

            // Update OK/NOK status
            fpga_error = thread1_fpga_error;

            // Handshake
            ready_new_value = true;
        }

        // Wake up thread2_process_data
        cv.notify_one();

        // Condition to stop the infinite loop
        if (data_transmissions_cnt == data_transmissions_cnt_max || thread1_fpga_error == true){
            printf("thread1_acquire: Break\n");
            break;
        }
    }


    // Deallocate memory
    printf("thread1_acquire: Deallocate\n");
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

    printf("thread2_process_data: Entered\n");
    bool thread2_fpga_error = false;


    
    using ms = std::chrono::milliseconds;

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
        if (data_transmissions_cnt == data_transmissions_cnt_max || thread2_fpga_error == true){
            printf("thread2_process_data: Break\n");
            break;
        }

        // Process data, break on error
        thread2_fpga_error = fpga_error;

        if (!thread2_fpga_error) {


            std::copy(&dataBufferRead[0], &dataBufferRead[0] + m_u32SegmentSize, &thread2_dataBufferRead[0]);

            // Wake up thread1_acquire
            ready_new_value = false;
            cv.notify_one();

            col_and_file_id = processReceivedData(col_and_file_id, thread2_dataBufferRead, m_u32TransferSize);

            // if (arr_data_processing_output[0] == 1){
            //     thread2_fpga_error = true;
            // }
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
    guiBackendObj f;

    std::thread t1(&guiBackendObj::thread1_acquire, &f);
    std::thread t2(&guiBackendObj::thread2_process_data, &f);

    t1.join();
    t2.join();
    return 0;
}