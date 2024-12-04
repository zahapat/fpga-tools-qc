    library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;
    use ieee.math_real.all;

    use std.textio.all;
    use std.env.finish;

    library lib_src;
    use lib_src.types_pack.all;
    use lib_src.const_pack.all;
    use lib_src.generics.all;

    library lib_sim;
    use lib_sim.types_pack_tb.all;
    use lib_sim.const_pack_tb.all;
    use lib_sim.essentials_tb.all;
    use lib_sim.clk_pack_tb.all;

    entity shiftreg_queue_buffer_tb is
    end shiftreg_queue_buffer_tb;

    architecture sim of shiftreg_queue_buffer_tb is

        -- Generics
        constant REAL_CLK_HZ : real := 400.0e6;
        constant INT_DATA_WIDTH : natural := 32;
        constant INT_QUEUE_DEPTH : natural := 4;

        -- Ports
        signal i_wr_data_valid : std_logic := '0';
        signal i_wr_data : std_logic_vector(INT_DATA_WIDTH-1 downto 0) := (others => '0');
        signal i_rd_valid : std_logic := '0';
        signal o_rd_data : std_logic_vector(INT_DATA_WIDTH-1 downto 0) := (others => '0');
        signal o_rd_data_rdy : std_logic := '0';
        signal o_buffer_empty : std_logic := '0';
        signal o_queue_empty : std_logic := '0';
        signal o_buffer_full : std_logic := '0';
        signal o_queue_full : std_logic := '0';
        signal o_buffer_full_latched : std_logic := '0';
        signal o_queue_full_latched : std_logic := '0';
        signal o_data_loss : std_logic := '0'; -- to LED - should never be asserted


        -- Print to console "TEST OK."
        procedure print_test_done is
            variable str : line;
        begin
            write(str, string'("TEST DONE."));
            writeline(output, str);
        end procedure;

        -- Clocks
        constant CLK_PERIOD : time := 1.0 sec / REAL_CLK_HZ;
        signal clk : std_logic := '0';

    begin

        -- Clocking
        clk <= not clk after CLK_PERIOD / 2.0;

        -- DUT Instantiation
        dut_shiftreg_queue_buffer : entity lib_src.shiftreg_queue_buffer(rtl)
        generic map (
            REAL_CLK_HZ => REAL_CLK_HZ,
            INT_DATA_WIDTH => INT_DATA_WIDTH,
            INT_QUEUE_DEPTH => INT_QUEUE_DEPTH
        )
        port map (
            -- clock
            clk => clk,

            -- Write request and Input to queue
            i_wr_data_valid => i_wr_data_valid,
            i_wr_data => i_wr_data,

            -- Read request and Output from queue
            i_rd_valid => i_rd_valid,
            o_rd_data => o_rd_data,
            o_rd_data_rdy => o_rd_data_rdy,

            -- Flags
            o_queue_empty => o_queue_empty,
            o_queue_full => o_queue_full,
            o_queue_full_latched => o_queue_full_latched, -- to LED - should never be asserted
            o_data_loss => o_data_loss,
            o_buffer_full => o_buffer_full,
            o_buffer_empty => o_buffer_empty
        );

        
        -- Sequencer
        proc_sequencer : process
        begin

            wait for 60 ns;
            wait until rising_edge(clk);
            i_wr_data_valid <= '1';
            i_wr_data <= std_logic_vector(to_unsigned(1, i_wr_data'length));
            wait until rising_edge(clk);
            i_wr_data_valid <= '0';

            wait for 60 ns;
            wait until rising_edge(clk);
            i_wr_data_valid <= '1';
            i_wr_data <= std_logic_vector(to_unsigned(2, i_wr_data'length));
            wait until rising_edge(clk);
            i_wr_data_valid <= '0';

            -- Two transactions in a row
            wait for 60 ns;
            wait until rising_edge(clk);
            i_wr_data_valid <= '1';
            i_wr_data <= std_logic_vector(to_unsigned(3, i_wr_data'length));
            wait until rising_edge(clk);
            i_wr_data_valid <= '1';
            i_wr_data <= std_logic_vector(to_unsigned(4, i_wr_data'length));
            wait until rising_edge(clk);
            i_wr_data_valid <= '0';

            -- Three transactions in a row
            wait for 60 ns;
            wait until rising_edge(clk);
            i_wr_data_valid <= '1';
            i_wr_data <= std_logic_vector(to_unsigned(5, i_wr_data'length));
            wait until rising_edge(clk);
            i_wr_data_valid <= '1';
            i_wr_data <= std_logic_vector(to_unsigned(6, i_wr_data'length));
            wait until rising_edge(clk);
            i_wr_data_valid <= '1';
            i_wr_data <= std_logic_vector(to_unsigned(7, i_wr_data'length));
            wait until rising_edge(clk);
            i_wr_data_valid <= '0';

            wait for 160 ns;
            -- One transaction to test data loss
            wait until rising_edge(clk);
            i_wr_data_valid <= '1';
            i_wr_data <= std_logic_vector(to_unsigned(8, i_wr_data'length));
            wait until rising_edge(clk);
            i_wr_data_valid <= '0';


            -- Read 1x
            wait for 400 ns;
            -- One transaction to test data loss
            wait until rising_edge(clk);
            i_rd_valid <= '1';
            wait until rising_edge(clk);
            i_rd_valid <= '0';


            -- Read 1x
            wait for 400 ns;
            -- One transaction to test data loss
            wait until rising_edge(clk);
            i_rd_valid <= '1';
            wait until rising_edge(clk);
            i_rd_valid <= '0';


            -- Read 1x
            wait for 400 ns;
            -- One transaction to test data loss
            wait until rising_edge(clk);
            i_rd_valid <= '1';
            wait until rising_edge(clk);
            i_rd_valid <= '0';


            -- Read 1x
            wait for 400 ns;
            -- One transaction to test data loss
            wait until rising_edge(clk);
            i_rd_valid <= '1';
            wait until rising_edge(clk);
            i_rd_valid <= '0';


            -- Read 1x
            wait for 400 ns;
            -- One transaction to test data loss
            wait until rising_edge(clk);
            i_rd_valid <= '1';
            wait until rising_edge(clk);
            i_rd_valid <= '0';


            -- Read 1x
            wait for 400 ns;
            -- One transaction to test data loss
            wait until rising_edge(clk);
            i_rd_valid <= '1';
            wait until rising_edge(clk);
            i_rd_valid <= '0';


            wait for 40 us;
            -- wait until rising_edge(fifo_full);

            print_test_done;
            finish;
            wait;
        end process;

    end architecture;







































