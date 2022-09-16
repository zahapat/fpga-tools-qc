    -- Includes all clock generators and all sim instances (DUTs, BFMs, ...)

    library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;
    use ieee.math_real.all;
    -- use ieee.math_complex.all;

    library std;
    use std.textio.all;
    use std.env.all;

    -- TB Packages
    --     * Module-specific TB Packages
    library lib_sim;
    use lib_sim.const_srcname_pack_tb.all;
    use lib_sim.types_srcname_pack_tb.all;
    use lib_sim.signals_srcname_pack_tb.all;

    --     * Global Project-specific TB Packages
    use lib_sim.const_pack_tb.all;
    use lib_sim.types_pack_tb.all;
    use lib_sim.signals_pack_tb.all;

    --     * Generic TB Packages
    use lib_sim.print_pack_tb.all;
    use lib_sim.clk_pack_tb.all;
    use lib_sim.list_string_pack_tb.all;
    use lib_sim.print_list_pack_tb.all;

    -- SRC Packages
    --     * Module-specific SRC Packages (if used, uncomment)
    -- use lib_sim.const_srcname_pack.all;
    -- use lib_sim.types_srcname_pack.all;
    -- use lib_sim.signals_srcname_pack.all;

    --     * Global project-specific SRC Packages
    library lib_src;
    use lib_src.const_pack.all;
    use lib_src.types_pack.all;
    use lib_src.signals_pack.all;

    -- OSVVM Packages
    library osvvm;
    use osvvm.RandomPkg.all;


    entity harness_srcname_tb is
    end harness_srcname_tb;

    architecture sim of harness_srcname_tb is
    begin

        -- gen_clk_freq_hz_int(clk, int_clk_hz);
        gen_clk_freq_hz_real(clk1, real_clk1_hz);

        -- inst_dutname : entity lib_src.srcname(rtl)
        -- port map (
        --     CLK => clk1,
        --     IN_DATA => dut1_tx1,
        --     OUT_CRC => dut1_rx1,
        --     OUT_MSG => dut1_rx2
        -- );



        -- Auxiliary valid pulses/triggers related to the dut2
        proc_aux_slv_aux_valid1 : process
        begin
            -- Shift the 'slv_aux_valid1', append 'to_aux_valid1'
            if rising_edge(clk1) then
                slv_aux_valid1(slv_aux_valid1'high downto 0) <= 
                    slv_aux_valid1(slv_aux_valid1'high-1 downto 0) & to_aux_valid1;
            end if;

            -- Synch with the latest updated output signal
            wait_deltas(5);

            -- The "aux_rx_dut1_valid_pulsed" will be used with:  "if aux_rx_dut1_valid_pulse = '1'/'0'" conditions
            aux_rx_dut1_valid_pulsed <= slv_aux_valid1(slv_aux_valid1'high);

            -- The "aux_rx_dut1_valid_monitor" will be used with:  "wait on aux_rx_dut1_valid'transaction" attributes
            if slv_aux_valid1(slv_aux_valid1'high) = '1' then
                aux_rx_dut1_valid_monitor <= force not(aux_rx_dut1_valid_monitor);
            end if;

            wait until rising_edge(clk1);
        end process;



        -- Auxiliary valid pulses/triggers related to the dut2
        proc_aux_slv_aux_valid2 : process
        begin
            -- Shift the 'slv_aux_valid2', append 'to_aux_valid2'
            if rising_edge(clk1) then
                slv_aux_valid2(slv_aux_valid2'high downto 0) <= 
                    slv_aux_valid2(slv_aux_valid2'high-1 downto 0) & to_aux_valid2;
            end if;

            -- Wait deltas until all outputs are valid
            wait_deltas(10);

            -- Send pulsed valid signal
            aux_rx_dut2_valid_pulsed <= slv_aux_valid2(slv_aux_valid2'high);

            -- Send oscillated valid signal for "wait on"
            if slv_aux_valid2(slv_aux_valid2'high) = '1' then
                aux_rx_dut2_valid_monitor <= force not(aux_rx_dut2_valid_monitor);
            end if;

            wait until rising_edge(clk1);
        end process;



        -- DUT1 Driver: Transmit data to DUT1 on redge of clk1
        proc_driver_dut1 : process
            variable v_dut1_tx1 : std_logic_vector(dut1_tx1'range) := (others => '0');
        begin
            if rising_edge(clk1) then
                if queue_sequence_dut1_tx1.length /= 0 then
                    -- dut1_tx1 <= string_bits_to_slv(queue_sent_dut1_tx1.get(0));
                    dut1_tx1 <= string_bits_to_slv(queue_sequence_dut1_tx1.get(0));
                    to_aux_valid1 <= '1';
                else
                    dut1_tx1 <= (others => '0');
                    to_aux_valid1 <= '0';
                end if;
            end if;

            -- Repeat
            wait until rising_edge(clk1);

            -- Remove the old item before sending the next item
            -- if queue_sent_dut1_tx1.length /= 0 then
            --     queue_sent_dut1_tx1.delete(0); -- THIS CAUSES PROBLEMS. CHECKERS EXPECT NONZERO VALUE
            -- end if;
        end process;


        -- DUT2 Driver: Interconnect DUT1 => DUT2
        dut2_tx1 <= (dut1_rx2 & dut1_rx1) xor dut2_tx1_aux1;
        to_aux_valid2 <= slv_aux_valid1(slv_aux_valid1'high);

        -- DUT2 Driver: Disconnect DUT1 and DUT2
        -- proc_driver_dut2 : process
        -- begin
        -- proc_driver_dut2 : process
        -- begin
        --     -- if rising_edge(clk1) then
        --         if queue_sent_dut2_tx1.length /= 0 then
        --             dut2_tx1 <= string_bits_to_slv(queue_sent_dut2_tx1.get(0));
        --             to_aux_valid2 <= '1';
        --             queue_sent_dut2_tx1.delete(0);
        --         else
        --             dut2_tx1 <= (others => '0');
        --             to_aux_valid2 <= '0';
        --         end if;
        --     -- end if;

        --     -- Repeat
        --     wait until rising_edge(clk1);
        -- end process;



        -- Auxiliary update global seed
        proc_aux_update_globseed : process
            variable v_rand_int : RandomPType;
        begin
                if rising_edge(clk1) then
                    glob_seed1 <= force abs(v_rand_int.RandInt(1, 2147483647));
                end if;

                wait until rising_edge(clk1);
        end process;

    end architecture;