----------------------------------------------------------------------------------
-- Company/University:        Technical University of Crete (TUC) - GR
-- Engineer:                  Spyridakis Christos 
--                            Bellonias Panagiotis
-- 
-- Create Date:               11/6/2018
-- Design Name: 	 
-- Module Name:               RF_Reg - Behavioral 
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
use IEEE.NUMERIC_STD.ALL;

entity RF_Reg is
 Port (    CLK : in  STD_LOGIC;
           RST : in  STD_LOGIC;
           ID : in  STD_LOGIC_VECTOR (4 downto 0);
           Ri : in  STD_LOGIC_VECTOR (4 downto 0);
           Tag_WE : in  STD_LOGIC;
           ROB_Tag_Accepted : in  STD_LOGIC_VECTOR (4 downto 0);
           ROB_Q : in  STD_LOGIC_VECTOR (4 downto 0);
           ROB_V : in  STD_LOGIC_VECTOR (31 downto 0);
           ROB_DEST : in  STD_LOGIC_VECTOR (4 downto 0);
           Q : out  STD_LOGIC_VECTOR (4 downto 0);
           V : out  STD_LOGIC_VECTOR (31 downto 0));
end RF_Reg;

architecture Behavioral of RF_Reg is

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

component Reg_V_Q_N is
  Port ( CLK : in  STD_LOGIC;
         RST : in  STD_LOGIC;
         EN : in  STD_LOGIC;
         VIN : in  STD_LOGIC_VECTOR (31 downto 0);
         QIN : in  STD_LOGIC_VECTOR (4 downto 0);
         VOUT : out  STD_LOGIC_VECTOR (31 downto 0);
         QOUT : out  STD_LOGIC_VECTOR (4 downto 0));
end component;

signal Q_I, Q_O : STD_LOGIC_VECTOR (4 downto 0);
signal V_I : STD_LOGIC_VECTOR (31 downto 0);

signal Sel, En : STD_LOGIC;

begin

-- Register Inputs selection
Sel <= '0' WHEN Tag_WE='1' AND ID = Ri ELSE              -- ISSUE : V="000.." AND Q = ROB_Tag_Accepted
       '1';                                              -- ELSE  : V= CDB_V  AND Q = "00000" 

-- Register Write Enable
En <= '1' WHEN Tag_WE='1' AND ID = Ri ELSE               -- ISSUE
      '1' WHEN ROB_DEST=ID AND ROB_Q = Q_O ELSE          -- ROB  
      '0';		

V_IN : Mux_2x32bits
Port map( In0  => "00000000000000000000000000000000",
		    In1  => ROB_V,
		    Sel  => Sel,
		    Outt => V_I);

Q_IN : Mux_2x5bits
Port map( In0  => ROB_Tag_Accepted,
		    In1  => "00000",
		    Sel  => Sel,
		    Outt => Q_I);

Reg : Reg_V_Q_N
Port map( CLK  => CLK,
		    RST  => RST,
		    EN   => En,
		    VIN  => V_I,
		    QIN  => Q_I,
		    VOUT => V,
		    QOUT => Q_O);	
Q <= Q_O;

end Behavioral;

