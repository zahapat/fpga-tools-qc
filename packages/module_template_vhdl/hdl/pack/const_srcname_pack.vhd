    -- Constants that are accessible to all testbench modules/submodules

    library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;
    use ieee.math_real.all;
    
    -- SRC Packages
    library lib_src;
    --     * Global project-specific SRC Packages
    use lib_src.const_pack.all;
    use lib_src.types_pack.all;

    package const_srcname_pack is

        ------------------------------------------------
        -- srcname constants, subtypes, const functions
        ------------------------------------------------
        -- USER INPUT
        constant SRCNAME_IN_DATA_WIDTH : integer := 8;
        subtype st_SRCNAME_IN_DATA_WIDTH is natural range 
            SRCNAME_IN_DATA_WIDTH-1 downto 0;

        constant SRCNAME_OUT_DATA_WIDTH : integer := 8;
        subtype st_SRCNAME_OUT_DATA_WIDTH is natural range 
            SRCNAME_OUT_DATA_WIDTH-1 downto 0;
        
    end package;

    package body const_srcname_pack is
    end package body;