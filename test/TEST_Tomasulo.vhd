----------------------------------------------------------------------------------
-- Company/University:        Technical University of Crete (TUC) - GR
-- Engineer:                  Spyridakis Christos 
--                            Bellonias Panagiotis
-- 
-- Create Date:               21:57:52 11/07/2018
-- Design Name:   
-- Module Name:               Tomasulo/TEST_Tomasulo.vhd
-- Project Name:              Tomasulo
-- Target Devices:            NONE
-- Tool versions:             Xilinx ISE 14.7 --TODO: VIVADO
-- Description:               Introduction in Dynamic Instruction Scheduling (Advanced Computer Architecture)
--                            implementing Tomasulo's Algorithm 	 
--   
-- 
-- VHDL Test Bench Created by ISE for module: Tomasulo
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
ENTITY TEST_Tomasulo IS
END TEST_Tomasulo;
 
ARCHITECTURE behavior OF TEST_Tomasulo IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT Tomasulo
    PORT(
         CLK : IN  std_logic;
         RST : IN  std_logic;
         Issue_I : IN  std_logic;
         Fu_type : IN  std_logic_vector(1 downto 0);
         FOP : IN  std_logic_vector(1 downto 0);
         Ri : IN  std_logic_vector(4 downto 0);
         Rj : IN  std_logic_vector(4 downto 0);
         Rk : IN  std_logic_vector(4 downto 0);
         Accepted : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal CLK : std_logic := '0';
   signal RST : std_logic := '0';
   signal Issue_I : std_logic := '0';
   signal Fu_type : std_logic_vector(1 downto 0) := (others => '0');
   signal FOP : std_logic_vector(1 downto 0) := (others => '0');
   signal Ri : std_logic_vector(4 downto 0) := (others => '0');
   signal Rj : std_logic_vector(4 downto 0) := (others => '0');
   signal Rk : std_logic_vector(4 downto 0) := (others => '0');

 	--Outputs
   signal Accepted : std_logic;

   -- Clock period definitions
   constant CLK_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: Tomasulo PORT MAP (
          CLK => CLK,
          RST => RST,
          Issue_I => Issue_I,
          Fu_type => Fu_type,
          FOP => FOP,
          Ri => Ri,
          Rj => Rj,
          Rk => Rk,
          Accepted => Accepted
        );

   -- Clock process definitions
   CLK_process :process
   begin
		CLK <= '0';
		wait for CLK_period/2;
		CLK <= '1';
		wait for CLK_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for 100 ns;	

		----------------------------------------------------------------CC:0    RST
		RST     <='1';
		Issue_I <='0';
		Fu_type <="00";
		FOP     <="00";
		Ri      <="00000";
		Rj      <="00000";
		Rk      <="00000";
      wait for CLK_period*1;
		
		----------------------------------------------------------------CC:1   add $2, $0, $0
		RST     <='0';
		Issue_I <='1';
		Fu_type <="01";
		FOP     <="00";
		Ri      <="00010";
		Rj      <="00000";
		Rk      <="00000";
      wait for CLK_period*1;
		
		----------------------------------------------------------------CC:2   or $3,$2,$0
		RST     <='0';
		Issue_I <='1';
		Fu_type <="00";
		FOP     <="01";
		Ri      <="00011";
		Rj      <="00010";
		Rk      <="00000";
      wait for CLK_period*1;
		
		
		----------------------------------------------------------------CC:3   sub $4,$0,$0
		RST     <='0';
		Issue_I <='1';
		Fu_type <="01";
		FOP     <="01";
		Ri      <="00100";
		Rj      <="00000";
		Rk      <="00000";
      wait for CLK_period*1;
		
		
		----------------------------------------------------------------CC:4  not $5,$0,$0
		RST     <='0';
		Issue_I <='1';
		Fu_type <="00";
		FOP     <="10";
		Ri      <="00101";
		Rj      <="00000";
		Rk      <="00000";
      wait for CLK_period*1;
	
		
		----------------------------------------------------------------CC:5   shift $6,$3,$0
		RST     <='0';
		Issue_I <='1';
		Fu_type <="01";
		FOP     <="10";
		Ri      <="00110";
		Rj      <="00011";
		Rk      <="00000";
      wait for CLK_period*1;
		
		
		----------------------------------------------------------------CC:6   and $7,$4,$0
		RST     <='0';
		Issue_I <='1';
		Fu_type <="00";
		FOP     <="00";
		Ri      <="00111";
		Rj      <="00100";
		Rk      <="00000";
      wait for CLK_period*1;
		
		
		----------------------------------------------------------------CC:7  and $7,$4,$0 x2
		RST     <='0';
		Issue_I <='1';
		Fu_type <="00";
		FOP     <="00";
		Ri      <="00111";
		Rj      <="00100";
		Rk      <="00000";
      wait for CLK_period*2;
		
		
		----------------------------------------------------------------CC:8 sub $8,$2,$0
		RST     <='0';
		Issue_I <='1';
		Fu_type <="01";
		FOP     <="01";
		Ri      <="01000";
		Rj      <="00010";
		Rk      <="00000";
      wait for CLK_period*1;
		
		
		----------------------------------------------------------------CC:9 and $9,$3,$5
		RST     <='0';
		Issue_I <='1';
		Fu_type <="00";
		FOP     <="00";
		Ri      <="01001";
		Rj      <="00011";
		Rk      <="00101";
      wait for CLK_period*1;
		
		
		----------------------------------------------------------------CC:10 shift $9,$2,$0
		RST     <='0';
		Issue_I <='1';
		Fu_type <="01";
		FOP     <="10";
		Ri      <="01001";
		Rj      <="00010";
		Rk      <="00000";
      wait for CLK_period*1;
		
		
		----------------------------------------------------------------CC:11 Nop
		RST     <='0';
		Issue_I <='0';
		Fu_type <="00";
		FOP     <="00";
		Ri      <="00000";
		Rj      <="00000";
		Rk      <="00000";
      wait for CLK_period*1;
		
		
		----------------------------------------------------------------CC:12
		RST     <='0';
		Issue_I <='0';
		Fu_type <="00";
		FOP     <="00";
		Ri      <="00000";
		Rj      <="00000";
		Rk      <="00000";
      wait for CLK_period*1;
		
		
		
		----------------------------------------------------------------CC:13
		RST     <='0';
		Issue_I <='0';
		Fu_type <="00";
		FOP     <="00";
		Ri      <="00000";
		Rj      <="00000";
		Rk      <="00000";
      wait for CLK_period*1;
		
		
		----------------------------------------------------------------CC:14
		RST     <='0';
		Issue_I <='0';
		Fu_type <="00";
		FOP     <="00";
		Ri      <="00000";
		Rj      <="00000";
		Rk      <="00000";
      wait for CLK_period*1;
		
		
		----------------------------------------------------------------CC:15
		RST     <='0';
		Issue_I <='0';
		Fu_type <="00";
		FOP     <="00";
		Ri      <="00000";
		Rj      <="00000";
		Rk      <="00000";
      wait for CLK_period*1;
		
		
		----------------------------------------------------------------CC:16
		RST     <='0';
		Issue_I <='0';
		Fu_type <="00";
		FOP     <="00";
		Ri      <="00000";
		Rj      <="00000";
		Rk      <="00000";
      wait for CLK_period*1;
		
		
		----------------------------------------------------------------CC:17
		RST     <='0';
		Issue_I <='0';
		Fu_type <="00";
		FOP     <="00";
		Ri      <="00000";
		Rj      <="00000";
		Rk      <="00000";
      wait for CLK_period*1;
		
		
		
      wait;
   end process;

END;
