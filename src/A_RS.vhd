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
-- Revision:                  0.01
-- Revision                   0.01 - File Created
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
           
           --CDB
           CDB_V : in  STD_LOGIC_VECTOR (31 downto 0);
           CDB_Q : in  STD_LOGIC_VECTOR (4 downto 0);
			  
           --TO FU
           A_Ready : out  STD_LOGIC;
           A_Op : out  STD_LOGIC_VECTOR (1 downto 0);
           A_Vj : out  STD_LOGIC_VECTOR (31 downto 0);
           A_Vk : out  STD_LOGIC_VECTOR (31 downto 0);
           A_Tag : out  STD_LOGIC_VECTOR (4 downto 0);
           A_Accepted : in  STD_LOGIC);
end A_RS;

architecture Behavioral of A_RS is


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

component Mux_3x32bits is
    Port ( In1 : in  STD_LOGIC_VECTOR (31 downto 0);
           In2 : in  STD_LOGIC_VECTOR (31 downto 0);
           In3 : in  STD_LOGIC_VECTOR (31 downto 0);
           Sel : in  STD_LOGIC_VECTOR (1 downto 0);
           Outt : out  STD_LOGIC_VECTOR (31 downto 0));
end component;

component Mux_3x5bits is
    Port ( In1 : in  STD_LOGIC_VECTOR (4 downto 0);
           In2 : in  STD_LOGIC_VECTOR (4 downto 0);
           In3 : in  STD_LOGIC_VECTOR (4 downto 0);
           Sel : in  STD_LOGIC_VECTOR (1 downto 0);
           Outt : out  STD_LOGIC_VECTOR (4 downto 0));
end component;

signal A1_Available, A2_Available, A3_Available: STD_LOGIC;
signal A1_Ready, A2_Ready, A3_Ready: STD_LOGIC;

begin

A_Available <= A1_Available OR A2_Available OR A3_Available;
A_Ready <= A1_Ready OR A2_Ready OR A3_Ready;


-- TODO :
--			1) A_Accepted for each Reg based on global 
--			2) AX_ISSUE based on global ISSUE
--			3) Tag Return fix

A1 : Reg_RS 
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
              Accepted  => A_Accepted);
				  
A2 : Reg_RS 
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
              Accepted  => A_Accepted);
				  
A3 : Reg_RS 
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
              Accepted  => A_Accepted);

--Output Mux
Op : Mux_3x5bits		 
    Port map( In1  => A1_Op,
              In2  => A2_Op,
              In3  => A3_Op,
              Sel  => A_Tag(2 downto 0),
              Outt => A_Op); 
				  
Vj : Mux_3x32bits		  
    Port map( In1  => A1_Vj,
              In2  => A2_Vj,
              In3  => A3_Vj,
              Sel  => A_Tag(2 downto 0),
              Outt => A_Vj);
				  
Vk : Mux_3x32bits		  
    Port map( In1  => A1_Vk,
              In2  => A2_Vk,
              In3  => A3_Vk,
              Sel  => A_Tag(2 downto 0),
              Outt => A_Vk);
				  
end Behavioral;

