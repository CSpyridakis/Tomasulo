----------------------------------------------------------------------------------
-- Company/University:        Technical University of Crete (TUC) - GR
-- Engineer:                  Spyridakis Christos 
--                            Bellonias Panagiotis
-- Create Date:   				18:35:19 10/26/2018
-- Design Name:   
-- Module Name:   				/Tomasulo/TEST_Reg_RS.vhd
-- Project Name:              Tomasulo
-- Target Devices:            NONE
-- Tool versions:             Xilinx ISE 14.7 --TODO: VIVADO
-- Description:               Introduction in Dynamic Instruction Scheduling (Advanced Computer Architecture)
--                            implementing Tomasulo's Algorithm 	 
--
-- 
-- VHDL Test Bench Created by ISE for module: Reg_RS
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
 
ENTITY TEST_Reg_RS IS
END TEST_Reg_RS;
 
ARCHITECTURE behavior OF TEST_Reg_RS IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT Reg_RS
    PORT(
         CLK : IN  std_logic;
         RST : IN  std_logic;
         ID : IN  std_logic_vector(4 downto 0);
         Available : OUT  std_logic;
         ISSUE : IN  std_logic;
         Op_ISSUE : IN  std_logic_vector(1 downto 0);
         Vj_ISSUE : IN  std_logic_vector(31 downto 0);
         Qj : IN  std_logic_vector(4 downto 0);
         Vk_ISSUE : IN  std_logic_vector(31 downto 0);
         Qk : IN  std_logic_vector(4 downto 0);
         CDB_V : IN  std_logic_vector(31 downto 0);
         CDB_Q : IN  std_logic_vector(4 downto 0);
         Ready : OUT  std_logic;
         Op : OUT  std_logic_vector(1 downto 0);
         Tag : OUT  std_logic_vector(4 downto 0);
         Vj : OUT  std_logic_vector(31 downto 0);
         Vk : OUT  std_logic_vector(31 downto 0);
         Accepted : IN  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal CLK : std_logic := '0';
   signal RST : std_logic := '0';
   signal ID : std_logic_vector(4 downto 0) := (others => '0');
   signal ISSUE : std_logic := '0';
   signal Op_ISSUE : std_logic_vector(1 downto 0) := (others => '0');
   signal Vj_ISSUE : std_logic_vector(31 downto 0) := (others => '0');
   signal Qj : std_logic_vector(4 downto 0) := (others => '0');
   signal Vk_ISSUE : std_logic_vector(31 downto 0) := (others => '0');
   signal Qk : std_logic_vector(4 downto 0) := (others => '0');
   signal CDB_V : std_logic_vector(31 downto 0) := (others => '0');
   signal CDB_Q : std_logic_vector(4 downto 0) := (others => '0');
   signal Accepted : std_logic := '0';

 	--Outputs
   signal Available : std_logic;
   signal Ready : std_logic;
   signal Op : std_logic_vector(1 downto 0);
   signal Tag : std_logic_vector(4 downto 0);
   signal Vj : std_logic_vector(31 downto 0);
   signal Vk : std_logic_vector(31 downto 0);

   -- Clock period definitions
   constant CLK_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: Reg_RS PORT MAP (
          CLK => CLK,
          RST => RST,
          ID => ID,
          Available => Available,
          ISSUE => ISSUE,
          Op_ISSUE => Op_ISSUE,
          Vj_ISSUE => Vj_ISSUE,
          Qj => Qj,
          Vk_ISSUE => Vk_ISSUE,
          Qk => Qk,
          CDB_V => CDB_V,
          CDB_Q => CDB_Q,
          Ready => Ready,
          Op => Op,
          Tag => Tag,
          Vj => Vj,
          Vk => Vk,
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
		
		
		ID <="10101";
		
		------------------------------------------------------------CC:1
		RST <='1';
		--
		ISSUE <='0';
		Op_ISSUE <="01";
		Vj_ISSUE <="00000000000000000000000000000000";
		Qj <="00000";
		Vk_ISSUE <="00000000000000000000000000000000";
		Qk <="00000";
		--
		CDB_V <="00000000000000000000000000000000";
		CDB_Q <="00000";
		--
		Accepted <='0';
      wait for CLK_period*1;

      ------------------------------------------------------------CC:2
		RST <='0';
		--
		ISSUE <='0';
		Op_ISSUE <="00";
		Vj_ISSUE <="00000000000000000000000000000000";
		Qj <="00000";
		Vk_ISSUE <="00000000000000000000000000000000";
		Qk <="00000";
		--
		CDB_V <="00000000000000000000000000000000";
		CDB_Q <="00000";
		--
		Accepted <='0';
      wait for CLK_period*3;
		
		------------------------------------------------------------CC:6   ISSUE with k valid
		RST <='0';
		--
		ISSUE <='1';
		Op_ISSUE <="01";
		Vj_ISSUE <="00000000000000000000000000000001";
		Qj <="00001";
		Vk_ISSUE <="00000000000000000000000000000010";
		Qk <="00000";
		--
		CDB_V <="00000000000000000000000000000000";
		CDB_Q <="00000";
		--
		Accepted <='0';
      wait for CLK_period*1;

		------------------------------------------------------------CC:7   CDB_Q = J_Q
		RST <='0';
		--
		ISSUE <='0';
		Op_ISSUE <="11";
		Vj_ISSUE <="00000000000000000000000000000010";
		Qj <="01000";
		Vk_ISSUE <="00000000100000000100000000000000";
		Qk <="01010";
		--
		CDB_V <="00000000000000000000000000000100";
		CDB_Q <="00001";
		--
		Accepted <='0';
      wait for CLK_period*1;
		
		------------------------------------------------------------CC:8   RS Accepted
		RST <='0';
		--
		ISSUE <='0';
		Op_ISSUE <="10";
		Vj_ISSUE <="00000010000000000000100001000000";
		Qj <="01010";
		Vk_ISSUE <="00000010000000001000000001000000";
		Qk <="01001";
		--
		CDB_V <="00001000000000001000000000000100";
		CDB_Q <="00011";
		--
		Accepted <='1';
      wait for CLK_period*1;
		
		------------------------------------------------------------CC:9   STALL
		RST <='0';
		--
		ISSUE <='0';
		Op_ISSUE <="00";
		Vj_ISSUE <="10000000000000000001000000000000";
		Qj <="01000";
		Vk_ISSUE <="00000000000001000000000000000000";
		Qk <="01010";
		--
		CDB_V <="00000000000000001000000000000100";
		CDB_Q <="00110";
		--
		Accepted <='0';
      wait for CLK_period*2;

		------------------------------------------------------------CC:11   Operation Completed
		RST <='0';
		--
		ISSUE <='0';
		Op_ISSUE <="01";
		Vj_ISSUE <="10000000100000100001000010000000";
		Qj <="01110";
		Vk_ISSUE <="00000000100001001000000010000000";
		Qk <="01011";
		--
		CDB_V <="00000000000000001000000000000100";
		CDB_Q <="10101";
		--
		Accepted <='0';
      wait for CLK_period*1;
		
		---------------------------------------------------------CC:12   END
		RST <='0';
		--
		ISSUE <='0';
		Op_ISSUE <="10";
		Vj_ISSUE <="10000000100000100001011110000000";
		Qj <="01011";
		Vk_ISSUE <="00000000100001001000100010000000";
		Qk <="00011";
		--
		CDB_V <="00000000010010001000000010100100";
		CDB_Q <="10010";
		--
		Accepted <='0';
      wait for CLK_period*1;      wait;
   end process;

END;
