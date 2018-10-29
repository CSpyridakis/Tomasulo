--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   00:51:17 10/29/2018
-- Design Name:   
-- Module Name:   /home/chspyman/Desktop/VHDL/Tomasulo29/TEST_RF.vhd
-- Project Name:  Tomasulo29
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: RF
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
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY TEST_RF IS
END TEST_RF;
 
ARCHITECTURE behavior OF TEST_RF IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT RF
    PORT(
         Ri : IN  std_logic_vector(4 downto 0);
         Rj : IN  std_logic_vector(4 downto 0);
         Rk : IN  std_logic_vector(4 downto 0);
         Tag_WE : IN  std_logic;
         Tag_Accepted : IN  std_logic_vector(4 downto 0);
         CDB_Q : IN  std_logic_vector(4 downto 0);
         CDB_V : IN  std_logic_vector(31 downto 0);
         CLK : IN  std_logic;
         RST : IN  std_logic;
         Qj : OUT  std_logic_vector(4 downto 0);
         Qk : OUT  std_logic_vector(4 downto 0);
         Vj : OUT  std_logic_vector(31 downto 0);
         Vk : OUT  std_logic_vector(31 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal Ri : std_logic_vector(4 downto 0) := (others => '0');
   signal Rj : std_logic_vector(4 downto 0) := (others => '0');
   signal Rk : std_logic_vector(4 downto 0) := (others => '0');
   signal Tag_WE : std_logic := '0';
   signal Tag_Accepted : std_logic_vector(4 downto 0) := (others => '0');
   signal CDB_Q : std_logic_vector(4 downto 0) := (others => '0');
   signal CDB_V : std_logic_vector(31 downto 0) := (others => '0');
   signal CLK : std_logic := '0';
   signal RST : std_logic := '0';

 	--Outputs
   signal Qj : std_logic_vector(4 downto 0);
   signal Qk : std_logic_vector(4 downto 0);
   signal Vj : std_logic_vector(31 downto 0);
   signal Vk : std_logic_vector(31 downto 0);

   -- Clock period definitions
   constant CLK_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: RF PORT MAP (
          Ri => Ri,
          Rj => Rj,
          Rk => Rk,
          Tag_WE => Tag_WE,
          Tag_Accepted => Tag_Accepted,
          CDB_Q => CDB_Q,
          CDB_V => CDB_V,
          CLK => CLK,
          RST => RST,
          Qj => Qj,
          Qk => Qk,
          Vj => Vj,
          Vk => Vk
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

	   ----------------------------------------------------------------------------CC: 1 RST
		RST          <='1';
		Ri           <="00000";
		Rj           <="00000";
		Rk           <="00000";
		Tag_WE       <='0';
		Tag_Accepted <="00000";
		CDB_Q        <="00000";
		CDB_V        <="00000000000000000000000000000000";
      wait for CLK_period*1;

		----------------------------------------------------------------------------CC: 2 Write R1_Q=4
		RST          <='0';
      Tag_WE       <='1';		
      Ri           <="00001";
      Tag_Accepted <="00100";
		Rj           <="00010";
		Rk           <="00011";
		CDB_Q        <="00000";
		CDB_V        <="00000000000000000000000000000000";
      wait for CLK_period*1;
      
		----------------------------------------------------------------------------CC: 3 Write R5_Q=17 Read R1 + CDB_Q=4
		RST          <='0';
      Tag_WE       <='1';		
      Ri           <="00101";
      Tag_Accepted <="10001";
		Rj           <="00001";
		Rk           <="00011";
		CDB_Q        <="00100";
		CDB_V        <="00000000000000000000000000001010";
      wait for CLK_period*1;
		
		----------------------------------------------------------------------------CC: 4 Nop
		RST          <='0';
      Tag_WE       <='0';		
      Ri           <="00000";
      Tag_Accepted <="00000";
		Rj           <="00000";
		Rk           <="00000";
		CDB_Q        <="00000";
		CDB_V        <="00000000000000000000000000000000";
      wait for CLK_period*1;
		
      wait;
   end process;

END;
