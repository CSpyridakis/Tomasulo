----------------------------------------------------------------------------------
-- Company/University:        Technical University of Crete (TUC) - GR
-- Engineer:                  Spyridakis Christos 
--                            Bellonias Panagiotis
-- 
-- Create Date:                
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
-- Additional Comments:       Resirvation Stations (RS) implementation
--                     
--
--                                          ABSTRACT: I/O Connections    
--               
--                                                     RS                                            
--                            ++ ------------------------------------------- ++    L_Q       + ---------- + 
--                            ||                                             || -----------> |            |
--                            ||                                             ||              |    Logic   |                       
--   + ------- +              ||                                             ||    L_Vk      |            |
--   |         |  L_Available ||        + ------------------------- +        || -----------> |            | 
--   |         | <----------- ||        | Qk  |   Vk  | Qj  |  Vj   |        ||              |     FU     |   
--   |         |              ||        + --- + ----- + --- + ----- +        ||    L_Vj      |            |                       
--   |    I    |              ||      L1|  5  |   3   |  5  |   3   |        || -----------> |            |                 
--   |    S    |              ||      L2|     |   2   |     |   2   |        ||              + ---------- + 
--   |    S    |              ||        |     |       |     |       |        ||  
--   |    U    |              ||        |  b  |   b   |  n  |   b   |        ||    A_Q       + ---------- +
--   |    E    |              ||      A1|  i  |   i   |  i  |   i   |        || -----------> |            |
--   |         |  A_Available ||      A2|  t  |   t   |  t  |   t   |        ||              | Arithmetic |
--   |         | <----------- ||      A3|  s  |   s   |  s  |   s   |        ||    A_Vk      |            |
--   + ------- +              ||        + ------------------------- +        || -----------> |            |
--       ||                   ||                                             ||              |     FU     |
--       ||                   ||                                             ||    A_Vj      |            | 
--       ||                   ||                                             || -----------> |            |
--       ||                   ++ ------------------------------------------- ++              + ---------- +                         
--       ||                              					              
--       ||                     /\   /\   /\   /\     ||         /\        /\
--       ||                     ||   ||   ||   ||     ||         ||        ||
--       ||                   Vk|| Qk|| Vj|| Qj|| Q_WB||         || CDB_V  || CDB_Q
--       ||                     ||   ||   ||   ||     ||         ||        ||
--       ||                     ||   ||   ||   ||     \/         ||        ||                
--       ||                  + ------------------------- +    + --------------- + 
--       ||                  |                           |    |                 |
--       ||                  |                           |    |                 |
--        \\_______________\ |             RF            |    |       CDB       |
--         --------------- / |                           |    |                 |
--             K, J, R       |                           |    |                 |
--                           + ------------------------- +    + --------------- +
--
--
--
-- + ---------------- +
-- |    RS ENCODING   |
-- + ----- + -------- +
-- |   A1  |  00 001  |
-- |   A2  |  00 010  |
-- |   A3  |  00 100  |
-- | ----- + -------- |
-- |   F1  |  01 001  |
-- |   F2  |  01 010  |
-- | ----- + -------- |
-- |  RST  |  10 000  |
-- | READY |  11 000  |
-- + ----- + -------- +
--
----------------------------------------------------------------------------------

-- TODO LIST:
--     * Enables 
--     * Q & V Inputs

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity RS is
    Port ( CLK  : in  STD_LOGIC;
           RST  : in  STD_LOGIC;
			  
	        --PHASE 1 (RS REGISTERS IN - Parallel steps - TOTAL time: 1 CC) 
			  --If RS is Available (step 1) accept next instruction (step 2) and rename RF register using TAG (step 3)
			  
			  L_Available : out  STD_LOGIC;                      --Step 1: RS Ready 
           A_Available : out  STD_LOGIC;

			  Vk : in  STD_LOGIC_VECTOR (31 downto 0);           --Step 2: Accept instruction
			  Qk : in  STD_LOGIC_VECTOR (4 downto 0);
			  Vj : in  STD_LOGIC_VECTOR (31 downto 0);
			  Qj : in  STD_LOGIC_VECTOR (4 downto 0);
			  
           Q_WB : out  STD_LOGIC_VECTOR (4 downto 0);         --Step 3: Rename RF with RS tag (Q_WB: Write Back)
			  
			  
			  --PHASE 2 (RS -> FU OUT - Parallel steps - TOTAL time: 1 CC)
			  --When an instruction is ready for execution forward values to Logical or Aritmetic FU
			  --IMPORTANT: 1 logical and 1 arithmetic instructions SHOULD forward in parallel
			  
           L_Q : out  STD_LOGIC_VECTOR (4 downto 0);          --Forward to Logical FU
           L_Vk : out  STD_LOGIC_VECTOR (31 downto 0);
           L_Vj : out  STD_LOGIC_VECTOR (31 downto 0);
			  
           A_Q : out  STD_LOGIC_VECTOR (4 downto 0);          --Forward to Arithmetical FU
           A_Vk : out  STD_LOGIC_VECTOR (31 downto 0);
           A_Vj : out  STD_LOGIC_VECTOR (31 downto 0);
			  
			  
			  --PHASE 3 (Instruction Completed Register Ready - TOTAL time: 1 CC)
			  CDB_Q : in  STD_LOGIC_VECTOR (4 downto 0);         --CDB TAG AND VALUE
           CDB_V : in  STD_LOGIC_VECTOR (31 downto 0));
end RS;

architecture Behavioral of RS is

-- REGISTERS FOR STORING VALUES - 32 bits
component Reg_32bits 
Port (     CLK  : in  STD_LOGIC;
           RST  : in  STD_LOGIC;
           EN   : in  STD_LOGIC;
           INN  : in  STD_LOGIC_VECTOR (31 downto 0);
           OUTT : out  STD_LOGIC_VECTOR (31 downto 0));
end component;

-- REGISTERS FOR STORING TAGS	- 5 bits
component Reg_5bits is
    Port ( CLK  : in  STD_LOGIC;
           RST  : in  STD_LOGIC;
           EN   : in  STD_LOGIC;
           INN  : in  STD_LOGIC_VECTOR (4 downto 0);
           OUTT : out  STD_LOGIC_VECTOR (4 downto 0));
end component;

--RST signals
signal RST_L1,RST_L2,RST_A1,RST_A2,RST_A3: std_logic;


-------------------- PHASE 1 --------------------
--Available signals
signal A_L1,A_L2,A_A1,A_A2,A_A3 : std_logic;


-------------------- PHASE 2 --------------------
--READY signals
signal R_L1,R_L2,R_A1,R_A2,R_A3: std_logic;

--Logical Value Out
signal L1_Vk,L1_Vj,L2_Vk,L2_Vj : STD_LOGIC_VECTOR (31 downto 0);
--Arithmetic Value Out
signal A1_Vk,A1_Vj,A2_Vk,A2_Vj,A3_Vk,A3_Vj : STD_LOGIC_VECTOR (31 downto 0);


-------------------- PHASE 3 --------------------

begin

------------------------------------Logical 1
L1_Vk : Reg_32bits 
Port map(  CLK  =>CLK,
           RST  =>RST_L1,
           EN   =>,
           INN  =>,
           OUTT =>L1_Vk);

L1_Qk : Reg_5bits
Port map(  CLK  =>CLK,
           RST  =>RST_L1,
           EN   =>,
           INN  =>,
           OUTT =>);
			  
L1_Vj : Reg_32bits 
Port map(  CLK  =>CLK,
           RST  =>RST_L1,
           EN   =>,
           INN  =>,
           OUTT =>L1_Vj);

L1_Qj : Reg_5bits
Port map(  CLK  =>CLK,
           RST  =>RST_L1,
           EN   =>,
           INN  =>,
           OUTT =>);
			  
------------------------------------------------------------------------------------------------

------------------------------------Arithmetic 1
A1_Vk : Reg_32bits 
Port map(  CLK  =>CLK,
           RST  =>RST_A1,
           EN   =>,
           INN  =>,
           OUTT =>A1_Vk);

A1_Qk : Reg_5bits
Port map(  CLK  =>CLK,
           RST  =>RST_A1,
           EN   =>,
           INN  =>,
           OUTT =>);
A1_Vj : Reg_32bits 
Port map(  CLK  =>CLK,
           RST  =>RST_A1,
           EN   =>,
           INN  =>,
           OUTT =>A1_Vj);

A1_Qj : Reg_5bits
Port map(  CLK  =>CLK,
           RST  =>RST_A1,
           EN   =>,
           INN  =>,
           OUTT =>);
			  
end Behavioral;

