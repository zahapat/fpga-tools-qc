--Copyright 1986-2020 Xilinx, Inc. All Rights Reserved.
----------------------------------------------------------------------------------
--Tool Version: Vivado v.2020.2 (win64) Build 3064766 Wed Nov 18 09:12:45 MST 2020
--Date        : Fri Oct 28 23:05:11 2022
--Host        : Patrik running 64-bit major release  (build 9200)
--Command     : generate_target top_wrapper.bd
--Design      : top_wrapper
--Purpose     : IP block netlist
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity top_wrapper is
  port (
    clk_in1_0 : in STD_LOGIC;
    clk_out1_0 : out STD_LOGIC
  );
end top_wrapper;

architecture STRUCTURE of top_wrapper is
  component top is
  port (
    clk_in1_0 : in STD_LOGIC;
    clk_out1_0 : out STD_LOGIC
  );
  end component top;
begin
top_i: component top
     port map (
      clk_in1_0 => clk_in1_0,
      clk_out1_0 => clk_out1_0
    );
end STRUCTURE;
