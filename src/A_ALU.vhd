----------------------------------------------------------------------------------
-- Company/University:        Technical University of Crete (TUC) - GR
-- Engineer:                  Spyridakis Christos 
--                            Bellonias Panagiotis
-- 
-- Create Date:               10/22/2018
-- Design Name: 	 
-- Module Name:               ALU - Behavioral 
-- Project Name:              Tomasulo
-- Target Devices:            NONE
-- Tool versions:             Xilinx ISE 14.7 --TODO: VIVADO
-- Description:               Introduction in Dynamic Instruction Scheduling (Advanced Computer Architecture)
--                            implementing Tomasulo's Algorithm 	 
--
-- Dependencies:              IEEE.STD_LOGIC_ARITH.ALL, IEEE.STD_LOGIC_SIGNED.ALL
--
-- Revision:                  0.01
-- Revision                   0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_SIGNED.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;

entity ALU is
    Port ( A_Vj : in  STD_LOGIC_VECTOR (31 downto 0);
           A_Vk : in  STD_LOGIC_VECTOR (31 downto 0);
           A_Op : in  STD_LOGIC_VECTOR (1 downto 0);
           A0_V : out  STD_LOGIC_VECTOR (31 downto 0);
			  
           L_Vj : in  STD_LOGIC_VECTOR (31 downto 0);
           L_Vk : in  STD_LOGIC_VECTOR (31 downto 0);
           L_Op : in  STD_LOGIC_VECTOR (1 downto 0);
           L0_V : out  STD_LOGIC_VECTOR (31 downto 0));
end ALU;

architecture Behavioral of ALU is

signal TMP_A_V, TMP_L_V : STD_LOGIC_VECTOR (31 downto 0);

begin

	WITH A_Op SELECT
	TMP_A_V <= A_Vj + A_Vk WHEN "00",
			     A_Vj - A_Vk WHEN "01",
			     A_Vj(30 DOWNTO 0) & '0' WHEN "10",
			     TMP_A_V WHEN OTHERS;
			  
	WITH L_Op SELECT
	TMP_L_V <= L_Vj AND L_Vk WHEN "00",
			     L_Vj OR L_Vk WHEN "01",
			     NOT L_Vj WHEN "10",
			     TMP_L_V WHEN OTHERS;
	
	A0_V<=TMP_A_V;
	L0_V<=TMP_L_V;
	
end Behavioral;

