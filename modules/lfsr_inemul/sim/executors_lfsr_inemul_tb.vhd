    -- This file procedures (here executor processes) that come from iniside of the sequencer process from the main tb file
    -- All of the executor processes are 
    --      triggered from exec_cmd.id = command
    --      After the end of the processes, a short boolean true pulse is sent

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
    use lib_sim.const_lfsr_inemul_pack_tb.all;
    use lib_sim.types_lfsr_inemul_pack_tb.all;
    use lib_sim.signals_lfsr_inemul_pack_tb.all;
    use lib_sim.triggers_lfsr_inemul_pack_tb.all;

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
    library lib_src;
    --     * Module-specific SRC Packages (not used)
    -- use lib_src.const_lfsr_inemul_pack.all;
    -- use lib_src.types_lfsr_inemul_pack.all;
    -- use lib_src.signals_lfsr_inemul_pack.all;

    --     * Global project-specific SRC Packages
    use lib_src.const_pack.all;
    use lib_src.types_pack.all;
    use lib_src.signals_pack.all;

    -- OSVVM Packages
    library osvvm;
    use osvvm.RandomPkg.all;


    entity executors_lfsr_inemul_tb is
    end executors_lfsr_inemul_tb;

    architecture sim of executors_lfsr_inemul_tb is
    begin

        -- Procedures from iniside of the sequencer process from the main tb file

        -- GENERAL

        -- GENERAL: Executor of the command "DUT1_REMOVE_ALL_QUEUES"
        proc_exec_check_dut1_remove_all_queues : process
            variable v_items_cnt : natural := 0;
            variable v_sent_cnt : natural := 0;
            variable pass : boolean := true;
        begin
            -- 1. Trigger executor process
            wait until trigger_general.id = DUT1_REMOVE_ALL_QUEUES;

            -- 2. The process
            print_string("DUT1_REMOVE_ALL_QUEUES:                 ");

            -- Before cleaning the queues, assure that all TX sequece items have propagated
            if queue_sequence_dut1_tx1.length /= 0 then
                pass := false;
                Stop;
            end if;

            -- Before cleaning the queues, assure that items RX.length = TX.length
            if queue_received_dut1_rx1.length /= queue_sent_dut1_tx1.length  then
                print_string("queue_received_dut1_rx1.length: " & to_string(queue_received_dut1_rx1.length));
                print_string("queue_sent_dut1_tx1.length: " & to_string(queue_sent_dut1_tx1.length));

                -- USER INPUT: UNCOMMENT the following in case RX.length < TX.length is intended
                pass := false;
                Stop;
            end if;
                
            if pass = true then
                    -- dut1_tx1
                queue_sent_dut1_tx1.clear;
                queue_expected_dut1_tx1.clear;
                queue_forbidden_dut1_tx1.clear;
                queue_expected_values_dut1_tx1.clear;
                queue_forbidden_values_dut1_tx1.clear;

                    -- dut1_rx1
                queue_received_dut1_rx1.clear;
                queue_expected_dut1_rx1.clear;
                queue_forbidden_dut1_rx1.clear;
                queue_expected_values_dut1_rx1.clear;
                queue_forbidden_values_dut1_rx1.clear;

                    -- dut1_rx2
                queue_received_dut1_rx2.clear;
                queue_expected_dut1_rx2.clear;
                queue_forbidden_dut1_rx2.clear;
                queue_expected_values_dut1_rx2.clear;
                queue_forbidden_values_dut1_rx2.clear;

                print_string("DUT1_REMOVE_ALL_QUEUES:                 Cleaning all queues done.");
            else
                print_string("DUT1_REMOVE_ALL_QUEUES:                 ERROR: Sequence queue 'queue_sequence_dut1_tx1' is not empty yet! Stop.");
                print_string("DUT1_REMOVE_ALL_QUEUES:                     -> Check 'WAIT_UNTIL_SEQUENCE_PROPAGATED' for possible mistakes/errors.");
                print_string("DUT1_REMOVE_ALL_QUEUES:                     -> Check 'queue_sequence_dut1_tx1' for possible mistakes/errors.");
                Stop;
            end if;


            -- 3. Executor done flag
            trigger_general.done <= force true;
            wait for 0 ns;
            trigger_general.done <= release;
        end process;



        -- GENERAL: Executor of the command "PRINT_ALL_LOGS"
        proc_exec_print_all_logs : process
            variable v_items_cnt_log1 : natural;
            variable v_items_cnt_log2 : natural;
            variable v_items_cnt_log3 : natural;
            variable v_items_cnt_log4 : natural;
            variable v_items_cnt_log5 : natural;
            variable v_items_cnt_log6 : natural;
            variable v_items_cnt_log7 : natural;
            variable v_items_cnt_log8 : natural;
            variable v_items_cnt_log9 : natural;
            variable v_items_cnt_log10 : natural;
            variable v_items_cnt_log11 : natural;
            variable v_items_cnt_log12 : natural;
            variable v_items_cnt_log13 : natural;
            variable v_items_cnt_log14 : natural;
            variable v_items_cnt_log15 : natural;
        begin
            -- 1. Trigger executor process
            wait until trigger_general.id = PRINT_ALL_LOGS;

            -- 2. The process
            -- DUT1
            v_items_cnt_log1 := log_sent_dut1_tx1.length; -- queue_sent_dut1_tx1

            v_items_cnt_log2 := log_expected_dut1_rx1.length; -- queue_expected_dut1_rx1
            v_items_cnt_log3 := log_forbidden_dut1_rx1.length; -- queue_forbidden_dut1_rx1
            v_items_cnt_log4 := log_received_dut1_rx1.length; -- queue_received_dut1_rx1
            v_items_cnt_log2 := log_expected_values_dut1_rx1.length; -- queue_expected_values_dut1_rx1
            v_items_cnt_log3 := log_forbidden_values_dut1_rx1.length; -- queue_forbidden_values_dut1_rx1

            v_items_cnt_log5 := log_expected_dut1_rx2.length; -- queue_expected_dut1_rx2
            v_items_cnt_log6 := log_forbidden_dut1_rx2.length; -- queue_forbidden_dut1_rx2
            v_items_cnt_log7 := log_received_dut1_rx2.length; -- queue_received_dut1_rx2
            v_items_cnt_log5 := log_expected_values_dut1_rx2.length; -- queue_expected_values_dut1_rx2
            v_items_cnt_log6 := log_forbidden_values_dut1_rx2.length; -- queue_forbidden_values_dut1_rx2


            print_string("PRINT_ALL_LOGS:");
            if v_items_cnt_log1 /= 0 then
                for i in 0 to v_items_cnt_log1-1 loop
                    if i = 0 then
                        print_string("====================");
                    end if;
                    print_string("transaction no. " & integer'image(i));

                    -- DUT1
                    -- dut1_tx1
                    print_string(    "log_sent_dut1_tx1:                      " & log_sent_dut1_tx1.get(i));

                    -- dut1_rx1
                    if i < v_items_cnt_log2 then
                        print_string("log_expected_dut1_rx1:                  " & log_expected_dut1_rx1.get(i));
                    end if;
                    if i < v_items_cnt_log3 then
                        print_string("log_forbidden_dut1_rx1:                 " & log_forbidden_dut1_rx1.get(i));
                    end if;
                    if i < v_items_cnt_log4 then
                        print_string("log_received_dut1_rx1:                  " & log_received_dut1_rx1.get(i));
                    end if;

                    -- dut1_rx2
                    if i < v_items_cnt_log5 then
                        print_string("log_expected_dut1_rx2:                  " & log_expected_dut1_rx2.get(i));
                    end if;
                    if i < v_items_cnt_log6 then
                        print_string("log_forbidden_dut1_rx2:                 " & log_forbidden_dut1_rx2.get(i));
                    end if;
                    if i < v_items_cnt_log7 then
                        print_string("log_received_dut1_rx2:                  " & log_received_dut1_rx2.get(i));
                    end if;

                    print_string("====================");
                end loop;
            else
                print_string("PRINT_ALL_LOGS:                         Nothing to print. Logs are empty or TX log log_sent_dut1_tx1 is 0.");
            end if;

            -- 3. Executor done flag
            trigger_general.done <= force true;
            wait for 0 ns;
            trigger_general.done <= release;
        end process;



        -- GENERAL: Executor of the command "REMOVE_ALL_LOGS"
        proc_exec_remove_all_logs : process
            variable v_items_cnt : natural;
        begin
            -- 1. Trigger executor process
            wait until trigger_general.id = REMOVE_ALL_LOGS;

            -- 2. The process
            print_string("REMOVE_ALL_LOGS:");

            -- DUT1
                -- dut1_tx1
            log_sent_dut1_tx1.clear;
            log_expected_dut1_tx1.clear;
            log_forbidden_dut1_tx1.clear;
            log_expected_values_dut1_tx1.clear;
            log_forbidden_values_dut1_tx1.clear;

                -- dut1_rx1
            log_received_dut1_rx1.clear;
            log_expected_dut1_rx1.clear;
            log_forbidden_dut1_rx1.clear;
            log_expected_values_dut1_rx1.clear;
            log_forbidden_values_dut1_rx1.clear;

                -- dut1_rx2
            log_received_dut1_rx2.clear;
            log_expected_dut1_rx2.clear;
            log_forbidden_dut1_rx2.clear;
            log_expected_values_dut1_rx2.clear;
            log_forbidden_values_dut1_rx2.clear;

            print_string("REMOVE_ALL_LOGS:                        Removing logs done.");

            -- 3. Executor done flag
            trigger_general.done <= force true;
            wait for 0 ns;
            trigger_general.done <= release;
        end process;



        -- DUT1
        -- TX: Executor of the command "DUT1_RESET_RELEASE"
            proc_exec_tx_dut1_reset_release : process
            begin
                -- 1. Trigger executor process
                wait until trigger_dut1_tx1.id = DUT1_RESET_RELEASE;

                -- 2. The process
                wait for real_clk1_period * 10;
                print_string("DUT1_RESET_RELEASE:                     Releasing signal rst1");
                rst1 <= '0';
                wait for real_clk1_period * 10;

                -- 3. Executor done flag
                trigger_dut1_tx1.done <= force true;
                wait for 0 ns;
                trigger_dut1_tx1.done <= release;
        end process;



        -- TX: Executor of the command "TX_DUT1_ZEROES"
        proc_exec_tx_dut1_zeroes : process
            variable v_dut1_tx1 : std_logic_vector(dut1_tx1'range);
        begin
            -- 1. Trigger executor process
            wait until trigger_dut1_tx1.id = TX_DUT1_ZEROES;

            -- 2. The process
            v_dut1_tx1 := (others => '0');
            print_string("TX_DUT1_ZEROES:                         " & to_string(v_dut1_tx1));

            -- Original
            -- queue_sent_dut1_tx1.append(to_string(v_dut1_tx1));
            -- log_sent_dut1_tx1.append(to_string(v_dut1_tx1));

            -- Enables the data flow
            queue_sequence_dut1_tx1.append(to_string(v_dut1_tx1));
            log_sequence_dut1_tx1.append(to_string(v_dut1_tx1));

            -- 3. Executor done flag
            trigger_dut1_tx1.done <= force true;
            wait for 0 ns;
            trigger_dut1_tx1.done <= release;
        end process;


        -- TX: Executor of the command "TX_DUT1_ONES"
        proc_exec_tx_dut1_ones : process
            variable v_dut1_tx1 : std_logic_vector(dut1_tx1'range);
        begin
            -- 1. Trigger executor process
            wait until trigger_dut1_tx1.id = TX_DUT1_ONES;

            -- 2. The process
            v_dut1_tx1 := (others => '1');
            print_string("TX_DUT1_ONES:                           " & to_string(v_dut1_tx1));

            -- Original
            -- queue_sent_dut1_tx1.append(to_string(v_dut1_tx1));
            -- log_sent_dut1_tx1.append(to_string(v_dut1_tx1));

            -- Enables the data flow
            queue_sequence_dut1_tx1.append(to_string(v_dut1_tx1));
            log_sequence_dut1_tx1.append(to_string(v_dut1_tx1));

            -- 3. Executor done flag
            trigger_dut1_tx1.done <= force true;
            wait for 0 ns;
            trigger_dut1_tx1.done <= release;
        end process;


        -- TX: Executor of the command "TX_DUT1_RANDOM_VALUE"
        proc_exec_tx_dut1_random_value : process
            variable v_dut1_tx1 : std_logic_vector(dut1_tx1'range);
            variable random_slv : RandomPType;
        begin
            -- 1. Trigger executor process
            wait until trigger_dut1_tx1.id = TX_DUT1_RANDOM_VALUE;

            -- 2. The process
            v_dut1_tx1 := random_slv.RandSlv(dut1_tx1'length);
            print_string("TX_DUT1_RANDOM_VALUE:                   " & to_string(v_dut1_tx1));

            -- Original
            -- queue_sent_dut1_tx1.append(to_string(v_dut1_tx1));
            -- log_sent_dut1_tx1.append(to_string(v_dut1_tx1));

            -- Enables the data flow
            queue_sequence_dut1_tx1.append(to_string(v_dut1_tx1));
            log_sequence_dut1_tx1.append(to_string(v_dut1_tx1));



            -- if queue_sequence_dut1_tx1.length /= 0 then
            --     print_string("ERROR");
            --     for i in 0 to queue_sequence_dut1_tx1.length-1 loop
            --         print_string("    queue_sequence_dut1_tx1 = " & queue_sequence_dut1_tx1.get(i));
            --     end loop;
            -- end if;

            -- 3. Executor done flag
            trigger_dut1_tx1.done <= force true;
            wait for 0 ns;
            trigger_dut1_tx1.done <= release;
        end process;


        -- TX: Executor of the command "TX_DUT1_SPECIFIC_VALUE"
        proc_exec_tx_dut1_specific_value : process
        begin
            -- 1. Trigger executor process
            wait until trigger_dut1_tx1.id = TX_DUT1_SPECIFIC_VALUE;

            -- 2. The process
            print_string("TX_DUT1_SPECIFIC_VALUE:                 " & to_string(trigger_dut1_tx1.data));

            -- Original
            -- queue_sent_dut1_tx1.append(to_string(trigger_dut1_tx1.data));
            -- log_sent_dut1_tx1.append(to_string(trigger_dut1_tx1.data));

            -- Enables the data flow
            queue_sequence_dut1_tx1.append(to_string(trigger_dut1_tx1.data));
            log_sequence_dut1_tx1.append(to_string(trigger_dut1_tx1.data));

            -- 3. Executor done flag
            trigger_dut1_tx1.done <= force true;
            wait for 0 ns;
            trigger_dut1_tx1.done <= release;
        end process;


        -- TX: Executor of the command "TX_DUT1_WAIT_UNTIL_SEQUENCE_TRANSMITTED"
        proc_exec_tx_dut1_wait_until_sequence_transmitted : process
            variable v_sent_cnt : natural := 0;
        begin
            -- 1. Trigger executor process
            wait until trigger_dut1_tx1.id = TX_DUT1_WAIT_UNTIL_SEQUENCE_TRANSMITTED;

            -- 2. The process
            print_string("TX_DUT1_WAIT_UNTIL_SEQUENCE_TRANSMITTED:");

            -- Propagate TX transactions from TX sequence
            while queue_sequence_dut1_tx1.length /= 0 loop
                wait_deltas(2);
                print_string("TX_DUT1_WAIT_UNTIL_SEQUENCE_TRANSMITTED TX to go:  queue_sequence_dut1_tx1.length: " & integer'image(queue_sequence_dut1_tx1.length));
                wait_cycles(1, clk1);
            end loop;
            wait_deltas(20);


            -- 3. Executor done flag
            trigger_dut1_tx1.done <= force true;
            wait for 0 ns;
            trigger_dut1_tx1.done <= release;
        end process;


        -- RX
        -- RX: Executor of the command "RX_DUT1_WAIT_UNTIL_EVERYTHING_RECEIVED"
        proc_exec_rx_dut1_wait_until_everything_received : process
            variable v_items_cnt : natural := 0;
            variable v_sent_cnt : natural := 0;
        begin
            -- 1. Trigger executor process
            wait until trigger_dut1_rx1.id = RX_DUT1_WAIT_UNTIL_EVERYTHING_RECEIVED;

            -- 2. The process
            print_string("RX_DUT1_WAIT_UNTIL_EVERYTHING_RECEIVED: ");

            -- Make sure all RX signals have propagated successfully
            print_string("RX_DUT1_WAIT_UNTIL_EVERYTHING_RECEIVED: TX done: queue_sent_dut1_tx1.length: " & integer'image(queue_sent_dut1_tx1.length));
            while queue_received_dut1_rx1.length < queue_sent_dut1_tx1.length loop
                wait_deltas(20);
                print_string("RX_DUT1_WAIT_UNTIL_EVERYTHING_RECEIVED: RX done: queue_received_dut1_rx1.length: " & integer'image(queue_received_dut1_rx1.length));
                wait_cycles(1, clk1);
            end loop;
            wait_deltas(20);


            -- 3. Executor done flag
            trigger_dut1_rx1.done <= force true;
            wait for 0 ns;
            trigger_dut1_rx1.done <= release;
        end process;


        -- CHECKER
        -- TX1
        -- CHECKER TX1: Cmd executor of the command "CHECK_DUT1_TX1_IS_SPECIFIC_VALUE"
        proc_exec_check_dut1_tx1_is_specific_value : process
        begin
            -- 1. Trigger executor process
            wait until trigger_dut1_tx1_check.id = CHECK_DUT1_TX1_IS_SPECIFIC_VALUE;

            -- 2. The process
            print_string("CHECK_DUT1_TX1_IS_SPECIFIC_VALUE:       " & to_string(trigger_dut1_tx1_check.data));
            queue_expected_dut1_tx1.append(to_string(trigger_dut1_tx1_check.data));
            log_expected_dut1_tx1.append(to_string(trigger_dut1_tx1_check.data));

            -- while queue_expected_dut1_tx1.length /= 0 loop
            --     wait_deltas(1);
            -- end loop;

            -- 3. Executor done flag
            trigger_dut1_tx1_check.done <= force true;
            wait for 0 ns;
            trigger_dut1_tx1_check.done <= release;
        end process;

        -- CHECKER TX1: Cmd executor of the command "CHECK_DUT1_TX1_IS_SPECIFIC_VALUES"
        proc_exec_check_dut1_tx1_is_specific_values : process
        begin
            -- 1. Trigger executor process
            wait until trigger_dut1_tx1_check.id = CHECK_DUT1_TX1_IS_SPECIFIC_VALUES;

            -- 2. The process
            print_string("CHECK_DUT1_TX1_IS_SPECIFIC_VALUES:      " & to_string(trigger_dut1_tx1_check.data));
            queue_expected_values_dut1_tx1.append(to_string(trigger_dut1_tx1_check.data));
            log_expected_values_dut1_tx1.append(to_string(trigger_dut1_tx1_check.data));

            -- while queue_expected_dut1_tx1.length /= 0 loop
            --     wait_deltas(1);
            -- end loop;

            -- 3. Executor done flag
            trigger_dut1_tx1_check.done <= force true;
            wait for 0 ns;
            trigger_dut1_tx1_check.done <= release;
        end process;

        -- CHECKER TX1: Cmd executor of the command "CHECK_DUT1_TX1_IS_ZERO"
        proc_exec_check_dut1_tx1_is_zero : process
            variable v_data : std_logic_vector(dut1_tx1'range) := (others => '0');
        begin
            -- 1. Trigger executor process
            wait until trigger_dut1_tx1_check.id = CHECK_DUT1_TX1_IS_ZERO;

            -- 2. The process
            print_string("CHECK_DUT1_TX1_IS_ZERO:                 " & to_string(v_data));
            queue_expected_dut1_tx1.append(to_string(v_data));
            log_expected_dut1_tx1.append(to_string(v_data));

            -- 3. Executor done flag
            trigger_dut1_tx1_check.done <= force true;
            wait for 0 ns;
            trigger_dut1_tx1_check.done <= release;
        end process;

        -- CHECKER TX1: Executor of the command "CHECK_DUT1_TX1_IS_ONE"
        proc_exec_check_dut1_tx1_is_one : process
            variable v_data : std_logic_vector(dut1_tx1'range) := (others => '1');
        begin
            -- 1. Trigger executor process
            wait until trigger_dut1_tx1_check.id = CHECK_DUT1_TX1_IS_ONE;

            -- 2. The process
            print_string("CHECK_DUT1_TX1_IS_ONE:                  " & to_string(v_data));
            queue_expected_dut1_tx1.append(to_string(v_data));
            log_expected_dut1_tx1.append(to_string(v_data));

            -- 3. Executor done flag
            trigger_dut1_tx1_check.done <= force true;
            wait for 0 ns;
            trigger_dut1_tx1_check.done <= release;
        end process;


        -- CHECKER TX1: Executor of the command "CHECK_DUT1_TX1_ISNOT_SPECIFIC_VALUE"
        proc_exec_check_dut1_tx1_isnot_specific_value : process
        begin
            -- 1. Trigger executor process
            wait until trigger_dut1_tx1_check.id = CHECK_DUT1_TX1_ISNOT_SPECIFIC_VALUE;

            -- 2. The process
            print_string("CHECK_DUT1_TX1_ISNOT_SPECIFIC_VALUE:    " & to_string(trigger_dut1_tx1_check.data));
            queue_forbidden_dut1_tx1.append(to_string(trigger_dut1_tx1_check.data));
            log_forbidden_dut1_tx1.append(to_string(trigger_dut1_tx1_check.data));

            -- while queue_expected_dut1_tx1.length /= 0 loop
            --     wait_deltas(1);
            -- end loop;

            -- 3. Executor done flag
            trigger_dut1_tx1_check.done <= force true;
            wait for 0 ns;
            trigger_dut1_tx1_check.done <= release;
        end process;

        -- CHECKER TX1: Executor of the command "CHECK_DUT1_TX1_ISNOT_SPECIFIC_VALUES"
        proc_exec_check_dut1_tx1_isnot_specific_values : process
        begin
            -- 1. Trigger executor process
            wait until trigger_dut1_tx1_check.id = CHECK_DUT1_TX1_ISNOT_SPECIFIC_VALUES;

            -- 2. The process
            print_string("CHECK_DUT1_TX1_ISNOT_SPECIFIC_VALUES:    " & to_string(trigger_dut1_tx1_check.data));
            queue_forbidden_values_dut1_tx1.append(to_string(trigger_dut1_tx1_check.data));
            log_forbidden_values_dut1_tx1.append(to_string(trigger_dut1_tx1_check.data));

            -- while queue_expected_dut1_tx1.length /= 0 loop
            --     wait_deltas(1);
            -- end loop;

            -- 3. Executor done flag
            trigger_dut1_tx1_check.done <= force true;
            wait for 0 ns;
            trigger_dut1_tx1_check.done <= release;
        end process;

        -- CHECKER TX1: Executor of the command "CHECK_DUT1_TX1_ISNOT_ZERO"
        proc_exec_check_dut1_tx1_isnot_zero : process
            variable v_data : std_logic_vector(dut1_tx1'range) := (others => '0');
        begin
            -- 1. Trigger executor process
            wait until trigger_dut1_tx1_check.id = CHECK_DUT1_TX1_ISNOT_ZERO;

            -- 2. The process
            print_string("CHECK_DUT1_TX1_ISNOT_ZERO:              " & to_string(v_data));
            queue_forbidden_dut1_tx1.append(to_string(v_data));
            log_forbidden_dut1_tx1.append(to_string(v_data));

            -- 3. Executor done flag
            trigger_dut1_tx1_check.done <= force true;
            wait for 0 ns;
            trigger_dut1_tx1_check.done <= release;
        end process;

        -- CHECKER TX1: Executor of the command "CHECK_DUT1_TX1_ISNOT_ONE"
        proc_exec_check_dut1_tx1_isnot_one : process
            variable v_data : std_logic_vector(dut1_tx1'range) := (others => '1');
        begin
            -- 1. Trigger executor process
            wait until trigger_dut1_tx1_check.id = CHECK_DUT1_TX1_ISNOT_ONE;

            -- 2. The process
            print_string("CHECK_DUT1_TX1_ISNOT_ONE:               " & to_string(v_data));
            queue_forbidden_dut1_tx1.append(to_string(v_data));
            log_forbidden_dut1_tx1.append(to_string(v_data));

            -- 3. Executor done flag
            trigger_dut1_tx1_check.done <= force true;
            wait for 0 ns;
            trigger_dut1_tx1_check.done <= release;
        end process;


        
        -- RX1
        -- CHECKER RX1: Cmd executor of the command "CHECK_DUT1_RX1_IS_SPECIFIC_VALUE"
        proc_exec_check_dut1_rx1_is_specific_value : process
        begin
            -- 1. Trigger executor process
            wait until trigger_dut1_rx1_check.id = CHECK_DUT1_RX1_IS_SPECIFIC_VALUE;

            -- 2. The process
            print_string("CHECK_DUT1_RX1_IS_SPECIFIC_VALUE:       " & to_string(trigger_dut1_rx1_check.data));
            queue_expected_dut1_rx1.append(to_string(trigger_dut1_rx1_check.data));
            log_expected_dut1_rx1.append(to_string(trigger_dut1_rx1_check.data));

            -- while queue_expected_dut1_rx1.length /= 0 loop
            --     wait_deltas(1);
            -- end loop;
            -- while queue_expected_dut1_rx1.length /= 0 loop
            --     wait_deltas(1);
            -- end loop;

            -- 3. Executor done flag
            trigger_dut1_rx1_check.done <= force true;
            wait for 0 ns;
            trigger_dut1_rx1_check.done <= release;
        end process;

        -- CHECKER RX1: Cmd executor of the command "CHECK_DUT1_RX1_IS_SPECIFIC_VALUES"
        proc_exec_check_dut1_rx1_is_specific_values : process
        begin
            -- 1. Trigger executor process
            wait until trigger_dut1_rx1_check.id = CHECK_DUT1_RX1_IS_SPECIFIC_VALUES;

            -- 2. The process
            print_string("CHECK_DUT1_RX1_IS_SPECIFIC_VALUES:      " & to_string(trigger_dut1_rx1_check.data));
            queue_expected_values_dut1_rx1.append(to_string(trigger_dut1_rx1_check.data));
            log_expected_values_dut1_rx1.append(to_string(trigger_dut1_rx1_check.data));

            -- while queue_expected_dut1_rx1.length /= 0 loop
            --     wait_deltas(1);
            -- end loop;
            -- while queue_expected_dut1_rx1.length /= 0 loop
            --     wait_deltas(1);
            -- end loop;

            -- 3. Executor done flag
            trigger_dut1_rx1_check.done <= force true;
            wait for 0 ns;
            trigger_dut1_rx1_check.done <= release;
        end process;

        -- CHECKER RX1: Cmd executor of the command "CHECK_DUT1_RX1_IS_ZERO"
        proc_exec_check_dut1_rx1_is_zero : process
            variable v_data : std_logic_vector(dut1_rx1'range) := (others => '0');
        begin
            -- 1. Trigger executor process
            wait until trigger_dut1_rx1_check.id = CHECK_DUT1_RX1_IS_ZERO;

            -- 2. The process
            print_string("CHECK_DUT1_RX1_IS_ZERO:                 " & to_string(v_data));
            queue_expected_dut1_rx1.append(to_string(v_data));
            log_expected_dut1_rx1.append(to_string(v_data));

            queue_expected_dut1_rx1.append(to_string(v_data));
            log_expected_dut1_rx1.append(to_string(v_data));

            -- 3. Executor done flag
            trigger_dut1_rx1_check.done <= force true;
            wait for 0 ns;
            trigger_dut1_rx1_check.done <= release;
        end process;

        -- CHECKER RX1: Executor of the command "CHECK_DUT1_RX1_IS_ONE"
        proc_exec_check_dut1_rx1_is_one : process
            variable v_data : std_logic_vector(dut1_rx1'range) := (others => '1');
        begin
            -- 1. Trigger executor process
            wait until trigger_dut1_rx1_check.id = CHECK_DUT1_RX1_IS_ONE;

            -- 2. The process
            print_string("CHECK_DUT1_RX1_IS_ONE:                  " & to_string(v_data));
            queue_expected_dut1_rx1.append(to_string(v_data));
            log_expected_dut1_rx1.append(to_string(v_data));

            queue_expected_dut1_rx1.append(to_string(v_data));
            log_expected_dut1_rx1.append(to_string(v_data));

            -- 3. Executor done flag
            trigger_dut1_rx1_check.done <= force true;
            wait for 0 ns;
            trigger_dut1_rx1_check.done <= release;
        end process;


        -- CHECKER RX1: Executor of the command "CHECK_DUT1_RX1_ISNOT_SPECIFIC_VALUE"
        proc_exec_check_dut1_rx1_isnot_specific_value : process
        begin
            -- 1. Trigger executor process
            wait until trigger_dut1_rx1_check.id = CHECK_DUT1_RX1_ISNOT_SPECIFIC_VALUE;

            -- 2. The process
            print_string("CHECK_DUT1_RX1_ISNOT_SPECIFIC_VALUE:    " & to_string(trigger_dut1_rx1_check.data));
            queue_forbidden_dut1_rx1.append(to_string(trigger_dut1_rx1_check.data));
            log_forbidden_dut1_rx1.append(to_string(trigger_dut1_rx1_check.data));

            -- while queue_expected_dut1_rx1.length /= 0 loop
            --     wait_deltas(1);
            -- end loop;
            -- while queue_expected_dut1_rx1.length /= 0 loop
            --     wait_deltas(1);
            -- end loop;

            -- 3. Executor done flag
            trigger_dut1_rx1_check.done <= force true;
            wait for 0 ns;
            trigger_dut1_rx1_check.done <= release;
        end process;

        -- CHECKER RX1: Executor of the command "CHECK_DUT1_RX1_ISNOT_SPECIFIC_VALUES"
        proc_exec_check_dut1_rx1_isnot_specific_values : process
        begin
            -- 1. Trigger executor process
            wait until trigger_dut1_rx1_check.id = CHECK_DUT1_RX1_ISNOT_SPECIFIC_VALUES;

            -- 2. The process
            print_string("CHECK_DUT1_RX1_ISNOT_SPECIFIC_VALUES:   " & to_string(trigger_dut1_rx1_check.data));
            queue_forbidden_values_dut1_rx1.append(to_string(trigger_dut1_rx1_check.data));
            log_forbidden_values_dut1_rx1.append(to_string(trigger_dut1_rx1_check.data));

            -- while queue_expected_dut1_rx1.length /= 0 loop
            --     wait_deltas(1);
            -- end loop;
            -- while queue_expected_dut1_rx1.length /= 0 loop
            --     wait_deltas(1);
            -- end loop;

            -- 3. Executor done flag
            trigger_dut1_rx1_check.done <= force true;
            wait for 0 ns;
            trigger_dut1_rx1_check.done <= release;
        end process;

        -- CHECKER RX1: Executor of the command "CHECK_DUT1_RX1_ISNOT_ZERO"
        proc_exec_check_dut1_rx1_isnot_zero : process
            variable v_data : std_logic_vector(dut1_rx1'range) := (others => '0');
        begin
            -- 1. Trigger executor process
            wait until trigger_dut1_rx1_check.id = CHECK_DUT1_RX1_ISNOT_ZERO;

            -- 2. The process
            print_string("CHECK_DUT1_RX1_ISNOT_ZERO:              " & to_string(v_data));
            queue_forbidden_dut1_rx1.append(to_string(v_data));
            log_forbidden_dut1_rx1.append(to_string(v_data));

            -- 3. Executor done flag
            trigger_dut1_rx1_check.done <= force true;
            wait for 0 ns;
            trigger_dut1_rx1_check.done <= release;
        end process;

        -- CHECKER RX1: Executor of the command "CHECK_DUT1_RX1_ISNOT_ONE"
        proc_exec_check_dut1_rx1_isnot_one : process
            variable v_data : std_logic_vector(dut1_rx1'range) := (others => '1');
        begin
            -- 1. Trigger executor process
            wait until trigger_dut1_rx1_check.id = CHECK_DUT1_RX1_ISNOT_ONE;

            -- 2. The process
            print_string("CHECK_DUT1_RX1_ISNOT_ONE:               " & to_string(v_data));
            queue_forbidden_dut1_rx1.append(to_string(v_data));
            log_forbidden_dut1_rx1.append(to_string(v_data));

            -- 3. Executor done flag
            trigger_dut1_rx1_check.done <= force true;
            wait for 0 ns;
            trigger_dut1_rx1_check.done <= release;
        end process;


        


        -- RX2
        -- CHECKER RX2: Cmd executor of the command "CHECK_DUT1_RX2_IS_SPECIFIC_VALUE"
        proc_exec_check_dut1_rx2_is_specific_value : process
        begin
            -- 1. Trigger executor process
            wait until trigger_dut1_rx2_check.id = CHECK_DUT1_RX2_IS_SPECIFIC_VALUE;

            -- 2. The process
            print_string("CHECK_DUT1_RX2_IS_SPECIFIC_VALUE:       " & to_string(trigger_dut1_rx2_check.data));
            queue_expected_dut1_rx2.append(to_string(trigger_dut1_rx2_check.data));
            log_expected_dut1_rx2.append(to_string(trigger_dut1_rx2_check.data));

            -- while queue_expected_dut1_rx2.length /= 0 loop
            --     wait_deltas(1);
            -- end loop;

            -- 3. Executor done flag
            trigger_dut1_rx2_check.done <= force true;
            wait for 0 ns;
            trigger_dut1_rx2_check.done <= release;
        end process;

        -- CHECKER RX2: Cmd executor of the command "CHECK_DUT1_RX2_IS_SPECIFIC_VALUES"
        proc_exec_check_dut1_rx2_is_specific_values : process
        begin
            -- 1. Trigger executor process
            wait until trigger_dut1_rx2_check.id = CHECK_DUT1_RX2_IS_SPECIFIC_VALUES;

            -- 2. The process
            print_string("CHECK_DUT1_RX2_IS_SPECIFIC_VALUES:      " & to_string(trigger_dut1_rx2_check.data));
            queue_expected_values_dut1_rx2.append(to_string(trigger_dut1_rx2_check.data));
            log_expected_values_dut1_rx2.append(to_string(trigger_dut1_rx2_check.data));

            -- while queue_expected_dut1_rx2.length /= 0 loop
            --     wait_deltas(1);
            -- end loop;

            -- 3. Executor done flag
            trigger_dut1_rx2_check.done <= force true;
            wait for 0 ns;
            trigger_dut1_rx2_check.done <= release;
        end process;

        -- CHECKER RX2: Cmd executor of the command "CHECK_DUT1_RX2_IS_ZERO"
        proc_exec_check_dut1_rx2_is_zero : process
            variable v_data : std_logic_vector(dut1_rx2'range) := (others => '0');
        begin
            -- 1. Trigger executor process
            wait until trigger_dut1_rx2_check.id = CHECK_DUT1_RX2_IS_ZERO;

            -- 2. The process
            print_string("CHECK_DUT1_RX2_IS_ZERO:                 " & to_string(v_data));
            queue_expected_dut1_rx2.append(to_string(v_data));
            log_expected_dut1_rx2.append(to_string(v_data));

            -- 3. Executor done flag
            trigger_dut1_rx2_check.done <= force true;
            wait for 0 ns;
            trigger_dut1_rx2_check.done <= release;
        end process;

        -- CHECKER RX2: Executor of the command "CHECK_DUT1_RX2_IS_ONE"
        proc_exec_check_dut1_rx2_is_one : process
            variable v_data : std_logic_vector(dut1_rx2'range) := (others => '1');
        begin
            -- 1. Trigger executor process
            wait until trigger_dut1_rx2_check.id = CHECK_DUT1_RX2_IS_ONE;

            -- 2. The process
            print_string("CHECK_DUT1_RX2_IS_ONE:                  " & to_string(v_data));
            queue_expected_dut1_rx2.append(to_string(v_data));
            log_expected_dut1_rx2.append(to_string(v_data));

            -- 3. Executor done flag
            trigger_dut1_rx2_check.done <= force true;
            wait for 0 ns;
            trigger_dut1_rx2_check.done <= release;
        end process;


        -- CHECKER RX2: Executor of the command "CHECK_DUT1_RX2_ISNOT_SPECIFIC_VALUE"
        proc_exec_check_dut1_rx2_isnot_specific_value : process
        begin
            -- 1. Trigger executor process
            wait until trigger_dut1_rx2_check.id = CHECK_DUT1_RX2_ISNOT_SPECIFIC_VALUE;

            -- 2. The process
            print_string("CHECK_DUT1_RX2_ISNOT_SPECIFIC_VALUE:    " & to_string(trigger_dut1_rx2_check.data));
            queue_forbidden_dut1_rx2.append(to_string(trigger_dut1_rx2_check.data));
            log_forbidden_dut1_rx2.append(to_string(trigger_dut1_rx2_check.data));

            -- while queue_expected_dut1_rx2.length /= 0 loop
            --     wait_deltas(1);
            -- end loop;

            -- 3. Executor done flag
            trigger_dut1_rx2_check.done <= force true;
            wait for 0 ns;
            trigger_dut1_rx2_check.done <= release;
        end process;

        -- CHECKER RX2: Executor of the command "CHECK_DUT1_RX2_ISNOT_SPECIFIC_VALUES"
        proc_exec_check_dut1_rx2_isnot_specific_values : process
        begin
            -- 1. Trigger executor process
            wait until trigger_dut1_rx2_check.id = CHECK_DUT1_RX2_ISNOT_SPECIFIC_VALUES;

            -- 2. The process
            print_string("CHECK_DUT1_RX2_ISNOT_SPECIFIC_VALUES:   " & to_string(trigger_dut1_rx2_check.data));
            queue_forbidden_values_dut1_rx2.append(to_string(trigger_dut1_rx2_check.data));
            log_forbidden_values_dut1_rx2.append(to_string(trigger_dut1_rx2_check.data));

            -- while queue_expected_dut1_rx2.length /= 0 loop
            --     wait_deltas(1);
            -- end loop;

            -- 3. Executor done flag
            trigger_dut1_rx2_check.done <= force true;
            wait for 0 ns;
            trigger_dut1_rx2_check.done <= release;
        end process;

        -- CHECKER RX2: Executor of the command "CHECK_DUT1_RX2_ISNOT_ZERO"
        proc_exec_check_dut1_rx2_isnot_zero : process
            variable v_data : std_logic_vector(dut1_rx2'range) := (others => '0');
        begin
            -- 1. Trigger executor process
            wait until trigger_dut1_rx2_check.id = CHECK_DUT1_RX2_ISNOT_ZERO;

            -- 2. The process
            print_string("CHECK_DUT1_RX2_ISNOT_ZERO:              " & to_string(v_data));
            queue_forbidden_dut1_rx2.append(to_string(v_data));
            log_forbidden_dut1_rx2.append(to_string(v_data));

            -- 3. Executor done flag
            trigger_dut1_rx2_check.done <= force true;
            wait for 0 ns;
            trigger_dut1_rx2_check.done <= release;
        end process;

        -- CHECKER RX2: Executor of the command "CHECK_DUT1_RX2_ISNOT_ONE"
        proc_exec_check_dut1_rx2_isnot_one : process
            variable v_data : std_logic_vector(dut1_rx2'range) := (others => '1');
        begin
            -- 1. Trigger executor process
            wait until trigger_dut1_rx2_check.id = CHECK_DUT1_RX2_ISNOT_ONE;

            -- 2. The process
            print_string("CHECK_DUT1_RX2_ISNOT_ONE:               " & to_string(v_data));
            queue_forbidden_dut1_rx2.append(to_string(v_data));
            log_forbidden_dut1_rx2.append(to_string(v_data));

            -- 3. Executor done flag
            trigger_dut1_rx2_check.done <= force true;
            wait for 0 ns;
            trigger_dut1_rx2_check.done <= release;
        end process;
    
    
    end architecture;