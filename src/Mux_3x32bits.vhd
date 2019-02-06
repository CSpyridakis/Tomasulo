----------------------------------------------------------------------------------
-- Company/University:        Technical University of Crete (TUC) - GR
-- Engineer:                  Spyridakis Christos 
--                            Bellonias Panagiotis
-- 
-- Create Date:               10/22/2018
-- Design Name: 	 
-- Module Name:               Mux_3x32bits - Behavioral 
-- Project Name:              Tomasulo
-- Target Devices:            NONE
-- Tool versions:             Xilinx ISE 14.7 --TODO: VIVADO
-- Description:               Introduction in Dynamic Instruction Scheduling (Advanced Computer Architecture)
--                            implementing Tomasulo's Algorithm 	 
--
-- Dependencies:              NONE
--
-- Revision:                  2.1
-- Revision                   2.1 - ROB
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Mux_3x32bits is
    Port ( In1 : in  STD_LOGIC_VECTOR (31 downto 0);
           In2 : in  STD_LOGIC_VECTOR (31 downto 0);
           In3 : in  STD_LOGIC_VECTOR (31 downto 0);
           Sel : in  STD_LOGIC_VECTOR (1 downto 0);
           Outt : out  STD_LOGIC_VECTOR (31 downto 0));
end Mux_3x32bits;

architecture Behavioral of Mux_3x32bits is
signal TMP : STD_LOGIC_VECTOR (31 downto 0);

begin
  WITH Sel SELECT
  TMP <= "00000000000000000000000000000000" WHEN "00",
         In1 WHEN "01",
         In2 WHEN "10",
         In3 WHEN "11",
         TMP WHEN OTHERS; 
           
  Outt <= TMP;
end Behavioral;
