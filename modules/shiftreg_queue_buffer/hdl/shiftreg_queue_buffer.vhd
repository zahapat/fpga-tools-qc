    library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;
    use ieee.math_real.all;

    library UNISIM;
    use UNISIM.VComponents.all;

    library lib_src;
    use lib_src.types_pack.all;

    entity shiftreg_queue_buffer is
        generic (
            REAL_CLK_HZ : real := 400.0e6;
            INT_DATA_WIDTH : natural := 28;
            INT_QUEUE_DEPTH : positive := 4
        );
        port (
            -- clock
            clk : in std_logic;

            -- Write request and Input to queue
            i_wr_data_valid : in std_logic;
            i_wr_data : in std_logic_vector(INT_DATA_WIDTH-1 downto 0);

            -- Read request and Output from queue
            i_rd_valid : in std_logic;
            o_rd_data : out std_logic_vector(INT_DATA_WIDTH-1 downto 0);
            o_rd_data_rdy : out std_logic;

            -- Flags
            o_buffer_empty : out std_logic;
            o_queue_empty : out std_logic;
            o_buffer_full : out std_logic;
            o_queue_full : out std_logic;
            o_buffer_full_latched : out std_logic;
            o_queue_full_latched : out std_logic;
            o_data_loss : out std_logic -- to LED - should never be asserted
        );
    end shiftreg_queue_buffer;
    
    architecture rtl of shiftreg_queue_buffer is
        
        -- Sampler as a Shifter
        -- Has 2 slots
        signal sl_i_wr_data_valid_event_p1 : std_logic := '0';
        signal sl_i_wr_data_valid_event_match : std_logic := '0';
        signal slv_data_buffer_shreg : std_logic_vector(INT_DATA_WIDTH*(2)-1 downto 0) := (others => '0');
        signal slv_valid_buffer_shreg : std_logic_vector(2-1 downto 0) := (others => '0');
        signal slv_event_buffer_shreg : std_logic_vector(2-1 downto 0) := (others => '0');

        -- Queue as a Shifter
        -- Has 'INT_QUEUE_DEPTH+1' slots (+1 because index 0 is just for transferring from burst buffer, the rest is loopable)
        signal slv_data_queue_shreg : std_logic_vector(INT_DATA_WIDTH*(INT_QUEUE_DEPTH+1)-1 downto 0) := (others => '0');
        signal slv_valid_queue_shreg : std_logic_vector((INT_QUEUE_DEPTH+1)-1 downto 0) := (others => '0');

        -- Read shifter
        signal slv_post_i_rd_valid : std_logic_vector((INT_QUEUE_DEPTH+1)-1 downto 0) := (others => '0');

        -- Flags
        signal sl_data_loss : std_logic := '0';
        signal sl_buffer_full_latched : std_logic := '0';
        signal sl_queue_full_latched : std_logic := '0';

        -- Shift left
        function slv_shift_left (
            slv_shifter : std_logic_vector;
            SHIFT_BY_X_BITS : positive := 1
            -- slv_insert_bits : std_logic_vector
        ) return std_logic_vector is
            variable v_slv_insert_bits : std_logic_vector(SHIFT_BY_X_BITS-1 downto 0) := (others => '0');
        begin
            -- v_slv_insert_bits(SHIFT_BY_X_BITS-1 downto 0) := slv_insert_bits(SHIFT_BY_X_BITS-1 downto 0);
            return slv_shifter(slv_shifter'high downto SHIFT_BY_X_BITS) 
                & v_slv_insert_bits;
        end function;

        function slv_shift_right (
            slv_shifter : std_logic_vector;
            SHIFT_BY_X_BITS : positive := 1
        ) return std_logic_vector is
            variable v_slv_insert_bits : std_logic_vector(SHIFT_BY_X_BITS-1 downto 0) := (others => '0');
        begin
            -- v_slv_insert_bits(SHIFT_BY_X_BITS-1 downto 0) := slv_insert_bits(SHIFT_BY_X_BITS-1 downto 0);
            return v_slv_insert_bits
                & slv_shifter(slv_shifter'high downto SHIFT_BY_X_BITS);
        end function;

    begin

        
        -------------------
        -- Data Samplers --
        -------------------
        slv_post_i_rd_valid(4) <= i_rd_valid;
        o_rd_data_rdy <= slv_valid_queue_shreg(4);
        o_rd_data <= slv_data_queue_shreg(5*INT_DATA_WIDTH-1 downto 4*INT_DATA_WIDTH);
        o_buffer_empty <= not slv_valid_buffer_shreg(0) and not slv_valid_buffer_shreg(1);
        o_queue_empty <= not slv_valid_queue_shreg(0) and not slv_valid_queue_shreg(1) and not slv_valid_queue_shreg(2) and not slv_valid_queue_shreg(3) and not slv_valid_queue_shreg(4);
        o_buffer_full <= slv_valid_buffer_shreg(0) and slv_valid_buffer_shreg(1);
        o_queue_full <= slv_valid_queue_shreg(0) and slv_valid_queue_shreg(1) and slv_valid_queue_shreg(2) and slv_valid_queue_shreg(3) and slv_valid_queue_shreg(4);
        o_buffer_full_latched <= sl_buffer_full_latched;
        o_queue_full_latched <= sl_queue_full_latched;
        o_data_loss <= sl_data_loss; -- attempt to write to full buffer
        proc_shiftreg_queue_buffer : process(clk)
        begin
            if rising_edge(clk) then

                sl_i_wr_data_valid_event_p1 <= sl_i_wr_data_valid_event_match;

                slv_post_i_rd_valid(3) <= slv_post_i_rd_valid(4);
                slv_post_i_rd_valid(2) <= slv_post_i_rd_valid(3);
                slv_post_i_rd_valid(1) <= slv_post_i_rd_valid(2);
                slv_post_i_rd_valid(0) <= slv_post_i_rd_valid(1);

                -- Buffer full flags
                if slv_valid_queue_shreg(0) = '1' 
                    and slv_valid_queue_shreg(1) = '1' 
                    and slv_valid_queue_shreg(2) = '1' 
                    and slv_valid_queue_shreg(3) = '1' 
                    and slv_valid_queue_shreg(4) = '1' then
                    sl_queue_full_latched <= '1';
                end if;

                if slv_valid_buffer_shreg(0) = '1' 
                    and slv_valid_queue_shreg(1) = '1' then
                    sl_buffer_full_latched <= '1';
                end if;

                ----------------------
                -- Data Queue Write --
                ----------------------
                -- Stages 2, 3 . . . of the Queue
                -- Loop: Stack valid transactions in the queue next to each other
                if slv_valid_queue_shreg(1) = '0' then
                    slv_valid_queue_shreg(0) <= slv_valid_buffer_shreg(0);
                    slv_data_queue_shreg(INT_DATA_WIDTH-1 downto 0) <= slv_data_buffer_shreg(INT_DATA_WIDTH-1 downto 0);

                    slv_valid_queue_shreg(1) <= slv_valid_queue_shreg(0);
                    slv_data_queue_shreg(2*INT_DATA_WIDTH-1 downto 1*INT_DATA_WIDTH) <= slv_data_queue_shreg(1*INT_DATA_WIDTH-1 downto 0*INT_DATA_WIDTH);
                elsif slv_post_i_rd_valid(1) = '1' then
                    slv_valid_queue_shreg(1) <= '0';
                end if;
                if slv_valid_queue_shreg(2) = '0' then
                    slv_valid_queue_shreg(1) <= slv_valid_queue_shreg(0);
                    slv_data_queue_shreg(2*INT_DATA_WIDTH-1 downto 1*INT_DATA_WIDTH) <= slv_data_queue_shreg(1*INT_DATA_WIDTH-1 downto 0*INT_DATA_WIDTH);

                    slv_valid_queue_shreg(2) <= slv_valid_queue_shreg(1);
                    slv_data_queue_shreg(3*INT_DATA_WIDTH-1 downto 2*INT_DATA_WIDTH) <= slv_data_queue_shreg(2*INT_DATA_WIDTH-1 downto 1*INT_DATA_WIDTH);
                elsif slv_post_i_rd_valid(2) = '1' then
                    slv_valid_queue_shreg(2) <= '0';
                end if;
                if slv_valid_queue_shreg(3) = '0' then
                    slv_valid_queue_shreg(2) <= slv_valid_queue_shreg(1);
                    slv_data_queue_shreg(3*INT_DATA_WIDTH-1 downto 2*INT_DATA_WIDTH) <= slv_data_queue_shreg(2*INT_DATA_WIDTH-1 downto 1*INT_DATA_WIDTH);

                    slv_valid_queue_shreg(3) <= slv_valid_queue_shreg(2);
                    slv_data_queue_shreg(4*INT_DATA_WIDTH-1 downto 3*INT_DATA_WIDTH) <= slv_data_queue_shreg(3*INT_DATA_WIDTH-1 downto 2*INT_DATA_WIDTH);
                elsif slv_post_i_rd_valid(3) = '1' then
                    slv_valid_queue_shreg(3) <= '0';
                end if;
                if slv_valid_queue_shreg(4) = '0' then
                    slv_valid_queue_shreg(3) <= slv_valid_queue_shreg(2);
                    slv_data_queue_shreg(4*INT_DATA_WIDTH-1 downto 3*INT_DATA_WIDTH) <= slv_data_queue_shreg(3*INT_DATA_WIDTH-1 downto 2*INT_DATA_WIDTH);

                    slv_valid_queue_shreg(4) <= slv_valid_queue_shreg(3);
                    slv_data_queue_shreg(5*INT_DATA_WIDTH-1 downto 4*INT_DATA_WIDTH) <= slv_data_queue_shreg(4*INT_DATA_WIDTH-1 downto 3*INT_DATA_WIDTH);
                elsif slv_post_i_rd_valid(4) = '1' then
                    slv_valid_queue_shreg(4) <= '0';
                end if;

                
                -- First Stage of the Queue
                if slv_valid_queue_shreg(0) = '0' and slv_valid_buffer_shreg(0) = '1' then

                        -- Read from burst Buffer, transfer to queue
                        slv_valid_queue_shreg(0) <= slv_valid_buffer_shreg(0);
                        slv_data_queue_shreg(INT_DATA_WIDTH-1 downto 0) <= slv_data_buffer_shreg(INT_DATA_WIDTH-1 downto 0);

                        -- Shift buffer and insert zeros after shifting
                        slv_valid_buffer_shreg <= slv_shift_right(slv_valid_buffer_shreg, 1);
                        slv_data_buffer_shreg <= slv_shift_right(slv_data_buffer_shreg, INT_DATA_WIDTH);

                elsif slv_post_i_rd_valid(0) = '1' then
                    slv_valid_queue_shreg(0) <= '0';
                elsif slv_valid_queue_shreg(0) = '1' and slv_valid_queue_shreg(1) = '1' then
                    slv_valid_queue_shreg(0) <= '1';
                elsif slv_valid_queue_shreg(0) = '1' then
                    slv_valid_queue_shreg(0) <= '0';
                end if;

                -----------------------
                -- Data Buffer Write --
                -----------------------
                -- Burst capture data on valid
                -- On two successive transations, store them into the two last bins in the buffer one after the other
                if i_wr_data_valid = '1' then

                    -- (0) is the first bin before the last one (1)
                    -- must also be free because data in this one will 
                    -- go to 1 in the next clk cycle)
                    if slv_valid_queue_shreg(0) = '0' or slv_valid_buffer_shreg(0) = '0' then
                        slv_valid_buffer_shreg(0)
                            <= i_wr_data_valid;
                        slv_data_buffer_shreg(INT_DATA_WIDTH-1 downto 0)
                            <= i_wr_data;
                    else
                        sl_data_loss <= '1';
                        report "shiftreg_queue_buffer: BUFFER FULL! Data MAY be lost if buffer is full!";
                    end if;


                    ---------------------
                    -- Data Queue Read --
                    ---------------------
                    -- if i_rd_valid = '1' then
                    --     slv_valid_queue_shreg(4) <= '0';
                    -- end if;

                end if;
            end if;
        end process;

    end architecture;