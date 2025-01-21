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
            INT_QUBITS_CNT     : integer := INT_QUBITS_CNT;
            INT_EMULATE_INPUTS : integer := INT_EMULATE_INPUTS;
            INT_ALL_DIGITS_PHOTON_1H_DELAY_NS    : integer := INT_ALL_DIGITS_PHOTON_1H_DELAY_NS;
            INT_ALL_DIGITS_PHOTON_1V_DELAY_NS    : integer := INT_ALL_DIGITS_PHOTON_1V_DELAY_NS;
            INT_WHOLE_DIGITS_CNT_PHOTON_1H_DELAY : integer := INT_WHOLE_DIGITS_CNT_PHOTON_1H_DELAY;
            INT_WHOLE_DIGITS_CNT_PHOTON_1V_DELAY : integer := INT_WHOLE_DIGITS_CNT_PHOTON_1V_DELAY;
            INT_ALL_DIGITS_PHOTON_2H_DELAY_NS    : integer := INT_ALL_DIGITS_PHOTON_2H_DELAY_NS;
            INT_ALL_DIGITS_PHOTON_2V_DELAY_NS    : integer := INT_ALL_DIGITS_PHOTON_2V_DELAY_NS;
            INT_WHOLE_DIGITS_CNT_PHOTON_2H_DELAY : integer := INT_WHOLE_DIGITS_CNT_PHOTON_2H_DELAY;
            INT_WHOLE_DIGITS_CNT_PHOTON_2V_DELAY : integer := INT_WHOLE_DIGITS_CNT_PHOTON_2V_DELAY;
            INT_ALL_DIGITS_PHOTON_3H_DELAY_NS    : integer := INT_ALL_DIGITS_PHOTON_3H_DELAY_NS;
            INT_ALL_DIGITS_PHOTON_3V_DELAY_NS    : integer := INT_ALL_DIGITS_PHOTON_3V_DELAY_NS;
            INT_WHOLE_DIGITS_CNT_PHOTON_3H_DELAY : integer := INT_WHOLE_DIGITS_CNT_PHOTON_3H_DELAY;
            INT_WHOLE_DIGITS_CNT_PHOTON_3V_DELAY : integer := INT_WHOLE_DIGITS_CNT_PHOTON_3V_DELAY;
            INT_ALL_DIGITS_PHOTON_4H_DELAY_NS    : integer := INT_ALL_DIGITS_PHOTON_4H_DELAY_NS;
            INT_ALL_DIGITS_PHOTON_4V_DELAY_NS    : integer := INT_ALL_DIGITS_PHOTON_4V_DELAY_NS;
            INT_WHOLE_DIGITS_CNT_PHOTON_4H_DELAY : integer := INT_WHOLE_DIGITS_CNT_PHOTON_4H_DELAY;
            INT_WHOLE_DIGITS_CNT_PHOTON_4V_DELAY : integer := INT_WHOLE_DIGITS_CNT_PHOTON_4V_DELAY;
            INT_ALL_DIGITS_PHOTON_5H_DELAY_NS    : integer := INT_ALL_DIGITS_PHOTON_5H_DELAY_NS;
            INT_ALL_DIGITS_PHOTON_5V_DELAY_NS    : integer := INT_ALL_DIGITS_PHOTON_5V_DELAY_NS;
            INT_WHOLE_DIGITS_CNT_PHOTON_5H_DELAY : integer := INT_WHOLE_DIGITS_CNT_PHOTON_5H_DELAY;
            INT_WHOLE_DIGITS_CNT_PHOTON_5V_DELAY : integer := INT_WHOLE_DIGITS_CNT_PHOTON_5V_DELAY;
            INT_ALL_DIGITS_PHOTON_6H_DELAY_NS    : integer := INT_ALL_DIGITS_PHOTON_6H_DELAY_NS;
            INT_ALL_DIGITS_PHOTON_6V_DELAY_NS    : integer := INT_ALL_DIGITS_PHOTON_6V_DELAY_NS;
            INT_WHOLE_DIGITS_CNT_PHOTON_6H_DELAY : integer := INT_WHOLE_DIGITS_CNT_PHOTON_6H_DELAY;
            INT_WHOLE_DIGITS_CNT_PHOTON_6V_DELAY : integer := INT_WHOLE_DIGITS_CNT_PHOTON_6V_DELAY;

            INT_CTRL_PULSE_HIGH_DURATION_NS  : integer := INT_CTRL_PULSE_HIGH_DURATION_NS;  -- EOM Control Pulse On Duration
            INT_CTRL_PULSE_DEAD_DURATION_NS  : integer := INT_CTRL_PULSE_DEAD_DURATION_NS;  -- EOM Control Pulse Off Duration (minimal)
            INT_CTRL_PULSE_EXTRA_DELAY_Q2_NS : integer := INT_CTRL_PULSE_EXTRA_DELAY_Q2_NS; -- EOM Control Pulse Delay to catch qubit 2
            INT_CTRL_PULSE_EXTRA_DELAY_Q3_NS : integer := INT_CTRL_PULSE_EXTRA_DELAY_Q3_NS; -- EOM Control Pulse Design to catch qubit 3
            INT_CTRL_PULSE_EXTRA_DELAY_Q4_NS : integer := INT_CTRL_PULSE_EXTRA_DELAY_Q4_NS; -- EOM Control Pulse Design to catch qubit 4
            INT_CTRL_PULSE_EXTRA_DELAY_Q5_NS : integer := INT_CTRL_PULSE_EXTRA_DELAY_Q5_NS; -- EOM Control Pulse Design to catch qubit 5
            INT_CTRL_PULSE_EXTRA_DELAY_Q6_NS : integer := INT_CTRL_PULSE_EXTRA_DELAY_Q6_NS; -- EOM Control Pulse Design to catch qubit 6

            INT_FEEDFWD_PROGRAMMING          : integer := INT_FEEDFWD_PROGRAMMING;
            INT_NUMBER_OF_GFLOWS             : integer := INT_NUMBER_OF_GFLOWS;                             -- Total number of Gflows
            INT_GFLOW_NUMBER                 : integer := INT_GFLOW_NUMBER                                  -- Set to 0 for all Gflows, set to greater than 0 to pick one Gflow

        );
        port (
            -- External 200MHz oscillator (having off-chip termination)
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

            -- Inputs from Detectors
            input_pads : in std_logic_vector(2*INT_QUBITS_CNT-1 downto 0); -- Single Data rate signals

            -- Feedforward control
            i_enable_feedforward : in std_logic; -- Pause/Run Feedforward
            i_rand_feedforward : in std_logic_vector(INT_QUBITS_CNT-1 downto 0);

            -- EOM Trigger + signal valid (for IO delay measuring)
            o_eom_ctrl_pulse : out std_logic;
            o_eom_ctrl_pulsegen_busy : out std_logic;  -- for propagation delay measurements
            o_debug_port_1 : out std_logic;      -- Debug port 1
            o_debug_port_2 : out std_logic;      -- Debug port 2
            o_debug_port_3 : out std_logic       -- Debug port 3
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
        -- SystemVerilog File: 
        --     - must be compiled to the same lib as glbl in ModelSim
        --     - must be instantiated outside of VHDL generate statements - ModelSim compiles, Vivado does not
        component clock_synthesizer
        generic (
            INT_SELECT_PRIMITIVE : integer;
            INT_BUF_CLKFB : integer;
            INT_BUF_OUT0 : integer;
            INT_BUF_OUT1 : integer;
            INT_BUF_OUT2 : integer;
            INT_BUF_OUT3 : integer;
            INT_BUF_OUT4 : integer;
            INT_BUF_OUT5 : integer;
            INT_BUF_OUT6 : integer;
            INT_BUF_OUTB0 : integer;
            INT_BUF_OUTB1 : integer;
            INT_BUF_OUTB2 : integer;
            INT_BUF_OUTB3 : integer;
            INT_BANDWIDTH : integer;
            INT_COMPENSATION : integer;
            IF_CLKIN1_DIFF : integer;
            REAL_CLKIN1_MHZ : real;
            REAL_CLKIN1_PKPK_JITTER_PS : real;
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
            REAL_PHASE_OUT6 : real;
            CLKFBOUT_USE_FINE_PS : integer;
            CLKOUT0_USE_FINE_PS : integer;
            CLKOUT1_USE_FINE_PS : integer;
            CLKOUT2_USE_FINE_PS : integer;
            CLKOUT3_USE_FINE_PS : integer;
            CLKOUT4_USE_FINE_PS : integer;
            CLKOUT5_USE_FINE_PS : integer;
            CLKOUT6_USE_FINE_PS : integer
        ); 
        port (
            in_reset : in std_logic;
            in_clk0_p : in std_logic;
            in_clk0_n : in std_logic;
            in_fineps_clk : in std_logic;
            in_fineps_incr : in std_logic;
            in_fineps_decr : in std_logic;
            in_fineps_valid : in std_logic;
            out_fineps_dready : out std_logic;
            out_clkfb : out std_logic;
            out_clk0 : out std_logic;
            out_clk1 : out std_logic;
            out_clk2 : out std_logic;
            out_clk3 : out std_logic;
            out_clk4 : out std_logic;
            out_clk5 : out std_logic;
            out_clk6 : out std_logic;
            out_clkb0 : out std_logic;
            out_clkb1 : out std_logic;
            out_clkb2 : out std_logic;
            out_clkb3 : out std_logic;
            out_clk0_nobuf : out std_logic;
            out_clk1_nobuf : out std_logic;
            out_clk2_nobuf : out std_logic;
            out_clk3_nobuf : out std_logic;
            out_clk0_inv : out std_logic;
            out_clk1_inv : out std_logic;
            out_clk2_inv : out std_logic;
            out_clk3_inv : out std_logic;
            locked : out std_logic
        );
        end component;

        -- Clocks
        constant REAL_BOARD_OSC_FREQ_MHZ : real := 200.0;
        constant REAL_CLK_EVAL_MHZ : real := 200.0;
        constant REAL_CLK_EVAL_HZ : real := 200.0e6;
        -- constant REAL_CLK_DSP_HZ : real := 300.0e6;
        constant REAL_CLK_DSP_HZ : real := 400.0e6; -- NEW
        -- constant REAL_CLK_DSP_HZ : real := 500.0e6; -- NEW
        constant REAL_CLK_ACQ_HZ : real := 600.0e6;

        ---------------
        -- Constants --
        ---------------
        constant INPUT_PADS_CNT : positive := INT_QUBITS_CNT*2;

        -- Noisy rising edge detection & keep input
        constant CHANNELS_CNT                     : positive := INPUT_PADS_CNT;
        constant PATTERN_WIDTH                    : positive := 3; --          3 = [ ] [ ] [ ] must be equal or less than PATTERN_WIDTH
        constant BUFFER_PATTERN                   : positive := 1; -- default: 1 =  0   0   1

        -- NEW
        -- constant PATTERN_WIDTH                    : positive := 4;    -- 4 = [ ] [ ] [ ] [ ] must be equal or less than PATTERN_WIDTH
        -- NEW
        -- constant BUFFER_PATTERN                   : positive := 3; -- default: 1 =  0   1   1

        -- constant BUFFER_PATTERN                   : positive := 3;    -- 3 =  0   1   1
        constant DETECTOR_ACTIVE_PERIOD_NS        : positive := 10;
        constant DETECTOR_DEAD_PERIOD_NS          : positive := 22;
        constant TOLERANCE_KEEP_FASTER_BIT_CYCLES : natural := 0; -- # To Be Deleted
        constant IGNORE_CYCLES_AFTER_TIMEUP       : natural := 3;

        -- CDCC Logic
        constant CDCC_BYPASS : boolean := false;

        -- Pseudorandom bit generator
        constant PRIM_POL_INT_VAL  : positive := 19;
        constant SYMBOL_WIDTH      : positive := 4;
        constant GF_SEED           : positive := 1;

        -- Gflow FSM
        -- Delay before: PATTERN_WIDTH + DELAY COMPENSATION BUFFER + REDGE clk + Output Logic Buffer
        --                                                   (metastability flipflop) + (2x oversample) + (redge detection) + (output logic)
        constant TOTAL_STATIC_DELAY_FPGA_BEFORE : natural := 1                        + 2               + 1                 + 1; -- NOTE: synchr flipflops are calculated in fsm_feedforward
        constant MAGIC_NUMBER_AFTER : natural := 5;


        -------------
        -- Signals --
        -------------      
        -- NEW
        -- MMCM clk outputs
        signal acq_clk0 : std_logic := '0';
        signal acq_clk90 : std_logic := '0';
        signal dsp_clk : std_logic := '0';
        signal eval_clk : std_logic := '0';
        signal inemul_clk : std_logic := '0';
        signal apd_emul_clk : std_logic := '0';
        signal mmcm_locked : std_logic := '0';

        -- IDELAY components
        signal slv_idelay_rdy : std_logic_vector(2 downto 0) := (others => '0');
        signal slv_idelay_rst : std_logic_vector(2 downto 0) := (others => '0');
        signal slv_mmcm_not_locked : std_logic_vector(2 downto 0) := (others => '0');

        -- Selects the correct MMCM output acquisition clock based on the for-generate index
        type t_preloaded_indices_2d is array (6-1 downto 0) of integer; -- is MAX_QUBITS_CNT- downto 0
        impure function clk_acq_preload_indices (
            constant QUBITS_CNT : natural
        ) return t_preloaded_indices_2d is
            variable v_preloaded_indices_2d : t_preloaded_indices_2d := (others => 0);
        begin
            for i in 0 to QUBITS_CNT-1 loop
                if i <= 1 then
                    -- acq_clk_X0Y4 index
                    v_preloaded_indices_2d(i) := 2;
                elsif i <= 4 then
                    -- acq_clk_X0Y3 index
                    v_preloaded_indices_2d(i) := 1;
                else
                    -- acq_clk_X0Y2 index
                    v_preloaded_indices_2d(i) := 0;
                end if;
            end loop;
            return v_preloaded_indices_2d;
        end function;
        constant BANK_ID : t_preloaded_indices_2d := clk_acq_preload_indices(6); -- MAX_QUBITS_CNT

        -- FIFO Set/Reset on device power up in both RD and WR domains
        signal sl_rst_eval_clk : std_logic := '0';
        signal sl_rst_readout_clk : std_logic := '0';
        signal sl_rst_dsp_clk : std_logic := '0';

        -- Dimensioned (fixed) input signals for 6 qubits max
        type t_input_channels_iddr_slv_2d is array (6-1 downto 0) of std_logic_vector(2-1 downto 0);
        type t_input_channels_iserdes_slv_2d is array (6-1 downto 0) of std_logic_vector(4-1 downto 0);

        signal slv_input_pads_v : std_logic_vector(6-1 downto 0) := (others => '0');
        signal slv_input_channels_v_fdre : std_logic_vector(6-1 downto 0) := (others => '0');
        signal slv_input_channels_v_iddr_2clk_2d : t_input_channels_iddr_slv_2d := (others => (others => '0'));
        signal slv_input_channels_v_iserdese2_2d : t_input_channels_iserdes_slv_2d := (others => (others => '0'));

        signal slv_input_pads_h : std_logic_vector(6-1 downto 0) := (others => '0');
        signal slv_input_channels_h_fdre : std_logic_vector(6-1 downto 0) := (others => '0');
        signal slv_input_channels_h_iddr_2clk_2d : t_input_channels_iddr_slv_2d := (others => (others => '0'));
        signal slv_input_channels_h_iserdese2_2d : t_input_channels_iserdes_slv_2d := (others => (others => '0'));

        signal slv_input_channels : std_logic_vector(12-1 downto 0) := (others => '0');
        signal slv_input_channels_donttouch : std_logic_vector(INT_QUBITS_CNT*2-1 downto 0) := (others => '0');

        -- to CDCC
        signal s_channels_redge_to_cdcc : std_logic_vector(12-1 downto 0) := (others => '0');
        signal s_stable_channels_to_cdcc : std_logic_vector(12-1 downto 0) := (others => '0');
        signal s_valid_qubits_stable_to_cdcc : std_logic_vector(12/2-1 downto 0) := (others => '0');

        signal sl_inemul_valid : std_logic := '0';

        signal slv_cdcc_rd_valid_to_fsm : std_logic_vector(INT_QUBITS_CNT-1 downto 0) := (others => '0');
        signal slv_cdcc_rd_qubits_to_fsm : std_logic_vector(CHANNELS_CNT-1 downto 0) := (others => '0');
        signal slv_cdcc_rd_qubits_to_fsm_delayed : std_logic_vector(CHANNELS_CNT-1 downto 0) := (others => '0');

        signal slv_enable_feedforward_to_cdcc : std_logic_vector(0 downto 0) := (others => '0');
        signal slv_enable_feedforward      : std_logic_vector(0 downto 0) := (others => '0');
        signal slv_rand_feedforward_to_cdcc : std_logic_vector(INT_QUBITS_CNT-1 downto 0) := (others => '0');
        signal slv_rand_feedforward        : std_logic_vector(INT_QUBITS_CNT-1 downto 0) := (others => '0');

        signal slv_feedforward_pulse       : std_logic_vector(0 downto 0) := (others => '0');
        signal slv_feedforward_pulse_trigger : std_logic_vector(0 downto 0) := (others => '0');
        signal sl_feedfwd_success_flag     : std_logic := '0';
        signal slv_feedfwd_success_flag    : std_logic_vector(0 downto 0) := (others => '0');
        signal sl_feedfwd_start            : std_logic := '0';
        signal slv_feedfwd_start           : std_logic_vector(0 downto 0) := (others => '0');
        signal slv_alpha_to_math           : std_logic_vector(1 downto 0) := (others => '0');
        signal slv_sx_sz_to_math           : std_logic_vector(1 downto 0) := (others => '0');
        signal slv_o_sx_next_to_math       : std_logic_vector(1 downto 0) := (others => '0');
        signal sl_actual_qubit_valid       : std_logic := '0';
        signal slv_actual_qubit            : std_logic_vector(1 downto 0) := (others => '0');
        signal slv_actual_qubit_time_stamp : std_logic_vector(st_transaction_data_max_width) := (others => '0');
        -- signal state_feedfwd               : natural range 0 to INT_QUBITS_CNT-1 := 0;
        signal state_feedfwd               : std_logic_vector(INT_QUBITS_CNT-1 downto 0) := (others => '0');


        signal sl_pseudorandom_to_math : std_logic := '0';
        signal slv_math_data_modulo    : std_logic_vector(1 downto 0) := (others => '0');
        signal sl_math_data_valid      : std_logic := '0';

        signal slv_feedfwd_eom_pulse         : std_logic_vector(0 downto 0) := (others => '0');
        signal slv_feedfwd_eom_pulse_en      : std_logic_vector(0 downto 0) := (others => '0');
        signal slv_feedfwd_eom_pulse_delayed : std_logic_vector(INT_QUBITS_CNT-2 downto 0) := (others => '0');
        signal slv_feedfwd_eom_pulse_delayed_ored : std_logic_vector(0 downto 0) := (others => '0');
        signal slv_feedfwd_eom_pulse_delayed_ored_ff : std_logic_vector(0 downto 0) := (others => '0');
        signal eom_ctrl_pulse_ready          : std_logic_vector(0 downto 0) := (others => '0');
        signal eom_ctrl_pulse_ready_delayed  : std_logic_vector(0 downto 0) := (others => '0');
        signal eom_ctrl_pulse_busy           : std_logic_vector(0 downto 0) := (others => '0');
        signal eom_ctrl_pulse_busy_delayed   : std_logic_vector(0 downto 0) := (others => '0');

        signal eom_ctrl_pulse_coincidence : std_logic_vector(0 downto 0) := (others => '0');

        -- Data buffers from G-Flow protocol module
        signal slv_qubit_buffer_2d      : t_qubit_buffer_2d := (others => (others => '0'));
        signal slv_time_stamp_buffer_2d : t_time_stamp_buffer_2d := (others => (others => '0'));
        signal slv_alpha_buffer_2d      : t_alpha_buffer_2d := (others => (others => '0'));
        signal slv_modulo_buffer_2d     : t_modulo_buffer_2d := (others => (others => '0'));
        signal slv_random_buffer_2d     : t_random_buffer_2d := (others => (others => '0'));
        signal slv_sx_buffer            : std_logic_vector(INT_QUBITS_CNT-1 downto 0) := (others => '0');
        signal slv_sz_buffer            : std_logic_vector(INT_QUBITS_CNT-1 downto 0) := (others => '0');
        signal slv_gflow_number         : std_logic_vector(28-1 downto 0);
        signal slv_actual_gflow_buffer  : std_logic_vector(integer(ceil(log2(real(INT_NUMBER_OF_GFLOWS+1))))-1 downto 0) := (others => '0');

        -- Pulses used for measurements
        signal slv_photon_losses_to_cdcc : std_logic_vector(INT_QUBITS_CNT-2 downto 0) := (others => '0');
        signal slv_photon_losses         : std_logic_vector(INT_QUBITS_CNT-2 downto 0) := (others => '0');
        signal slv_channels_detections_cntr : t_photon_counter_2d := (others => (others => '0'));

        -- CDCC Sampl clk to Readout clk transfer
        signal slv_qubit_buffer_to_transfer_rd_valid      : std_logic_vector(INT_QUBITS_CNT downto 0) := (others => '0');
        signal slv_time_stamp_buffer_to_transfer_rd_valid : std_logic_vector(INT_QUBITS_CNT downto 0) := (others => '0');
        signal slv_alpha_buffer_to_transfer_rd_valid      : std_logic_vector(INT_QUBITS_CNT downto 0) := (others => '0');
        signal slv_modulo_buffer_to_transfer_rd_valid     : std_logic_vector(INT_QUBITS_CNT downto 0) := (others => '0');
        signal slv_random_buffer_to_transfer_rd_valid     : std_logic_vector(INT_QUBITS_CNT downto 0) := (others => '0');
        signal sl_sx_buffer_to_transfer_rd_valid          : std_logic := '0';
        signal sl_sz_buffer_to_transfer_rd_valid          : std_logic := '0';
        signal sl_actual_gflow_buffer_to_transfer_rd_valid  : std_logic := '0';
        signal sl_feedfwd_success_done_to_transfer_rd_valid : std_logic := '0';

        signal slv_qubit_buffer_to_transfer_rd_rdy      : std_logic_vector(INT_QUBITS_CNT downto 0) := (others => '0');
        signal slv_time_stamp_buffer_to_transfer_rd_rdy : std_logic_vector(INT_QUBITS_CNT downto 0) := (others => '0');
        signal slv_alpha_buffer_to_transfer_rd_rdy      : std_logic_vector(INT_QUBITS_CNT downto 0) := (others => '0');
        signal slv_modulo_buffer_to_transfer_rd_rdy     : std_logic_vector(INT_QUBITS_CNT downto 0) := (others => '0');
        signal slv_random_buffer_to_transfer_rd_rdy     : std_logic_vector(INT_QUBITS_CNT downto 0) := (others => '0');
        signal sl_sx_buffer_to_transfer_rd_rdy          : std_logic := '0';
        signal sl_sz_buffer_to_transfer_rd_rdy          : std_logic := '0';
        signal sl_actual_gflow_buffer_to_transfer_rd_rdy  : std_logic := '0';
        signal sl_feedfwd_success_done_to_transfer_rd_rdy : std_logic := '0';

        signal slv_qubit_buffer_to_transfer_2d      : t_qubit_buffer_2d := (others => (others => '0'));
        signal slv_time_stamp_buffer_to_transfer_2d : t_time_stamp_buffer_2d := (others => (others => '0'));
        signal slv_alpha_buffer_to_transfer_2d      : t_alpha_buffer_2d := (others => (others => '0'));
        signal slv_modulo_buffer_to_transfer_2d     : t_modulo_buffer_2d := (others => (others => '0'));
        signal slv_random_buffer_to_transfer_2d     : t_random_buffer_2d := (others => (others => '0'));
        signal slv_sx_buffer_to_transfer            : std_logic_vector(INT_QUBITS_CNT-1 downto 0) := (others => '0');
        signal slv_sz_buffer_to_transfer            : std_logic_vector(INT_QUBITS_CNT-1 downto 0) := (others => '0');
        signal slv_actual_gflow_buffer_to_transfer  : std_logic_vector(slv_actual_gflow_buffer'range) := (others => '0');
        signal sl_feedfwd_success_done_to_transfer  : std_logic := '0';

        signal slv_qubit_buffer_transferred_2d      : t_qubit_buffer_2d := (others => (others => '0'));
        signal slv_time_stamp_buffer_transferred_2d : t_time_stamp_buffer_2d := (others => (others => '0'));
        signal slv_alpha_buffer_transferred_2d      : t_alpha_buffer_2d := (others => (others => '0'));
        signal slv_modulo_buffer_transferred_2d     : t_modulo_buffer_2d := (others => (others => '0'));
        signal slv_random_buffer_transferred_2d     : t_random_buffer_2d := (others => (others => '0'));
        signal slv_sx_buffer_transferred            : std_logic_vector(INT_QUBITS_CNT-1 downto 0) := (others => '0');
        signal slv_sz_buffer_transferred            : std_logic_vector(INT_QUBITS_CNT-1 downto 0) := (others => '0');
        signal slv_actual_gflow_buffer_transferred  : std_logic_vector(slv_actual_gflow_buffer'range) := (others => '0');
        signal sl_feedfwd_success_done_transferred  : std_logic := '0';

        -- Output Signals
        signal slv_debug_port_1 : std_logic_vector(0 downto 0) := (others => '0');
        signal slv_debug_port_2 : std_logic_vector(0 downto 0) := (others => '0');
        signal slv_debug_port_3 : std_logic_vector(0 downto 0) := (others => '0');
        signal slv_eom_ctrl_pulse : std_logic_vector(0 downto 0) := (others => '0');
        signal slv_eom_ctrl_pulsegen_busy : std_logic_vector(0 downto 0) := (others => '0');
        signal slv_photon_1h : std_logic_vector(0 downto 0) := (others => '0');
        signal slv_photon_1v : std_logic_vector(0 downto 0) := (others => '0');

        -- Keep the input logic at all cost
        attribute DONT_TOUCH : string;
        attribute DONT_TOUCH of slv_input_channels_donttouch : signal is "TRUE";


        -- Convert Integer generic values to real numbers
        impure function int_to_real (
            constant INT_ALL_DIGITS : integer;        -- Contains whole and decimal digits (e.g. 4541710)
            constant INT_WHOLE_DIGITS_COUNT : integer -- Positive int specifies the number of whole digits in 'INT_ALL_DIGITS' (e.g. 2 to be converted to 45.41710)
                                                      -- Negative int adds leading zeros to 'INT_ALL_DIGITS' (e.g. -2 to be converted to 0.004541710)
                                                      -- Zero will create a decimal number: 0.'INT_ALL_DIGITS' (to be converted to 0.4541710)
        ) return real is
        begin
            if INT_ALL_DIGITS /= 0 then
                return (real(INT_ALL_DIGITS) / (10.0**(floor(log10(abs(real(INT_ALL_DIGITS))))+1.0))) * (0.1**(-1.0*real(INT_WHOLE_DIGITS_COUNT)));
            else
                return 0.0;
            end if;
        end function;
        constant PHOTON_1H_DELAY_NS : real := abs(int_to_real(INT_ALL_DIGITS_PHOTON_1H_DELAY_NS, INT_WHOLE_DIGITS_CNT_PHOTON_1H_DELAY));
        constant PHOTON_1V_DELAY_NS : real := abs(int_to_real(INT_ALL_DIGITS_PHOTON_1V_DELAY_NS, INT_WHOLE_DIGITS_CNT_PHOTON_1V_DELAY));
        constant PHOTON_2H_DELAY_NS : real := abs(int_to_real(INT_ALL_DIGITS_PHOTON_2H_DELAY_NS, INT_WHOLE_DIGITS_CNT_PHOTON_2H_DELAY));
        constant PHOTON_2V_DELAY_NS : real := abs(int_to_real(INT_ALL_DIGITS_PHOTON_2V_DELAY_NS, INT_WHOLE_DIGITS_CNT_PHOTON_2V_DELAY));
        constant PHOTON_3H_DELAY_NS : real := abs(int_to_real(INT_ALL_DIGITS_PHOTON_3H_DELAY_NS, INT_WHOLE_DIGITS_CNT_PHOTON_3H_DELAY));
        constant PHOTON_3V_DELAY_NS : real := abs(int_to_real(INT_ALL_DIGITS_PHOTON_3V_DELAY_NS, INT_WHOLE_DIGITS_CNT_PHOTON_3V_DELAY));
        constant PHOTON_4H_DELAY_NS : real := abs(int_to_real(INT_ALL_DIGITS_PHOTON_4H_DELAY_NS, INT_WHOLE_DIGITS_CNT_PHOTON_4H_DELAY));
        constant PHOTON_4V_DELAY_NS : real := abs(int_to_real(INT_ALL_DIGITS_PHOTON_4V_DELAY_NS, INT_WHOLE_DIGITS_CNT_PHOTON_4V_DELAY));
        constant PHOTON_5H_DELAY_NS : real := abs(int_to_real(INT_ALL_DIGITS_PHOTON_5H_DELAY_NS, INT_WHOLE_DIGITS_CNT_PHOTON_5H_DELAY));
        constant PHOTON_5V_DELAY_NS : real := abs(int_to_real(INT_ALL_DIGITS_PHOTON_5V_DELAY_NS, INT_WHOLE_DIGITS_CNT_PHOTON_5V_DELAY));
        constant PHOTON_6H_DELAY_NS : real := abs(int_to_real(INT_ALL_DIGITS_PHOTON_6H_DELAY_NS, INT_WHOLE_DIGITS_CNT_PHOTON_6H_DELAY));
        constant PHOTON_6V_DELAY_NS : real := abs(int_to_real(INT_ALL_DIGITS_PHOTON_6V_DELAY_NS, INT_WHOLE_DIGITS_CNT_PHOTON_6V_DELAY));

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


        -- NEW
        -- Ceil function may increase the difference from the target and generated delay
        --                            H        V
        type idelay_taps_hvphotons is array(1 downto 0) of natural;
        type idelay_taps_hvphotons_allqubits_2d is array (6-1 downto 0) of idelay_taps_hvphotons;
        impure function correct_periods (
            constant REAL_CLK_HZ : real;
            constant PHOTON_H_DELAY_NS_REAL_ABS : real;
            constant PHOTON_V_DELAY_NS_REAL_ABS : real
        ) return idelay_taps_hvphotons is
            --                                          CLK_PERIOD_NS
            variable v_periods_plus_one : real := 0.0;
            variable v_periods_plus_one_abserror : real;

            variable v_periods_actual : real := 0.0;
            variable v_periods_actual_abserror : real;

            variable v_periods_minus_one : real := 0.0;
            variable v_periods_minus_one_abserror : real;

            variable real_target_value : real := 0.0;
            variable v_clk_period_ns : real := 0.0;
            variable v_time_difference_photons_ns_abs : real := 0.0;
            variable v_clk_periods_difference_delay : natural := 0;

            variable both_idelays : idelay_taps_hvphotons := (others => 0);
        begin

            report "PHOTON_H_DELAY_NS_REAL_ABS = " & real'image(PHOTON_H_DELAY_NS_REAL_ABS);
            report "PHOTON_V_DELAY_NS_REAL_ABS = " & real'image(PHOTON_V_DELAY_NS_REAL_ABS);

            -- No fine ps compensation if all delays are equal
            if PHOTON_H_DELAY_NS_REAL_ABS = PHOTON_V_DELAY_NS_REAL_ABS then
                both_idelays(0) := 0; -- V
                both_idelays(1) := 0; -- H
                return both_idelays;
            end if;

            v_clk_period_ns := (1.0/real(REAL_CLK_HZ) * 1.0e9);

            -- Absolute time difference of H and V photons
            v_time_difference_photons_ns_abs :=
                abs(PHOTON_H_DELAY_NS_REAL_ABS-PHOTON_V_DELAY_NS_REAL_ABS);
            report "v_time_difference_photons_ns_abs=" & real'image(v_time_difference_photons_ns_abs);

            -- Delay in lock periods at clock 'REAL_CLK_HZ'
            v_clk_periods_difference_delay :=
                natural( ceil(v_time_difference_photons_ns_abs / v_clk_period_ns) );
            report "ceil(v_time_difference_photns_ns_abs / v_clk_period_ns)=" & integer'image(v_clk_periods_difference_delay);

            -- Calculate delay -1 clock cycle, +0 clock cycle, +1 clock cycle
            -- to assess which one leads to more accurate delay compensation
            -- at the 'REAL_CLK_HZ' clock
            v_periods_plus_one := v_clk_period_ns * real(v_clk_periods_difference_delay+1);
            v_periods_actual := v_clk_period_ns * real(v_clk_periods_difference_delay);
            v_periods_minus_one := v_clk_period_ns * real(v_clk_periods_difference_delay-1);
            report "v_periods_plus_one=" & real'image(v_periods_plus_one);
            report "v_periods_actual=" & real'image(v_periods_actual);
            report "v_periods_minus_one=" & real'image(v_periods_minus_one);

            real_target_value := real(v_time_difference_photons_ns_abs);
            report "real_target_value=" & real'image(v_periods_minus_one);

            -- Compare differences from each case and select the one with minimum error 
            -- (closest to the target delay value to be compensated)
            if real_target_value < v_periods_plus_one then
                v_periods_plus_one_abserror := v_periods_plus_one - real_target_value;
            else
                v_periods_plus_one_abserror := real_target_value - v_periods_plus_one;
            end if;
            report "v_periods_plus_one_abserror=" & real'image(v_periods_plus_one_abserror);


            if real_target_value < v_periods_actual then
                v_periods_actual_abserror := v_periods_actual - real_target_value;
            else
                v_periods_actual_abserror := real_target_value - v_periods_actual;
            end if;
            report "v_periods_actual_abserror=" & real'image(v_periods_actual_abserror);

            if real_target_value < v_periods_minus_one then
                v_periods_minus_one_abserror := v_periods_minus_one - real_target_value;
            else
                v_periods_minus_one_abserror := real_target_value - v_periods_minus_one;
            end if;
            report "v_periods_minus_one_abserror=" & real'image(v_periods_minus_one_abserror);

            -- If CLK_PERIODS+1 gives less error
            if v_periods_plus_one_abserror < v_periods_actual_abserror then
                if v_periods_plus_one_abserror < v_periods_minus_one_abserror then

                    v_clk_periods_difference_delay := v_clk_periods_difference_delay + 1;

                    report "TOP: v_clk_periods_difference_delay + 1 = " & integer'image(v_clk_periods_difference_delay);
                    report "TOP: v_periods_plus_one_abserror = " & real'image(v_periods_plus_one_abserror);
                    if PHOTON_H_DELAY_NS_REAL_ABS < PHOTON_V_DELAY_NS_REAL_ABS then
                        -- Since H (arrives realier) needs to match the delay of V 
                        -- -> add additional, yet uncompensated, precise delay
                        both_idelays(0) := 0; -- V
                        both_idelays(1) := natural(v_periods_plus_one_abserror*1000.0/78.0); -- H; uncompensated fine delay difference->ps / 78ps IDELAY tap resolution
                        report "TOP: both_idelays(0) = " & integer'image(both_idelays(0));
                        report "TOP: both_idelays(1) = " & integer'image(both_idelays(1));
                    else
                        -- Since V (arrives earlier) needs to match the delay of H 
                        -- -> add additional, yet uncompensated, precise delay
                        both_idelays(0) := natural(v_periods_plus_one_abserror*1000.0/78.0); -- V; uncompensated fine delay difference->ps / 78ps IDELAY tap resolution
                        both_idelays(1) := 0; -- H
                        report "TOP: else both_idelays(0) = " & integer'image(both_idelays(0));
                        report "TOP: else both_idelays(1) = " & integer'image(both_idelays(1));
                    end if;
                    return both_idelays;
                end if;
            end if;

            -- If CLK_PERIODS-1 gives less error
            if v_periods_minus_one_abserror < v_periods_actual_abserror then
                if v_periods_minus_one_abserror < v_periods_plus_one_abserror then

                    v_clk_periods_difference_delay := v_clk_periods_difference_delay - 1;

                    report "TOP: v_clk_periods_difference_delay - 1 = " & integer'image(v_clk_periods_difference_delay);
                    report "TOP: v_periods_minus_one_abserror = " & real'image(v_periods_minus_one_abserror);
                    if PHOTON_H_DELAY_NS_REAL_ABS < PHOTON_V_DELAY_NS_REAL_ABS then
                        -- Since H (arrives realier) needs to match the delay of V 
                        -- -> add additional precise delay for precise compensation
                        both_idelays(0) := 0; -- V
                        both_idelays(1) := natural(v_periods_minus_one_abserror*1000.0/78.0); -- H; uncompensated fine delay difference->ps / 78ps IDELAY tap resolution
                        report "TOP: both_idelays(0) = " & integer'image(both_idelays(0));
                        report "TOP: both_idelays(1) = " & integer'image(both_idelays(1));
                    else
                        -- Since V (arrives earlier) needs to match the delay of H 
                        -- -> add additional, yet uncompensated, precise delay
                        both_idelays(0) := natural(v_periods_minus_one_abserror*1000.0/78.0); -- V; uncompensated fine delay difference->ps / 78ps IDELAY tap resolution
                        both_idelays(1) := 0; -- H
                        report "TOP: else both_idelays(0) = " & integer'image(both_idelays(0));
                        report "TOP: else both_idelays(1) = " & integer'image(both_idelays(1));
                    end if;
                    return both_idelays;
                end if;
            end if;

            report "TOP: v_clk_periods_difference_delay = " & integer'image(v_clk_periods_difference_delay);
            report "TOP: v_periods_actual_abserror = " & real'image(v_periods_actual_abserror);
            if PHOTON_H_DELAY_NS_REAL_ABS < PHOTON_V_DELAY_NS_REAL_ABS then
                -- Since H (arrives realier) needs to match the delay of V 
                -- -> add additional, yet uncompensated, precise delay
                both_idelays(0) := 0; -- V
                both_idelays(1) := natural(v_periods_actual_abserror*1000.0/78.0); -- H; uncompensated fine delay difference->ps / 78ps IDELAY tap resolution
                report "TOP: both_idelays(0) = " & integer'image(both_idelays(0));
                report "TOP: both_idelays(1) = " & integer'image(both_idelays(1));
            else
                -- Since V (arrives earlier) needs to match the delay of H 
                -- -> add additional, yet uncompensated, precise delay
                both_idelays(0) := natural(v_periods_actual_abserror*1000.0/78.0); -- V; uncompensated fine delay difference->ps / 78ps IDELAY tap resolution
                both_idelays(1) := 0; -- H
                report "TOP: else both_idelays(0) = " & integer'image(both_idelays(0));
                report "TOP: else both_idelays(1) = " & integer'image(both_idelays(1));
            end if;
            return both_idelays;

        end function;

        --Example: if v_periods_actual_abserror = 0.8333 ns -> (0.8333*1000) ps / 78 ps IDELAY tap = 10.7 (round up) = 11 taps
        constant TAPS_DELAY_COMPENSATION_IDELAY : idelay_taps_hvphotons_allqubits_2d := (
            correct_periods(REAL_CLK_ACQ_HZ,PHOTON_6H_DELAY_NS,PHOTON_6V_DELAY_NS),
            correct_periods(REAL_CLK_ACQ_HZ,PHOTON_5H_DELAY_NS,PHOTON_5V_DELAY_NS),
            correct_periods(REAL_CLK_ACQ_HZ,PHOTON_4H_DELAY_NS,PHOTON_4V_DELAY_NS),
            correct_periods(REAL_CLK_ACQ_HZ,PHOTON_3H_DELAY_NS,PHOTON_3V_DELAY_NS),
            correct_periods(REAL_CLK_ACQ_HZ,PHOTON_2H_DELAY_NS,PHOTON_2V_DELAY_NS),
            correct_periods(REAL_CLK_ACQ_HZ,PHOTON_1H_DELAY_NS,PHOTON_1V_DELAY_NS)
        );


        -- And gate to multiple signals
        function or_all_bits_in_slv (
            slv_signal : std_logic_vector; -- min 2 bit wide slv
            SLV_WIDTH : positive
        ) return std_logic is
            variable v_slv_signal : std_logic_vector(SLV_WIDTH-1 downto 0) := (others => '0');
            variable v_sl_output : std_logic := '0';
        begin
            v_slv_signal(SLV_WIDTH-1 downto 0) := slv_signal(SLV_WIDTH-1 downto 0);
            v_sl_output := v_slv_signal(SLV_WIDTH-1);
            for i in SLV_WIDTH-2 downto 0 loop
                v_sl_output := v_sl_output or v_slv_signal(i);
            end loop;
            return v_sl_output;
        end function;


        type t_delays_before_eom_2d is array (6-2 downto 0) of natural;
        constant INT_CTRL_PULSE_EXTRA_DELAY_QX_NS : t_delays_before_eom_2d := (
            INT_CTRL_PULSE_EXTRA_DELAY_Q6_NS,
            INT_CTRL_PULSE_EXTRA_DELAY_Q5_NS,
            INT_CTRL_PULSE_EXTRA_DELAY_Q4_NS,
            INT_CTRL_PULSE_EXTRA_DELAY_Q3_NS,
            INT_CTRL_PULSE_EXTRA_DELAY_Q2_NS  -- index 0
        );

    begin

        -- Re-assign and tie unused wires to zero to prevent width mismatch
        -- s_input_pads(INT_QUBITS_CNT*2-1 downto 0) <= input_pads(INT_QUBITS_CNT*2-1 downto 0);
        gen_assign_inputs : for i in 0 to INT_QUBITS_CNT-1 generate
            slv_input_pads_v(i) <= input_pads(i*2);
            slv_input_pads_h(i) <= input_pads(i*2 + 1);
        end generate;


        -- Reassign i_enable_feedforward, synchronize with dsp_clk
        slv_enable_feedforward_to_cdcc(0) <= i_enable_feedforward;
        inst_nff_cdcc_enable_feedforward : entity lib_src.nff_cdcc(rtl)
            generic map (
                BYPASS => false,
                ASYNC_FLOPS_CNT => 2,
                DATA_WIDTH => 1,
                FLOPS_BEFORE_CROSSING_CNT => 1,
                WR_READY_DEASSERTED_CYCLES => 1
            )
            port map (
                -- Write ports
                clk_write => readout_clk,
                wr_en     => '1',
                wr_data   => slv_enable_feedforward_to_cdcc,
                wr_ready  => open,

                -- Read ports
                clk_read => dsp_clk,
                rd_valid => open,
                rd_data  => slv_enable_feedforward
            );

        -- Reassign i_rand_feedforward, synchronize with dsp_clk
        slv_rand_feedforward_to_cdcc <= i_rand_feedforward;
        inst_nff_cdcc_rand_feedforward : entity lib_src.nff_cdcc(rtl)
            generic map (
                BYPASS => false,
                ASYNC_FLOPS_CNT => 2,
                DATA_WIDTH => INT_QUBITS_CNT,
                FLOPS_BEFORE_CROSSING_CNT => 1,
                WR_READY_DEASSERTED_CYCLES => 1
            )
            port map (
                -- Write ports
                clk_write => readout_clk,
                wr_en     => '1',
                wr_data   => slv_rand_feedforward_to_cdcc,
                wr_ready  => open,

                -- Read ports
                clk_read => dsp_clk,
                rd_valid => open,
                rd_data  => slv_rand_feedforward
            );


        -- The order is given by physical pins, defines the logic of the 'clk_acq_preload_indices' function
        slv_mmcm_not_locked(2) <= not mmcm_locked;
        slv_mmcm_not_locked(1) <= not mmcm_locked;
        slv_mmcm_not_locked(0) <= not mmcm_locked;


        -- LEDs
        led(3) <= not mmcm_locked;
        led(2) <= not slv_enable_feedforward(0);
        led(1) <= '1';
        led(0) <= not sl_led_fifo_full_latched;


        -- Instances of Clock Synthesizers (Verilog)
        -- NEW
        inst_clock_synthesizer : clock_synthesizer
        generic map (
            INT_SELECT_PRIMITIVE => -1,     -- 0=PLL; else MMCM (default)

            INT_BUF_CLKFB => -1,            -- 0=No Buffer; 1=BUFH; 2=BUFIO; 3=BUFR; else=BUFG (default)
            INT_BUF_OUT0 => -1, --DoNotTouch-- 0=No Buffer; 1=BUFH; 2=BUFIO; 3=BUFR; else=BUFG (default)
            INT_BUF_OUT1 => -1,
            INT_BUF_OUT2 => -1,
            INT_BUF_OUT3 => -1,
            INT_BUF_OUT4 => -1,
            INT_BUF_OUT5 => -1,
            INT_BUF_OUT6 => -1,             -- (not available in PLL)
            INT_BUF_OUTB0 => 0,             -- (not available in PLL, no access to BUFIO) 0=No Buffer (default); 1=BUFH; 2=BUFIO; 3=BUFR; else=BUFG
            INT_BUF_OUTB1 => 0,             -- (not available in PLL, no access to BUFIO)
            INT_BUF_OUTB2 => 0,             -- (not available in PLL, no access to BUFIO)
            INT_BUF_OUTB3 => 0,             -- (not available in PLL, no access to BUFIO)

            INT_BANDWIDTH => 1,             -- Target bandwidth and performance: 0=LOW, 1=HIGH, others=OPTIMIZED (affects jitter, phase margin)
            INT_COMPENSATION => 0,          -- Delay Compensation: 0=ZHOLD, 1=BUF_IN, 2=EXTERNAL, 3=INTERNAL

            IF_CLKIN1_DIFF => 1,            -- Set to 1 if input clock is differential, else 0
            REAL_CLKIN1_PKPK_JITTER_PS => 20.0, -- Available in Clocking Oscillators Section in online Docs for xem7350

            -- Setup the VCO frequency for the entire device
            REAL_CLKIN1_MHZ => REAL_BOARD_OSC_FREQ_MHZ, -- Input clock frequency in MHz
            INT_VCO_DIVIDE => 1,
            REAL_VCO_MULTIPLY => 6.0,

            REAL_DIVIDE_OUT0 => 3.0, -- 400
            -- REAL_DIVIDE_OUT0 => 2.4,
            INT_DIVIDE_OUT1 => 40,
            INT_DIVIDE_OUT2 => 2,
            INT_DIVIDE_OUT3 => 2,
            INT_DIVIDE_OUT4 => 4,
            INT_DIVIDE_OUT5 => 0,
            INT_DIVIDE_OUT6 => 0,           -- (not available in PLL)

            REAL_DUTY_OUT0 => 0.5,
            REAL_DUTY_OUT1 => 0.2,
            REAL_DUTY_OUT2 => 0.5,
            REAL_DUTY_OUT3 => 0.5,
            REAL_DUTY_OUT4 => 0.5,
            REAL_DUTY_OUT5 => 0.5,
            REAL_DUTY_OUT6 => 0.5,          -- (not available in PLL)

            REAL_PHASE_OUT0 => 0.0,
            REAL_PHASE_OUT1 => 0.0,
            REAL_PHASE_OUT2 => 0.0,
            REAL_PHASE_OUT3 => 90.0,
            REAL_PHASE_OUT4 => 0.0,
            REAL_PHASE_OUT5 => 0.0,
            REAL_PHASE_OUT6 => 0.0,         -- (not available in PLL)

            CLKFBOUT_USE_FINE_PS => 0,      -- Fine Phase Shifting (not available in PLL)
            CLKOUT0_USE_FINE_PS => 0,
            CLKOUT1_USE_FINE_PS => 1,
            CLKOUT2_USE_FINE_PS => 0,
            CLKOUT3_USE_FINE_PS => 0,
            CLKOUT4_USE_FINE_PS => 1,
            CLKOUT5_USE_FINE_PS => 0,
            CLKOUT6_USE_FINE_PS => 0
        ) port map (
            -- Inputs
            in_reset => '0',
            in_clk0_p => sys_clk_p,         -- Has off-chip termination
            in_clk0_n => sys_clk_n,

            -- Fine Phase Shift (not available in PLL)
            in_fineps_clk     => eval_clk,
            in_fineps_incr    => '1', -- Unidirectional shift
            in_fineps_decr    => '0',
            in_fineps_valid   => '1', -- Constantly enabled
            out_fineps_dready => open,

                                      -- Output Freq [MHz] | Phase Offset [Deg]
            out_clkfb => eval_clk,    --            200    |    0
            out_clk0 => dsp_clk,      --            400    |    0
            out_clk1 => apd_emul_clk, --             30    |    0  (variable by fineps)
            out_clk2 => acq_clk0,     --            200    |    0
            out_clk3 => acq_clk90,    --            200    |    90 (fixed)
            out_clk4 => inemul_clk,   --            200    |    0  (variable by fineps)
            out_clk5 => open,
            out_clk6 => open,               -- (not available in PLL)
            out_clkb0 => open,              -- (not available in PLL, no access to BUFIO)
            out_clkb1 => open,              -- (not available in PLL, no access to BUFIO)
            out_clkb2 => open,              -- (not available in PLL, no access to BUFIO)
            out_clkb3 => open,              -- (not available in PLL, no access to BUFIO)
            out_clk0_nobuf => open,          -- Direct outputs from MMCM CLKOUT0-4 pins (no buffers applied)
            out_clk1_nobuf => open,
            out_clk2_nobuf => open,
            out_clk3_nobuf => open,
            out_clk0_inv => open,            -- Inverted positive clocks out_clkx 0-4 through an inverter
            out_clk1_inv => open,
            out_clk2_inv => open,
            out_clk3_inv => open,
            locked => mmcm_locked
        );

        -- Modules be placed to 'X0Y4' bank
        -- IDELAYCTRL:
        -- -> REFCLK = 200 Mhz -> tap delay is 78ps 
        -- -> REFCLK = 300 Mhz -> tap delay is 52ps (unavailable in -1 speed grade FPGAs)
        -- -> REFCLK = 400 Mhz -> tap delay is 39ps (unavailable in -1 speed grade FPGAs)
        -- * maximal precision of REFCLK is +- 10MHz
        -- * module requires 52 ns reset strobe
        inst_SRLC32E_idelayctrl_X0Y4 : SRLC32E
        generic map (
                INIT => X"00000000")
        port map (
                CLK => eval_clk,            -- Clock input
                CE => '1',                  -- Clock enable input
                D => slv_mmcm_not_locked(2),-- SRL data input
                A => "00000",               -- 5-bit shift depth select input
                Q => open,                  -- SRL data output
                Q31 => slv_idelay_rst(2)    -- SRL cascade output pin
        );
        inst_IDELAYCTRL_X0Y4 : IDELAYCTRL
        port map (
            RDY => slv_idelay_rdy(2),  -- 1-bit output: Ready output
            REFCLK => eval_clk,        -- 1-bit input: Reference clock input (must be 200 MHz +- 10 MHz -> 78ps tap delay on an -1 speed grade 7series FPGA)
            RST => slv_idelay_rst(2)   -- 1-bit input: Active high reset input
        );


        -- Modules to be placed to 'X0Y3' bank
        inst_SRLC32E_idelayctrl_X0Y3 : SRLC32E
        generic map (
                INIT => X"00000000")
        port map (
                CLK => eval_clk,            -- Clock input
                CE => '1',                  -- Clock enable input
                D => slv_mmcm_not_locked(1),-- SRL data input
                A => "00000",               -- 5-bit shift depth select input
                Q => open,                  -- SRL data output
                Q31 => slv_idelay_rst(1)    -- SRL cascade output pin
        );
        inst_IDELAYCTRL_X0Y3 : IDELAYCTRL
        port map (
            RDY => slv_idelay_rdy(1),  -- 1-bit output: Ready output
            REFCLK => eval_clk,        -- 1-bit input: Reference clock input (must be 200 MHz +- 10 MHz -> 78ps tap delay on an -1 speed grade 7series FPGA)
            RST => slv_idelay_rst(1)   -- 1-bit input: Active high reset input
        );


        -- Modules to be placed to 'X0Y2' bank
        inst_SRLC32E_idelayctrl_X0Y1 : SRLC32E
        generic map (
                INIT => X"00000000")
        port map (
                CLK => eval_clk,            -- Clock input
                CE => '1',                  -- Clock enable input
                D => slv_mmcm_not_locked(0),-- SRL data input
                A => "00000",               -- 5-bit shift depth select input
                Q => open,                  -- SRL data output
                Q31 => slv_idelay_rst(0)    -- SRL cascade output pin
        );
        inst_IDELAYCTRL_X0Y1 : IDELAYCTRL
        port map (
            RDY => slv_idelay_rdy(0),  -- 1-bit output: Ready output
            REFCLK => eval_clk,        -- 1-bit input: Reference clock input (must be 200 MHz +- 10 MHz -> 78ps tap delay on an -1 speed grade 7series FPGA)
            RST => slv_idelay_rst(0)   -- 1-bit input: Active high reset input
        );



        ---------------------
        -- GFLOW DATA PATH --
        ---------------------
        -- Dedicated Xilinx Input Buffers and Samplers
        gen_emul_false0 : if INT_QUBITS_CNT >= 1 and INT_EMULATE_INPUTS = 0 generate
            -- Target bits that will be connected to the coarse delay compensator
            slv_input_channels(0) <= slv_input_channels_v_iserdese2_2d(0)(3);
            slv_input_channels(1) <= slv_input_channels_h_iserdese2_2d(0)(3);

            inst_xilinx_sdr_sampler_v0 : entity lib_src.xilinx_sdr_sampler(rtl)
            generic map (
                SELECT_PRIMITIVE => 4,            -- 1 = FDRE, 2 = IDDR_2CLK, 3 = ISERDESE2, 4 = ISERDESE2+IDELAYE2, 0 = All (Simulation Purposes)
                -- INT_IDELAY_TAPS => 0,
                INT_IDELAY_TAPS => TAPS_DELAY_COMPENSATION_IDELAY(0)(0), -- NEW
                REAL_IDELAY_REFCLK_FREQUENCY => 200.0
            ) port map (
                -- Clocks
                clk => acq_clk0,     -- 0 degrees phase-shift (always connect)
                clk90 => acq_clk90,  -- 90 degrees phase-shift (only ISERDESE2)
                clk180 => '0',   -- 180 degrees phase-shift (only IDDR_2CLK)
                clk_idelay => '0', -- Clock at a frequency specified by REAL_IDELAY_REFCLK_FREQUENCY

                -- Input Data
                in_pad => slv_input_pads_v(0),   -- FPGA pad (top-level input)
                in_reset_iserdese2 => slv_mmcm_not_locked(BANK_ID(0)),    -- Reset for ISERDESE2 to initialize outputs
                in_enable_iserdese2 => slv_idelay_rdy(BANK_ID(0)),

                -- Output Data
                out_data_fdre => slv_input_channels_v_fdre(0),              -- Data from the FDRE Primitive (maped to IFF)
                out_data_iddr_2clk => slv_input_channels_v_iddr_2clk_2d(0), -- Data from the IDDR_2CLK Primitive
                out_data_iserdese2 => slv_input_channels_v_iserdese2_2d(0)  -- Data from the ISERDESE2 Primitive
            );

            inst_xilinx_sdr_sampler_h0 : entity lib_src.xilinx_sdr_sampler(rtl)
            generic map (
                SELECT_PRIMITIVE => 4,            -- 1 = FDRE, 2 = IDDR_2CLK, 3 = ISERDESE2, 4 = ISERDESE2+IDELAYE2, 0 = All (Simulation Purposes)
                -- #TODO
                -- INT_IDELAY_TAPS => 0,
                INT_IDELAY_TAPS => TAPS_DELAY_COMPENSATION_IDELAY(0)(1), -- NEW
                REAL_IDELAY_REFCLK_FREQUENCY => 200.0
            ) port map (
                -- Clocks
                clk => acq_clk0,     -- 0 degrees phase-shift (always connect)
                clk90 => acq_clk90,  -- 90 degrees phase-shift (only ISERDESE2)
                clk180 => '0',   -- 180 degrees phase-shift (only IDDR_2CLK)
                clk_idelay => '0', -- Clock at a frequency specified by REAL_IDELAY_REFCLK_FREQUENCY

                -- Input Data
                in_pad => slv_input_pads_h(0),   -- FPGA pad (top-level input)

                in_reset_iserdese2 => slv_mmcm_not_locked(BANK_ID(0)),    -- Reset for ISERDESE2 to initialize outputs
                in_enable_iserdese2 => slv_idelay_rdy(BANK_ID(0)),

                -- Output Data
                out_data_fdre => slv_input_channels_h_fdre(0),              -- Data from the FDRE Primitive (maped to IFF)
                out_data_iddr_2clk => slv_input_channels_h_iddr_2clk_2d(0), -- Data from the IDDR_2CLK Primitive
                out_data_iserdese2 => slv_input_channels_h_iserdese2_2d(0)  -- Data from the ISERDESE2 Primitive
            );
        end generate;

        gen_emul_false1 : if INT_QUBITS_CNT >= 2 and INT_EMULATE_INPUTS = 0 generate
            -- Target bits that will be connected to the coarse delay compensator
            slv_input_channels(2) <= slv_input_channels_v_iserdese2_2d(1)(3);
            slv_input_channels(3) <= slv_input_channels_h_iserdese2_2d(1)(3);

            inst_xilinx_sdr_sampler_v1 : entity lib_src.xilinx_sdr_sampler(rtl)
            generic map (
                SELECT_PRIMITIVE => 4,            -- 1 = FDRE, 2 = IDDR_2CLK, 3 = ISERDESE2, 4 = ISERDESE2+IDELAYE2, 0 = All (Simulation Purposes)
                -- INT_IDELAY_TAPS => 0,
                INT_IDELAY_TAPS => TAPS_DELAY_COMPENSATION_IDELAY(1)(0),
                REAL_IDELAY_REFCLK_FREQUENCY => 200.0
            ) port map (
                -- Clocks
                clk => acq_clk0,     -- 0 degrees phase-shift (always connect)
                clk90 => acq_clk90,  -- 90 degrees phase-shift (only ISERDESE2)
                clk180 => '0',                   -- 180 degrees phase-shift (only IDDR_2CLK)
                clk_idelay => '0', -- Clock at a frequency specified by REAL_IDELAY_REFCLK_FREQUENCY

                -- Input Data
                in_pad => slv_input_pads_v(1),   -- FPGA pad (top-level input)

                in_reset_iserdese2 => slv_mmcm_not_locked(BANK_ID(1)),  -- Reset ISERDESE2 to initialize outputs
                in_enable_iserdese2 => slv_idelay_rdy(BANK_ID(1)),

                -- Output Data
                out_data_fdre => slv_input_channels_v_fdre(1),              -- Data from the FDRE Primitive (maped to IFF)
                out_data_iddr_2clk => slv_input_channels_v_iddr_2clk_2d(1), -- Data from the IDDR_2CLK Primitive
                out_data_iserdese2 => slv_input_channels_v_iserdese2_2d(1)  -- Data from the ISERDESE2 Primitive
            );

            inst_xilinx_sdr_sampler_h1 : entity lib_src.xilinx_sdr_sampler(rtl)
            generic map (
                SELECT_PRIMITIVE => 4,            -- 1 = FDRE, 2 = IDDR_2CLK, 3 = ISERDESE2, 4 = ISERDESE2+IDELAYE2, 0 = All (Simulation Purposes)
                -- INT_IDELAY_TAPS => 0,
                INT_IDELAY_TAPS => TAPS_DELAY_COMPENSATION_IDELAY(1)(1),
                REAL_IDELAY_REFCLK_FREQUENCY => 200.0
            ) port map (
                -- Clocks
                clk => acq_clk0,     -- 0 degrees phase-shift (always connect)
                clk90 => acq_clk90,  -- 90 degrees phase-shift (only ISERDESE2)
                clk180 => '0',   -- 180 degrees phase-shift (only IDDR_2CLK)
                clk_idelay => '0', -- Clock at a frequency specified by REAL_IDELAY_REFCLK_FREQUENCY

                -- Input Data
                in_pad => slv_input_pads_h(1),    -- FPGA pad (top-level input)

                in_reset_iserdese2 => slv_mmcm_not_locked(BANK_ID(1)),   -- Reset ISERDESE2 to initialize outputs
                in_enable_iserdese2 => slv_idelay_rdy(BANK_ID(1)),

                -- Output Data
                out_data_fdre => slv_input_channels_h_fdre(1),              -- Data from the FDRE Primitive (maped to IFF)
                out_data_iddr_2clk => slv_input_channels_h_iddr_2clk_2d(1), -- Data from the IDDR_2CLK Primitive
                out_data_iserdese2 => slv_input_channels_h_iserdese2_2d(1)  -- Data from the ISERDESE2 Primitive
            );
        end generate;

        gen_emul_false2 : if INT_QUBITS_CNT >= 3 and INT_EMULATE_INPUTS = 0 generate
            -- Target bits that will be connected to the coarse delay compensator
            slv_input_channels(4) <= slv_input_channels_v_iserdese2_2d(2)(3);
            slv_input_channels(5) <= slv_input_channels_h_iserdese2_2d(2)(3);

            inst_xilinx_sdr_sampler_v2 : entity lib_src.xilinx_sdr_sampler(rtl)
            generic map (
                SELECT_PRIMITIVE => 4,            -- 1 = FDRE, 2 = IDDR_2CLK, 3 = ISERDESE2, 4 = ISERDESE2+IDELAYE2, 0 = All (Simulation Purposes)
                -- INT_IDELAY_TAPS => 0,
                INT_IDELAY_TAPS => TAPS_DELAY_COMPENSATION_IDELAY(2)(0),
                REAL_IDELAY_REFCLK_FREQUENCY => 200.0
            ) port map (
                -- Clocks
                clk => acq_clk0,     -- 0 degrees phase-shift (always connect)
                clk90 => acq_clk90,  -- 90 degrees phase-shift (only ISERDESE2)
                clk180 => '0',   -- 180 degrees phase-shift (only IDDR_2CLK)
                clk_idelay => '0', -- Clock at a frequency specified by REAL_IDELAY_REFCLK_FREQUENCY

                -- Input Data
                in_pad => slv_input_pads_v(2),   -- FPGA pad (top-level input)

                in_reset_iserdese2 => slv_mmcm_not_locked(BANK_ID(2)),    -- Reset for ISERDESE2 to initialize outputs
                in_enable_iserdese2 => slv_idelay_rdy(BANK_ID(2)),

                -- Output Data
                out_data_fdre => slv_input_channels_v_fdre(2),              -- Data from the FDRE Primitive (maped to IFF)
                out_data_iddr_2clk => slv_input_channels_v_iddr_2clk_2d(2), -- Data from the IDDR_2CLK Primitive
                out_data_iserdese2 => slv_input_channels_v_iserdese2_2d(2)  -- Data from the ISERDESE2 Primitive
            );

            inst_xilinx_sdr_sampler_h2 : entity lib_src.xilinx_sdr_sampler(rtl)
            generic map (
                SELECT_PRIMITIVE => 4,            -- 1 = FDRE, 2 = IDDR_2CLK, 3 = ISERDESE2, 4 = ISERDESE2+IDELAYE2, 0 = All (Simulation Purposes)
                -- INT_IDELAY_TAPS => 0,
                INT_IDELAY_TAPS => TAPS_DELAY_COMPENSATION_IDELAY(2)(1),
                REAL_IDELAY_REFCLK_FREQUENCY => 200.0
            ) port map (
                -- Clocks
                clk => acq_clk0,     -- 0 degrees phase-shift (always connect)
                clk90 => acq_clk90,  -- 90 degrees phase-shift (only ISERDESE2)
                clk180 => '0',   -- 180 degrees phase-shift (only IDDR_2CLK)
                clk_idelay => '0', -- Clock at a frequency specified by REAL_IDELAY_REFCLK_FREQUENCY

                -- Input Data
                in_pad => slv_input_pads_h(2),  -- FPGA pad (top-level input)

                in_reset_iserdese2 => slv_mmcm_not_locked(BANK_ID(2)),   -- Reset for ISERDESE2 to initialize outputs
                in_enable_iserdese2 => slv_idelay_rdy(BANK_ID(2)),

                -- Output Data
                out_data_fdre => slv_input_channels_h_fdre(2),              -- Data from the FDRE Primitive (maped to IFF)
                out_data_iddr_2clk => slv_input_channels_h_iddr_2clk_2d(2), -- Data from the IDDR_2CLK Primitive
                out_data_iserdese2 => slv_input_channels_h_iserdese2_2d(2)  -- Data from the ISERDESE2 Primitive
            );
        end generate;

        gen_emul_false3 : if INT_QUBITS_CNT >= 4 and INT_EMULATE_INPUTS = 0 generate
            -- Target bits that will be connected to the coarse delay compensator
            slv_input_channels(6) <= slv_input_channels_v_iserdese2_2d(3)(3);
            slv_input_channels(7) <= slv_input_channels_h_iserdese2_2d(3)(3);

            inst_xilinx_sdr_sampler_v3 : entity lib_src.xilinx_sdr_sampler(rtl)
            generic map (
                SELECT_PRIMITIVE => 4,            -- 1 = FDRE, 2 = IDDR_2CLK, 3 = ISERDESE2, 4 = ISERDESE2+IDELAYE2, 0 = All (Simulation Purposes)
                -- INT_IDELAY_TAPS => 0,
                INT_IDELAY_TAPS => TAPS_DELAY_COMPENSATION_IDELAY(3)(0),
                REAL_IDELAY_REFCLK_FREQUENCY => 200.0
            ) port map (
                -- Clocks
                clk => acq_clk0,     -- 0 degrees phase-shift (always connect)
                clk90 => acq_clk90,  -- 90 degrees phase-shift (only ISERDESE2)
                clk180 => '0',   -- 180 degrees phase-shift (only IDDR_2CLK)
                clk_idelay => '0', -- Clock at a frequency specified by REAL_IDELAY_REFCLK_FREQUENCY

                -- Input Data
                in_pad => slv_input_pads_v(3),  -- FPGA pad (top-level input)

                in_reset_iserdese2 => slv_mmcm_not_locked(BANK_ID(3)),    -- Reset for ISERDESE2 to initialize outputs
                in_enable_iserdese2 => slv_idelay_rdy(BANK_ID(3)),

                -- Output Data
                out_data_fdre => slv_input_channels_v_fdre(3),              -- Data from the FDRE Primitive (maped to IFF)
                out_data_iddr_2clk => slv_input_channels_v_iddr_2clk_2d(3), -- Data from the IDDR_2CLK Primitive
                out_data_iserdese2 => slv_input_channels_v_iserdese2_2d(3)  -- Data from the ISERDESE2 Primitive
            );

            inst_xilinx_sdr_sampler_h3 : entity lib_src.xilinx_sdr_sampler(rtl)
            generic map (
                SELECT_PRIMITIVE => 4,            -- 1 = FDRE, 2 = IDDR_2CLK, 3 = ISERDESE2, 4 = ISERDESE2+IDELAYE2, 0 = All (Simulation Purposes)
                -- INT_IDELAY_TAPS => 0,
                INT_IDELAY_TAPS => TAPS_DELAY_COMPENSATION_IDELAY(3)(1),
                REAL_IDELAY_REFCLK_FREQUENCY => 200.0
            ) port map (
                -- Clocks
                clk => acq_clk0,     -- 0 degrees phase-shift (always connect)
                clk90 => acq_clk90,  -- 90 degrees phase-shift (only ISERDESE2)
                clk180 => '0',   -- 180 degrees phase-shift (only IDDR_2CLK)
                clk_idelay => '0', -- Clock at a frequency specified by REAL_IDELAY_REFCLK_FREQUENCY
                
                -- Input Data
                in_pad => slv_input_pads_h(3),  -- FPGA pad (top-level input)

                in_reset_iserdese2 => slv_mmcm_not_locked(BANK_ID(3)),  -- Reset for ISERDESE2 to initialize outputs
                in_enable_iserdese2 => slv_idelay_rdy(BANK_ID(3)),

                -- Output Data
                out_data_fdre => slv_input_channels_h_fdre(3),              -- Data from the FDRE Primitive (maped to IFF)
                out_data_iddr_2clk => slv_input_channels_h_iddr_2clk_2d(3), -- Data from the IDDR_2CLK Primitive
                out_data_iserdese2 => slv_input_channels_h_iserdese2_2d(3)  -- Data from the ISERDESE2 Primitive
            );
        end generate;

        gen_emul_false4 : if INT_QUBITS_CNT >= 5 and INT_EMULATE_INPUTS = 0 generate
            -- Target bits that will be connected to the coarse delay compensator
            slv_input_channels(8) <= slv_input_channels_v_iserdese2_2d(4)(3);
            slv_input_channels(9) <= slv_input_channels_h_iserdese2_2d(4)(3);

            inst_xilinx_sdr_sampler_v4 : entity lib_src.xilinx_sdr_sampler(rtl)
            generic map (
                SELECT_PRIMITIVE => 4,            -- 1 = FDRE, 2 = IDDR_2CLK, 3 = ISERDESE2, 4 = ISERDESE2+IDELAYE2, 0 = All (Simulation Purposes)
                -- INT_IDELAY_TAPS => 0,
                INT_IDELAY_TAPS => TAPS_DELAY_COMPENSATION_IDELAY(4)(0),
                REAL_IDELAY_REFCLK_FREQUENCY => 200.0
            ) port map (
                -- Clocks
                clk => acq_clk0,     -- 0 degrees phase-shift (always connect)
                clk90 => acq_clk90,  -- 90 degrees phase-shift (only ISERDESE2)
                clk180 => '0',   -- 180 degrees phase-shift (only IDDR_2CLK)
                clk_idelay => '0', -- Clock at a frequency specified by REAL_IDELAY_REFCLK_FREQUENCY
                
                -- Input Data
                in_pad => slv_input_pads_v(4),  -- FPGA pad (top-level input)

                in_reset_iserdese2 => slv_mmcm_not_locked(BANK_ID(4)),  -- Reset for ISERDESE2 to initialize outputs
                in_enable_iserdese2 => slv_idelay_rdy(BANK_ID(4)),

                -- Output Data
                out_data_fdre => slv_input_channels_v_fdre(4),              -- Data from the FDRE Primitive (maped to IFF)
                out_data_iddr_2clk => slv_input_channels_v_iddr_2clk_2d(4), -- Data from the IDDR_2CLK Primitive
                out_data_iserdese2 => slv_input_channels_v_iserdese2_2d(4)  -- Data from the ISERDESE2 Primitive
            );

            inst_xilinx_sdr_sampler_h4 : entity lib_src.xilinx_sdr_sampler(rtl)
            generic map (
                SELECT_PRIMITIVE => 4,            -- 1 = FDRE, 2 = IDDR_2CLK, 3 = ISERDESE2, 4 = ISERDESE2+IDELAYE2, 0 = All (Simulation Purposes)
                -- INT_IDELAY_TAPS => 0,
                INT_IDELAY_TAPS => TAPS_DELAY_COMPENSATION_IDELAY(4)(1),
                REAL_IDELAY_REFCLK_FREQUENCY => 200.0
            ) port map (
                -- Clocks
                clk => acq_clk0,     -- 0 degrees phase-shift (always connect)
                clk90 => acq_clk90,  -- 90 degrees phase-shift (only ISERDESE2)
                clk180 => '0',   -- 180 degrees phase-shift (only IDDR_2CLK)
                clk_idelay => '0', -- Clock at a frequency specified by REAL_IDELAY_REFCLK_FREQUENCY
                
                -- Input Data
                in_pad => slv_input_pads_h(4),  -- FPGA pad (top-level input)

                in_reset_iserdese2 => slv_mmcm_not_locked(BANK_ID(4)),   -- Reset for ISERDESE2 to initialize outputs
                in_enable_iserdese2 => slv_idelay_rdy(BANK_ID(4)),

                -- Output Data
                out_data_fdre => slv_input_channels_h_fdre(4),              -- Data from the FDRE Primitive (maped to IFF)
                out_data_iddr_2clk => slv_input_channels_h_iddr_2clk_2d(4), -- Data from the IDDR_2CLK Primitive
                out_data_iserdese2 => slv_input_channels_h_iserdese2_2d(4)  -- Data from the ISERDESE2 Primitive
            );
        end generate;

        gen_emul_false5 : if INT_QUBITS_CNT >= 6 and INT_EMULATE_INPUTS = 0 generate
            -- Target bits that will be connected to the coarse delay compensator
            slv_input_channels(10) <= slv_input_channels_v_iserdese2_2d(5)(3);
            slv_input_channels(11) <= slv_input_channels_h_iserdese2_2d(5)(3);

            inst_xilinx_sdr_sampler_v5 : entity lib_src.xilinx_sdr_sampler(rtl)
            generic map (
                SELECT_PRIMITIVE => 4,            -- 1 = FDRE, 2 = IDDR_2CLK, 3 = ISERDESE2, 4 = ISERDESE2+IDELAYE2, 0 = All (Simulation Purposes)
                -- INT_IDELAY_TAPS => 0,
                INT_IDELAY_TAPS => TAPS_DELAY_COMPENSATION_IDELAY(5)(0),
                REAL_IDELAY_REFCLK_FREQUENCY => 200.0
            ) port map (
                -- Clocks
                clk => acq_clk0,     -- 0 degrees phase-shift (always connect)
                clk90 => acq_clk90,  -- 90 degrees phase-shift (only ISERDESE2)
                clk180 => '0',   -- 180 degrees phase-shift (only IDDR_2CLK)
                clk_idelay => '0', -- Clock at a frequency specified by REAL_IDELAY_REFCLK_FREQUENCY
                
                -- Input Data
                in_pad => slv_input_pads_v(5),  -- FPGA pad (top-level input)

                in_reset_iserdese2 => slv_mmcm_not_locked(BANK_ID(5)),  -- Reset for ISERDESE2 to initialize outputs
                in_enable_iserdese2 => slv_idelay_rdy(BANK_ID(5)),

                -- Output Data
                out_data_fdre => slv_input_channels_v_fdre(5),              -- Data from the FDRE Primitive (maped to IFF)
                out_data_iddr_2clk => slv_input_channels_v_iddr_2clk_2d(5), -- Data from the IDDR_2CLK Primitive
                out_data_iserdese2 => slv_input_channels_v_iserdese2_2d(5)  -- Data from the ISERDESE2 Primitive
            );

            inst_xilinx_sdr_sampler_h5 : entity lib_src.xilinx_sdr_sampler(rtl)
            generic map (
                SELECT_PRIMITIVE => 4,            -- 1 = FDRE, 2 = IDDR_2CLK, 3 = ISERDESE2, 4 = ISERDESE2+IDELAYE2, 0 = All (Simulation Purposes)
                -- INT_IDELAY_TAPS => 0,
                INT_IDELAY_TAPS => TAPS_DELAY_COMPENSATION_IDELAY(5)(1),
                REAL_IDELAY_REFCLK_FREQUENCY => 200.0
            ) port map (
                -- Clocks
                clk => acq_clk0,     -- 0 degrees phase-shift (always connect)
                clk90 => acq_clk90,  -- 90 degrees phase-shift (only ISERDESE2)
                clk180 => '0',   -- 180 degrees phase-shift (only IDDR_2CLK)
                clk_idelay => '0', -- Clock at a frequency specified by REAL_IDELAY_REFCLK_FREQUENCY
                
                -- Input Data
                in_pad => slv_input_pads_h(5),  -- FPGA pad (top-level input)

                in_reset_iserdese2 => slv_mmcm_not_locked(BANK_ID(5)),   -- Reset for ISERDESE2 to initialize outputs
                in_enable_iserdese2 => slv_idelay_rdy(BANK_ID(5)),

                -- Output Data
                out_data_fdre => slv_input_channels_h_fdre(5),              -- Data from the FDRE Primitive (maped to IFF)
                out_data_iddr_2clk => slv_input_channels_h_iddr_2clk_2d(5), -- Data from the IDDR_2CLK Primitive
                out_data_iserdese2 => slv_input_channels_h_iserdese2_2d(5)  -- Data from the ISERDESE2 Primitive
            );
        end generate;


        -- If Necessary, uncomment this input emulator for evaluation
        -- Instance Clock Synthesizer (Verilog) - simulate non-phase-locked pulse detection
        gen_emul_true : if INT_EMULATE_INPUTS /= 0 generate
            inst_lfsr_inemul : entity lib_src.lfsr_inemul(rtl)
            generic map (
                RST_VAL               => RST_VAL,
                SYMBOL_WIDTH          => 12, -- MAX 20
                -- PRIM_POL_INT_VAL      => 4179,
                GF_SEED               => 1,
                DATA_PULLDOWN_ENABLE  => true,
                PULLDOWN_CYCLES       => 2 -- min 2
            )
            port map (
                clk => inemul_clk,
                rst => '0',

                ready => open,
                data_out => slv_input_channels(12-1 downto 0),
                valid_out => open
            );
        end generate;


        -- FIFO Read Reset: readout_clk domain:
        --     RST must be held high for at least five RDCLK clock cycles, 
        --     and RDEN must be low before RST becomes active high, 
        --     and RDEN remains low during this reset cycle.
        -- Ensure the strobe is longer than the time that takes MMCM to lock (~260.1 ns)
        -- NEW
        inst_reset_fifo_readout_clk : entity lib_src.reset(rtl)
        generic map (
            -- 10.02 * 2^RST_STROBE_COUNTER_WIDTH / 2 = strobe duration (ns)
            RST_STROBE_COUNTER_WIDTH => 6 -- = 320.64 ns (min value, should be lower by -1 than the above reset module's value)
        )
        port map (
            CLK     => readout_clk,
            IN_RST  => '1',             -- On Power-up
            OUT_RST => sl_rst_readout_clk
        );


        -- FIFO Write Reset: eval_clk domain:
        -- RST must be held high for at least five WRCLK clock cycles, 
        --     and WREN must be low before RST becomes active high, 
        --     and WREN remains low during this reset cycle.
        -- Ensure the strobe is longer than the time that takes MMCM to lock (~260.1 ns)
        -- NEW
        inst_reset_fifo_eval_clk : entity lib_src.reset(rtl)
        generic map (
            -- 5 * 2^RST_STROBE_COUNTER_WIDTH / 2 = strobe duration (ns)
            RST_STROBE_COUNTER_WIDTH => 7 -- 320 ns
        )
        port map (
            CLK     => eval_clk,
            IN_RST  => '1',             -- On Power-up
            OUT_RST => sl_rst_eval_clk
        );


        -- FIFO Read Reset: dsp_clk domain:
        --     RST must be held high for at least five RDCLK clock cycles, 
        --     and RDEN must be low before RST becomes active high, 
        --     and RDEN remains low during this reset cycle.
        -- Ensure the strobe is longer than the time that takes MMCM to lock (~260.1 ns)
        -- NEW
        inst_reset_fifo_dsp_clk : entity lib_src.reset(rtl)
        generic map (
            -- 2.5 * 2^RST_STROBE_COUNTER_WIDTH / 2 = strobe duration (ns)
            RST_STROBE_COUNTER_WIDTH => 9 -- = 640 ns (should be HIGHER than the strobe duration above)
        )
        port map (
            CLK     => dsp_clk,
            IN_RST  => '1',             -- On Power-up
            OUT_RST => sl_rst_dsp_clk
        );


        ---------------------------------------------
        -- FEEDFORWARD Data Path: Data Readout
        ---------------------------------------------
        -- Readout with FIFO and CSV read instructions
        gen_map_bits : for i in 0 to INT_QUBITS_CNT-1 generate
            slv_alpha_buffer_transferred_2d(i)(0) <= slv_sx_buffer_transferred(i);
            slv_modulo_buffer_transferred_2d(i)(0) <= slv_sz_buffer_transferred(i);
        end generate;
        
        inst_csv_readout : entity lib_src.csv_readout(rtl)
        generic map (
            INT_QUBITS_CNT => INT_QUBITS_CNT,
            CLK_HZ => REAL_CLK_EVAL_HZ,
            -- REGULAR_SAMPLER_SECONDS => 5.0e-6,  -- Change this value to alter the frequency of regular reporting
            -- REGULAR_SAMPLER_SECONDS_2 => 5.0e-6 -- Change this value to alter the frequency of regular reporting
            REGULAR_SAMPLER_SECONDS => 1.0,  -- Change this value to alter the frequency of regular reporting
            REGULAR_SAMPLER_SECONDS_2 => 1.0 -- Change this value to alter the frequency of regular reporting
        ) port map (
            -- Reset
            wr_rst => sl_rst_eval_clk,
            rd_rst => sl_rst_readout_clk,

            -- Write endpoint signals
            wr_sys_clk => eval_clk,

            wr_photon_losses => slv_photon_losses,
            wr_channels_detections => slv_channels_detections_cntr,
            wr_valid_feedfwd_success_done => sl_feedfwd_success_done_transferred,
            wr_data_qubit_buffer => slv_qubit_buffer_transferred_2d,
            wr_data_time_stamp_buffer => slv_time_stamp_buffer_transferred_2d,
            wr_data_alpha_buffer => slv_alpha_buffer_transferred_2d, -- Sx
            wr_data_random_buffer => slv_random_buffer_transferred_2d,
            wr_data_modulo_buffer => slv_modulo_buffer_transferred_2d, -- Sz
            wr_data_actual_gflow_buffer => slv_actual_gflow_buffer_transferred, -- Sz

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


        ---------------------------------------------------
        -- FEEDFORWARD Data Path: Coarse Delay Compensation
        ---------------------------------------------------
        -- Input metastability filter and H/V photon delay compensation
        slv_input_channels_donttouch(INT_QUBITS_CNT*2-1 downto 0) <= slv_input_channels(INT_QUBITS_CNT*2-1 downto 0);
        gen_photon_delay_compensation : for i in 0 to INT_QUBITS_CNT-1 generate
            inst_photon_delay_compensation : entity lib_src.delay_compensation(rtl)
            generic map (
                RST_VAL                   => RST_VAL,
                PATTERN_WIDTH             => PATTERN_WIDTH,
                BUFFER_PATTERN            => BUFFER_PATTERN,
                CLK_HZ                    => REAL_CLK_ACQ_HZ,

                DETECTOR_ACTIVE_PERIOD_NS => DETECTOR_ACTIVE_PERIOD_NS,
                DETECTOR_DEAD_PERIOD_NS   => DETECTOR_DEAD_PERIOD_NS,

                TOLERANCE_KEEP_FASTER_BIT_CYCLES => TOLERANCE_KEEP_FASTER_BIT_CYCLES,
                IGNORE_CYCLES_AFTER_TIMEUP => IGNORE_CYCLES_AFTER_TIMEUP,

                PHOTON_H_DELAY_NS => PHOTON_XH_DELAY_NS(i),
                PHOTON_V_DELAY_NS => PHOTON_XV_DELAY_NS(i)
            )
            port map (
                clk => acq_clk0,
                rst => '0',
                noisy_channels_in => slv_input_channels_donttouch((i+1)*2-1 downto (i*2)),

                qubit_valid => s_valid_qubits_stable_to_cdcc(i),
                qubit_compensated => s_stable_channels_to_cdcc((i+1)*2-1 downto (i*2)),

                channels_redge => s_channels_redge_to_cdcc((i+1)*2-1 downto (i*2))
            );

        end generate;


        ----------------------------------------------------
        -- FEEDFORWARD Data Path: CDCC: Inputs -> Controller
        ----------------------------------------------------
        -- n-FF CDCC (Cross Domain Crossing Circuit)
        gen_nff_cdcc_sysclk : for i in 0 to INT_QUBITS_CNT-1 generate
            slv_cdcc_rd_valid_to_fsm(i) <= slv_cdcc_rd_qubits_to_fsm((i+1)*2-1) or slv_cdcc_rd_qubits_to_fsm(i*2);
            inst_nff_cdcc_cntcross_samplclk_bit1 : entity lib_src.nff_cdcc_flag(rtl)
            generic map (
                BYPASS => CDCC_BYPASS,
                ASYNC_FLOPS_CNT => 2,
                FLOPS_BEFORE_CROSSING_CNT => 1,
                -- FLOPS_BEFORE_CROSSING_CNT => 2,
                WR_READY_DEASSERTED_CYCLES => 4
            )
            port map (
                clk_write => acq_clk0,
                wr_en => s_stable_channels_to_cdcc((i+1)*2-1),
                wr_ready => open,

                -- dsp_clk
                clk_read => dsp_clk,
                rd_valid => slv_cdcc_rd_qubits_to_fsm((i+1)*2-1)
            );

            inst_nff_cdcc_cntcross_samplclk_bit2 : entity lib_src.nff_cdcc_flag(rtl)
            generic map (
                BYPASS => CDCC_BYPASS,
                ASYNC_FLOPS_CNT => 2,
                FLOPS_BEFORE_CROSSING_CNT => 1,
                -- FLOPS_BEFORE_CROSSING_CNT => 2,
                WR_READY_DEASSERTED_CYCLES => 4
            )
            port map (
                clk_write => acq_clk0,
                wr_en => s_stable_channels_to_cdcc(i*2),
                wr_ready => open,

                -- dsp_clk
                clk_read => dsp_clk,
                rd_valid => slv_cdcc_rd_qubits_to_fsm(i*2)
            );
        end generate;


        ---------------------------------------------------
        -- FEEDFORWARD Data Path: Flow Ambiguity Controller
        ---------------------------------------------------
        -- G-Flow Protocol FSM (path delay: +1)
        inst_fsm_gflow : entity lib_src.fsm_gflow(rtl)
        generic map (
            INT_FEEDFWD_PROGRAMMING => INT_FEEDFWD_PROGRAMMING,
            RST_VAL                 => RST_VAL,
            CLK_HZ                  => REAL_CLK_DSP_HZ,
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
            INT_NUMBER_OF_GFLOWS    => INT_NUMBER_OF_GFLOWS,
            GFLOW_NUMBER            => INT_GFLOW_NUMBER
        )
        port map (
            clk                       => dsp_clk,
            rst                       => sl_rst_dsp_clk,
            enable                    => slv_enable_feedforward(0),

            i_random_string           => slv_rand_feedforward,

            qubits_sampled_valid      => slv_cdcc_rd_valid_to_fsm,
            qubits_sampled            => slv_cdcc_rd_qubits_to_fsm,

            o_feedforward_pulse       => slv_feedforward_pulse,
            o_feedforward_pulse_trigger => slv_feedforward_pulse_trigger,

            o_unsuccessful_qubits     => slv_photon_losses_to_cdcc(INT_QUBITS_CNT-2 downto 0),

            feedfwd_success_flag      => sl_feedfwd_success_flag,
            feedfwd_start             => sl_feedfwd_start,
            qubit_buffer              => slv_qubit_buffer_2d,
            time_stamp_buffer         => slv_time_stamp_buffer_2d,
            random_buffer             => slv_random_buffer_2d,
            sx_buffer                 => slv_sx_buffer,
            sz_buffer                 => slv_sz_buffer,
            actual_gflow_buffer       => slv_actual_gflow_buffer,

            actual_qubit_valid        => sl_actual_qubit_valid,
            actual_qubit              => slv_actual_qubit,
            state_feedfwd             => state_feedfwd,
            eom_ctrl_pulse_ready      => eom_ctrl_pulse_ready_delayed(0),
            o_sx_next                 => slv_o_sx_next_to_math
        );



        --------------------------------------------------
        -- FEEDFORWARD Data Path: Pseudornd. Bit Generator
        --------------------------------------------------
        -- Pseudorandom number generator outputting bit by bit (on background)
        inst_lfsr_bitgen : entity lib_src.lfsr_bitgen(rtl)
        generic map (
            RST_VAL          => RST_VAL,
            PRIM_POL_INT_VAL => PRIM_POL_INT_VAL,
            SYMBOL_WIDTH     => SYMBOL_WIDTH,
            GF_SEED          => GF_SEED
        )
        port map (
            CLK      => dsp_clk,
            RST      => '0',
            RAND_BIT => sl_pseudorandom_to_math
        );



        -----------------------------------------------
        -- FEEDFORWARD Data Path: Functional Dependence
        -----------------------------------------------
        -- Additional Math block (path delay+1 or +2)
        -- inst_alu_gflow : entity lib_src.alu_gflow(rtl)
        -- generic map (
        --     RST_VAL => RST_VAL,
        --     QUBITS_CNT => INT_QUBITS_CNT,
        --     SYNCH_FACTORS_CALCULATION => true  -- +1 delay if true
        -- )
        -- port map (
        --     CLK             => dsp_clk,
        --     RST             => '0',
        --     QUBIT_VALID     => sl_actual_qubit_valid,
        --     STATE_QUBIT     => state_gflow,
        --     S_X             => slv_sx_sz_to_math(0), -- X correction (EOM control)
        --     S_Z             => slv_sx_sz_to_math(1), -- Z correction (masking)
        --     ALPHA_POSITIVE  => slv_alpha_to_math,
        --     RAND_BIT        => sl_pseudorandom_to_math,
        --     RANDOM_BUFFER   => slv_random_buffer_2d,
        --     MODULO_BUFFER   => slv_modulo_buffer_2d,
        --     DATA_MODULO_OUT => slv_math_data_modulo,
        --     DATA_VALID      => sl_math_data_valid
        -- );
        


        ------------------------------------------------
        -- FEEDFORWARD Data Path: CDCC: Gflow -> Readout
        ------------------------------------------------
        -- CDCC Data transfer to slower readout clock domain
        -- Success Flag Transfer
        inst_shiftreg_queue_success_flag : entity lib_src.shiftreg_queue_shifter(rtl)
        generic map (
            REAL_CLK_HZ => REAL_CLK_DSP_HZ,
            INT_DATA_WIDTH => 1,
            INT_QUEUE_DEPTH => 3
        ) port map (
            clk => dsp_clk, -- clock
            i_wr_data_valid => sl_feedfwd_success_flag, -- Write request and Input to queue
            i_wr_data     => (others => '0'), 
            i_rd_valid    => sl_feedfwd_success_done_to_transfer_rd_valid,-- Read request and Output from queue
            o_rd_data     => open,
            o_rd_data_rdy => sl_feedfwd_success_done_to_transfer_rd_rdy,

            o_buffer_empty => open,
            o_queue_empty => open,
            o_buffer_full => open,
            o_queue_full => open,
            o_buffer_full_latched => open,
            o_queue_full_latched => open,
            o_data_loss => open -- to LED - should never be asserted
        );


        inst_nff_cdcc_success_done : entity lib_src.nff_cdcc(rtl)
        generic map (
            BYPASS => false,
            ASYNC_FLOPS_CNT => 2,
            DATA_WIDTH => 1,
            FLOPS_BEFORE_CROSSING_CNT => 1,
            WR_READY_DEASSERTED_CYCLES => 20
        )
        port map (
            -- Write ports
            clk_write => dsp_clk,
            wr_en     => sl_feedfwd_success_done_to_transfer_rd_rdy,
            wr_data   => (others => '0'),
            wr_ready  => sl_feedfwd_success_done_to_transfer_rd_valid,

            -- Read ports
            clk_read => eval_clk,
            rd_valid => sl_feedfwd_success_done_transferred,
            rd_data  => open
        );

        -- Count unsuccessful qubits per channel and transfer the value to the readout domain
        gen_cdcc_photon_losses_flags : for i in INT_QUBITS_CNT-2 downto 0 generate
            inst_nff_cdcc_photon_loss_event : entity lib_src.nff_cdcc_flag(rtl)
                generic map (
                    BYPASS => false,
                    ASYNC_FLOPS_CNT => 2,
                    FLOPS_BEFORE_CROSSING_CNT => 1,
                    WR_READY_DEASSERTED_CYCLES => 4
                )
                port map (
                    -- Write ports
                    clk_write => dsp_clk,
                    wr_en => slv_photon_losses_to_cdcc(i),
                    wr_ready => open,

                    -- Read ports
                    clk_read => eval_clk,
                    rd_valid => slv_photon_losses(i)
                );
        end generate;

        -- Count all photons on FPGA's inputs to verify
        gen_cdcc_cntr_ch_photons : for i in INT_QUBITS_CNT*2-1 downto 0 generate
            inst_nff_cdcc_cntr_ch_photons : entity lib_src.nff_cdcc_cntr(rtl)
                generic map (
                    ASYNC_FLOPS_CNT => 2,
                    CNTR_WIDTH => 1,
                    FLOPS_BEFORE_CROSSING_CNT => 1,
                    WR_READY_DEASSERTED_CYCLES => 3 -- Optional handshake
                )
                port map (
                    -- Write ports
                    clk_write => dsp_clk,
                    wr_en => slv_cdcc_rd_qubits_to_fsm(i),
                    wr_ready => open,

                    -- Read ports
                    clk_read => eval_clk,
                    rd_valid => open,
                    rd_data => slv_channels_detections_cntr(i)
                );
        end generate;

        gen_cdcc_transfer_data : for i in 0 to INT_QUBITS_CNT-1 generate
            -- Queue: Qubit Buffer
            inst_shiftreg_queue_qubit_buffer : entity lib_src.shiftreg_queue_shifter(rtl)
            generic map (
                REAL_CLK_HZ => REAL_CLK_DSP_HZ,
                INT_DATA_WIDTH => 2,
                INT_QUEUE_DEPTH => 3
            ) port map (
                clk => dsp_clk, -- clock
                i_wr_data_valid => sl_feedfwd_success_flag, -- Write request and Input to queue
                i_wr_data     => slv_qubit_buffer_2d(i), 
                i_rd_valid    => slv_qubit_buffer_to_transfer_rd_valid(i),-- Read request and Output from queue
                o_rd_data     => slv_qubit_buffer_to_transfer_2d(i),
                o_rd_data_rdy => slv_qubit_buffer_to_transfer_rd_rdy(i),

                o_buffer_empty => open,
                o_queue_empty => open,
                o_buffer_full => open,
                o_queue_full => open,
                o_buffer_full_latched => open,
                o_queue_full_latched => open,
                o_data_loss => open -- to LED - should never be asserted
            );

            -- CDCC: Qubit Buffer
            inst_nff_cdcc_qubit_buffer : entity lib_src.nff_cdcc(rtl)
            generic map (
                BYPASS => false,
                ASYNC_FLOPS_CNT => 2,
                DATA_WIDTH => 2,
                FLOPS_BEFORE_CROSSING_CNT => 1,
                WR_READY_DEASSERTED_CYCLES => 20
            )
            port map (
                -- Write ports
                clk_write => dsp_clk,
                wr_en     => slv_qubit_buffer_to_transfer_rd_rdy(i),
                wr_data   => slv_qubit_buffer_to_transfer_2d(i),
                wr_ready  => slv_qubit_buffer_to_transfer_rd_valid(i),

                -- Read ports
                clk_read => eval_clk,
                rd_valid => open,
                rd_data  => slv_qubit_buffer_transferred_2d(i)
            );


            -- Queue: Random Buffer
            inst_shiftreg_queue_random_buffer : entity lib_src.shiftreg_queue_shifter(rtl)
            generic map (
                REAL_CLK_HZ => REAL_CLK_DSP_HZ,
                INT_DATA_WIDTH => 1,
                INT_QUEUE_DEPTH => 3
            ) port map (
                clk => dsp_clk, -- clock
                i_wr_data_valid => sl_feedfwd_success_flag, -- Write request and Input to queue
                i_wr_data     => slv_random_buffer_2d(i), 
                i_rd_valid    => slv_random_buffer_to_transfer_rd_valid(i),-- Read request and Output from queue
                o_rd_data     => slv_random_buffer_to_transfer_2d(i),
                o_rd_data_rdy => slv_random_buffer_to_transfer_rd_rdy(i),

                o_buffer_empty => open,
                o_queue_empty => open,
                o_buffer_full => open,
                o_queue_full => open,
                o_buffer_full_latched => open,
                o_queue_full_latched => open,
                o_data_loss => open -- to LED - should never be asserted
            );

            -- CDCC: Random Buffer
            inst_nff_cdcc_random_buffer : entity lib_src.nff_cdcc(rtl)
            generic map (
                BYPASS => false,
                ASYNC_FLOPS_CNT => 2,
                DATA_WIDTH => 1,
                FLOPS_BEFORE_CROSSING_CNT => 1,
                WR_READY_DEASSERTED_CYCLES => 20
            )
            port map (
                -- Write ports
                clk_write => dsp_clk,
                wr_en     => slv_random_buffer_to_transfer_rd_rdy(i),
                wr_data   => slv_random_buffer_to_transfer_2d(i),
                wr_ready  => slv_random_buffer_to_transfer_rd_valid(i),

                -- Read ports
                clk_read => eval_clk,
                rd_valid => open,
                rd_data  => slv_random_buffer_transferred_2d(i)
            );
        end generate;


        -- Queue: Sx Buffer
        inst_shiftreg_queue_sx_buffer : entity lib_src.shiftreg_queue_shifter(rtl)
        generic map (
            REAL_CLK_HZ => REAL_CLK_DSP_HZ,
            INT_DATA_WIDTH => INT_QUBITS_CNT,
            INT_QUEUE_DEPTH => 3
        ) port map (
            clk => dsp_clk, -- clock
            i_wr_data_valid => sl_feedfwd_success_flag, -- Write request and Input to queue
            i_wr_data     => slv_sx_buffer,
            i_rd_valid    => sl_sx_buffer_to_transfer_rd_valid,-- Read request and Output from queue
            o_rd_data     => slv_sx_buffer_to_transfer,
            o_rd_data_rdy => sl_sx_buffer_to_transfer_rd_rdy,

            o_buffer_empty => open,
            o_queue_empty => open,
            o_buffer_full => open,
            o_queue_full => open,
            o_buffer_full_latched => open,
            o_queue_full_latched => open,
            o_data_loss => open -- to LED - should never be asserted
        );

        -- CDCC: Sx Buffer
        inst_nff_cdcc_sx_buffer : entity lib_src.nff_cdcc(rtl)
        generic map (
            BYPASS => false,
            ASYNC_FLOPS_CNT => 2,
            DATA_WIDTH => INT_QUBITS_CNT,
            FLOPS_BEFORE_CROSSING_CNT => 1,
            WR_READY_DEASSERTED_CYCLES => 20
        )
        port map (
            -- Write ports
            clk_write => dsp_clk,
            wr_en     => sl_sx_buffer_to_transfer_rd_rdy,
            wr_data   => slv_sx_buffer_to_transfer,
            wr_ready  => sl_sx_buffer_to_transfer_rd_valid,

            -- Read ports
            clk_read => eval_clk,
            rd_valid => open,
            rd_data  => slv_sx_buffer_transferred
        );


        -- Queue: Sz Buffer
        inst_shiftreg_queue_sz_buffer : entity lib_src.shiftreg_queue_shifter(rtl)
        generic map (
            REAL_CLK_HZ => REAL_CLK_DSP_HZ,
            INT_DATA_WIDTH => INT_QUBITS_CNT,
            INT_QUEUE_DEPTH => 3
        ) port map (
            clk => dsp_clk, -- clock
            i_wr_data_valid => sl_feedfwd_success_flag, -- Write request and Input to queue
            i_wr_data     => slv_sz_buffer,
            i_rd_valid    => sl_sz_buffer_to_transfer_rd_valid,-- Read request and Output from queue
            o_rd_data     => slv_sz_buffer_to_transfer,
            o_rd_data_rdy => sl_sz_buffer_to_transfer_rd_rdy,

            o_buffer_empty => open,
            o_queue_empty => open,
            o_buffer_full => open,
            o_queue_full => open,
            o_buffer_full_latched => open,
            o_queue_full_latched => open,
            o_data_loss => open -- to LED - should never be asserted
        );

        -- CDCC: Sz Buffer
        inst_nff_cdcc_sz_buffer : entity lib_src.nff_cdcc(rtl)
        generic map (
            BYPASS => false,
            ASYNC_FLOPS_CNT => 2,
            DATA_WIDTH => INT_QUBITS_CNT,
            FLOPS_BEFORE_CROSSING_CNT => 1,
            WR_READY_DEASSERTED_CYCLES => 20
        )
        port map (
            -- Write ports
            clk_write => dsp_clk,
            wr_en     => sl_sz_buffer_to_transfer_rd_rdy,
            wr_data   => slv_sz_buffer_to_transfer,
            wr_ready  => sl_sz_buffer_to_transfer_rd_valid,

            -- Read ports
            clk_read => eval_clk,
            rd_valid => open,
            rd_data  => slv_sz_buffer_transferred
        );


        -- Queue: Actual Gflow Buffer
        inst_shiftreg_queue_actual_gflow_buffer : entity lib_src.shiftreg_queue_shifter(rtl)
        generic map (
            REAL_CLK_HZ => REAL_CLK_DSP_HZ,
            INT_DATA_WIDTH => slv_actual_gflow_buffer'length,
            INT_QUEUE_DEPTH => 3
        ) port map (
            clk => dsp_clk, -- clock
            i_wr_data_valid => sl_feedfwd_success_flag, -- Write request and Input to queue
            i_wr_data     => slv_actual_gflow_buffer,
            i_rd_valid    => sl_actual_gflow_buffer_to_transfer_rd_valid,-- Read request and Output from queue
            o_rd_data     => slv_actual_gflow_buffer_to_transfer,
            o_rd_data_rdy => sl_actual_gflow_buffer_to_transfer_rd_rdy,

            o_buffer_empty => open,
            o_queue_empty => open,
            o_buffer_full => open,
            o_queue_full => open,
            o_buffer_full_latched => open,
            o_queue_full_latched => open,
            o_data_loss => open -- to LED - should never be asserted
        );

        -- CDCC: Actual Gflow Buffer
        inst_nff_cdcc_actual_gflow_buffer : entity lib_src.nff_cdcc(rtl)
        generic map (
            BYPASS => false,
            ASYNC_FLOPS_CNT => 2,
            DATA_WIDTH => slv_actual_gflow_buffer'length,
            FLOPS_BEFORE_CROSSING_CNT => 1,
            WR_READY_DEASSERTED_CYCLES => 20
        )
        port map (
            -- Write ports
            clk_write => dsp_clk,
            wr_en     => sl_actual_gflow_buffer_to_transfer_rd_rdy,
            wr_data   => slv_actual_gflow_buffer_to_transfer,
            wr_ready  => sl_actual_gflow_buffer_to_transfer_rd_valid,

            -- Read ports
            clk_read => eval_clk,
            rd_valid => open,
            rd_data  => slv_actual_gflow_buffer_transferred
        );



        -- CDCC Timestamp Buffer
        gen_cdcc_transfer_feedfwd_timestamps : for i in 0 to INT_QUBITS_CNT generate
            inst_shiftreg_queue_timestamp_buffer : entity lib_src.shiftreg_queue_shifter(rtl)
            generic map (
                REAL_CLK_HZ => REAL_CLK_DSP_HZ,
                INT_DATA_WIDTH => 32-4,
                INT_QUEUE_DEPTH => 3
            ) port map (
                clk => dsp_clk, -- clock
                i_wr_data_valid => sl_feedfwd_success_flag, -- Write request and Input to queue
                i_wr_data => slv_time_stamp_buffer_2d(i), 
                i_rd_valid => slv_time_stamp_buffer_to_transfer_rd_valid(i),-- Read request and Output from queue
                o_rd_data => slv_time_stamp_buffer_to_transfer_2d(i),
                o_rd_data_rdy => slv_time_stamp_buffer_to_transfer_rd_rdy(i),

                o_buffer_empty => open,
                o_queue_empty => open,
                o_buffer_full => open,
                o_queue_full => open,
                o_buffer_full_latched => open,
                o_queue_full_latched => open,
                o_data_loss => open -- to LED - should never be asserted
            );

            inst_nff_cdcc_timestamp_buffer : entity lib_src.nff_cdcc(rtl)
            generic map (
                BYPASS => false,
                ASYNC_FLOPS_CNT => 2,
                DATA_WIDTH => 32-4,
                FLOPS_BEFORE_CROSSING_CNT => 1,
                WR_READY_DEASSERTED_CYCLES => 20
            )
            port map (
                -- Write ports
                clk_write => dsp_clk,
                wr_en     => slv_time_stamp_buffer_to_transfer_rd_rdy(i),
                wr_data   => slv_time_stamp_buffer_to_transfer_2d(i),
                wr_ready  => slv_time_stamp_buffer_to_transfer_rd_valid(i),

                -- Read ports
                clk_read => eval_clk,
                rd_valid => open,
                rd_data  => slv_time_stamp_buffer_transferred_2d(i)
            );
        end generate;



        -------------------------------------------------
        -- FEEDFORWARD Data Path: Output Pulse Generation
        -------------------------------------------------
        -- EOM Trigger logic
        inst_pulse_gen : entity lib_src.pulse_gen(rtl)
        generic map (
            RST_VAL                => RST_VAL,
            DATA_WIDTH             => 1,
            REAL_CLK_HZ            => REAL_CLK_DSP_HZ,
            PULSE_DURATION_HIGH_NS => INT_CTRL_PULSE_HIGH_DURATION_NS,
            PULSE_DURATION_LOW_NS  => INT_CTRL_PULSE_DEAD_DURATION_NS
        )
        port map (
            CLK           => dsp_clk,
            RST           => '0',
            PULSE_TRIGGER => sl_actual_qubit_valid,
            -- IN_DATA       => slv_feedforward_pulse(0 downto 0),
            IN_DATA       => slv_o_sx_next_to_math(0 downto 0),
            PULSES_OUT    => slv_feedfwd_eom_pulse,
            READY         => eom_ctrl_pulse_ready,
            BUSY          => eom_ctrl_pulse_busy
        );

        -- Feedforward start flag
        inst_pulse_gen_feedfwd_start_flag : entity lib_src.pulse_gen(rtl)
        generic map (
            RST_VAL                => RST_VAL,
            DATA_WIDTH             => 1,
            REAL_CLK_HZ            => REAL_CLK_DSP_HZ,
            PULSE_DURATION_HIGH_NS => 5,
            PULSE_DURATION_LOW_NS  => 5
        )
        port map (
            CLK           => dsp_clk,
            RST           => '0',
            PULSE_TRIGGER => sl_feedfwd_start,
            IN_DATA       => "1",
            PULSES_OUT    => slv_feedfwd_start,
            READY         => open,
            BUSY          => open
        );

        -- Feedforward success flag
        inst_pulse_gen_feedfwd_success_flag : entity lib_src.pulse_gen(rtl)
        generic map (
            RST_VAL                => RST_VAL,
            DATA_WIDTH             => 1,
            REAL_CLK_HZ            => REAL_CLK_DSP_HZ,
            PULSE_DURATION_HIGH_NS => 5,
            PULSE_DURATION_LOW_NS  => 5
        )
        port map (
            CLK           => dsp_clk,
            RST           => '0',
            PULSE_TRIGGER => sl_feedfwd_success_flag,
            IN_DATA       => "1",
            PULSES_OUT    => slv_feedfwd_success_flag,
            READY         => open,
            BUSY          => open
        );


        -- Coincidence detection trigger
        inst_pulse_gen_coincidence_flag : entity lib_src.pulse_gen(rtl)
        generic map (
            RST_VAL                => RST_VAL,
            DATA_WIDTH             => 1,
            REAL_CLK_HZ            => REAL_CLK_DSP_HZ,
            PULSE_DURATION_HIGH_NS => 5,
            PULSE_DURATION_LOW_NS  => 5
        )
        port map (
            CLK           => dsp_clk,
            RST           => '0',
            PULSE_TRIGGER => sl_actual_qubit_valid,
            IN_DATA       => slv_feedforward_pulse_trigger(0 downto 0),
            -- IN_DATA       => "1",
            PULSES_OUT    => eom_ctrl_pulse_coincidence,
            READY         => open,
            BUSY          => open
        );



        -------------------------------------------
        -- FEEDFORWARD Data Path: Coarse Delay Line
        -------------------------------------------
        -- EOM Trigger pulse delay
        gen_reg_delays_before_eom : for i in 0 to INT_QUBITS_CNT-2 generate
            -- inst_reg_delay_eom_pulse : entity lib_src.reg_delay(rtl)
            inst_shiftreg_delay_eom_pulse : entity lib_src.shiftreg_delay(rtl)
            generic map (
                CLK_HZ => REAL_CLK_DSP_HZ, -- NEW
                RST_VAL => RST_VAL,
                DATA_WIDTH => 1,
                DELAY_CYCLES => 0, -- Keep DELAY_CYCLES zero to allow DELAY_NS value to be used for the delay calculation
                DELAY_NS => INT_CTRL_PULSE_EXTRA_DELAY_QX_NS(i) -- This value should be a multiple of clock period for precise results
            )
            port map (
                clk    => dsp_clk,
                i_en   => state_feedfwd(i+1),
                i_data => slv_feedfwd_eom_pulse,
                o_data => slv_feedfwd_eom_pulse_delayed(i downto i)
            );
        end generate;

        -- One extra delay line for multigate OR
        slv_feedfwd_eom_pulse_delayed_ored(0) <= 
            or_all_bits_in_slv(slv_feedfwd_eom_pulse_delayed, slv_feedfwd_eom_pulse_delayed'length);
        inst_reg_delay_eom_pulse : entity lib_src.reg_delay(rtl)
        generic map (
            CLK_HZ => REAL_CLK_DSP_HZ, -- NEW
            RST_VAL => RST_VAL,
            DATA_WIDTH => 1,
            DELAY_CYCLES => 3, -- Keep DELAY_CYCLES zero to allow DELAY_NS value to be used for the delay calculation
            DELAY_NS => 0 -- This value should be a multiple of clock period for precise results
        )
        port map (
            clk    => dsp_clk,
            i_en   => '1',
            i_data => slv_feedfwd_eom_pulse_delayed_ored,
            o_data => slv_feedfwd_eom_pulse_delayed_ored_ff
        );


        -- Pulse Gen Ready delay
        inst_reg_delay_pulse_gen_ready : entity lib_src.reg_delay(rtl)
        generic map (
            CLK_HZ => REAL_CLK_DSP_HZ,
            RST_VAL => RST_VAL,
            DATA_WIDTH => 1,
            DELAY_CYCLES => 0, -- Keep DELAY_CYCLES zero to allow DELAY_NS value to be the base for the delay calculation
            DELAY_NS => INT_CTRL_PULSE_EXTRA_DELAY_Q2_NS -- This value should be a multiple of clock period for precise results
        )
        port map (
            clk    => dsp_clk,
            i_en   => '1',
            i_data => eom_ctrl_pulse_ready,
            o_data => eom_ctrl_pulse_ready_delayed
        );


        inst_reg_delay_pulse_gen_busy : entity lib_src.reg_delay(rtl)
        generic map (
            CLK_HZ => REAL_CLK_DSP_HZ,
            RST_VAL => RST_VAL,
            DATA_WIDTH => 1,
            DELAY_CYCLES => 0, -- Keep DELAY_CYCLES zero to allow DELAY_NS value to be the base for the delay calculation
            DELAY_NS => INT_CTRL_PULSE_EXTRA_DELAY_Q2_NS -- This value should be a multiple of clock period for precise results
        )
        port map (
            clk    => dsp_clk,
            i_en   => '1',
            i_data => eom_ctrl_pulse_busy,
            o_data => eom_ctrl_pulse_busy_delayed
        );


        -----------------------------------------------
        -- FEEDFORWARD Data Path: EOM Modulation Output
        -----------------------------------------------
        -- Xilinx OBUFs
        -- +1 clk cycle delay
        -- EOM CONTROL PULSE
        o_eom_ctrl_pulse <= slv_eom_ctrl_pulse(0);
        inst_xilinx_obuf_eom : entity lib_src.xilinx_obufs(rtl)
        generic map (
            PINS_CNT => 1
        )
        port map (
            clk      => dsp_clk,
            data_in  => slv_feedfwd_eom_pulse_delayed_ored_ff,
            data_out => slv_eom_ctrl_pulse(0 downto 0)
        );



        -----------------------------------------------
        -- FEEDFORWARD Data Path: Signals for Debugging
        -----------------------------------------------
        -- DEBUG signals to ensure correct functionality
    
        -- A pulse that has a similar duration as the APD pulse width
        -- +1 clk cycle delay
        -- EOM CONTROL PULSE -> OSCILLOSCOPE
        o_debug_port_1 <= slv_debug_port_1(0);
        inst_xilinx_obuf_debug1 : entity lib_src.xilinx_obufs(rtl)
        generic map (
            PINS_CNT => 1
        )
        port map (
            clk      => dsp_clk,
            data_in  => slv_feedfwd_eom_pulse_delayed_ored,
            data_out => slv_debug_port_1(0 downto 0)
        );

        -- +1 clk cycle delay
        -- FEEDFORWARD SUCCESS
        o_debug_port_2 <= slv_debug_port_2(0);
        inst_xilinx_obuf_debug2 : entity lib_src.xilinx_obufs(rtl)
        generic map (
            PINS_CNT => 1
        )
        port map (
            clk      => dsp_clk,
            data_in  => slv_feedfwd_success_flag(0 downto 0),
            data_out => slv_debug_port_2(0 downto 0)
        );

        -- +1 clk cycle delay
        -- FEEDFORWARD START
        o_debug_port_3 <= slv_debug_port_3(0);
        inst_xilinx_obuf_debug3 : entity lib_src.xilinx_obufs(rtl)
        generic map (
            PINS_CNT => 1
        )
        port map (
            clk      => dsp_clk,
            data_in  => slv_feedfwd_start(0 downto 0),
            data_out => slv_debug_port_3(0 downto 0)
        );



        -- For simulation (not outputted from the FPGA)
        -- +1 clk cycle delay
        o_eom_ctrl_pulsegen_busy <= slv_eom_ctrl_pulsegen_busy(0);
        inst_xilinx_obuf_pulsegen_busy : entity lib_src.xilinx_obufs(rtl)
        generic map (
            PINS_CNT => 1
        )
        port map (
            clk      => dsp_clk, -- original
            data_in  => eom_ctrl_pulse_busy_delayed, -- original
            data_out => slv_eom_ctrl_pulsegen_busy(0 downto 0)
        );

    end architecture;