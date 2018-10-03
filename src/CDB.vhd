----------------------------------------------------------------------------------
-- Company/University:        Technical University of Crete (TUC) - GR
-- Engineer:                  Spyridakis Christos 
--                            Bellonias Panagiotis
-- 
-- Create Date:                
-- Design Name: 	 
-- Module Name:               CDB - Behavioral  
-- Project Name:              Tomasulo
-- Target Devices:            NONE
-- Tool versions:             Xilinx ISE 14.7 --TODO: VIVADO
-- Description:               Introduction in Dynamic Instruction Scheduling (Advanced Computer Architecture)
--                            implementing Tomasulo's Algorithm 	 
--
-- Dependencies:              NONE
--
-- Revision:                  0.01
-- Revision                   0.01 - File Created
-- Additional Comments:       Common Data Bus implementation (CDB)


----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity CDB is
    Port ( CDB_V : out  STD_LOGIC_VECTOR (31 downto 0);
           CDB_Q : out  STD_LOGIC_VECTOR (4 downto 0);
			  
			  --Arithmetic
			  RA : in  STD_LOGIC;
           AV : in  STD_LOGIC_VECTOR (31 downto 0);
           AQ : in  STD_LOGIC_VECTOR (4 downto 0);
			  GA : out  STD_LOGIC;
			  
			  --Logical
			  RL : in  STD_LOGIC;
           LV : in  STD_LOGIC_VECTOR (31 downto 0);
           LQ : in  STD_LOGIC_VECTOR (4 downto 0);
			  GL : out  STD_LOGIC;
			  
			  --Memory
			  RM : in  STD_LOGIC;	
           MV : in  STD_LOGIC_VECTOR (31 downto 0);
           MQ : in  STD_LOGIC_VECTOR (4 downto 0);
			  GM : out  STD_LOGIC);
end CDB;

architecture Behavioral of CDB is

begin


end Behavioral;

