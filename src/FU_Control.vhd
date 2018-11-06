----------------------------------------------------------------------------------
-- Company/University:        Technical University of Crete (TUC) - GR
-- Engineer:                  Spyridakis Christos 
--                            Bellonias Panagiotis
-- 
-- Create Date:               10/22/2018
-- Design Name: 	 
-- Module Name:               FU_Control - Behavioral 
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

entity FU_Control is
    Port ( CLK : in  STD_LOGIC;
           A_Ready : in  STD_LOGIC;
           A_Tag : in  STD_LOGIC_VECTOR (4 downto 0);
           A1_Q : in  STD_LOGIC_VECTOR (4 downto 0);
           A2_Q : in  STD_LOGIC_VECTOR (4 downto 0);
           A3_Q : in  STD_LOGIC_VECTOR (4 downto 0);
           A_Accepted : out  STD_LOGIC_VECTOR (4 downto 0);
           A_Request : out  STD_LOGIC;
           A_Grant : in  STD_LOGIC;
           A1_EN : out  STD_LOGIC;
           A2_EN : out  STD_LOGIC;
           A3_EN : out  STD_LOGIC;
			  
           L_Ready : in  STD_LOGIC;
           L_Tag : in  STD_LOGIC_VECTOR (4 downto 0);
           L1_Q : in  STD_LOGIC_VECTOR (4 downto 0);
           L2_Q : in  STD_LOGIC_VECTOR (4 downto 0);
           L_Accepted : out  STD_LOGIC_VECTOR (4 downto 0);
           L_Request : out  STD_LOGIC;
           L_Grant : in  STD_LOGIC;
           L1_EN : out  STD_LOGIC;
           L2_EN : out  STD_LOGIC);
end FU_Control;

architecture Behavioral of FU_Control is

--Arithmetic and logical pipeline levels Empty state
signal A1_EMPTY, A2_EMPTY, A3_EMPTY, L1_EMPTY, L2_EMPTY : STD_LOGIC;	
BEGIN

	--Arithmetic and logical pipeline levels Empty state Condition
	A1_EMPTY <= '0' WHEN A1_Q(4)='1' OR A1_Q(3)='1' OR A1_Q(2)='1' OR A1_Q(1)='1' OR A1_Q(0)= '1' ELSE '1';			
	A2_EMPTY <= '0' WHEN A2_Q(4)='1' OR A2_Q(3)='1' OR A2_Q(2)='1' OR A2_Q(1)='1' OR A2_Q(0)= '1' ELSE '1';			
	A3_EMPTY <= '0' WHEN A3_Q(4)='1' OR A3_Q(3)='1' OR A3_Q(2)='1' OR A3_Q(1)='1' OR A3_Q(0)= '1' ELSE '1';			
	L1_EMPTY <= '0' WHEN L1_Q(4)='1' OR L1_Q(3)='1' OR L1_Q(2)='1' OR L1_Q(1)='1' OR L1_Q(0)= '1' ELSE '1';			
	L2_EMPTY <= '0' WHEN L2_Q(4)='1' OR L2_Q(3)='1' OR L2_Q(2)='1' OR L2_Q(1)='1' OR L2_Q(0)= '1' ELSE '1';

   PROCESS(CLK, A1_EMPTY, A2_EMPTY, A3_EMPTY, L1_EMPTY, L2_EMPTY, A_Grant, A_Ready, L_Grant, L_Ready)
	BEGIN
		IF (falling_edge(CLK)) THEN																						-- TODO 
			-------------------------------------------------------------------------------------------- X_Accept
			--Arithmetic 
			IF (A_Ready='1' AND (A_Grant='1' OR (A1_EMPTY='1' OR A2_EMPTY='1' OR A3_EMPTY='1'))) THEN	
				A_Accepted <= A_Tag;
			ELSE
				A_Accepted <= "00000";
			END IF;
			
			--Logical 
			IF (L_Ready='1' AND (L_Grant='1' OR (L1_EMPTY='1' OR L2_EMPTY='1')))THEN	
				L_Accepted <= L_Tag;
			ELSE
				L_Accepted <= "00000";
			END IF;
			
			-------------------------------------------------------------------------------------------- X_Request
			--Arithmetic 
			IF (A2_EMPTY='0' OR A3_EMPTY='0') THEN		
				A_Request <= '1' ;
			ELSE
				A_Request <= '0' ;
			END IF;
			
			--Logical 
			IF (L1_EMPTY='0' OR L2_EMPTY='0') THEN		
				L_Request <= '1' ;
			ELSE
				L_Request <= '0' ;
			END IF;
			
			-------------------------------------------------------------------------------------------- Enables
			--A1_EN
			IF (A_Ready='1' AND (A1_EMPTY='1' OR A2_EMPTY='1' OR A3_EMPTY='1' OR A_Grant='1')) THEN	                   -- New Arithmetic Operation with at least one empty Level OR New Arithmetic Operation with none enpty Level and A is Granted
				A1_EN <= '1';
			ELSIF (A_Ready='0' AND A1_EMPTY='0' AND (A2_EMPTY='1' OR A3_EMPTY='1' OR A_Grant='1')) THEN	               -- No new Operation. Forward valid data [1] -> [0/1] -> [0/1] ONLY if it is possible
				A1_EN <= '1';                                                                                          --                                       A1      A2       A3
			ELSE
				A1_EN <= '0';
			END IF;
			
			--A2_EN	                                                                                                        A1     A2     A3
			IF (A1_EMPTY='0' AND A2_EMPTY='1') THEN                                                                     --  [1] -> [0] -> [X]
				A2_EN <= '1';
			ELSIF	(A2_EMPTY='0' AND A3_EMPTY='1') THEN                                                                --  [X] -> [1] -> [0]
				A2_EN <= '1';
			ELSIF	(A2_EMPTY='0' AND A3_EMPTY='0' AND A_Grant='1') THEN                                                --  [X] -> [1] -> [1]  AND A is Granted
				A2_EN <= '1'; 
			ELSE 
				A2_EN <= '0';
			END IF;
			
			--A3_EN                                                                                                         A1     A2     A3
			IF (A2_EMPTY='0' AND A3_EMPTY='1') THEN                                                                     --  [X] -> [1] -> [0]
				A3_EN <= '1';
			ELSIF	(A3_EMPTY='0' AND A_Grant='1') THEN                                                                 --  [X] -> [X] -> [1] AND A is Granted
				A3_EN <= '1';
			ELSE 
				A3_EN <= '0';
			END IF;
			
			--L1_EN
			IF (L_Ready='1' AND (L1_EMPTY='1' OR L2_EMPTY='1' OR L_Grant='1')) THEN                                     -- New Logical Operation with at least one empty Level OR New Logica Operation with none enpty Level and L is Granted
				L1_EN <= '1';
			ELSIF (L_Ready='0' AND L1_EMPTY='0' AND (L2_EMPTY='1' OR L_Grant='1')) THEN                                 -- No new Operation. Forward valid data [1] -> [0/1]  ONLY if it is possible
				L1_EN <= '1';                                                                                           --                                       L1      L2 
			ELSE
				L1_EN <= '0';
			END IF;
			
			--L2_EN                                                                                                        L1     L2
			IF (L1_EMPTY='0' AND L2_EMPTY='1') THEN                                                                     -- [1] -> [0]
				L2_EN <= '1';
			ELSIF (L2_EMPTY='0' AND L_Grant='1') THEN                                                                   -- [X] -> [1] AND L is Granted
				L2_EN <= '1';
			ELSE
				L2_EN <= '0';
			END IF;
			
		END IF;
   END PROCESS;
END Behavioral;

