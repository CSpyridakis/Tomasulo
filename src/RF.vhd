----------------------------------------------------------------------------------
-- Company/University:        Technical University of Crete (TUC) - GR
-- Engineer:                  Spyridakis Christos 
--                            Bellonias Panagiotis
-- 
-- Create Date:                
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
-- Additional Comments:       Register File implementation (RF)
--
--
--                                          ABSTRACT: I/O Connections    
--               
--                                                     RF                                            
--                            ++ ------------------------------------------- ++              + ---------- + 
--                            ||                                             ||              |            |
--                            ||                                             ||              |            |                       
--   + ------- +              ||                                             ||    CDB_V     |            |
--   |         |       K      ||        + ------------------------- +        || <----------- |            | 
--   |         | -----------> ||        |     Q       |     V       |        ||              |            |   
--   |         |              ||        + ----------- + ----------- +        ||              |            |                       
--   |    I    |              ||       0|     5       |     3       |        ||              |            |                 
--   |    S    |       J      ||       1|             |     2       |        ||              |    CDB     | 
--   |    S    | -----------> ||       2|             |             |        ||              |            |
--   |    U    |              ||       .|     b       |     b       |        ||              |            |
--   |    E    |              ||       .|     i       |     i       |        ||              |            |
--   |         |       R      ||       .|     t       |     t       |        ||              |            |
--   |         | -----------> ||      31|     s       |     s       |        ||    CDB_Q     |            |
--   + ------- +              ||        + ------------------------- +        || <----------- |            |
--                            ||                                             ||              |            |
--                            ||                                             ||              |            | 
--                            ||                                             ||              |            |
--                            ++ ------------------------------------------- ++              + ---------- +                         
--                                       					              
--                                         ||   ||   ||   ||     /\         
--                                         ||   ||   ||   ||     ||         
--                                       Vk|| Qk|| Vj|| Qj|| Q_WB||         
--                                         ||   ||   ||   ||     ||         
--                                         \/   \/   \/   \/     ||                       
--                                      + ------------------------- +    
--                                      |                           |    
--                                      |                           |    
--                                      |             RS            |   
--                                      |                           |    
--                                      |                           |    
--                                      + ------------------------- +    
--
----------------------------------------------------------------------------------

-- TODO LIST:
--     * V Update if CDB_Q == Qn : 0 < n < 32 , nεN

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity RF is
    Port ( CLK  : in  STD_LOGIC;
           RST  : in  STD_LOGIC;
			  
	        --PHASE 1 ( TOTAL time: 1 CC)
			  K : in  STD_LOGIC_VECTOR (4 downto 0);          --Step 1: ISSUE -> RF
           J : in  STD_LOGIC_VECTOR (4 downto 0);
			  
			  Vk : out  STD_LOGIC_VECTOR (31 downto 0);       --Step 2: RF -> RS
           Qk : out  STD_LOGIC_VECTOR (4 downto 0);
           Vj : out  STD_LOGIC_VECTOR (31 downto 0);
           Qj : out  STD_LOGIC_VECTOR (4 downto 0);
			  
           R : in  STD_LOGIC_VECTOR (4 downto 0);          --Step 3: RF -> RS
           Q_WB : in  STD_LOGIC_VECTOR (4 downto 0);
           
			  --PHASE 2 ( CDB -> RF - TOTAL time: 1 CC)
           CDB_V : in  STD_LOGIC_VECTOR (31 downto 0);
           CDB_Q : in  STD_LOGIC_VECTOR (0 downto 0));
end RF;

architecture Behavioral of RF is

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

--Write Enable for Register Value
signal EV1,EV2,EV3,EV4,EV5,EV6,EV7,EV8,EV9,EV10,EV11,EV12,EV13,EV14,EV15,EV16,EV17,EV18,EV19,EV20,EV21,EV22,EV23,EV24,EV25,EV26,EV27,EV28,EV29,EV30,EV31: STD_LOGIC;
--Register tmp OUTPUT Values
signal V0,V1,V2,V3,V4,V5,V6,V7,V8,V9,V10,V11,V12,V13,V14,V15,V16,V17,V18,V19,V20,V21,V22,V23,V24,V25,V26,V27,V28,V29,V30,V31: STD_LOGIC_VECTOR (31 downto 0);

--Write Enable for Register Tag
signal EQ1,EQ2,EQ3,EQ4,EQ5,EQ6,EQ7,EQ8,EQ9,EQ10,EQ11,EQ12,EQ13,EQ14,EQ15,EQ16,EQ17,EQ18,EQ19,EQ20,EQ21,EQ22,EQ23,EQ24,EQ25,EQ26,EQ27,EQ28,EQ29,EQ30,EQ31: STD_LOGIC;
--Register tmp OUTPUT Tags
signal Q0,Q1,Q2,Q3,Q4,Q5,Q6,Q7,Q8,Q9,Q10,Q11,Q12,Q13,Q14,Q15,Q16,Q17,Q18,Q19,Q20,Q21,Q22,Q23,Q24,Q25,Q26,Q27,Q28,Q29,Q30,Q31: STD_LOGIC_VECTOR (4 downto 0);

begin
------------------------------------------------------------------------ Multiplexers
------------------------------------ MUX Vk
WITH K SELECT
Vk <=
     V0 WHEN "00000",
	  V1 WHEN "00001",
	  V2 WHEN "00010",
	  V3 WHEN "00011",
	  V4 WHEN "00100",
	  V5 WHEN "00101",
	  V6 WHEN "00110",
	  V7 WHEN "00111",
	  V8 WHEN "01000",
	  V9 WHEN "01001",
	  V10 WHEN "01010",
	  V11 WHEN "01011",
	  V12 WHEN "01100",
	  V13 WHEN "01101",
	  V14 WHEN "01110",
	  V15 WHEN "01111",
	  V16 WHEN "10000",
	  V17 WHEN "10001",
	  V18 WHEN "10010",
	  V19 WHEN "10011",
	  V20 WHEN "10100",
	  V21 WHEN "10101",
	  V22 WHEN "10110",
	  V23 WHEN "10111",
	  V24 WHEN "11000",
	  V25 WHEN "11001",
	  V26 WHEN "11010",
	  V27 WHEN "11011",
	  V28 WHEN "11100",
	  V29 WHEN "11101",
	  V30 WHEN "11110",
	  V31 WHEN OTHERS;

------------------------------------ MUX Qk
WITH K SELECT
Qk <=
     Q0 WHEN "00000",
	  Q1 WHEN "00001",
	  Q2 WHEN "00010",
	  Q3 WHEN "00011",
	  Q4 WHEN "00100",
	  Q5 WHEN "00101",
	  Q6 WHEN "00110",
	  Q7 WHEN "00111",
	  Q8 WHEN "01000",
	  Q9 WHEN "01001",
	  Q10 WHEN "01010",
	  Q11 WHEN "01011",
	  Q12 WHEN "01100",
	  Q13 WHEN "01101",
	  Q14 WHEN "01110",
	  Q15 WHEN "01111",
	  Q16 WHEN "10000",
	  Q17 WHEN "10001",
	  Q18 WHEN "10010",
	  Q19 WHEN "10011",
	  Q20 WHEN "10100",
	  Q21 WHEN "10101",
	  Q22 WHEN "10110",
	  Q23 WHEN "10111",
	  Q24 WHEN "11000",
	  Q25 WHEN "11001",
	  Q26 WHEN "11010",
	  Q27 WHEN "11011",
	  Q28 WHEN "11100",
	  Q29 WHEN "11101",
	  Q30 WHEN "11110",
	  Q31 WHEN OTHERS;	  

------------------------------------ MUX Vk
WITH J SELECT
Vj <=
     V0 WHEN "00000",
	  V1 WHEN "00001",
	  V2 WHEN "00010",
	  V3 WHEN "00011",
	  V4 WHEN "00100",
	  V5 WHEN "00101",
	  V6 WHEN "00110",
	  V7 WHEN "00111",
	  V8 WHEN "01000",
	  V9 WHEN "01001",
	  V10 WHEN "01010",
	  V11 WHEN "01011",
	  V12 WHEN "01100",
	  V13 WHEN "01101",
	  V14 WHEN "01110",
	  V15 WHEN "01111",
	  V16 WHEN "10000",
	  V17 WHEN "10001",
	  V18 WHEN "10010",
	  V19 WHEN "10011",
	  V20 WHEN "10100",
	  V21 WHEN "10101",
	  V22 WHEN "10110",
	  V23 WHEN "10111",
	  V24 WHEN "11000",
	  V25 WHEN "11001",
	  V26 WHEN "11010",
	  V27 WHEN "11011",
	  V28 WHEN "11100",
	  V29 WHEN "11101",
	  V30 WHEN "11110",
	  V31 WHEN OTHERS;

------------------------------------ MUX Qk
WITH J SELECT
Qj <=
     Q0 WHEN "00000",
	  Q1 WHEN "00001",
	  Q2 WHEN "00010",
	  Q3 WHEN "00011",
	  Q4 WHEN "00100",
	  Q5 WHEN "00101",
	  Q6 WHEN "00110",
	  Q7 WHEN "00111",
	  Q8 WHEN "01000",
	  Q9 WHEN "01001",
	  Q10 WHEN "01010",
	  Q11 WHEN "01011",
	  Q12 WHEN "01100",
	  Q13 WHEN "01101",
	  Q14 WHEN "01110",
	  Q15 WHEN "01111",
	  Q16 WHEN "10000",
	  Q17 WHEN "10001",
	  Q18 WHEN "10010",
	  Q19 WHEN "10011",
	  Q20 WHEN "10100",
	  Q21 WHEN "10101",
	  Q22 WHEN "10110",
	  Q23 WHEN "10111",
	  Q24 WHEN "11000",
	  Q25 WHEN "11001",
	  Q26 WHEN "11010",
	  Q27 WHEN "11011",
	  Q28 WHEN "11100",
	  Q29 WHEN "11101",
	  Q30 WHEN "11110",
	  Q31 WHEN OTHERS;	 


------------------------------------------------------------------------ Registers
------------------------------------ R 0
R_V0 : Reg_32bits 
Port map(  CLK  =>CLK,
           RST  =>RST,
           EN   =>'0',
           INN  =>"00000000000000000000000000000000",
           OUTT =>V0);

R_Q0 : Reg_5bits
Port map(  CLK  =>CLK,
           RST  =>RST,
           EN   =>'0',
           INN  =>"00000",
           OUTT =>Q0);
------------------------------------ R1
R_V1 : Reg_32bits
Port map(  CLK  =>CLK,
           RST  =>RST,
           EN   =>EV1,
           INN  =>CDB_V,
           OUTT =>V1);

R_Q1 : Reg_5bits
Port map(  CLK  =>CLK,
           RST  =>RST,
           EN   =>EQ1,
           INN  =>Q,
           OUTT =>Q1);


------------------------------------ R2
R_V2 : Reg_32bits
Port map(  CLK  =>CLK,
           RST  =>RST,
           EN   =>EV2,
           INN  =>CDB_V,
           OUTT =>V2);

R_Q2 : Reg_5bits
Port map(  CLK  =>CLK,
           RST  =>RST,
           EN   =>EQ2,
           INN  =>Q,
           OUTT =>Q2);


------------------------------------ R3
R_V3 : Reg_32bits
Port map(  CLK  =>CLK,
           RST  =>RST,
           EN   =>EV3,
           INN  =>CDB_V,
           OUTT =>V3);

R_Q3 : Reg_5bits
Port map(  CLK  =>CLK,
           RST  =>RST,
           EN   =>EQ3,
           INN  =>Q,
           OUTT =>Q3);


------------------------------------ R4
R_V4 : Reg_32bits
Port map(  CLK  =>CLK,
           RST  =>RST,
           EN   =>EV4,
           INN  =>CDB_V,
           OUTT =>V4);

R_Q4 : Reg_5bits
Port map(  CLK  =>CLK,
           RST  =>RST,
           EN   =>EQ4,
           INN  =>Q,
           OUTT =>Q4);


------------------------------------ R5
R_V5 : Reg_32bits
Port map(  CLK  =>CLK,
           RST  =>RST,
           EN   =>EV5,
           INN  =>CDB_V,
           OUTT =>V5);

R_Q5 : Reg_5bits
Port map(  CLK  =>CLK,
           RST  =>RST,
           EN   =>EQ5,
           INN  =>Q,
           OUTT =>Q5);


------------------------------------ R6
R_V6 : Reg_32bits
Port map(  CLK  =>CLK,
           RST  =>RST,
           EN   =>EV6,
           INN  =>CDB_V,
           OUTT =>V6);

R_Q6 : Reg_5bits
Port map(  CLK  =>CLK,
           RST  =>RST,
           EN   =>EQ6,
           INN  =>Q,
           OUTT =>Q6);


------------------------------------ R7
R_V7 : Reg_32bits
Port map(  CLK  =>CLK,
           RST  =>RST,
           EN   =>EV7,
           INN  =>CDB_V,
           OUTT =>V7);

R_Q7 : Reg_5bits
Port map(  CLK  =>CLK,
           RST  =>RST,
           EN   =>EQ7,
           INN  =>Q,
           OUTT =>Q7);


------------------------------------ R8
R_V8 : Reg_32bits
Port map(  CLK  =>CLK,
           RST  =>RST,
           EN   =>EV8,
           INN  =>CDB_V,
           OUTT =>V8);

R_Q8 : Reg_5bits
Port map(  CLK  =>CLK,
           RST  =>RST,
           EN   =>EQ8,
           INN  =>Q,
           OUTT =>Q8);


------------------------------------ R9
R_V9 : Reg_32bits
Port map(  CLK  =>CLK,
           RST  =>RST,
           EN   =>EV9,
           INN  =>CDB_V,
           OUTT =>V9);

R_Q9 : Reg_5bits
Port map(  CLK  =>CLK,
           RST  =>RST,
           EN   =>EQ9,
           INN  =>Q,
           OUTT =>Q9);


------------------------------------ R10
R_V10 : Reg_32bits
Port map(  CLK  =>CLK,
           RST  =>RST,
           EN   =>EV10,
           INN  =>CDB_V,
           OUTT =>V10);

R_Q10 : Reg_5bits
Port map(  CLK  =>CLK,
           RST  =>RST,
           EN   =>EQ10,
           INN  =>Q,
           OUTT =>Q10);


------------------------------------ R11
R_V11 : Reg_32bits
Port map(  CLK  =>CLK,
           RST  =>RST,
           EN   =>EV11,
           INN  =>CDB_V,
           OUTT =>V11);

R_Q11 : Reg_5bits
Port map(  CLK  =>CLK,
           RST  =>RST,
           EN   =>EQ11,
           INN  =>Q,
           OUTT =>Q11);


------------------------------------ R12
R_V12 : Reg_32bits
Port map(  CLK  =>CLK,
           RST  =>RST,
           EN   =>EV12,
           INN  =>CDB_V,
           OUTT =>V12);

R_Q12 : Reg_5bits
Port map(  CLK  =>CLK,
           RST  =>RST,
           EN   =>EQ12,
           INN  =>Q,
           OUTT =>Q12);


------------------------------------ R13
R_V13 : Reg_32bits
Port map(  CLK  =>CLK,
           RST  =>RST,
           EN   =>EV13,
           INN  =>CDB_V,
           OUTT =>V13);

R_Q13 : Reg_5bits
Port map(  CLK  =>CLK,
           RST  =>RST,
           EN   =>EQ13,
           INN  =>Q,
           OUTT =>Q13);


------------------------------------ R14
R_V14 : Reg_32bits
Port map(  CLK  =>CLK,
           RST  =>RST,
           EN   =>EV14,
           INN  =>CDB_V,
           OUTT =>V14);

R_Q14 : Reg_5bits
Port map(  CLK  =>CLK,
           RST  =>RST,
           EN   =>EQ14,
           INN  =>Q,
           OUTT =>Q14);


------------------------------------ R15
R_V15 : Reg_32bits
Port map(  CLK  =>CLK,
           RST  =>RST,
           EN   =>EV15,
           INN  =>CDB_V,
           OUTT =>V15);

R_Q15 : Reg_5bits
Port map(  CLK  =>CLK,
           RST  =>RST,
           EN   =>EQ15,
           INN  =>Q,
           OUTT =>Q15);


------------------------------------ R16
R_V16 : Reg_32bits
Port map(  CLK  =>CLK,
           RST  =>RST,
           EN   =>EV16,
           INN  =>CDB_V,
           OUTT =>V16);

R_Q16 : Reg_5bits
Port map(  CLK  =>CLK,
           RST  =>RST,
           EN   =>EQ16,
           INN  =>Q,
           OUTT =>Q16);


------------------------------------ R17
R_V17 : Reg_32bits
Port map(  CLK  =>CLK,
           RST  =>RST,
           EN   =>EV17,
           INN  =>CDB_V,
           OUTT =>V17);

R_Q17 : Reg_5bits
Port map(  CLK  =>CLK,
           RST  =>RST,
           EN   =>EQ17,
           INN  =>Q,
           OUTT =>Q17);


------------------------------------ R18
R_V18 : Reg_32bits
Port map(  CLK  =>CLK,
           RST  =>RST,
           EN   =>EV18,
           INN  =>CDB_V,
           OUTT =>V18);

R_Q18 : Reg_5bits
Port map(  CLK  =>CLK,
           RST  =>RST,
           EN   =>EQ18,
           INN  =>Q,
           OUTT =>Q18);


------------------------------------ R19
R_V19 : Reg_32bits
Port map(  CLK  =>CLK,
           RST  =>RST,
           EN   =>EV19,
           INN  =>CDB_V,
           OUTT =>V19);

R_Q19 : Reg_5bits
Port map(  CLK  =>CLK,
           RST  =>RST,
           EN   =>EQ19,
           INN  =>Q,
           OUTT =>Q19);


------------------------------------ R20
R_V20 : Reg_32bits
Port map(  CLK  =>CLK,
           RST  =>RST,
           EN   =>EV20,
           INN  =>CDB_V,
           OUTT =>V20);

R_Q20 : Reg_5bits
Port map(  CLK  =>CLK,
           RST  =>RST,
           EN   =>EQ20,
           INN  =>Q,
           OUTT =>Q20);


------------------------------------ R21
R_V21 : Reg_32bits
Port map(  CLK  =>CLK,
           RST  =>RST,
           EN   =>EV21,
           INN  =>CDB_V,
           OUTT =>V21);

R_Q21 : Reg_5bits
Port map(  CLK  =>CLK,
           RST  =>RST,
           EN   =>EQ21,
           INN  =>Q,
           OUTT =>Q21);


------------------------------------ R22
R_V22 : Reg_32bits
Port map(  CLK  =>CLK,
           RST  =>RST,
           EN   =>EV22,
           INN  =>CDB_V,
           OUTT =>V22);

R_Q22 : Reg_5bits
Port map(  CLK  =>CLK,
           RST  =>RST,
           EN   =>EQ22,
           INN  =>Q,
           OUTT =>Q22);


------------------------------------ R23
R_V23 : Reg_32bits
Port map(  CLK  =>CLK,
           RST  =>RST,
           EN   =>EV23,
           INN  =>CDB_V,
           OUTT =>V23);

R_Q23 : Reg_5bits
Port map(  CLK  =>CLK,
           RST  =>RST,
           EN   =>EQ23,
           INN  =>Q,
           OUTT =>Q23);


------------------------------------ R24
R_V24 : Reg_32bits
Port map(  CLK  =>CLK,
           RST  =>RST,
           EN   =>EV24,
           INN  =>CDB_V,
           OUTT =>V24);

R_Q24 : Reg_5bits
Port map(  CLK  =>CLK,
           RST  =>RST,
           EN   =>EQ24,
           INN  =>Q,
           OUTT =>Q24);


------------------------------------ R25
R_V25 : Reg_32bits
Port map(  CLK  =>CLK,
           RST  =>RST,
           EN   =>EV25,
           INN  =>CDB_V,
           OUTT =>V25);

R_Q25 : Reg_5bits
Port map(  CLK  =>CLK,
           RST  =>RST,
           EN   =>EQ25,
           INN  =>Q,
           OUTT =>Q25);


------------------------------------ R26
R_V26 : Reg_32bits
Port map(  CLK  =>CLK,
           RST  =>RST,
           EN   =>EV26,
           INN  =>CDB_V,
           OUTT =>V26);

R_Q26 : Reg_5bits
Port map(  CLK  =>CLK,
           RST  =>RST,
           EN   =>EQ26,
           INN  =>Q,
           OUTT =>Q26);


------------------------------------ R27
R_V27 : Reg_32bits
Port map(  CLK  =>CLK,
           RST  =>RST,
           EN   =>EV27,
           INN  =>CDB_V,
           OUTT =>V27);

R_Q27 : Reg_5bits
Port map(  CLK  =>CLK,
           RST  =>RST,
           EN   =>EQ27,
           INN  =>Q,
           OUTT =>Q27);


------------------------------------ R28
R_V28 : Reg_32bits
Port map(  CLK  =>CLK,
           RST  =>RST,
           EN   =>EV28,
           INN  =>CDB_V,
           OUTT =>V28);

R_Q28 : Reg_5bits
Port map(  CLK  =>CLK,
           RST  =>RST,
           EN   =>EQ28,
           INN  =>Q,
           OUTT =>Q28);


------------------------------------ R29
R_V29 : Reg_32bits
Port map(  CLK  =>CLK,
           RST  =>RST,
           EN   =>EV29,
           INN  =>CDB_V,
           OUTT =>V29);

R_Q29 : Reg_5bits
Port map(  CLK  =>CLK,
           RST  =>RST,
           EN   =>EQ29,
           INN  =>Q,
           OUTT =>Q29);


------------------------------------ R30
R_V30 : Reg_32bits
Port map(  CLK  =>CLK,
           RST  =>RST,
           EN   =>EV30,
           INN  =>CDB_V,
           OUTT =>V30);

R_Q30 : Reg_5bits
Port map(  CLK  =>CLK,
           RST  =>RST,
           EN   =>EQ30,
           INN  =>Q,
           OUTT =>Q30);


------------------------------------ R31
R_V31 : Reg_32bits
Port map(  CLK  =>CLK,
           RST  =>RST,
           EN   =>EV31,
           INN  =>CDB_V,
           OUTT =>V31);

R_Q31 : Reg_5bits
Port map(  CLK  =>CLK,
           RST  =>RST,
           EN   =>EQ31,
           INN  =>Q,
           OUTT =>Q31);

			  
end Behavioral;

