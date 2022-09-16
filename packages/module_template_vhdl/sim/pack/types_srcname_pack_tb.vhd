    -- This package contains all global types accessible to all SRC modules

    library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

    -- SRC Packages
    library lib_src;
    --     * Module-specific SRC Packages (if used, uncomment)
    -- use lib_src.const_srcname_pack.all;

    --     * Global project-specific SRC Packages
    use lib_src.const_pack.all;
    use lib_src.types_pack.all;
    use lib_src.signals_pack.all;


    -- TB Packages
    --     * Module-specific TB Packages
    library lib_sim;
    use lib_sim.const_srcname_pack_tb.all;

    --     * Global Project-specific TB Packages
    use lib_sim.const_pack_tb.all;
    use lib_sim.types_pack_tb.all;
    use lib_sim.signals_pack_tb.all;

    use lib_sim.list_string_pack_tb.all;
    use lib_sim.print_list_pack_tb.all;

    package types_srcname_pack_tb is

    end package;

    package body types_srcname_pack_tb is
    end package body;