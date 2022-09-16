    -- checkers_crc_tb.vhd: Testbench Scoreboard subcomponent for module checkers_crc_tb.vhd
    -- Engineer: Patrik Zahalka 
    -- Email: patrik.zahalka@univie.ac.at

    library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;
    use ieee.math_real.all;
    -- use ieee.math_complex.all;

    library std;
    use std.textio.all;
    use std.env.all;

    -- SRC Packages
    library lib_src;
    --     * Module-specific SRC Packages (if used, uncomment)
    -- use lib_src.const_srcname_pack.all;
    -- use lib_src.types_srcname_pack.all;
    -- use lib_src.signals_srcname_pack.all;

    --     * Global project-specific SRC Packages
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

    entity checkers_srcname_tb is
    end checkers_srcname_tb;

    architecture sim of checkers_srcname_tb is
    begin


        -- DUT1
        --     * dut1_tx1
        proc_check_dut1_tx1_is : process
            variable v_expected_data : std_logic_vector(dut1_tx1'range);

            variable v_expected_items_cnt : natural := 0;
            variable v_transactions_sent_cnt : natural := 0;
            variable v_received_cnt : natural := 0;
        begin
            wait on dut1_tx1'transaction;

            -- wait long enough until 'log_sent_dut1_tx1' gets updated
            wait_deltas(20);
            v_transactions_sent_cnt := log_sent_dut1_tx1.length;

            v_expected_items_cnt := queue_expected_dut1_tx1.length;

            -- Run only if checking is requested and if at least one transaction has been sent
            if v_expected_items_cnt /= 0 and v_transactions_sent_cnt /= 0 then

                -- Check the next item in the queue
                -- v_expected_data := string_bits_to_slv(queue_expected_dut1_tx1.get(0));
                v_expected_data := string_bits_to_slv(queue_expected_dut1_tx1.get(v_transactions_sent_cnt-1));

                -- The actual assertion logic
                assert dut1_tx1 = v_expected_data
                    report "check_dut1_tx1_is: 'dut1_tx1' (" & to_string(dut1_tx1) & 
                    ") not matching 'v_expected_data': " & to_string(v_expected_data) & 
                    "Transaction: " & integer'image(v_transactions_sent_cnt-1)
                    severity failure;
            end if;

            -- Delete the item
            -- queue_expected_dut1_tx1.delete(0);
        end process;


        proc_check_dut1_tx1_is_values : process
            variable v_expected_data : std_logic_vector(dut1_tx1'range);

            variable v_expected_items_cnt : natural := 0;
            variable v_transactions_sent_cnt : natural := 0;
            variable v_received_cnt : natural := 0;
        begin
            wait on dut1_tx1'transaction;

            -- wait long enough until 'log_sent_dut1_tx1' gets updated
            wait_deltas(20);
            v_transactions_sent_cnt := log_sent_dut1_tx1.length;

            v_expected_items_cnt := queue_expected_values_dut1_tx1.length;

            -- Run only if checking is requested and if at least one transaction has been sent
            if v_expected_items_cnt /= 0 and v_transactions_sent_cnt /= 0 then

                -- Check all the items in the queue
                for i in 0 to v_expected_items_cnt-1 loop
                    v_expected_data := string_bits_to_slv(queue_expected_values_dut1_tx1.get(i));

                    -- The actual assertion logic
                    assert dut1_tx1 = v_expected_data
                        report "check_dut1_tx1_is: 'dut1_tx1' (" & to_string(dut1_tx1) & 
                        ") not matching 'v_expected_data': " & to_string(v_expected_data) & 
                        "Transaction: " & integer'image(v_transactions_sent_cnt-1)
                        severity failure;
                end loop;

            end if;
        end process;


        proc_check_dut1_tx1_isnot : process
            variable v_forbidden_data : std_logic_vector(dut1_tx1'range);

            variable v_forbidden_items_cnt : natural := 0;
            variable v_transactions_sent_cnt : natural := 0;
            variable v_received_cnt : natural := 0;
        begin
            wait on dut1_tx1'transaction;

            -- wait long enough until 'log_sent_dut1_tx1' gets updated
            wait_deltas(20);
            v_transactions_sent_cnt := log_sent_dut1_tx1.length;

            v_forbidden_items_cnt := log_forbidden_dut1_tx1.length;

            -- Run only if checking is requested and if at least one transaction has been sent
            if v_forbidden_items_cnt /= 0 and v_transactions_sent_cnt /= 0 then

                -- Check the next item in the queue
                -- v_forbidden_data := string_bits_to_slv(log_forbidden_dut1_tx1.get(0));
                v_forbidden_data := string_bits_to_slv(log_forbidden_dut1_tx1.get(v_transactions_sent_cnt-1));

                -- The actual assertion logic
                assert dut1_tx1 /= v_forbidden_data
                    report "check_dut1_tx1_is: 'dut1_tx1' (" & to_string(dut1_tx1) & 
                    ") is matching 'v_forbidden_data': " & to_string(v_forbidden_data) & 
                    "Transaction: " & integer'image(v_transactions_sent_cnt-1)
                    severity failure;
            end if;

            -- Delete the item
            -- log_forbidden_dut1_tx1.delete(0);

        end process;

        proc_check_dut1_tx1_isnot_values : process
            variable v_forbidden_data : std_logic_vector(dut1_tx1'range);

            variable v_forbidden_items_cnt : natural := 0;
            variable v_transactions_sent_cnt : natural := 0;
        begin
            wait on dut1_tx1'transaction;

            -- wait long enough until 'log_sent_dut1_tx1' gets updated
            wait_deltas(20);
            v_transactions_sent_cnt := log_sent_dut1_tx1.length;

            v_forbidden_items_cnt := log_forbidden_values_dut1_tx1.length;

            -- Run only if checking is requested and if at least one transaction has been sent
            if v_forbidden_items_cnt /= 0 and v_transactions_sent_cnt /= 0 then

                -- Check all the items in the queue
                for i in 0 to v_forbidden_items_cnt-1 loop
                    v_forbidden_data := string_bits_to_slv(log_forbidden_values_dut1_tx1.get(i));

                    -- The actual assertion logic
                    assert dut1_tx1 /= v_forbidden_data
                        report "check_dut1_tx1_is: 'dut1_tx1' (" & to_string(dut1_tx1) & 
                        ") is matching 'v_forbidden_data': " & to_string(v_forbidden_data) & 
                        "Transaction: " & integer'image(v_transactions_sent_cnt-1)
                        severity failure;
                end loop;
            end if;

        end process;


        --     * dut1_rx1
        proc_check_dut1_rx1_is : process
            variable v_expected_data : std_logic_vector(dut1_rx1'range);

            variable v_expected_items_cnt : natural := 0;
            variable v_transactions_sent_cnt : natural := 0;
            variable v_received_cnt : natural := 0;
        begin
            wait on dut1_rx1'transaction;

            wait_deltas(20);
            v_transactions_sent_cnt := log_sent_dut1_tx1.length;

            v_expected_items_cnt := queue_expected_dut1_rx1.length;
            v_received_cnt := log_received_dut1_rx1.length; -- watch out: 'log_received_dut1_rx1' gets updated on delta(1) in monitors


            -- Check only required number of received outputs
            if v_received_cnt <= v_transactions_sent_cnt then

                -- Run only if checking is requested and if at least one transaction has been sent
                if v_expected_items_cnt /= 0 and v_transactions_sent_cnt /= 0 
                    and queue_received_dut1_rx1.length < queue_sent_dut1_tx1.length then

                    -- Check the next item in the queue
                    -- v_expected_data := string_bits_to_slv(queue_expected_dut1_rx1.get(0));
                    v_expected_data := string_bits_to_slv(queue_expected_dut1_rx1.get(v_received_cnt-1));

                    -- The actual assertion logic
                    assert dut1_rx1 = v_expected_data
                        report "***proc_check_dut1_rx1_is: 'dut1_rx1' (" & to_string(dut1_rx1) & 
                        ") not matching 'v_expected_data': " & to_string(v_expected_data) & 
                        " Transaction: " & integer'image(v_received_cnt-1)
                        severity failure;

                end if;
            end if;
            
            -- Delete the item
            -- queue_expected_dut1_rx1.delete(0);
        end process;

        proc_check_dut1_rx1_is_values : process
            variable v_expected_data : std_logic_vector(dut1_rx1'range);

            variable v_expected_items_cnt : natural := 0;
            variable v_transactions_sent_cnt : natural := 0;
            variable v_received_cnt : natural := 0;
        begin
            wait on dut1_rx1'transaction;

            wait_deltas(20);
            v_transactions_sent_cnt := log_sent_dut1_tx1.length;

            v_expected_items_cnt := queue_expected_values_dut1_rx1.length;
            v_received_cnt := log_received_dut1_rx1.length; -- watch out: 'log_received_dut1_rx1' gets updated on delta(1) in monitors


            -- Check only required number of received outputs
            if v_received_cnt <= v_transactions_sent_cnt then

                -- Run only if checking is requested and if at least one transaction has been sent
                if v_expected_items_cnt /= 0 and v_transactions_sent_cnt /= 0
                    and queue_received_dut1_rx1.length < queue_sent_dut1_tx1.length then

                    -- Check all the items in the queue
                    for i in 0 to v_expected_items_cnt-1 loop
                        v_expected_data := string_bits_to_slv(queue_expected_values_dut1_rx1.get(i));

                        -- The actual assertion logic
                        assert dut1_rx1 = v_expected_data
                            report "proc_check_dut1_rx1_is_values: 'dut1_rx1' (" & to_string(dut1_rx1) & 
                            ") not matching 'v_expected_data': " & to_string(v_expected_data) & 
                            " Transaction: " & integer'image(v_received_cnt-1)
                            severity failure;
                    end loop;

                end if;
            end if;
        end process;


        proc_check_dut1_rx1_isnot : process
            variable v_forbidden_data : std_logic_vector(dut1_rx1'range);

            variable v_forbidden_items_cnt : natural := 0;
            variable v_transactions_sent_cnt : natural := 0;
            variable v_received_cnt : natural := 0;
        begin
            wait on dut1_rx1'transaction;

            wait_deltas(20);
            v_transactions_sent_cnt := log_sent_dut1_tx1.length;

            v_forbidden_items_cnt := log_forbidden_dut1_rx1.length;
            v_received_cnt := log_received_dut1_rx1.length; -- watch out: 'log_received_dut1_rx1' gets updated on delta(1) in monitors


            -- Check only required number of received outputs
            if v_received_cnt <= v_transactions_sent_cnt then

                -- Run only if checking is requested and if at least one transaction has been sent
                if v_forbidden_items_cnt /= 0 and v_transactions_sent_cnt /= 0
                    and queue_received_dut1_rx1.length < queue_sent_dut1_tx1.length then

                    -- Check the next item in the queue
                    -- v_forbidden_data := string_bits_to_slv(log_forbidden_dut1_rx1.get(0));
                    v_forbidden_data := string_bits_to_slv(log_forbidden_dut1_rx1.get(v_received_cnt-1));

                    -- The actual assertion logic
                    assert dut1_rx1 /= v_forbidden_data
                        report "proc_check_dut1_rx1_isnot: 'dut1_rx1' (" & to_string(dut1_rx1) & 
                        ") is matching 'v_forbidden_data': " & to_string(v_forbidden_data) & 
                        " Transaction: " & integer'image(v_received_cnt-1)
                        severity failure;

                end if;
            end if;

            -- Delete the item
            -- log_forbidden_dut1_rx1.delete(0);
        end process;

        proc_check_dut1_rx1_isnot_values : process
            variable v_forbidden_data : std_logic_vector(dut1_rx1'range);

            variable v_forbidden_items_cnt : natural := 0;
            variable v_transactions_sent_cnt : natural := 0;
            variable v_received_cnt : natural := 0;
        begin
            wait on dut1_rx1'transaction;

            wait_deltas(20);
            v_transactions_sent_cnt := log_sent_dut1_tx1.length;

            v_forbidden_items_cnt := log_forbidden_values_dut1_rx1.length;
            v_received_cnt := log_received_dut1_rx1.length; -- watch out: 'log_received_dut1_rx1' gets updated on delta(1) in monitors


            -- Check only required number of received outputs
            if v_received_cnt <= v_transactions_sent_cnt then

                -- Run only if checking is requested and if at least one transaction has been sent
                if v_forbidden_items_cnt /= 0 and v_transactions_sent_cnt /= 0
                    and queue_received_dut1_rx1.length < queue_sent_dut1_tx1.length then

                    -- Check all the items in the queue
                    for i in 0 to v_forbidden_items_cnt-1 loop
                        v_forbidden_data := string_bits_to_slv(log_forbidden_values_dut1_rx1.get(i));

                        -- The actual assertion logic
                        assert dut1_rx1 /= v_forbidden_data
                            report "proc_check_dut1_rx1_isnot_values: 'dut1_rx1' (" & to_string(dut1_rx1) & 
                            ") is matching 'v_forbidden_data': " & to_string(v_forbidden_data)
                            severity failure;
                    end loop;

                end if;
            end if;
        end process;


        --     * dut1_rx2
        proc_check_dut1_rx2_is : process
            variable v_expected_data : std_logic_vector(dut1_rx2'range);

            variable v_expected_items_cnt : natural := 0;
            variable v_transactions_sent_cnt : natural := 0;
            variable v_received_cnt : natural := 0;
        begin
            wait on dut1_rx2'transaction;

            wait_deltas(20);
            v_transactions_sent_cnt := log_sent_dut1_tx1.length;

            v_expected_items_cnt := queue_expected_dut1_rx2.length;
            v_received_cnt := log_received_dut1_rx2.length; -- watch out: 'log_received_dut1_rx2' gets updated on delta(1) in monitors


            -- Check only required number of received outputs
            if v_received_cnt <= v_transactions_sent_cnt then

                -- Run only if checking is requested and if at least one transaction has been sent
                if v_expected_items_cnt /= 0 and v_transactions_sent_cnt /= 0
                    and queue_received_dut1_rx2.length < queue_sent_dut1_tx1.length then

                    -- Check the next item in the queue
                    -- v_expected_data := string_bits_to_slv(queue_expected_dut1_rx2.get(0));
                    v_expected_data := string_bits_to_slv(queue_expected_dut1_rx2.get(v_received_cnt-1));

                    -- The actual assertion logic
                    assert dut1_rx2 = v_expected_data
                        report "proc_check_dut1_rx2_is: 'dut1_rx2' (" & to_string(dut1_rx2) & 
                        ") not matching 'v_expected_data': " & to_string(v_expected_data)
                        severity failure;

                end if;
            end if;

            -- Delete the item
            -- queue_expected_dut1_rx2.delete(0);
        end process;

        proc_check_dut1_rx2_is_values : process
            variable v_expected_data : std_logic_vector(dut1_rx2'range);

            variable v_expected_items_cnt : natural := 0;
            variable v_transactions_sent_cnt : natural := 0;
            variable v_received_cnt : natural := 0;
        begin
            wait on dut1_rx2'transaction;

            wait_deltas(20);
            v_transactions_sent_cnt := log_sent_dut1_tx1.length;

            v_expected_items_cnt := queue_expected_values_dut1_rx2.length;
            v_received_cnt := log_received_dut1_rx2.length; -- watch out: 'log_received_dut1_rx2' gets updated on delta(1) in monitors


            -- Check only required number of received outputs
            if v_received_cnt <= v_transactions_sent_cnt then

                -- Run only if checking is requested and if at least one transaction has been sent
                if v_expected_items_cnt /= 0 and v_transactions_sent_cnt /= 0
                    and queue_received_dut1_rx2.length < queue_sent_dut1_tx1.length then

                    -- Check all the items in the queue
                    for i in 0 to v_expected_items_cnt-1 loop
                        v_expected_data := string_bits_to_slv(queue_expected_values_dut1_rx2.get(i));

                        -- The actual assertion logic
                        assert dut1_rx2 = v_expected_data
                            report "proc_check_dut1_rx2_is_values: 'dut1_rx2' (" & to_string(dut1_rx2) & 
                            ") not matching 'v_expected_data': " & to_string(v_expected_data)
                            severity failure;
                    end loop;

                end if;
            end if;
        end process;


        proc_check_dut1_rx2_isnot : process
            variable v_forbidden_data : std_logic_vector(dut1_rx2'range);

            variable v_forbidden_items_cnt : natural := 0;
            variable v_transactions_sent_cnt : natural := 0;
            variable v_received_cnt : natural := 0;
        begin
            wait on dut1_rx2'transaction;

            wait_deltas(20);
            v_transactions_sent_cnt := log_sent_dut1_tx1.length;

            v_forbidden_items_cnt := log_forbidden_dut1_rx2.length;
            v_received_cnt := log_received_dut1_rx2.length; -- watch out: 'log_received_dut1_rx2' gets updated on delta(1) in monitors


            -- Check only required number of received outputs
            if v_received_cnt <= v_transactions_sent_cnt then

                -- Run only if checking is requested and if at least one transaction has been sent
                if v_forbidden_items_cnt /= 0 and v_transactions_sent_cnt /= 0
                    and queue_received_dut1_rx2.length < queue_sent_dut1_tx1.length then

                    -- Check the next item in the queue
                    -- v_forbidden_data := string_bits_to_slv(log_forbidden_dut1_rx2.get(0));
                    v_forbidden_data := string_bits_to_slv(log_forbidden_dut1_rx2.get(v_received_cnt-1));

                    -- The actual assertion logic
                    assert dut1_rx2 /= v_forbidden_data
                        report "proc_check_dut1_rx2_isnot: 'dut1_rx2' (" & to_string(dut1_rx2) & 
                        ") is matching 'v_forbidden_data': " & to_string(v_forbidden_data)
                        severity failure;

                end if;
            end if;

            -- Delete the item
            -- log_forbidden_dut1_rx2.delete(0);
        end process;

        proc_check_dut1_rx2_isnot_values : process
            variable v_forbidden_data : std_logic_vector(dut1_rx2'range);

            variable v_forbidden_items_cnt : natural := 0;
            variable v_transactions_sent_cnt : natural := 0;
            variable v_received_cnt : natural := 0;
        begin
            wait on dut1_rx2'transaction;

            wait_deltas(20);
            v_transactions_sent_cnt := log_sent_dut1_tx1.length;

            v_forbidden_items_cnt := log_forbidden_values_dut1_rx2.length;
            v_received_cnt := log_received_dut1_rx2.length; -- watch out: 'log_received_dut1_rx2' gets updated on delta(1) in monitors


            -- Check only required number of received outputs
            if v_received_cnt <= v_transactions_sent_cnt then

                -- Run only if checking is requested and if at least one transaction has been sent
                if v_forbidden_items_cnt /= 0 and v_transactions_sent_cnt /= 0
                    and queue_received_dut1_rx2.length < queue_sent_dut1_tx1.length then

                    -- Check all the items in the queue
                    for i in 0 to v_forbidden_items_cnt-1 loop
                        v_forbidden_data := string_bits_to_slv(log_forbidden_values_dut1_rx2.get(i));

                        -- The actual assertion logic
                        assert dut1_rx2 /= v_forbidden_data
                            report "proc_check_dut1_rx2_isnot_values: 'dut1_rx2' (" & to_string(dut1_rx2) & 
                            ") is matching 'v_forbidden_data': " & to_string(v_forbidden_data)
                            severity failure;
                            -- severity warning;
                    end loop;

                end if;
            end if;
        end process;

    end architecture;