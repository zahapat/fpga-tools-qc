    library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

    library UNISIM;
    use UNISIM.VComponents.all;

    entity xilinx_obufs is
        generic (
            PINS_CNT : natural
        );
        port (
            clk : in std_logic;
            data_in : in std_logic_vector(PINS_CNT-1 downto 0);
            data_out : out std_logic_vector(PINS_CNT-1 downto 0)
        );
    end xilinx_obufs;

    architecture rtl of xilinx_obufs is

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

        -- FDRE signals
        signal slv_obuf_fdre_data : std_logic_vector(data_in'range) := (others => '0');

    begin

        -- Generate OBUFs
        gen_obufs : for i in data_in'range generate

            -- Use OLOGIC cell as a register
            inst_fdre_ologic: FDRE
            port map (
                D => data_in(i),
                Q => slv_obuf_fdre_data(i),
                C => clk,
                CE => '1',
                R=>'0'
            );

            -- Inst onput buffer
            inst_output_obuf : OBUF
            port map (
                I => slv_obuf_fdre_data(i),
                O => data_out(i)
            );
        end generate;


    end architecture;