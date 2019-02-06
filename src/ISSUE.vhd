----------------------------------------------------------------------------------
-- Company/University:        Technical University of Crete (TUC) - GR
-- Engineer:                  Spyridakis Christos 
--                            Bellonias Panagiotis
-- 
-- Create Date:               10/25/2018
-- Design Name: 	 
-- Module Name:               ISSUE - Behavioral 
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

entity ISSUE is
    Port ( CLK : in  STD_LOGIC;
           A_Available : in  STD_LOGIC;
           L_Available : in  STD_LOGIC;
           Issue_I : in  STD_LOGIC;
           Fu_type : in  STD_LOGIC_VECTOR (1 downto 0);
           Tag_WE : out  STD_LOGIC;
           Accepted : out  STD_LOGIC);
end ISSUE;

architecture Behavioral of ISSUE is

signal ACCE : STD_LOGIC;

begin
	 process (CLK)
	 begin
		if (falling_edge(CLK)) then
			-- Issue Arithmetical Instruction AND available Arithmetical RS
			if A_Available='1' AND Issue_I='1' AND Fu_type="01" then     
				ACCE<='1';
			-- Issue Logical Instruction AND available Logical RS
			elsif L_Available='1' AND Issue_I='1' AND Fu_type="00" then  
			    ACCE<='1';
			else
			    ACCE<='0';
			end if;
		end if;
	 end process;
 
    Tag_WE <= ACCE ;
    Accepted <= ACCE;
end Behavioral;

