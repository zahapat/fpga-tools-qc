    library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

    entity nff_cdcc_cntr is
        generic (
            ASYNC_FLOPS_CNT : positive := 2;
            CNTR_WIDTH : positive := 2;
            FLOPS_BEFORE_CROSSING_CNT : natural := 1;
            WR_READY_DEASSERTED_CYCLES : positive := 3
        );
        port (
            -- Write ports
            clk_write : in  std_logic;
            wr_en     : in  std_logic;
            wr_ready  : out std_logic;

            -- Read ports
            clk_read : in  std_logic;
            rd_valid : out std_logic;
            rd_data  : out std_logic_vector(CNTR_WIDTH-1 downto 0)
        );
    end nff_cdcc_cntr;

    architecture rtl of nff_cdcc_cntr is

        -- Sample and latch data
        signal slv_data_to_cross_latched : std_logic_vector(CNTR_WIDTH-1 downto 0) := (others => '0');

        type t_slv_data_to_cross_2d is array(FLOPS_BEFORE_CROSSING_CNT downto 0) of std_logic_vector(CNTR_WIDTH-1 downto 0);
        signal slv_data_to_cross_2d : t_slv_data_to_cross_2d := (others => (others => '0'));


        -- CDCC: Async n-FF synchronizer
        type t_slv_data_async_2ff_2d is array(ASYNC_FLOPS_CNT downto 0) of std_logic_vector(CNTR_WIDTH-1 downto 0);
        signal slv_data_asyncff_2d : t_slv_data_async_2ff_2d := (others => (others => '0'));
        signal slv_data_synchronized : std_logic_vector(CNTR_WIDTH-1 downto 0) := (others => '0');


        -- Output logic
        signal slv_data_synchronized_p1 : std_logic_vector(CNTR_WIDTH-1 downto 0) := (others => '0');


        -- Attributes to prevent logic trimming and removing it
        attribute KEEP : string;
        attribute KEEP of slv_data_asyncff_2d : signal is "TRUE";
        attribute KEEP of slv_data_to_cross_2d : signal is "TRUE";

        attribute DONT_TOUCH : string;
        attribute DONT_TOUCH of slv_data_asyncff_2d: signal is "TRUE";
        attribute DONT_TOUCH of slv_data_to_cross_2d: signal is "TRUE";

        -- Ucomment if necessary
        -- attribute SHREG_EXTRACT : string;
        -- attribute SHREG_EXTRACT of slv_data_asyncff_2d: signal is "FALSE";
        -- attribute SHREG_EXTRACT of slv_data_to_cross_2d: signal is "FALSE";

        -- Registers capable of receiving asynchronous data in the D input pin relative to the source clock
        attribute ASYNC_REG : boolean;
        attribute ASYNC_REG of slv_data_asyncff_2d : signal is true;

        signal sl_wr_ready : std_logic := '0';
        signal sl_wr_busy : std_logic := '0';
        signal slv_wr_ready_srl : std_logic_vector(WR_READY_DEASSERTED_CYCLES+1 downto 0) := (others => '0');

        signal slv_wr_gray_to_bin : std_logic_vector(CNTR_WIDTH-1 downto 0) := (others => '0');
        signal slv_wr_incremented_bin : std_logic_vector(CNTR_WIDTH-1 downto 0) := (others => '0');

        procedure incr_bin_slv (
            signal slv_bin_number : inout std_logic_vector(CNTR_WIDTH-1 downto 0)
        ) is begin
            slv_bin_number <= std_logic_vector(unsigned(slv_bin_number) + "1");
        end procedure;

        function bin_to_gray (
            slv_bin_number : std_logic_vector(CNTR_WIDTH-1 downto 0)
        ) return std_logic_vector is
            variable v_shifted_right_by_one : std_logic_vector(CNTR_WIDTH-1 downto 0) := (others => '0');
            variable v_bin_xored_with_shifted_bin : std_logic_vector(CNTR_WIDTH-1 downto 0) := (others => '0');
        begin
            v_shifted_right_by_one := '0' & slv_bin_number(CNTR_WIDTH-1 downto 1);

            for i in 0 to CNTR_WIDTH-1 loop
                v_bin_xored_with_shifted_bin(i) := slv_bin_number(i) xor v_shifted_right_by_one(i);
            end loop;

            return v_bin_xored_with_shifted_bin;
        end function;

        function gray_to_bin (
            slv_gray_number : std_logic_vector(CNTR_WIDTH-1 downto 0)
        ) return std_logic_vector is
            variable v_xored_accumulated : std_logic_vector(CNTR_WIDTH-1 downto 0) := (others => '0');
        begin

            for i in 0 to CNTR_WIDTH-1 loop
                for j in i to CNTR_WIDTH-1 loop
                    v_xored_accumulated(i) := v_xored_accumulated(i) xor slv_gray_number(j);
                end loop;
            end loop;

            return v_xored_accumulated;
        end function;

    begin

        -- Module is ready once busy flag is low (if ring buffer is full)
        wr_ready <= not sl_wr_busy;

        proc_cdcc_wr_ready : process(clk_write)
        begin
            if rising_edge(clk_write) then

                -- Always shift
                slv_wr_ready_srl(slv_wr_ready_srl'high downto 1) <=
                    slv_wr_ready_srl(slv_wr_ready_srl'high-1 downto 1) 
                    & slv_wr_ready_srl(0);

                -- Ring buffer is full, module is not busy
                if slv_wr_ready_srl(WR_READY_DEASSERTED_CYCLES-1) = slv_wr_ready_srl(0) then
                    sl_wr_busy <= '0';
                end if;

                -- Assert wr_busy only if not busy and write enable has been detected
                if wr_en = '1' and sl_wr_busy = '0' then
                    sl_wr_busy <= wr_en;
                    slv_wr_ready_srl(0) <= not slv_wr_ready_srl(0); -- Set new value for full ring buffer
                end if;

            end if;
        end process;

        slv_wr_gray_to_bin <= gray_to_bin(slv_data_to_cross_2d(0));
        slv_wr_incremented_bin <= std_logic_vector(unsigned(slv_wr_gray_to_bin) + "1");
        proc_latch_data_writeclk : process(clk_write)
            variable v_slv_wr_incremented_bin : std_logic_vector(CNTR_WIDTH-1 downto 0);
        begin
            if rising_edge(clk_write) then

                for i in 1 to FLOPS_BEFORE_CROSSING_CNT loop
                    -- Synchronize data (changes infrequently)
                    slv_data_to_cross_2d(i) <= slv_data_to_cross_2d(i-1);
                end loop;

                -- if wr_en = '1' and sl_wr_busy = '0' then
                if wr_en = '1' then
                    -- v_slv_wr_incremented_bin := gray_to_bin(slv_data_to_cross_2d(0));
                    slv_data_to_cross_2d(0) <= bin_to_gray(slv_wr_incremented_bin);
                end if;

            end if;
        end process;


        -- Read: CDC Circuit
        proc_cdcc_readclk : process(clk_read)
        begin
            if rising_edge(clk_read) then

                -- #TODO PERFORMANCE BOTTLENECK
                -- #TODO Should this be in the clk_write domain? I guess not... 
                slv_data_asyncff_2d(0) <= slv_data_to_cross_2d(FLOPS_BEFORE_CROSSING_CNT);  -- set_false_path

                -- Async flops
                -- #TODO Redo this. One can not specify the number of flip-flops in total (ASYNC_FLOPS_CNT=1 is actually 2)
                for i in 1 to ASYNC_FLOPS_CNT loop
                    -- Synchronize data (changes infrequently)
                    slv_data_asyncff_2d(i) <= slv_data_asyncff_2d(i-1);
                end loop;

                -- Sync flop
                slv_data_synchronized <= slv_data_asyncff_2d(ASYNC_FLOPS_CNT);

            end if;
        end process;


        -- Read: Output logic
        proc_outlogic_readclk : process(clk_read)
        begin
            if rising_edge(clk_read) then

                -- Default
                slv_data_synchronized_p1 <= slv_data_synchronized;

                -- Data always propagate further
                rd_data <= gray_to_bin(slv_data_synchronized);

                -- Valid pulldown
                rd_valid <= '0';

                -- Control (after): valid on data event (still gray value, only 1 bit changes, should be fast)
                if slv_data_synchronized_p1 /= slv_data_synchronized then
                    rd_valid <= '1';
                end if;

            end if;
        end process;

    end architecture;