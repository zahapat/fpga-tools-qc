-- set_property AUTO_INCREMENTAL_CHECKPOINT 1 [get_runs synth_1]
-- set_property AUTO_INCREMENTAL_CHECKPOINT.DIRECTORY C:/Users/Patrik/gflow/gflow_ok_clean/vivado/gflow_ok_clean.srcs/utils_1/imports/synth_1 [get_runs synth_1]
-- set_property AUTO_INCREMENTAL_CHECKPOINT 1 [get_runs impl_1]
-- set_property AUTO_INCREMENTAL_CHECKPOINT.DIRECTORY C:/Users/Patrik/gflow/gflow_ok_clean/vivado/gflow_ok_clean.srcs/utils_1/imports/impl_1 [get_runs impl_1]


-- Read https://docs.xilinx.com/r/2021.2-English/ug949-vivado-design-methodology/Incremental-Synthesis
-- synth_design -incremental_mode <value> command:

-- off
-- Incremental synthesis is not run.
-- quick
-- Fastest results but no cross boundary optimizations. This mode limits logic performance.
-- default
-- Most logic optimizations enabled, including cross-boundary optimization. Compile time is significantly reduced from non-incremental synthesis.
-- aggressive
-- All optimizations are enabled. Compile time is significantly reduced from non-incremental synthesis.



-- set_property strategy Flow_AlternateRoutability [get_runs synth_1]
-- set_property STEPS.SYNTH_DESIGN.ARGS.RETIMING true [get_runs synth_1]

-- set_property strategy Performance_Retiming [get_runs impl_1]

    -- top.vhd: Architecture of the FPGA part of the G-Flow protocol

    library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

    -- library work;
    
    library UNISIM;
    use UNISIM.VComponents.all;
    
    library lib_src;
    use lib_src.FRONTPANEL.all;
    use lib_src.types_pack.all;

    entity top_gflow is
        generic(
            -- okHost generics
            CAPABILITY : std_logic_vector(31 downto 0) := x"00000001"; -- bitfield, used to indicate features supported by this bitfile
            READ_FROM_FPGA_ONLY : boolean := true;

            -- Gflow generics
            RST_VAL                : std_logic := '1';
            CLK_SYS_HZ             : natural := 100e6;
            CLK_SAMPL_HZ           : natural := 250e6;

            QUBITS_CNT             : positive := 4;

            INPUT_PADS_CNT         : positive := 8;
            OUTPUT_PADS_CNT        : positive := 1;

            -- Parameters in user GUI
            EMULATE_INPUTS         : boolean := true;
            PHOTON_1H_DELAY_NS     : real := 75.65;
            PHOTON_1V_DELAY_NS     : real := 75.01;
            PHOTON_2H_DELAY_NS     : real := -2117.95;
            PHOTON_2V_DELAY_NS     : real := -2125.35;
            PHOTON_3H_DELAY_NS     : real := -1030.35;
            PHOTON_3V_DELAY_NS     : real := -1034.45;
            PHOTON_4H_DELAY_NS     : real := -3177.95;
            PHOTON_4V_DELAY_NS     : real := -3181.05;

            WRITE_ON_VALID         : boolean := true
        );
        port (

            -- External 200MHz oscillator
            sys_clk_p : in std_logic;
            sys_clk_n : in std_logic;

            -- okHost signals
            okUH  : in    std_logic_vector(4 downto 0);
            okHU  : out   std_logic_vector(2 downto 0);
            okUHU : inout std_logic_vector(31 downto 0); -- data
            okAA  : inout std_logic;

            -- Debug LEDs
            led : out std_logic_vector(3 downto 0);

            -- Inputs from SPCM
            input_pads : in std_logic_vector(INPUT_PADS_CNT-1 downto 0);

            -- PCD Trigger
            output_pads : out std_logic_vector(OUTPUT_PADS_CNT-1 downto 0)

        );
    end top_gflow;

    architecture str of top_gflow is


        -------------------------------
        -- Opal Kelly okHost signals --
        -------------------------------
        constant OUT_ENDPTS_TOTAL_CNT : integer := 5;

        signal okClk : std_logic := '0';
        signal okHE  : std_logic_vector(112 downto 0) := (others => '0');
        signal okEH  : std_logic_vector(64 downto 0) := (others => '0');

        -- Number of outgoing endpoints in your design (n*65-1 downto 0)
        signal okEHx : std_logic_vector(OUT_ENDPTS_TOTAL_CNT*65-1 downto 0);

        -- Endpoint: WireIn
        signal slv_win_ep00               : std_logic_vector(31 downto 0) := (others => '0');
        signal slv_win_ep01_throttle_out  : std_logic_vector(31 downto 0) := (others => '0');
        signal slv_win_ep02_throttle_in   : std_logic_vector(31 downto 0) := (others => '0');
        signal slv_win_ep03_fixed_pattern : std_logic_vector(31 downto 0) := (others => '0');

        -- Endpoint: WireOut
        signal slv_wout_ep20            : std_logic_vector(31 downto 0) := (others => '0');
        signal slv_wout_ep21_rcv_errors : std_logic_vector(31 downto 0) := (others => '0');
        signal slv_wout_ep3e            : std_logic_vector(31 downto 0) := (others => '0');
        signal slv_wout_ep3f            : std_logic_vector(31 downto 0) := (others => '0');

        -- Endpoint: PipeIn
        signal slv_pipe_in_endp_write_en : std_logic := '0';
        signal slv_pipe_in_endp_ready    : std_logic := '0';
        signal slv_pipe_in_endp_data     : std_logic_vector(31 downto 0) := (others => '0');
        signal slv_blockstrobe_pipe_in : std_logic := '0';

        -- Endpoint: PipeOut
        signal slv_pipe_out_endp_read_en : std_logic;
        signal slv_pipe_out_endp_ready   : std_logic;
        signal slv_pipe_out_endp_data    : std_logic_vector(31 downto 0);
        signal slv_blockstrobe_pipe_out : std_logic;

        signal slv_pattern_code : std_logic_vector(2 downto 0) := (others => '0');

        -- USB FIFO Control
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
        constant CHANNELS_CNT                     : positive := 8;
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

        -- Qubit Sampler
        constant LUTRAM_SAMPLER_WIDTH : positive := 2;
        constant LUTRAM_SAMPLER_DEPTH : positive := 2;

        -- Reset
        constant RST_STROBE_CNTR_WIDTH_SYSCLK : positive := 28; -- 10*10^(-9) sec * 2^28 / 2 = 1.3 sec
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
        signal sl_rst_sysclk : std_logic;
        signal sl_rst_samplclk : std_logic := '0';

        signal s_noisy_channels : std_logic_vector(CHANNELS_CNT-1 downto 0) := (others => '0');
        signal s_stable_channels_to_cdcc : std_logic_vector(CHANNELS_CNT-1 downto 0) := (others => '0');
        signal s_valid_qubits_stable_to_cdcc : std_logic_vector(CHANNELS_CNT/2-1 downto 0) := (others => '0');

        signal sl_inemul_ready : std_logic := '0';
        signal sl_inemul_valid : std_logic := '0';

        signal s_q1_valid_to_sampler : std_logic := '0';
        signal s_q2_valid_to_sampler : std_logic := '0';
        signal s_q3_valid_to_sampler : std_logic := '0';
        signal s_q4_valid_to_sampler : std_logic := '0';
        signal slv_qubits_valid_to_cdcc : std_logic_vector(QUBITS_CNT-1 downto 0) := (others => '0');

        signal slv_cdcc_rd_valid_to_fsm : std_logic_vector(QUBITS_CNT-1 downto 0) := (others => '0');
        signal slv_cdcc_rd_qubits_to_fsm : std_logic_vector(CHANNELS_CNT-1 downto 0) := (others => '0');

        signal s_q1_sampler_empty : std_logic := '0';
        signal s_q2_sampler_empty : std_logic := '0';
        signal s_q3_sampler_empty : std_logic := '0';
        signal s_q4_sampler_empty : std_logic := '0';
        signal s_q1_sampler_full : std_logic := '0';
        signal s_q2_sampler_full : std_logic := '0';
        signal s_q3_sampler_full : std_logic := '0';
        signal s_q4_sampler_full : std_logic := '0';

        signal sl_gflow_success_flag       : std_logic := '0';
        signal sl_gflow_success_done       : std_logic;
        signal slv_alpha_to_math           : std_logic_vector(1 downto 0) := (others => '0');
        signal slv_sx_sz_to_math            : std_logic_vector(1 downto 0) := (others => '0');
        signal sl_actual_qubit_valid       : std_logic := '0';
        signal slv_actual_qubit            : std_logic_vector(1 downto 0) := (others => '0');
        signal slv_actual_qubit_time_stamp : std_logic_vector(st_transaction_data_max_width) := (others => '0');

        signal sl_pseudorandom_to_math  : std_logic := '0';
        signal slv_math_data_modulo            : std_logic_vector(1 downto 0) := (others => '0');
        signal sl_math_data_valid       : std_logic := '0';

        signal slv_modulo_to_sampl      : std_logic_vector(1 downto 0) := (others => '0');
        signal sl_delay_pulse_trigger   : std_logic := '0';
        signal s_valid_flags_uart_tx    : std_logic_vector(DELAY_GFLOW_TO_SAMPL_MOD-1 downto 0) := (others => '0');
        signal s_1MHz_pulse             : std_logic := '0';

        signal s_sampl_to_outl          : std_logic_vector(OUTPUT_PULSES_CNT-1 downto 0) := (others => '0');
        signal slv_out_1MHz_pulses      : std_logic_vector(1 downto 0) := (others => '0');


        -- Input_emulator
        signal EMUL_PHOTON_1H : std_logic := '0';
        signal EMUL_PHOTON_1V : std_logic := '0';
        signal EMUL_PHOTON_2H : std_logic := '0';
        signal EMUL_PHOTON_2V : std_logic := '0';
        signal EMUL_PHOTON_3H : std_logic := '0';
        signal EMUL_PHOTON_3V : std_logic := '0';
        signal EMUL_PHOTON_4H : std_logic := '0';
        signal EMUL_PHOTON_4V : std_logic := '0';


        -- To probe from uart_control
        signal sl_valid_pckt           : std_logic := '0';
        signal sl_uart_send_flag       : std_logic := '0';
        signal slv_probe_s_cnt_periods : std_logic_vector(9 downto 0) := (others => '0');


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

    begin


        ---------------------------
        -- OK FRONTPANEL Wire OR --
        ---------------------------
        -- okHost interface needs to be connected to user endpoints
        -- - A Gateway for FrontPanel to interact with user design
        -- - Contains the logic that lets the USB microcontroller on the device communicate with 
        --   the various endpoints within the design.
        -- The following signals need to be connected directly to pins on the FPGA 
        -- which go to the USB microcontroller 
        inst_ok_host_interf : entity lib_src.okHost
        port map (
            okUH=>okUH,     -- Input signals         : from USB Controller Host interface (from PC)
            okHU=>okHU,     -- Output signals        : to USB Controller Host interface (to PC)
            okUHU=>okUHU,   -- DATA IN/OUT           : to/from USB Controller Host interface
            okAA=>okAA,     -- FLAG IN/OUT           : to/from USB Controller Host interface
            okClk=>okClk,   -- Output synch CLK      : from 'okLibrary.vhd'; buffered copy of the host interface clock (100.8 MHz)
            okHE=>okHE,     -- Input Control signals : to user target endpoints (host to endpoint)
            okEH=>okEH      -- Output Control flag   : from user target endpoints (endpoint to host)
        );

        ---------------------------
        -- OK FRONTPANEL Wire OR --
        ---------------------------
        -- All endpoints on a single output bus 'okEHx' are OR-ed together, the output is 'okEH' bus
        -- -> Each endpoint (x) is told when it can send its data to the bus
        -- Available in library 'okLibrary.vhd'
        -- Multiple endpoints can share a bus without requiring the use of tristates or a large mux
        -- The OR-ed output goes to 'okEH'
        -- -> Set N to fit the number of OUTPUT endpoints in your design
        inst_ok_wire_or : entity lib_src.okWireOR
        generic map (
            N => OUT_ENDPTS_TOTAL_CNT
        ) 
        port map (
            okEH  => okEH,
            okEHx => okEHx
        );

        -----------------------------------------
        -- OK FRONTPANEL Wire In/Out Endpoints --
        -----------------------------------------
        -- Wire In (to FPGA)
        slv_pattern_code <= slv_win_ep00(4 downto 2);
        -- inst_wire_in_addr_00 : entity lib_src.okWireIn
        -- port map (
        --     okHE       => okHE,
        --     -- ep_addr    => std_logic_vector(to_unsigned(0, 8)),
        --     ep_addr    => std_logic_vector(to_unsigned(16#00#, 8)),
        --     ep_dataout => slv_win_ep00 -- slv_win_ep00 = reset + throttle_set
        -- );
        -- inst_wire_in_addr_01 : entity lib_src.okWireIn 
        -- port map (
        --     okHE       => okHE,
        --     ep_addr    => std_logic_vector(to_unsigned(16#01#, 8)),
        --     ep_dataout => slv_win_ep01_throttle_out
        -- );
        -- inst_wire_in_addr_02 : entity lib_src.okWireIn
        -- port map (
        --     okHE       => okHE,
        --     ep_addr    => std_logic_vector(to_unsigned(16#02#, 8)),
        --     ep_dataout => slv_win_ep02_throttle_in
        -- );
        -- inst_wire_in_addr_03 : entity lib_src.okWireIn
        -- port map (
        --     okHE       => okHE, 
        --     ep_addr    => std_logic_vector(to_unsigned(16#03#, 8)),
        --     ep_dataout => slv_win_ep03_fixed_pattern
        -- );

        -- Wire Out (from FPGA)
        slv_wout_ep20 <= x"12345678";
        -- inst_wire_out_addr_20 : entity lib_src.okWireOut
        -- port map (
        --     okHE      => okHE, 
        --     okEH      => okEHx( 1*65-1 downto 0*65 ), -- Common output bus loc to be OR-ed
        --     ep_addr   => std_logic_vector(to_unsigned(16#20#, 8)),
        --     ep_datain => slv_wout_ep20
        -- );

        -- -- led <= not slv_wout_ep21_rcv_errors(3 downto 0);
        -- inst_wire_out_addr_21 : entity lib_src.okWireOut
        -- port map (
        --     okHE      => okHE,
        --     okEH      => okEHx( 2*65-1 downto 1*65 ), -- Common output bus loc to be OR-ed
        --     ep_addr   => std_logic_vector(to_unsigned(16#21#, 8)),
        --     ep_datain => slv_wout_ep21_rcv_errors
        -- );

        -- slv_wout_ep3e <= CAPABILITY;
        -- inst_wire_out_addr_3e : entity lib_src.okWireOut   
        -- port map (
        --     okHE      => okHE,
        --     okEH      => okEHx( 3*65-1 downto 2*65 ), -- Common output bus loc to be OR-ed
        --     ep_addr   => std_logic_vector(to_unsigned(16#3e#, 8)),
        --     ep_datain => slv_wout_ep3e
        -- );

        -- slv_wout_ep3f <= x"beeff00d";
        -- inst_wire_out_addr_3f : entity lib_src.okWireOut   
        -- port map (
        --     okHE      => okHE,
        --     okEH      => okEHx( 4*65-1 downto 3*65 ), -- Common output bus loc to be OR-ed
        --     ep_addr   => std_logic_vector(to_unsigned(16#3f#, 8)),
        --     ep_datain => slv_wout_ep3f
        -- );


        -----------------------------------------
        -- OK FRONTPANEL Pipe In/Out Endpoints --
        -----------------------------------------
        -- okPipeIn endpoint:
        --     Frontpanel 'PC -> FPGA' Pipeline Interface
        --     For synchronous multi-byte data transfer from PC -> FPGA 
        --     (from host to the target endpoint)
        -- gen_pipe_in : if READ_FROM_FPGA_ONLY = false generate
        --     ep_80 : entity lib_src.okBTPipeIn
        --     port map (
        --         okHE	       => okHE,
        --         okEH	       => okEHx( 5*65-1 downto 4*65 ),
        --         ep_addr        => 16#80#,
        --         ep_write       => slv_pipe_in_endp_write_en,
        --         ep_blockstrobe => slv_blockstrobe_pipe_in,
        --         ep_dataout     => slv_pipe_in_endp_data,    -- DATA IN
        --         ep_ready       => slv_pipe_in_endp_ready    -- READY
        --     );
        -- end generate;

        -- okPipeOut endpoint: 
        --     Frontpanel 'FPGA -> PC' Pipeline Interface
        --     For synchronous multi-byte data transfer from FPGA -> PC
        --     (from target endpoint to the host)
        ep_A0 : entity lib_src.okBTPipeOut
        port map (
            okHE           => okHE,
            okEH           => okEHx( 5*65-1 downto 4*65 ),
            ep_addr        => std_logic_vector(to_unsigned(16#A0#, 8)),
            ep_read        => slv_pipe_out_endp_read_en,
            ep_blockstrobe => slv_blockstrobe_pipe_out,
            ep_datain      => slv_pipe_out_endp_data,   -- DATA OUT
            ep_ready       => slv_pipe_out_endp_ready   -- READY
        );



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

            -- Write endpoint signals: faster CLK, slower rate
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

            -- Read endpoint signals: slower CLK, faster rate
            rd_ok_clk     => okClk,
            rd_data_ready => slv_pipe_out_endp_ready,
            rd_enable     => slv_pipe_out_endp_read_en,
            rd_data_32b   => slv_pipe_out_endp_data,

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

        -- s_noisy_channels(7) = PHOTON 1H;
        -- s_noisy_channels(6) = PHOTON 1V;
        -- s_noisy_channels(5) = PHOTON 2H;
        -- s_noisy_channels(4) = PHOTON 2V;
        -- s_noisy_channels(3) = PHOTON 3H;
        -- s_noisy_channels(2) = PHOTON 3V;
        -- s_noisy_channels(1) = PHOTON 4H;
        -- s_noisy_channels(0) = PHOTON 4V;

        -- Input Buffers
        gen_emul_false : if EMULATE_INPUTS = false generate
            inst_xilinx_ibufs : entity lib_src.xilinx_ibufs(rtl)
            generic map (
                PINS_CNT => 8
            )
            port map (
                clk => sampl_clk,
                data_in => input_pads,
                data_out => s_noisy_channels
            );
        end generate;


        -- If Necessary, uncomment this input emulator for evaluation
        gen_emul_true : if EMULATE_INPUTS = true generate 
            inst_lfsr_inemul : entity lib_src.lfsr_inemul(rtl)
            generic map (
                -- RST_VAL           => RST_VAL,
                -- SYMBOL_WIDTH      => CHANNELS_CNT,
                -- REQUESTED_FREQ_HZ => REQUESTED_EMUL_FREQ_HZ,
                -- SYSTEMCLK_FREQ_HZ => SYSTEMCLK_EMUL_FREQ_HZ
                RST_VAL               => RST_VAL,
                SYMBOL_WIDTH          => CHANNELS_CNT,
                PRIM_POL_INT_VAL      => 501,
                GF_SEED               => 1,
                DATA_PULLDOWN_ENABLE  => true,
                PULLDOWN_CYCLES       => 2 -- min 2
            )
            port map (
                clk => sys_clk,
                rst => sl_rst_sysclk,
        
                ready => sl_inemul_ready,
                data_out => s_noisy_channels,
                valid_out => sl_inemul_valid
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

        -- Reset: sampl_clk domain
        -- inst_pullup_reset_samplclk : entity lib_src.pullup_reset(rtl)
        -- generic map (
        --     RST_STROBE_COUNTER_WIDTH => RST_STROBE_CNTR_WIDTH_SAMPLCLK
        -- )
        -- port map (
        --     CLK     => sampl_clk,
        --     IN_RST  => sl_rst,  -- Pullup
        --     OUT_RST => sl_rst_samplclk
        -- );

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
            noisy_channels_in => s_noisy_channels(7 downto 6),

            qubit_valid_250MHz => s_valid_qubits_stable_to_cdcc(3),
            qubit_250MHz => s_stable_channels_to_cdcc(7 downto 6)
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
            noisy_channels_in => s_noisy_channels(5 downto 4),

            qubit_valid_250MHz => s_valid_qubits_stable_to_cdcc(2),
            qubit_250MHz => s_stable_channels_to_cdcc(5 downto 4)
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
            noisy_channels_in => s_noisy_channels(3 downto 2),

            qubit_valid_250MHz => s_valid_qubits_stable_to_cdcc(1),
            qubit_250MHz => s_stable_channels_to_cdcc(3 downto 2)
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
            noisy_channels_in => s_noisy_channels(1 downto 0),

            qubit_valid_250MHz => s_valid_qubits_stable_to_cdcc(0),
            qubit_250MHz => s_stable_channels_to_cdcc(1 downto 0)
        );


        -- n-FF CDCC (Cross Domain Crossing Circuit)
        gen_nff_cdcc_sysclk : for i in 0 to QUBITS_CNT-1 generate
            inst_nff_cdcc_samplclk : entity lib_src.nff_cdcc(rtl)
            generic map (
                ASYNC_FLOPS_CNT => 2,
                DATA_WIDTH => 2,
                FLOPS_BEFORE_CROSSING_CNT => 1
            )
            port map (
                -- sampl_clk
                clk_write => sampl_clk,
                wr_en     => s_valid_qubits_stable_to_cdcc(i),
                wr_data   => s_stable_channels_to_cdcc((i+1)*2-1 downto i*2),

                -- sys_clk
                clk_read => sys_clk,
                rd_valid => slv_cdcc_rd_valid_to_fsm(i),
                rd_data  => slv_cdcc_rd_qubits_to_fsm((i+1)*2-1 downto i*2)
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
            PHOTON_4V_DELAY_NS      => PHOTON_4V_DELAY_NS
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
            actual_qubit_time_stamp   => slv_actual_qubit_time_stamp
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