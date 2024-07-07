    -- reset.vhd : Resets the system by long-lasting reset pulse (reset strobe)

    library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;
    
    entity reset is
        generic (
            RST_STROBE_COUNTER_WIDTH  : positive := 4
        );
        port (
            CLK     : in std_logic;
            IN_RST  : in std_logic; -- Pullup
            OUT_RST : out std_logic
        );
    end reset;
    
    architecture rtl of reset is
    
        -- Pull up logic: true value (pressed button) = grounded signal IN_RST
        constant PULLUP_RST_PRESSED : std_logic := '0';

        -- Initialisation only for simulation purposes (ignored after synthesis, it is automatically 0)
        signal cnt_reset_strobe : unsigned(RST_STROBE_COUNTER_WIDTH-1 downto 0) := (others => '0');

    begin

        -- Generate reset pulse on device power-on, or if IN_RST = '0'
        proc_reset_strobe: process(CLK)
        begin
            if rising_edge(CLK) then
                if IN_RST = PULLUP_RST_PRESSED then
                    -- IN_RST = '0'
                    cnt_reset_strobe <= (others => '0');
                else
                    -- IN_RST = '1': count up to 2**X, output last bit (inverted)
                    if cnt_reset_strobe(cnt_reset_strobe'high) = '0' then
                        cnt_reset_strobe <= cnt_reset_strobe + 1;
                    end if;
                end if;
            end if;
        end process;
    
        -- Releasing reset signal
        proc_propag_rst : process (CLK)
        begin
            if rising_edge(CLK) then
                OUT_RST <= not cnt_reset_strobe(cnt_reset_strobe'high);
            end if;
        end process;

    end architecture;