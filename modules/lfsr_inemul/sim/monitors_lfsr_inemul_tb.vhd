    -- Monitor is responsible for capturing signal activity on the DUT's interface

    library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;
    use ieee.math_real.all;
    -- use ieee.math_complex.all;

    library std;
    use std.textio.all;
    use std.env.all;

    -- SRC Packages
    --     * Module-specific SRC Packages (not used)
    -- use lib_sim.const_lfsr_inemul_pack.all;
    -- use lib_sim.types_lfsr_inemul_pack.all;
    -- use lib_sim.signals_lfsr_inemul_pack.all;

    --     * Global project-specific SRC Packages
    library lib_src;
    use lib_src.const_pack.all;
    use lib_src.types_pack.all;
    use lib_src.signals_pack.all;

    -- TB Packages
    --     * Module-specific TB Packages
    library lib_sim;
    use lib_sim.const_lfsr_inemul_pack_tb.all;
    use lib_sim.types_lfsr_inemul_pack_tb.all;
    use lib_sim.signals_lfsr_inemul_pack_tb.all;

    --     * Global Project-specific TB Packages
    use lib_sim.const_pack_tb.all;
    use lib_sim.types_pack_tb.all;
    use lib_sim.signals_pack_tb.all;

    --     * Generic TB Packages
    use lib_sim.print_pack_tb.all;
    use lib_sim.clk_pack_tb.all;
    use lib_sim.list_string_pack_tb.all;
    use lib_sim.print_list_pack_tb.all;

    entity monitors_lfsr_inemul_tb is
    end monitors_lfsr_inemul_tb;

    architecture sim of monitors_lfsr_inemul_tb is
    begin


        -- DUT1
        --     * dut1_tx1
        proc_monitor_dut1_tx1 : process
            variable v_valid_deasserted : boolean := true;
        begin

            -- Trigger the monitor
            -- USER INPUT: UNCOMMENT IF: The module has a data input
            -- wait on dut1_tx1'transaction;
            -- if rising_edge(clk1) and dut1_ready = '1' then -- dut1 has a complementary dut1_tx1_valid1 => scan for dut1_ready redge

            --     -- Monitor only if something has been sent (from sequence queue)
            --     if queue_sequence_dut1_tx1.length /= 0 then
            --         log_sent_dut1_tx1.append(queue_sequence_dut1_tx1.get(0));
            --         queue_sent_dut1_tx1.append(queue_sequence_dut1_tx1.get(0));

            --         queue_sequence_dut1_tx1.delete(0);
            --     end if;
            -- end if;

            -- -- Seek if ready deasserted in the next clk, otherwise sample every clk
            -- wait until rising_edge(clk1);
            -- v_valid_deasserted := true;
            -- if dut1_ready = '1' then
            --     v_valid_deasserted := false;
            -- end if;

            -- -- Repeat if ready deasserted, wait until next redge
            -- if v_valid_deasserted = true then
            --     wait until rising_edge(dut1_ready);
            -- end if;


            -- USER INPUT: UNCOMMENT IF: The module has NO data input
            if rising_edge(clk1) then
                if queue_sequence_dut1_tx1.length /= 0 then
                    log_sent_dut1_tx1.append(queue_sequence_dut1_tx1.get(0));
                    queue_sent_dut1_tx1.append(queue_sequence_dut1_tx1.get(0));

                    queue_sequence_dut1_tx1.delete(0);
                end if;
            end if;
            wait until rising_edge(clk1);
        end process;


        --     * dut1_rx1
        proc_monitor_dut1_rx1 : process
            variable v_valid_deasserted : boolean := true;
        begin
            -- Trigger the monitor + Add to log & queue
            -- wait on dut1_rx1'transaction;
            -- wait on dut1_rx1_valid1'transaction;

            -- dut1_tx1 has a complementary dut1_rx1_valid1 => scan for dut1_rx1_valid1 redge
            if rising_edge(dut1_rx1_valid1) or dut1_rx1_valid1 = '1' then -- dut1_tx1 has a complementary dut1_rx1_valid1 => scan for dut1_rx1_valid1 redge
                -- wait_deltas(5);

                -- USER INPUT:
                -- UNCOMMENT TBE BELOW IF: Monitor only if something has been sent & monitor only desired number of data
                if queue_sent_dut1_tx1.length /= 0 and queue_received_dut1_rx1.length < queue_sent_dut1_tx1.length then
                    log_received_dut1_rx1.append(to_string(dut1_rx1));
                    queue_received_dut1_rx1.append(to_string(dut1_rx1));
                end if;

                -- UNCOMMENT TBE BELOW IF: Always monitor
                -- report"Appending";
                -- log_received_dut1_rx1.append(to_string(dut1_rx1));
                -- queue_received_dut1_rx1.append(to_string(dut1_rx1));
            end if;

            -- Seek if valid deasserted in the next clk, otherwise sample every clk
            wait until rising_edge(clk1);
            v_valid_deasserted := true;
            if dut1_rx1_valid1 = '1' then
                v_valid_deasserted := false;
            end if;

            -- Repeat if valid deasserted, wait until next redge
            if v_valid_deasserted = true then
                wait until rising_edge(dut1_rx1_valid1);
            end if;
        end process;

        --     * dut1_rx2 (not used)
        -- proc_monitor_dut1_rx2 : process
        -- begin
        --     -- Trigger the monitor + Add to log & queue
        --     wait on dut1_rx2'transaction; -- If dut1_rx2 is not latched => scan for any activity on this port
        --     wait_deltas(2);

        --     -- Monitor only if something has been sent & monitor only desired number of data
        --     if queue_sent_dut1_tx1.length /= 0 and queue_received_dut1_rx2.length < queue_sent_dut1_tx1.length then
        --         log_received_dut1_rx2.append(to_string(dut1_rx2));
        --         queue_received_dut1_rx2.append(to_string(dut1_rx2));
        --     end if;
        -- end process;

    end architecture;