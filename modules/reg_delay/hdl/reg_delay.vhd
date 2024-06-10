    -- delay.vhd: This block performs signal delay by the given number of clock cycles

    library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;
    use ieee.math_real.all;

    entity reg_delay is
        generic (
            CLK_HZ  : real := 250.0e6;
            RST_VAL : std_logic := '1';
            DATA_WIDTH : positive := 1;
            DELAY_CYCLES : natural := 2;
            DELAY_NS : natural := 2      -- This value should be a multiple of clock period for precise results
        );
        port (
            clk    : in  std_logic;
            i_data : in  std_logic_vector(DATA_WIDTH-1 downto 0);
            o_data : out std_logic_vector(DATA_WIDTH-1 downto 0)
        );
    end reg_delay;

    architecture rtl of reg_delay is

        -- Convert to HZ to Nanoseconds
        constant CLK_PERIOD_NS : real := 
            (1.0/real(CLK_HZ) * 1.0e9);

        -- Must not be negative number, minimum is zero
        constant TIME_DELAY_PERIODS : natural :=
                natural( ceil(real(DELAY_NS) / CLK_PERIOD_NS) );
        
        -- If you specify DELAY_CYCLES (is greater than zero), then DELAY_NS generic will be ignored
        -- Otherwise get the number of clock cycles to delay the data based on DELAY_NS
        impure function get_delay_in_clock_cycles return natural is 
        begin
            if DELAY_CYCLES /= 0 and TIME_DELAY_PERIODS /= 0 then
                return DELAY_CYCLES;
            elsif DELAY_CYCLES = 0 and TIME_DELAY_PERIODS /= 0 then
                return TIME_DELAY_PERIODS;
            elsif DELAY_CYCLES /= 0 and TIME_DELAY_PERIODS = 0 then
                return DELAY_CYCLES;
            else
                return DELAY_CYCLES;
            end if;
        end function;

        constant DELAY_CYCLES_CALCULATED : natural := get_delay_in_clock_cycles;

        -- Create a an array of arrays to create enough room to delay the 1d data
        type t_array_2d is array(DELAY_CYCLES_CALCULATED downto 0) of std_logic_vector(i_data'range);

        -- 2d 1d-data buffer
        signal slv_buffer_reg_2d : t_array_2d := (others => (others => '0'));

    begin

        -- Connect input and output ports
        slv_buffer_reg_2d(0)(i_data'range) <= i_data(i_data'range);
        o_data <= slv_buffer_reg_2d(DELAY_CYCLES_CALCULATED);

        -- Delay the signal
        gen_delay_line : for i in 0 to DELAY_CYCLES_CALCULATED-1 generate
            proc_delay_line_sync : process(clk)
            begin
                if DELAY_CYCLES_CALCULATED > 0 then -- This will work as if-generate - the synthesizer will not attempt to implement this if false
                    if rising_edge(clk) then
                        slv_buffer_reg_2d(i+1)(i_data'range) <= slv_buffer_reg_2d(i)(i_data'range);
                    end if;
                end if;
            end process;
        end generate;

    end architecture;