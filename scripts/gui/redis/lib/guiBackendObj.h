#include <stdlib.h>

#include "okFrontPanel.h"

#include <mutex>
#include <condition_variable>

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

    std::ofstream outFile;

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

        // Clear content of the output file file
        outFile.open("outputFile.csv", std::ofstream::out | std::ofstream::trunc);
        // outFile << "q1,q2,q3,q4,alpha_q1,alpha_q2,alpha_q3,alpha_q4,random_q1,random_q2,random_q3,random_q4,modulo_q1,modulo_q2,modulo_q3,modulo_q4,time_q1,time_q1_overflows,time_q2,time_q2_overflows,time_q3,time_q3_overflows,time_q4,time_q4_overflows" << std::endl;
        outFile << "q1,q2,q3,q4,alpha_q1,alpha_q2,alpha_q3,alpha_q4,random_q1,random_q2,random_q3,random_q4,modulo_q1,modulo_q2,modulo_q3,modulo_q4,time_q1,time_q1_overflows,time_q2 (10 ns),time_q3 (10 ns),time_q4 (10ns)" << std::endl;
        outFile.close();
    }

    // Destructor
    virtual ~guiBackendObj() 
    {
        outFile.close();
        printf("guiBackendObj: Destructing\n");
    }

    // Configure the FPGA with the given configuration bitfile.
    bool initializeFPGA(okCFrontPanel* okDevice, char* bitfile);

    // ...
    void processReceivedData(Redis *redis, unsigned char* pucBuffer, UINT32 bufferSize, int time_sec_last, int* arr_data_processing);

    // ...
    void printRxTransaction(std::bitset<32> uns32b);

    // Performs read only operation form the FPGA
    bool Read(unsigned char* pBufferRead_thread1, okCFrontPanel* okDevice, UINT32 m_u32TransferSizeCount);

    // This thread reads data from the FPGA
    int thread1_acquire();

    // This thread sends data to redis server
    void thread2_send();
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