    -- xilinx_iophase_aligner.vhd : - This module scans and aligns the phases of clocks fed 
    --                              through BUFIO buffers to BUFG clocks. Clocks from BUFGs 
    --                              can drive logic elements, while clocks from BUFIOs can 
    --                              only drive peripheral IO components. 
    --                              - At high frequencies, it is necessary that both clocks 
    --                              are phase aligned. This way, data can be reliably
    --                              transferred from elements driven by BUFIO clocks to 
    --                              elements in programmable fabric driven by different clock
    --                              buffers (BUFGs).
    --                              - Misaligned clocks may cause data loss and suboptimal 
    --                              timing results.
    --                              - Ports of this module can be directly interfaced with 
    --                              MMCM_ADV and the custom "clock_synthesizer.py" module
    
    library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

    library UNISIM;
    use UNISIM.VComponents.all;

    entity xilinx_iophase_aligner is
        port (
            -- Clocks
            clk_bufio : in std_logic;     -- MMCM1's clock output, 
                                          --       then fed through BUFIO
            clkb_bufio : in std_logic;    -- MMCM1's clock output (the exact same port as clk_bufio), inverted, 
                                          --       then fed through BUFIO
            clk_bufg : in std_logic;      -- MMCM1's (or of any other synchronous MMCM) clock output (SAME freq as clk_bufio), 
                                          --       then fed through BUFG (or any other buffer that can drive logic)
            clk_div_bufg : in std_logic;  -- MMCM1's (or of any other synchronous MMCM) clock output (SAME freq as clk_bufio/2), 
                                          --       then fed through BUFG (or any other buffer that can drive logic but same as clk_bufg)

            -- Reset
            in_idelay_rdy : in std_logic; -- Mandatory! Or connect MMCM_locked if IDELAY not used

            -- Reset & Enable signals - synchronized with clk_div_bufg clock
            out_en_aligned : out std_logic;
            out_rst_aligned : out std_logic;
            out_en : out std_logic;
            out_rst : out std_logic;

            -- Input Data
            in_mmcm_locked : in std_logic;
            in_fineps_dready : in std_logic;

            -- Output Data
            out_aligned_flag : out std_logic;
            out_fineps_decrement : out std_logic;     -- Do not connect to MMCM_ADV but connect to clk_synthesizer's "in_fineps_decr" port
            out_fineps_increment : out std_logic;     -- Connect to MMCM_ADV's "PSINCDEC" port, or clk_synthesizer's "in_fineps_incr" port
            out_fineps_enable : out std_logic         -- Connect to MMCM_ADV's "PSEN" port, or clk_synthesizer's "in_fineps_valid" port
        );
    end xilinx_iophase_aligner;

    architecture rtl of xilinx_iophase_aligner is

        -- OSERDESE2
        signal slv_oserdes_pattern : std_logic_vector(4-1 downto 0) := (others => '0');
        signal sl_output_feedback_clock : std_logic := '0';

        -- ISERDESE2
        -- std_logic array into std_logic_vector conversion
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

        
        -- Phase alignment signals
        signal sl_32b_delayed_reset : std_logic := '0';
        signal sl_clock_sampled_2d : t_channels_iserdes_2d := (others => '0');
        signal slv_clock_sampled : std_logic_vector(4-1 downto 0) := (others => '0');
        signal slv_clock_sampled_p1 : std_logic_vector(4-1 downto 0) := (others => '0');
        signal slv_clock_sampled_last : std_logic_vector(4-1 downto 0) := (others => '0');
        signal slv_clock_sampled_last_reg : std_logic_vector(4-1 downto 0) := (others => '0');
        signal state : std_logic_vector(4-1 downto 0) := (others => '0');
        signal state_next : std_logic_vector(state'range) := (others => '0');
        signal counter_increment : std_logic := '0';
        signal counter_enable : std_logic := '0';
        signal counter_ctrl : std_logic_vector(2-1 downto 0) := (others => '0');
        signal counter : std_logic_vector(7-1 downto 0) := (others => '0');
        signal sl_aligned_flag : std_logic := '0';

        -- Reset and Enable generator sigals
        signal sl_alignment_rst : std_logic := '0';
        signal sl_alignment_srl_ce : std_logic := '0';
        signal sl_alignment_srl_in : std_logic := '0';
        signal sl_alignment_srl_out : std_logic := '0';
        signal sl_alignment_en_logic_out : std_logic := '0';
        signal sl_alignment_en : std_logic := '0';

        signal sl_idelay_rst : std_logic := '0';
        signal sl_idelay_srl_ce : std_logic := '0';
        signal sl_idelay_srl_in : std_logic := '0';
        signal sl_idelay_srl_out : std_logic := '0';
        signal sl_idelay_en_logic_out : std_logic := '0';
        signal sl_idelay_en : std_logic := '0';

        -- Attributes
        -- attribute MAXDELAY : string;
        -- attribute MAXDELAY of slv_oserdes_pattern : signal is "600ps";
        -- attribute MAXDELAY of sl_clock_sampled_2d : signal is "600ps";
        attribute KEEP_HIERARCHY : string;
        attribute KEEP_HIERARCHY of rtl : architecture is "YES";

    begin

        -- Once IDELAY is READY, output enable signal
        -- Apply 1x clk_div_bufg cycle reset delay
        inst_FDSE_idelay_en : FDSE
        generic map (INIT => '1')
        port map (
            D => '0',
            CE => in_idelay_rdy,  -- Normally IDELAY Ready port! See XAPP523
            C => clk_div_bufg,
            S => '0', 
            Q => sl_idelay_rst
        );

        out_rst <= sl_idelay_rst;
        
        sl_idelay_srl_ce <= not sl_idelay_rst;
        inst_SRLC32E_idelay_en : SRLC32E
        generic map (INIT => X"00000001")
        port map (
            CLK => clk_div_bufg, 
            A => "10000", -- 16 cycles
            CE => sl_idelay_srl_ce, 
            D => sl_idelay_srl_in,
            Q => sl_idelay_srl_out, 
            Q31 => open
        );
        inst_FDRE_idelay_en : FDRE
        generic map (INIT => '0')
        port map (
            D => sl_idelay_srl_out, 
            CE => '1', 
            C => clk_div_bufg, 
            R => sl_idelay_rst, 
            Q => sl_idelay_srl_in
        );
        
        inst_LUT4_idelay_en : LUT4
        generic map (INIT => X"0B08")
        port map (
                I3 => sl_idelay_en, 
                I2 => sl_idelay_rst, 
                I1 => sl_idelay_srl_in, 
                I0 => '1', 
                O => sl_idelay_en_logic_out
        );

        inst_FD_idelay_en : FD
        generic map (INIT => '0')
        port map (
            D => sl_idelay_en_logic_out,
            C => clk_div_bufg,
            Q => sl_idelay_en
        );
        out_en <= sl_idelay_en;

        -- Instantiate OSERDES
        inst_OSERDESE2_phase_aligner : OSERDESE2
        generic map (
            DATA_RATE_OQ => "DDR",      -- Specify data rate to "DDR" or "SDR" 
            DATA_RATE_TQ => "DDR",      -- Specify data rate to "DDR", "SDR", or "BUF" 
            DATA_WIDTH => 4,            -- Specify parallel data width - For DDR: 4,6,8, or 10 (For SDR or BUF: 2,3,4,5,6,7, or 8)
            INIT_OQ => '0',             -- Initial value of OQ output (1'b0,1'b1)
            INIT_TQ => '0',             -- Initial value of TQ output (1'b0,1'b1)
            SERDES_MODE => "MASTER",    -- Set SERDES mode to "MASTER" or "SLAVE" 
            SRVAL_OQ => '0',            -- OQ output value when SR is used (1'b0,1'b1)
            SRVAL_TQ => '0',            -- TQ output value when SR is used (1'b0,1'b1)
            TBYTE_CTL => "FALSE",       -- Enable tristate byte operation ("FALSE", "TRUE")
            TBYTE_SRC => "FALSE",       -- Tristate byte source ("FALSE", "TRUE")
            TRISTATE_WIDTH => 4         -- 3-state converter width (1,4)
                                        --     When DATA_RATE_TQ = DDR: 2 or 4 
                                        --     When DATA_RATE_TQ = SDR or BUF: 1 " 
        )
        port map (
            OFB => sl_output_feedback_clock,  -- 1-bit output: Feedback path for data
            OQ => open,                 -- 1-bit output: Data path output
            SHIFTOUT1 => open,          -- 1-bit Data output expansion
            SHIFTOUT2 => open,          -- 1-bit Data output expansion
            TBYTEOUT => open,           -- 1-bit output: Byte group tristate
            TFB => open,                -- 1-bit output: 3-state control
            TQ => open,                 -- 1-bit output: 3-state control
            CLK => clk_bufg,            -- 1-bit input: High speed clock
            CLKDIV => clk_div_bufg,     -- 1-bit input: Divided clock
            D1 => slv_oserdes_pattern(0), -- 1-bit input: Parallel data input
            D2 => slv_oserdes_pattern(1), -- 1-bit input: Parallel data input
            D3 => slv_oserdes_pattern(2), -- 1-bit input: Parallel data input
            D4 => slv_oserdes_pattern(3), -- 1-bit input: Parallel data input
            D5 => '0',                  -- 1-bit input: Parallel data input
            D6 => '0',                  -- 1-bit input: Parallel data input
            D7 => '0',                  -- 1-bit input: Parallel data input
            D8 => '0',                  -- 1-bit input: Parallel data input
            OCE => sl_idelay_en,        -- 1-bit input: Output data clock enable
            RST => sl_idelay_rst,       -- 1-bit input: Reset
            SHIFTIN1 => '0',            -- 1-bit input: Data input expansion
            SHIFTIN2 => '0',            -- 1-bit input: Data input expansion
            T1 => '0',                  -- 1-bit input: Parallel 3-state input
            T2 => '0',                  -- 1-bit input: Parallel 3-state input
            T3 => '0',                  -- 1-bit input: Parallel 3-state input
            T4 => '0',                  -- 1-bit input: Parallel 3-state input
            TBYTEIN => '0',             -- 1-bit input: Byte group tristate
            TCE => '0'                  -- 1-bit input: 3-state clock enable
        );

        -- Instantiate ISERDES
        slv_clock_sampled <= sl_array_to_slv(4, sl_clock_sampled_2d);
        inst_ISERDESE2_phase_aligner : ISERDESE2
        generic map (
            INTERFACE_TYPE => "NETWORKING", -- MEMORY, MEMORY_DDR3, MEMORY_QDR, NETWORKING, OVERSAMPLE
            DATA_RATE => "DDR",             -- Specify data rate of "DDR" or "SDR" 
            DATA_WIDTH => 4,                -- Specify data width:
                                            --      NETWORKING SDR: 2,3,4,5,6,7,8 : DDR 4,6,8,10
                                            --      MEMORY SDR N/A : DDR 4
            DYN_CLKDIV_INV_EN => "FALSE",   -- Enable DYNCLKDIVINVSEL inversion (FALSE, TRUE)
            DYN_CLK_INV_EN => "FALSE",      -- Enable DYNCLKINVSEL inversion (FALSE, TRUE)
            INIT_Q1 => '0',                 -- Initial value on the Q output (0/1)
            INIT_Q2 => '0',                 -- Initial value on the Q output (0/1)
            INIT_Q3 => '0',                 -- Initial value on the Q output (0/1)
            INIT_Q4 => '0',                 -- Initial value on the Q output (0/1)
            IOBDELAY => "NONE",             -- ["NONE": O=>D | Q1-Q6=>D];  ["IBUF": O=>DDLY | Q1-Q6=>D];  ["IFD": O=>D | Q1-Q6=>DDLY];  ["BOTH": O=>DDLY | Q1-Q6=>DDLY]
            -- IOBDELAY => "IFD",             -- ["NONE": O=>D | Q1-Q6=>D];  ["IBUF": O=>DDLY | Q1-Q6=>D];  ["IFD": O=>D | Q1-Q6=>DDLY];  ["BOTH": O=>DDLY | Q1-Q6=>DDLY]
            NUM_CE => 1,                    -- Number of clock enables (1,2)
            -- NUM_CE => 2,                    -- Number of clock enables (1,2)
            OFB_USED => "TRUE",             -- Enables ("TRUE") the path from the OLOGIC, OSERDESE2 OFB pin to the ISERDESE2 OFB pin and disables the use of the D input pin.
            SERDES_MODE => "MASTER",        -- Specifies whether the ISERDESE2 module is a master or slave when using width expansion. Set to "MASTER" when not using width expansion.
            SRVAL_Q1 => '0',                -- Q output value when SR is used (0/1)
            SRVAL_Q2 => '0',                -- Q output value when SR is used (0/1)
            SRVAL_Q3 => '0',                -- Q output value when SR is used (0/1)
            SRVAL_Q4 => '0'                 -- Q output value when SR is used (0/1)
        ) port map (
            D => '0',                       -- 1-bit input: Data input
            DDLY => '0',                    -- 1-bit input: Serial data from IDELAYE2
            CE1 => sl_idelay_en,               -- 1-bit input: Data register clock enable input
            CE2 => '1',                     -- 1-bit input: Data register clock enable input
            CLK => clk_bufio,               -- 1-bit input: High-speed clock used to clock in the input serial data stream
            CLKB => clkb_bufio,             -- 1-bit input: High-speed secondary clock used to clock in the input serial data stream. In any mode other than "MEMORY_QDR", connect CLKB to an inverted version of CLK. In "MEMORY_QDR" mode CLKB should be connected to a unique, phase shifted clock
            CLKDIV => clk_div_bufg,         -- 1-bit input: The divided clock input (CLKDIV) is typically a divided version of CLK (depending on the width of the implemented deserialization). 
                                            --              It drives the output of the serial-to-parallel converter, the Bitslip submodule, and the CE module
            CLKDIVP => '0',                 -- 1-bit input: Only supported in MIG. Sourced by PHASER_IN divided CLK in MEMORY_DDR3 mode. All other modes connect to ground
            RST => sl_idelay_rst,      -- 1-bit input: Active high asynchronous reset 
                                            --              Note: MUST be applied for a longer period
            O => open,                      -- 1-bit output: The combinatorial output port (O) is an UNregistered output of the ISERDESE2 module. This output can come directly from the data input (D), or from the data input (DDLY) via the IDELAYE2.
            Q1 => sl_clock_sampled_2d(0),   -- (=T+0deg   = Sample 1 clocked by CLK) 1-bit (each) output: The output ports Q1 to Q8 are the registered outputs of the ISERDESE2 module. 
            Q2 => sl_clock_sampled_2d(1),   -- (=T+180deg = Sample 3 clocked by OCLK)                     One ISERDESE2 block can support up to eight bits (i.e., a 1:8 deserialization). 
            Q3 => sl_clock_sampled_2d(2),   -- (=T+90deg  = Sample 2 clocked by CLKB)                     Bit widths greater than eight (up to 14) can be supported using Width Expansion.
            Q4 => sl_clock_sampled_2d(3),   -- (=T+270deg = Sample 4 clocked by OCLKB)                    The first data bit received appears on the highest order Q output. The bit 
            Q5 => open,                     --                                                            ordering at the input of an OSERDESE2 is the opposite of the bit ordering at
            Q6 => open,                     --                                                            the output of an ISERDESE2 block.
            Q7 => open,
            Q8 => open,
            SHIFTIN1 => '0',                -- 1-bit (each) input: Data width expansion input ports
            SHIFTIN2 => '0',                --                     If SERDES_MODE="SLAVE", connect SHIFTIN1/2 to the master ISERDESE2 SHIFTOUT1/2 outputs. Otherwise, leave SHIFTOUT1/2 unconnected and/or SHIFTIN1/2 grounded
            SHIFTOUT1 => open,              -- 1-bit (each) output: Data width expansion output ports
            SHIFTOUT2 => open,              --                      If SERDES_MODE="MASTER" and two ISERDESE2s are to be cascaded, connect SHIFTOUT1/2 to the slave ISERDESE2 SHIFTIN1/2 inputs
            DYNCLKDIVSEL => '0',            -- 1-bit input: Dynamically select CLKDIV inversion
            DYNCLKSEL => '0',               -- 1-bit input: Dynamically select CLK and CLKB inversion
            OFB => sl_output_feedback_clock,-- 1-bit input: Data feedback from OSERDESE2; The serial input data port (OFB) is the serial (high-speed) data input port of the ISERDESE2. This port works in conjunction only with the 7 series FPGA OSERDESE2 port OFB
            OCLK => '0',                    -- 1-bit input: The OCLK clock input synchronizes data transfer in strobe-based memory interfaces. The OCLK clock is only used when INTERFACE_TYPE is set to "MEMORY". The OCLK clock input is used to transfer strobe-based memory data onto a free-running clock domain
                                            --              OCLK is a free-running FPGA clock at the same frequency as the strobe on the CLK input. The timing of the domain transfer is set by the user by adjusting the delay of the strobe signal to the CLK input (e.g., using IDELAY). Examples of setting the 
                                            --              timing of this domain transfer are given in the Memory Interface Generator (MIG). When INTERFACE_TYPE is "NETWORKING", this port is unused and should be connected to GND.
            OCLKB => '0',                   -- 1-bit input: The OCLK clock input synchronizes data transfer in strobe-based memory interfaces. The OCLKB clock is only used when INTERFACE_TYPE is set to "MEMORY".
            BITSLIP => '0'                  -- 1-bit input: The BITSLIP pin performs a Bitslip operation synchronous to
                                            -- CLKDIV when asserted (active High). Subsequently, the data seen on the
                                            -- Q1 to Q8 output ports will shift, as in a barrel-shifter operation, one
                                            -- position every time Bitslip is invoked (DDR operation is different from
                                            -- SDR).
        );

        
        -- Initialize OSERDESE2 pattern, synchronize with clock
        proc_oserdes_patt : process(clk_div_bufg, sl_idelay_rst)
        begin
            if sl_idelay_rst = '1' then
                slv_oserdes_pattern <= (others => '0');
            elsif rising_edge(clk_div_bufg) then
                if sl_idelay_en = '1' then
                    -- slv_oserdes_pattern <= "0101";
                    slv_oserdes_pattern <= "1010";
                end if;
            end if;
        end process;

        -- Perform the phase alignment
        gen_sampled_clk_pref : for i in 0 to 4-1 generate
            delay_clock_sampled : FDRE
                port map (
                C     => clk_div_bufg,
                R     => sl_idelay_rst,
                D     => slv_clock_sampled(i),
                Q     => slv_clock_sampled_p1(i),
                CE    => '1'
            );
        end generate;


        -- Initialize the FSM state, update the actual state on rising edge
        proc_state_update : process (clk_div_bufg, sl_idelay_rst)
        begin
            if sl_idelay_rst = '1' then
                state <= (others => '0');
                slv_clock_sampled_last_reg <= (others => '0'); 
            elsif rising_edge(clk_div_bufg) then
                state <= state_next;
                slv_clock_sampled_last_reg <= slv_clock_sampled_last;
            end if;
        end process;


        -- Counter control
        counter_ctrl <= counter_enable & counter_increment;
        process (clk_div_bufg, sl_idelay_rst)
        begin
            if sl_idelay_rst = '1' then
                counter <= (others => '0');

            elsif rising_edge(clk_div_bufg) then
                case counter_ctrl is
                    when "01" =>
                        counter <= counter;     -- never used
                    when "10" =>
                        counter <= std_logic_vector(unsigned(counter) - 1); -- never used
                    when "11" =>
                        counter <= std_logic_vector(unsigned(counter) + 1);
                    when others => -- "00"
                        counter <= (others => '0');
                end case;
            end if;
        end process;


        -- Alignment status
        -- sl_aligned_flag <= (not state(3) and state(2) and not state(1) and state(0));
        sl_aligned_flag <= (not state(3) and state(2) and state(1) and state(0));
        inst_FDR_alignment: FDR
        port map (
            C     => clk_div_bufg,
            R     => sl_idelay_rst,
            D     => sl_aligned_flag,
            Q     => out_aligned_flag
        );


        -- Prepare phase aligner state update before next rising edge
        proc_prepare_state_update : process (state, counter,
            slv_clock_sampled, slv_clock_sampled_p1, in_mmcm_locked,
            in_fineps_dready)
        begin
            case state is
                when "0000" =>
                    if in_mmcm_locked = '1' then
                        -- Proceed to initial state
                        state_next <= "0001";
                    else
                        -- Stay in this reset state
                        state_next <= "0000";
                    end if;

                    -- Counter & PS Control signals
                    out_fineps_decrement  <= '0'; -- to fine phase shifter module
                    out_fineps_increment  <= '0'; -- to fine phase shifter module
                    out_fineps_enable     <= '0'; -- to fine phase shifter module
                    counter_enable    <= '0';
                    counter_increment <= '0';


                -- Initial state: Sample clock profile for the first time
                when "0001" =>
                    if slv_clock_sampled_p1 /= slv_clock_sampled then
                        -- The clock is on transition now, bypass the next state
                        state_next <= "1111";
                    else
                        -- Proceed to the next state to later check if it is on transition
                        state_next <= "1000";                      
                    end if;

                    -- Counter & PS Control signals
                    out_fineps_decrement  <= '0'; -- to fine phase shifter module
                    out_fineps_increment  <= '0'; -- to fine phase shifter module
                    out_fineps_enable     <= '0'; -- to fine phase shifter module
                    counter_enable    <= '0';
                    counter_increment <= '0';


                -- Initial state: Check if slv_clock_sampled_p2 is on transition
                when "1000" =>
                    if slv_clock_sampled_p1 /= slv_clock_sampled then
                        -- The clock is on transition now
                        state_next <= "1111";

                    -- Original
                    elsif ((counter > "0001111") and (slv_clock_sampled = "1010")) then
                        state_next <= "1011";
                        -- state_next <= "0010";
                    elsif ((counter > "0001111") and (slv_clock_sampled = "0101")) then
                        state_next <= "0010";
                        -- state_next <= "1011";

                    else
                        -- Stay in this state
                        state_next <= "1000";
                    end if;

                    -- Counter & PS Control signals
                    out_fineps_decrement  <= '0'; -- to fine phase shifter module
                    out_fineps_increment  <= '0'; -- to fine phase shifter module
                    out_fineps_enable     <= '0'; -- to fine phase shifter module
                    counter_enable    <= '1';
                    counter_increment <= '1';


                -- Proceed to phase alignment: increment delay (2x)
                when "1111" =>
                    state_next <= "1101";

                    -- Counter & PS Control signals
                    out_fineps_decrement  <= '0'; -- to fine phase shifter module
                    out_fineps_increment  <= '1'; -- to fine phase shifter module
                    out_fineps_enable     <= '1'; -- to fine phase shifter module
                    counter_enable    <= '0';
                    counter_increment <= '0';


                -- Wait until fine phase shift MMCM module is ready
                when "1101" =>
                    if in_fineps_dready = '1' then
                        state_next <= "1100";
                    else
                        state_next <= "1101";
                    end if;

                    -- Counter & PS Control signals
                    out_fineps_decrement  <= '0'; -- to fine phase shifter module
                    out_fineps_increment  <= '0'; -- to fine phase shifter module
                    out_fineps_enable     <= '0'; -- to fine phase shifter module
                    counter_enable    <= '1';
                    counter_increment <= '1';


                -- Rescan for clock transition (counter reset)
                when "1100" =>
                    state_next <= "1000";

                    -- Counter & PS Control signals
                    out_fineps_decrement  <= '0'; -- to fine phase shifter module
                    out_fineps_increment  <= '0'; -- to fine phase shifter module
                    out_fineps_enable     <= '0'; -- to fine phase shifter module
                    counter_enable    <= '0';
                    counter_increment <= '0';


                -- Increment PS once
                when "0010" =>
                    state_next <= "1110"; -- (below)

                    -- Counter & PS Control signals
                    out_fineps_decrement  <= '0'; -- to fine phase shifter module
                    out_fineps_increment  <= '1'; -- to fine phase shifter module
                    out_fineps_enable     <= '1'; -- to fine phase shifter module
                    counter_enable    <= '0';
                    counter_increment <= '0';
                    

                -- Wait for 8 cycles, then look for rising edge
                when "1110" =>
                    if counter > "0111111" then
                        state_next <= "1110";
                    elsif slv_clock_sampled /= "0101" then
                        state_next <= "0111";
                    else
                        state_next <= "0010";
                    end if;

                    -- Counter & PS Control signals
                    out_fineps_decrement  <= '0'; -- to fine phase shifter module
                    out_fineps_increment  <= '0'; -- to fine phase shifter module
                    out_fineps_enable     <= '0'; -- to fine phase shifter module
                    counter_enable    <= '0';
                    counter_increment <= '0';


                -- Increment PS once
                when "1011" =>
                    state_next <= "0100";

                    -- Counter & PS Control signals
                    out_fineps_decrement  <= '0'; -- to fine phase shifter module
                    out_fineps_increment  <= '1'; -- to fine phase shifter module
                    out_fineps_enable     <= '1'; -- to fine phase shifter module
                    counter_enable    <= '0';
                    counter_increment <= '0';


                -- Wait for 8 cycles, then look for falling edge
                when "0100" =>
                    if in_fineps_dready = '0' then
                        state_next <= "0100";
                    elsif slv_clock_sampled = "0101" then
                        state_next <= "1001";
                    else
                        state_next <= "1011";
                    end if;

                    -- Counter & PS Control signals
                    out_fineps_decrement  <= '0'; -- to fine phase shifter module
                    out_fineps_increment  <= '0'; -- to fine phase shifter module
                    out_fineps_enable     <= '0'; -- to fine phase shifter module
                    counter_enable    <= '0';
                    counter_increment <= '0';


                -- Increment PS once
                when "1001" =>
                    state_next <= "0011"; -- (below)

                    -- slv_clock_sampled_last <= slv_clock_sampled;

                    -- Counter & PS Control signals
                    out_fineps_decrement  <= '0'; -- to fine phase shifter module
                    out_fineps_increment  <= '1'; -- to fine phase shifter module
                    out_fineps_enable     <= '1'; -- to fine phase shifter module
                    counter_enable    <= '0';
                    counter_increment <= '0';


                -- Wait for 8 cycles, then look for rising edge
                when "0011" =>
                    if in_fineps_dready = '0' then
                        state_next <= "0011";
                    elsif slv_clock_sampled = "1010" then
                        -- state_next <= "1010"; -- (below)
                        state_next <= "0111"; -- (below)
                    else
                        state_next <= "1001";
                    end if;

                    -- Counter & PS Control signals
                    out_fineps_decrement  <= '0'; -- to fine phase shifter module
                    out_fineps_increment  <= '0'; -- to fine phase shifter module
                    out_fineps_enable     <= '0'; -- to fine phase shifter module
                    counter_enable    <= '0';
                    counter_increment <= '0';


                -- Check if aligned properly: decrement 1x if incrementation exceeded the phase alignment
                -- (particularly when rising edge is detected changes between fineps increment and in_fineps_dready)
                -- when "1010" =>

                --     if slv_clock_sampled_last_reg = "0101" then
                --         state_next <= "0111";
                --         out_fineps_decrement <= '1'; -- to fine phase shifter module
                --         out_fineps_increment <= '0'; -- to fine phase shifter module
                --         out_fineps_enable    <= '1'; -- to fine phase shifter module
                --     else
                --         state_next <= "0101";
                --         out_fineps_decrement <= '0'; -- to fine phase shifter module
                --         out_fineps_increment <= '0'; -- to fine phase shifter module
                --         out_fineps_enable    <= '0'; -- to fine phase shifter module
                --     end if;


                -- Complete waiting for the decrementation
                when "0111" =>
                    -- if in_fineps_dready = '0' then
                    --     state_next <= "0111";
                    -- else 
                    --     state_next <= "0101";
                    -- end if;
                    state_next <= "0111";

                    -- Counter & PS Control signals
                    out_fineps_decrement  <= '0'; -- to fine phase shifter module
                    out_fineps_increment  <= '0'; -- to fine phase shifter module
                    out_fineps_enable     <= '0'; -- to fine phase shifter module
                    counter_enable    <= '0';
                    counter_increment <= '0';


                -- Training complete for this clock channel
                -- when "0101" =>
                --     state_next <= "0101";

                --     -- Counter & PS Control signals
                --     out_fineps_decrement  <= '0'; -- to fine phase shifter module
                --     out_fineps_increment  <= '0'; -- to fine phase shifter module
                --     out_fineps_enable     <= '0'; -- to fine phase shifter module
                --     counter_enable    <= '0';
                --     counter_increment <= '0';

                when others =>
                    state_next <= (others => '0');

                    -- Counter & PS Control signals
                    out_fineps_decrement  <= '0'; -- to fine phase shifter module
                    out_fineps_increment  <= '0'; -- to fine phase shifter module
                    out_fineps_enable     <= '0'; -- to fine phase shifter module
                    counter_enable    <= '0';
                    counter_increment <= '0';

            end case;
        end process;


        -- After successful alignment, output enable signal
        -- Apply 1x clk_div_bufg cycle reset delay
        inst_FDSE_alignment_en : FDSE
        generic map (INIT => '1')
        port map (
            D => '0',
            CE => sl_aligned_flag,  -- Normally IDELAY Ready port! See XAPP523
            C => clk_div_bufg,
            S => '0', 
            Q => sl_alignment_rst
        );

        out_rst_aligned <= sl_alignment_rst;
        
        sl_alignment_srl_ce <= not sl_alignment_rst;
        inst_SRLC32E_alignment_en : SRLC32E
        generic map (INIT => X"00000001")
        port map (
            CLK => clk_div_bufg, 
            A => "10000", -- 16 cycles
            CE => sl_alignment_srl_ce, 
            D => sl_alignment_srl_in,
            Q => sl_alignment_srl_out, 
            Q31 => open
        );
        inst_FDRE_alignment_en : FDRE
        generic map (INIT => '0')
        port map (
            D => sl_alignment_srl_out, 
            CE => '1', 
            C => clk_div_bufg, 
            R => sl_alignment_rst, 
            Q => sl_alignment_srl_in
        );
        
        inst_LUT4_alignment_en : LUT4
        generic map (INIT => X"0B08")
        port map (
                I3 => sl_alignment_en, 
                I2 => sl_alignment_rst, 
                I1 => sl_alignment_srl_in, 
                I0 => '1', 
                O => sl_alignment_en_logic_out
        );

        inst_FD_alignment_en : FD
        generic map (INIT => '0')
        port map (
            D => sl_alignment_en_logic_out,
            C => clk_div_bufg,
            Q => sl_alignment_en
        );
        out_en_aligned <= sl_alignment_en;


    end architecture;