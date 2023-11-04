    -- Signals that are accessible to all testbench modules/submodules

    library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

    library lib_sim;
    use lib_sim.const_pack_tb.all;
    use lib_sim.types_pack_tb.all;
    
    use lib_sim.list_string_pack_tb.all;
    use lib_sim.print_list_pack_tb.all;


    package signals_pack_tb is

        ----------------------------------------------
        -- Interfaces = data queues (triggers) between executors -> checkers (tests)) / monitors
        ----------------------------------------------
        -- AUXILLIARY
        -- Interface Executor => Checker

    end package;

    package body signals_pack_tb is

    end package body;