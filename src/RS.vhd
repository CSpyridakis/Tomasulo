----------------------------------------------------------------------------------
-- Company/University:        Technical University of Crete (TUC) - GR
-- Engineer:                  Spyridakis Christos 
--                            Bellonias Panagiotis
-- 
-- Create Date:               10/24/2018
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

entity RS is
    Port ( CLK : in  STD_LOGIC;
           RST : in  STD_LOGIC;
			  
           --ISSUE
           A_Available : out  STD_LOGIC;	
           L_Available : out  STD_LOGIC;
			  
           ISSUE : in  STD_LOGIC;
           FU_type : in  STD_LOGIC_VECTOR (1 downto 0);
           FOP : in  STD_LOGIC_VECTOR (1 downto 0);
			  
           Vj : in  STD_LOGIC_VECTOR (31 downto 0);
           Qj : in  STD_LOGIC_VECTOR (4 downto 0);
           Vk : in  STD_LOGIC_VECTOR (31 downto 0);
           Qk : in  STD_LOGIC_VECTOR (4 downto 0);
			  
           Tag_Accepted : out  STD_LOGIC_VECTOR (4 downto 0);
           
           --CDB
           CDB_V : in  STD_LOGIC_VECTOR (31 downto 0);
           CDB_Q : in  STD_LOGIC_VECTOR (4 downto 0);
           
           --A_RS to A_FU
           A_Ready : out  STD_LOGIC;
           A_Op : out  STD_LOGIC_VECTOR (1 downto 0);
           A_Vj : out  STD_LOGIC_VECTOR (31 downto 0);
           A_Vk : out  STD_LOGIC_VECTOR (31 downto 0);
           A_Tag : out  STD_LOGIC_VECTOR (4 downto 0);
           A_Accepted : in  STD_LOGIC_VECTOR (4 downto 0);

           --L_RS to L_FU
           L_Ready : in  STD_LOGIC;
           L_Op : out  STD_LOGIC_VECTOR (1 downto 0);
           L_Vj : out  STD_LOGIC_VECTOR (31 downto 0);
           L_Vk : out  STD_LOGIC_VECTOR (31 downto 0);
           L_Tag : out  STD_LOGIC_VECTOR (4 downto 0);
           L_Accepted : in  STD_LOGIC_VECTOR (4 downto 0));

end RS;

architecture Behavioral of RS is


component A_RS is
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
           A_Accepted : in  STD_LOGIC_VECTOR (4 downto 0));
end component;

component L_RS is
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
           L_Accepted : in  STD_LOGIC_VECTOR (4 downto 0));
end component ;

signal A_Issue, L_Issue : STD_LOGIC;				

begin

A_Issue <= '1' WHEN ISSUE = '1' AND FU_type="01" ELSE '0';

L_Issue <= '1' WHEN ISSUE = '1' AND FU_type="00" ELSE '0';
			  
A_RS : A_RS 
    Port map( CLK 		  => CLK,
              RST 		  => RST,
              A_Available => A_Available,
              ISSUE       => A_Issue,
              FOP 		  => FOP,
              Vj          => Vj,
              Qj          => Qj,
              Vk          => Vk,
              Qk          => Qk,
              CDB_V  	  => CDB_V,
              CDB_Q  	  => CDB_Q,
              A_Ready 	  => A_Ready,
              A_Op 		  => A_Op,
              A_Vj        => A_Vj,
              A_Vk        => A_Vk,
              A_Tag  	  => A_Tag,
              A_Accepted  => A_Accepted);

L_RS : L_RS 
    Port map( CLK 		  => CLK,
              RST 		  => RST,
              L_Available => L_Available,
              ISSUE       => L_Issue,
              FOP 		  => FOP,
              Vj          => Vj,
              Qj          => Qj,
              Vk          => Vk,
              Qk          => Qk,
              CDB_V  	  => CDB_V,
              CDB_Q  	  => CDB_Q,
              L_Ready 	  => L_Ready,
              L_Op 		  => L_Op,
              L_Vj        => L_Vj,
              L_Vk        => L_Vk,
              L_Tag  	  => L_Tag,
              L_Accepted  => L_Accepted);
				  
end Behavioral;

