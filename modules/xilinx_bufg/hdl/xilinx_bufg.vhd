    library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

    library UNISIM;
    use UNISIM.VComponents.all;

    entity xilinx_bufg is
        port (
            bit_in : in std_logic;
            bit_out : out std_logic
        );
    end xilinx_bufg;

    architecture rtl of xilinx_bufg is

        -- Xilinx BUFG Primitive
        component BUFG port (
            I  : in    std_logic;
            O  : out   std_logic
        );
        end component;

        -- Signals
        signal sl_bit_in : std_logic := '0';
        signal sl_bit_out : std_logic := '0';

    begin

        -- Instantiate BUFG primitive
        sl_bit_in <= bit_in;
        bit_out <= sl_bit_out;
        inst_BUFG : BUFG
        port map (
            I => sl_bit_in,  -- 1-bit input: Clock input
            O => sl_bit_out -- 1-bit output: Clock output
        );

    end architecture;