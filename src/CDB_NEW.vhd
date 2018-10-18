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
-- Additional Comments: 
--
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity CDB is
    Port ( AR_REQ : in  STD_LOGIC;
           AR_D : in  STD_LOGIC_VECTOR (31 downto 0);
           ARD_Q : in  STD_LOGIC_VECTOR (3 downto 0);
           L_REQ : in  STD_LOGIC;
           L_D : in  STD_LOGIC_VECTOR (31 downto 0);
           LRD_Q : in  STD_LOGIC_VECTOR (3 downto 0);
           RST : in  STD_LOGIC;
           CLK : in  STD_LOGIC;
           GRANTED : out  STD_LOGIC_VECTOR (1 downto 0);
           CDB_V : out  STD_LOGIC_VECTOR (31 downto 0);
           CDB_Q : out  STD_LOGIC_VECTOR (3 downto 0));
end CDB;

architecture Behavioral of CDB is
	signal LAST : STD_LOGIC_VECTOR (1 DOWNTO 0) := "01";
   signal CDB_GRANTED, OUTPUT : STD_LOGIC_VECTOR (1 DOWNTO 0) := "11";
begin
	process
    begin
        wait until(CLK'EVENT and CLK = '1');
        
        if(RST='1') then
            CDB_GRANTED <= "11"; --CDB OFF
            LAST <= "01";	 -- Proteraiotita se logical	
        elsif(AR_REQ = '1' and L_REQ = '1')then
            if(LAST="01")then -- Paw logical
                CDB_GRANTED <= "00";
                LAST <= "00";		
            else
                CDB_GRANTED <= "01";
                LAST <= "01";	
            end if;
        elsif(AR_REQ = '1')then
            CDB_GRANTED <= "01";
            LAST <= "01";		
        elsif(L_REQ = '1')then
            CDB_GRANTED <= "00";
            LAST <= "00";		
        else       
            CDB_GRANTED <= "11";
        end if;        
        
    end process;
	
	OUTPUT <= CDB_GRANTED;
	
	GRANTED <= CDB_GRANTED;
	
	CDB_V <= 	AR_D WHEN OUTPUT = "01" ELSE
			L_D WHEN OUTPUT = "00" ELSE
			(OTHERS => '0');
				
	CDB_Q <=	ARD_Q WHEN OUTPUT = "01" ELSE
			LRD_Q WHEN OUTPUT = "00" ELSE
			(OTHERS => '1');
 


end Behavioral;

