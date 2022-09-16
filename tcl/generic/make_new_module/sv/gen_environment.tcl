puts $new_file_sim "    // This file contains a container class, which contains Mailbox, Sequencer and Driver."
puts $new_file_sim "    // Mailbox handle is shared across the Sequencer and Driver."
puts $new_file_sim ""
puts $new_file_sim ""
puts $new_file_sim "    `include \"${name_file}_transaction.sv\""
puts $new_file_sim "    `include \"${name_file}_sequencer.sv\""
puts $new_file_sim "    `include \"${name_file}_driver.sv\""
puts $new_file_sim "    `include \"${name_file}_monitor.sv\""
puts $new_file_sim "    `include \"${name_file}_scoreboard.sv\""
puts $new_file_sim "    class environment;"
puts $new_file_sim "    "
puts $new_file_sim "        // sequencer and driver instance"
puts $new_file_sim "        sequencer  seq;"
puts $new_file_sim "        driver     driv;"
puts $new_file_sim "        monitor    mon;"
puts $new_file_sim "        scoreboard scb;"
puts $new_file_sim "        "
puts $new_file_sim "        // Mailbox handle's"
puts $new_file_sim "        mailbox mail_seq2driv;"
puts $new_file_sim "        mailbox mail_monitor2scb;"
puts $new_file_sim "        "
puts $new_file_sim "        // Virtual interface"
puts $new_file_sim "        virtual intf virt_intf;"
puts $new_file_sim "        "
puts $new_file_sim "        // Constructor"
puts $new_file_sim "        function new(virtual intf virt_intf);"
puts $new_file_sim "            // Get the interface from test"
puts $new_file_sim "            this.virt_intf = virt_intf;"
puts $new_file_sim "            "
puts $new_file_sim "            // Create the mailbox (Same handle will be shared across sequencer and driver)"
puts $new_file_sim "            mail_seq2driv = new();"
puts $new_file_sim "            mail_monitor2scb  = new();"
puts $new_file_sim "            "
puts $new_file_sim "            // Create sequencer, driver, monitor, scoreboard"
puts $new_file_sim "            seq  = new(mail_seq2driv);"
puts $new_file_sim "            driv = new(virt_intf, mail_seq2driv);"
puts $new_file_sim "            mon  = new(virt_intf, mail_monitor2scb);"
puts $new_file_sim "            scb  = new(mail_monitor2scb);"
puts $new_file_sim "        endfunction"
puts $new_file_sim "        "
puts $new_file_sim "        // Pre-test"
puts $new_file_sim "        task pre_test();"
puts $new_file_sim "            driv.reset();"
puts $new_file_sim "        endtask"
puts $new_file_sim "        "
puts $new_file_sim "        // Test"
puts $new_file_sim "        task test();"
puts $new_file_sim "            fork"
puts $new_file_sim "            seq.main();"
puts $new_file_sim "            driv.main();"
puts $new_file_sim "            mon.main();"
puts $new_file_sim "            scb.main();"
puts $new_file_sim "            join_any"
puts $new_file_sim "        endtask"
puts $new_file_sim "        "
puts $new_file_sim "        // Post-test"
puts $new_file_sim "        task post_test();"
puts $new_file_sim "            wait(seq.ended.triggered);"
puts $new_file_sim "            wait(seq.repeat_count == driv.trans_cnt); // Optional"
puts $new_file_sim "            wait(seq.repeat_count == scb.trans_cnt);"
puts $new_file_sim "        endtask "
puts $new_file_sim "        "
puts $new_file_sim "        // Run task"
puts $new_file_sim "        task run;"
puts $new_file_sim "            pre_test();"
puts $new_file_sim "            test();"
puts $new_file_sim "            post_test();"
puts $new_file_sim "            \$finish;"
puts $new_file_sim "        endtask"
puts $new_file_sim "    "
puts $new_file_sim "    endclass"