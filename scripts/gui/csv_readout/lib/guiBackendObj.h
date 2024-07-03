#include <stdlib.h>

#include "okFrontPanel.h"

#include <mutex>
#include <condition_variable>
#include <tuple>

typedef unsigned int UINT32;

class guiBackendObj {
    // Stop data transfer if...
    int data_transmissions_cnt_max; // 1 window of data in python gui is 100 (with time_step_ns = 5)

    // Shared variables among threads
    int data_transmissions_cnt;
    unsigned char* dataBufferRead;
    bool fpga_error;

    // Thread Lock and Condition Variable for sharing data among threads
    std::mutex mtx;
    std::condition_variable cv;

    // Flag when a new value is ready
    bool ready_new_value;

    // OK API Variables
    okTDeviceInfo  m_devInfo;
    UINT32         m_u32BlockSize;
    UINT32         m_u32SegmentSize;
    UINT32         m_u32TransferSize;
    UINT32         m_u32TransferSizeCount;

    // Data transfer and R/W rate
    // UINT32         m_u32FixedPattern;
    // UINT32         m_u32ThrottleIn;
    // UINT32         m_u32ThrottleOut;
    // int            m_ePattern;

    // Board ID and initialization
    const char* okBoardOnSerial;
    char* bitfile;

    OpalKelly::FrontPanelDevices allOkDevices;
    OpalKelly::FrontPanelPtr okDevicePtr;

    std::ofstream outFile1;
    std::ofstream outFile2;

public:

    // Constructor
    guiBackendObj() : data_transmissions_cnt{0}, ready_new_value{false} 
    {
        printf("guiBackendObj: Constructing\n");

        // Open the device, optionally selecting the one with the specified okBoardOnSerial.
        okBoardOnSerial = "";
        bitfile = (char*)"bitfile.bit";

        // Declare default sizes for data transmission (Read)
        data_transmissions_cnt_max = 10000;

        // (1048576 BytesTotal / 4 BytesPerTransaction = 262144 TransactionsTotal)
        //  1048576 = 1 * 1024 * 1024 = 1x TransferSize
        m_u32BlockSize = 16;
        // m_u32SegmentSize = 64 * m_u32BlockSize;
        m_u32SegmentSize = 1 * m_u32BlockSize;
        m_u32TransferSize = 1 * m_u32SegmentSize;  // DO NOT CHANGE
        m_u32TransferSizeCount = 1; // DO NOT CHANGE

        // Clear content of the output files and add headers
        outFile1.open("outputFile1.csv", std::ofstream::out | std::ofstream::trunc);
        outFile1 << "photons H/V 1-to-X,,alpha 1-to-X,,modulo 1-to-X,,random 1-to-X,,timestamp 1-to-X" << std::endl;
        outFile1.close();

        outFile2.open("outputFile2.csv", std::ofstream::out | std::ofstream::trunc);
        outFile2 << "combinations 1-to-QUBITS**2-1," << std::endl;
        outFile2.close();
    }

    // Destructor
    virtual ~guiBackendObj() 
    {
        outFile1.close();
        outFile2.close();
        printf("guiBackendObj: Destructing\n");
    }

    // Configure the FPGA with the given configuration bitfile.
    bool initializeFPGA(okCFrontPanel* okDevice, char* bitfile);

    // ...
    std::tuple<int, int> processReceivedData(std::tuple<int, int> col_and_file_id, unsigned char* pucBuffer, UINT32 bufferSize);

    // ...
    void printEntireTransaction(std::bitset<32> uns32b);

    // Performs read only operation form the FPGA
    bool Read(unsigned char* pBufferRead_thread1, okCFrontPanel* okDevice, UINT32 m_u32TransferSizeCount);

    // This thread reads data from the FPGA
    int thread1_acquire();

    // This thread processes data from the FPGA
    void thread2_process_data();
};



// Linkage with other languages: functions to be linked - prototypes
extern "C" {
    // guiBackendObj - Constructor
    guiBackendObj* linked_ObjectConstructor();

    // guiBackendObj - Destructor
    void linked_ObjectDestructor(guiBackendObj* pointerObj);

    // guiBackendObj - Method1
    // double* linked_ObjectMethod1(guiBackendObj* ptrLinkedObject, int& print_numbers_cnt);
}