    -- top.vhd: Architecture of the FPGA part of the G-Flow protocol

    library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;
    use ieee.math_real.all;

    library UNISIM;
    use UNISIM.VComponents.all;

    library lib_src;
    use lib_src.types_pack.all;
    use lib_src.generics.all;

    entity top_gflow is
        generic(
            -- Gflow generics
            RST_VAL : std_logic := '1';

            -- Integer parameters from Makefile
            INT_QUBITS_CNT                  : integer := INT_QUBITS_CNT;
            INT_EMULATE_INPUTS              : integer := INT_EMULATE_INPUTS;
            INT_WHOLE_PHOTON_1H_DELAY_NS    : integer := INT_WHOLE_PHOTON_1H_DELAY_NS;
            INT_DECIM_PHOTON_1H_DELAY_NS    : integer := INT_DECIM_PHOTON_1H_DELAY_NS;
            INT_WHOLE_PHOTON_1V_DELAY_NS    : integer := INT_WHOLE_PHOTON_1V_DELAY_NS;
            INT_DECIM_PHOTON_1V_DELAY_NS    : integer := INT_DECIM_PHOTON_1V_DELAY_NS;
            INT_WHOLE_PHOTON_2H_DELAY_NS    : integer := INT_WHOLE_PHOTON_2H_DELAY_NS;
            INT_DECIM_PHOTON_2H_DELAY_NS    : integer := INT_DECIM_PHOTON_2H_DELAY_NS;
            INT_WHOLE_PHOTON_2V_DELAY_NS    : integer := INT_WHOLE_PHOTON_2V_DELAY_NS;
            INT_DECIM_PHOTON_2V_DELAY_NS    : integer := INT_DECIM_PHOTON_2V_DELAY_NS;
            INT_WHOLE_PHOTON_3H_DELAY_NS    : integer := INT_WHOLE_PHOTON_3H_DELAY_NS;
            INT_DECIM_PHOTON_3H_DELAY_NS    : integer := INT_DECIM_PHOTON_3H_DELAY_NS;
            INT_WHOLE_PHOTON_3V_DELAY_NS    : integer := INT_WHOLE_PHOTON_3V_DELAY_NS;
            INT_DECIM_PHOTON_3V_DELAY_NS    : integer := INT_DECIM_PHOTON_3V_DELAY_NS;
            INT_WHOLE_PHOTON_4H_DELAY_NS    : integer := INT_WHOLE_PHOTON_4H_DELAY_NS;
            INT_DECIM_PHOTON_4H_DELAY_NS    : integer := INT_DECIM_PHOTON_4H_DELAY_NS;
            INT_WHOLE_PHOTON_4V_DELAY_NS    : integer := INT_WHOLE_PHOTON_4V_DELAY_NS;
            INT_DECIM_PHOTON_4V_DELAY_NS    : integer := INT_DECIM_PHOTON_4V_DELAY_NS;
            INT_WHOLE_PHOTON_5H_DELAY_NS    : integer := INT_WHOLE_PHOTON_5H_DELAY_NS;
            INT_DECIM_PHOTON_5H_DELAY_NS    : integer := INT_DECIM_PHOTON_5H_DELAY_NS;
            INT_WHOLE_PHOTON_5V_DELAY_NS    : integer := INT_WHOLE_PHOTON_5V_DELAY_NS;
            INT_DECIM_PHOTON_5V_DELAY_NS    : integer := INT_DECIM_PHOTON_5V_DELAY_NS;
            INT_WHOLE_PHOTON_6H_DELAY_NS    : integer := INT_WHOLE_PHOTON_6H_DELAY_NS;
            INT_DECIM_PHOTON_6H_DELAY_NS    : integer := INT_DECIM_PHOTON_6H_DELAY_NS;
            INT_WHOLE_PHOTON_6V_DELAY_NS    : integer := INT_WHOLE_PHOTON_6V_DELAY_NS;
            INT_DECIM_PHOTON_6V_DELAY_NS    : integer := INT_DECIM_PHOTON_6V_DELAY_NS;
            INT_DISCARD_QUBITS_TIME_NS      : integer := INT_DISCARD_QUBITS_TIME_NS;           -- Stop feedforward for a given time
            INT_CTRL_PULSE_HIGH_DURATION_NS : integer := INT_CTRL_PULSE_HIGH_DURATION_NS; -- PCD Control Pulse Design & Delay
            INT_CTRL_PULSE_DEAD_DURATION_NS : integer := INT_CTRL_PULSE_DEAD_DURATION_NS; -- PCD Control Pulse Design & Delay
            INT_CTRL_PULSE_EXTRA_DELAY_NS   : integer := INT_CTRL_PULSE_EXTRA_DELAY_NS;   -- PCD Control Pulse Design & Delay

            WRITE_ON_VALID : boolean := true

        );
        port (

            -- External 200MHz oscillator
            sys_clk_p : in std_logic;
            sys_clk_n : in std_logic;

            -- Readout Endpoint Signals
            readout_clk        : in std_logic;
            readout_data_ready : out std_logic;
            readout_data_valid : out std_logic;
            readout_enable     : in std_logic;
            readout_data_32b   : out std_logic_vector(31 downto 0);

            -- Debug LEDs
            led : out std_logic_vector(3 downto 0);

            -- Inputs from SPCM
            input_pads : in std_logic_vector(2*INT_QUBITS_CNT-1 downto 0);

            -- PCD Trigger + signal valid (for IO delay measuring)
            o_pcd_ctrl_pulse : out std_logic;
            o_photon_sampled : out std_logic

        );
    end top_gflow;

    architecture str of top_gflow is

        ------------------------------
        -- USB FIFO Readout Control --
        ------------------------------
        signal sl_led_fifo_full_latched : std_logic := '0';
        signal slv_fifo_wr_valid_qubit_flags : std_logic_vector(INT_QUBITS_CNT-1 downto 0) := (others => '0');
        signal sl_usb_fifo_empty : std_logic := '0';
        signal sl_usb_fifo_full : std_logic := '0';
        signal sl_usb_fifo_prog_empty : std_logic := '0';


        ----------------
        -- Components --
        ----------------
        -- SystemVerilog File (must be compiled to the same lib as glbl)
        component clock_synthesizer
        generic (
            IF_CLKIN1_DIFF : integer;
            REAL_CLKIN1_MHZ : real;
            INT_VCO_DIVIDE : integer;
            REAL_VCO_MULTIPLY : real;
            REAL_DIVIDE_OUT0 : real;
            INT_DIVIDE_OUT1  : integer;
            INT_DIVIDE_OUT2  : integer;
            INT_DIVIDE_OUT3  : integer;
            INT_DIVIDE_OUT4  : integer;
            INT_DIVIDE_OUT5  : integer;
            INT_DIVIDE_OUT6  : integer;
            REAL_DUTY_OUT0 : real;
            REAL_DUTY_OUT1 : real;
            REAL_DUTY_OUT2 : real;
            REAL_DUTY_OUT3 : real;
            REAL_DUTY_OUT4 : real;
            REAL_DUTY_OUT5 : real;
            REAL_DUTY_OUT6 : real;
            REAL_PHASE_OUT0 : real;
            REAL_PHASE_OUT1 : real;
            REAL_PHASE_OUT2 : real;
            REAL_PHASE_OUT3 : real;
            REAL_PHASE_OUT4 : real;
            REAL_PHASE_OUT5 : real;
            REAL_PHASE_OUT6 : real
        ); 
        port (
            in_clk0_p : in std_logic;
            in_clk0_n : in std_logic;
            in_fineps_clk : in std_logic;
            in_fineps_incr : in std_logic;
            in_fineps_decr : in std_logic;
            in_fineps_valid : in std_logic;
            out_fineps_dready : out std_logic;
            out_clk0 : out std_logic;
            out_clk1 : out std_logic;
            out_clk2 : out std_logic;
            out_clk3 : out std_logic;
            out_clk4 : out std_logic;
            out_clk5 : out std_logic;
            out_clk6 : out std_logic;
            locked : out std_logic
        );
        end component;

        -- Clocks
        constant REAL_BOARD_OSC_FREQ_MHZ : real := 200.0;
        constant REAL_CLK_SYS_HZ : real := 200.0e6;
        constant REAL_CLK_SAMPL_HZ : real := 300.0e6;
        constant REAL_CLK_ACQ_HZ : real := 600.0e6;

        ---------------
        -- Constants --
        ---------------
        constant INPUT_PADS_CNT : positive := INT_QUBITS_CNT*2;

        -- Noisy rising edge detection & keep input
        constant CHANNELS_CNT                     : positive := INPUT_PADS_CNT;
        constant BUFFER_DEPTH                     : positive := 3;  -- [ ] [ ] [ ]
        constant PATTERN_WIDTH                    : positive := 3;  --  0   1   1  = rising edge -> oversampling 2x
        constant BUFFER_PATTERN                   : positive := 1;
        constant CNT_ONEHOT_WIDTH                 : positive := 2;  -- 1xclk = 5 ns -> 4 x 5ns = 20 ns (does not exceed 32 ns => OK)
        constant DETECTOR_ACTIVE_PERIOD_NS        : positive := 10;
        constant DETECTOR_DEAD_PERIOD_NS          : positive := 22;
        constant TOLERANCE_KEEP_FASTER_BIT_CYCLES : natural := 0; -- # To Be Deleted
        constant IGNORE_CYCLES_AFTER_TIMEUP       : natural := 3;

        -- CDCC Logic
        constant CDCC_BYPASS : boolean := false;

        -- Reset
        -- constant RST_STROBE_CNTR_WIDTH_SYSCLK : positive := 28; -- 10*10^(-9) sec * 2^28 / 2 = 1.3 sec
        constant RST_STROBE_CNTR_WIDTH_SYSCLK : positive := 3; -- 10*10^(-9) sec * 2^28 / 2 = 1.3 sec
        constant RST_STROBE_CNTR_WIDTH_SAMPLCLK : positive := 2;

        -- Pseudorandom bit generator
        constant PRIM_POL_INT_VAL  : positive := 19;
        constant SYMBOL_WIDTH      : positive := 4;
        constant GF_SEED           : positive := 1;

        -- Gflow FSM
        -- Delay before: BUFFER_DEPTH + DELAY COMPENSATION BUFFER + REDGE clk + Output Logic Buffer
        constant CTRL_PULSE_DUR_WITH_DEADTIME_NS : natural := INT_CTRL_PULSE_HIGH_DURATION_NS + INT_CTRL_PULSE_DEAD_DURATION_NS; -- Duration of the output PCD control pulse in ns (e.g. 100 ns high, 50 ns deadtime = 150 ns)
        --                                                   (metastability flipflop) + (2x oversample) + (redge detection) + (output logic)
        constant TOTAL_STATIC_DELAY_FPGA_BEFORE : natural := 1                        + 2               + 1                 + 1; -- NOTE: synchr flipflops are calculated in fsm_gflow
        constant MAGIC_NUMBER_AFTER : natural := 5;

        -- USB3 Transaction
        signal slv_usb3_transaction_32b : std_logic_vector(31 downto 0) := (others => '0'); -- Probing inner signals real-time


        -------------
        -- Signals --
        -------------
        -- Clock Wizard
        signal sys_clk : std_logic := '0';
        signal sampl_clk : std_logic := '0';
        signal acq_clk : std_logic := '0';
        signal locked : std_logic := '0';

        signal sl_rst : std_logic := '0';
        signal sl_rst_sysclk : std_logic := '0'; -- Pullup
        signal sl_rst_samplclk : std_logic := '0';

        -- Dimensioned (fixed) signals for 6 qubits max
        signal s_noisy_channels : std_logic_vector(12-1 downto 0) := (others => '0');
        signal s_channels_redge_synchronized_to_cdcc : std_logic_vector(12-1 downto 0) := (others => '0');
        signal s_stable_channels_to_cdcc : std_logic_vector(12-1 downto 0) := (others => '0');
        signal s_valid_qubits_stable_to_cdcc : std_logic_vector(12/2-1 downto 0) := (others => '0');

        signal sl_inemul_valid : std_logic := '0';

        signal slv_cdcc_rd_valid_to_fsm : std_logic_vector(INT_QUBITS_CNT-1 downto 0) := (others => '0');
        signal slv_cdcc_rd_qubits_to_fsm : std_logic_vector(CHANNELS_CNT-1 downto 0) := (others => '0');

        signal slv_unsuccessful_qubits     : std_logic_vector(INT_QUBITS_CNT-1 downto 1) := (others => '0');
        signal sl_gflow_success_flag       : std_logic := '0';
        signal sl_gflow_success_done       : std_logic := '0';
        signal slv_alpha_to_math           : std_logic_vector(1 downto 0) := (others => '0');
        signal slv_sx_sz_to_math           : std_logic_vector(1 downto 0) := (others => '0');
        signal sl_actual_qubit_valid       : std_logic := '0';
        signal slv_actual_qubit            : std_logic_vector(1 downto 0) := (others => '0');
        signal slv_actual_qubit_time_stamp : std_logic_vector(st_transaction_data_max_width) := (others => '0');
        signal state_gflow                 : natural range 0 to INT_QUBITS_CNT-1 := 0;

        signal sl_pseudorandom_to_math  : std_logic := '0';
        signal slv_math_data_modulo     : std_logic_vector(1 downto 0) := (others => '0');
        signal sl_math_data_valid       : std_logic := '0';

        signal slv_modulo_bit_pulse         : std_logic_vector(0 downto 0) := (others => '0');       
        signal slv_modulo_bit_pulse_delayed : std_logic_vector(0 downto 0) := (others => '0');
        signal pcd_ctrl_pulse_ready         : std_logic_vector(0 downto 0) := (others => '0');
        signal pcd_ctrl_pulse_ready_delayed : std_logic_vector(0 downto 0) := (others => '0');
        signal pcd_ctrl_pulse_busy          : std_logic_vector(0 downto 0) := (others => '0');
        signal pcd_ctrl_pulse_busy_delayed  : std_logic_vector(0 downto 0) := (others => '0');

        -- Data buffers from G-Flow protocol module
        signal slv_qubit_buffer_2d      : t_qubit_buffer_2d := (others => (others => '0'));
        signal slv_time_stamp_buffer_2d : t_time_stamp_buffer_2d := (others => (others => '0'));
        signal slv_alpha_buffer_2d      : t_alpha_buffer_2d := (others => (others => '0'));
        signal slv_modulo_buffer_2d     : t_modulo_buffer_2d := (others => (others => '0'));
        signal slv_random_buffer_2d     : t_random_buffer_2d := (others => (others => '0'));
        signal slv_unsuccessful_cntr_2d : t_unsuccessful_cntr_2d := (others => (others => '0'));

        -- CDCC Sampl clk to Readout clk transfer
        signal slv_qubit_buffer_transferred_2d      : t_qubit_buffer_2d := (others => (others => '0'));
        signal slv_time_stamp_buffer_transferred_2d : t_time_stamp_buffer_2d := (others => (others => '0'));
        signal slv_alpha_buffer_transferred_2d      : t_alpha_buffer_2d := (others => (others => '0'));
        signal slv_modulo_buffer_transferred_2d     : t_modulo_buffer_2d := (others => (others => '0'));
        signal slv_random_buffer_transferred_2d     : t_random_buffer_2d := (others => (others => '0'));
        signal sl_gflow_success_done_transferred    : std_logic := '0';

        -- Output Signals
        signal slv_pcd_ctrl_pulse : std_logic_vector(0 downto 0) := (others => '0');
        signal slv_photon_sampled : std_logic_vector(0 downto 0) := (others => '0');

        -- Keep the input logic at all cost
        attribute DONT_TOUCH : string;
        attribute DONT_TOUCH of s_noisy_channels : signal is "TRUE";


        -- Convert Integer generic values to real numbers
        -- Prevent dividing by zero
        impure function get_divisor (
            constant DIVISOR : integer
        ) return integer is
        begin
            if DIVISOR = 0 then
                return 1;
            else
                return integer(10.0**(floor(log10(real(DIVISOR))) + 1.0));
            end if;
        end function;
        constant PHOTON_1H_DELAY_NS : real := real(INT_WHOLE_PHOTON_1H_DELAY_NS) + real(INT_DECIM_PHOTON_1H_DELAY_NS) / real(get_divisor(INT_DECIM_PHOTON_1H_DELAY_NS));
        constant PHOTON_1V_DELAY_NS : real := real(INT_WHOLE_PHOTON_1V_DELAY_NS) + real(INT_DECIM_PHOTON_1V_DELAY_NS) / real(get_divisor(INT_DECIM_PHOTON_1V_DELAY_NS));
        constant PHOTON_2H_DELAY_NS : real := real(INT_WHOLE_PHOTON_2H_DELAY_NS) + real(INT_DECIM_PHOTON_2H_DELAY_NS) / real(get_divisor(INT_DECIM_PHOTON_2H_DELAY_NS));
        constant PHOTON_2V_DELAY_NS : real := real(INT_WHOLE_PHOTON_2V_DELAY_NS) + real(INT_DECIM_PHOTON_2V_DELAY_NS) / real(get_divisor(INT_DECIM_PHOTON_2V_DELAY_NS));
        constant PHOTON_3H_DELAY_NS : real := real(INT_WHOLE_PHOTON_3H_DELAY_NS) + real(INT_DECIM_PHOTON_3H_DELAY_NS) / real(get_divisor(INT_DECIM_PHOTON_3H_DELAY_NS));
        constant PHOTON_3V_DELAY_NS : real := real(INT_WHOLE_PHOTON_3V_DELAY_NS) + real(INT_DECIM_PHOTON_3V_DELAY_NS) / real(get_divisor(INT_DECIM_PHOTON_3V_DELAY_NS));
        constant PHOTON_4H_DELAY_NS : real := real(INT_WHOLE_PHOTON_4H_DELAY_NS) + real(INT_DECIM_PHOTON_4H_DELAY_NS) / real(get_divisor(INT_DECIM_PHOTON_4H_DELAY_NS));
        constant PHOTON_4V_DELAY_NS : real := real(INT_WHOLE_PHOTON_4V_DELAY_NS) + real(INT_DECIM_PHOTON_4V_DELAY_NS) / real(get_divisor(INT_DECIM_PHOTON_4V_DELAY_NS));
        constant PHOTON_5H_DELAY_NS : real := real(INT_WHOLE_PHOTON_5H_DELAY_NS) + real(INT_DECIM_PHOTON_5H_DELAY_NS) / real(get_divisor(INT_DECIM_PHOTON_5H_DELAY_NS));
        constant PHOTON_5V_DELAY_NS : real := real(INT_WHOLE_PHOTON_5V_DELAY_NS) + real(INT_DECIM_PHOTON_5V_DELAY_NS) / real(get_divisor(INT_DECIM_PHOTON_5V_DELAY_NS));
        constant PHOTON_6H_DELAY_NS : real := real(INT_WHOLE_PHOTON_6H_DELAY_NS) + real(INT_DECIM_PHOTON_6H_DELAY_NS) / real(get_divisor(INT_DECIM_PHOTON_6H_DELAY_NS));
        constant PHOTON_6V_DELAY_NS : real := real(INT_WHOLE_PHOTON_6V_DELAY_NS) + real(INT_DECIM_PHOTON_6V_DELAY_NS) / real(get_divisor(INT_DECIM_PHOTON_6V_DELAY_NS));

        type t_periods_q_2d is array (6-1 downto 0) of real; 
        constant PHOTON_XH_DELAY_NS : t_periods_q_2d := (
            PHOTON_6H_DELAY_NS, -- index 5
            PHOTON_5H_DELAY_NS, -- index 4
            PHOTON_4H_DELAY_NS, -- index 3
            PHOTON_3H_DELAY_NS, -- index 2
            PHOTON_2H_DELAY_NS, -- index 1
            PHOTON_1H_DELAY_NS  -- index 0
        );
        constant PHOTON_XV_DELAY_NS : t_periods_q_2d := (
            PHOTON_6V_DELAY_NS, -- index 5
            PHOTON_5V_DELAY_NS, -- index 4
            PHOTON_4V_DELAY_NS, -- index 3
            PHOTON_3V_DELAY_NS, -- index 2
            PHOTON_2V_DELAY_NS, -- index 1
            PHOTON_1V_DELAY_NS  -- index 0
        );

    begin


        ----------------------
        -- Xilinx IP Blocks --
        ----------------------
        -- Instance Clock Synthesizer (Verilog)
        inst_clock_synthesizer : clock_synthesizer
        generic map (
            -- If input clk is differential, set to 1
            IF_CLKIN1_DIFF => 1,

            -- Set input clk parameters
            REAL_CLKIN1_MHZ => REAL_BOARD_OSC_FREQ_MHZ,

            -- Setup the VCO frequency for the entire device
            INT_VCO_DIVIDE => 1,
            REAL_VCO_MULTIPLY => 6.0,

            REAL_DIVIDE_OUT0 => 2.0,
            INT_DIVIDE_OUT1 => 4,
            INT_DIVIDE_OUT2 => 6,
            INT_DIVIDE_OUT3 => 0,
            INT_DIVIDE_OUT4 => 0,
            INT_DIVIDE_OUT5 => 0,
            INT_DIVIDE_OUT6 => 0,

            REAL_DUTY_OUT0 => 0.5,
            REAL_DUTY_OUT1 => 0.5,
            REAL_DUTY_OUT2 => 0.5,
            REAL_DUTY_OUT3 => 0.5,
            REAL_DUTY_OUT4 => 0.5,
            REAL_DUTY_OUT5 => 0.5,
            REAL_DUTY_OUT6 => 0.5,

            REAL_PHASE_OUT0 => 0.0,
            REAL_PHASE_OUT1 => 0.0,
            REAL_PHASE_OUT2 => 0.0,
            REAL_PHASE_OUT3 => 0.0,
            REAL_PHASE_OUT4 => 0.0,
            REAL_PHASE_OUT5 => 0.0,
            REAL_PHASE_OUT6 => 0.0
        ) port map (
            -- Inputs
            in_clk0_p => sys_clk_p,
            in_clk0_n => sys_clk_n,

            -- Fine Phase Shift
            in_fineps_clk     => '0',
            in_fineps_incr    => '0',
            in_fineps_decr    => '0',
            in_fineps_valid   => '0',
            out_fineps_dready => open,

            -- Outputs
            out_clk0 => acq_clk,
            out_clk1 => sampl_clk,
            out_clk2 => sys_clk,
            out_clk3 => open,
            out_clk4 => open,
            out_clk5 => open,
            out_clk6 => open,
            locked => locked
        );


        ----------
        -- LEDs --
        ----------
        led(3) <= '1';
        led(2) <= '1';
        led(1) <= '1';
        led(0) <= not sl_led_fifo_full_latched;


        ------------------------------------
        -- User 32b Transaction to okHost --
        ------------------------------------
        -- USB PipeOut FIFO Control
        inst_okHost_fifo_ctrl : entity lib_src.ok_usb_32b_fifo_ctrl(rtl)
        generic map (
            INT_QUBITS_CNT => INT_QUBITS_CNT,
            RST_VAL => RST_VAL,
            CLK_HZ => REAL_CLK_SYS_HZ,
            WRITE_VALID_SIGNALS_CNT => 4,
            WRITE_ON_VALID => WRITE_ON_VALID
        )
        port map (
            -- Reset
            rst => sl_rst_sysclk,

            -- Write endpoint signals
            wr_sys_clk => sys_clk,

            wr_unsuccessful_cnt => slv_unsuccessful_cntr_2d,
            wr_valid_gflow_success_done => sl_gflow_success_done_transferred,
            wr_data_qubit_buffer => slv_qubit_buffer_transferred_2d,
            wr_data_time_stamp_buffer => slv_time_stamp_buffer_transferred_2d,
            wr_data_alpha_buffer => slv_alpha_buffer_transferred_2d,
            wr_data_random_buffer => slv_random_buffer_transferred_2d,
            wr_data_modulo_buffer => slv_modulo_buffer_transferred_2d,

            -- Optional: Readout endpoint signals
            readout_clk     => readout_clk,
            readout_data_ready => readout_data_ready,
            readout_data_valid => readout_data_valid,
            readout_enable     => readout_enable,
            readout_data_32b   => readout_data_32b,

            -- Flags
            fifo_full       => sl_usb_fifo_full,
            fifo_empty      => sl_usb_fifo_empty,
            fifo_prog_empty => sl_usb_fifo_prog_empty,

            -- LED
            fifo_full_latched => sl_led_fifo_full_latched

        );

        -- 32b transaction to be transferred to PC over USB3 (read-only)
        slv_usb3_transaction_32b(31) <= slv_cdcc_rd_valid_to_fsm(3);
        slv_usb3_transaction_32b(30 downto 29) <= slv_cdcc_rd_qubits_to_fsm(7 downto 6);
        slv_usb3_transaction_32b(28) <= slv_cdcc_rd_valid_to_fsm(2);
        slv_usb3_transaction_32b(27 downto 26) <= slv_cdcc_rd_qubits_to_fsm(5 downto 4);
        slv_usb3_transaction_32b(25) <= slv_cdcc_rd_valid_to_fsm(1);
        slv_usb3_transaction_32b(24 downto 23) <= slv_cdcc_rd_qubits_to_fsm(3 downto 2);
        slv_usb3_transaction_32b(22) <= slv_cdcc_rd_valid_to_fsm(0);
        slv_usb3_transaction_32b(21 downto 20) <= slv_cdcc_rd_qubits_to_fsm(1 downto 0);

        slv_usb3_transaction_32b(19) <= sl_gflow_success_flag;
        slv_usb3_transaction_32b(18) <= sl_gflow_success_done;
        slv_usb3_transaction_32b(17) <= '0'; -- free
        slv_usb3_transaction_32b(16) <= slv_actual_qubit(1);
        slv_usb3_transaction_32b(15) <= slv_actual_qubit(0);

        slv_usb3_transaction_32b(14) <= sl_actual_qubit_valid;           -- Flag to indicate qubit detection: valid data for 'slv_alpha_to_math' and 'slv_sx_sz_to_math' and 'sl_pseudorandom_to_math'
        slv_usb3_transaction_32b(13 downto 12) <= slv_alpha_to_math;     -- Valid alpha if 'sl_actual_qubit_valid' is valid
        slv_usb3_transaction_32b(11 downto 10) <= slv_sx_sz_to_math;     -- Valid qubit if 'sl_actual_qubit_valid' is valid
        slv_usb3_transaction_32b(9) <= sl_pseudorandom_to_math;          -- Valid random bit if 'sl_actual_qubit_valid' is valid
        slv_usb3_transaction_32b(8 downto 7) <= (others => '0');         -- free
        slv_usb3_transaction_32b(6 downto 5) <= slv_math_data_modulo;    -- In between, check the input going to modulo
        slv_usb3_transaction_32b(4) <= sl_math_data_valid;               -- Flag to indicate valid modulo
        slv_usb3_transaction_32b(3 downto 0) <= (others => '0');         -- Free



        ---------------------
        -- GFLOW DATA PATH --
        ---------------------
        -- s_noisy_channels(0) = PHOTON 1V;
        -- s_noisy_channels(1) = PHOTON 1H;
        -- s_noisy_channels(2) = PHOTON 2V;
        -- s_noisy_channels(3) = PHOTON 2H;
        -- s_noisy_channels(4) = PHOTON 3V;
        -- s_noisy_channels(5) = PHOTON 3H;
        -- s_noisy_channels(6) = PHOTON 4V;
        -- s_noisy_channels(7) = PHOTON 4H;
        -- s_noisy_channels(8) = PHOTON 5V;
        -- s_noisy_channels(9) = PHOTON 5H;
        -- s_noisy_channels(10) = PHOTON 6V;
        -- s_noisy_channels(11) = PHOTON 6H;

        -- Input Buffers
        gen_emul_false : if INT_EMULATE_INPUTS = 0 generate
            inst_xilinx_ibufs : entity lib_src.xilinx_ibufs(rtl)
            generic map (
                PINS_CNT => INPUT_PADS_CNT
            )
            port map (
                clk => acq_clk,
                data_in => input_pads,
                data_out => s_noisy_channels(CHANNELS_CNT-1 downto 0)
            );
        end generate;


        -- If Necessary, uncomment this input emulator for evaluation
        gen_emul_true : if INT_EMULATE_INPUTS /= 0 generate 
            inst_lfsr_inemul : entity lib_src.lfsr_inemul(rtl)
            generic map (
                RST_VAL               => RST_VAL,
                SYMBOL_WIDTH          => 12,
                PRIM_POL_INT_VAL      => 4179,
                GF_SEED               => 1,
                DATA_PULLDOWN_ENABLE  => true,
                PULLDOWN_CYCLES       => 2 -- min 2
            )
            port map (
                clk => sampl_clk,
                rst => sl_rst_sysclk,

                ready => open,
                data_out => s_noisy_channels(12-1 downto 0),
                valid_out => open
            );
        end generate;


        -- Reset: sys_clk domain
        sl_rst <= '1';
        inst_reset_sysclk : entity lib_src.reset(rtl)
        generic map (
            RST_STROBE_COUNTER_WIDTH => RST_STROBE_CNTR_WIDTH_SYSCLK
        )
        port map (
            CLK     => sys_clk,
            IN_RST  => sl_rst,  -- Pullup
            OUT_RST => sl_rst_sysclk
        );

        -- Input metastability filter and qubit deskew
        gen_photon_delay_compensation : for i in 0 to INT_QUBITS_CNT-1 generate
            inst_photon_delay_compensation : entity lib_src.qubit_deskew(rtl)
            generic map (
                RST_VAL                   => RST_VAL,
                BUFFER_DEPTH              => BUFFER_DEPTH,
                PATTERN_WIDTH             => PATTERN_WIDTH,
                BUFFER_PATTERN            => BUFFER_PATTERN,
                CLK_HZ                    => REAL_CLK_ACQ_HZ,

                CNT_ONEHOT_WIDTH          => CNT_ONEHOT_WIDTH,
                DETECTOR_ACTIVE_PERIOD_NS => DETECTOR_ACTIVE_PERIOD_NS,
                DETECTOR_DEAD_PERIOD_NS   => DETECTOR_DEAD_PERIOD_NS,

                TOLERANCE_KEEP_FASTER_BIT_CYCLES => TOLERANCE_KEEP_FASTER_BIT_CYCLES,
                IGNORE_CYCLES_AFTER_TIMEUP => IGNORE_CYCLES_AFTER_TIMEUP,

                PHOTON_H_DELAY_NS => PHOTON_XH_DELAY_NS(i),
                PHOTON_V_DELAY_NS => PHOTON_XV_DELAY_NS(i)
            )
            port map (
                clk => acq_clk,
                rst => sl_rst_samplclk,
                noisy_channels_in => s_noisy_channels((i+1)*2-1 downto (i*2)),
                
                qubit_valid_250MHz => s_valid_qubits_stable_to_cdcc(i),
                qubit_250MHz => s_stable_channels_to_cdcc((i+1)*2-1 downto (i*2)),

                channels_redge_synchronized => s_channels_redge_synchronized_to_cdcc((i+1)*2-1 downto (i*2))
            );

        end generate;


        -- n-FF CDCC (Cross Domain Crossing Circuit)
        gen_nff_cdcc_sysclk : for i in 0 to INT_QUBITS_CNT-1 generate
            slv_cdcc_rd_valid_to_fsm(i) <= slv_cdcc_rd_qubits_to_fsm((i+1)*2-1) or slv_cdcc_rd_qubits_to_fsm(i*2);
            inst_nff_cdcc_cntcross_samplclk_bit1 : entity lib_src.nff_cdcc_flag(rtl)
            generic map (
                BYPASS => CDCC_BYPASS,
                ASYNC_FLOPS_CNT => 2,
                FLOPS_BEFORE_CROSSING_CNT => 1,
                WR_READY_DEASSERTED_CYCLES => 4
            )
            port map (
                -- sampl_clk
                clk_write => acq_clk,
                wr_en => s_stable_channels_to_cdcc((i+1)*2-1),
                wr_ready  => open,

                -- sys_clk
                clk_read => sampl_clk,
                rd_valid => slv_cdcc_rd_qubits_to_fsm((i+1)*2-1)
            );

            inst_nff_cdcc_cntcross_samplclk_bit2 : entity lib_src.nff_cdcc_flag(rtl)
            generic map (
                BYPASS => CDCC_BYPASS,
                ASYNC_FLOPS_CNT => 2,
                FLOPS_BEFORE_CROSSING_CNT => 1,
                WR_READY_DEASSERTED_CYCLES => 4
            )
            port map (
                -- sampl_clk
                clk_write => acq_clk,
                wr_en => s_stable_channels_to_cdcc(i*2),
                wr_ready  => open,

                -- sys_clk
                clk_read => sampl_clk,
                rd_valid => slv_cdcc_rd_qubits_to_fsm(i*2)
            );
        end generate;


        -- G-Flow Protocol FSM (path delay: +1)
        inst_fsm_gflow : entity lib_src.fsm_gflow(rtl)
        generic map (
            RST_VAL                 => RST_VAL,
            -- SAMPL_CLK_HZ            => REAL_CLK_SAMPL_HZ,
            CLK_HZ                  => REAL_CLK_SAMPL_HZ,
            CTRL_PULSE_DUR_WITH_DEADTIME_NS => CTRL_PULSE_DUR_WITH_DEADTIME_NS,
            QUBITS_CNT              => INT_QUBITS_CNT,
            PHOTON_1H_DELAY_NS      => PHOTON_1H_DELAY_NS,
            PHOTON_1V_DELAY_NS      => PHOTON_1V_DELAY_NS,
            PHOTON_2H_DELAY_NS      => PHOTON_2H_DELAY_NS,
            PHOTON_2V_DELAY_NS      => PHOTON_2V_DELAY_NS,
            PHOTON_3H_DELAY_NS      => PHOTON_3H_DELAY_NS,
            PHOTON_3V_DELAY_NS      => PHOTON_3V_DELAY_NS,
            PHOTON_4H_DELAY_NS      => PHOTON_4H_DELAY_NS,
            PHOTON_4V_DELAY_NS      => PHOTON_4V_DELAY_NS,
            PHOTON_5H_DELAY_NS      => PHOTON_5H_DELAY_NS,
            PHOTON_5V_DELAY_NS      => PHOTON_5V_DELAY_NS,
            PHOTON_6H_DELAY_NS      => PHOTON_6H_DELAY_NS,
            PHOTON_6V_DELAY_NS      => PHOTON_6V_DELAY_NS,
            DISCARD_QUBITS_TIME_NS  => INT_DISCARD_QUBITS_TIME_NS
        )
        port map (
            clk                       => sampl_clk,
            rst                       => sl_rst_sysclk,

            qubits_sampled_valid      => slv_cdcc_rd_valid_to_fsm,
            qubits_sampled            => slv_cdcc_rd_qubits_to_fsm,

            feedback_mod_valid        => sl_math_data_valid,
            feedback_mod              => slv_math_data_modulo,

            o_unsuccessful_qubits     => slv_unsuccessful_qubits,

            gflow_success_flag        => sl_gflow_success_flag,
            gflow_success_done        => sl_gflow_success_done,
            qubit_buffer              => slv_qubit_buffer_2d,
            time_stamp_buffer         => slv_time_stamp_buffer_2d,
            alpha_buffer              => slv_alpha_buffer_2d,


            to_math_alpha             => slv_alpha_to_math,
            to_math_sx_xz             => slv_sx_sz_to_math,

            actual_qubit_valid        => sl_actual_qubit_valid,
            actual_qubit              => slv_actual_qubit,
            actual_qubit_time_stamp   => slv_actual_qubit_time_stamp,
            state_gflow               => state_gflow,
            pcd_ctrl_pulse_ready      => pcd_ctrl_pulse_ready_delayed(0)
        );


        -- Pseudorandom number generator outputting bit by bit (on background)
        inst_lfsr_bitgen : entity lib_src.lfsr_bitgen(rtl)
        generic map (
            RST_VAL          => RST_VAL,
            PRIM_POL_INT_VAL => PRIM_POL_INT_VAL,
            SYMBOL_WIDTH     => SYMBOL_WIDTH,
            GF_SEED          => GF_SEED
        )
        port map (
            CLK      => sampl_clk,
            RST      => sl_rst_sysclk,
            RAND_BIT => sl_pseudorandom_to_math
        );


        -- Math block (path delay+1 or +2)
        inst_alu_gflow : entity lib_src.alu_gflow(rtl)
        generic map (
            RST_VAL => RST_VAL,
            QUBITS_CNT => INT_QUBITS_CNT,
            SYNCH_FACTORS_CALCULATION => true  -- +1 delay if true
        )
        port map (
            CLK             => sampl_clk,
            RST             => sl_rst_sysclk,
            QUBIT_VALID     => sl_actual_qubit_valid,
            STATE_QUBIT     => state_gflow,
            S_X             => slv_sx_sz_to_math(0),
            S_Z             => slv_sx_sz_to_math(1),
            ALPHA_POSITIVE  => slv_alpha_to_math,
            RAND_BIT        => sl_pseudorandom_to_math,
            RANDOM_BUFFER   => slv_random_buffer_2d,
            MODULO_BUFFER   => slv_modulo_buffer_2d,
            DATA_MODULO_OUT => slv_math_data_modulo,
            DATA_VALID      => sl_math_data_valid
        );

        -- CDCC Data transfer to slower readout clock domain
        -- Success Flag Transfer
        inst_nff_cdcc_success_done : entity lib_src.nff_cdcc(rtl)
        generic map (
            BYPASS => false,
            ASYNC_FLOPS_CNT => 2,
            DATA_WIDTH => 1,
            FLOPS_BEFORE_CROSSING_CNT => 1,
            WR_READY_DEASSERTED_CYCLES => 2
        )
        port map (
            -- sampl_clk
            clk_write => sampl_clk,
            wr_en     => sl_gflow_success_done,
            wr_data   => (others => '0'),
            wr_ready  => open,

            -- sys_clk
            clk_read => sys_clk,
            rd_valid => sl_gflow_success_done_transferred,
            rd_data  => open
        );

        -- -- Count unsuccessful qubits per channel and transfer the value to the readout domain
        -- gen_cdcc_count_unsuccessful_detections : for i in INT_QUBITS_CNT-1 downto 1 generate
        --     inst_nff_cdcc_unsuccessful_cntr : entity lib_src.nff_cdcc_cntr(rtl)
        --         generic map (
        --             ASYNC_FLOPS_CNT => 2,
        --             CNTR_WIDTH => 8,
        --             FLOPS_BEFORE_CROSSING_CNT => 1,
        --             WR_READY_DEASSERTED_CYCLES => 2
        --         )
        --         port map (
        --             -- Write ports
        --             clk_write => sampl_clk,
        --             wr_en     => slv_unsuccessful_qubits(i),
        --             wr_ready  => open,

        --             -- Read ports
        --             clk_read  => sys_clk,
        --             rd_valid  => open,
        --             rd_data   => slv_unsuccessful_cntr_2d(i)
        --         );
        -- end generate;

        gen_cdcc_transfer_data : for i in 0 to INT_QUBITS_CNT-1 generate
            -- CDCC Qubit Buffer
            inst_nff_cdcc_qubit_buffer : entity lib_src.nff_cdcc(rtl)
                generic map (
                    BYPASS => false,
                    ASYNC_FLOPS_CNT => 2,
                    DATA_WIDTH => 2,
                    FLOPS_BEFORE_CROSSING_CNT => 1,
                    WR_READY_DEASSERTED_CYCLES => 2
                )
                port map (
                    -- sampl_clk
                    clk_write => sampl_clk,
                    wr_en     => sl_gflow_success_done,
                    wr_data   => slv_qubit_buffer_2d(i),
                    wr_ready  => open,

                    -- sys_clk
                    clk_read => sys_clk,
                    rd_valid => open,
                    rd_data  => slv_qubit_buffer_transferred_2d(i)
                );

                -- CDCC Timestamp Buffer
                inst_nff_cdcc_timestamp_buffer : entity lib_src.nff_cdcc(rtl)
                generic map (
                    BYPASS => false,
                    ASYNC_FLOPS_CNT => 2,
                    DATA_WIDTH => 32-4,
                    FLOPS_BEFORE_CROSSING_CNT => 1,
                    WR_READY_DEASSERTED_CYCLES => 2
                )
                port map (
                    -- sampl_clk
                    clk_write => sampl_clk,
                    wr_en     => sl_gflow_success_done,
                    wr_data   => slv_time_stamp_buffer_2d(i),
                    wr_ready  => open,

                    -- sys_clk
                    clk_read => sys_clk,
                    rd_valid => open,
                    rd_data  => slv_time_stamp_buffer_transferred_2d(i)
                );

                -- CDCC Alpha Buffer
                inst_nff_cdcc_alpha_buffer : entity lib_src.nff_cdcc(rtl)
                generic map (
                    BYPASS => false,
                    ASYNC_FLOPS_CNT => 2,
                    DATA_WIDTH => 2,
                    FLOPS_BEFORE_CROSSING_CNT => 1,
                    WR_READY_DEASSERTED_CYCLES => 2
                )
                port map (
                    -- sampl_clk
                    clk_write => sampl_clk,
                    wr_en     => sl_gflow_success_done,
                    wr_data   => slv_alpha_buffer_2d(i),
                    wr_ready  => open,

                    -- sys_clk
                    clk_read => sys_clk,
                    rd_valid => open,
                    rd_data  => slv_alpha_buffer_transferred_2d(i)
                );

                -- CDCC Modulo Buffer
                inst_nff_cdcc_modulo_buffer : entity lib_src.nff_cdcc(rtl)
                generic map (
                    BYPASS => false,
                    ASYNC_FLOPS_CNT => 2,
                    DATA_WIDTH => 2,
                    FLOPS_BEFORE_CROSSING_CNT => 1,
                    WR_READY_DEASSERTED_CYCLES => 2
                )
                port map (
                    -- sampl_clk
                    clk_write => sampl_clk,
                    wr_en     => sl_gflow_success_done,
                    wr_data   => slv_modulo_buffer_2d(i),
                    wr_ready  => open,

                    -- sys_clk
                    clk_read => sys_clk,
                    rd_valid => open,
                    rd_data  => slv_modulo_buffer_transferred_2d(i)
                );

                -- CDCC Random Bit Buffer
                inst_nff_cdcc_random_buffer : entity lib_src.nff_cdcc(rtl)
                generic map (
                    BYPASS => false,
                    ASYNC_FLOPS_CNT => 2,
                    DATA_WIDTH => 1,
                    FLOPS_BEFORE_CROSSING_CNT => 1,
                    WR_READY_DEASSERTED_CYCLES => 2
                )
                port map (
                    -- sampl_clk
                    clk_write => sampl_clk,
                    wr_en     => sl_gflow_success_done,
                    wr_data   => slv_random_buffer_2d(i),
                    wr_ready  => open,

                    -- sys_clk
                    clk_read => sys_clk,
                    rd_valid => open,
                    rd_data  => slv_random_buffer_transferred_2d(i)
                );
        end generate;



        -- PCD Trigger logic
        -- + INT_CTRL_PULSE_HIGH_DURATION_NS + INT_CTRL_PULSE_DEAD_DURATION_NS delay
        inst_pulse_gen : entity lib_src.pulse_gen(rtl)
        generic map (
            RST_VAL                => RST_VAL,
            DATA_WIDTH             => 1,
            REAL_CLK_HZ            => REAL_CLK_SYS_HZ,
            PULSE_DURATION_HIGH_NS => INT_CTRL_PULSE_HIGH_DURATION_NS,
            PULSE_DURATION_LOW_NS  => INT_CTRL_PULSE_DEAD_DURATION_NS
        )
        port map (
            CLK           => sampl_clk,
            RST           => sl_rst_sysclk,
            PULSE_TRIGGER => sl_math_data_valid,
            IN_DATA       => slv_math_data_modulo(1 downto 1), -- take higher modulo bit
            PULSES_OUT    => slv_modulo_bit_pulse,
            READY         => pcd_ctrl_pulse_ready,
            BUSY          => pcd_ctrl_pulse_busy
        );


        -- PCD Trigger modulo pulse delay
        -- + INT_CTRL_PULSE_EXTRA_DELAY_NS delay
        inst_reg_delay_modulo_pulse : entity lib_src.reg_delay(rtl)
        generic map (
            RST_VAL => RST_VAL,
            DATA_WIDTH => 1,
            DELAY_CYCLES => 0, -- Keep DELAY_CYCLES zero to allow DELAY_NS value to be the base for the delay calculation
            DELAY_NS => INT_CTRL_PULSE_EXTRA_DELAY_NS -- This value should be a multiple of clock period for precise results
        )
        port map (
            clk    => sampl_clk,
            i_data => slv_modulo_bit_pulse,
            o_data => slv_modulo_bit_pulse_delayed
        );

        -- Pulse Gen Ready delay
        -- + INT_CTRL_PULSE_EXTRA_DELAY_NS delay
        inst_reg_delay_pulse_gen_ready : entity lib_src.reg_delay(rtl)
        generic map (
            RST_VAL => RST_VAL,
            DATA_WIDTH => 1,
            DELAY_CYCLES => 0, -- Keep DELAY_CYCLES zero to allow DELAY_NS value to be the base for the delay calculation
            DELAY_NS => INT_CTRL_PULSE_EXTRA_DELAY_NS -- This value should be a multiple of clock period for precise results
        )
        port map (
            clk    => sampl_clk,
            i_data => pcd_ctrl_pulse_ready,
            o_data => pcd_ctrl_pulse_ready_delayed
        );

        inst_reg_delay_pulse_gen_busy : entity lib_src.reg_delay(rtl)
        generic map (
            RST_VAL => RST_VAL,
            DATA_WIDTH => 1,
            DELAY_CYCLES => 0, -- Keep DELAY_CYCLES zero to allow DELAY_NS value to be the base for the delay calculation
            DELAY_NS => INT_CTRL_PULSE_EXTRA_DELAY_NS -- This value should be a multiple of clock period for precise results
        )
        port map (
            clk    => sampl_clk,
            i_data => pcd_ctrl_pulse_busy,
            o_data => pcd_ctrl_pulse_busy_delayed
        );


        -- Xilinx OBUFs
        -- +1 clk cycle delay
        o_pcd_ctrl_pulse <= slv_pcd_ctrl_pulse(0);
        inst_xilinx_obuf_pcd : entity lib_src.xilinx_obufs(rtl)
        generic map (
            PINS_CNT => 1
        )
        port map (
            clk      => sampl_clk,
            data_in  => slv_modulo_bit_pulse_delayed,
            data_out => slv_pcd_ctrl_pulse(0 downto 0)
        );

        -- +1 clk cycle delay
        o_photon_sampled <= slv_photon_sampled(0);
        inst_xilinx_obuf_busy : entity lib_src.xilinx_obufs(rtl)
        generic map (
            PINS_CNT => 1
        )
        port map (
            clk      => sampl_clk,
            data_in  => pcd_ctrl_pulse_busy_delayed,
            data_out => slv_photon_sampled(0 downto 0)
        );

    end architecture;