    -- File "srcname.vhd": description
    -- Engineer: Patrik Zahalka (patrik.zahalka@univie.ac.at; zahalka.patrik@gmail.com)
    -- Year: 2022

    library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;
    use ieee.math_real.all;

    -- SRC Packages
    library lib_src;
    --     * Module-specific SRC Packages
    use lib_src.const_srcname_pack.all;
    use lib_src.types_srcname_pack.all;
    use lib_src.signals_srcname_pack.all;

    --     * Global project-specific SRC Packages
    use lib_src.const_pack.all;
    use lib_src.types_pack.all;
    use lib_src.signals_pack.all;

    entity srcname is
        generic (
            RST_VAL         : std_logic := '1';
            IN_DATA_WIDTH   : integer := SRCNAME_IN_DATA_WIDTH;
            OUT_DATA_WIDTH  : integer := SRCNAME_OUT_DATA_WIDTH
        );
        port (
            -- In
            clk         : in std_logic;
            rst         : in std_logic;
            data_in     : in std_logic_vector(IN_DATA_WIDTH-1 downto 0);

            -- Out
            ready       : out std_logic;
            data_out    : out std_logic_vector(OUT_DATA_WIDTH-1 downto 0);
            valid       : out std_logic
        );
    end srcname;

    architecture rtl of srcname is

        -- Function RTL
        function func_mask (
            func_input : in std_logic_vector(IN_DATA_WIDTH-1 downto 0)
        ) return std_logic_vector is
            variable var_slv_output_vector  : std_logic_vector(func_input'range) := (others => '1');
        begin
            -- Function body
            return func_input xor var_slv_output_vector;
        end function func_mask;

    begin

        -- Always ready to accept data
        ready <= '1';

        -- Synchronous logic with synchronous reset
        data_out <= slv_data_out;
        proc_name : process(clk)
        begin
            if rising_edge(clk) then
                if rst = RST_VAL then
                    slv_data_out <= (others => '0');

                else
                    slv_data_out <= func_mask(data_in);
                end if;
            end if;
        end process;

        

    end architecture;
