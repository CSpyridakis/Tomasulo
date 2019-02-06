----------------------------------------------------------------------------------
-- Company/University:        Technical University of Crete (TUC) - GR
-- Engineer:                  Spyridakis Christos 
--                            Bellonias Panagiotis
-- 
-- Create Date:                
-- Design Name: 	 
-- Module Name:               ROB_Reg - Behavioral 
-- Project Name:              Tomasulo
-- Target Devices:            NONE
-- Tool versions:             Xilinx ISE 14.7 --TODO: VIVADO
-- Description:               Introduction in Dynamic Instruction Scheduling (Advanced Computer Architecture)
--                            implementing Tomasulo's Algorithm 	 
--
-- Dependencies:              NONE
--
-- Revision:                  2.1 
-- Revision                   2.1 - ROB
-- Additional Comments: 
--
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity ROB_Reg is
    Port ( CLK : in  STD_LOGIC;
           RST : in  STD_LOGIC;
           MY_TAG : in STD_LOGIC_VECTOR (4 downto 0);
			  
           --FROM ISSUE (PUSH INTO QUEUE)
           ISSUE : in STD_LOGIC;
           ISSUE_PC : in STD_LOGIC_VECTOR (31 downto 0);
           ISSUE_I_type : in STD_LOGIC_VECTOR (1 downto 0);
           ISSUE_Dest : in STD_LOGIC_VECTOR (4 downto 0);

           --FROM CDB (UPDATE QUEUE)
           CDB_Q: in STD_LOGIC_VECTOR (4 downto 0);
           CDB_V : in STD_LOGIC_VECTOR (31 downto 0);

           --EXCEPTION
           I_EXCEPTION : in STD_LOGIC_VECTOR (4 downto 0);
			  
           --TO RF/MEM (POP FROM QUEUE, only if instruction has been executed)
           EXECUTED : out STD_LOGIC;
           POP : in STD_LOGIC;
           DEST_RF : out STD_LOGIC_VECTOR (4 downto 0);
           DEST_MEM : out STD_LOGIC_VECTOR (4 downto 0);
           VALUE : out STD_LOGIC_VECTOR (31 downto 0); 
			  
           --EXCEPTION HANDLER
           EXCEPTION : out STD_LOGIC_VECTOR (4 downto 0);
           PC : out STD_LOGIC_VECTOR (31 downto 0);
			  
           --MY TAG AND STATUS
           EMPTY : out  STD_LOGIC;
           TAG : out STD_LOGIC_VECTOR (4 downto 0));
end ROB_Reg;

architecture Behavioral of ROB_Reg is

--Store REG empty status 
component Reg_1bit_N is
    Port ( CLK  : in  STD_LOGIC;
           RST  : in  STD_LOGIC;
           EN   : in  STD_LOGIC;
           INN  : in  STD_LOGIC;
           OUTT : out  STD_LOGIC);
end component;

--Executed information if instruction has been completed
component Reg_1bit is
    Port ( CLK  : in  STD_LOGIC;
           RST  : in  STD_LOGIC;
           EN   : in  STD_LOGIC;
           INN  : in  STD_LOGIC;
           OUTT : out  STD_LOGIC);
end component;

--Store I_type
component Reg_2bits is
    Port ( CLK  : in  STD_LOGIC;
           RST  : in  STD_LOGIC;
           EN   : in  STD_LOGIC;
           INN  : in  STD_LOGIC_VECTOR(1 downto 0);
           OUTT : out  STD_LOGIC_VECTOR(1 downto 0));
end component;

--Store Dest, Exception and Pc
component Reg_5bits is
    Port ( CLK  : in  STD_LOGIC;
           RST  : in  STD_LOGIC;
           EN   : in  STD_LOGIC;
           INN  : in  STD_LOGIC_VECTOR (4 downto 0);
           OUTT : out  STD_LOGIC_VECTOR (4 downto 0));
end component;

--Store Value
component Reg_32bits is
    Port ( CLK  : in  STD_LOGIC;
           RST  : in  STD_LOGIC;
           EN   : in  STD_LOGIC;
           INN  : in  STD_LOGIC_VECTOR (31 downto 0);
           OUTT : out  STD_LOGIC_VECTOR (31 downto 0));
end component;

--Enables
signal EMPTY_EN, Exec_EN, I_Type_EN, Dest_EN, Exception_EN, PC_EN, Value_EN : STD_LOGIC;
--Resets
signal EMPTY_RST, Exec_RST, I_Type_RST, Dest_RST, Exception_RST, PC_RST, Value_RST : STD_LOGIC;

signal I_Type : STD_LOGIC_VECTOR (1 downto 0);
signal DEST : STD_LOGIC_VECTOR (4 downto 0);
signal EXEC : STD_LOGIC;

signal EMPTY_TMP : STD_LOGIC;

--DEBUG SIGNAL
TYPE DEBUG_SIGNALS IS (INIT_S, RST_S, PUSH_S, UPDATE_S, POP_S, EXCEPTION_S, NONE_S);  
SIGNAL DEBUG_ME : DEBUG_SIGNALS := INIT_S;

begin

--Init my TAG
TAG<=MY_TAG;

EXECUTED<=EXEC;
EMPTY<=EMPTY_TMP;

--DESTINATION
DEST_RF  <= DEST WHEN I_Type(1)='0' ELSE "00000";
DEST_MEM <= DEST WHEN I_Type(1)='1' ELSE "00000";

--Enables
I_Type_EN    <='1' WHEN RST='0' AND EMPTY_TMP='1' AND ISSUE='1' AND EXEC='0' ELSE '0';
Dest_EN      <='1' WHEN RST='0' AND EMPTY_TMP='1' AND ISSUE='1' AND EXEC='0' ELSE '0';
PC_EN        <='1' WHEN RST='0' AND EMPTY_TMP='1' AND ISSUE='1' AND EXEC='0' ELSE '0';
EMPTY_EN     <='1' WHEN RST='0' AND EMPTY_TMP='1' AND ISSUE='1' AND EXEC='0' ELSE '0';
Exec_EN      <='1' WHEN RST='0' AND EMPTY_TMP='0' AND ISSUE='0' AND CDB_Q=MY_TAG AND I_EXCEPTION="00000" ELSE '0';
Value_EN     <='1' WHEN RST='0' AND EMPTY_TMP='0' AND ISSUE='0' AND CDB_Q=MY_TAG AND I_EXCEPTION="00000" ELSE '0';
Exception_EN <='1' WHEN RST='0' AND EMPTY_TMP='0' AND ISSUE='0' AND I_EXCEPTION/="00000" ELSE '0';

--Resets
Exec_RST      <='1' WHEN RST='1' OR (RST='0' AND ISSUE='0' AND EXEC='1' AND I_EXCEPTION="00000" AND POP='1') ELSE '0';
I_Type_RST    <='1' WHEN RST='1' OR (RST='0' AND ISSUE='0' AND EXEC='1' AND I_EXCEPTION="00000" AND POP='1') ELSE '0';
Dest_RST      <='1' WHEN RST='1' OR (RST='0' AND ISSUE='0' AND EXEC='1' AND I_EXCEPTION="00000" AND POP='1') ELSE '0';
Exception_RST <='1' WHEN RST='1' OR (RST='0' AND ISSUE='0' AND EXEC='1' AND I_EXCEPTION="00000" AND POP='1') ELSE '0';
PC_RST        <='1' WHEN RST='1' OR (RST='0' AND ISSUE='0' AND EXEC='1' AND I_EXCEPTION="00000" AND POP='1') ELSE '0';
Value_RST     <='1' WHEN RST='1' OR (RST='0' AND ISSUE='0' AND EXEC='1' AND I_EXCEPTION="00000" AND POP='1') ELSE '0';
EMPTY_RST     <='1' WHEN RST='1' OR (RST='0' AND ISSUE='0' AND EXEC='1' AND I_EXCEPTION="00000" AND POP='1') ELSE '0';

--DEBUG MESSAGES
DEBUG_ME <= RST_S       WHEN RST='1' ELSE
            PUSH_S      WHEN RST='0' AND EMPTY_TMP='1' AND ISSUE='1' AND EXEC='0' ELSE
            UPDATE_S    WHEN RST='0' AND EMPTY_TMP='0' AND ISSUE='0' AND EXEC='0' AND I_EXCEPTION="00000" AND CDB_Q=MY_TAG  ELSE
            EXCEPTION_S WHEN RST='0' AND EMPTY_TMP='0' AND ISSUE='0' AND EXEC='0' AND I_EXCEPTION/="00000" ELSE
            POP_S       WHEN RST='0' AND EMPTY_TMP='0' AND ISSUE='0' AND EXEC='1' AND I_EXCEPTION="00000" AND POP='1' ELSE
            NONE_S;

--EMPTY
EMPTY_R : Reg_1bit_N
    Port map( CLK  => CLK,
              RST  => EMPTY_RST,
              EN   => EMPTY_EN,
              INN  => '0',
              OUTT => EMPTY_TMP);
				  
--Executed
Exec_R : Reg_1bit
    Port map( CLK  => CLK,
              RST  => Exec_RST,
              EN   => Exec_EN,
              INN  => '1',
              OUTT => EXEC);

--I_Type		  
I_Type_R : Reg_2bits
    Port map( CLK  => CLK,
              RST  => I_Type_RST,
              EN   => I_Type_EN,
              INN  => ISSUE_I_type,
              OUTT => I_Type);

--Destination		  
Dest_R : Reg_5bits
    Port map( CLK  => CLK,
              RST  => Dest_RST,
              EN   => Dest_EN,
              INN  => ISSUE_Dest,
              OUTT => DEST);

--Exception			  
Exception_R : Reg_5bits
    Port map( CLK  => CLK,
              RST  => Exception_RST,
              EN   => Exception_EN,
              INN  => I_EXCEPTION,
              OUTT => EXCEPTION);

--PC
PC_R : Reg_32bits
    Port map( CLK  => CLK,
              RST  => PC_RST,
              EN   => PC_EN,
              INN  => ISSUE_PC,
              OUTT => PC);		

--Value
Value_R : Reg_32bits
    Port map( CLK  => CLK,
              RST  => Value_RST,
              EN   => Value_EN,
              INN  => CDB_V,
              OUTT => VALUE);					  
end Behavioral;


