--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   21:56:43 10/23/2018
-- Design Name:   
-- Module Name:   /Tomasulo/TEST_FU.vhd
-- Project Name:  Toma23_10
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: FU
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

ENTITY TEST_FU IS
END TEST_FU;
 
ARCHITECTURE behavior OF TEST_FU IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT FU
    PORT(
         CLK : IN  std_logic;
         RST : IN  std_logic;
         A_Ready : IN  std_logic;
         A_Tag : IN  std_logic_vector(4 downto 0);
         A_Op : IN  std_logic_vector(1 downto 0);
         A_Vj : IN  std_logic_vector(31 downto 0);
         A_Vk : IN  std_logic_vector(31 downto 0);
         A_Accepted : OUT  std_logic;
         A_Request : OUT  std_logic;
         A_Grant : IN  std_logic;
         A_Q : OUT  std_logic_vector(4 downto 0);
         A_V : OUT  std_logic_vector(31 downto 0);
         L_Ready : IN  std_logic;
         L_Tag : IN  std_logic_vector(4 downto 0);
         L_Op : IN  std_logic_vector(1 downto 0);
         L_Vj : IN  std_logic_vector(31 downto 0);
         L_Vk : IN  std_logic_vector(31 downto 0);
         L_Accepted : OUT  std_logic;
         L_Request : OUT  std_logic;
         L_Grant : IN  std_logic;
         L_Q : OUT  std_logic_vector(4 downto 0);
         L_V : OUT  std_logic_vector(31 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal CLK : std_logic := '0';
   signal RST : std_logic := '0';
   signal A_Ready : std_logic := '0';
   signal A_Tag : std_logic_vector(4 downto 0) := (others => '0');
   signal A_Op : std_logic_vector(1 downto 0) := (others => '0');
   signal A_Vj : std_logic_vector(31 downto 0) := (others => '0');
   signal A_Vk : std_logic_vector(31 downto 0) := (others => '0');
   signal A_Grant : std_logic := '0';
   signal L_Ready : std_logic := '0';
   signal L_Tag : std_logic_vector(4 downto 0) := (others => '0');
   signal L_Op : std_logic_vector(1 downto 0) := (others => '0');
   signal L_Vj : std_logic_vector(31 downto 0) := (others => '0');
   signal L_Vk : std_logic_vector(31 downto 0) := (others => '0');
   signal L_Grant : std_logic := '0';

 	--Outputs
   signal A_Accepted : std_logic;
   signal A_Request : std_logic;
   signal A_Q : std_logic_vector(4 downto 0);
   signal A_V : std_logic_vector(31 downto 0);
   signal L_Accepted : std_logic;
   signal L_Request : std_logic;
   signal L_Q : std_logic_vector(4 downto 0);
   signal L_V : std_logic_vector(31 downto 0);

   -- Clock period definitions
   constant CLK_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: FU PORT MAP (
          CLK => CLK,
          RST => RST,
          A_Ready => A_Ready,
          A_Tag => A_Tag,
          A_Op => A_Op,
          A_Vj => A_Vj,
          A_Vk => A_Vk,
          A_Accepted => A_Accepted,
          A_Request => A_Request,
          A_Grant => A_Grant,
          A_Q => A_Q,
          A_V => A_V,
          L_Ready => L_Ready,
          L_Tag => L_Tag,
          L_Op => L_Op,
          L_Vj => L_Vj,
          L_Vk => L_Vk,
          L_Accepted => L_Accepted,
          L_Request => L_Request,
          L_Grant => L_Grant,
          L_Q => L_Q,
          L_V => L_V
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
		---------------------------------------------------------------------- CLK=1 | RST
		RST        <='1';
		
		A_Ready    <='0';
		A_Grant 	  <='0';
		A_Tag      <="00000";
		A_Op       <="00";
		A_Vj       <="00000000000000000000000000000000";
		A_Vk       <="00000000000000000000000000000000";
		
		L_Ready    <='0';
		L_Grant    <='0';
		L_Tag      <="00000";
		L_Op       <="00";
		L_Vj       <="00000000000000000000000000000000";
		L_Vk       <="00000000000000000000000000000000";
      wait for CLK_period*1;

		---------------------------------------------------------------------- CLK=2 
		RST        <='0';
		---------------------------INPUT: {A RS 1} <= {1} + {1} | RESULT: CC=3 {01001} = 2
		A_Ready    <='1';
		A_Grant 	  <='0';
		A_Tag      <="01001";
		A_Op       <="00";
		A_Vj       <="00000000000000000000000000000001";
		A_Vk       <="00000000000000000000000000000001";
		--------------------------- Nop
		L_Ready    <='0';
		L_Grant    <='0';
		L_Tag      <="00000";
		L_Op       <="00";
		L_Vj       <="00000000000000000000000000000000";
		L_Vk       <="00000000000000000000000000000000";
      wait for CLK_period*1;



		---------------------------------------------------------------------- CLK=3 
		RST        <='0';
		--------------------------- Nop
		A_Ready    <='0';
		A_Grant 	  <='0';
		A_Tag      <="00000";
		A_Op       <="00";
		A_Vj       <="00000000000000000000000000000000";
		A_Vk       <="00000000000000000000000000000000";
		--------------------------- INPUT: {L RS 2} <= {1} OR {2}  | RESULT: CC= 5 {00010} = 3
		L_Ready    <='1';
		L_Grant    <='0';
		L_Tag      <="00010";
		L_Op       <="01";
		L_Vj       <="00000000000000000000000000000001";
		L_Vk       <="00000000000000000000000000000010";
      wait for CLK_period*1;
		
		
		
		---------------------------------------------------------------------- CLK=4
		RST        <='0';
		--------------------------- INPUT: {A RS 3} <= {5} - {2}  | RESULT: CC= 7 {01011} = 3
		A_Ready    <='1';
		A_Grant 	  <='0';
		A_Tag      <="01011";
		A_Op       <="01";
		A_Vj       <="00000000000000000000000000000101";
		A_Vk       <="00000000000000000000000000000010";
		--------------------------- INPUT: {L RS 1} <= {10} AND {6}  | RESULT: CC= 6 {00001} = 2
		L_Ready    <='1';
		L_Grant    <='0';
		L_Tag      <="00001";
		L_Op       <="00";
		L_Vj       <="00000000000000000000000000001010";
		L_Vk       <="00000000000000000000000000000110";
      wait for CLK_period*1;
		
		
		---------------------------------------------------------------------- CLK=5
		RST        <='0';
		--------------------------- Nop
		A_Ready    <='0';
		A_Grant 	  <='1';
		A_Tag      <="00000";
		A_Op       <="00";
		A_Vj       <="00000000000000000000000000000000";
		A_Vk       <="00000000000000000000000000000010";
		--------------------------- Nop
		L_Ready    <='0';
		L_Grant    <='0';
		L_Tag      <="00000";
		L_Op       <="00";
		L_Vj       <="00000000000000000000000000000000";
		L_Vk       <="00000000000000000000000000000000";
      wait for CLK_period*1;		

		---------------------------------------------------------------------- CLK=6
		RST        <='0';
		--------------------------- Nop
		A_Ready    <='0';
		A_Grant 	  <='0';
		A_Tag      <="00000";
		A_Op       <="00";
		A_Vj       <="00000000000000000000000000000000";
		A_Vk       <="00000000000000000000000000000010";
		--------------------------- Nop
		L_Ready    <='0';
		L_Grant    <='1';
		L_Tag      <="00000";
		L_Op       <="00";
		L_Vj       <="00000000000000000000000000000000";
		L_Vk       <="00000000000000000000000000000000";
      wait for CLK_period*1;	
		
		---------------------------------------------------------------------- CLK=7
		RST        <='0';
		--------------------------- Nop
		A_Ready    <='0';
		A_Grant 	  <='0';
		A_Tag      <="00000";
		A_Op       <="00";
		A_Vj       <="00000000000000000000000000000000";
		A_Vk       <="00000000000000000000000000000010";
		--------------------------- Nop
		L_Ready    <='0';
		L_Grant    <='0';
		L_Tag      <="00000";
		L_Op       <="00";
		L_Vj       <="00000000000000000000000000000000";
		L_Vk       <="00000000000000000000000000000000";
      wait for CLK_period*1;	
      wait;
   end process;

END;
