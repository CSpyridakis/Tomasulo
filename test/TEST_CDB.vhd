--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   17:02:06 10/27/2018
-- Design Name:   
-- Module Name:   /home/pb/Xilinx/PC_Architecture/TEST_CDB.vhd
-- Project Name:  PC_Architecture
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: CDB
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
 
ENTITY TEST_CDB IS
END TEST_CDB;
 
ARCHITECTURE behavior OF TEST_CDB IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT CDB
    PORT(
         A_REQUEST : IN  std_logic;
         A_V : IN  std_logic_vector(31 downto 0);
         A_Q : IN  std_logic_vector(4 downto 0);
         L_REQUEST : IN  std_logic;
         L_V : IN  std_logic_vector(31 downto 0);
         L_Q : IN  std_logic_vector(4 downto 0);
         RST : IN  std_logic;
         CLK : IN  std_logic;
         A_GRAND : OUT  std_logic;
         L_GRAND : OUT  std_logic;
         CDB_V : OUT  std_logic_vector(31 downto 0);
         CDB_Q : OUT  std_logic_vector(4 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal A_REQUEST : std_logic := '0';
   signal A_V : std_logic_vector(31 downto 0) := (others => '0');
   signal A_Q : std_logic_vector(4 downto 0) := (others => '0');
   signal L_REQUEST : std_logic := '0';
   signal L_V : std_logic_vector(31 downto 0) := (others => '0');
   signal L_Q : std_logic_vector(4 downto 0) := (others => '0');
   signal RST : std_logic := '0';
   signal CLK : std_logic := '0';

 	--Outputs
   signal A_GRAND : std_logic;
   signal L_GRAND : std_logic;
   signal CDB_V : std_logic_vector(31 downto 0);
   signal CDB_Q : std_logic_vector(4 downto 0);

   -- Clock period definitions
   constant CLK_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: CDB PORT MAP (
          A_REQUEST => A_REQUEST,
          A_V => A_V,
          A_Q => A_Q,
          L_REQUEST => L_REQUEST,
          L_V => L_V,
          L_Q => L_Q,
          RST => RST,
          CLK => CLK,
          A_GRAND => A_GRAND,
          L_GRAND => L_GRAND,
          CDB_V => CDB_V,
          CDB_Q => CDB_Q
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
			A_REQUEST <='0';
			A_V <="00000000000000000000000000000001";
         A_Q <= "00001";
         L_REQUEST <='0';
         L_V <= "00000000000000000000000000001101";
         L_Q <= "00101";
         RST <= '1';
      wait for CLK_period*1;
		A_REQUEST <='1';
			A_V <="00000000000000000000000000000001";
         A_Q <= "00001";
         L_REQUEST <='0';
         L_V <= "00000000000000000000000000001101";
         L_Q <= "00101";
         RST <= '0';
      wait for CLK_period*1;
		A_REQUEST <='0';
			A_V <="00000000000000000000000000000001";
         A_Q <= "00001";
         L_REQUEST <='1';
         L_V <= "00000000000000000000000000001101";
         L_Q <= "00101";
         RST <= '0';
      wait for CLK_period*1;
		A_REQUEST <='1';
			A_V <="00000000000000000000000000000001";
         A_Q <= "00001";
         L_REQUEST <='1';
         L_V <= "00000000000000000000000000001101";
         L_Q <= "00101";
         RST <= '0';
      wait for CLK_period*1;
		A_REQUEST <='1';
			A_V <="00000000000000000000000000000001";
         A_Q <= "00001";
         L_REQUEST <='1';
         L_V <= "00000000000000000000000000001101";
         L_Q <= "00101";
         RST <= '0';
      wait for CLK_period*1;
		A_REQUEST <='1';
			A_V <="00000000000000000000000000000001";
         A_Q <= "00001";
         L_REQUEST <='1';
         L_V <= "00000000000000000000000000001101";
         L_Q <= "00101";
         RST <= '1';
      wait for CLK_period*1;

      -- insert stimulus here 

      wait;
   end process;

END;
