----------------------------------------------------------------------------------
-- Company/University:        Technical University of Crete (TUC) - GR
-- Engineer:                  Spyridakis Christos 
--                            Bellonias Panagiotis
-- 
-- Create Date:               10/25/2018	
-- Design Name:   
-- Module Name:               /Tomasulo/TEST_ISSUE.vhd
-- Project Name:              Tomasulo
-- Target Devices:            NONE
-- Tool versions:             Xilinx ISE 14.7 --TODO: VIVADO
-- Description:               Introduction in Dynamic Instruction Scheduling (Advanced Computer Architecture)
--                            implementing Tomasulo's Algorithm
-- 	 
-- VHDL Test Bench Created by ISE for module: ISSUE
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
 
ENTITY TEST_ISSUE IS
END TEST_ISSUE;
 
ARCHITECTURE behavior OF TEST_ISSUE IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT ISSUE
    PORT(
         CLK : IN  std_logic;
         CLK_O : OUT  std_logic;
         RST : IN  std_logic;
         RST_O : OUT  std_logic;
         A_Available : IN  std_logic;
         L_Available : IN  std_logic;
         Issue_I : IN  std_logic;
         Issue_O : OUT  std_logic;
         Fu_type : IN  std_logic_vector(1 downto 0);
         Fu_type_O : OUT  std_logic_vector(1 downto 0);
         FOP : IN  std_logic_vector(1 downto 0);
         FOP_O : OUT  std_logic_vector(1 downto 0);
         Tag_Accapted : IN  std_logic_vector(4 downto 0);
         Tag_Accapted_O : OUT  std_logic_vector(4 downto 0);
         Tag_WE : OUT  std_logic;
         Accepted : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal CLK : std_logic := '0';
   signal RST : std_logic := '0';
   signal A_Available : std_logic := '0';
   signal L_Available : std_logic := '0';
   signal Issue_I : std_logic := '0';
   signal Fu_type : std_logic_vector(1 downto 0) := (others => '0');
   signal FOP : std_logic_vector(1 downto 0) := (others => '0');
   signal Tag_Accapted : std_logic_vector(4 downto 0) := (others => '0');

 	--Outputs
   signal CLK_O : std_logic;
   signal RST_O : std_logic;
   signal Issue_O : std_logic;
   signal Fu_type_O : std_logic_vector(1 downto 0);
   signal FOP_O : std_logic_vector(1 downto 0);
   signal Tag_Accapted_O : std_logic_vector(4 downto 0);
   signal Tag_WE : std_logic;
   signal Accepted : std_logic;

   -- Clock period definitions
   constant CLK_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: ISSUE PORT MAP (
          CLK => CLK,
          CLK_O => CLK_O,
          RST => RST,
          RST_O => RST_O,
          A_Available => A_Available,
          L_Available => L_Available,
          Issue_I => Issue_I,
          Issue_O => Issue_O,
          Fu_type => Fu_type,
          Fu_type_O => Fu_type_O,
          FOP => FOP,
          FOP_O => FOP_O,
          Tag_Accapted => Tag_Accapted,
          Tag_Accapted_O => Tag_Accapted_O,
          Tag_WE => Tag_WE,
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

		------------------------------------------------------------------CC:1  RST
      RST <='1';
      A_Available <='0';
      L_Available <='0';
      Issue_I <='0';
      Fu_type <="00";
      FOP <="01";
      Tag_Accapted <="00000";
      wait for CLK_period*1;

		------------------------------------------------------------------CC:2  ARithmetic Issue Arithmetic Available
      RST <='0';
      A_Available <='1';
      L_Available <='0';
      Issue_I <='1';
      Fu_type <="01";
      FOP <="10";
      Tag_Accapted <="01001";
      wait for CLK_period*1;

		------------------------------------------------------------------CC:3  Logical Issue Logical Available 
      RST <='0';
      A_Available <='0';
      L_Available <='1';
      Issue_I <='1';
      Fu_type <="00";
      FOP <="00";
      Tag_Accapted <="00001";
      wait for CLK_period*1;
      
		------------------------------------------------------------------CC:4  Logical Issue Arithmetic Available
      RST <='0';
      A_Available <='1';
      L_Available <='0';
      Issue_I <='1';
      Fu_type <="00";
      FOP <="10";
      Tag_Accapted <="00000";
      wait for CLK_period*1;

		------------------------------------------------------------------CC:5  Arithmetic Issue Logical Available
      RST <='0';
      A_Available <='0';
      L_Available <='1';
      Issue_I <='1';
      Fu_type <="01";
      FOP <="00";
      Tag_Accapted <="00000";
      wait for CLK_period*1;
		------------------------------------------------------------------CC:6  NO ISSUE
      RST <='0';
      A_Available <='0';
      L_Available <='0';
      Issue_I <='0';
      Fu_type <="00";
      FOP <="00";
      Tag_Accapted <="00000";
      wait;
   end process;

END;
