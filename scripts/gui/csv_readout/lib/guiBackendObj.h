#include <stdlib.h>

#include "okFrontPanel.h"

#include <mutex>
#include <condition_variable>
#include <tuple>

typedef unsigned int UINT32;

class guiBackendObj {
    // Shared variables among threads
    unsigned char* dataBufferRead;
    bool thr1_to_thr2_stop_request;

    // Thread Lock and Condition Variable for sharing data among threads
    std::mutex mtx;
    std::condition_variable cv;

    // Flag when a new value is ready
    bool ready_new_value;

    // Readout variables
    int last_column_cntr = 0;
    int actual_file_id = 0;
    int actual_column_cntr_csv1 = 0;
    int actual_column_cntr_csv2 = 0;
    int actual_column_cntr_csv3 = 0;
    bool actual_file_csv1 = 0;
    bool actual_file_csv2 = 0;
    bool actual_file_csv3 = 0;

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

    // Command Line Arguments (initialized in constructor)
    bool program_only;
    int qubits_count;
    double float_run_time_seconds;
    char* bitfile_name;

    OpalKelly::FrontPanelDevices allOkDevices;
    OpalKelly::FrontPanelPtr okDevicePtr;

    // Declaration of output CSV Files
    std::ofstream outFile1;
    std::ofstream outFile2;
    std::ofstream outFile3;

    // Declaration of readout bucket bins for data and cmds
    UINT32 command;
    UINT32 data;
    std::bitset<32> uns32b;
    std::bitset<28> uns28b_data;
    std::bitset<4> uns4b_cmd;

    // Declaration of iterators
    UINT32 i_iter;
    UINT32 j_iter;

private:

public:

    // Constructor
    guiBackendObj(
        bool program_only=false,
        int qubits_count=4, 
        double float_run_time_seconds=5, 
        char* bitfile_name="bitfile.bit"
    ) : ready_new_value{false} {

        std::cout << "guiBackendObj: Constructor started" << std::endl;

        // Command Line Arguments
        this->program_only = program_only;
        this->qubits_count = qubits_count;
        this->float_run_time_seconds = float_run_time_seconds;
        this->bitfile_name = bitfile_name;

        // Open the device, optionally selecting the one with the specified okBoardOnSerial.
        // "" = do not check for serial port. Pick the one device connected to the PC.
        okBoardOnSerial = "";

        // Define transfer size
        // (1048576 BytesTotal / 4 BytesPerTransaction = 262144 TransactionsTotal)
        //  1048576 = 1 * 1024 * 1024 = 1x TransferSize

        // m_u32BlockSize = 16; // Before
        m_u32BlockSize = 64; // After

        // m_u32SegmentSize = 64 * m_u32BlockSize; original
        
        m_u32SegmentSize = 32 * m_u32BlockSize;
        m_u32TransferSize = 1 * m_u32SegmentSize;  // DO NOT CHANGE
        m_u32TransferSizeCount = 1; // DO NOT CHANGE


        // Clear content of the output files and add headers
        // Header CSV file 1
        outFile1.open("outputFile1.csv", std::ofstream::out | std::ofstream::trunc);
        for (int i = 1; i <= qubits_count; i++){
            outFile1 << "photon_q" << i << ",";
        }
        outFile1 << ",";

        for (int i = 1; i <= qubits_count; i++){
            outFile1 << "alpha_q" << i << ",";
        }
        outFile1 << ",";

        for (int i = 1; i <= qubits_count; i++){
            outFile1 << "mod_q" << i << ",";
        }
        outFile1 << ",";

        for (int i = 1; i <= qubits_count; i++){
            outFile1 << "rand_q" << i << ",";
        }
        outFile1 << ",";

        outFile1 << "timestamp_q1_ovflw" << ","; // This is to correct time on overflow detection
        for (int i = 1; i <= qubits_count; i++){
            outFile1 << "timestamp_q" << i << ",";
        }
        outFile1 << ",@time" << std::endl;
        // outFile1.close();


        // Header CSV file 2
        outFile2.open("outputFile2.csv", std::ofstream::out | std::ofstream::trunc);
        for (int i = 0; i < pow(2, qubits_count); i++){
            // Bitset width must be known at compile time
            if (qubits_count == 1) {outFile2 << std::bitset<1>(i) << ",";}
            else if (qubits_count == 2) {outFile2 << std::bitset<2>(i) << ",";}
            else if (qubits_count == 3) {outFile2 << std::bitset<3>(i) << ",";}
            else if (qubits_count == 4) {outFile2 << std::bitset<4>(i) << ",";}
            else if (qubits_count == 5) {outFile2 << std::bitset<5>(i) << ",";}
            else if (qubits_count == 6) {outFile2 << std::bitset<6>(i) << ",";}
        }
        outFile2 << ",@time" << std::endl;
        // outFile2.close();


        // Header CSV file 3
        outFile3.open("outputFile3.csv", std::ofstream::out | std::ofstream::trunc);
        for (int i = 1; i <= qubits_count*2; i++){
            outFile3 << "chann_" << i << ",";
        }
        outFile3 << ",";

        for (int i = 2; i <= qubits_count; i++){
            outFile3 << "loss_q" << i << ",";
        }
        outFile3 << ",@time" << std::endl;
        // outFile3.close();

    }

    // Destructor
    virtual ~guiBackendObj()
    {
        // Close all files
        outFile1.close();
        outFile2.close();
        outFile3.close();
        std::cout << "guiBackendObj: Destructing" << std::endl;
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