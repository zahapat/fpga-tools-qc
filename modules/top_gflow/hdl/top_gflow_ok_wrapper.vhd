    -- top.vhd: Architecture of the FPGA part of the G-Flow protocol

    library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

    library UNISIM;
    use UNISIM.VComponents.all;

    library lib_src;
    use lib_src.FRONTPANEL.all;
    use lib_src.types_pack.all;
    use lib_src.generics.all;

    entity top_gflow_ok_wrapper is
        generic(
            -- okHost generics
            CAPABILITY : std_logic_vector(31 downto 0) := x"00000001"; -- bitfield, used to indicate features supported by this bitfile

            -- Gflow generics
            RST_VAL                : std_logic := '1';

            INT_QUBITS_CNT         : positive := INT_QUBITS_CNT;

            -- Integer parameters from Makefile
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
            INT_CTRL_PULSE_EXTRA_DELAY_Q6_NS : integer := INT_CTRL_PULSE_EXTRA_DELAY_Q6_NS -- EOM Control Pulse Design to catch qubit 6
        );
        port (

            -- External 200MHz oscillator
            sys_clk_p : in std_logic;
            sys_clk_n : in std_logic;

            -- okHost signals
            okUH  : in    std_logic_vector(4 downto 0);
            okHU  : out   std_logic_vector(2 downto 0);
            okUHU : inout std_logic_vector(31 downto 0);
            okAA  : inout std_logic;

            -- Debug LEDs
            led : out std_logic_vector(3 downto 0);

            -- Inputs from Detectors
            input_pads : in std_logic_vector(2*INT_QUBITS_CNT-1 downto 0);

            -- PCD Trigger & valid signal for IO delay measurements
            o_eom_ctrl_pulse : out std_logic;
            -- o_eom_ctrl_pulsegen_busy : out std_logic;  -- for propagation delay measurements
            o_debug_port_1 : out std_logic;      -- Debug port 1
            o_debug_port_2 : out std_logic;      -- Debug port 2
            o_debug_port_3 : out std_logic       -- Debug port 3

        );
    end top_gflow_ok_wrapper;

    architecture str of top_gflow_ok_wrapper is


        -------------------------------
        -- Opal Kelly okHost signals --
        -------------------------------
        constant OUT_ENDPTS_TOTAL_CNT : integer := 5;

        signal okClk : std_logic := '0';
        signal okHE  : std_logic_vector(112 downto 0) := (others => '0');
        signal okEH  : std_logic_vector(64 downto 0) := (others => '0');

        -- Number of outgoing endpoints in your design (n*65-1 downto 0)
        signal okEHx : std_logic_vector(OUT_ENDPTS_TOTAL_CNT*65-1 downto 0);

        -- Endpoint: TriggerIn
        signal slv_tin_ep40 : std_logic_vector(32-1 downto 0);  --:= (others => '0');

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


    begin


        ------------------
        -- OK FRONTPANEL--
        ------------------
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

        ---------------------------
        -- OK FRONTPANEL Trigger --
        ---------------------------
        -- Trigger In (to FPGA)
        inst_trigger_in_addr40 : entity lib_src.okTriggerIn
        port map (
            okHE       => okHE,
            ep_addr    => std_logic_vector(to_unsigned(16#40#, 8)), -- x"40",
            -- ep_addr    => std_logic_vector(to_unsigned(16#00#, 8)),
            ep_clk     => okClk,
            ep_trigger => slv_tin_ep40
        );

        -----------------------------------------
        -- OK FRONTPANEL Wire In/Out Endpoints --
        -----------------------------------------
        -- Wire In (to FPGA)
        slv_pattern_code <= slv_win_ep00(4 downto 2);
        inst_wire_in_addr_00 : entity lib_src.okWireIn
        port map (
            okHE       => okHE,
            ep_addr    => std_logic_vector(to_unsigned(16#00#, 8)),
            ep_dataout => slv_win_ep00 -- slv_win_ep00 = reset + throttle_set
        );
        inst_wire_in_addr_01 : entity lib_src.okWireIn 
        port map (
            okHE       => okHE,
            ep_addr    => std_logic_vector(to_unsigned(16#01#, 8)),
            ep_dataout => slv_win_ep01_throttle_out
        );
        inst_wire_in_addr_02 : entity lib_src.okWireIn
        port map (
            okHE       => okHE,
            ep_addr    => std_logic_vector(to_unsigned(16#02#, 8)),
            ep_dataout => slv_win_ep02_throttle_in
        );
        inst_wire_in_addr_03 : entity lib_src.okWireIn
        port map (
            okHE       => okHE, 
            ep_addr    => std_logic_vector(to_unsigned(16#03#, 8)),
            ep_dataout => slv_win_ep03_fixed_pattern
        );

        -- Wire Out (from FPGA)
        slv_wout_ep20 <= x"12345678";
        inst_wire_out_addr_20 : entity lib_src.okWireOut
        port map (
            okHE      => okHE, 
            okEH      => okEHx( 1*65-1 downto 0*65 ), -- Common output bus loc to be OR-ed
            ep_addr   => std_logic_vector(to_unsigned(16#20#, 8)),
            ep_datain => slv_wout_ep20
        );

        -- -- led <= not slv_wout_ep21_rcv_errors(3 downto 0);
        inst_wire_out_addr_21 : entity lib_src.okWireOut
        port map (
            okHE      => okHE,
            okEH      => okEHx( 2*65-1 downto 1*65 ), -- Common output bus loc to be OR-ed
            ep_addr   => std_logic_vector(to_unsigned(16#21#, 8)),
            ep_datain => slv_wout_ep21_rcv_errors
        );

        slv_wout_ep3e <= CAPABILITY;
        inst_wire_out_addr_3e : entity lib_src.okWireOut   
        port map (
            okHE      => okHE,
            okEH      => okEHx( 3*65-1 downto 2*65 ), -- Common output bus loc to be OR-ed
            ep_addr   => std_logic_vector(to_unsigned(16#3e#, 8)),
            ep_datain => slv_wout_ep3e
        );

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
        ep_80 : entity lib_src.okBTPipeIn
        port map (
            okHE	       => okHE,
            okEH	       => okEHx( 4*65-1 downto 3*65 ),
            ep_addr        => std_logic_vector(to_unsigned(16#80#, 8)),
            ep_write       => slv_pipe_in_endp_write_en,
            ep_blockstrobe => slv_blockstrobe_pipe_in,
            ep_dataout     => slv_pipe_in_endp_data,    -- DATA IN
            ep_ready       => slv_pipe_in_endp_ready    -- READY
        );

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


        -----------------
        -- G-Flow Core --
        -----------------
        inst_top_gflow : entity lib_src.top_gflow(str)
        generic map (
            -- Gflow generics
            RST_VAL => RST_VAL,

            INT_QUBITS_CNT => INT_QUBITS_CNT,
            INT_EMULATE_INPUTS => INT_EMULATE_INPUTS,
            INT_ALL_DIGITS_PHOTON_1H_DELAY_NS    => INT_ALL_DIGITS_PHOTON_1H_DELAY_NS,
            INT_ALL_DIGITS_PHOTON_1V_DELAY_NS    => INT_ALL_DIGITS_PHOTON_1V_DELAY_NS,
            INT_WHOLE_DIGITS_CNT_PHOTON_1H_DELAY => INT_WHOLE_DIGITS_CNT_PHOTON_1H_DELAY,
            INT_WHOLE_DIGITS_CNT_PHOTON_1V_DELAY => INT_WHOLE_DIGITS_CNT_PHOTON_1V_DELAY,
            INT_ALL_DIGITS_PHOTON_2H_DELAY_NS    => INT_ALL_DIGITS_PHOTON_2H_DELAY_NS,
            INT_ALL_DIGITS_PHOTON_2V_DELAY_NS    => INT_ALL_DIGITS_PHOTON_2V_DELAY_NS,
            INT_WHOLE_DIGITS_CNT_PHOTON_2H_DELAY => INT_WHOLE_DIGITS_CNT_PHOTON_2H_DELAY,
            INT_WHOLE_DIGITS_CNT_PHOTON_2V_DELAY => INT_WHOLE_DIGITS_CNT_PHOTON_2V_DELAY,
            INT_ALL_DIGITS_PHOTON_3H_DELAY_NS    => INT_ALL_DIGITS_PHOTON_3H_DELAY_NS,
            INT_ALL_DIGITS_PHOTON_3V_DELAY_NS    => INT_ALL_DIGITS_PHOTON_3V_DELAY_NS,
            INT_WHOLE_DIGITS_CNT_PHOTON_3H_DELAY => INT_WHOLE_DIGITS_CNT_PHOTON_3H_DELAY,
            INT_WHOLE_DIGITS_CNT_PHOTON_3V_DELAY => INT_WHOLE_DIGITS_CNT_PHOTON_3V_DELAY,
            INT_ALL_DIGITS_PHOTON_4H_DELAY_NS    => INT_ALL_DIGITS_PHOTON_4H_DELAY_NS,
            INT_ALL_DIGITS_PHOTON_4V_DELAY_NS    => INT_ALL_DIGITS_PHOTON_4V_DELAY_NS,
            INT_WHOLE_DIGITS_CNT_PHOTON_4H_DELAY => INT_WHOLE_DIGITS_CNT_PHOTON_4H_DELAY,
            INT_WHOLE_DIGITS_CNT_PHOTON_4V_DELAY => INT_WHOLE_DIGITS_CNT_PHOTON_4V_DELAY,
            INT_ALL_DIGITS_PHOTON_5H_DELAY_NS    => INT_ALL_DIGITS_PHOTON_5H_DELAY_NS,
            INT_ALL_DIGITS_PHOTON_5V_DELAY_NS    => INT_ALL_DIGITS_PHOTON_5V_DELAY_NS,
            INT_WHOLE_DIGITS_CNT_PHOTON_5H_DELAY => INT_WHOLE_DIGITS_CNT_PHOTON_5H_DELAY,
            INT_WHOLE_DIGITS_CNT_PHOTON_5V_DELAY => INT_WHOLE_DIGITS_CNT_PHOTON_5V_DELAY,
            INT_ALL_DIGITS_PHOTON_6H_DELAY_NS    => INT_ALL_DIGITS_PHOTON_6H_DELAY_NS,
            INT_ALL_DIGITS_PHOTON_6V_DELAY_NS    => INT_ALL_DIGITS_PHOTON_6V_DELAY_NS,
            INT_WHOLE_DIGITS_CNT_PHOTON_6H_DELAY => INT_WHOLE_DIGITS_CNT_PHOTON_6H_DELAY,
            INT_WHOLE_DIGITS_CNT_PHOTON_6V_DELAY => INT_WHOLE_DIGITS_CNT_PHOTON_6V_DELAY,

            -- PCD Control Pulse Design & Delay
            INT_CTRL_PULSE_HIGH_DURATION_NS => INT_CTRL_PULSE_HIGH_DURATION_NS,
            INT_CTRL_PULSE_DEAD_DURATION_NS => INT_CTRL_PULSE_DEAD_DURATION_NS,
            INT_CTRL_PULSE_EXTRA_DELAY_Q2_NS => INT_CTRL_PULSE_EXTRA_DELAY_Q2_NS,
            INT_CTRL_PULSE_EXTRA_DELAY_Q3_NS => INT_CTRL_PULSE_EXTRA_DELAY_Q3_NS,
            INT_CTRL_PULSE_EXTRA_DELAY_Q4_NS => INT_CTRL_PULSE_EXTRA_DELAY_Q4_NS,
            INT_CTRL_PULSE_EXTRA_DELAY_Q5_NS => INT_CTRL_PULSE_EXTRA_DELAY_Q5_NS,
            INT_CTRL_PULSE_EXTRA_DELAY_Q6_NS => INT_CTRL_PULSE_EXTRA_DELAY_Q6_NS
        )
        port map (
            -- External 200MHz oscillator
            sys_clk_p => sys_clk_p,
            sys_clk_n => sys_clk_n,

            -- Debug LEDs
            led => led,

            -- Optional: Readout Endpoint Signals
            readout_clk        => okClk,
            readout_data_ready => slv_pipe_out_endp_ready,
            readout_enable     => slv_pipe_out_endp_read_en,
            readout_data_32b   => slv_pipe_out_endp_data,

            -- Inputs from Detectors
            input_pads => input_pads,

            -- Feedforward control
            i_enable_feedforward => slv_tin_ep40(0),
            -- i_enable_feedforward => '1',
            i_rand_feedforward => slv_tin_ep40(INT_QUBITS_CNT downto 1),
            -- i_rand_feedforward => (others => '0'),

            -- PCD Trigger
            o_eom_ctrl_pulse => o_eom_ctrl_pulse,
            o_eom_ctrl_pulsegen_busy => open,
            o_debug_port_1 => o_debug_port_1,
            o_debug_port_2 => o_debug_port_2,
            o_debug_port_3 => o_debug_port_3
        );

    end architecture;