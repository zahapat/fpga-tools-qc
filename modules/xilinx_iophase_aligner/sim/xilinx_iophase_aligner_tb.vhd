    -- xilinx_iophase_aligner_tb: Testbench of the component xilinx_iophase_aligner.vhd

    library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

    library UNISIM;
    use UNISIM.VComponents.all;

    use std.env.finish;
    use std.textio.all;

    library lib_src;

    entity xilinx_iophase_aligner_tb is
    end xilinx_iophase_aligner_tb;

    architecture sim of xilinx_iophase_aligner_tb is

        -- CLK GENERATOR SWITCH
        constant CLKGEN_IS_CLOCK_SYNTHESIZER : boolean := false;

        -- On-board Oscillator
        constant REAL_CLK_HZ : real := 300.0e6;
        constant CLK_PERIOD : time := 1.0 sec / REAL_CLK_HZ;
        constant REAL_CLK_PERIOD_NS : real := real(1.0 / (REAL_CLK_HZ) * 1.0e9);
        signal in_clk_mmcm : std_logic := '0';

        -- MMCM signals
        signal clkout0 : std_logic := '0';
        signal clkout1 : std_logic := '0';
        signal clkout2 : std_logic := '0';
        signal clkout3 : std_logic := '0';
        signal mmcm_fb : std_logic := '0';

        signal fwd_clk : std_logic := '0';
        signal acq_clk : std_logic := '0';

        signal acq_clk_90_BUFIO : std_logic := '0';
        signal acq_clkb_90_BUFIO : std_logic := '0';
        
        -- I/O Ports
        signal clk_bufio : std_logic := '0';
        signal clkb_bufio : std_logic := '0';
        signal clk_bufg : std_logic := '0';
        signal clk_div2_bufg : std_logic := '0';
        
        signal in_idelay_rdy : std_logic := '0';
        signal out_en_aligned : std_logic := '0';
        signal out_rst_aligned : std_logic := '0';
        signal out_en : std_logic := '0';
        signal out_rst : std_logic := '0';
        
        signal in_mmcm_locked : std_logic := '0';
        signal in_fineps_dready : std_logic := '0';

        signal out_aligned_flag : std_logic := '0';
        signal out_fineps_decrement : std_logic := '0';
        signal out_fineps_increment : std_logic := '0';
        signal out_fineps_enable : std_logic := '0';


        -- Print to console "TEST OK."
        procedure print_test_ok is
            variable str : line;
        begin
            write(str, string'("TEST OK."));
            writeline(output, str);
        end procedure;


        -- Clock Synthesizer component
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

    begin

        -- DUT Instance
        in_idelay_rdy <= in_mmcm_locked;
        dut : entity lib_src.xilinx_iophase_aligner(rtl)
        port map (
            -- Clocks
            clk_bufio => clk_bufio,
            clkb_bufio => clkb_bufio,
            clk_bufg => clk_bufg,
            clk_div_bufg => clk_div2_bufg,

            in_idelay_rdy => in_idelay_rdy,

            out_en_aligned => out_en_aligned,
            out_rst_aligned => out_rst_aligned,
            out_en => out_en,
            out_rst => out_rst,

            -- Input Data
            in_mmcm_locked => in_mmcm_locked,
            in_fineps_dready => in_fineps_dready,

            -- Output Data
            out_aligned_flag => out_aligned_flag,
            out_fineps_decrement => out_fineps_decrement,
            out_fineps_increment => out_fineps_increment,
            out_fineps_enable => out_fineps_enable
        );

        --CLK generator
        in_clk_mmcm <= not in_clk_mmcm after (CLK_PERIOD/2.0);

        gen_clksynth : if CLKGEN_IS_CLOCK_SYNTHESIZER = true generate
            -- Clock Synthesizer (MMCM)
            inst_clock_synthesizer : clock_synthesizer
            generic map (
                INT_SELECT_PRIMITIVE => -1,     -- 0=PLL; else MMCM (default)

                INT_BUF_CLKFB => 0,             -- 0=No Buffer; 1=BUFH; 2=BUFIO; 3=BUFR; else=BUFG (default)
                INT_BUF_OUT0 => 0,              -- 0=No Buffer; 1=BUFH; 2=BUFIO; 3=BUFR; else=BUFG (default)
                -- INT_BUF_OUT1 => 1, -- BUFH when not using ISERDES
                -- INT_BUF_OUT2 => 1, -- BUFH when not using ISERDES
                INT_BUF_OUT1 => 2, -- BUFIO when using ISERDES
                INT_BUF_OUT2 => 2, -- BUFIO when using ISERDES
                INT_BUF_OUT3 => 1,
                INT_BUF_OUT4 => -1,
                INT_BUF_OUT5 => -1,
                INT_BUF_OUT6 => -1,             -- (not available in PLL)
                INT_BUF_OUTB0 => 0,             -- (not available in PLL, no access to BUFIO) 0=No Buffer (default); 1=BUFH; 2=BUFIO; 3=BUFR; else=BUFG
                INT_BUF_OUTB1 => 0,             -- (not available in PLL, no access to BUFIO)
                INT_BUF_OUTB2 => 0,             -- (not available in PLL, no access to BUFIO)
                INT_BUF_OUTB3 => 0,             -- (not available in PLL, no access to BUFIO)

                INT_BANDWIDTH => 1,             -- Target bandwidth and performance: 0=LOW, 1=HIGH, others=OPTIMIZED (affects jitter, phase margin)
                INT_COMPENSATION => 3,          -- Delay Compensation: 0=ZHOLD, 1=BUF_IN, 2=EXTERNAL, 3=INTERNAL

                IF_CLKIN1_DIFF => 0,            -- Set to 1 if input clock is differential, else 0
                REAL_CLKIN1_PKPK_JITTER_PS => 70.000,

                -- Setup the VCO frequency for the entire device
                REAL_CLKIN1_MHZ => 300.0,       -- Input clock frequency in MHz
                INT_VCO_DIVIDE => 1,
                REAL_VCO_MULTIPLY => 4.0,

                REAL_DIVIDE_OUT0 => 4.0,
                INT_DIVIDE_OUT1 => 2,
                INT_DIVIDE_OUT2 => 2,
                INT_DIVIDE_OUT3 => 2,
                INT_DIVIDE_OUT4 => 0,
                INT_DIVIDE_OUT5 => 0,
                INT_DIVIDE_OUT6 => 0,           -- (not available in PLL)

                REAL_DUTY_OUT0 => 0.5,
                REAL_DUTY_OUT1 => 0.5,
                REAL_DUTY_OUT2 => 0.5,
                REAL_DUTY_OUT3 => 0.5,
                REAL_DUTY_OUT4 => 0.5,
                REAL_DUTY_OUT5 => 0.5,
                REAL_DUTY_OUT6 => 0.5,          -- (not available in PLL)

                REAL_PHASE_OUT0 => 0.0,
                REAL_PHASE_OUT1 => 0.0,
                REAL_PHASE_OUT2 => 90.000,
                REAL_PHASE_OUT3 => 0.0,
                REAL_PHASE_OUT4 => 0.0,
                REAL_PHASE_OUT5 => 0.0,
                REAL_PHASE_OUT6 => 0.0,         -- (not available in PLL)

                CLKFBOUT_USE_FINE_PS => 0,      -- Fine Phase Shifting (not available in PLL)
                CLKOUT0_USE_FINE_PS => 0,
                CLKOUT1_USE_FINE_PS => 1,
                CLKOUT2_USE_FINE_PS => 1,
                CLKOUT3_USE_FINE_PS => 0,
                CLKOUT4_USE_FINE_PS => 0,
                CLKOUT5_USE_FINE_PS => 0,
                CLKOUT6_USE_FINE_PS => 0
            ) port map (
                -- Inputs
                in_clk0_p => in_clk_mmcm,
                in_clk0_n => '0',

                -- Fine Phase Shift (not available in PLL)
                in_fineps_clk     => clk_div2_bufg,
                in_fineps_incr    => out_fineps_increment,
                in_fineps_decr    => out_fineps_decrement,
                in_fineps_valid   => out_fineps_enable,
                out_fineps_dready => in_fineps_dready,

                -- Outputs
                out_clkfb => open,
                out_clk0 => clk_div2_bufg,    -- 300 (plan B)
                out_clk1 => clk_bufio,        -- 600
                out_clk2 => acq_clk_90_BUFIO, -- 600 90
                out_clk3 => clk_bufg,         -- 600
                out_clk4 => open,
                out_clk5 => open,
                out_clk6 => open,               -- (not available in PLL)
                out_clkb0 => open,              -- Inverted MMCM clocks (not available in PLL)
                out_clkb1 => open,
                out_clkb2 => open,
                out_clkb3 => open,
                out_clk0_nobuf => fwd_clk,      -- Direct outputs from MMCM CLKOUT0-4 pins (no buffers applied)
                out_clk1_nobuf => acq_clk,
                out_clk2_nobuf => open,
                out_clk3_nobuf => open,
                out_clk0_inv => open,           -- Inverted positive clocks out_clkx 0-4 through an inverter
                out_clk1_inv => clkb_bufio,
                out_clk2_inv => acq_clkb_90_BUFIO,
                out_clk3_inv => open,
                locked => in_mmcm_locked
            );
            -- Output buffering (only when using ISERDES)
            -- inst_BUFR_clk_div2 : BUFR generic map (BUFR_DIVIDE => "2", SIM_DEVICE => "7SERIES") 
            --                           port map (I => acq_clk, O => clk_div2_bufg, CE => '1', CLR => '0');
        end generate;


        -- MMCM version
        gen_mmcm_adv : if CLKGEN_IS_CLOCK_SYNTHESIZER = false generate
            clkb_bufio <= not clk_bufio;
            inst_MMCME2_ADV : MMCME2_ADV
            generic map (
                BANDWIDTH => "HIGH",
                CLKFBOUT_MULT_F => 4.0,
                DIVCLK_DIVIDE => 1,
                CLKFBOUT_PHASE => 0.0,
                CLKIN1_PERIOD => REAL_CLK_PERIOD_NS,
                CLKIN2_PERIOD => 1.0e2, -- dummy value
                CLKOUT0_DIVIDE_F => 2.0,
                CLKOUT1_DIVIDE => 2,
                CLKOUT2_DIVIDE => 4,
                CLKOUT3_DIVIDE => 2,
                CLKOUT4_DIVIDE => 1,
                CLKOUT5_DIVIDE => 1,
                CLKOUT6_DIVIDE => 1,
                CLKOUT0_DUTY_CYCLE => 0.5,
                CLKOUT1_DUTY_CYCLE => 0.5,
                CLKOUT2_DUTY_CYCLE => 0.5,
                CLKOUT3_DUTY_CYCLE => 0.5,
                CLKOUT4_DUTY_CYCLE => 0.5,
                CLKOUT5_DUTY_CYCLE => 0.5,
                CLKOUT6_DUTY_CYCLE => 0.5,
                CLKOUT0_PHASE => 0.0,
                CLKOUT1_PHASE => 0.0,
                CLKOUT2_PHASE => 0.0,
                CLKOUT3_PHASE => 0.0,
                CLKOUT4_PHASE => 0.0,
                CLKOUT5_PHASE => 0.0,
                CLKOUT6_PHASE => 0.0,
                CLKOUT4_CASCADE => FALSE,
                COMPENSATION => "ZHOLD",
                REF_JITTER1 => 0.0,
                REF_JITTER2 => 0.0,
                STARTUP_WAIT => FALSE,
                SS_EN => "FALSE",
                SS_MODE => "CENTER_HIGH",
                SS_MOD_PERIOD => 10000,
                CLKFBOUT_USE_FINE_PS => FALSE,

                CLKOUT0_USE_FINE_PS => TRUE,  -- BUFIO (0)
                CLKOUT1_USE_FINE_PS => TRUE,  -- BUFIO (90)
                CLKOUT2_USE_FINE_PS => FALSE, -- BUFG CLK_DIV
                CLKOUT3_USE_FINE_PS => FALSE, -- BUFG (0)

                CLKOUT4_USE_FINE_PS => FALSE,
                CLKOUT5_USE_FINE_PS => FALSE,
                CLKOUT6_USE_FINE_PS => FALSE
            )
            port map (
                -- Clock Outputs: 1-bit (each) output: User configurable clock outputs
                CLKOUT0 => clkout0, -- clk_bufio
                CLKOUT0B => open,
                CLKOUT1 => clkout1, -- CLKIO625(1)
                CLKOUT1B => open,
                CLKOUT2 => clkout2, -- clk_div2_bufg
                CLKOUT2B => open,
                CLKOUT3 => clkout3, -- clk_bufg
                CLKOUT3B => open,
                CLKOUT4 => open,
                CLKOUT5 => open,
                CLKOUT6 => open,
                DO => open,
                DRDY => open,
                PSDONE => in_fineps_dready,
                CLKFBOUT => mmcm_fb,
                CLKFBOUTB => open,
                CLKFBSTOPPED => open,
                CLKINSTOPPED => open,
                LOCKED => in_mmcm_locked,
                CLKIN1 => in_clk_mmcm,
                CLKIN2 => '0',
                CLKINSEL => '1',
                PWRDWN => '0',
                RST => '0',
                DADDR => (others => '0'),
                DCLK => '0',
                DEN => '0',
                DI => (others => '0'),
                DWE => '0',
                PSCLK => clk_div2_bufg,
                PSEN => out_fineps_enable,
                PSINCDEC => out_fineps_increment,
                CLKFBIN => mmcm_fb
            );

            -- Output buffering
            -------------------------------------
            inst_BUFIO       : BUFIO port map(I=>clkout0,O=>clk_bufio);
            -- inst_BUFIO_90    : BUFIO port map(I=>clkout1,O=>CLKIO625(1));
            inst_BUFG_DIV2   : BUFG  port map(I=>clkout2,O=>clk_div2_bufg);
            inst_BUFG        : BUFG  port map(I=>clkout3,O=>clk_bufg);
        end generate;


        -- Sequencer
        proc_sequencer : process
        begin
            wait until rising_edge(out_en_aligned);

            wait for 10 * CLK_PERIOD;

            print_test_ok;
            finish;
            wait;
        end process;

    end architecture;