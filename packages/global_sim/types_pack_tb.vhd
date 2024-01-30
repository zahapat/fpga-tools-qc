    -- This package contains all global types accessible to all SRC modules

    library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

    library lib_src;
    use lib_src.const_pack.all;
    use lib_src.generics.all;
    use lib_src.types_pack.all;
    use lib_src.signals_pack.all;

    library lib_sim;
    use lib_sim.const_pack_tb.all;

    use lib_sim.list_string_pack_tb.all;
    use lib_sim.print_list_pack_tb.all;

    package types_pack_tb is

    end package;

    package body types_pack_tb is

    end package body;