----------------------------------------------------------------------------------
-- Company/University:        Technical University of Crete (TUC) - GR
-- Engineer:                  Spyridakis Christos 
--                            Bellonias Panagiotis
-- 
-- Create Date:               10/22/2018
-- Design Name: 	 
-- Module Name:               Reg_V_Q - Behavioral 
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

entity Reg_V_Q is
    Port ( CLK : in  STD_LOGIC;
           RST : in  STD_LOGIC;
           EN : in  STD_LOGIC;
           VIN : in  STD_LOGIC_VECTOR (31 downto 0);
           QIN : in  STD_LOGIC_VECTOR (4 downto 0);
           VOUT : out  STD_LOGIC_VECTOR (31 downto 0);
           QOUT : out  STD_LOGIC_VECTOR (4 downto 0));
end Reg_V_Q;

architecture Behavioral of Reg_V_Q is

-- REGISTER FOR STORING VALUE - 32 bits
component Reg_32bits 
    Port ( CLK  : in  STD_LOGIC;
           RST  : in  STD_LOGIC;
           EN   : in  STD_LOGIC;
           INN  : in  STD_LOGIC_VECTOR (31 downto 0);
           OUTT : out  STD_LOGIC_VECTOR (31 downto 0));
end component;

-- REGISTER FOR STORING TAG	- 5 bits
component Reg_5bits is
    Port ( CLK  : in  STD_LOGIC;
           RST  : in  STD_LOGIC;
           EN   : in  STD_LOGIC;
           INN  : in  STD_LOGIC_VECTOR (4 downto 0);
           OUTT : out STD_LOGIC_VECTOR (4 downto 0));
end component;

begin
v_reg : Reg_32bits
Port map( CLK  => CLK,
          RST  => RST,
          EN   => EN,
          INN  => VIN,
          OUTT => VOUT);

q_reg : Reg_5bits
Port map( CLK  => CLK,
          RST  => RST,
          EN   => EN,
          INN  => QIN,
          OUTT => QOUT);
end Behavioral;

