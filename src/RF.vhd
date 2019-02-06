----------------------------------------------------------------------------------
-- Company/University:        Technical University of Crete (TUC) - GR
-- Engineer:                  Spyridakis Christos 
--                            Bellonias Panagiotis
-- 
-- Create Date:               10/22/2018
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
-- Revision:                  2.1
-- Revision                   2.1 - ROB
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity RF is
    Port ( CLK : in  STD_LOGIC;
           RST : in  STD_LOGIC;
           Ri : in  STD_LOGIC_VECTOR (4 downto 0);
           Rj : in  STD_LOGIC_VECTOR (4 downto 0);
           Rk : in  STD_LOGIC_VECTOR (4 downto 0);
           Tag_WE : in  STD_LOGIC;
           ROB_Tag_Accepted : in  STD_LOGIC_VECTOR (4 downto 0);
           ROB_Q : in  STD_LOGIC_VECTOR (4 downto 0);
           ROB_V : in  STD_LOGIC_VECTOR (31 downto 0);
           ROB_DEST : in  STD_LOGIC_VECTOR (4 downto 0);
           Tag_Rj : out  STD_LOGIC_VECTOR (4 downto 0);
           Tag_Rk : out  STD_LOGIC_VECTOR (4 downto 0);
           Qj : out  STD_LOGIC_VECTOR (4 downto 0);
           Qk : out  STD_LOGIC_VECTOR (4 downto 0);
           Vj : out  STD_LOGIC_VECTOR (31 downto 0);
           Vk : out  STD_LOGIC_VECTOR (31 downto 0));
end RF;

architecture Behavioral of RF is

component RF_Reg is
    Port ( CLK : in  STD_LOGIC;
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
end component;

-- Vout Tmp signals 
type signal_32x32 is array (31 downto 0) of STD_LOGIC_VECTOR (31 downto 0);
signal VOUT : signal_32x32 := (others => (others => '0'));

-- Qout Tmp singals
type signal_32x5 is array (31 downto 0) of STD_LOGIC_VECTOR (4 downto 0);
signal QOUT : signal_32x5 := (others => (others => '0'));

begin

-- Read Registers
process(Rj, Rk)
begin 
	  Vj<=VOUT(to_integer(UNSIGNED(Rj)));
	  Qj<=QOUT(to_integer(UNSIGNED(Rj))); 
	  Vk<=VOUT(to_integer(UNSIGNED(Rk)));
	  Qk<=QOUT(to_integer(UNSIGNED(Rk)));
	  
	  Tag_Rj <= QOUT(to_integer(UNSIGNED(Rj)));
	  Tag_Rk <= QOUT(to_integer(UNSIGNED(Rk)));  
end process;

-- Registers 0
QOUT(0) <= "00000";
VOUT(0) <= "00000000000000000000000000000000";

-- Registers 1
Reg1 : RF_Reg
Port map( CLK          => CLK,
          RST          => RST,
          ID           => "00001",
          Ri           => Ri,
          Tag_WE       => Tag_WE,
          ROB_Tag_Accepted => ROB_Tag_Accepted,
          ROB_Q        => ROB_Q,
          ROB_V        => ROB_V,
          ROB_DEST     => ROB_DEST,
          Q            => QOUT(1),
          V            => VOUT(1));

-- Registers 2
Reg2 : RF_Reg
Port map( CLK          => CLK,
          RST          => RST,
          ID           => "00010",
          Ri           => Ri,
          Tag_WE       => Tag_WE,
          ROB_Tag_Accepted => ROB_Tag_Accepted,
          ROB_Q        => ROB_Q,
          ROB_V        => ROB_V,
          ROB_DEST     => ROB_DEST,
          Q            => QOUT(2),
          V            => VOUT(2));

-- Registers 3
Reg3 : RF_Reg
Port map( CLK          => CLK,
          RST          => RST,
          ID           => "00011",
          Ri           => Ri,
          Tag_WE       => Tag_WE,
          ROB_Tag_Accepted => ROB_Tag_Accepted,
          ROB_Q        => ROB_Q,
          ROB_V        => ROB_V,
          ROB_DEST     => ROB_DEST,
          Q            => QOUT(3),
          V            => VOUT(3));

-- Registers 4
Reg4 : RF_Reg
Port map( CLK          => CLK,
          RST          => RST,
          ID           => "00100",
          Ri           => Ri,
          Tag_WE       => Tag_WE,
          ROB_Tag_Accepted => ROB_Tag_Accepted,
          ROB_Q        => ROB_Q,
          ROB_V        => ROB_V,
          ROB_DEST     => ROB_DEST,
          Q            => QOUT(4),
          V            => VOUT(4));

-- Registers 5
Reg5 : RF_Reg
Port map( CLK          => CLK,
          RST          => RST,
          ID           => "00101",
          Ri           => Ri,
          Tag_WE       => Tag_WE,
          ROB_Tag_Accepted => ROB_Tag_Accepted,
          ROB_Q        => ROB_Q,
          ROB_V        => ROB_V,
          ROB_DEST     => ROB_DEST,
          Q            => QOUT(5),
          V            => VOUT(5));

-- Registers 6
Reg6 : RF_Reg
Port map( CLK          => CLK,
          RST          => RST,
          ID           => "00110",
          Ri           => Ri,
          Tag_WE       => Tag_WE,
          ROB_Tag_Accepted => ROB_Tag_Accepted,
          ROB_Q        => ROB_Q,
          ROB_V        => ROB_V,
          ROB_DEST     => ROB_DEST,
          Q            => QOUT(6),
          V            => VOUT(6));

-- Registers 7
Reg7 : RF_Reg
Port map( CLK          => CLK,
          RST          => RST,
          ID           => "00111",
          Ri           => Ri,
          Tag_WE       => Tag_WE,
          ROB_Tag_Accepted => ROB_Tag_Accepted,
          ROB_Q        => ROB_Q,
          ROB_V        => ROB_V,
          ROB_DEST     => ROB_DEST,
          Q            => QOUT(7),
          V            => VOUT(7));

-- Registers 8
Reg8 : RF_Reg
Port map( CLK          => CLK,
          RST          => RST,
          ID           => "01000",
          Ri           => Ri,
          Tag_WE       => Tag_WE,
          ROB_Tag_Accepted => ROB_Tag_Accepted,
          ROB_Q        => ROB_Q,
          ROB_V        => ROB_V,
          ROB_DEST     => ROB_DEST,
          Q            => QOUT(8),
          V            => VOUT(8));

-- Registers 9
Reg9 : RF_Reg
Port map( CLK          => CLK,
          RST          => RST,
          ID           => "01001",
          Ri           => Ri,
          Tag_WE       => Tag_WE,
          ROB_Tag_Accepted => ROB_Tag_Accepted,
          ROB_Q        => ROB_Q,
          ROB_V        => ROB_V,
          ROB_DEST     => ROB_DEST,
          Q            => QOUT(9),
          V            => VOUT(9));

-- Registers 10
Reg10 : RF_Reg
Port map( CLK          => CLK,
          RST          => RST,
          ID           => "01010",
          Ri           => Ri,
          Tag_WE       => Tag_WE,
          ROB_Tag_Accepted => ROB_Tag_Accepted,
          ROB_Q        => ROB_Q,
          ROB_V        => ROB_V,
          ROB_DEST     => ROB_DEST,
          Q            => QOUT(10),
          V            => VOUT(10));

-- Registers 11
Reg11 : RF_Reg
Port map( CLK          => CLK,
          RST          => RST,
          ID           => "01011",
          Ri           => Ri,
          Tag_WE       => Tag_WE,
          ROB_Tag_Accepted => ROB_Tag_Accepted,
          ROB_Q        => ROB_Q,
          ROB_V        => ROB_V,
          ROB_DEST     => ROB_DEST,
          Q            => QOUT(11),
          V            => VOUT(11));

-- Registers 12
Reg12 : RF_Reg
Port map( CLK          => CLK,
          RST          => RST,
          ID           => "01100",
          Ri           => Ri,
          Tag_WE       => Tag_WE,
          ROB_Tag_Accepted => ROB_Tag_Accepted,
          ROB_Q        => ROB_Q,
          ROB_V        => ROB_V,
          ROB_DEST     => ROB_DEST,
          Q            => QOUT(12),
          V            => VOUT(12));

-- Registers 13
Reg13 : RF_Reg
Port map( CLK          => CLK,
          RST          => RST,
          ID           => "01101",
          Ri           => Ri,
          Tag_WE       => Tag_WE,
          ROB_Tag_Accepted => ROB_Tag_Accepted,
          ROB_Q        => ROB_Q,
          ROB_V        => ROB_V,
          ROB_DEST     => ROB_DEST,
          Q            => QOUT(13),
          V            => VOUT(13));

-- Registers 14
Reg14 : RF_Reg
Port map( CLK          => CLK,
          RST          => RST,
          ID           => "01110",
          Ri           => Ri,
          Tag_WE       => Tag_WE,
          ROB_Tag_Accepted => ROB_Tag_Accepted,
          ROB_Q        => ROB_Q,
          ROB_V        => ROB_V,
          ROB_DEST     => ROB_DEST,
          Q            => QOUT(14),
          V            => VOUT(14));

-- Registers 15
Reg15 : RF_Reg
Port map( CLK          => CLK,
          RST          => RST,
          ID           => "01111",
          Ri           => Ri,
          Tag_WE       => Tag_WE,
          ROB_Tag_Accepted => ROB_Tag_Accepted,
          ROB_Q        => ROB_Q,
          ROB_V        => ROB_V,
          ROB_DEST     => ROB_DEST,
          Q            => QOUT(15),
          V            => VOUT(15));

-- Registers 16
Reg16 : RF_Reg
Port map( CLK          => CLK,
          RST          => RST,
          ID           => "10000",
          Ri           => Ri,
          Tag_WE       => Tag_WE,
          ROB_Tag_Accepted => ROB_Tag_Accepted,
          ROB_Q        => ROB_Q,
          ROB_V        => ROB_V,
          ROB_DEST     => ROB_DEST,
          Q            => QOUT(16),
          V            => VOUT(16));

-- Registers 17
Reg17 : RF_Reg
Port map( CLK          => CLK,
          RST          => RST,
          ID           => "10001",
          Ri           => Ri,
          Tag_WE       => Tag_WE,
          ROB_Tag_Accepted => ROB_Tag_Accepted,
          ROB_Q        => ROB_Q,
          ROB_V        => ROB_V,
          ROB_DEST     => ROB_DEST,
          Q            => QOUT(17),
          V            => VOUT(17));

-- Registers 18
Reg18 : RF_Reg
Port map( CLK          => CLK,
          RST          => RST,
          ID           => "10010",
          Ri           => Ri,
          Tag_WE       => Tag_WE,
          ROB_Tag_Accepted => ROB_Tag_Accepted,
          ROB_Q        => ROB_Q,
          ROB_V        => ROB_V,
          ROB_DEST     => ROB_DEST,
          Q            => QOUT(18),
          V            => VOUT(18));

-- Registers 19
Reg19 : RF_Reg
Port map( CLK          => CLK,
          RST          => RST,
          ID           => "10011",
          Ri           => Ri,
          Tag_WE       => Tag_WE,
          ROB_Tag_Accepted => ROB_Tag_Accepted,
          ROB_Q        => ROB_Q,
          ROB_V        => ROB_V,
          ROB_DEST     => ROB_DEST,
          Q            => QOUT(19),
          V            => VOUT(19));

-- Registers 20
Reg20 : RF_Reg
Port map( CLK          => CLK,
          RST          => RST,
          ID           => "10100",
          Ri           => Ri,
          Tag_WE       => Tag_WE,
          ROB_Tag_Accepted => ROB_Tag_Accepted,
          ROB_Q        => ROB_Q,
          ROB_V        => ROB_V,
          ROB_DEST     => ROB_DEST,
          Q            => QOUT(20),
          V            => VOUT(20));

-- Registers 21
Reg21 : RF_Reg
Port map( CLK          => CLK,
          RST          => RST,
          ID           => "10101",
          Ri           => Ri,
          Tag_WE       => Tag_WE,
          ROB_Tag_Accepted => ROB_Tag_Accepted,
          ROB_Q        => ROB_Q,
          ROB_V        => ROB_V,
          ROB_DEST     => ROB_DEST,
          Q            => QOUT(21),
          V            => VOUT(21));

-- Registers 22
Reg22 : RF_Reg
Port map( CLK          => CLK,
          RST          => RST,
          ID           => "10110",
          Ri           => Ri,
          Tag_WE       => Tag_WE,
          ROB_Tag_Accepted => ROB_Tag_Accepted,
          ROB_Q        => ROB_Q,
          ROB_V        => ROB_V,
          ROB_DEST     => ROB_DEST,
          Q            => QOUT(22),
          V            => VOUT(22));

-- Registers 23
Reg23 : RF_Reg
Port map( CLK          => CLK,
          RST          => RST,
          ID           => "10111",
          Ri           => Ri,
          Tag_WE       => Tag_WE,
          ROB_Tag_Accepted => ROB_Tag_Accepted,
          ROB_Q        => ROB_Q,
          ROB_V        => ROB_V,
          ROB_DEST     => ROB_DEST,
          Q            => QOUT(23),
          V            => VOUT(23));

-- Registers 24
Reg24 : RF_Reg
Port map( CLK          => CLK,
          RST          => RST,
          ID           => "11000",
          Ri           => Ri,
          Tag_WE       => Tag_WE,
          ROB_Tag_Accepted => ROB_Tag_Accepted,
          ROB_Q        => ROB_Q,
          ROB_V        => ROB_V,
          ROB_DEST     => ROB_DEST,
          Q            => QOUT(24),
          V            => VOUT(24));

-- Registers 25
Reg25 : RF_Reg
Port map( CLK          => CLK,
          RST          => RST,
          ID           => "11001",
          Ri           => Ri,
          Tag_WE       => Tag_WE,
          ROB_Tag_Accepted => ROB_Tag_Accepted,
          ROB_Q        => ROB_Q,
          ROB_V        => ROB_V,
          ROB_DEST     => ROB_DEST,
          Q            => QOUT(25),
          V            => VOUT(25));

-- Registers 26
Reg26 : RF_Reg
Port map( CLK          => CLK,
          RST          => RST,
          ID           => "11010",
          Ri           => Ri,
          Tag_WE       => Tag_WE,
          ROB_Tag_Accepted => ROB_Tag_Accepted,
          ROB_Q        => ROB_Q,
          ROB_V        => ROB_V,
          ROB_DEST     => ROB_DEST,
          Q            => QOUT(26),
          V            => VOUT(26));

-- Registers 27
Reg27 : RF_Reg
Port map( CLK          => CLK,
          RST          => RST,
          ID           => "11011",
          Ri           => Ri,
          Tag_WE       => Tag_WE,
          ROB_Tag_Accepted => ROB_Tag_Accepted,
          ROB_Q        => ROB_Q,
          ROB_V        => ROB_V,
          ROB_DEST     => ROB_DEST,
          Q            => QOUT(27),
          V            => VOUT(27));

-- Registers 28
Reg28 : RF_Reg
Port map( CLK          => CLK,
          RST          => RST,
          ID           => "11100",
          Ri           => Ri,
          Tag_WE       => Tag_WE,
          ROB_Tag_Accepted => ROB_Tag_Accepted,
          ROB_Q        => ROB_Q,
          ROB_V        => ROB_V,
          ROB_DEST     => ROB_DEST,
          Q            => QOUT(28),
          V            => VOUT(28));

-- Registers 29
Reg29 : RF_Reg
Port map( CLK          => CLK,
          RST          => RST,
          ID           => "11101",
          Ri           => Ri,
          Tag_WE       => Tag_WE,
          ROB_Tag_Accepted => ROB_Tag_Accepted,
          ROB_Q        => ROB_Q,
          ROB_V        => ROB_V,
          ROB_DEST     => ROB_DEST,
          Q            => QOUT(29),
          V            => VOUT(29));

-- Registers 30
Reg30 : RF_Reg
Port map( CLK          => CLK,
          RST          => RST,
          ID           => "11110",
          Ri           => Ri,
          Tag_WE       => Tag_WE,
          ROB_Tag_Accepted => ROB_Tag_Accepted,
          ROB_Q        => ROB_Q,
          ROB_V        => ROB_V,
          ROB_DEST     => ROB_DEST,
          Q            => QOUT(30),
          V            => VOUT(30));

-- Registers 31
Reg31 : RF_Reg
Port map( CLK          => CLK,
          RST          => RST,
          ID           => "11111",
          Ri           => Ri,
          Tag_WE       => Tag_WE,
          ROB_Tag_Accepted => ROB_Tag_Accepted,
          ROB_Q        => ROB_Q,
          ROB_V        => ROB_V,
          ROB_DEST     => ROB_DEST,
          Q            => QOUT(31),
          V            => VOUT(31));
			  
end Behavioral;

