    library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

    -- library work;

    library UNISIM;
    use UNISIM.VComponents.all;

    library lib_src;
    use lib_src.FRONTPANEL.all;

    entity top_memristor is
        generic(
            -- Generics of 'shiftreg_redgedetect'
            INT_BUFFER_WIDTH   : positive := 3;
            INT_PATTERN_WIDTH  : positive := 3;
            INT_DETECT_PATTERN : positive := 1;

            -- Generics of 'johnson_cnt'
            SL_RST_VAL : std_logic := '1';
            INT_JOHNS_CNT_WIDTH : natural := 3;

            -- Generics of 'shiftreg_redgedetect'
            INT_ASYNC_FLOPS_CNT : positive := 2;
            INT_ASYNC_FLOPS_CNT_EVENTGEN : positive := 2;
            INT_FLOPS_BEFORE_CROSSING_CNT : positive := 1;
            INT_FLOPS_BEFORE_CROSSING_EVENTGEN : positive := 1;

            -- Generics of 'memristor_ctrl'
            INT_CTRL_DATA_WIDTH : positive := 3;
            INT_CLK_SYS_HZ : natural := 85208333;
            INT_LAP_DURATION_NS : natural := 1e3  -- 1000 ns -> 1 us lap time

        );
        port (
            -- Clocks
            clk0 : in std_logic;
            clk1 : in std_logic;
            clk2 : in std_logic;
            clk3 : in std_logic;
            clk4 : in std_logic;
            clk5 : in std_logic;
            sampl_clk : in std_logic;
            sys_clk : in std_logic;

            -- Data in
            pulse_in : in std_logic;

            -- Data out
            pulse_out : out std_logic
        );
    end top_memristor;

    architecture str of top_memristor is


        -- "shiftreg_redgedetect" signals
        signal sl_pulse_in : std_logic := '0'; -- Input Port
        signal sl_redgedetect_event : std_logic := '0';

        -- "johnson_cnt" signals
        signal slv_johns_counter_val : std_logic_vector(INT_JOHNS_CNT_WIDTH-1 downto 0) := (others => '0');

        -- "nff_cdcc_fedge" signals
        constant INT_DATA_WIDTH : natural := INT_JOHNS_CNT_WIDTH;
        signal sl_cdcc_valid_pulsed_out : std_logic := '0';
        signal slv_cdcc_data_out : std_logic_vector(INT_DATA_WIDTH-1 downto 0) := (others => '0');

        -- "memristor_ctrl" signals
        signal sl_ctrl_pulse_out : std_logic := '0'; -- Output Port


    begin


        -- Instantiate Rising Edge Detector for channel 'pulse_in'
        sl_pulse_in <= pulse_in;
        inst_shiftreg_redgedetect: entity lib_src.shiftreg_redgedetect(rtl)
        generic map (
            INT_BUFFER_WIDTH => INT_BUFFER_WIDTH,
            INT_PATTERN_WIDTH => INT_PATTERN_WIDTH,
            INT_DETECT_PATTERN => INT_DETECT_PATTERN
        )
        port map (
            -- Inputs
            clk => sampl_clk,
            in_noisy_channel => sl_pulse_in,

            -- Outputs
            out_ready => open,
            out_valid => open,
            out_event => sl_redgedetect_event,
            out_pulsed => open
        );


        -- Johnson Counter counts on every event on its input
        inst_johnson_cnt : entity lib_src.johnson_cnt(rtl)
        generic map (
            SL_RST_VAL => SL_RST_VAL,
            INT_JOHNS_CNT_WIDTH => INT_JOHNS_CNT_WIDTH
        )
        port map (
            -- Inputs
            clk => sampl_clk,
            rst => '0',
            in_event => sl_redgedetect_event,

            -- Outputs
            out_ready => open,
            out_valid_pulsed => open,
            out_data => slv_johns_counter_val
        );


        -- Transfer detected rising edge from sampl_clk domain to sys_clk domain operating with fedge logic 
        inst_nff_cdcc_fedge: entity lib_src.nff_cdcc_fedge(rtl)
        generic map (
            INT_ASYNC_FLOPS_CNT => INT_ASYNC_FLOPS_CNT,
            INT_ASYNC_FLOPS_CNT_EVENTGEN => INT_ASYNC_FLOPS_CNT_EVENTGEN,
            INT_DATA_WIDTH => INT_DATA_WIDTH,
            INT_FLOPS_BEFORE_CROSSING_CNT => INT_FLOPS_BEFORE_CROSSING_CNT,
            INT_FLOPS_BEFORE_CROSSING_EVENTGEN => INT_FLOPS_BEFORE_CROSSING_EVENTGEN
        )
        port map (
            -- Write ports (faster clock, wr_en at rate A)
            clk_write => sampl_clk,
            wr_data => slv_johns_counter_val,

            -- Read ports (slower clock, sends event pulses to faster clk domain at rate A)
            clk_read => sys_clk,
            rd_valid_pulsed => sl_cdcc_valid_pulsed_out,
            rd_data => slv_cdcc_data_out
        );


        -- Decode the counter value and produce an output pulse "equal" to the number of counts per second
        pulse_out <= sl_ctrl_pulse_out;
        inst_memristor_ctrl : entity lib_src.memristor_ctrl(rtl)
        generic map (
            INT_CTRL_DATA_WIDTH => INT_CTRL_DATA_WIDTH,
            INT_CLK_SYS_HZ => INT_CLK_SYS_HZ,
            INT_LAP_DURATION_NS => INT_LAP_DURATION_NS
        )
        port map (
            -- Clocks
            clk0 => clk0,
            clk1 => clk1,
            clk2 => clk2,
            clk3 => clk3,
            clk4 => clk4,
            clk5 => clk5,
            sys_clk => sys_clk,

            -- Inputs
            in_valid_pulsed => sl_cdcc_valid_pulsed_out,
            in_data => slv_cdcc_data_out,

            -- Outputs
            out_pulse => sl_ctrl_pulse_out
        );


    end architecture;