----------------------------------------------------------------------------------
-- Company/University:        Technical University of Crete (TUC) - GR
-- Engineer:                  Spyridakis Christos 
--                            Bellonias Panagiotis
-- 
-- Create Date:   				19:58:59 12/18/2018
-- Design Name:   
-- Module Name:   				Tomasulo/TEST_ROB_Reg.vhd
-- Project Name:  				Tomasulo
-- Target Devices:            NONE
-- Tool versions:             Xilinx ISE 14.7 --TODO: VIVADO
-- Description:               Introduction in Dynamic Instruction Scheduling (Advanced Computer Architecture)
--                            implementing Tomasulo's Algorithm 	 
--
-- VHDL Test Bench Created by ISE for module: ROB_Reg
-- 
-- Dependencies:					NONE
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
 
ENTITY TEST_ROB_Reg IS
END TEST_ROB_Reg;
 
ARCHITECTURE behavior OF TEST_ROB_Reg IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT ROB_Reg
    PORT(
         CLK : IN  std_logic;
         RST : IN  std_logic;
         MY_TAG : IN  std_logic_vector(4 downto 0);
         ISSUE : IN  std_logic;
         ISSUE_PC : IN  std_logic_vector(31 downto 0);
         ISSUE_I_type : IN  std_logic_vector(1 downto 0);
         ISSUE_Dest : IN  std_logic_vector(4 downto 0);
         CDB_Q : IN  std_logic_vector(4 downto 0);
         CDB_V : IN  std_logic_vector(31 downto 0);
         I_EXCEPTION : IN  std_logic_vector(4 downto 0);
         EXECUTED : OUT  std_logic;
         POP : IN  std_logic;
         DEST_RF : OUT  std_logic_vector(4 downto 0);
         DEST_MEM : OUT  std_logic_vector(4 downto 0);
         VALUE : OUT  std_logic_vector(31 downto 0);
         EXCEPTION : OUT  std_logic_vector(4 downto 0);
         PC : OUT  std_logic_vector(31 downto 0);
         TAG : OUT  std_logic_vector(4 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal CLK : std_logic := '0';
   signal RST : std_logic := '0';
   signal MY_TAG : std_logic_vector(4 downto 0) := (others => '0');
   signal ISSUE : std_logic := '0';
   signal ISSUE_PC : std_logic_vector(31 downto 0) := (others => '0');
   signal ISSUE_I_type : std_logic_vector(1 downto 0) := (others => '0');
   signal ISSUE_Dest : std_logic_vector(4 downto 0) := (others => '0');
   signal CDB_Q : std_logic_vector(4 downto 0) := (others => '0');
   signal CDB_V : std_logic_vector(31 downto 0) := (others => '0');
   signal I_EXCEPTION : std_logic_vector(4 downto 0) := (others => '0');
   signal POP : std_logic := '0';

 	--Outputs
   signal EXECUTED : std_logic;
   signal DEST_RF : std_logic_vector(4 downto 0);
   signal DEST_MEM : std_logic_vector(4 downto 0);
   signal VALUE : std_logic_vector(31 downto 0);
   signal EXCEPTION : std_logic_vector(4 downto 0);
   signal PC : std_logic_vector(31 downto 0);
   signal TAG : std_logic_vector(4 downto 0);

   -- Clock period definitions
   constant CLK_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: ROB_Reg PORT MAP (
          CLK => CLK,
          RST => RST,
          MY_TAG => MY_TAG,
          ISSUE => ISSUE,
          ISSUE_PC => ISSUE_PC,
          ISSUE_I_type => ISSUE_I_type,
          ISSUE_Dest => ISSUE_Dest,
          CDB_Q => CDB_Q,
          CDB_V => CDB_V,
          I_EXCEPTION => I_EXCEPTION,
          EXECUTED => EXECUTED,
          POP => POP,
          DEST_RF => DEST_RF,
          DEST_MEM => DEST_MEM,
          VALUE => VALUE,
          EXCEPTION => EXCEPTION,
          PC => PC,
          TAG => TAG
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

		-------------------------------------------------------CC:1 RST
		RST          <='1';
		MY_TAG       <="00100";
		wait for CLK_period*1;
		
		-------------------------------------------------------CC:2 Nop (Empty)
		RST          <='0';
		ISSUE        <='0';
		ISSUE_PC     <="00000000000000000000000000000011";
		ISSUE_I_type <="10";
		ISSUE_Dest   <="10000";
		CDB_Q        <="01010";
		CDB_V        <="00000000000000000000000000011111";
		I_EXCEPTION  <="00000";
		POP          <='0';
		wait for CLK_period*1;

		-------------------------------------------------------CC:3 ISSUE	Arithmetical that write to reg 1
		RST          <='0';
		ISSUE        <='1';
		ISSUE_PC     <="00000000000000000000000000000011";
		ISSUE_I_type <="00";
		ISSUE_Dest   <="00001";
		CDB_Q        <="01000";
		CDB_V        <="00000000000000000000000000111111";
		I_EXCEPTION  <="00000";
		POP          <='0';
		wait for CLK_period*1;		

		-------------------------------------------------------CC:4 Nop (Saved values exist)
		RST          <='0';
		ISSUE        <='0';
		ISSUE_PC     <="00000000000000000000000000010011";
		ISSUE_I_type <="10";
		ISSUE_Dest   <="10001";
		CDB_Q        <="01010";
		CDB_V        <="00010000000000000000000000111111";
		I_EXCEPTION  <="00000";
		POP          <='0';
		wait for CLK_period*1;	
		
		-------------------------------------------------------CC:5 Nopx2 (Saved values exist)
		RST          <='0';
		ISSUE        <='0';
		ISSUE_PC     <="00000000000000000000000000011011";
		ISSUE_I_type <="11";
		ISSUE_Dest   <="10011";
		CDB_Q        <="01110";
		CDB_V        <="00010001000000000000000000111111";
		I_EXCEPTION  <="00000";
		POP          <='0';
		wait for CLK_period*2;	
		
		-------------------------------------------------------CC:7 Update
		RST          <='0';
		ISSUE        <='0';
		ISSUE_PC     <="00000000000000000000000000011111";
		ISSUE_I_type <="00";
		ISSUE_Dest   <="11011";
		CDB_Q        <="00100";
		CDB_V        <="00000000000000000000000000001010";
		I_EXCEPTION  <="00000";
		POP          <='0';
		wait for CLK_period*1;	
		
		-------------------------------------------------------CC:8 Nop 
		RST          <='0';
		ISSUE        <='0';
		ISSUE_PC     <="00000000000000000000000000000111";
		ISSUE_I_type <="10";
		ISSUE_Dest   <="10010";
		CDB_Q        <="00110";
		CDB_V        <="00010010000000000000000000001010";
		I_EXCEPTION  <="00000";
		POP          <='0';
		wait for CLK_period*1;	
		
		-------------------------------------------------------CC:10 POP
		RST          <='0';
		ISSUE        <='0';
		ISSUE_PC     <="00000000000000000000000000000010";
		ISSUE_I_type <="01";
		ISSUE_Dest   <="00011";
		CDB_Q        <="00101";
		CDB_V        <="00000000000000000000010001001010";
		I_EXCEPTION  <="00000";
		POP          <='1';
		wait for CLK_period*1;
		
		-------------------------------------------------------CC:11 Nop x 3
		RST          <='0';
		ISSUE        <='0';
		ISSUE_PC     <="00000000000000000000000000000000";
		ISSUE_I_type <="00";
		ISSUE_Dest   <="00000";
		CDB_Q        <="00000";
		CDB_V        <="00000000000000000000000000000000";
		I_EXCEPTION  <="00000";
		POP          <='0';
		wait for CLK_period*3;
		
		-------------------------------------------------------CC:14 ISSUE
		RST          <='0';
		ISSUE        <='1';
		ISSUE_PC     <="00000000000000000000000000000010";
		ISSUE_I_type <="01";
		ISSUE_Dest   <="00011";
		CDB_Q        <="10000";
		CDB_V        <="00000000000000000000000000000001";
		I_EXCEPTION  <="00000";
		POP          <='0';
		wait for CLK_period*1;
		
		-------------------------------------------------------CC:15 Nop x 2
		RST          <='0';
		ISSUE        <='0';
		ISSUE_PC     <="00000000000000000000000000000000";
		ISSUE_I_type <="00";
		ISSUE_Dest   <="00000";
		CDB_Q        <="00000";
		CDB_V        <="00000000000000000000000000000000";
		I_EXCEPTION  <="00000";
		POP          <='0';
		wait for CLK_period*2;
		
		-------------------------------------------------------CC:17 Exception
		RST          <='0';
		ISSUE        <='0';
		ISSUE_PC     <="00000000000000000000000000000000";
		ISSUE_I_type <="00";
		ISSUE_Dest   <="00000";
		CDB_Q        <="00000";
		CDB_V        <="00000000000000000000000000000000";
		I_EXCEPTION  <="01011";
		POP          <='0';
		wait for CLK_period*1;
		
		-------------------------------------------------------CC:18 Nop x 2
		RST          <='0';
		ISSUE        <='0';
		ISSUE_PC     <="00000000000000000000000000000000";
		ISSUE_I_type <="00";
		ISSUE_Dest   <="00000";
		CDB_Q        <="00000";
		CDB_V        <="00000000000000000000000000000000";
		I_EXCEPTION  <="00000";
		POP          <='0';
		wait for CLK_period*2;
		
      wait;
   end process;

END;
