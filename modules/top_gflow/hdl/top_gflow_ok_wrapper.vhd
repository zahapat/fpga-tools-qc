    -- top.vhd: Architecture of the FPGA part of the G-Flow protocol

    library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

    library UNISIM;
    use UNISIM.VComponents.all;
    
    library lib_src;
    use lib_src.FRONTPANEL.all;
    use lib_src.types_pack.all;

    entity top_gflow_ok_wrapper is
        generic(
            -- okHost generics
            CAPABILITY : std_logic_vector(31 downto 0) := x"00000001"; -- bitfield, used to indicate features supported by this bitfile

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
            PHOTON_5H_DELAY_NS     : real := -3177.95;
            PHOTON_5V_DELAY_NS     : real := -3181.05;
            PHOTON_6H_DELAY_NS     : real := -3177.95;
            PHOTON_6V_DELAY_NS     : real := -3181.05;
            PHOTON_7H_DELAY_NS     : real := -3177.95;
            PHOTON_7V_DELAY_NS     : real := -3181.05;
            PHOTON_8H_DELAY_NS     : real := -3177.95;
            PHOTON_8V_DELAY_NS     : real := -3181.05;

            WRITE_ON_VALID         : boolean := true
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

            -- Inputs from SPCM
            input_pads : in std_logic_vector(INPUT_PADS_CNT-1 downto 0);

            -- PCD Trigger
            output_pads : out std_logic_vector(OUTPUT_PADS_CNT-1 downto 0)

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
        inst_gflow : entity lib_src.top_gflow(str)
        generic map (
            -- Gflow generics
            RST_VAL => RST_VAL,
            CLK_SYS_HZ => CLK_SYS_HZ,
            CLK_SAMPL_HZ => CLK_SAMPL_HZ,

            QUBITS_CNT => QUBITS_CNT,

            INPUT_PADS_CNT => INPUT_PADS_CNT,
            OUTPUT_PADS_CNT => OUTPUT_PADS_CNT,

            -- Parameters in user GUI
            EMULATE_INPUTS => EMULATE_INPUTS,
            PHOTON_1H_DELAY_NS => PHOTON_1H_DELAY_NS,
            PHOTON_1V_DELAY_NS => PHOTON_1V_DELAY_NS,
            PHOTON_2H_DELAY_NS => PHOTON_2H_DELAY_NS,
            PHOTON_2V_DELAY_NS => PHOTON_2V_DELAY_NS,
            PHOTON_3H_DELAY_NS => PHOTON_3H_DELAY_NS,
            PHOTON_3V_DELAY_NS => PHOTON_3V_DELAY_NS,
            PHOTON_4H_DELAY_NS => PHOTON_4H_DELAY_NS,
            PHOTON_4V_DELAY_NS => PHOTON_4V_DELAY_NS,
            PHOTON_5H_DELAY_NS => PHOTON_5H_DELAY_NS,
            PHOTON_5V_DELAY_NS => PHOTON_5V_DELAY_NS,
            PHOTON_6H_DELAY_NS => PHOTON_6H_DELAY_NS,
            PHOTON_6V_DELAY_NS => PHOTON_6V_DELAY_NS,
            PHOTON_7H_DELAY_NS => PHOTON_7H_DELAY_NS,
            PHOTON_7V_DELAY_NS => PHOTON_7V_DELAY_NS,
            PHOTON_8H_DELAY_NS => PHOTON_8H_DELAY_NS,
            PHOTON_8V_DELAY_NS => PHOTON_8V_DELAY_NS,

            WRITE_ON_VALID => WRITE_ON_VALID
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

            -- Inputs from SPCM
            input_pads => input_pads,

            -- PCD Trigger
            output_pads => output_pads
        );

    end architecture;