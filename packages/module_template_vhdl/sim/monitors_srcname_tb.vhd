    -- Monitor is responsible for capturing signal activity from the design interface
    -- without asking

    library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;
    use ieee.math_real.all;
    -- use ieee.math_complex.all;

    library std;
    use std.textio.all;
    use std.env.all;

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

    entity monitors_srcname_tb is
    end monitors_srcname_tb;

    architecture sim of monitors_srcname_tb is
    begin


        -- Monitor the signal dut2_tx1_aux1 -> capture valid data dut2_tx1
        proc_dut2_tx1_aux1_monitor_1 : process
            variable transactions_done_cnt : natural;
        begin
            -- Trigger the monitor
            wait on dut2_tx1'transaction;                       -- Data arrived
            wait_deltas(10);                                    -- Let the new data get updated

            -- Log & Capture up to the same amount of data as TX data done
            transactions_done_cnt := log_sent_dut1_tx1.length;
            if log_sent_dut1_tx1.length /= 0 then
                -- Capture data in signals, load them to a queue + log

                    -- dut2_tx1
                if log_sent_dut2_tx1.length /= transactions_done_cnt then
                    log_sent_dut2_tx1.append(to_string(dut2_tx1));
                    queue_sent_dut2_tx1.append(to_string(dut2_tx1));
                end if;

            end if;
        end process;



        -- DUT1
        --     * dut1_tx1
        proc_monitor_dut1_tx1 : process
        begin

            -- Trigger the monitor
            wait on dut1_tx1'transaction;

            -- Monitor only if something has been already sent (from sequence queue)
            if queue_sequence_dut1_tx1.length /= 0 then
                log_sent_dut1_tx1.append(queue_sequence_dut1_tx1.get(0));
                queue_sent_dut1_tx1.append(queue_sequence_dut1_tx1.get(0));

                queue_sequence_dut1_tx1.delete(0);
            end if;
        end process;


        --     * dut1_rx1
        proc_monitor_dut1_rx1 : process
        begin
            -- Trigger the monitor + Add to log & queue
            wait on dut1_rx1'transaction;
            wait_deltas(2);

            -- Monitor only if something has been already sent & monitor only desired number of data
            if queue_sent_dut1_tx1.length /= 0 and queue_received_dut1_rx1.length < queue_sent_dut1_tx1.length then
                log_received_dut1_rx1.append(to_string(dut1_rx1));
                queue_received_dut1_rx1.append(to_string(dut1_rx1));
            end if;
        end process;

        --     * dut1_rx2
        proc_monitor_dut1_rx2 : process
        begin
            -- Trigger the monitor + Add to log & queue
            wait on dut1_rx2'transaction;
            wait_deltas(2);

            -- Monitor only if something has been already sent & monitor only desired number of data
            if queue_sent_dut1_tx1.length /= 0 and queue_received_dut1_rx2.length < queue_sent_dut1_tx1.length then
                log_received_dut1_rx2.append(to_string(dut1_rx2));
                queue_received_dut1_rx2.append(to_string(dut1_rx2));
            end if;
        end process;

    end architecture;