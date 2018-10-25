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
-- Revision:                  0.01
-- Revision                   0.01 - File Created
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
           
           --CDB
           CDB_V : in  STD_LOGIC_VECTOR (31 downto 0);
           CDB_Q : in  STD_LOGIC_VECTOR (4 downto 0);
			  
           --TO FU
           L_Ready : out  STD_LOGIC;
           L_Op : out  STD_LOGIC_VECTOR (1 downto 0);
           L_Vj : out  STD_LOGIC_VECTOR (31 downto 0);
           L_Vk : out  STD_LOGIC_VECTOR (31 downto 0);
           L_Tag : out  STD_LOGIC_VECTOR (4 downto 0);
           L_Accepted : in  STD_LOGIC);
end L_RS ;

architecture Behavioral of L_RS  is

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

signal L1_Available, L2_Available: STD_LOGIC;
signal L1_Ready, L2_Ready: STD_LOGIC;

begin

L_Available <= L1_Available OR L2_Available;
L_Ready <= L1_Ready OR L2_Ready;

L1 : Reg_RS 
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
              Accepted  => L_Accepted);
				  
L2 : Reg_RS 
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
              Accepted  => A_Accepted);

--Output Mux
Op : Mux_3x5bits		  
    Port map( In1  => L1_Op,
              In2  => L2_Op,
              In3  => "00",
              Sel  => L_Tag(2 downto 0),
              Outt => L_Op);
				  
Vj : Mux_3x32bits		  
    Port map( In1  => L1_Vj,
              In2  => L2_Vj,
              In3  => "00000000000000000000000000000000",
              Sel  => L_Tag(2 downto 0),
              Outt => L_Vj);
				  
Vk : Mux_3x32bits		  
    Port map( In1  => L1_Vk,
              In2  => L2_Vk,
              In3  => "00000000000000000000000000000000",
              Sel  => L_Tag(2 downto 0),
              Outt => L_Vk);
  
end Behavioral;
