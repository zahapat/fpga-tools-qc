    library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

    entity nff_cdcc_flag is
        generic (
            BYPASS : boolean := false;
            ASYNC_FLOPS_CNT : positive := 2;
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
            rd_valid : out std_logic
        );
    end nff_cdcc_flag;

    architecture rtl of nff_cdcc_flag is

        -- Sample and latch data
        signal sl_bit_to_cross_latched : std_logic := '0';

        signal slv_wr_en_event_to_cross : std_logic_vector(FLOPS_BEFORE_CROSSING_CNT downto 0) := (others => '0');

        -- CDCC: Async n-FF synchronizer
        signal slv_wr_en_event_asyncff : std_logic_vector(ASYNC_FLOPS_CNT downto 0) := (others => '0');
        signal sl_wr_en_event_synchronized : std_logic := '0';

        -- Output logic
        signal sl_wr_en_event_synchronized_p1 : std_logic := '0';


        -- Attributes to prevent logic trimming and removing it
        attribute KEEP : string;
        attribute KEEP of slv_wr_en_event_asyncff : signal is "TRUE";
        attribute KEEP of slv_wr_en_event_to_cross : signal is "TRUE";

        attribute DONT_TOUCH : string;
        attribute DONT_TOUCH of slv_wr_en_event_asyncff: signal is "TRUE";
        attribute DONT_TOUCH of slv_wr_en_event_to_cross: signal is "TRUE";

        -- Ucomment if necessary
        -- attribute SHREG_EXTRACT : string;
        -- attribute SHREG_EXTRACT of slv_wr_en_event_asyncff: signal is "FALSE";
        -- attribute SHREG_EXTRACT of slv_wr_en_event_to_cross: signal is "FALSE";

        attribute ASYNC_REG : boolean;
        attribute ASYNC_REG of slv_wr_en_event_asyncff : signal is true;

        signal sl_wr_ready : std_logic := '0';
        signal sl_wr_busy : std_logic := '0';
        signal sl_next_low_srl_bit : std_logic := '0';
        signal slv_wr_ready_srl : std_logic_vector(WR_READY_DEASSERTED_CYCLES+1 downto 0) := (others => '0');
        signal slv_next_srl : std_logic_vector(WR_READY_DEASSERTED_CYCLES downto 0) := (others => '0');

    begin


        gen_if_clocks_different : if BYPASS = false generate
            
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

            proc_latch_writeclk : process(clk_write)
            begin
                if rising_edge(clk_write) then

                    for i in 1 to FLOPS_BEFORE_CROSSING_CNT loop
                        -- Synchronize 1 bit (changes infrequently)
                        slv_wr_en_event_to_cross(i) <= slv_wr_en_event_to_cross(i-1);
                    end loop;

                    -- if wr_en = '1' and sl_wr_busy = '0' then
                    if wr_en = '1' then
                        slv_wr_en_event_to_cross(0) <= not slv_wr_en_event_to_cross(0);
                    end if;

                end if;
            end process;


            -- Read: CDC Circuit
            proc_cdcc_readclk : process(clk_read)
            begin
                if rising_edge(clk_read) then

                    -- #TODO PERFORMANCE BOTTLENECK
                    slv_wr_en_event_asyncff(0) <= slv_wr_en_event_to_cross(FLOPS_BEFORE_CROSSING_CNT);          -- set_false_path

                    -- Async flops
                    -- #TODO Redo this. One can not specify the number of flip-flops in total (ASYNC_FLOPS_CNT=1 is actually 2)
                    for i in 1 to ASYNC_FLOPS_CNT loop
                        -- Synchronize 1 bit (changes infrequently)
                        slv_wr_en_event_asyncff(i) <= slv_wr_en_event_asyncff(i-1);
                    end loop;

                    -- Sync flop
                    sl_wr_en_event_synchronized <= slv_wr_en_event_asyncff(ASYNC_FLOPS_CNT);

                end if;
            end process;


            -- Read: Output logic
            proc_outlogic_readclk : process(clk_read)
            begin
                if rising_edge(clk_read) then

                    -- Default
                    sl_wr_en_event_synchronized_p1 <= sl_wr_en_event_synchronized;

                    -- Valid pulldown
                    rd_valid <= '0';

                    -- Control (after): valid on data event
                    if sl_wr_en_event_synchronized_p1 /= sl_wr_en_event_synchronized then
                        rd_valid <= '1';
                    end if;

                end if;
            end process;
        end generate;

        -- Bypass this module if requested
        gen_if_clocks_equal : if BYPASS = true generate
            wr_ready <= '1';

            sl_wr_en_event_synchronized <= wr_en;
            rd_valid <= sl_wr_en_event_synchronized;
        end generate;

    end architecture;