----------------------------------------------------------------------------------
-- Company/University:        Technical University of Crete (TUC) - GR
-- Engineer:                  Spyridakis Christos 
--                            Bellonias Panagiotis
-- 
-- Create Date:               10/22/2018
-- Design Name: 	 
-- Module Name:               RF - Behavioral 
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
use IEEE.NUMERIC_STD.ALL;

entity RF is
    Port ( RD : in  STD_LOGIC_VECTOR (4 downto 0);
           RS : in  STD_LOGIC_VECTOR (4 downto 0);
           RT : in  STD_LOGIC_VECTOR (4 downto 0);
           ISSUE_WE : in  STD_LOGIC;
           Q_INSTRCT : in  STD_LOGIC_VECTOR (3 downto 0);
           CDB_Q : in  STD_LOGIC_VECTOR (3 downto 0);
           CDB_V : in  STD_LOGIC_VECTOR (31 downto 0);
           CLK : in  STD_LOGIC;
           RST : in  STD_LOGIC;
           Q_RS : out  STD_LOGIC_VECTOR (3 downto 0);
           Q_RT : out  STD_LOGIC_VECTOR (3 downto 0);
           READ_RS : out  STD_LOGIC_VECTOR (31 downto 0);
           READ_RT : out  STD_LOGIC_VECTOR (31 downto 0));
end RF;

architecture Behavioral of RF is
	type REGISTERS is array(31 downto 0) of STD_LOGIC_VECTOR(31 downto 0);
	signal V : REGISTERS := (others => (others => '0'));
begin
process
	begin
	
		wait until rising_edge(CLK);
		
		if (RST = '1') then
			V <= (others => (others => '0'));
			L_X: for I in 0 to 10 loop 
				V(I) <= STD_LOGIC_VECTOR(to_unsigned(I, V(I)'LENGTH));      
			end loop L_X; 
		else
			if ISSUE_WE = '1' then
				V(to_integer(UNSIGNED(RD))) <= CDB_V;
			end if;			
			if RD = RS then
				READ_RS <= CDB_V;
				Q_RS <= CDB_Q;
			else 
				READ_RS <= V(to_integer(UNSIGNED(RS)));
			end if;			
			if RD = RT THEN
				READ_RT <= CDB_V;
				Q_RT <= CDB_Q;
			else 
				READ_RT <= V(to_integer(UNSIGNED(RT)));
			end if;
		end if;
	
	end process;


end Behavioral;

