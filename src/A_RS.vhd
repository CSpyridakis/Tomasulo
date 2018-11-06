----------------------------------------------------------------------------------
-- Company/University:        Technical University of Crete (TUC) - GR
-- Engineer:                  Spyridakis Christos 
--                            Bellonias Panagiotis
-- 
-- Create Date:                
-- Design Name: 	 
-- Module Name:               A_RS - Behavioral 
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

entity A_RS is
    Port ( CLK : in  STD_LOGIC;
           RST : in  STD_LOGIC;
			  
           A_Available : out  STD_LOGIC;
			  
           --ISSUE
           ISSUE : in  STD_LOGIC;
           FOP : in  STD_LOGIC_VECTOR (1 downto 0);
           Vj : in  STD_LOGIC_VECTOR (31 downto 0);
           Qj : in  STD_LOGIC_VECTOR (4 downto 0);
           Vk : in  STD_LOGIC_VECTOR (31 downto 0);
           Qk : in  STD_LOGIC_VECTOR (4 downto 0);
           A_Tag_Accepted : out STD_LOGIC_VECTOR (4 downto 0);
			  
           --CDB
           CDB_V : in  STD_LOGIC_VECTOR (31 downto 0);
           CDB_Q : in  STD_LOGIC_VECTOR (4 downto 0);
			  
           --TO FU
           A_Ready : out  STD_LOGIC;
           A_Op : out  STD_LOGIC_VECTOR (1 downto 0);
           A_Vj : out  STD_LOGIC_VECTOR (31 downto 0);
           A_Vk : out  STD_LOGIC_VECTOR (31 downto 0);
           A_Tag : out  STD_LOGIC_VECTOR (4 downto 0);
           A_Accepted : in  STD_LOGIC_VECTOR (4 downto 0));
end A_RS;

architecture Behavioral of A_RS is

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

signal A1_Available, A2_Available, A3_Available: STD_LOGIC;
signal A1_Ready, A2_Ready, A3_Ready: STD_LOGIC;
signal A1_Accepted, A2_Accepted, A3_Accepted : STD_LOGIC;
signal A1_ISSUE, A2_ISSUE, A3_ISSUE : STD_LOGIC;
signal A_TagS, A1_Tag, A2_Tag, A3_Tag : STD_LOGIC_VECTOR (4 downto 0);
signal A1_Op, A2_Op, A3_Op : STD_LOGIC_VECTOR (1 downto 0);
signal A1_Vj, A1_Vk, A2_Vj, A2_Vk, A3_Vj, A3_Vk : STD_LOGIC_VECTOR (31 downto 0);

TYPE LastAcceptedCases IS (NONE, A1, A2, A3);  
SIGNAL Last : LastAcceptedCases := NONE;    
  
begin

-- Accepted From FU RS Ready bit update
A1_Accepted <= '1' WHEN A_Accepted="01001" ELSE '0';
A2_Accepted <= '1' WHEN A_Accepted="01010" ELSE '0';
A3_Accepted <= '1' WHEN A_Accepted="01011" ELSE '0';

A_Tag <= A_TagS;

-- RS ISSUE
PROCESS(CLK, ISSUE, A1_Available, A2_Available, A3_Available)
BEGIN
		A_Available <= A1_Available OR A2_Available OR A3_Available;
		A_Ready <= A1_Ready OR A2_Ready OR A3_Ready;
		
		IF (ISSUE='1' AND A1_Available='1' AND CLK='0' ) THEN                                             -- IF A_RS1 is available will accept next instruction
			A1_ISSUE <= '1';
			A2_ISSUE <= '0';
			A3_ISSUE <= '0';
			A_Tag_Accepted <= "01001";
		ELSIF (ISSUE='1' AND A1_Available='0' AND A2_Available='1' AND CLK='0') THEN                      -- IF A_RS2 is available will accept next instruction
			A1_ISSUE <= '0';
			A2_ISSUE <= '1';
			A3_ISSUE <= '0';
			A_Tag_Accepted <= "01010";
		ELSIF (ISSUE='1' AND A1_Available='0' AND A2_Available='0' AND A3_Available='1' AND CLK='0') THEN -- IF A_RS3 is available will accept next instruction
			A1_ISSUE <= '0';
			A2_ISSUE <= '0';
			A3_ISSUE <= '1';
			A_Tag_Accepted <= "01011";
		ELSE
			A1_ISSUE <= '0';
			A2_ISSUE <= '0';
			A3_ISSUE <= '0';
			A_Tag_Accepted <= "00000";
		END IF;
END PROCESS;

-- Select Which Ready RS forward to FU (Round Robin Selection)
PROCESS(A1_Ready, A2_Ready, A3_Ready)
BEGIN
	IF (A1_Ready='1' AND (Last=None OR (Last=A3) OR (Last=A2 AND A3_Ready='0'))) THEN
		Last<=A1;
		A_TagS<=A1_Tag;
	ELSIF(A2_Ready='1' AND (Last=None OR (Last=A1) OR (Last=A3 AND A1_Ready='0'))) THEN
		Last<=A2;
		A_TagS<=A2_Tag;
	ELSIF(A3_Ready='1' AND (Last=None OR (Last=A2) OR (Last=A1 AND A2_Ready='0'))) THEN
		Last<=A3;
		A_TagS<=A3_Tag;
	ELSE
		Last<=Last;
		A_TagS<="00000";
	END IF;
END PROCESS;

A1_R : Reg_RS 
    Port map( CLK       => CLK,
              RST       => RST,
              ID        => "01001",
              Available => A1_Available,
              ISSUE     => A1_ISSUE,
              Op_ISSUE  => FOP,
              Vj_ISSUE  => Vj,
              Qj        => Qj,
              Vk_ISSUE  => Vk,
              Qk        => Qk,
              CDB_V     => CDB_V,
              CDB_Q     => CDB_Q,
              Ready     => A1_Ready,
              Op        => A1_Op,
              Tag       => A1_Tag,
              Vj        => A1_Vj,
              Vk        => A1_Vk,
              Accepted  => A1_Accepted);
				  
A2_R : Reg_RS 
    Port map( CLK       => CLK,
              RST       => RST,
              ID        => "01010",
              Available => A2_Available,
              ISSUE     => A2_ISSUE,
              Op_ISSUE  => FOP,
              Vj_ISSUE  => Vj,
              Qj        => Qj,
              Vk_ISSUE  => Vk,
              Qk        => Qk,
              CDB_V     => CDB_V,
              CDB_Q     => CDB_Q,
              Ready     => A2_Ready,
              Op        => A2_Op,
              Tag       => A2_Tag,
              Vj        => A2_Vj,
              Vk        => A2_Vk,
              Accepted  => A2_Accepted);
				  
A3_R : Reg_RS 
    Port map( CLK       => CLK,
              RST       => RST,
              ID        => "01011",
              Available => A3_Available,
              ISSUE     => A3_ISSUE,
              Op_ISSUE  => FOP,
              Vj_ISSUE  => Vj,
              Qj        => Qj,
              Vk_ISSUE  => Vk,
              Qk        => Qk,
              CDB_V     => CDB_V,
              CDB_Q     => CDB_Q,
              Ready     => A3_Ready,
              Op        => A3_Op,
              Tag       => A3_Tag,
              Vj        => A3_Vj,
              Vk        => A3_Vk,
              Accepted  => A3_Accepted);

--Output Mux
Op_M : Mux_3x2bits		 
    Port map( In1  => A1_Op,
              In2  => A2_Op,
              In3  => A3_Op,
              Sel  => A_TagS(1 downto 0),
              Outt => A_Op); 
				  
Vj_M : Mux_3x32bits		  
    Port map( In1  => A1_Vj,
              In2  => A2_Vj,
              In3  => A3_Vj,
              Sel  => A_TagS(1 downto 0),
              Outt => A_Vj);
				  
Vk_M : Mux_3x32bits		  
    Port map( In1  => A1_Vk,
              In2  => A2_Vk,
              In3  => A3_Vk,
              Sel  => A_TagS(1 downto 0),
              Outt => A_Vk);
				  
end Behavioral;

