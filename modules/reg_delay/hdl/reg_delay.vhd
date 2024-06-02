    -- delay.vhd: This block performs signal delay by the given number of clock cycles

    library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

    library lib_src;
    use lib_src.types_pack.all;

    entity reg_delay is
        generic (
            RST_VAL : std_logic := '1';
            DATA_WIDTH : positive := 1;
            DELAY_CYCLES : natural := 2
        );
        port (
            clk    : in  std_logic;
            i_data : in  std_logic_vector(DATA_WIDTH-1 downto 0);
            o_data : out std_logic_vector(DATA_WIDTH-1 downto 0)
        );
    end reg_delay;

    architecture rtl of reg_delay is

        -- Create a an array of arrays to create enough room to delay the 1d data
        type t_array_2d is array(DELAY_CYCLES downto 0) of std_logic_vector(i_data'range);

        -- 2d 1d-data buffer
        signal slv_buffer_reg_2d : t_array_2d := (others => (others => '0'));

    begin

        -- Connect input and output ports
        slv_buffer_reg_2d(0)(i_data'range) <= i_data(i_data'range);
        o_data <= slv_buffer_reg_2d(DELAY_CYCLES);

        -- Delay the signal
        gen_delay_line : for i in 0 to DELAY_CYCLES-1 generate
            proc_delay_line_sync : process(clk)
            begin
                if DELAY_CYCLES > 0 then -- This will work as if-generate - the synthesizer will not attempt to implement this if false
                    if rising_edge(clk) then
                        slv_buffer_reg_2d(i+1)(i_data'range) <= slv_buffer_reg_2d(i)(i_data'range);
                    end if;
                end if;
            end process;
        end generate;

    end architecture;