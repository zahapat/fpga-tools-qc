-- FOR COMPILING USE VHDL 2008
--      -> compile before testbenches

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Prototypes of the subprograms
package clk_pack_tb is

    -- procedure gen_clk(signal clk : inout std_logic);   -- INOUT because we are going to assign and read from it (NO RETURN NEEDED)


    procedure gen_clk_freq_hz_int (
        signal clk : inout std_logic;
        constant CLK_HZ : integer
    );


    procedure gen_clk_freq_hz_real (
        signal clk : inout std_logic;
        constant CLK_HZ_REAL : real
    );


    procedure gen_clk_period_time (
        signal clk : inout std_logic;
        constant CLK_PERIOD : time
    );


    procedure gen_pulse_up_real_ns (
        signal pulse : inout std_logic;
        constant DURATION_HIGH_REAL_NS : real
    );

    procedure gen_pulse_up_time (
        signal pulse : inout std_logic;
        constant DURATION_HIGH_TIME : time;
        constant UNIT : time
    );


    procedure gen_pulse_real_ns (
        signal pulse : inout std_logic;
        constant DURATION_HIGH_REAL_NS : real;
        constant DURATION_LOW_REAL_NS : real
    );


    -- Does not work when combined with UVVM Clock gen
    procedure wait_cycles (
        constant cycles_cnt : integer;
        signal clk_name : std_logic 
    );

    procedure wait_deltas (
        constant deltas_cnt : positive
    );


end package;


-- Bodies of all the prototypes
package body clk_pack_tb is

    -- Clock generator: 'const_pack_tb' package, this pck must exist where CLK_PERIOD is declared
    -- gen_clk(sl_my_clock)
    -- procedure gen_clk (signal clk : inout std_logic) is -- INOUT because we are going to assign and read from it (NO RETURN NEEDED)
    -- begin
    --     clk <= not clk after CLK_PERIOD / 2;
    -- end procedure;


    -- Clock generator - Pass 'Integer' type value as Hz
    -- gen_clk_freq_hz_int(sl_my_clock, 100e6)
    -- gen_clk_freq_hz_int(sl_my_clock, INT_CLK_PERIOD)
    procedure gen_clk_freq_hz_int (
        signal clk : inout std_logic;
        constant CLK_HZ : integer
    ) is 
        constant CLK_PERIOD : time := 1 sec / CLK_HZ;
    begin
        clk <= not clk after CLK_PERIOD / 2;
    end procedure;


    -- Clock generator - Pass 'Real' type value as Hz
    -- gen_clk_freq_hz_real(sl_my_clock, 100.0e6)
    -- gen_clk_freq_hz_real(sl_my_clock, REAL_CLK_PERIOD)
    procedure gen_clk_freq_hz_real (
        signal clk : inout std_logic;
        constant CLK_HZ_REAL : real
    ) is 
        constant CLK_PERIOD : time := 1 sec / CLK_HZ_REAL;
    begin
        clk <= not clk after CLK_PERIOD / 2;
    end procedure;


    -- Clock generator - Pass 'Time' type value as period (1/Hz)
    -- gen_clk_period_time(sl_my_clock, TIME_CLK_PERIOD)
    procedure gen_clk_period_time (
        signal clk : inout std_logic;
        constant CLK_PERIOD : time
    ) is begin
        clk <= not clk after CLK_PERIOD / 2;
    end procedure;


    -- Pulse generator: Pass 'Real' type as duration (in ns) for pulse HIGH,
    -- gen_pulse_up_real_ns(sl_my_pulse, 78.0)
    -- gen_clk_freq_hz_int(sl_my_clock, REAL_DURATION_HIGH_NS)
    procedure gen_pulse_up_real_ns (
        signal pulse : inout std_logic;
        constant DURATION_HIGH_REAL_NS : real
    ) is begin
        pulse <= '1';
        wait for DURATION_HIGH_REAL_NS * 1 ns;
        pulse <= '0';
    end procedure;


    procedure gen_pulse_up_time (
        signal pulse : inout std_logic;
        constant DURATION_HIGH_TIME : time;
        constant UNIT : time
    ) is begin
        pulse <= '1';
        wait for real(DURATION_HIGH_TIME / UNIT) * UNIT;
        pulse <= '0';
    end procedure;



    -- Pulse generator: Pass 2x 'Real' type as durations (in ns) for pulse HIGH and DOWN,
    -- gen_pulse_real_ns(sl_my_pulse, 78.0, 69.0)
    -- gen_pulse_real_ns(sl_my_pulse, REAL_DURATION_HIGH_NS, REAL_DURATION_LOW_NS)
    procedure gen_pulse_real_ns (
        signal pulse : inout std_logic;
        constant DURATION_HIGH_REAL_NS : real;
        constant DURATION_LOW_REAL_NS : real
    ) is begin
        pulse <= '1';
        wait for DURATION_HIGH_REAL_NS * 1 ns;
        pulse <= '0';
        wait for DURATION_LOW_REAL_NS * 1 ns;
    end procedure;


    -- Wait certain number of clock cycles
    procedure wait_cycles (
        constant cycles_cnt : integer;
        signal clk_name : std_logic 
    ) is begin
        for i in 0 to cycles_cnt-1 loop
            wait until rising_edge(clk_name);
        end loop;
    end procedure;


    -- Update data in within the following number of delta cycles
    procedure wait_deltas (
        constant deltas_cnt : positive
    ) is begin
        if deltas_cnt = 0 then
            null;
        else
            for i in 0 to deltas_cnt-1 loop
                wait for 0 ns;
            end loop;
        end if;
    end procedure;

end package body;