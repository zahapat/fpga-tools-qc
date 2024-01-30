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
            RST_VAL                : std_logic := '1';
            CLK_SYS_HZ             : natural := 100e6;
            CLK_SAMPL_HZ           : natural := 250e6;

            INPUT_PADS_CNT         : positive := 8;
            OUTPUT_PADS_CNT        : positive := 1;
            
            QUBITS_CNT             : positive := INT_QUBITS_CNT;

            -- Integer parameters from Makefile
            INT_EMULATE_INPUTS           : integer := INT_EMULATE_INPUTS;
            INT_WHOLE_PHOTON_2H_DELAY_NS : integer := INT_WHOLE_PHOTON_2H_DELAY_NS;
            INT_DECIM_PHOTON_2H_DELAY_NS : integer := INT_DECIM_PHOTON_2H_DELAY_NS;
            INT_WHOLE_PHOTON_2V_DELAY_NS : integer := INT_WHOLE_PHOTON_2V_DELAY_NS;
            INT_DECIM_PHOTON_2V_DELAY_NS : integer := INT_DECIM_PHOTON_2V_DELAY_NS;
            INT_WHOLE_PHOTON_3H_DELAY_NS : integer := INT_WHOLE_PHOTON_3H_DELAY_NS;
            INT_DECIM_PHOTON_3H_DELAY_NS : integer := INT_DECIM_PHOTON_3H_DELAY_NS;
            INT_WHOLE_PHOTON_3V_DELAY_NS : integer := INT_WHOLE_PHOTON_3V_DELAY_NS;
            INT_DECIM_PHOTON_3V_DELAY_NS : integer := INT_DECIM_PHOTON_3V_DELAY_NS;
            INT_WHOLE_PHOTON_4H_DELAY_NS : integer := INT_WHOLE_PHOTON_4H_DELAY_NS;
            INT_DECIM_PHOTON_4H_DELAY_NS : integer := INT_DECIM_PHOTON_4H_DELAY_NS;
            INT_WHOLE_PHOTON_4V_DELAY_NS : integer := INT_WHOLE_PHOTON_4V_DELAY_NS;
            INT_DECIM_PHOTON_4V_DELAY_NS : integer := INT_DECIM_PHOTON_4V_DELAY_NS;
            INT_WHOLE_PHOTON_5H_DELAY_NS : integer := INT_WHOLE_PHOTON_5H_DELAY_NS;
            INT_DECIM_PHOTON_5H_DELAY_NS : integer := INT_DECIM_PHOTON_5H_DELAY_NS;
            INT_WHOLE_PHOTON_5V_DELAY_NS : integer := INT_WHOLE_PHOTON_5V_DELAY_NS;
            INT_DECIM_PHOTON_5V_DELAY_NS : integer := INT_DECIM_PHOTON_5V_DELAY_NS;
            INT_WHOLE_PHOTON_6H_DELAY_NS : integer := INT_WHOLE_PHOTON_6H_DELAY_NS;
            INT_DECIM_PHOTON_6H_DELAY_NS : integer := INT_DECIM_PHOTON_6H_DELAY_NS;
            INT_WHOLE_PHOTON_6V_DELAY_NS : integer := INT_WHOLE_PHOTON_6V_DELAY_NS;
            INT_DECIM_PHOTON_6V_DELAY_NS : integer := INT_DECIM_PHOTON_6V_DELAY_NS;
            INT_WHOLE_PHOTON_7H_DELAY_NS : integer := INT_WHOLE_PHOTON_7H_DELAY_NS;
            INT_DECIM_PHOTON_7H_DELAY_NS : integer := INT_DECIM_PHOTON_7H_DELAY_NS;
            INT_WHOLE_PHOTON_7V_DELAY_NS : integer := INT_WHOLE_PHOTON_7V_DELAY_NS;
            INT_DECIM_PHOTON_7V_DELAY_NS : integer := INT_DECIM_PHOTON_7V_DELAY_NS;
            INT_WHOLE_PHOTON_8H_DELAY_NS : integer := INT_WHOLE_PHOTON_8H_DELAY_NS;
            INT_DECIM_PHOTON_8H_DELAY_NS : integer := INT_DECIM_PHOTON_8H_DELAY_NS;
            INT_WHOLE_PHOTON_8V_DELAY_NS : integer := INT_WHOLE_PHOTON_8V_DELAY_NS;
            INT_DECIM_PHOTON_8V_DELAY_NS : integer := INT_DECIM_PHOTON_8V_DELAY_NS;
            

            WRITE_ON_VALID         : boolean := true
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
            input_pads : in std_logic_vector(INPUT_PADS_CNT-1 downto 0);

            -- PCD Trigger
            output_pads : out std_logic_vector(OUTPUT_PADS_CNT-1 downto 0)

        );
    end top_gflow;

    architecture str of top_gflow is

        ------------------------------
        -- USB FIFO Readout Control --
        ------------------------------
        signal sl_led_fifo_full_latched : std_logic := '0';
        signal slv_fifo_wr_valid_qubit_flags : std_logic_vector(QUBITS_CNT-1 downto 0);
        signal sl_usb_fifo_empty : std_logic := '0';
        signal sl_usb_fifo_full : std_logic := '0';
        signal sl_usb_fifo_prog_empty : std_logic := '0';


        ---------------------
        -- Vivado IP Cores --
        ---------------------
        -- Xilinx Clock generator
        component clk_wiz_0
        port (
            clk_out1          : out    std_logic;
            clk_out2          : out    std_logic;
            clk_in1_p         : in     std_logic;
            clk_in1_n         : in     std_logic;
            locked            : out    std_logic
        );
        end component;


        ---------------
        -- Constants --
        ---------------
        -- Input Emulator
        constant REQUESTED_EMUL_FREQ_HZ : real := 1.0e6;
        constant SYSTEMCLK_EMUL_FREQ_HZ : real := real(CLK_SAMPL_HZ);

        -- Noisy rising edge detection & keep input
        constant CHANNELS_CNT                     : positive := INPUT_PADS_CNT;
        constant BUFFER_DEPTH                     : positive := 6;
        constant PATTERN_WIDTH                    : positive := 2;
        constant BUFFER_PATTERN                   : positive := 1;
        constant ZERO_BITS_CNT                    : positive := 1;
        constant HIGH_BITS_CNT                    : positive := 2;
        constant CNT_ONEHOT_WIDTH                 : positive := 2;  -- 1xclk = 5 ns -> 4 x 5ns = 20 ns (does not exceed 32 ns => OK)
        constant DETECTOR_ACTIVE_PERIOD_NS        : positive := 10;
        constant DETECTOR_DEAD_PERIOD_NS          : positive := 22;
        constant TOLERANCE_KEEP_FASTER_BIT_CYCLES : natural := 1;
        constant IGNORE_CYCLES_AFTER_TIMEUP       : natural := 3;

        -- Reset
        -- constant RST_STROBE_CNTR_WIDTH_SYSCLK : positive := 28; -- 10*10^(-9) sec * 2^28 / 2 = 1.3 sec
        constant RST_STROBE_CNTR_WIDTH_SYSCLK : positive := 3; -- 10*10^(-9) sec * 2^28 / 2 = 1.3 sec
        constant RST_STROBE_CNTR_WIDTH_SAMPLCLK : positive := 2;

        -- Pseudorandom bit generator
        constant PRIM_POL_INT_VAL  : positive := 19;
        constant SYMBOL_WIDTH      : positive := 4;
        constant GF_SEED           : positive := 1;

        -- Modulo
        constant INPUT_DATA_WIDTH  : positive := 4;
        constant OUTPUT_DATA_WIDTH : positive := 2;
        constant MODULO            : positive := 4;
        constant IF_MODULO_POW_2   : std_logic := '1';

        -- Delay counter for write enable (sample-enable) signal: gflow + math_block + modulo
        function calc_delay_to_mod return positive is
        begin
            if IF_MODULO_POW_2 = '0' then
                return 2;
            else
                return 3;
            end if;
        end function;
        constant DELAY_GFLOW_TO_SAMPL_MOD : positive := calc_delay_to_mod; -- after optimizing modulo

        -- Gflow FSM
        function calc_delay_after_gflow return positive is
            begin
                if IF_MODULO_POW_2 = '0' then
                    return 4;
                else
                    return 5;
                end if;
            end function;
        constant PCD_DELAY_US            : natural := 1;           -- Duration of the pulse from PCD in usec

        constant TOTAL_DELAY_DETECTOR_REDGE : natural := 4;
        constant TOTAL_DELAY_PCD_REDGE : natural := 4;
        constant TOTAL_DELAY_IN_LOGIC : natural := BUFFER_DEPTH + 4;
        constant TOTAL_DELAY_FPGA_BEFORE : natural := TOTAL_DELAY_PCD_REDGE + TOTAL_DELAY_DETECTOR_REDGE + TOTAL_DELAY_IN_LOGIC;    -- Delay before this module
        constant TOTAL_DELAY_FPGA_AFTER  : natural := calc_delay_after_gflow; -- Delay behind this module

        -- Sampler
        constant OUTPUT_PULSES_CNT : positive := 2;

        -- 1 MHz pulse generator
        constant REQUESTED_FREQ_HZ : real := 1.0e6;
        constant SYSTEMCLK_FREQ_HZ : real := real(CLK_SYS_HZ);

        -- FIFO
        constant RAM_WIDTH : positive := 8;
        constant RAM_DEPTH : positive := 256;

        -- USB3 Transaction
        signal slv_usb3_transaction_32b : std_logic_vector(31 downto 0) := (others => '0'); -- Probing inner signals real-time


        -------------
        -- Signals --
        -------------
        -- Clock Wizard
        signal sys_clk : std_logic;
        signal sampl_clk : std_logic;
        signal locked : std_logic;

        signal sl_rst : std_logic := '0';
        signal sl_rst_sysclk : std_logic := '0'; -- Pullup
        signal sl_rst_samplclk : std_logic := '0';

        -- Dimensioned for 8 qubits max
        signal s_noisy_channels : std_logic_vector(16-1 downto 0) := (others => '0');
        signal s_stable_channels_to_cdcc : std_logic_vector(16-1 downto 0) := (others => '0');
        signal s_valid_qubits_stable_to_cdcc : std_logic_vector(16/2-1 downto 0) := (others => '0');

        signal sl_inemul_valid : std_logic := '0';

        signal slv_cdcc_rd_valid_to_fsm : std_logic_vector(QUBITS_CNT-1 downto 0) := (others => '0');
        signal slv_cdcc_rd_qubits_to_fsm : std_logic_vector(CHANNELS_CNT-1 downto 0) := (others => '0');

        signal sl_gflow_success_flag       : std_logic := '0';
        signal sl_gflow_success_done       : std_logic;
        signal slv_alpha_to_math           : std_logic_vector(1 downto 0) := (others => '0');
        signal slv_sx_sz_to_math           : std_logic_vector(1 downto 0) := (others => '0');
        signal sl_actual_qubit_valid       : std_logic := '0';
        signal slv_actual_qubit            : std_logic_vector(1 downto 0) := (others => '0');
        signal slv_actual_qubit_time_stamp : std_logic_vector(st_transaction_data_max_width) := (others => '0');
        signal state_gflow             : natural range 0 to QUBITS_CNT-1 := 0;

        signal sl_pseudorandom_to_math  : std_logic := '0';
        signal slv_math_data_modulo     : std_logic_vector(1 downto 0) := (others => '0');
        signal sl_math_data_valid       : std_logic := '0';

        signal slv_out_1MHz_pulses      : std_logic_vector(1 downto 0) := (others => '0');       

        -- Data buffers from G-Flow protocol module
        signal slv_qubit_buffer_2d      : t_qubit_buffer_2d;
        signal slv_time_stamp_buffer_2d : t_time_stamp_buffer_2d;
        signal slv_time_stamp_buffer_overflows_2d : t_time_stamp_buffer_overflows_2d;
        signal slv_alpha_buffer_2d      : t_alpha_buffer_2d;
        signal slv_modulo_buffer_2d     : t_modulo_buffer_2d;
        signal slv_random_buffer_2d     : t_random_buffer_2d;


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
                return integer(10.0*(floor(log10(real(DIVISOR))) + 1.0));
            end if;
        end function;
        constant PHOTON_1H_DELAY_NS : real := 75.65; -- #TODO
        constant PHOTON_1V_DELAY_NS : real := 75.01; -- #TODO
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
        constant PHOTON_7H_DELAY_NS : real := real(INT_WHOLE_PHOTON_7H_DELAY_NS) + real(INT_DECIM_PHOTON_7H_DELAY_NS) / real(get_divisor(INT_DECIM_PHOTON_7H_DELAY_NS));
        constant PHOTON_7V_DELAY_NS : real := real(INT_WHOLE_PHOTON_7V_DELAY_NS) + real(INT_DECIM_PHOTON_7V_DELAY_NS) / real(get_divisor(INT_DECIM_PHOTON_7V_DELAY_NS));
        constant PHOTON_8H_DELAY_NS : real := real(INT_WHOLE_PHOTON_8H_DELAY_NS) + real(INT_DECIM_PHOTON_8H_DELAY_NS) / real(get_divisor(INT_DECIM_PHOTON_8H_DELAY_NS));
        constant PHOTON_8V_DELAY_NS : real := real(INT_WHOLE_PHOTON_8V_DELAY_NS) + real(INT_DECIM_PHOTON_8V_DELAY_NS) / real(get_divisor(INT_DECIM_PHOTON_8V_DELAY_NS));

    begin


        ----------------------
        -- Xilinx IP Blocks --
        ----------------------
        -- Clock Wizard
        clk_wiz : clk_wiz_0
        port map (
            clk_in1_p => sys_clk_p,
            clk_in1_n => sys_clk_n,

            clk_out1 => sys_clk,
            clk_out2 => sampl_clk,

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
        slv_fifo_wr_valid_qubit_flags(3) <= slv_cdcc_rd_valid_to_fsm(3);
        slv_fifo_wr_valid_qubit_flags(2) <= slv_cdcc_rd_valid_to_fsm(2);
        slv_fifo_wr_valid_qubit_flags(1) <= slv_cdcc_rd_valid_to_fsm(1);
        slv_fifo_wr_valid_qubit_flags(0) <= slv_cdcc_rd_valid_to_fsm(0);
        inst_okHost_fifo_ctrl : entity lib_src.ok_usb_32b_fifo_ctrl(rtl)
        generic map (
            RST_VAL => RST_VAL,
            CLK_HZ => CLK_SYS_HZ,
            WRITE_VALID_SIGNALS_CNT => 4,
            WRITE_ON_VALID => WRITE_ON_VALID
        )
        port map (
            -- Reset
            rst => sl_rst_sysclk,

            -- Write endpoint signals
            wr_sys_clk           => sys_clk,

            wr_valid_qubit_flags => slv_fifo_wr_valid_qubit_flags,
            wr_valid_gflow_success_done => sl_gflow_success_done,

            wr_data_qubit_buffer => slv_qubit_buffer_2d,
            wr_data_time_stamp_buffer => slv_time_stamp_buffer_2d,
            wr_data_time_stamp_buffer_overflows => slv_time_stamp_buffer_overflows_2d,
            wr_data_alpha_buffer => slv_alpha_buffer_2d,
            wr_data_random_buffer => slv_random_buffer_2d,
            wr_data_modulo_buffer => slv_modulo_buffer_2d,
            wr_data_stream_32b  => slv_usb3_transaction_32b,

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
        slv_usb3_transaction_32b(11 downto 10) <= slv_sx_sz_to_math;      -- Valid qubit if 'sl_actual_qubit_valid' is valid
        slv_usb3_transaction_32b(9) <= sl_pseudorandom_to_math;          -- Valid random bit if 'sl_actual_qubit_valid' is valid
        slv_usb3_transaction_32b(8 downto 7) <= (others => '0');         -- free
        slv_usb3_transaction_32b(6 downto 5) <= slv_math_data_modulo;    -- In between, check the input going to modulo
        slv_usb3_transaction_32b(4) <= sl_math_data_valid;               -- Flag to indicate valid modulo
        slv_usb3_transaction_32b(3 downto 2) <= (others => '0');         -- Free
        slv_usb3_transaction_32b(1) <= '0';                              -- Free
        slv_usb3_transaction_32b(0) <= slv_out_1MHz_pulses(1);           -- PCD trigger = output pulse 2



        ---------------------
        -- GFLOW DATA PATH --
        ---------------------
        -- If inputs not emulated: Assign collapsed photons to separate channels:

        -- OLD:
        -- s_noisy_channels(7) = PHOTON 1H;
        -- s_noisy_channels(6) = PHOTON 1V;
        -- s_noisy_channels(5) = PHOTON 2H;
        -- s_noisy_channels(4) = PHOTON 2V;
        -- s_noisy_channels(3) = PHOTON 3H;
        -- s_noisy_channels(2) = PHOTON 3V;
        -- s_noisy_channels(1) = PHOTON 4H;
        -- s_noisy_channels(0) = PHOTON 4V;

        -- NEW:
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
        -- s_noisy_channels(12) = PHOTON 7V;
        -- s_noisy_channels(13) = PHOTON 7H;
        -- s_noisy_channels(14) = PHOTON 8V;
        -- s_noisy_channels(15) = PHOTON 8H;

        -- Input Buffers
        gen_emul_false : if INT_EMULATE_INPUTS = 0 generate
            inst_xilinx_ibufs : entity lib_src.xilinx_ibufs(rtl)
            generic map (
                PINS_CNT => INPUT_PADS_CNT
            )
            port map (
                clk => sampl_clk,
                data_in => input_pads,
                data_out => s_noisy_channels(CHANNELS_CNT-1 downto 0)
            );
        end generate;


        -- If Necessary, uncomment this input emulator for evaluation
        gen_emul_true : if INT_EMULATE_INPUTS /= 0 generate 
            inst_lfsr_inemul_q1_to_q4 : entity lib_src.lfsr_inemul(rtl)
            generic map (
                RST_VAL               => RST_VAL,
                SYMBOL_WIDTH          => 8,
                PRIM_POL_INT_VAL      => 501,
                GF_SEED               => 1,
                DATA_PULLDOWN_ENABLE  => true,
                PULLDOWN_CYCLES       => 2 -- min 2
            )
            port map (
                clk => sys_clk,
                rst => sl_rst_sysclk,
        
                ready => open,
                data_out => s_noisy_channels(16-1 downto 8),
                valid_out => open
            );

            inst_lfsr_inemul_q5_to_q8 : entity lib_src.lfsr_inemul(rtl)
            generic map (
                RST_VAL               => RST_VAL,
                SYMBOL_WIDTH          => 8,
                PRIM_POL_INT_VAL      => 501,
                GF_SEED               => 1,
                DATA_PULLDOWN_ENABLE  => true,
                PULLDOWN_CYCLES       => 2 -- min 2
            )
            port map (
                clk => sys_clk,
                rst => sl_rst_sysclk,
        
                ready => open,
                data_out => s_noisy_channels(8-1 downto 0),
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
        -- QUBIT 1
        inst_qubit1_deskew : entity lib_src.qubit_deskew(rtl)
        generic map (
            RST_VAL                   => RST_VAL,
            BUFFER_DEPTH              => BUFFER_DEPTH,
            PATTERN_WIDTH             => PATTERN_WIDTH,
            BUFFER_PATTERN            => BUFFER_PATTERN,
            ZERO_BITS_CNT             => ZERO_BITS_CNT,
            HIGH_BITS_CNT             => HIGH_BITS_CNT,
            CLK_HZ                    => CLK_SAMPL_HZ,

            CNT_ONEHOT_WIDTH          => CNT_ONEHOT_WIDTH,
            DETECTOR_ACTIVE_PERIOD_NS => DETECTOR_ACTIVE_PERIOD_NS,
            DETECTOR_DEAD_PERIOD_NS   => DETECTOR_DEAD_PERIOD_NS,

            TOLERANCE_KEEP_FASTER_BIT_CYCLES => TOLERANCE_KEEP_FASTER_BIT_CYCLES,
            IGNORE_CYCLES_AFTER_TIMEUP => IGNORE_CYCLES_AFTER_TIMEUP,

            PHOTON_H_DELAY_NS => PHOTON_1H_DELAY_NS,
            PHOTON_V_DELAY_NS => PHOTON_1V_DELAY_NS
        )
        port map (
            clk => sampl_clk,
            rst => sl_rst_samplclk,
            noisy_channels_in => s_noisy_channels(1 downto 0),
            
            qubit_valid_250MHz => s_valid_qubits_stable_to_cdcc(0),
            qubit_250MHz => s_stable_channels_to_cdcc(1 downto 0)
        );

        -- QUBIT 2
        inst_qubit2_deskew : entity lib_src.qubit_deskew(rtl)
        generic map (
            RST_VAL                   => RST_VAL,
            BUFFER_DEPTH              => BUFFER_DEPTH,
            PATTERN_WIDTH             => PATTERN_WIDTH,
            BUFFER_PATTERN            => BUFFER_PATTERN,
            ZERO_BITS_CNT             => ZERO_BITS_CNT,
            HIGH_BITS_CNT             => HIGH_BITS_CNT,
            CLK_HZ                    => CLK_SAMPL_HZ,

            CNT_ONEHOT_WIDTH          => CNT_ONEHOT_WIDTH,
            DETECTOR_ACTIVE_PERIOD_NS => DETECTOR_ACTIVE_PERIOD_NS,
            DETECTOR_DEAD_PERIOD_NS   => DETECTOR_DEAD_PERIOD_NS,

            TOLERANCE_KEEP_FASTER_BIT_CYCLES => TOLERANCE_KEEP_FASTER_BIT_CYCLES,
            IGNORE_CYCLES_AFTER_TIMEUP => IGNORE_CYCLES_AFTER_TIMEUP,

            PHOTON_H_DELAY_NS => PHOTON_2H_DELAY_NS,
            PHOTON_V_DELAY_NS => PHOTON_2V_DELAY_NS
        )
        port map (
            clk => sampl_clk,
            rst => sl_rst_samplclk,
            noisy_channels_in => s_noisy_channels(3 downto 2),

            qubit_valid_250MHz => s_valid_qubits_stable_to_cdcc(1),
            qubit_250MHz => s_stable_channels_to_cdcc(3 downto 2)
        );

        -- QUBIT 3
        inst_qubit3_deskew : entity lib_src.qubit_deskew(rtl)
        generic map (
            RST_VAL                   => RST_VAL,
            BUFFER_DEPTH              => BUFFER_DEPTH,
            PATTERN_WIDTH             => PATTERN_WIDTH,
            BUFFER_PATTERN            => BUFFER_PATTERN,
            ZERO_BITS_CNT             => ZERO_BITS_CNT,
            HIGH_BITS_CNT             => HIGH_BITS_CNT,
            CLK_HZ                    => CLK_SAMPL_HZ,

            CNT_ONEHOT_WIDTH          => CNT_ONEHOT_WIDTH,
            DETECTOR_ACTIVE_PERIOD_NS => DETECTOR_ACTIVE_PERIOD_NS,
            DETECTOR_DEAD_PERIOD_NS   => DETECTOR_DEAD_PERIOD_NS,

            TOLERANCE_KEEP_FASTER_BIT_CYCLES => TOLERANCE_KEEP_FASTER_BIT_CYCLES,
            IGNORE_CYCLES_AFTER_TIMEUP => IGNORE_CYCLES_AFTER_TIMEUP,

            PHOTON_H_DELAY_NS => PHOTON_3H_DELAY_NS,
            PHOTON_V_DELAY_NS => PHOTON_3V_DELAY_NS
        )
        port map (
            clk => sampl_clk,
            rst => sl_rst_samplclk,
            noisy_channels_in => s_noisy_channels(5 downto 4),

            qubit_valid_250MHz => s_valid_qubits_stable_to_cdcc(2),
            qubit_250MHz => s_stable_channels_to_cdcc(5 downto 4)
        );

        -- QUBIT 4
        inst_qubit4_deskew : entity lib_src.qubit_deskew(rtl)
        generic map (
            RST_VAL                   => RST_VAL,
            BUFFER_DEPTH              => BUFFER_DEPTH,
            PATTERN_WIDTH             => PATTERN_WIDTH,
            BUFFER_PATTERN            => BUFFER_PATTERN,
            ZERO_BITS_CNT             => ZERO_BITS_CNT,
            HIGH_BITS_CNT             => HIGH_BITS_CNT,
            CLK_HZ                    => CLK_SAMPL_HZ,

            CNT_ONEHOT_WIDTH          => CNT_ONEHOT_WIDTH,
            DETECTOR_ACTIVE_PERIOD_NS => DETECTOR_ACTIVE_PERIOD_NS,
            DETECTOR_DEAD_PERIOD_NS   => DETECTOR_DEAD_PERIOD_NS,

            TOLERANCE_KEEP_FASTER_BIT_CYCLES => TOLERANCE_KEEP_FASTER_BIT_CYCLES,
            IGNORE_CYCLES_AFTER_TIMEUP => IGNORE_CYCLES_AFTER_TIMEUP,

            PHOTON_H_DELAY_NS => PHOTON_4H_DELAY_NS,
            PHOTON_V_DELAY_NS => PHOTON_4V_DELAY_NS
        )
        port map (
            clk => sampl_clk,
            rst => sl_rst_samplclk,
            noisy_channels_in => s_noisy_channels(7 downto 6),

            qubit_valid_250MHz => s_valid_qubits_stable_to_cdcc(3),
            qubit_250MHz => s_stable_channels_to_cdcc(7 downto 6)
        );

        -- QUBIT 5
        inst_qubit5_deskew : entity lib_src.qubit_deskew(rtl)
        generic map (
            RST_VAL                   => RST_VAL,
            BUFFER_DEPTH              => BUFFER_DEPTH,
            PATTERN_WIDTH             => PATTERN_WIDTH,
            BUFFER_PATTERN            => BUFFER_PATTERN,
            ZERO_BITS_CNT             => ZERO_BITS_CNT,
            HIGH_BITS_CNT             => HIGH_BITS_CNT,
            CLK_HZ                    => CLK_SAMPL_HZ,

            CNT_ONEHOT_WIDTH          => CNT_ONEHOT_WIDTH,
            DETECTOR_ACTIVE_PERIOD_NS => DETECTOR_ACTIVE_PERIOD_NS,
            DETECTOR_DEAD_PERIOD_NS   => DETECTOR_DEAD_PERIOD_NS,

            TOLERANCE_KEEP_FASTER_BIT_CYCLES => TOLERANCE_KEEP_FASTER_BIT_CYCLES,
            IGNORE_CYCLES_AFTER_TIMEUP => IGNORE_CYCLES_AFTER_TIMEUP,

            PHOTON_H_DELAY_NS => PHOTON_5H_DELAY_NS,
            PHOTON_V_DELAY_NS => PHOTON_5V_DELAY_NS
        )
        port map (
            clk => sampl_clk,
            rst => sl_rst_samplclk,
            noisy_channels_in => s_noisy_channels(9 downto 8),

            qubit_valid_250MHz => s_valid_qubits_stable_to_cdcc(4),
            qubit_250MHz => s_stable_channels_to_cdcc(9 downto 8)
        );

        -- QUBIT 6
        inst_qubit6_deskew : entity lib_src.qubit_deskew(rtl)
        generic map (
            RST_VAL                   => RST_VAL,
            BUFFER_DEPTH              => BUFFER_DEPTH,
            PATTERN_WIDTH             => PATTERN_WIDTH,
            BUFFER_PATTERN            => BUFFER_PATTERN,
            ZERO_BITS_CNT             => ZERO_BITS_CNT,
            HIGH_BITS_CNT             => HIGH_BITS_CNT,
            CLK_HZ                    => CLK_SAMPL_HZ,

            CNT_ONEHOT_WIDTH          => CNT_ONEHOT_WIDTH,
            DETECTOR_ACTIVE_PERIOD_NS => DETECTOR_ACTIVE_PERIOD_NS,
            DETECTOR_DEAD_PERIOD_NS   => DETECTOR_DEAD_PERIOD_NS,

            TOLERANCE_KEEP_FASTER_BIT_CYCLES => TOLERANCE_KEEP_FASTER_BIT_CYCLES,
            IGNORE_CYCLES_AFTER_TIMEUP => IGNORE_CYCLES_AFTER_TIMEUP,

            PHOTON_H_DELAY_NS => PHOTON_6H_DELAY_NS,
            PHOTON_V_DELAY_NS => PHOTON_6V_DELAY_NS
        )
        port map (
            clk => sampl_clk,
            rst => sl_rst_samplclk,
            noisy_channels_in => s_noisy_channels(11 downto 10),

            qubit_valid_250MHz => s_valid_qubits_stable_to_cdcc(5),
            qubit_250MHz => s_stable_channels_to_cdcc(11 downto 10)
        );


        -- QUBIT 7
        inst_qubit7_deskew : entity lib_src.qubit_deskew(rtl)
        generic map (
            RST_VAL                   => RST_VAL,
            BUFFER_DEPTH              => BUFFER_DEPTH,
            PATTERN_WIDTH             => PATTERN_WIDTH,
            BUFFER_PATTERN            => BUFFER_PATTERN,
            ZERO_BITS_CNT             => ZERO_BITS_CNT,
            HIGH_BITS_CNT             => HIGH_BITS_CNT,
            CLK_HZ                    => CLK_SAMPL_HZ,

            CNT_ONEHOT_WIDTH          => CNT_ONEHOT_WIDTH,
            DETECTOR_ACTIVE_PERIOD_NS => DETECTOR_ACTIVE_PERIOD_NS,
            DETECTOR_DEAD_PERIOD_NS   => DETECTOR_DEAD_PERIOD_NS,

            TOLERANCE_KEEP_FASTER_BIT_CYCLES => TOLERANCE_KEEP_FASTER_BIT_CYCLES,
            IGNORE_CYCLES_AFTER_TIMEUP => IGNORE_CYCLES_AFTER_TIMEUP,

            PHOTON_H_DELAY_NS => PHOTON_7H_DELAY_NS,
            PHOTON_V_DELAY_NS => PHOTON_7V_DELAY_NS
        )
        port map (
            clk => sampl_clk,
            rst => sl_rst_samplclk,
            noisy_channels_in => s_noisy_channels(13 downto 12),

            qubit_valid_250MHz => s_valid_qubits_stable_to_cdcc(6),
            qubit_250MHz => s_stable_channels_to_cdcc(13 downto 12)
        );

        -- QUBIT 8
        inst_qubit8_deskew : entity lib_src.qubit_deskew(rtl)
        generic map (
            RST_VAL                   => RST_VAL,
            BUFFER_DEPTH              => BUFFER_DEPTH,
            PATTERN_WIDTH             => PATTERN_WIDTH,
            BUFFER_PATTERN            => BUFFER_PATTERN,
            ZERO_BITS_CNT             => ZERO_BITS_CNT,
            HIGH_BITS_CNT             => HIGH_BITS_CNT,
            CLK_HZ                    => CLK_SAMPL_HZ,

            CNT_ONEHOT_WIDTH          => CNT_ONEHOT_WIDTH,
            DETECTOR_ACTIVE_PERIOD_NS => DETECTOR_ACTIVE_PERIOD_NS,
            DETECTOR_DEAD_PERIOD_NS   => DETECTOR_DEAD_PERIOD_NS,

            TOLERANCE_KEEP_FASTER_BIT_CYCLES => TOLERANCE_KEEP_FASTER_BIT_CYCLES,
            IGNORE_CYCLES_AFTER_TIMEUP => IGNORE_CYCLES_AFTER_TIMEUP,

            PHOTON_H_DELAY_NS => PHOTON_8H_DELAY_NS,
            PHOTON_V_DELAY_NS => PHOTON_8V_DELAY_NS
        )
        port map (
            clk => sampl_clk,
            rst => sl_rst_samplclk,
            noisy_channels_in => s_noisy_channels(15 downto 14),

            qubit_valid_250MHz => s_valid_qubits_stable_to_cdcc(7),
            qubit_250MHz => s_stable_channels_to_cdcc(15 downto 14)
        );


        -- n-FF CDCC (Cross Domain Crossing Circuit)
        gen_nff_cdcc_sysclk : for i in 0 to QUBITS_CNT-1 generate
            inst_nff_cdcc_cntcross_samplclk_bit1 : entity lib_src.nff_cdcc(rtl)
            generic map (
                ASYNC_FLOPS_CNT => 2,
                DATA_WIDTH => 1,
                FLOPS_BEFORE_CROSSING_CNT => 1,
                WR_READY_DEASSERTED_CYCLES => 2
            )
            port map (
                -- sampl_clk
                clk_write => sampl_clk,
                wr_en     => s_valid_qubits_stable_to_cdcc(QUBITS_CNT-1-i),
                wr_data   => s_stable_channels_to_cdcc((QUBITS_CNT-1-i+1)*2-1 downto (QUBITS_CNT-1-i+1)*2-1),
                wr_ready  => open,

                -- sys_clk
                clk_read => sys_clk,
                rd_valid => slv_cdcc_rd_valid_to_fsm(i),
                rd_data  => slv_cdcc_rd_qubits_to_fsm((i+1)*2-1 downto (i+1)*2-1)
            );

            inst_nff_cdcc_cntcross_samplclk_bit2 : entity lib_src.nff_cdcc(rtl)
            generic map (
                ASYNC_FLOPS_CNT => 2,
                DATA_WIDTH => 1,
                FLOPS_BEFORE_CROSSING_CNT => 1,
                WR_READY_DEASSERTED_CYCLES => 2
            )
            port map (
                -- sampl_clk
                clk_write => sampl_clk,
                wr_en     => s_valid_qubits_stable_to_cdcc(QUBITS_CNT-1-i),
                wr_data   => s_stable_channels_to_cdcc((QUBITS_CNT-1-i)*2 downto (QUBITS_CNT-1-i)*2),
                wr_ready  => open,

                -- sys_clk
                clk_read => sys_clk,
                rd_valid => open,
                rd_data  => slv_cdcc_rd_qubits_to_fsm(i*2 downto i*2)
            );
        end generate;


        -- G-Flow Protocol FSM (path delay: +1)
        inst_fsm_gflow : entity lib_src.fsm_gflow(rtl)
        generic map (
            RST_VAL                 => RST_VAL,
            CLK_HZ                  => CLK_SYS_HZ,
            PCD_DELAY_US            => PCD_DELAY_US,
            QUBITS_CNT              => QUBITS_CNT,
            TOTAL_DELAY_FPGA_BEFORE => TOTAL_DELAY_FPGA_BEFORE,
            TOTAL_DELAY_FPGA_AFTER  => TOTAL_DELAY_FPGA_AFTER,
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
            PHOTON_7H_DELAY_NS      => PHOTON_7H_DELAY_NS,
            PHOTON_7V_DELAY_NS      => PHOTON_7V_DELAY_NS,
            PHOTON_8H_DELAY_NS      => PHOTON_8H_DELAY_NS,
            PHOTON_8V_DELAY_NS      => PHOTON_8V_DELAY_NS
        )
        port map (
            clk                       => sys_clk,
            rst                       => sl_rst_sysclk,

            qubits_sampled_valid      => slv_cdcc_rd_valid_to_fsm,
            qubits_sampled            => slv_cdcc_rd_qubits_to_fsm,

            feedback_mod_valid        => sl_math_data_valid,
            feedback_mod              => slv_math_data_modulo,

            gflow_success_flag          => sl_gflow_success_flag,
            gflow_success_done          => sl_gflow_success_done,
            qubit_buffer                => slv_qubit_buffer_2d,
            time_stamp_buffer           => slv_time_stamp_buffer_2d,
            time_stamp_buffer_overflows => slv_time_stamp_buffer_overflows_2d,
            alpha_buffer                => slv_alpha_buffer_2d,


            to_math_alpha             => slv_alpha_to_math,
            to_math_sx_xz             => slv_sx_sz_to_math,

            actual_qubit_valid        => sl_actual_qubit_valid,
            actual_qubit              => slv_actual_qubit,
            actual_qubit_time_stamp   => slv_actual_qubit_time_stamp,
            state_gflow               => state_gflow
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
            CLK      => sys_clk,
            RST      => sl_rst_sysclk,
            RAND_BIT => sl_pseudorandom_to_math
        );


        -- Math block (path delay+1 or +2)
        inst_alu_gflow : entity lib_src.alu_gflow(rtl)
        generic map (
            RST_VAL => RST_VAL,
            QUBITS_CNT => QUBITS_CNT,
            SYNCH_FACTORS_CALCULATION => true  -- +1 delay if true
        )
        port map (
            CLK             => sys_clk,
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


        -- PCD Trigger logic
        inst_pulse_gen : entity lib_src.pulse_gen(rtl)
        generic map (
            RST_VAL           => RST_VAL,
            DATA_WIDTH        => OUTPUT_PULSES_CNT,
            REQUESTED_FREQ_HZ => REQUESTED_FREQ_HZ,
            SYSTEMCLK_FREQ_HZ => SYSTEMCLK_FREQ_HZ
        )
        port map (
            CLK           => sys_clk,
            RST           => sl_rst_sysclk,
            PULSE_TRIGGER => sl_math_data_valid,
            IN_DATA       => slv_math_data_modulo,
            PULSES_OUT    => slv_out_1MHz_pulses
        );


        -- Xilinx OBUFs
        inst_xilinx_obufs : entity lib_src.xilinx_obufs(rtl)
        generic map (
            PINS_CNT => 1
        )
        port map (
            clk      => sys_clk,
            data_in  => slv_out_1MHz_pulses(1 downto 1),
            data_out => output_pads
        );

    end architecture;