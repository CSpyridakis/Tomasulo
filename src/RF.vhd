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
-- Revision:                  0.01
-- Revision                   0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity RF is
    Port ( Ri : in  STD_LOGIC_VECTOR (4 downto 0);
           Rj : in  STD_LOGIC_VECTOR (4 downto 0);
           Rk : in  STD_LOGIC_VECTOR (4 downto 0);
           Tag_WE : in  STD_LOGIC;
           Tag_Accepted : in  STD_LOGIC_VECTOR (4 downto 0);
           CDB_Q : in  STD_LOGIC_VECTOR (4 downto 0);
           CDB_V : in  STD_LOGIC_VECTOR (31 downto 0);
           CLK : in  STD_LOGIC;
           RST : in  STD_LOGIC;
           Qj : out  STD_LOGIC_VECTOR (4 downto 0);
           Qk : out  STD_LOGIC_VECTOR (4 downto 0);
           Vj : out  STD_LOGIC_VECTOR (31 downto 0);
           Vk : out  STD_LOGIC_VECTOR (31 downto 0));
end RF;

architecture Behavioral of RF is
  
component Reg_V_Q is
  Port ( CLK : in  STD_LOGIC;
         RST : in  STD_LOGIC;
         EN : in  STD_LOGIC;
         VIN : in  STD_LOGIC_VECTOR (31 downto 0);
         QIN : in  STD_LOGIC_VECTOR (4 downto 0);
         VOUT : out  STD_LOGIC_VECTOR (31 downto 0);
         QOUT : out  STD_LOGIC_VECTOR (4 downto 0));
end component;
    
type REGISTERS is array(31 downto 0) of STD_LOGIC_VECTOR(31 downto 0);
signal V : REGISTERS := (others => (others => '0'));

-- V in/out Tmp signals 
type signal_32x32 is array (31 downto 0) of STD_LOGIC_VECTOR (31 downto 0);
signal VIN, VOUT : signal_32x32 := (others => (others => '0'));

-- Q in/out Tmp singals
type signal_32x5 is array (31 downto 0) of STD_LOGIC_VECTOR (4 downto 0);
signal QIN, QOUT : signal_32x5 := (others => (others => '0'));

-- Wen tmp signals
type signal_32x1 is array (31 downto 0) of STD_LOGIC;
signal WEN : signal_32x1 := (others => '0');

begin
  
-- Registers generate
RF_Regs : FOR n IN 31 DOWNTO 0 GENERATE
 reg:Reg_V_Q
  Port map( 
         CLK => CLK,
         RST => RST,
         EN =>WEN(n),
         VIN =>VIN(n),
         QIN =>QIN(n),
         VOUT =>VOUT(n),
         QOUT =>QOUT(n));
END GENERATE RF_Regs;
  
process(CLK, CDB_Q, Tag_WE)
begin
    
	-- CDB Broadcasting + ISSUE
	if(falling_edge(CLK)) then
	 for n in 31 DOWNTO 0 LOOP
		if (Tag_WE='1' AND n=to_integer(UNSIGNED(Ri))) then 				-- Write tag on Ri when ISSUE
		  QIN(to_integer(UNSIGNED(Ri)))<=Tag_Accepted;
		  WEN(to_integer(UNSIGNED(Ri)))<='1';
		elsif (CDB_Q/="00000" AND QOUT(n)=CDB_Q) then						-- Write CDB_V when CDB_Q = Rx_Q 
			VIN(n)<=CDB_V;
			QIN(n)<="00000";
			WEN(n)<='1';
		else
		  WEN(n)<='0';
		end if;
	 end loop;
	end if;    
     
	-- Forwarding
	if (CDB_Q/="00000" AND CDB_Q = QOUT(to_integer(UNSIGNED(Rj))) AND CDB_Q = QOUT(to_integer(UNSIGNED(Rk)))) then			-- Forward CDB_V to Rj and Rk when CDB_Q =Rj_Q and CDB_Q=Rk_Q 
	  Vj<=CDB_V;
	  Qj<="00000"; 
	  Vk<=CDB_V;
	  Qk<="00000";
	elsif (CDB_Q/="00000" AND CDB_Q = QOUT(to_integer(UNSIGNED(Rj)))) then																-- Forward CDB_V to Rj when CDB_Q =Rj_Q 
	  Vj<=CDB_V;
	  Qj<="00000";
	  Vk<=VOUT(to_integer(UNSIGNED(Rk)));
	  Qk<=QOUT(to_integer(UNSIGNED(Rk)));
	elsif (CDB_Q/="00000" AND CDB_Q = QOUT(to_integer(UNSIGNED(Rk)))) then																-- Forward CDB_V to Rk when CDB_Q =Rk_Q 
	  Vj<=VOUT(to_integer(UNSIGNED(Rj)));
	  Qj<=QOUT(to_integer(UNSIGNED(Rj))); 
	  Vk<=CDB_V;
	  Qk<="00000";
	else
	  Vj<=VOUT(to_integer(UNSIGNED(Rj)));
	  Qj<=QOUT(to_integer(UNSIGNED(Rj))); 
	  Vk<=VOUT(to_integer(UNSIGNED(Rk)));
	  Qk<=QOUT(to_integer(UNSIGNED(Rk))); 
	end if;   

end process;
end Behavioral;

