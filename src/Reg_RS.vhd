----------------------------------------------------------------------------------
-- Company/University:        Technical University of Crete (TUC) - GR
-- Engineer:                  Spyridakis Christos 
--                            Bellonias Panagiotis
-- 
-- Create Date:                
-- Design Name: 	 
-- Module Name:               Reg_RS - Behavioral 
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

entity Reg_RS is
    Port ( CLK : in  STD_LOGIC;
           RST : in  STD_LOGIC;
			  
           ID : in  STD_LOGIC_VECTOR (4 downto 0);
           Available : out  STD_LOGIC;
			  
           --ISSUE
           ISSUE : in  STD_LOGIC;
           Op_ISSUE : in  STD_LOGIC_VECTOR (1 downto 0);
           Vj_ISSUE : in  STD_LOGIC_VECTOR (31 downto 0);
           Qj : in  STD_LOGIC_VECTOR (4 downto 0);
           Vk_ISSUE : in  STD_LOGIC_VECTOR (31 downto 0);
           Qk : in  STD_LOGIC_VECTOR (4 downto 0);
			  
           --CDB
           CDB_V : in  STD_LOGIC_VECTOR (31 downto 0);
           CDB_Q : in  STD_LOGIC_VECTOR (4 downto 0);
           
           Ready : out  STD_LOGIC;
           Op : out  STD_LOGIC_VECTOR (1 downto 0);
           Tag : out  STD_LOGIC_VECTOR (4 downto 0);
           Vj : out  STD_LOGIC_VECTOR (31 downto 0);
           Vk : out  STD_LOGIC_VECTOR (31 downto 0);
           Accepted : in  STD_LOGIC);
end Reg_RS;

architecture Behavioral of Reg_RS is


component Reg_1bit is
    Port ( CLK  : in  STD_LOGIC;
           RST  : in  STD_LOGIC;
           EN   : in  STD_LOGIC;
           INN  : in  STD_LOGIC;
           OUTT : out  STD_LOGIC);
end component;

component Reg_V_Q is
    Port ( CLK : in  STD_LOGIC;
           RST : in  STD_LOGIC;
           EN : in  STD_LOGIC;
           VIN : in  STD_LOGIC_VECTOR (31 downto 0);
           QIN : in  STD_LOGIC_VECTOR (4 downto 0);
           VOUT : out  STD_LOGIC_VECTOR (31 downto 0);
           QOUT : out  STD_LOGIC_VECTOR (4 downto 0));
end component;			  
			  
component Mux_2x32bits is
    Port ( In0 : in  STD_LOGIC_VECTOR (31 downto 0);
           In1 : in  STD_LOGIC_VECTOR (31 downto 0);
           Sel : in  STD_LOGIC;
           Outt : out  STD_LOGIC_VECTOR (31 downto 0));
end component;

component Mux_2x5bits is
    Port ( In0 : in  STD_LOGIC_VECTOR (4 downto 0);
           In1 : in  STD_LOGIC_VECTOR (4 downto 0);
           Sel : in  STD_LOGIC;
           Outt : out  STD_LOGIC_VECTOR (4 downto 0));
end component;

--Tmp Arithmetic and Logical Pipeline Signals
signal  Avail, Av_RST, Av_EN, J_RST, J_EN, K_RST, K_EN, Re_RST, Re_EN : STD_LOGIC;							
signal  J_Vin, K_Vin: STD_LOGIC_VECTOR (31 downto 0);
signal  J_Qin, J_Q, K_Qin, K_Q: STD_LOGIC_VECTOR (4 downto 0);

type states is (ResetS, AvailableS, IssueS, L_MatchS, R_MatchS, ReadyS, ExecutingS);
signal State: states := AvailableS;

begin

	---------------------------------------------------------- Reservation Station CONTROL
	--Resets
	Av_RST <= '1' WHEN STATE=ResetS ELSE	--System RST
	          '0';
	
	Re_RST <= '1' WHEN STATE=ResetS ELSE	--System RST
	          '0';
	
	J_RST <= '1' WHEN STATE=ResetS ELSE	--System RST
	         '0';
	
	K_RST <= '1' WHEN STATE=ResetS ELSE	--System RST
	         '0';

	--Enables
	Av_EN <= '1' WHEN STATE=IssueS ELSE	--ISSUE
	         '0';
	
	J_EN <= '1' WHEN STATE=IssueS ELSE	--ISSUE
	        '0';
	
	K_EN <= '1' WHEN STATE=IssueS ELSE	--ISSUE
	        '0';
	
	Re_EN<='0';
		
	---------------------------------------------------------- Reservation Station FSM			  
	PROCESS(CLK, RST, STATE, J_Q, K_Q)
	BEGIN
		IF (rising_edge(CLK)) THEN
			IF (RST='1') THEN                 --RST
	         STATE <= ResetS;
			ELSIF (STATE=ResetS) THEN               
				STATE <= AvailableS;
			ELSIF (ISSUE='1' AND STATE=AvailableS) THEN
				STATE <= IssueS;
			END IF;
			IF (J_Q="00000" AND K_Q="00000") THEN
				STATE <=ReadyS;
			END IF;
		END IF;
	END PROCESS;
	
	---------------------------------------------------------- Reservation Station Available + Ready Registers
	AvailableR : Reg_1bit 
		 Port map( CLK  => CLK,
					  RST  => Av_RST,
					  EN   => Av_EN,
					  INN  => '1',
					  OUTT => Avail);
	Available <= Avail;

	ReadyR : Reg_1bit 
		 Port map( CLK  => CLK,
					  RST  => Re_RST,
					  EN   => Re_EN,
					  INN  => '1',
					  OUTT => Ready);	

	Tag<=ID;
				  
	---------------------------------------------------------- Reservation Station Data and Tag for J
	Vj_In : Mux_2x32bits 
		 Port map( In0  => CDB_V,
					  In1  => Vj_ISSUE,
					  Sel  => Avail,
					  Outt => J_Vin);

	Qj_In : Mux_2x5bits 
		 Port map( In0  => "00000",
					  In1  => Qj,
					  Sel  => Avail,
					  Outt => J_Qin);	
					  
	J : Reg_V_Q
		 Port map( CLK  => CLK,
					  RST  => J_RST,
					  EN   => J_EN,
					  VIN  => J_Vin,
					  QIN  => J_Qin,
					  VOUT => Vj,
					  QOUT => J_Q);
					  
	---------------------------------------------------------- Reservation Station Data and Tag for K				  
	Vk_In : Mux_2x32bits 
		 Port map( In0  => CDB_V,
					  In1  => Vk_ISSUE,
					  Sel  => Avail,
					  Outt => K_Vin);

	Qk_In : Mux_2x5bits 
		 Port map( In0  => "00000",
					  In1  => Qk,
					  Sel  => Avail,
					  Outt => K_Qin);				  
	K : Reg_V_Q
		 Port map( CLK  => CLK,
					  RST  => K_RST,
					  EN   => K_EN,
					  VIN  => K_Vin,
					  QIN  => K_Qin,
					  VOUT => Vk,
					  QOUT => K_Q); 
					  	
end Behavioral;

