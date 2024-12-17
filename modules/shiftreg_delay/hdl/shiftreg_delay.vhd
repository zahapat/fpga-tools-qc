    -- delay.vhd: This block performs signal delay by the given number of clock cycles

    library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;
    use ieee.math_real.all;

    entity shiftreg_delay is
        generic (
            CLK_HZ  : real := 250.0e6;
            RST_VAL : std_logic := '1';
            DATA_WIDTH : positive := 1;
            DELAY_CYCLES : natural := 2;
            DELAY_NS : natural := 2      -- This value should be a multiple of clock period for precise results
        );
        port (
            clk    : in  std_logic;
            i_en   : in  std_logic;
            i_data : in  std_logic_vector(DATA_WIDTH-1 downto 0);
            o_data : out std_logic_vector(DATA_WIDTH-1 downto 0)
        );
    end shiftreg_delay;

    architecture rtl of shiftreg_delay is

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

        -- Shiftregister buffer
        -- signal slv_buffer_reg_2d : t_array_2d := (others => (others => '0'));
        signal slv_buffer_shiftreg : std_logic_vector((DELAY_CYCLES_CALCULATED+2)*DATA_WIDTH-1 downto 0) := (others => '0');

    begin

        -- Connect input and output ports
        slv_buffer_shiftreg(i_data'range) <= i_data(i_data'range) when i_en = '1' else (others => '0');
        o_data <= slv_buffer_shiftreg((DELAY_CYCLES_CALCULATED+1)*DATA_WIDTH-1 downto (DELAY_CYCLES_CALCULATED)*DATA_WIDTH);

        -- Delay the signal
        gen_delay_line : for i in 0 to DELAY_CYCLES_CALCULATED-1 generate
            proc_delay_line_sync : process(clk)
            begin
                if DELAY_CYCLES_CALCULATED > 0 then -- This will work as if-generate - the synthesizer will not attempt to implement this if false
                    if rising_edge(clk) then
                        slv_buffer_shiftreg((DELAY_CYCLES_CALCULATED+2)*DATA_WIDTH-1 downto DATA_WIDTH)
                            <= slv_buffer_shiftreg((DELAY_CYCLES_CALCULATED+1)*DATA_WIDTH-1 downto DATA_WIDTH)
                               & slv_buffer_shiftreg(DATA_WIDTH-1 downto 0);
                    end if;
                end if;
            end process;
        end generate;

    end architecture;