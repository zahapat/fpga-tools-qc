    library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

    entity nff_cdcc_fedge is
        generic (
            INT_ASYNC_FLOPS_CNT : positive := 2;
            INT_ASYNC_FLOPS_CNT_EVENTGEN : positive := 2;
            INT_DATA_WIDTH : natural := 3;
            INT_FLOPS_BEFORE_CROSSING_CNT : positive := 1;
            INT_FLOPS_BEFORE_CROSSING_EVENTGEN : positive := 1
        );
        port (
            -- Write ports (faster clock, wr_en at rate A)
            clk_write : in  std_logic;
            wr_data   : in  std_logic_vector(INT_DATA_WIDTH-1 downto 0);

            -- Read ports (slower clock, rd_en_pulse at rate similar to A)
            clk_read : in  std_logic;
            rd_valid : out std_logic;
            rd_data  : out std_logic_vector(INT_DATA_WIDTH-1 downto 0)
        );
    end nff_cdcc_fedge;

    architecture rtl of nff_cdcc_fedge is

        -- Sample and latch data
        signal slv_data_to_cross_latched : std_logic_vector(INT_DATA_WIDTH-1 downto 0) := (others => '0');
        signal sl_bit_to_cross_latched : std_logic := '0';

        type t_slv_data_to_cross_2d is array(INT_FLOPS_BEFORE_CROSSING_CNT downto 0) of std_logic_vector(INT_DATA_WIDTH-1 downto 0);
        signal slv_data_to_cross_2d : t_slv_data_to_cross_2d := (others => (others => '0'));
        signal slv_bit_to_cross : std_logic_vector(INT_FLOPS_BEFORE_CROSSING_CNT downto 0) := (others => '0');


        -- CDCC: Async n-FF synchronizer
        type t_slv_data_async_2ff_2d is array(INT_ASYNC_FLOPS_CNT downto 0) of std_logic_vector(INT_DATA_WIDTH-1 downto 0);
        signal slv_data_asyncff_2d : t_slv_data_async_2ff_2d := (others => (others => '0'));
        signal slv_bit_asyncff : std_logic_vector(INT_ASYNC_FLOPS_CNT downto 0) := (others => '0');
        signal slv_data_synchronized : std_logic_vector(INT_DATA_WIDTH-1 downto 0) := (others => '0');
        signal sl_bit_synchronized : std_logic := '0';


        -- Event generator / Oscillator
        signal sl_eventgen : std_logic := '0';
        signal sl_flop_eventgen_for_samplhz : std_logic := '0';
        signal slv_eventgen_to_cross : std_logic_vector(INT_FLOPS_BEFORE_CROSSING_EVENTGEN downto 0) := (others => '0');
        signal slv_bit_asyncff_eventgen : std_logic_vector(INT_ASYNC_FLOPS_CNT_EVENTGEN downto 0) := (others => '0');

        signal sl_flop_eventgen_samplhz : std_logic := '0';
        signal sl_flop_eventgen_samplhz_p1 : std_logic := '0';


        -- Output logic
        signal sl_bit_synchronized_p1 : std_logic := '0';


        -- Attributes to prevent logic trimming and 
        attribute KEEP : string;
        attribute KEEP of slv_bit_asyncff_eventgen: signal is "TRUE";
        attribute KEEP of slv_eventgen_to_cross: signal is "TRUE";
        attribute KEEP of slv_data_asyncff_2d : signal is "TRUE";
        attribute KEEP of slv_bit_asyncff : signal is "TRUE";
        attribute KEEP of slv_data_to_cross_2d : signal is "TRUE";
        attribute KEEP of slv_bit_to_cross : signal is "TRUE";

        attribute DONT_TOUCH : string;
        attribute DONT_TOUCH of slv_bit_asyncff_eventgen: signal is "TRUE";
        attribute DONT_TOUCH of slv_eventgen_to_cross: signal is "TRUE";
        attribute DONT_TOUCH of slv_data_asyncff_2d: signal is "TRUE";
        attribute DONT_TOUCH of slv_bit_asyncff: signal is "TRUE";
        attribute DONT_TOUCH of slv_data_to_cross_2d: signal is "TRUE";
        attribute DONT_TOUCH of slv_bit_to_cross: signal is "TRUE";

        attribute SHREG_EXTRACT : string;
        attribute SHREG_EXTRACT of slv_bit_asyncff_eventgen: signal is "FALSE";
        attribute SHREG_EXTRACT of slv_eventgen_to_cross: signal is "FALSE";
        attribute SHREG_EXTRACT of slv_data_asyncff_2d: signal is "FALSE";
        attribute SHREG_EXTRACT of slv_bit_asyncff: signal is "FALSE";
        attribute SHREG_EXTRACT of slv_data_to_cross_2d: signal is "FALSE";
        attribute SHREG_EXTRACT of slv_bit_to_cross: signal is "FALSE";

        attribute ASYNC_REG : string;
        attribute ASYNC_REG of slv_bit_asyncff_eventgen: signal is "TRUE";
        attribute ASYNC_REG of slv_data_asyncff_2d : signal is "TRUE";
        attribute ASYNC_REG of slv_bit_asyncff : signal is "TRUE";


    begin


        -- Event generator: An oscillator originating in the slow domain, propagating to the faster domain
        proc_event_gen_slow_domain : process(clk_read)
        begin
            if falling_edge(clk_read) then
                -- This signal works as an write enable signal
                sl_eventgen <= not sl_eventgen;
                slv_eventgen_to_cross(0) <= sl_eventgen;
            end if;
        end process;


        -- Event Generator Before Crossing: Stabilize event oscillations in the slow domain
        proc_event_gen_before_crossing : process(clk_read)
        begin
            if falling_edge(clk_read) then

                for i in 1 to INT_FLOPS_BEFORE_CROSSING_EVENTGEN loop
                    -- Signal changes infrequently (relative to the fast domain)
                    slv_eventgen_to_cross(i) <= slv_eventgen_to_cross(i-1);
                end loop;

            end if;
        end process;


        -- CDCC: Propagate the event oscillations to the faster domain in phase with the slower one
        proc_event_gen_crossing : process(clk_write)
        begin
            if falling_edge(clk_write) then

                -- Crossing
                slv_bit_asyncff_eventgen(0) <= slv_eventgen_to_cross(INT_FLOPS_BEFORE_CROSSING_EVENTGEN); -- set_false_path
                for i in 1 to INT_ASYNC_FLOPS_CNT_EVENTGEN loop
                    slv_bit_asyncff_eventgen(i) <= slv_bit_asyncff_eventgen(i-1);
                end loop;

                sl_flop_eventgen_samplhz <= slv_bit_asyncff_eventgen(INT_ASYNC_FLOPS_CNT_EVENTGEN);
                sl_flop_eventgen_samplhz_p1 <= sl_flop_eventgen_samplhz;

            end if;
        end process;


        -- Write: Latch, capture data to cross + create an event: each change = new data
        -- slv_data_to_cross_2d(0) <= slv_data_to_cross_latched;
        -- slv_bit_to_cross(0) <= sl_bit_to_cross_latched;
        proc_latch_data_writeclk : process(clk_write)
        begin
            if falling_edge(clk_write) then

                for i in 1 to INT_FLOPS_BEFORE_CROSSING_CNT loop
                    -- Synchronize data (changes infrequently)
                    slv_data_to_cross_2d(i) <= slv_data_to_cross_2d(i-1);

                    -- Synchronize 1 bit (changes infrequently)
                    slv_bit_to_cross(i) <= slv_bit_to_cross(i-1);
                end loop;

                -- Sample data on each event, since they operate on fedge
                if sl_flop_eventgen_samplhz_p1 /= sl_flop_eventgen_samplhz then
                    slv_data_to_cross_2d(0) <= wr_data;
                    slv_bit_to_cross(0) <= not slv_bit_to_cross(0);
                end if;

            end if;
        end process;


        -- Read: CDC Circuit
        proc_cdcc_readclk : process(clk_read)
        begin
            if falling_edge(clk_read) then

                -- Crossing
                slv_data_asyncff_2d(0) <= slv_data_to_cross_2d(INT_FLOPS_BEFORE_CROSSING_CNT);  -- set_false_path
                slv_bit_asyncff(0) <= slv_bit_to_cross(INT_FLOPS_BEFORE_CROSSING_CNT);          -- set_false_path

                -- Async flops
                for i in 1 to INT_ASYNC_FLOPS_CNT loop
                    -- Synchronize data (changes infrequently)
                    slv_data_asyncff_2d(i) <= slv_data_asyncff_2d(i-1);

                    -- Synchronize 1 bit (changes infrequently)
                    slv_bit_asyncff(i) <= slv_bit_asyncff(i-1);
                end loop;

                -- Sync flop
                slv_data_synchronized <= slv_data_asyncff_2d(INT_ASYNC_FLOPS_CNT);
                sl_bit_synchronized <= slv_bit_asyncff(INT_ASYNC_FLOPS_CNT);

            end if;
        end process;


        -- Read: Output logic
        proc_outlogic_readclk : process(clk_read)
        begin
            if falling_edge(clk_read) then

                -- Default
                sl_bit_synchronized_p1 <= sl_bit_synchronized;

                -- Data always propagate further
                rd_data <= slv_data_synchronized;

                -- Valid pulldown
                rd_valid <= '0';

                -- Control (after): valid on data event
                if sl_bit_synchronized_p1 /= sl_bit_synchronized then
                    rd_valid <= '1';
                end if;

            end if;
        end process;

    end architecture;