----------------------------------------------------------------------------------
-- Company/University:        Technical University of Crete (TUC) - GR
-- Engineer:                  Spyridakis Christos 
--                            Bellonias Panagiotis
-- 
-- Create Date:               14:51:58 12/18/2018
-- Design Name:   
-- Module Name:               Τomasulo/TEST_Tomasulo.vhd
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
			PC : in  STD_LOGIC_VECTOR (31 downto 0);
         Fu_type : IN  std_logic_vector(1 downto 0);
         FOP : IN  std_logic_vector(1 downto 0);
         Ri : IN  std_logic_vector(4 downto 0);
         Rj : IN  std_logic_vector(4 downto 0);
         Rk : IN  std_logic_vector(4 downto 0);
         Immed : IN  std_logic;
         V_immed : IN  std_logic_vector(31 downto 0);
			EXCEPTION_INPUT : in STD_LOGIC_VECTOR (4 downto 0);
			EXC_PC : out  STD_LOGIC_VECTOR (31 downto 0);
			EXCEPTION : out  STD_LOGIC_VECTOR (4 downto 0);
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
   signal Immed : std_logic := '0';
   signal V_immed : std_logic_vector(31 downto 0) := (others => '0');
	signal PC : std_logic_vector(31 downto 0) := (others => '0');
	signal EXCEPTION_INPUT : STD_LOGIC_VECTOR (4 downto 0) := (others => '0');
	 
 	--Outputs
   signal Accepted : std_logic;
	signal EXC_PC : std_logic_vector(31 downto 0) := (others => '0');
	signal EXCEPTION : std_logic_vector(4 downto 0) := (others => '0');
	
   -- Clock period definitions
   constant CLK_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: Tomasulo PORT MAP (
          CLK => CLK,
          RST => RST,
          Issue_I => Issue_I,
			 PC => PC,
          Fu_type => Fu_type,
          FOP => FOP,
          Ri => Ri,
          Rj => Rj,
          Rk => Rk,
          Immed => Immed,
          V_immed => V_immed,
			 EXCEPTION_INPUT=>EXCEPTION_INPUT,
			 EXC_PC => EXC_PC,
			 EXCEPTION => EXCEPTION,
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

      ----------------------------------------------------------------CC:1    RST
		RST     <='1';
		Issue_I <='0';
		Fu_type <="00";
		FOP     <="00";
		Ri      <="00000";
		Rj      <="00000";
		Rk      <="00000";
		Immed   <='0';
		V_immed <="00000000000000000000000000000000";
		PC      <="00000000000000000000000000000001";
      wait for CLK_period*1;
		
		----------------------------------------------------------------CC:2   addi $1, $0, 1
		RST     <='0';
		Issue_I <='1';
		Fu_type <="01";
		FOP     <="00";
		Ri      <="00001";
		Rj      <="00000";
		Rk      <="00000";
		Immed   <='1';
		V_immed <="00000000000000000000000000000001";
		PC      <="00000000000000000000000000000100";
		EXCEPTION_INPUT<="00000";
      wait for CLK_period*1;
		
		
		----------------------------------------------------------------CC:3  ori $2, $1, 2
		RST     <='0';
		Issue_I <='1';
		Fu_type <="00";
		FOP     <="01";
		Ri      <="00010";
		Rj      <="00001";
		Rk      <="00000";
		Immed   <='1';
		V_immed <="00000000000000000000000000000010";
		PC      <="00000000000000000000000000001000";
		EXCEPTION_INPUT<="00000";
      wait for CLK_period*1;
		
		----------------------------------------------------------------CC:4  addi $3, $2, 1
		RST     <='0';
		Issue_I <='1';
		Fu_type <="01";
		FOP     <="00";
		Ri      <="00011";
		Rj      <="00010";
		Rk      <="00000";
		Immed   <='1';
		V_immed <="11111111111111111111111111111111";
		PC      <="00000000000000000000000000001100";
		EXCEPTION_INPUT<="00000";
      wait for CLK_period*1;
		
		----------------------------------------------------------------CC:5   ori $4, $0, 4
		RST     <='0';
		Issue_I <='1';
		Fu_type <="00";
		FOP     <="01";
		Ri      <="00100";
		Rj      <="00000";
		Rk      <="00000";
		Immed   <='1';
		V_immed <="00000000000000000000000000000100";
		PC      <="00000000000000000000000000010100";
		EXCEPTION_INPUT<="00000";
      wait for CLK_period*1;
		
		----------------------------------------------------------------CC:6   addi $5, $0, 5
		RST     <='0';
		Issue_I <='1';
		Fu_type <="01";
		FOP     <="00";
		Ri      <="00101";
		Rj      <="00000";
		Rk      <="00000";
		Immed   <='1';
		V_immed <="00000000000000000000000000000101";
		PC      <="00000000000000000000000000011000";
		EXCEPTION_INPUT<="00000";
      wait for CLK_period*1;
		
		----------------------------------------------------------------CC:7   addi $6, $0, 6
		RST     <='0';
		Issue_I <='1';
		Fu_type <="01";
		FOP     <="00";
		Ri      <="00110";
		Rj      <="00000";
		Rk      <="00000";
		Immed   <='1';
		V_immed <="00000000000000000000000000000110";
		PC      <="00000000000000000000000000001110";
		EXCEPTION_INPUT<="00000";
      wait for CLK_period*1;
		
		----------------------------------------------------------------CC:8   nop
		RST     <='0';
		Issue_I <='0';
		Fu_type <="00";
		FOP     <="00";
		Ri      <="00000";
		Rj      <="00000";
		Rk      <="00000";
		Immed   <='0';
		V_immed <="00000000000000000000000000000000";
		PC      <="00000000000000000000000000000000";
		EXCEPTION_INPUT<="00000";
      wait for CLK_period*1;

      wait;
   end process;

END;
