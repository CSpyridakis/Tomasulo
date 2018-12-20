----------------------------------------------------------------------------------
-- Company/University:        Technical University of Crete (TUC) - GR
-- Engineer:                  Spyridakis Christos 
--                            Bellonias Panagiotis
-- 
-- Create Date:   				01:22:14 12/20/2018
-- Design Name:   
-- Module Name:               Tomasulo3/TEST_ROB.vhd
-- Project Name:              Tomasulo
-- Target Devices:            NONE
-- Tool versions:             Xilinx ISE 14.7 --TODO: VIVADO
-- Description:               Introduction in Dynamic Instruction Scheduling (Advanced Computer Architecture)
--                            implementing Tomasulo's Algorithm 	 
--
-- VHDL Test Bench Created by ISE for module: ROB
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
 
ENTITY TEST_ROB IS
END TEST_ROB;
 
ARCHITECTURE behavior OF TEST_ROB IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT ROB
    PORT(
         CLK : IN  std_logic;
         RST : IN  std_logic;
         ISSUE : IN  std_logic;
         ISSUE_PC : IN  std_logic_vector(31 downto 0);
         ISSUE_I_type : IN  std_logic_vector(1 downto 0);
         ISSUE_Dest : IN  std_logic_vector(4 downto 0);
         ROB_TAG_ACCEPTED : OUT  std_logic_vector(4 downto 0);
         ISSUE_RF_Rj : IN  std_logic_vector(4 downto 0);
         ISSUE_RF_Rj_Exists : OUT  std_logic;
         ISSUE_RF_Rj_Value : OUT  std_logic_vector(31 downto 0);
         ISSUE_RF_Rj_Tag : OUT  std_logic_vector(4 downto 0);
         ISSUE_RF_Rk : IN  std_logic_vector(4 downto 0);
         ISSUE_RF_Rk_Exists : OUT  std_logic;
         ISSUE_RF_Rk_Value : OUT  std_logic_vector(31 downto 0);
         ISSUE_RF_Rk_Tag : OUT  std_logic_vector(4 downto 0);
         CDB_Q : IN  std_logic_vector(4 downto 0);
         CDB_V : IN  std_logic_vector(31 downto 0);
         DEST_RF : OUT  std_logic_vector(4 downto 0);
         DEST_MEM : OUT  std_logic_vector(4 downto 0);
         VALUE : OUT  std_logic_vector(31 downto 0);
         EXCEPTION_IN : IN  std_logic_vector(4 downto 0);
         EXCEPTION : OUT  std_logic_vector(4 downto 0);
         PC : OUT  std_logic_vector(31 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal CLK : std_logic := '0';
   signal RST : std_logic := '0';
   signal ISSUE : std_logic := '0';
   signal ISSUE_PC : std_logic_vector(31 downto 0) := (others => '0');
   signal ISSUE_I_type : std_logic_vector(1 downto 0) := (others => '0');
   signal ISSUE_Dest : std_logic_vector(4 downto 0) := (others => '0');
   signal ISSUE_RF_Rj : std_logic_vector(4 downto 0) := (others => '0');
   signal ISSUE_RF_Rk : std_logic_vector(4 downto 0) := (others => '0');
   signal CDB_Q : std_logic_vector(4 downto 0) := (others => '0');
   signal CDB_V : std_logic_vector(31 downto 0) := (others => '0');
   signal EXCEPTION_IN : std_logic_vector(4 downto 0) := (others => '0');

 	--Outputs
   signal ROB_TAG_ACCEPTED : std_logic_vector(4 downto 0);
   signal ISSUE_RF_Rj_Exists : std_logic;
   signal ISSUE_RF_Rj_Value : std_logic_vector(31 downto 0);
   signal ISSUE_RF_Rj_Tag : std_logic_vector(4 downto 0);
   signal ISSUE_RF_Rk_Exists : std_logic;
   signal ISSUE_RF_Rk_Value : std_logic_vector(31 downto 0);
   signal ISSUE_RF_Rk_Tag : std_logic_vector(4 downto 0);
   signal DEST_RF : std_logic_vector(4 downto 0);
   signal DEST_MEM : std_logic_vector(4 downto 0);
   signal VALUE : std_logic_vector(31 downto 0);
   signal EXCEPTION : std_logic_vector(4 downto 0);
   signal PC : std_logic_vector(31 downto 0);

   -- Clock period definitions
   constant CLK_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: ROB PORT MAP (
          CLK => CLK,
          RST => RST,
          ISSUE => ISSUE,
          ISSUE_PC => ISSUE_PC,
          ISSUE_I_type => ISSUE_I_type,
          ISSUE_Dest => ISSUE_Dest,
          ROB_TAG_ACCEPTED => ROB_TAG_ACCEPTED,
          ISSUE_RF_Rj => ISSUE_RF_Rj,
          ISSUE_RF_Rj_Exists => ISSUE_RF_Rj_Exists,
          ISSUE_RF_Rj_Value => ISSUE_RF_Rj_Value,
          ISSUE_RF_Rj_Tag => ISSUE_RF_Rj_Tag,
          ISSUE_RF_Rk => ISSUE_RF_Rk,
          ISSUE_RF_Rk_Exists => ISSUE_RF_Rk_Exists,
          ISSUE_RF_Rk_Value => ISSUE_RF_Rk_Value,
          ISSUE_RF_Rk_Tag => ISSUE_RF_Rk_Tag,
          CDB_Q => CDB_Q,
          CDB_V => CDB_V,
          DEST_RF => DEST_RF,
          DEST_MEM => DEST_MEM,
          VALUE => VALUE,
          EXCEPTION_IN => EXCEPTION_IN,
          EXCEPTION => EXCEPTION,
          PC => PC
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
	
		--------------------------------------------------------CC: 1 RST
		RST <='1';
		ISSUE<='0';
		ISSUE_PC <="00000000000000000000000000000000";
		ISSUE_I_type <="00";
		ISSUE_Dest <="00000";
		ISSUE_RF_Rj <="00000";
		ISSUE_RF_Rk <="00000";
		CDB_Q <="00000";
		CDB_V <="00000000000000000000000000000000";
		EXCEPTION_IN <="00000";
      wait for CLK_period*1;

		
		--------------------------------------------------------CC: 2 Nop 
		RST <='0';
		ISSUE<='0';
		ISSUE_PC <="00000000000000000000000000000000";
		ISSUE_I_type <="00";
		ISSUE_Dest <="00000";
		ISSUE_RF_Rj <="00000";
		ISSUE_RF_Rk <="00000";
		CDB_Q <="00000";
		CDB_V <="00010000000000001000000100000000";
		EXCEPTION_IN <="00000";
      wait for CLK_period*1;
		
		--------------------------------------------------------CC:3 ISSUE 1
		RST <='0';
		ISSUE<='1';
		ISSUE_PC <="00000000000000000000000000000100";
		ISSUE_I_type <="01";
		ISSUE_Dest <="00001";
		ISSUE_RF_Rj <="00000";
		ISSUE_RF_Rk <="00000";
		CDB_Q <="00000";
		CDB_V <="00000000000000000000000000000000";
		EXCEPTION_IN <="00000";
      wait for CLK_period*1;
		
		--------------------------------------------------------CC:4 ISSUE 2
		RST <='0';
		ISSUE<='1';
		ISSUE_PC <="00000000000000000000000000001000";
		ISSUE_I_type <="00";
		ISSUE_Dest <="00010";
		ISSUE_RF_Rj <="00000";
		ISSUE_RF_Rk <="00000";
		CDB_Q <="00000";
		CDB_V <="00000000000000000000000000000000";
		EXCEPTION_IN <="00000";
      wait for CLK_period*1;
		
		--------------------------------------------------------CC:5 CDB 2 ==> ROB(0)=9
		RST <='0';
		ISSUE<='0';
		ISSUE_PC <="00000000000000000000000000000000";
		ISSUE_I_type <="00";
		ISSUE_Dest <="00000";
		ISSUE_RF_Rj <="00000";
		ISSUE_RF_Rk <="00000";
		CDB_Q <="00001";
		CDB_V <="00000000000000000000000000001001";
		EXCEPTION_IN <="00000";
      wait for CLK_period*1;
		
		--------------------------------------------------------CC: 6 ISSUE 3  + ROB VALUE TAKE FROM 2
		RST <='0';
		ISSUE<='1';
		ISSUE_PC <="00000000000000000000000000001100";
		ISSUE_I_type <="01";
		ISSUE_Dest <="00011";
		ISSUE_RF_Rj <="00001";
		ISSUE_RF_Rk <="00000";
		CDB_Q <="00000";
		CDB_V <="00000000000000000000000000000000";
		EXCEPTION_IN <="00000";
      wait for CLK_period*1;
		
		--------------------------------------------------------CC: 7 Nop
		RST <='0';
		ISSUE<='0';
		ISSUE_PC <="00000000000000000000000000000000";
		ISSUE_I_type <="00";
		ISSUE_Dest <="00000";
		ISSUE_RF_Rj <="00000";
		ISSUE_RF_Rk <="00000";
		CDB_Q <="00000";
		CDB_V <="00000000000000000000000000000000";
		EXCEPTION_IN <="00000";
      wait for CLK_period*1;
		
		--------------------------------------------------------CC:8 ISSUE 4 + CDB 3 ==> ROB(1)=12
		RST <='0';
		ISSUE<='1';
		ISSUE_PC <="00000000000000000000000000010000";
		ISSUE_I_type <="00";
		ISSUE_Dest <="00100";
		ISSUE_RF_Rj <="00000";
		ISSUE_RF_Rk <="00010";
		CDB_Q <="00010";
		CDB_V <="00000000000000000000000000001100";
		EXCEPTION_IN <="00000";
      wait for CLK_period*1;
		
		--------------------------------------------------------CC:9 ISSUE 5
		RST <='0';
		ISSUE<='1';
		ISSUE_PC <="00000000000000000000000000010100";
		ISSUE_I_type <="01";
		ISSUE_Dest <="00101";
		ISSUE_RF_Rj <="00000";
		ISSUE_RF_Rk <="00000";
		CDB_Q <="00000";
		CDB_V <="00000000000000000000000000000000";
		EXCEPTION_IN <="00000";
      wait for CLK_period*1;
		
		--------------------------------------------------------CC:10 CDB 5 ==> ROB(3)=32
		RST <='0';
		ISSUE<='0';
		ISSUE_PC <="00000000000000000000000000000000";
		ISSUE_I_type <="00";
		ISSUE_Dest <="00000";
		ISSUE_RF_Rj <="00000";
		ISSUE_RF_Rk <="00000";
		CDB_Q <="00100";
		CDB_V <="00000000000000000000000000100000";
		EXCEPTION_IN <="00000";
      wait for CLK_period*1;
		
		--------------------------------------------------------CC:11 CDB 1 ==> ROB(29)=21  ++ ROB VALUE TAKE FROM 5
		RST <='0';
		ISSUE<='0';
		ISSUE_PC <="00000000000000000000000000000000";
		ISSUE_I_type <="00";
		ISSUE_Dest <="00000";
		ISSUE_RF_Rj <="00000";
		ISSUE_RF_Rk <="00100";
		CDB_Q <="11110";
		CDB_V <="00000000000000000000000000010101";
		EXCEPTION_IN <="00000";
      wait for CLK_period*1;
		
		--------------------------------------------------------CC:12 CDB 4 ==> ROB(2)=6
		RST <='0';
		ISSUE<='0';
		ISSUE_PC <="00000000000000000000000000000000";
		ISSUE_I_type <="00";
		ISSUE_Dest <="00000";
		ISSUE_RF_Rj <="00000";
		ISSUE_RF_Rk <="00000";
		CDB_Q <="00011";
		CDB_V <="00000000000000000000000000000110";
		EXCEPTION_IN <="00000";
      wait for CLK_period*1;
      -- insert stimulus here 

      wait;
   end process;

END;
