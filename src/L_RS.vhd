----------------------------------------------------------------------------------
-- Company/University:        Technical University of Crete (TUC) - GR
-- Engineer:                  Spyridakis Christos 
--                            Bellonias Panagiotis
-- 
-- Create Date:                
-- Design Name: 	 
-- Module Name:               L_RS - Behavioral 
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

entity L_RS is
    Port ( CLK : in  STD_LOGIC;
           RST : in  STD_LOGIC;
			  
           L_Available : out  STD_LOGIC;
			  
           --ISSUE
           ISSUE : in  STD_LOGIC;
           FOP : in  STD_LOGIC_VECTOR (1 downto 0);
           Vj : in  STD_LOGIC_VECTOR (31 downto 0);
           Qj : in  STD_LOGIC_VECTOR (4 downto 0);
           Vk : in  STD_LOGIC_VECTOR (31 downto 0);
           Qk : in  STD_LOGIC_VECTOR (4 downto 0);
           L_Tag_Accepted : out STD_LOGIC_VECTOR (4 downto 0);
				
           --CDB
           CDB_V : in  STD_LOGIC_VECTOR (31 downto 0);
           CDB_Q : in  STD_LOGIC_VECTOR (4 downto 0);
			  
           --TO FU
           L_Ready : out  STD_LOGIC;
           L_Op : out  STD_LOGIC_VECTOR (1 downto 0);
           L_Vj : out  STD_LOGIC_VECTOR (31 downto 0);
           L_Vk : out  STD_LOGIC_VECTOR (31 downto 0);
           L_Tag : out  STD_LOGIC_VECTOR (4 downto 0);
           L_Accepted : in  STD_LOGIC_VECTOR (4 downto 0));
end L_RS ;

architecture Behavioral of L_RS  is

-- Data, Tag, Available and Ready registers exist here
component Reg_RS is
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
           
           --RS
           Ready : out  STD_LOGIC;
           Op : out  STD_LOGIC_VECTOR (1 downto 0);
           Tag : out  STD_LOGIC_VECTOR (4 downto 0);
           Vj : out  STD_LOGIC_VECTOR (31 downto 0);
           Vk : out  STD_LOGIC_VECTOR (31 downto 0);
           Accepted : in  STD_LOGIC);
end component;

-- MUX for output data signals selection 
component Mux_3x32bits is
    Port ( In1 : in  STD_LOGIC_VECTOR (31 downto 0);
           In2 : in  STD_LOGIC_VECTOR (31 downto 0);
           In3 : in  STD_LOGIC_VECTOR (31 downto 0);
           Sel : in  STD_LOGIC_VECTOR (1 downto 0);
           Outt : out  STD_LOGIC_VECTOR (31 downto 0));
end component;

-- MUX for output opcode signal selection
component Mux_3x2bits is
    Port ( In1 : in  STD_LOGIC_VECTOR (1 downto 0);
           In2 : in  STD_LOGIC_VECTOR (1 downto 0);
           In3 : in  STD_LOGIC_VECTOR (1 downto 0);
           Sel : in  STD_LOGIC_VECTOR (1 downto 0);
           Outt : out  STD_LOGIC_VECTOR (1 downto 0));
end component;

signal L1_Available, L2_Available: STD_LOGIC;
signal L1_Ready, L2_Ready: STD_LOGIC;
signal L1_Accepted, L2_Accepted: STD_LOGIC;
signal L1_ISSUE, L2_ISSUE: STD_LOGIC;
signal L_TagS, L1_Tag, L2_Tag: STD_LOGIC_VECTOR (4 downto 0);
signal L1_Op, L2_Op : STD_LOGIC_VECTOR (1 downto 0);
signal L1_Vj, L1_Vk, L2_Vj, L2_Vk: STD_LOGIC_VECTOR (31 downto 0);

TYPE LastAcceptedCases IS (NONE, L1, L2);  
SIGNAL Last : LastAcceptedCases := NONE;

begin

-- Accepted From FU RS Ready bit update
L1_Accepted <= '1' WHEN L_Accepted="00001" ELSE '0';
L2_Accepted <= '1' WHEN L_Accepted="00010" ELSE '0';

L_Tag <= L_TagS;

-- RS ISSUE
PROCESS(CLK, ISSUE, L1_Available, L2_Available)
BEGIN
		L_Available <= L1_Available OR L2_Available;
		L_Ready <= L1_Ready OR L2_Ready;
		
		IF (ISSUE='1' AND L1_Available='1' AND CLK='0' ) THEN                             -- IF L_RS1 is available will accept next instruction
			L1_ISSUE <= '1';
			L2_ISSUE <= '0';
			L_Tag_Accepted <= "00001";
		ELSIF (ISSUE='1' AND L1_Available='0' AND L2_Available='1' AND CLK='0') THEN      -- IF L_RS2 is available will accept next instruction
			L1_ISSUE <= '0';
			L2_ISSUE <= '1';
			L_Tag_Accepted <= "00010";
		ELSE
			L1_ISSUE <= '0';
			L2_ISSUE <= '0';
			L_Tag_Accepted <= "00000";
		END IF;
END PROCESS;

-- Select Which Ready RS forward to FU (Round Robin Selection)
PROCESS(L1_Ready, L2_Ready)
BEGIN
	IF (L1_Ready='1' AND (Last=None OR Last=L2)) THEN
		Last<=L1;
		L_TagS<=L1_Tag;
	ELSIF(L2_Ready='1' AND (Last=None OR Last=L1)) THEN
		Last<=L2;
		L_TagS<=L2_Tag;
	ELSE
		Last<=Last;
		L_TagS<="00000";
	END IF;
END PROCESS;

L1_R : Reg_RS 
    Port map( CLK       => CLK,
              RST       => RST,
              ID        => "00001",
              Available => L1_Available,
              ISSUE     => L1_ISSUE,
              Op_ISSUE  => FOP,
              Vj_ISSUE  => Vj,
              Qj        => Qj,
              Vk_ISSUE  => Vk,
              Qk        => Qk,
              CDB_V     => CDB_V,
              CDB_Q     => CDB_Q,
              Ready     => L1_Ready,
              Op        => L1_Op,
              Tag       => L1_Tag,
              Vj        => L1_Vj,
              Vk        => L1_Vk,
              Accepted  => L1_Accepted);
				  
L2_R : Reg_RS 
    Port map( CLK       => CLK,
              RST       => RST,
              ID        => "00010",
              Available => L2_Available,
              ISSUE     => L2_ISSUE,
              Op_ISSUE  => FOP,
              Vj_ISSUE  => Vj,
              Qj        => Qj,
              Vk_ISSUE  => Vk,
              Qk        => Qk,
              CDB_V     => CDB_V,
              CDB_Q     => CDB_Q,
              Ready     => L2_Ready,
              Op        => L2_Op,
              Tag       => L2_Tag,
              Vj        => L2_Vj,
              Vk        => L2_Vk,
              Accepted  => L2_Accepted);

--Output Mux
Op_M : Mux_3x2bits		  
    Port map( In1  => L1_Op,
              In2  => L2_Op,
              In3  => "00",
              Sel  => L_TagS(1 downto 0),
              Outt => L_Op);
				  
Vj_M : Mux_3x32bits		  
    Port map( In1  => L1_Vj,
              In2  => L2_Vj,
              In3  => "00000000000000000000000000000000",
              Sel  => L_TagS(1 downto 0),
              Outt => L_Vj);
				  
Vk_M : Mux_3x32bits		  
    Port map( In1  => L1_Vk,
              In2  => L2_Vk,
              In3  => "00000000000000000000000000000000",
              Sel  => L_TagS(1 downto 0),
              Outt => L_Vk);
  
end Behavioral;

