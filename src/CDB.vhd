----------------------------------------------------------------------------------
-- Company/University:        Technical University of Crete (TUC) - GR
-- Engineer:                  Spyridakis Christos 
--                            Bellonias Panagiotis
-- 
-- Create Date:               10/22/2018
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
-- Revision:                  1.0
-- Revision                   1.0 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity CDB is
    Port ( RST : in  STD_LOGIC;
           CLK : in  STD_LOGIC;
           A_REQUEST : in  STD_LOGIC;
           A_V : in  STD_LOGIC_VECTOR (31 downto 0);
           A_Q : in  STD_LOGIC_VECTOR (4 downto 0);
           L_REQUEST : in  STD_LOGIC;
           L_V : in  STD_LOGIC_VECTOR (31 downto 0);
           L_Q : in  STD_LOGIC_VECTOR (4 downto 0);
           A_GRAND : out STD_LOGIC;
           L_GRAND : out STD_LOGIC;
           CDB_V : out  STD_LOGIC_VECTOR (31 downto 0);
           CDB_Q : out  STD_LOGIC_VECTOR (4 downto 0));
end CDB;

architecture Behavioral of CDB is
   signal LAST : STD_LOGIC_VECTOR (1 DOWNTO 0) := "01";
   signal CDB_GRANTED, OUTPUT : STD_LOGIC_VECTOR (1 DOWNTO 0) := "00";
begin

process(CLK,RST,A_REQUEST, L_REQUEST)
begin
  IF (rising_edge(CLK)) THEN 
	  if(RST='1') then	
			CDB_GRANTED <= "00"; --CDB OFF
			LAST <= "01";	 -- Proteraiotita se logical	
	  elsif(A_REQUEST = '1' and L_REQUEST = '1')then
			if(LAST="01")then -- Paw logical
				 CDB_GRANTED <= "10";
				 LAST <= "10";		
			else
				 CDB_GRANTED <= "01";
				 LAST <= "01";	
			end if;
	  elsif(A_REQUEST = '1')then
			CDB_GRANTED <= "01";
			LAST <= "01";		
	  elsif(L_REQUEST = '1')then
			CDB_GRANTED <= "10";
			LAST <= "10";		
	  else       
			CDB_GRANTED <= "00";
	  end if;        
  END IF;
end process;
 
OUTPUT  <= CDB_GRANTED;
A_GRAND <= CDB_GRANTED(0);
L_GRAND <= CDB_GRANTED(1);

CDB_V <= A_V WHEN OUTPUT = "01" ELSE
         L_V WHEN OUTPUT = "10" ELSE
         (OTHERS => '0');
 
CDB_Q <= A_Q WHEN OUTPUT = "01" ELSE
         L_Q WHEN OUTPUT = "10" ELSE
         (OTHERS => '0');
end Behavioral;

