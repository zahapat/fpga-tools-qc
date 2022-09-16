    library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

    library UNISIM;
    use UNISIM.VComponents.all;

    entity xilinx_ibufs is
        generic (
            PINS_CNT : natural
        );
        port (
            clk : in std_logic;
            data_in : in std_logic_vector(PINS_CNT-1 downto 0);
            data_out : out std_logic_vector(PINS_CNT-1 downto 0)
        );
    end xilinx_ibufs;

    architecture rtl of xilinx_ibufs is

        -- Xilinx FDRE Primitive
        component FDRE port (
            D  : in    std_logic;
            C  : in    std_logic;
            CE : in    std_logic;
            R  : in    std_logic;
            Q  : out   std_logic
        );
        end component;
        attribute IOB: string;
        attribute IOB of FDRE  : component is "TRUE";

        -- Pulldown
        signal slv_pin_pull : std_logic_vector(data_in'range) := (others => '0');

        -- FDRE signals
        signal slv_ibuf_fdre_data : std_logic_vector(data_in'range) := (others => '0');

    begin


        -- Generate IBUFs with pullup logic
        gen_ibufs : for i in data_in'range generate
            slv_pin_pull(i) <= data_in(i);

            -- Inst pullup logic
            inst_pullup_logic : PULLUP
            port map (
                O => slv_pin_pull(i)
            );

            -- Inst input buffer
            inst_input_ibuf : IBUF
            port map (
                I => slv_pin_pull(i),
                O => slv_ibuf_fdre_data(i)
            );

            -- Use OLOGIC cell as a register
            inst_fdre_cell: FDRE
            port map (
                D => slv_ibuf_fdre_data(i),
                Q => data_out(i),
                C => clk,
                CE => '1',
                R=>'0'
            );
        end generate;

    end architecture;