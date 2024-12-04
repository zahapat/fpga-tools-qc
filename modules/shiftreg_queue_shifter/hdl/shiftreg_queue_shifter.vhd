    library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;
    use ieee.math_real.all;

    library UNISIM;
    use UNISIM.VComponents.all;

    library lib_src;
    use lib_src.types_pack.all;

    entity shiftreg_queue_shifter is
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
    end shiftreg_queue_shifter;
    
    architecture rtl of shiftreg_queue_shifter is
        
        -- Sampler as a Shifter
        -- Has 2 slots
        signal slv_i_wr_data_valid : std_logic_vector(0 downto 0) := (others => '0');
        signal slv_data_buffer_shreg : std_logic_vector(INT_DATA_WIDTH*(INT_QUEUE_DEPTH+1)-1 downto 0) := (others => '0');
        signal slv_valid_buffer_shreg : std_logic_vector((INT_QUEUE_DEPTH+1)-1 downto 0) := (others => '0');

        -- Queue as a Shifter
        -- Has 'INT_QUEUE_DEPTH+1' slots (+1 because index 0 is just for transferring from burst buffer, the rest is loopable)
        signal slv_data_queue_shreg : std_logic_vector(INT_DATA_WIDTH*(INT_QUEUE_DEPTH+1)-1 downto 0) := (others => '0');
        signal slv_valid_queue_shreg : std_logic_vector((INT_QUEUE_DEPTH+1)-1 downto 0) := (others => '0');

        -- Read shifter
        signal slv_post_i_rd_valid_pres : std_logic_vector((INT_QUEUE_DEPTH+1)-1 downto 0) := (others => '0');
        signal slv_post_i_rd_valid_next : std_logic_vector((INT_QUEUE_DEPTH+1)-1 downto 0) := (others => '0');

        -- Flags
        signal sl_o_queue_full : std_logic := '0';
        signal sl_data_loss : std_logic := '0';
        signal sl_buffer_full_latched : std_logic := '0';
        signal sl_queue_full_latched : std_logic := '0';
        signal sl_o_buffer_full : std_logic := '0';


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
            -- slv_insert_bits : std_logic_vector
        ) return std_logic_vector is
            variable v_slv_insert_bits : std_logic_vector(SHIFT_BY_X_BITS-1 downto 0) := (others => '0');
        begin
            -- v_slv_insert_bits(SHIFT_BY_X_BITS-1 downto 0) := slv_insert_bits(SHIFT_BY_X_BITS-1 downto 0);
            return v_slv_insert_bits
                & slv_shifter(slv_shifter'high downto SHIFT_BY_X_BITS);
        end function;



        function slv_shift_right_insert (
            slv_shifter : std_logic_vector;
            SHIFT_BY_X_BITS : positive := 1;
            slv_insert_bits : std_logic_vector
        ) return std_logic_vector is
            variable v_slv_insert_bits : std_logic_vector(SHIFT_BY_X_BITS-1 downto 0) := (others => '0');
        begin
            v_slv_insert_bits(SHIFT_BY_X_BITS-1 downto 0) := slv_insert_bits(SHIFT_BY_X_BITS-1 downto 0);
            return v_slv_insert_bits
                & slv_shifter(slv_shifter'high downto SHIFT_BY_X_BITS);
        end function;


        -- And gate to multiple signals
        function and_all_bits_in_slv (
            slv_signal : std_logic_vector; -- min 2 bit wide slv
            SLV_WIDTH : positive
        ) return std_logic is
            variable v_slv_signal : std_logic_vector(SLV_WIDTH-1 downto 0) := (others => '0');
            variable v_sl_output : std_logic := '0';
        begin
            v_slv_signal(SLV_WIDTH-1 downto 0) := slv_signal(SLV_WIDTH-1 downto 0);
            v_sl_output := v_slv_signal(SLV_WIDTH-1);
            for i in SLV_WIDTH-2 downto 0 loop
                v_sl_output := v_sl_output and v_slv_signal(i);
            end loop;
            return v_sl_output;
        end function;

        function not_and_all_bits_in_slv (
            slv_signal : std_logic_vector; -- min 2 bit wide slv
            SLV_WIDTH : positive
        ) return std_logic is
            variable v_slv_signal : std_logic_vector(SLV_WIDTH-1 downto 0) := (others => '0');
            variable v_sl_output : std_logic := '0';
        begin
            v_slv_signal(SLV_WIDTH-1 downto 0) := slv_signal(SLV_WIDTH-1 downto 0);
            v_sl_output := not v_slv_signal(SLV_WIDTH-1);
            for i in SLV_WIDTH-2 downto 0 loop
                v_sl_output := v_sl_output and not v_slv_signal(i);
            end loop;
            return v_sl_output;
        end function;

    begin

        
        -- Output
        o_rd_data_rdy <= slv_valid_queue_shreg(slv_valid_queue_shreg'high);
        o_rd_data <= slv_data_queue_shreg((INT_QUEUE_DEPTH+1)*INT_DATA_WIDTH-1 downto INT_QUEUE_DEPTH*INT_DATA_WIDTH);
        
        -- Read valid backpropagation shifter
        slv_post_i_rd_valid_pres <= i_rd_valid 
            & slv_post_i_rd_valid_next(slv_post_i_rd_valid_next'high downto 1);

        -- Flags
        o_buffer_empty <= not slv_valid_queue_shreg(0) and not slv_valid_queue_shreg(1);
        o_queue_empty <= not_and_all_bits_in_slv(slv_valid_queue_shreg, slv_valid_queue_shreg'length);
        sl_o_buffer_full <= slv_valid_queue_shreg(0) and slv_valid_queue_shreg(1);
        o_buffer_full <= sl_o_buffer_full;
        sl_o_queue_full <= and_all_bits_in_slv(slv_valid_queue_shreg, slv_valid_queue_shreg'length);
        o_queue_full <= sl_o_queue_full;
        o_buffer_full_latched <= sl_buffer_full_latched;
        o_queue_full_latched <= sl_queue_full_latched;

        -- Data loss flag
        o_data_loss <= sl_data_loss; -- attempt to write to full buffer = data loss
        proc_shiftreg_queue_shifter : process(clk)
        begin
            if rising_edge(clk) then

                -- Always shift buffer and insert current valid flag and data on the left (most significant bits)
                -- This buffer serves to scan for available positions in data queue
                -- slv_valid_buffer_shreg <= slv_shift_right_insert(slv_valid_buffer_shreg, 1, slv_i_wr_data_valid);
                -- slv_data_buffer_shreg <= slv_shift_right_insert(slv_data_buffer_shreg, INT_DATA_WIDTH, i_wr_data);

                slv_post_i_rd_valid_next <= slv_post_i_rd_valid_pres;

                -- Queue full latched
                if slv_valid_queue_shreg = std_logic_vector(to_unsigned(
                    2**(slv_valid_queue_shreg'length)-1, slv_valid_queue_shreg'length)) then 
                    sl_queue_full_latched <= '1';
                end if;

                -- Buffer full latched
                if sl_o_buffer_full = '1' then
                    sl_buffer_full_latched <= '1';
                end if;

                -- Data loss latched
                if i_wr_data_valid = '1' and sl_o_buffer_full = '1' then
                    sl_data_loss <= '1';
                end if;

                ----------------------
                -- Data Queue Write --
                ----------------------
                -- Stage 1 of the Queue
                if slv_valid_queue_shreg(1) = '0' or slv_post_i_rd_valid_pres(1) = '1' then
                    -- Mandatory
                    slv_valid_queue_shreg(1) <= slv_valid_queue_shreg(0);
                    slv_data_queue_shreg(2*INT_DATA_WIDTH-1 downto 1*INT_DATA_WIDTH) <= slv_data_queue_shreg(1*INT_DATA_WIDTH-1 downto 0*INT_DATA_WIDTH);
                end if;

                -- Stages 2, 3, . . . of the Queue
                -- Loop 2 to n: Stack valid transactions in the queue next to each other
                for i in 2 to INT_QUEUE_DEPTH loop
                    if slv_valid_queue_shreg(i) = '0' or slv_post_i_rd_valid_pres(i) = '1' then
                        slv_valid_queue_shreg(i-1) <= slv_valid_queue_shreg(i-2);
                        slv_data_queue_shreg((i)*INT_DATA_WIDTH-1 downto (i-1)*INT_DATA_WIDTH) <= slv_data_queue_shreg((i-1)*INT_DATA_WIDTH-1 downto (i-2)*INT_DATA_WIDTH);
    
                        -- Mandatory
                        slv_valid_queue_shreg(i) <= slv_valid_queue_shreg(i-1);
                        slv_data_queue_shreg((i+1)*INT_DATA_WIDTH-1 downto i*INT_DATA_WIDTH) <= slv_data_queue_shreg(i*INT_DATA_WIDTH-1 downto (i-1)*INT_DATA_WIDTH);
                    end if;
                end loop;


                --------------------------
                -- Writing to the Queue --
                --------------------------
                -- If the queue is full, keep the last item valid (it will become '0' otherwise, which is incorrect)
                -- This will also prevent from overriding the last item in the queue unless slv_valid_queue_shreg(1) or slv_valid_queue_shreg(0) is zero again
                slv_valid_queue_shreg(0) <= sl_o_queue_full;
                if slv_valid_queue_shreg(0) = '0' or slv_valid_queue_shreg(1) = '0' then
                    -- This 'or' condition allows to store up to two successive valid transactions
                    -- Read from burst Buffer, transfer to queue position 0 if this position is available
                    -- Skip checking if current transation is valid because if not valid, the queue will not stack the transation and will ignore it
                    slv_valid_queue_shreg(0) <= i_wr_data_valid;
                    slv_data_queue_shreg(INT_DATA_WIDTH-1 downto 0) <= i_wr_data;
                    -- slv_valid_queue_shreg(0) <= slv_valid_buffer_shreg(0);
                    -- slv_data_queue_shreg(INT_DATA_WIDTH-1 downto 0) <= slv_data_buffer_shreg(INT_DATA_WIDTH-1 downto 0);

                -- If read has been requested, force deassert slv_valid_queue_shreg(0)
                elsif slv_post_i_rd_valid_pres(0) = '1' then
                    slv_valid_queue_shreg(0) <= '0';
                end if;


            end if;
        end process;

    end architecture;