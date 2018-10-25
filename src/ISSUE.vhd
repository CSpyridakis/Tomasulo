----------------------------------------------------------------------------------
-- Company/University:        Technical University of Crete (TUC) - GR
-- Engineer:                  Spyridakis Christos 
--                            Bellonias Panagiotis
-- 
-- Create Date:               10/25/2018
-- Design Name: 	 
-- Module Name:               RS - Behavioral 
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
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity ISSUE is
    Port ( CLK : in  STD_LOGIC;
           CLK_O : out  STD_LOGIC;
			  
			  RST : in  STD_LOGIC;
			  RST_O : out  STD_LOGIC;
			  
           A_Available : in  STD_LOGIC;
			  L_Available : in  STD_LOGIC;
			  
           Issue_I : in  STD_LOGIC;
           Issue_O : out  STD_LOGIC;
           
			  Fu_type : in  STD_LOGIC_VECTOR (1 downto 0);
           Fu_type_O : out  STD_LOGIC_VECTOR (1 downto 0);
           
			  FOP : in  STD_LOGIC_VECTOR (1 downto 0);
			  FOP_O : out  STD_LOGIC_VECTOR (1 downto 0);
           
			  Tag_Accapted : in  STD_LOGIC_VECTOR (4 downto 0);
           Tag_Accapted_O : out  STD_LOGIC_VECTOR (4 downto 0);
           
			  Tag_WE : out  STD_LOGIC;
           Accepted : out  STD_LOGIC);
end ISSUE;

architecture Behavioral of ISSUE is

signal ACCE : STD_LOGIC;

begin
     CLK_O <= CLK;
     RST_O <= RST;
	  
     Issue_O <= Issue_I;
     Fu_type_O <= Fu_type;
     FOP_O <= FOP;
     
	  Tag_Accapted_O <= Tag_Accapted;
	  
	  ACCE <= '1' WHEN A_Available='1' AND Issue_I='1' AND Fu_type="01" ELSE
             '1' WHEN L_Available='1' AND Issue_I='1' AND Fu_type="00" ELSE
             '0';
				 
     Tag_WE <= ACCE ;
     Accepted <= ACCE;
end Behavioral;

