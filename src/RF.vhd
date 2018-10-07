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
-- Dependencies:              IEEE.numeric_std.all
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
--   |         |       E      ||        + ------------------------- +        || <----------- |            | 
--   |         | -----------> ||        |     Q       |     V       |        ||              |            |   
--   |         |              ||        + ----------- + ----------- +        ||              |            |                       
--   |    I    |              ||       0|     5       |     3       |        ||              |            |                 
--   |    S    |       K      ||       1|             |     2       |        ||     CDB_Q    |    CDB     | 
--   |    S    | -----------> ||       2|             |             |        || <----------- |            |
--   |    U    |              ||       .|     b       |     b       |        ||              |            |
--   |    E    |       J      ||       .|     i       |     i       |        ||              |            |
--   |         | -----------> ||       .|     t       |     t       |        ||              |            |
--   |         |              ||      31|     s       |     s       |        ||    CDB_E     |            |
--   |         |       R      ||        + ------------------------- +        || <----------- |            |
--   |         | -----------> ||                                             ||              |            |
--   |         |              ||                                             ||              |            | 
--   + ------- +              ||                                             ||              |            |
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
use IEEE.numeric_std.all;

entity RF is
    Port ( CLK  : in  STD_LOGIC;
           RST  : in  STD_LOGIC;
			  
	        --PHASE 1 (Concurrent steps - TOTAL time: 1 CC)
			  K : in  STD_LOGIC_VECTOR (4 downto 0);          --Step 1: ISSUE -> RF -- Issue registers' addresses to read (AKA Rs and Rt on R-type MIPS instructions)
           J : in  STD_LOGIC_VECTOR (4 downto 0);
			  
			  Vk : out  STD_LOGIC_VECTOR (31 downto 0);       --Step 2: RF -> RS -- Registers' data
           Qk : out  STD_LOGIC_VECTOR (4 downto 0);
           Vj : out  STD_LOGIC_VECTOR (31 downto 0);
           Qj : out  STD_LOGIC_VECTOR (4 downto 0);
			  
           R : in  STD_LOGIC_VECTOR (4 downto 0);          --Step 3: RS -> RF -- Renaming Rd tag
           Q_WB : in  STD_LOGIC_VECTOR (4 downto 0);
           
			  E : in STD_LOGIC;                               --Step 4: Execute
			  
			  --PHASE 2 ( CDB -> RF - TOTAL time: 1 CC)
			  CDB_E : in STD_LOGIC;                           -- New Tag on CDB (Execute actions needed)
           CDB_V : in  STD_LOGIC_VECTOR (31 downto 0);
           CDB_Q : in  STD_LOGIC_VECTOR (4 downto 0));
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

--Signal types
type T_32x1 is array (31 downto 0) of STD_LOGIC;
type T_32x5 is array (31 downto 0) of STD_LOGIC_VECTOR (4 downto 0);
type T_32x32 is array (31 downto 0) of STD_LOGIC_VECTOR (31 downto 0);

--Register's tmp signals 
signal EVQ : T_32x1;    --Value and Tag Write Enable 	
signal VI : T_32x32;    --Values I/O 
signal VO : T_32x32;			
signal QI : T_32x5;     --Tags I/O 		
signal QO : T_32x5;			

begin

------------------------------------------------------------------------ Registers
R_V: FOR n IN 31 DOWNTO 0 GENERATE                    -- Values
    v_reg:Reg_32bits
    Port map( 
			  CLK  => CLK,
           RST  => RST,
           EN   => EVQ(n),
           INN  => VI(n),
           OUTT => VO(n));
END GENERATE R_V;

R_Q: FOR n IN 31 DOWNTO 0 GENERATE                    -- Tags
    q_reg:Reg_5bits
    Port map( 
			  CLK  => CLK,
           RST  => RST,
           EN   => EVQ(n),
           INN  => QI(n),
           OUTT => QO(n));
END GENERATE R_Q;

------------------------------------------------------------------------ Multiplexers
Vk <= VO(to_integer(unsigned(K))); 

			  
end Behavioral;

