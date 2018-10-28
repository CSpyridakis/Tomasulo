----------------------------------------------------------------------------------
-- Company/University:        Technical University of Crete (TUC) - GR
-- Engineer:                  Spyridakis Christos 
--                            Bellonias Panagiotis
-- 
-- Create Date:   				22:19:27 10/28/2018
-- Design Name:   
-- Module Name:               /Tomasulo/TEST_RS.vhd
-- Project Name:              Tomasulo
-- Target Devices:            NONE
-- Tool versions:             Xilinx ISE 14.7 --TODO: VIVADO
-- Description:               Introduction in Dynamic Instruction Scheduling (Advanced Computer Architecture)
--                            implementing Tomasulo's Algorithm 	 
--
-- VHDL Test Bench Created by ISE for module: RS
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
 
ENTITY TEST_RS IS
END TEST_RS;
 
ARCHITECTURE behavior OF TEST_RS IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT RS
    PORT(
         CLK : IN  std_logic;
         RST : IN  std_logic;
         A_Available : OUT  std_logic;
         L_Available : OUT  std_logic;
         ISSUE : IN  std_logic;
         FU_type : IN  std_logic_vector(1 downto 0);
         FOP : IN  std_logic_vector(1 downto 0);
         Vj : IN  std_logic_vector(31 downto 0);
         Qj : IN  std_logic_vector(4 downto 0);
         Vk : IN  std_logic_vector(31 downto 0);
         Qk : IN  std_logic_vector(4 downto 0);
         Tag_Accepted : OUT  std_logic_vector(4 downto 0);
         CDB_V : IN  std_logic_vector(31 downto 0);
         CDB_Q : IN  std_logic_vector(4 downto 0);
         A_Ready : OUT  std_logic;
         A_Op : OUT  std_logic_vector(1 downto 0);
         A_Vj : OUT  std_logic_vector(31 downto 0);
         A_Vk : OUT  std_logic_vector(31 downto 0);
         A_Tag : OUT  std_logic_vector(4 downto 0);
         A_Accepted : IN  std_logic_vector(4 downto 0);
         L_Ready : OUT  std_logic;
         L_Op : OUT  std_logic_vector(1 downto 0);
         L_Vj : OUT  std_logic_vector(31 downto 0);
         L_Vk : OUT  std_logic_vector(31 downto 0);
         L_Tag : OUT  std_logic_vector(4 downto 0);
         L_Accepted : IN  std_logic_vector(4 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal CLK : std_logic := '0';
   signal RST : std_logic := '0';
   signal ISSUE : std_logic := '0';
   signal FU_type : std_logic_vector(1 downto 0) := (others => '0');
   signal FOP : std_logic_vector(1 downto 0) := (others => '0');
   signal Vj : std_logic_vector(31 downto 0) := (others => '0');
   signal Qj : std_logic_vector(4 downto 0) := (others => '0');
   signal Vk : std_logic_vector(31 downto 0) := (others => '0');
   signal Qk : std_logic_vector(4 downto 0) := (others => '0');
   signal CDB_V : std_logic_vector(31 downto 0) := (others => '0');
   signal CDB_Q : std_logic_vector(4 downto 0) := (others => '0');
   signal A_Accepted : std_logic_vector(4 downto 0) := (others => '0');
   signal L_Accepted : std_logic_vector(4 downto 0) := (others => '0');

 	--Outputs
   signal A_Available : std_logic;
   signal L_Available : std_logic;
   signal Tag_Accepted : std_logic_vector(4 downto 0);
   signal A_Ready : std_logic;
   signal A_Op : std_logic_vector(1 downto 0);
   signal A_Vj : std_logic_vector(31 downto 0);
   signal A_Vk : std_logic_vector(31 downto 0);
   signal A_Tag : std_logic_vector(4 downto 0);
   signal L_Ready : std_logic;
   signal L_Op : std_logic_vector(1 downto 0);
   signal L_Vj : std_logic_vector(31 downto 0);
   signal L_Vk : std_logic_vector(31 downto 0);
   signal L_Tag : std_logic_vector(4 downto 0);

   -- Clock period definitions
   constant CLK_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: RS PORT MAP (
          CLK => CLK,
          RST => RST,
          A_Available => A_Available,
          L_Available => L_Available,
          ISSUE => ISSUE,
          FU_type => FU_type,
          FOP => FOP,
          Vj => Vj,
          Qj => Qj,
          Vk => Vk,
          Qk => Qk,
          Tag_Accepted => Tag_Accepted,
          CDB_V => CDB_V,
          CDB_Q => CDB_Q,
          A_Ready => A_Ready,
          A_Op => A_Op,
          A_Vj => A_Vj,
          A_Vk => A_Vk,
          A_Tag => A_Tag,
          A_Accepted => A_Accepted,
          L_Ready => L_Ready,
          L_Op => L_Op,
          L_Vj => L_Vj,
          L_Vk => L_Vk,
          L_Tag => L_Tag,
          L_Accepted => L_Accepted
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

      
		------------------------------------------------------------------------CC: 1  RST
      RST        <='1';
		ISSUE      <='0';
		FU_type    <="00";
		FOP        <="00";
		Vj         <="00000000000000000000000000000000";
		Qj         <="00000";
		Vk         <="00000000000000000000000000000000";
		Qk         <="00000";
		CDB_V      <="00000000000000000000000000000000";
		CDB_Q      <="00000";
		A_Accepted <="00000";
		L_Accepted <="00000";
		wait for CLK_period*1;
		
		
		------------------------------------------------------------------------CC: 2  L1=Logical ISSUE NON READY (WAITING FOR 01011)
		RST        <='0';
		ISSUE      <='1';
		FU_type    <="00";
		FOP        <="01";
		Vj         <="00000000000000000000000000000111";
		Qj         <="01011";
		Vk         <="00000000000000000000000000000001";
		Qk         <="00000";
		CDB_V      <="00000000000000000000000000000000";
		CDB_Q      <="00000";
		A_Accepted <="00000";
		L_Accepted <="00000";
		wait for CLK_period*1;
		
		------------------------------------------------------------------------CC: 3  A1=Arithmetic ISSUE READY + CDB 01011
		RST        <='0';
		ISSUE      <='1';
		FU_type    <="01";
		FOP        <="01";
		Vj         <="00000000000000000000000000000010";
		Qj         <="00000";
		Vk         <="00000000000000000000000000000011";
		Qk         <="00000";
		CDB_V      <="00000000000000000000000000000100";
		CDB_Q      <="01011";
		A_Accepted <="00000";
		L_Accepted <="00000";
		wait for CLK_period*1;
		
		------------------------------------------------------------------------CC: 4  A2=Arithmetic ISSUE NON READY (01001 waiting) + A1 accepted + L1 accepted  
		RST        <='0';
		ISSUE      <='1';
		FU_type    <="01";
		FOP        <="01";
		Vj         <="00000000000000000000000000000100";
		Qj         <="00000";
		Vk         <="00000000000000000000000000000000";
		Qk         <="01001";
		CDB_V      <="00000000000000000000000000000000";
		CDB_Q      <="00000";
		A_Accepted <="01001";
		L_Accepted <="00001";
		wait for CLK_period*1;
		
		---------------------------------------------------------------------CC: 5 Nop
		RST        <='0';
		ISSUE      <='0';
		FU_type    <="00";
		FOP        <="00";
		Vj         <="00000000000000000000000000000000";
		Qj         <="00000";
		Vk         <="00000000000000000000000000000000";
		Qk         <="00000";
		CDB_V      <="00000000000000000000000000000000";
		CDB_Q      <="00000";
		A_Accepted <="00000";
		L_Accepted <="00000";
		wait for CLK_period*1;
		
		------------------------------------------------------------------------CC: 6  A1 DONE 
		RST        <='0';
		ISSUE      <='0';
		FU_type    <="00";
		FOP        <="00";
		Vj         <="00000000000000000000000000000000";
		Qj         <="00000";
		Vk         <="00000000000000000000000000000000";
		Qk         <="00000";
		CDB_V      <="00000000000000000000000001111111";
		CDB_Q      <="01001";
		A_Accepted <="00000";
		L_Accepted <="00000";
		wait for CLK_period*1;
		
		---------------------------------------------------------------------CC: 7 Nop
		RST        <='0';
		ISSUE      <='0';
		FU_type    <="00";
		FOP        <="00";
		Vj         <="00000000000000000000000000000000";
		Qj         <="00000";
		Vk         <="00000000000000000000000000000000";
		Qk         <="00000";
		CDB_V      <="00000000000000000000000000000000";
		CDB_Q      <="00000";
		A_Accepted <="00000";
		L_Accepted <="00000";
		wait for CLK_period*1;
		
      wait;
   end process;

END;
