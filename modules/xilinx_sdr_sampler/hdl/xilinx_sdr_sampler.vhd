    library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;
    use ieee.math_real.all;

    library UNISIM;
    use UNISIM.VComponents.all;

    entity xilinx_sdr_sampler is
        generic (
            SELECT_PRIMITIVE : natural := 0;                      -- 1 = FDRE, 2 = IDDR_2CLK, 3 = ISERDESE2, 4=ISERDESE2+IDELAY, 0 = All (Simulation Purposes)
            INT_IDELAY_TAPS : integer := 0;
            REAL_IDELAY_REFCLK_FREQUENCY : real := 200.0
        );
        port (
            -- Clocks
            clk : in std_logic;                                   -- 0 degrees phase-shift (always connect)
            clk90 : in std_logic;                                 -- 90 degrees phase-shift (only for ISERDESE2)
            clk180 : in std_logic;                                -- 180 degrees phase-shift (only for IDDR_2CLK)
            clk_idelay : in std_logic;                            -- Clock at a frequency specified by REAL_IDELAY_REFCLK_FREQUENCY
            -- Input Data
            in_pad : in std_logic;                                -- FPGA pad (top-level input)
            in_reset_iserdese2 : in std_logic;                    -- Reset for ISERDESE2 to initialize outputs
            in_enable_iserdese2 : in std_logic;                   -- Enable for ISERDESE2 to enable outputs
            -- Output Data
            out_data_fdre : out std_logic;                        -- Data from the FDRE Primitive (maped to IFF)
            out_data_iddr_2clk : out std_logic_vector(2-1 downto 0); -- Data from the IDDR_2CLK Primitive
            out_data_iserdese2 : out std_logic_vector(4-1 downto 0)
        );
    end xilinx_sdr_sampler;

    architecture rtl of xilinx_sdr_sampler is

        -- Xilinx FDRE Primitive
        component FDRE port (
            D  : in    std_logic;
            C  : in    std_logic;
            CE : in    std_logic;
            R  : in    std_logic;
            Q  : out   std_logic
        );
        end component;
        attribute IOB: string;
        attribute IOB of FDRE  : component is "TRUE";

        -- FPGA Pad
        signal sl_pad : std_logic := '0';

        -- IBUF
        signal sl_data_ibuf_out : std_logic := '0';

        -- FDRE
        signal sl_out_data_fdre : std_logic := '0';

        -- IDDR2_2CLK
        signal slv_out_data_iddr_2clk : std_logic_vector(2-1 downto 0) := (others => '0');

        -- ISERDESE2
        -- "std_logic" array into "std_logic_vector" conversion
        type t_channels_iserdes_2d is array (4-1 downto 0) of std_logic;
        impure function sl_array_to_slv (
            constant ARR_WIDTH : positive;
            signal std_logic_array : t_channels_iserdes_2d
        ) return std_logic_vector is
            variable v_std_logic_vector : std_logic_vector(ARR_WIDTH-1 downto 0) := (others => '0');
        begin
            for i in 0 to ARR_WIDTH-1 loop
                v_std_logic_vector(i) := std_logic_array(i);
            end loop;
            return v_std_logic_vector;
        end function;

        signal clkb : std_logic := '0';
        signal clk90b : std_logic := '0';
        signal sl_out_data_iserdese2_2d : t_channels_iserdes_2d := (others => '0');
        signal slv_out_data_iserdese2 : std_logic_vector(4-1 downto 0) := (others => '0');

        -- IDELAYE2
        signal sl_idelay_to_iserdes : std_logic := '0';
        signal slv_idelay_taps : std_logic_vector(5-1 downto 0) := (others => '0');

        -- Attributes
        attribute KEEP_HIERARCHY : string;
        attribute KEEP_HIERARCHY of rtl : architecture is "YES";
    begin

        -- Generate IBUFs with pullup logic
        sl_pad <= in_pad;

        -- Connect to entity outputs
        out_data_fdre <= sl_out_data_fdre;
        out_data_iddr_2clk <= slv_out_data_iddr_2clk;
        slv_out_data_iserdese2 <= sl_array_to_slv(4, sl_out_data_iserdese2_2d);
        out_data_iserdese2 <= slv_out_data_iserdese2;

        -- Input data signal buffer (always placed)
        inst_IBUF_sdr_sampler : IBUF
        port map (
            I => sl_pad,
            O => sl_data_ibuf_out
        );

        -- Use ILOGIC IFF cell
        gen_FDRE : if ((SELECT_PRIMITIVE = 1) or (SELECT_PRIMITIVE = 0)) generate
            inst_FDRE_sdr_sampler: FDRE
            port map (
                D => sl_data_ibuf_out,
                Q => sl_out_data_fdre,
                C => clk,
                CE => '1',
                R=>'0'
            );
        end generate;


        gen_IDDR_2CLK : if ((SELECT_PRIMITIVE = 2) or (SELECT_PRIMITIVE = 0)) generate
            inst_IDDR_2CLK_sdr_sampler : IDDR_2CLK
            generic map (
                --  DDR_CLK_EDGE attribute:
                --  "OPPOSITE_EDGE": Given a DDR data and clock at pin D and C respectively, 
                --              Q1 changes after every positive edge of clock C, and Q2 
                --              changes after every positive edge of clock CB
                --  "SAME_EDGE": An extra register has been placed in front of the CB clocked 
                --              data register. DDR data is now presented into the FPGA fabric 
                --              at the positive edge of clock C
                --              Note: Q1 and Q2 no longer have pair 1 and 2. Instead, the 
                --              first pair presented is Pair 1 and DON'T CARE, followed by 
                --              Pair 2 and 3 at the next clock cycle.
                --  "SAME_EDGE_PIPELINED": An extra register has been placed in front of the 
                --              C clocked data register. A data pair now appears at the Q1 
                --              and Q2 pin at the same time during the positive edge of C. 
                --              Note: However, using this mode requires an additional cycle 
                --              of latency for Q1 and Q2 signals to change.
                DDR_CLK_EDGE => "SAME_EDGE_PIPELINED", -- "SAME_EDGE_PIPELINED" = Metastability resolution
                INIT_Q1 => '0',                 -- Initial value of Q1: '0' or '1'
                INIT_Q2 => '0',                 -- Initial value of Q2: '0' or '1'
                SRTYPE => "SYNC")               -- Set/Reset type: "SYNC" or "ASYNC"
            port map (
                CE => '1',                      -- 1-bit input: active high enables clock input
                C => clk,                       -- 1-bit input: primary clock input
                CB => clk180,                  -- 1-bit input: secondary clock input (do not use CLKOUTXB as it is allegedly inverted twice, deteriorating the performance)
                R => '0',                       -- 1-bit input: active high reset sets outputs to logical one
                S => '0',                       -- 1-bit input: active high set sets outputs to logical zero
                D => sl_data_ibuf_out,          -- 1-bit input: DDR data input
                Q1 => slv_out_data_iddr_2clk(0),    -- 1-bit output: for positive edge of clock
                Q2 => slv_out_data_iddr_2clk(1)     -- 1-bit output: for negative edge of clock
            );
        end generate;


        gen_ISERDESE2 : if ((SELECT_PRIMITIVE = 3) or (SELECT_PRIMITIVE = 0)) generate

            -- Create inversed clocks
            clkb <= not clk;
            clk90b <= not clk90;

            inst_ISERDESE2_sdr_sampler : ISERDESE2
            generic map (
                INTERFACE_TYPE => "OVERSAMPLE", -- MEMORY, MEMORY_DDR3, MEMORY_QDR, NETWORKING, OVERSAMPLE
                DATA_RATE => "DDR",             -- DDR, SDR
                DATA_WIDTH => 4,                -- Parallel data width (2-8,10,14)
                DYN_CLKDIV_INV_EN => "FALSE",   -- Enable DYNCLKDIVINVSEL inversion (FALSE, TRUE)
                DYN_CLK_INV_EN => "FALSE",      -- Enable DYNCLKINVSEL inversion (FALSE, TRUE)
                INIT_Q1 => '0',                 -- Initial value on the Q output (0/1)
                INIT_Q2 => '0',                 -- Initial value on the Q output (0/1)
                INIT_Q3 => '0',                 -- Initial value on the Q output (0/1)
                INIT_Q4 => '0',                 -- Initial value on the Q output (0/1)
                IOBDELAY => "NONE",             -- ["NONE": O=>D | Q1-Q6=>D];  ["IBUF": O=>DDLY | Q1-Q6=>D];  ["IFD": O=>D | Q1-Q6=>DDLY];  ["BOTH": O=>DDLY | Q1-Q6=>DDLY]
                NUM_CE => 1,                    -- Number of clock enables (1,2)
                OFB_USED => "FALSE",            -- Enables ("TRUE") the path from the OLOGIC, OSERDESE2 OFB pin to the ISERDESE2 OFB pin and disables the use of the D input pin.
                SERDES_MODE => "MASTER",        -- Specifies whether the ISERDESE2 module is a master or slave when using width expansion. Set to "MASTER" when not using width expansion.
                SRVAL_Q1 => '0',                -- Q output value when SR is used (0/1)
                SRVAL_Q2 => '0',                -- Q output value when SR is used (0/1)
                SRVAL_Q3 => '0',                -- Q output value when SR is used (0/1)
                SRVAL_Q4 => '0'                 -- Q output value when SR is used (0/1)
            ) port map (
                D => sl_data_ibuf_out,          -- 1-bit input: Data input
                DDLY => '0',                    -- 1-bit input: Serial data from IDELAYE2
                CE1 => in_enable_iserdese2,     -- 1-bit input: Data register clock enable input
                CE2 => '1',                     -- 1-bit input: Data register clock enable input
                CLK => clk,                     -- 1-bit input: High-speed clock used to clock in the input serial data stream
                CLKB => clkb,                   -- 1-bit input: High-speed secondary clock used to clock in the input serial data stream. In any mode other than "MEMORY_QDR", connect CLKB to an inverted version of CLK. In "MEMORY_QDR" mode CLKB should be connected to a unique, phase shifted clock
                CLKDIV => '0',                  -- 1-bit input: The divided clock input (CLKDIV) is typically a divided version of CLK (depending on the width of the implemented deserialization). 
                                                --              It drives the output of the serial-to-parallel converter, the Bitslip submodule, and the CE module
                CLKDIVP => '0',                 -- 1-bit input: Only supported in MIG. Sourced by PHASER_IN divided CLK in MEMORY_DDR3 mode. All other modes connect to ground
                RST => in_reset_iserdese2,      -- 1-bit input: Active high asynchronous reset 
                                                    --              Note: MUST be applied for a longer period
                O => open,                          -- 1-bit output: The combinatorial output port (O) is an UNregistered output of the ISERDESE2 module. This output can come directly from the data input (D), or from the data input (DDLY) via the IDELAYE2.
                Q1 => sl_out_data_iserdese2_2d(0),  -- (=T+0deg   = Sample 1 clocked by CLK) 1-bit (each) output: The output ports Q1 to Q8 are the registered outputs of the ISERDESE2 module. 
                Q2 => sl_out_data_iserdese2_2d(1),  -- (=T+180deg = Sample 3 clocked by OCLK)                     One ISERDESE2 block can support up to eight bits (i.e., a 1:8 deserialization). 
                Q3 => sl_out_data_iserdese2_2d(2),  -- (=T+90deg  = Sample 2 clocked by CLKB)                     Bit widths greater than eight (up to 14) can be supported using Width Expansion.
                Q4 => sl_out_data_iserdese2_2d(3),  -- (=T+270deg = Sample 4 clocked by OCLKB)                    The first data bit received appears on the highest order Q output. The bit 
                Q5 => open,                         --                                                            ordering at the input of an OSERDESE2 is the opposite of the bit ordering at
                Q6 => open,                         --                                                            the output of an ISERDESE2 block.
                Q7 => open, 
                Q8 => open, 
                SHIFTIN1 => '0',                -- 1-bit (each) input: Data width expansion input ports
                SHIFTIN2 => '0',                --                     If SERDES_MODE="SLAVE", connect SHIFTIN1/2 to the master ISERDESE2 SHIFTOUT1/2 outputs. Otherwise, leave SHIFTOUT1/2 unconnected and/or SHIFTIN1/2 grounded
                SHIFTOUT1 => open,              -- 1-bit (each) output: Data width expansion output ports
                SHIFTOUT2 => open,              --                      If SERDES_MODE="MASTER" and two ISERDESE2s are to be cascaded, connect SHIFTOUT1/2 to the slave ISERDESE2 SHIFTIN1/2 inputs
                DYNCLKDIVSEL => '0',            -- 1-bit input: Dynamically select CLKDIV inversion
                DYNCLKSEL => '0',               -- 1-bit input: Dynamically select CLK and CLKB inversion
                OFB => '0',                     -- 1-bit input: Data feedback from OSERDESE2; The serial input data port (OFB) is the serial (high-speed) data input port of the ISERDESE2. This port works in conjunction only with the 7 series FPGA OSERDESE2 port OFB
                OCLK => clk90,                  -- 1-bit input: The OCLK clock input synchronizes data transfer in strobe-based memory interfaces. The OCLK clock is only used when INTERFACE_TYPE is set to "MEMORY". The OCLK clock input is used to transfer strobe-based memory data onto a free-running clock domain
                                                --              OCLK is a free-running FPGA clock at the same frequency as the strobe on the CLK input. The timing of the domain transfer is set by the user by adjusting the delay of the strobe signal to the CLK input (e.g., using IDELAY). Examples of setting the 
                                                --              timing of this domain transfer are given in the Memory Interface Generator (MIG). When INTERFACE_TYPE is "NETWORKING", this port is unused and should be connected to GND.
                OCLKB => clk90b,                -- 1-bit input: The OCLK clock input synchronizes data transfer in strobe-based memory interfaces. The OCLKB clock is only used when INTERFACE_TYPE is set to "MEMORY".
                BITSLIP => '0'                  -- 1-bit input: The BITSLIP pin performs a Bitslip operation synchronous to
                                                -- CLKDIV when asserted (active High). Subsequently, the data seen on the
                                                -- Q1 to Q8 output ports will shift, as in a barrel-shifter operation, one
                                                -- position every time Bitslip is invoked (DDR operation is different from
                                                -- SDR).
            );
        end generate;


        gen_ISERDESE2_IDELAY : if ((SELECT_PRIMITIVE = 4) or (SELECT_PRIMITIVE = 0)) generate

            -- Create inversed clocks
            clkb <= not clk;
            clk90b <= not clk90;

            -- Instantiate IDELAY
            slv_idelay_taps <= std_logic_vector(to_unsigned(INT_IDELAY_TAPS, 5));
            IDELAYE2_inst : IDELAYE2
            generic map (
                IDELAY_TYPE => "FIXED",           -- FIXED, VARIABLE, VAR_LOAD, VAR_LOAD_PIPE
                IDELAY_VALUE => INT_IDELAY_TAPS,      -- Input delay tap setting (0-31)
                HIGH_PERFORMANCE_MODE => "TRUE",  -- Reduced jitter ("TRUE"), Reduced power ("FALSE")
                REFCLK_FREQUENCY => REAL_IDELAY_REFCLK_FREQUENCY,  -- IDELAYCTRL clock input frequency in MHz (190.0-210.0, 290.0-310.0).
                CINVCTRL_SEL => "FALSE",          -- Enable dynamic clock inversion (FALSE, TRUE)
                SIGNAL_PATTERN => "DATA",         -- DATA, CLOCK input signal
                DELAY_SRC => "IDATAIN",           -- Delay input (IDATAIN, DATAIN)
                PIPE_SEL => "FALSE"               -- Select pipelined mode, FALSE, TRUE
            )
            port map (
                C => clk_idelay,                 -- 1-bit input: Clock input
                LD => '0',                       -- 1-bit input: Load IDELAY_VALUE input
                LDPIPEEN => '0',                 -- 1-bit input: Enable PIPELINE register to load data input
                REGRST => '0',                   -- 1-bit input: Active-high reset tap-delay input
                CE => '0',                       -- 1-bit input: Active high enable increment/decrement input
                INC => '0',                      -- 1-bit input: Increment / Decrement tap delay input
                CINVCTRL => '0',                 -- 1-bit input: Dynamic clock inversion input
                CNTVALUEIN => slv_idelay_taps,   -- 5-bit input: Counter value input
                IDATAIN => sl_data_ibuf_out,     -- 1-bit input: Data input from the I/O
                DATAIN => '0',                   -- 1-bit input: Internal delay data input
                DATAOUT => sl_idelay_to_iserdes, -- 1-bit output: Delayed data output
                CNTVALUEOUT => open              -- 5-bit output: Counter value output
            );

            inst_ISERDESE2_sdr_sampler : ISERDESE2
            generic map (
                INTERFACE_TYPE => "OVERSAMPLE", -- MEMORY, MEMORY_DDR3, MEMORY_QDR, NETWORKING, OVERSAMPLE
                DATA_RATE => "DDR",             -- DDR, SDR
                DATA_WIDTH => 4,                -- Parallel data width (2-8,10,14)
                DYN_CLKDIV_INV_EN => "FALSE",   -- Enable DYNCLKDIVINVSEL inversion (FALSE, TRUE)
                DYN_CLK_INV_EN => "FALSE",      -- Enable DYNCLKINVSEL inversion (FALSE, TRUE)
                INIT_Q1 => '0',                 -- Initial value on the Q output (0/1)
                INIT_Q2 => '0',                 -- Initial value on the Q output (0/1)
                INIT_Q3 => '0',                 -- Initial value on the Q output (0/1)
                INIT_Q4 => '0',                 -- Initial value on the Q output (0/1)
                IOBDELAY => "IFD",              -- ["NONE": O=>D | Q1-Q6=>D];  ["IBUF": O=>DDLY | Q1-Q6=>D];  ["IFD": O=>D | Q1-Q6=>DDLY];  ["BOTH": O=>DDLY | Q1-Q6=>DDLY]
                NUM_CE => 1,                    -- Number of clock enables (1,2)
                OFB_USED => "FALSE",            -- Enables ("TRUE") the path from the OLOGIC, OSERDESE2 OFB pin to the ISERDESE2 OFB pin and disables the use of the D input pin.
                SERDES_MODE => "MASTER",        -- Specifies whether the ISERDESE2 module is a master or slave when using width expansion. Set to "MASTER" when not using width expansion.
                SRVAL_Q1 => '0',                -- Q output value when SR is used (0/1)
                SRVAL_Q2 => '0',                -- Q output value when SR is used (0/1)
                SRVAL_Q3 => '0',                -- Q output value when SR is used (0/1)
                SRVAL_Q4 => '0'                 -- Q output value when SR is used (0/1)
            ) port map (
                D => '0',                       -- 1-bit input: Data input
                DDLY => sl_idelay_to_iserdes,   -- 1-bit input: Serial data from IDELAYE2
                CE1 => in_enable_iserdese2,     -- 1-bit input: Data register clock enable input -- SETUP SLACK!
                CE2 => '1',                     -- 1-bit input: Data register clock enable input
                CLK => clk,                     -- 1-bit input: High-speed clock used to clock in the input serial data stream
                CLKB => clkb,                   -- 1-bit input: High-speed secondary clock used to clock in the input serial data stream. In any mode other than "MEMORY_QDR", connect CLKB to an inverted version of CLK. In "MEMORY_QDR" mode CLKB should be connected to a unique, phase shifted clock
                CLKDIV => '0',                  -- 1-bit input: The divided clock input (CLKDIV) is typically a divided version of CLK (depending on the width of the implemented deserialization). 
                                                --              It drives the output of the serial-to-parallel converter, the Bitslip submodule, and the CE module
                CLKDIVP => '0',                 -- 1-bit input: Only supported in MIG. Sourced by PHASER_IN divided CLK in MEMORY_DDR3 mode. All other modes connect to ground
                RST => in_reset_iserdese2,      -- 1-bit input: Active high asynchronous reset 
                                                    --              Note: MUST be applied for a longer period
                O => open,                          -- 1-bit output: The combinatorial output port (O) is an UNregistered output of the ISERDESE2 module. This output can come directly from the data input (D), or from the data input (DDLY) via the IDELAYE2.
                Q1 => sl_out_data_iserdese2_2d(0),  -- (=T+0deg   = Sample 1 clocked by CLK) 1-bit (each) output: The output ports Q1 to Q8 are the registered outputs of the ISERDESE2 module. 
                Q2 => sl_out_data_iserdese2_2d(1),  -- (=T+180deg = Sample 3 clocked by OCLK)                     One ISERDESE2 block can support up to eight bits (i.e., a 1:8 deserialization). 
                Q3 => sl_out_data_iserdese2_2d(2),  -- (=T+90deg  = Sample 2 clocked by CLKB)                     Bit widths greater than eight (up to 14) can be supported using Width Expansion.
                Q4 => sl_out_data_iserdese2_2d(3),  -- (=T+270deg = Sample 4 clocked by OCLKB)                    The first data bit received appears on the highest order Q output. The bit 
                Q5 => open,                         --                                                            ordering at the input of an OSERDESE2 is the opposite of the bit ordering at
                Q6 => open,                         --                                                            the output of an ISERDESE2 block.
                Q7 => open, 
                Q8 => open, 
                SHIFTIN1 => '0',                -- 1-bit (each) input: Data width expansion input ports
                SHIFTIN2 => '0',                --                     If SERDES_MODE="SLAVE", connect SHIFTIN1/2 to the master ISERDESE2 SHIFTOUT1/2 outputs. Otherwise, leave SHIFTOUT1/2 unconnected and/or SHIFTIN1/2 grounded
                SHIFTOUT1 => open,              -- 1-bit (each) output: Data width expansion output ports
                SHIFTOUT2 => open,              --                      If SERDES_MODE="MASTER" and two ISERDESE2s are to be cascaded, connect SHIFTOUT1/2 to the slave ISERDESE2 SHIFTIN1/2 inputs
                DYNCLKDIVSEL => '0',            -- 1-bit input: Dynamically select CLKDIV inversion
                DYNCLKSEL => '0',               -- 1-bit input: Dynamically select CLK and CLKB inversion
                OFB => '0',                     -- 1-bit input: Data feedback from OSERDESE2; The serial input data port (OFB) is the serial (high-speed) data input port of the ISERDESE2. This port works in conjunction only with the 7 series FPGA OSERDESE2 port OFB
                OCLK => clk90,                  -- 1-bit input: The OCLK clock input synchronizes data transfer in strobe-based memory interfaces. The OCLK clock is only used when INTERFACE_TYPE is set to "MEMORY". The OCLK clock input is used to transfer strobe-based memory data onto a free-running clock domain
                                                --              OCLK is a free-running FPGA clock at the same frequency as the strobe on the CLK input. The timing of the domain transfer is set by the user by adjusting the delay of the strobe signal to the CLK input (e.g., using IDELAY). Examples of setting the 
                                                --              timing of this domain transfer are given in the Memory Interface Generator (MIG). When INTERFACE_TYPE is "NETWORKING", this port is unused and should be connected to GND.
                OCLKB => clk90b,                -- 1-bit input: The OCLK clock input synchronizes data transfer in strobe-based memory interfaces. The OCLKB clock is only used when INTERFACE_TYPE is set to "MEMORY".
                BITSLIP => '0'                  -- 1-bit input: The BITSLIP pin performs a Bitslip operation synchronous to
                                                -- CLKDIV when asserted (active High). Subsequently, the data seen on the
                                                -- Q1 to Q8 output ports will shift, as in a barrel-shifter operation, one
                                                -- position every time Bitslip is invoked (DDR operation is different from
                                                -- SDR).
            );
        end generate;

    end architecture;