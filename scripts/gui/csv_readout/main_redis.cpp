#include <iostream>
#include <string>
#include <thread>
#include <mutex>
#include <condition_variable>

#include <sw/redis++/redis++.h>
#include <stdlib.h>
#include <unordered_set>
using namespace sw::redis;

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
#include "./lib/guiBackendObj_redis.h"



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


void guiBackendObj::processReceivedData(Redis *redis, unsigned char* pucBuffer, UINT32 bufferSize, int time_sec_last, int* arr_data_processing_output)
{

    using Attrs = std::vector<std::pair<std::string, std::string>>;
    using namespace sw::redis;
    // auto& redis_cli = redis;
    // auto& redis_addr
    // auto redis = *redis;

    int processed_data = 0;
    int time_sec = time_sec_last;
    UINT32 i;
    UINT32* pu32Buffer = (UINT32*)pucBuffer;
    std::bitset<32> uns32b;

    // Parse the message
    std::bitset<4> command;         // 0, 1, 2, 3

    // If command = 4
    std::bitset<28> successes_in_one_sec;       // 4, 5

    // If command = 1
    std::bitset<2> modulo_q4;       // 4, 5
    std::bitset<2> modulo_q3;       // 6, 7
    std::bitset<2> modulo_q2;       // 8, 9
    std::bitset<2> modulo_q1;       // 10, 11

    std::bitset<1> random_q1;       // 12
    std::bitset<1> random_q2;       // 13
    std::bitset<1> random_q3;       // 14
    std::bitset<1> random_q4;       // 15

    std::bitset<2> alpha_q1;        // 16, 17
    std::bitset<2> alpha_q2;        // 18, 19
    std::bitset<2> alpha_q3;        // 20, 21
    std::bitset<2> alpha_q4;        // 22, 23

    std::bitset<2> q4;              // 24, 25
    std::bitset<2> q3;              // 26, 27
    std::bitset<2> q2;              // 28, 29
    std::bitset<2> q1;              // 30, 31

    int write_max_clusters_per_process = 1;
    int written_clusters_per_process = 0;


    bool cmd_1 = false;
    bool cmd_2 = false;
    int cnt_appended_values = 0;
    bool cmd_3 = false;

    unsigned long* arr_data_write_to_file = new unsigned long[23];

    // command = 2
    std::bitset<28> time;           // 4 to 31

    outFile.open("outputFile.csv", std::ofstream::app);


    // printReceivedData(pucBuffer, bufferSize);

    // Data Processing: Divide by number of bytes in the total number of bits
    for (i=0; i<bufferSize/4; i++) {

        // If data nonzero
        if (pu32Buffer[i])
            uns32b = std::bitset<32>(pu32Buffer[i]);
            // printRxTransaction(uns32b);


            // Parse the received command
            for(int j = 0; j < 4; j++){
                command.set(j, uns32b[j]);
            }
            UINT32 command_parsed = (UINT32)(command.to_ulong());


            // Execute the command
            switch (command_parsed){

                // command = 1: Get & Parse Data + Append to a file
                case 1:
                    if (written_clusters_per_process < write_max_clusters_per_process
                        && cmd_1 == false)
                    {
                        q1.set(1, uns32b[31]);              // 30, 31
                        q1.set(0, uns32b[30]);              // 30, 31
                        q2.set(1, uns32b[29]);              // 28, 29
                        q2.set(0, uns32b[28]);              // 28, 29
                        q3.set(1, uns32b[27]);              // 26, 27
                        q3.set(0, uns32b[26]);              // 26, 27
                        q4.set(1, uns32b[25]);              // 24, 25
                        q4.set(0, uns32b[24]);              // 24, 25

                        alpha_q1.set(1, uns32b[23]);        // 22, 23
                        alpha_q1.set(0, uns32b[22]);        // 22, 23
                        alpha_q2.set(1, uns32b[21]);        // 20, 21
                        alpha_q2.set(0, uns32b[20]);        // 20, 21
                        alpha_q3.set(1, uns32b[19]);        // 18, 19
                        alpha_q3.set(0, uns32b[18]);        // 18, 19
                        alpha_q4.set(1, uns32b[17]);        // 16, 17
                        alpha_q4.set(0, uns32b[16]);        // 16, 17

                        // random_q1;       // 15
                        // random_q2;       // 14
                        // random_q3;       // 13
                        // random_q4;       // 12

                        modulo_q1.set(1, uns32b[11]);      // 10, 11
                        modulo_q1.set(0, uns32b[10]);      // 10, 11
                        modulo_q2.set(1, uns32b[9]);       // 8, 9
                        modulo_q2.set(0, uns32b[8]);       // 8, 9
                        modulo_q3.set(1, uns32b[7]);       // 6, 7
                        modulo_q3.set(0, uns32b[6]);       // 6, 7
                        modulo_q4.set(1, uns32b[5]);       // 4, 5
                        modulo_q4.set(0, uns32b[4]);       // 4, 5


                        arr_data_write_to_file[0] = q1.to_ulong();
                        arr_data_write_to_file[1] = q2.to_ulong();
                        arr_data_write_to_file[2] = q3.to_ulong();
                        arr_data_write_to_file[3] = q4.to_ulong();

                        arr_data_write_to_file[4] = alpha_q1.to_ulong();
                        arr_data_write_to_file[5] = alpha_q2.to_ulong();
                        arr_data_write_to_file[6] = alpha_q3.to_ulong();
                        arr_data_write_to_file[7] = alpha_q4.to_ulong();

                        arr_data_write_to_file[8] = uns32b[15];
                        arr_data_write_to_file[9] = uns32b[14];
                        arr_data_write_to_file[10] = uns32b[13];
                        arr_data_write_to_file[11] = uns32b[12];

                        arr_data_write_to_file[12] = modulo_q1.to_ulong();
                        arr_data_write_to_file[13] = modulo_q2.to_ulong();
                        arr_data_write_to_file[14] = modulo_q3.to_ulong();
                        arr_data_write_to_file[15] = modulo_q4.to_ulong();


                        // outFile << std::to_string((int)q1.to_ulong()) << ",";
                        // outFile << std::to_string((int)q2.to_ulong()) << ",";
                        // outFile << std::to_string((int)q3.to_ulong()) << ",";
                        // outFile << std::to_string((int)q4.to_ulong()) << ",";

                        // outFile << std::to_string((int)alpha_q1.to_ulong()) << ",";
                        // outFile << std::to_string((int)alpha_q2.to_ulong()) << ",";
                        // outFile << std::to_string((int)alpha_q3.to_ulong()) << ",";
                        // outFile << std::to_string((int)alpha_q4.to_ulong()) << ",";

                        // outFile << std::to_string(uns32b[15]) << ",";
                        // outFile << std::to_string(uns32b[14]) << ",";
                        // outFile << std::to_string(uns32b[13]) << ",";
                        // outFile << std::to_string(uns32b[12]) << ",";

                        // outFile << std::to_string((int)modulo_q1.to_ulong()) << ",";
                        // outFile << std::to_string((int)modulo_q2.to_ulong()) << ",";
                        // outFile << std::to_string((int)modulo_q3.to_ulong()) << ",";
                        // outFile << std::to_string((int)modulo_q4.to_ulong()) << ",";
                        // cluster_written = true;

                        cmd_1 = true;
                    }

                    break;



                // command = 2: Get Time + Append to a file
                case 2:
                    if (written_clusters_per_process < write_max_clusters_per_process 
                        && cmd_1 == true
                        && cnt_appended_values < 7
                        )
                    {
                        for(int j = 4; j < 32; j++) {
                            time.set(j-4, uns32b[j]);
                        }

                        cnt_appended_values++;
                        arr_data_write_to_file[15+cnt_appended_values] = time.to_ulong();

                        if (cnt_appended_values == 7)
                            cmd_2 = true;


                        // outFile << std::to_string((int)time.to_ulong()) << ",";
                    } else {
                        // Start over
                        cmd_1 = false;
                        cmd_2 = false;
                        cnt_appended_values = 0;
                    }

                    break;



                // command = 3: Get Time + Append to a file + End line
                case 3:
                    if (written_clusters_per_process < write_max_clusters_per_process
                        && cmd_1 == true 
                        && cmd_2 == true){
                        for(int j = 4; j < 32; j++) {
                            time.set(j-4, uns32b[j]);
                        }
                        outFile << arr_data_write_to_file[0] << "," 
                                << arr_data_write_to_file[1] << ","
                                << arr_data_write_to_file[2] << ","
                                << arr_data_write_to_file[3] << ","
                                << arr_data_write_to_file[4] << ","
                                << arr_data_write_to_file[5] << ","
                                << arr_data_write_to_file[6] << ","
                                << arr_data_write_to_file[7] << ","
                                << arr_data_write_to_file[8] << ","
                                << arr_data_write_to_file[9] << ","
                                << arr_data_write_to_file[10] << ","
                                << arr_data_write_to_file[11] << ","
                                << arr_data_write_to_file[12] << ","
                                << arr_data_write_to_file[13] << ","
                                << arr_data_write_to_file[14] << ","
                                << arr_data_write_to_file[15] << ","
                                // << arr_data_write_to_file[16] << ","
                                // << arr_data_write_to_file[17] << ","
                                // << arr_data_write_to_file[18] << ","
                                // << arr_data_write_to_file[19] << ","
                                // << arr_data_write_to_file[20] << ","
                                // << arr_data_write_to_file[21] << ","
                                // << arr_data_write_to_file[22] << ","
                                // << time.to_ulong() << std::endl;

                                // << (unsigned long long)((unsigned long long)arr_data_write_to_file[16] + (unsigned long long)(2^29)*(unsigned long long)arr_data_write_to_file[17]) << ","
                                // << (unsigned long long)((unsigned long long)arr_data_write_to_file[18] + (unsigned long long)(2^29)*(unsigned long long)arr_data_write_to_file[19]) << ","
                                // << (unsigned long long)((unsigned long long)arr_data_write_to_file[20] + (unsigned long long)(2^29)*(unsigned long long)arr_data_write_to_file[21]) << ","
                                // << (unsigned long long)((unsigned long long)arr_data_write_to_file[22] + (unsigned long long)(2^29)*(unsigned long long)time.to_ulong()) << std::endl;

                                << (unsigned long long)(arr_data_write_to_file[16] + (unsigned long long)pow(2, 28)*arr_data_write_to_file[17]) << ","
                                << (unsigned long long)(arr_data_write_to_file[18] + (unsigned long long)pow(2, 28)*arr_data_write_to_file[19]) << ","
                                << (unsigned long long)(arr_data_write_to_file[20] + (unsigned long long)pow(2, 28)*arr_data_write_to_file[21]) << ","
                                << (unsigned long long)(arr_data_write_to_file[22] + (unsigned long long)pow(2, 28)*time.to_ulong()) << std::endl;

                                // << arr_data_write_to_file[18] << ","
                                // << arr_data_write_to_file[19] << ","
                                // << arr_data_write_to_file[20] << ","
                                // << arr_data_write_to_file[21] << ","
                                // << arr_data_write_to_file[22] << ","
                                // << (int)time.to_ulong() << std::endl;

                        written_clusters_per_process++;
                        arr_data_processing_output[2] = written_clusters_per_process;

                        // Start over
                        cmd_1 = false;
                        cmd_2 = false;
                        cnt_appended_values = 0;
                    } else {
                        // Start over
                        cmd_1 = false;
                        cmd_2 = false;
                        cnt_appended_values = 0;
                    }

                    break;



                // command = 4: Print the count + Send to Redis
                case 4:
                    // printRxTransaction(uns32b);
                    time_sec++;
                    for(int j = 4; j < 32; j++) {
                        successes_in_one_sec.set(j-4, uns32b[j]);
                    }
                    int successes_in_one_sec_parsed = (int)(successes_in_one_sec.to_ulong());

                    printf("Second: %d, Counts: %d\n", time_sec, successes_in_one_sec_parsed);

                    // Send to Redis
                    Attrs attrs = {
                        {"dataKey1", std::to_string(successes_in_one_sec_parsed)},
                        {"dataKey2", std::to_string(time_sec)}
                    };

                    // Add an item to the Redis stream. This method returns the auto generated id.
                    redis->xadd("myStreamKey", "*", attrs.begin(), attrs.end());

                    break;
            }
    }

    // printf("time_sec: returning %d\n", time_sec);
    outFile.close();
    delete [] arr_data_write_to_file;
    arr_data_processing_output[0] = 0; // Return No Error
    arr_data_processing_output[1] = time_sec; // Return OK
    // return;
}



void guiBackendObj::printRxTransaction(std::bitset<32> uns32b)
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
        // printf("thread1_acquire: waited\n");
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
        // printf("thread1_acquire: processed\n");

        // Wake up thread2_send
        cv.notify_one();
        // printf("thread1_acquire: notified\n");

        // Condition to stop the infinite loop
        if (data_transmissions_cnt == data_transmissions_cnt_max || thread1_fpga_error == true){
            printf("thread1_acquire: Break\n");
            break;
        }
    }


    // Deallocate memory
    printf("thread1_acquire: Deallocate\n");
    #if defined(__QNX__)
        // usbd_free(pValid);
        usbd_free(dataBufferRead);
    #else
        // delete [] pValid;
        delete [] dataBufferRead;
    #endif

    return(0);
}



// This thread sends processed_data to redis server
void guiBackendObj::thread2_send()
{

    printf("thread2_send: Entered\n");
    // int int_data_to_redis;
    // int time_ns = 0;
    // int time_step_ns = 5;
    bool thread2_fpga_error = false;
    int time_sec_last = 0;
    int time_sec_new = 0;


    try {
        // auto redis = Redis("tcp://127.0.0.1");
        // Redis redis = Redis("tcp://127.0.0.1");

        // sw::redis::Redis *redis = new sw::redis::Redis(config)
        // auto& redis_addr = redis;

        Redis* redis = new Redis("tcp://127.0.0.1");

        using Attrs = std::vector<std::pair<std::string, std::string>>;
        using ms = std::chrono::milliseconds;

        // Delete previous content in the Redis server and start over
        redis->xtrim("myStreamKey", 0, false);

        // [Status 1 OK/0 NOK, time_sec_new, written_clusters_per_process, Out3]
        int* arr_data_processing_output = new int[4];
        // arr_data_processing_output = 0;
        // arr_data_processing_output[0] = 0;

        // Data to be transferred from thread 1 to thread 2
        unsigned char* thread2_dataBufferRead = new unsigned char[m_u32SegmentSize];

        for(;;){

            // Add some delay to get new values
            // std::this_thread::sleep_for(ms(10));

            std::unique_lock<std::mutex> lock(mtx);

            // Release the lock and wait until ready_new_value has been produced
            cv.wait(lock, [this]{ return ready_new_value; });
            // printf("thread2_send: waited\n");

            // Condition to stop the infinite loop
            if (data_transmissions_cnt == data_transmissions_cnt_max || thread2_fpga_error == true){
                printf("thread2_send: Break\n");
                delete [] redis;
                delete [] arr_data_processing_output;
                break;
            }

            // Set stream item: processed_data and processed_data keys to be transferred to Redis server
            thread2_fpga_error = fpga_error;

            if (!thread2_fpga_error) {


                std::copy(&dataBufferRead[0], &dataBufferRead[0] + m_u32SegmentSize, &thread2_dataBufferRead[0]);

                // Wake up thread1_acquire
                ready_new_value = false;
                cv.notify_one();
                // printf("thread2_send: notified\n");

                processReceivedData(redis, thread2_dataBufferRead, m_u32TransferSize, time_sec_last, arr_data_processing_output);
                time_sec_new = arr_data_processing_output[1];

                if (arr_data_processing_output[0] == 1){
                    thread2_fpga_error = true;
                }

                if (time_sec_new < time_sec_last){
                    thread2_fpga_error = true;
                }

                if (time_sec_last != 0 && time_sec_new < time_sec_last) {
                    thread2_fpga_error = true;
                }

                time_sec_last = time_sec_new;

                // // Handshake
                // ready_new_value = false;
            }
            // printf("thread2_send: processed\n");

            // // Wake up thread1_acquire
            // cv.notify_one();
            // printf("thread2_send: notified\n");

            // // Condition to stop the infinite loop
            // if (data_transmissions_cnt == data_transmissions_cnt_max || thread2_fpga_error == true){
            //     printf("thread2_send: Break\n");
            //     break;
            // }

        }
    } catch (const Error &e) {
        // Redis error message
        bool thread2_fpga_error = true;
        std::cerr << e.what() << std::endl;
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

    // // guiBackendObj - Method1
    // double* linked_ObjectMethod1(guiBackendObj* ptrLinkedObject, int& print_numbers_cnt) {
    //     return ptrLinkedObject->linked_ObjectMethod1(print_numbers_cnt);
    // }

}


int main(int argc, char** argv)
{
    guiBackendObj f;

    std::thread t1(&guiBackendObj::thread1_acquire, &f);
    std::thread t2(&guiBackendObj::thread2_send, &f);

    t1.join();
    t2.join();
    return 0;
}