----------------------------------------------------------------------------------
-- Company/University:        Technical University of Crete (TUC) - GR
-- Engineer:                  Spyridakis Christos 
--                            Bellonias Panagiotis
-- 
-- Create Date:                
-- Design Name: 	 
-- Module Name:               ROB - Behavioral 
-- Project Name:              Tomasulo
-- Target Devices:            NONE
-- Tool versions:             Xilinx ISE 14.7 --TODO: VIVADO
-- Description:               Introduction in Dynamic Instruction Scheduling (Advanced Computer Architecture)
--                            implementing Tomasulo's Algorithm 	 
--
-- Dependencies:              NONE
--
-- Revision:                  2.0 
-- Revision                   2.0 - ROB
-- Additional Comments: 
--
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity ROB is
 Port (    CLK : in  STD_LOGIC;
           RST : in  STD_LOGIC;
			  
			  --ISSUE
			  ISSUE : in STD_LOGIC;
			  ISSUE_PC : in STD_LOGIC_VECTOR (31 downto 0);
			  ISSUE_I_type : in STD_LOGIC_VECTOR (1 downto 0);
			  ISSUE_Dest : in STD_LOGIC_VECTOR (4 downto 0);
			  ROB_TAG_ACCEPTED :out STD_LOGIC_VECTOR (4 downto 0);
			  
			  --FROM CDB (UPDATE QUEUE)
			  CDB_Q: in STD_LOGIC_VECTOR (4 downto 0);
			  CDB_V : in STD_LOGIC_VECTOR (31 downto 0);
			  
			  --POP
			  DEST_RF : out STD_LOGIC_VECTOR (4 downto 0);
			  DEST_MEM : out STD_LOGIC_VECTOR (4 downto 0);
			  VALUE : out STD_LOGIC_VECTOR (31 downto 0); 
			  
			  --EXCEPTION HANDLER
			  EXCEPTION : out STD_LOGIC_VECTOR (4 downto 0);
			  PC : out STD_LOGIC_VECTOR (31 downto 0));
end ROB;

architecture Behavioral of ROB is

component ROB_Reg is
 Port (    CLK : in  STD_LOGIC;
           RST : in  STD_LOGIC;
			  MY_TAG : in STD_LOGIC_VECTOR (4 downto 0);
			  
			  --FROM ISSUE (PUSH INTO QUEUE)
			  ISSUE : in STD_LOGIC;
			  ISSUE_PC : in STD_LOGIC_VECTOR (31 downto 0);
			  ISSUE_I_type : in STD_LOGIC_VECTOR (1 downto 0);
			  ISSUE_Dest : in STD_LOGIC_VECTOR (4 downto 0);

			  --FROM CDB (UPDATE QUEUE)
			  CDB_Q: in STD_LOGIC_VECTOR (4 downto 0);
			  CDB_V : in STD_LOGIC_VECTOR (31 downto 0);

			  --EXCEPTION
           I_EXCEPTION : in STD_LOGIC_VECTOR (4 downto 0);
			  
			  --TO RF/MEM (POP FROM QUEUE, only if instruction has been executed)
			  EXECUTED : out STD_LOGIC;
			  POP : in STD_LOGIC;
			  DEST_RF : out STD_LOGIC_VECTOR (4 downto 0);
			  DEST_MEM : out STD_LOGIC_VECTOR (4 downto 0);
			  VALUE : out STD_LOGIC_VECTOR (31 downto 0); 
			  
			  --EXCEPTION HANDLER
			  EXCEPTION : out STD_LOGIC_VECTOR (4 downto 0);
			  PC : out STD_LOGIC_VECTOR (31 downto 0);
			  
			  --MY TAG AND STATUS
			  EMPTY : out  STD_LOGIC;
			  TAG : out STD_LOGIC_VECTOR (4 downto 0));
end component;


type signal_30x32 is array (29 downto 0) of STD_LOGIC_VECTOR (31 downto 0);
type signal_30x5 is array (29 downto 0) of STD_LOGIC_VECTOR (4 downto 0);
type signal_30x2 is array (29 downto 0) of STD_LOGIC_VECTOR (1 downto 0);
type signal_30x1 is array (29 downto 0) of STD_LOGIC;

--ISSUE (PUSH) 
signal S_PC : signal_30x32 := (others => (others => '0'));
signal S_I_TYPE : signal_30x2 := (others => (others => '0'));
signal S_DEST : signal_30x5 := (others => (others => '0'));
signal S_ISSUE : signal_30x1 := "000000000000000000000000000000";	--CONTROL SIGNAL

--EXCEPTION
signal S_EXCEPTION_IN : signal_30x5 := (others => (others => '0'));
signal S_EXCEPTION : signal_30x5 := (others => (others => '0'));

--POP
signal S_EXECUTED : signal_30x1 := "000000000000000000000000000000";	
signal S_DEST_RF : signal_30x5 := (others => (others => '0'));
signal S_DEST_MEM : signal_30x5 := (others => (others => '0'));
signal S_VALUE : signal_30x32 := (others => (others => '0'));
signal S_POP: signal_30x1 := "000000000000000000000000000000";			--CONTROL SIGNAL

--ROB SLOT EXTRA INFO AND CONTROL
signal S_TAG : signal_30x5 := (others => (others => '0'));
signal S_EMPTY : signal_30x1 := "000000000000000000000000000000";	
signal S_RST : signal_30x1 := "000000000000000000000000000000";		--CONTROL SIGNAL


signal ISSUE_POINTER, COMMIT_POINTER : integer range 0 to 29 :=0; 
--variable F, S : integer;


--DEBUG SIGNAL
TYPE STATES_SIGNALS IS (INIT_S, RST_S, PUSH_S_LOW, PUSH_S_HIGH, UPDATE_S, POP_S, EXCEPTION_S, NONE_S);  
SIGNAL LAST : STATES_SIGNALS := INIT_S;

begin		  

ROB_TAG_ACCEPTED <= S_TAG(ISSUE_POINTER+1) WHEN ISSUE_POINTER+1<30 ELSE S_TAG(0);
			  
DEST_RF   <= S_DEST_RF(COMMIT_POINTER) WHEN S_POP(COMMIT_POINTER)='1' ELSE "00000";
DEST_MEM  <= S_DEST_MEM(COMMIT_POINTER) WHEN S_POP(COMMIT_POINTER)='1' ELSE "00000";
VALUE     <= S_VALUE(COMMIT_POINTER) WHEN S_POP(COMMIT_POINTER)='1' ELSE "00000000000000000000000000000000";

EXCEPTION <= S_EXCEPTION(COMMIT_POINTER);
PC        <= S_PC(COMMIT_POINTER);

PROCESS(CLK, RST, ISSUE)
variable n, k : integer;
BEGIN
		--RST
		IF (RST='1') THEN 
			 FOR i IN 0 TO 29 LOOP
				  S_RST(i) <= '1';  
			 END LOOP;
			
			LAST<=RST_S;
			
			ISSUE_POINTER<=0;
			COMMIT_POINTER<=0;
		ELSE
			--RST OFF
			 FOR i IN 0 TO 29 LOOP
				  S_RST(i) <= '0';  
			 END LOOP;
			
			n:=ISSUE_POINTER;
			k:=COMMIT_POINTER;
			
			--PUSH
			IF (ISSUE='1' AND CLK='0') THEN 
				S_ISSUE(n)<='0';
				n:=n+1;
				IF(n>29) THEN n:=0; END IF;
				S_ISSUE(n)<='1';
				LAST<=PUSH_S_LOW;
			ELSIF (ISSUE='0' AND CLK='0') THEN
				S_ISSUE(COMMIT_POINTER)<='0';
			END IF;
		
			--OUT OF BOUNDS FIX
			IF(k>29) THEN k :=0 ; END IF;
			
			
--			--COMMIT
--			IF(S_POP(k)='1') THEN 
--				DEST_RF  <= S_DEST_RF(k);
--				DEST_MEM <= S_DEST_MEM(k);
--				VALUE    <= S_VALUE(k);
--			ELSE 
--				DEST_RF  <= "00000";
--				DEST_MEM <= "00000";
--				VALUE    <= "00000000000000000000000000000000";
--			END IF;
--			
--			--EXCEPTION
--			EXCEPTION <= S_EXCEPTION(k);
--			PC        <= S_PC(k);
--			
			
			ISSUE_POINTER <= n;
			COMMIT_POINTER <= k;
		END IF;
END PROCESS;

--ROB SLOT 0
ROB_R0 : ROB_Reg
Port map(    CLK          => CLK,
             RST          => S_RST(0),
             MY_TAG       => "00001",
             ISSUE        => S_ISSUE(0),
             ISSUE_PC     => ISSUE_PC,
             ISSUE_I_type => ISSUE_I_type,
             ISSUE_Dest   => ISSUE_Dest,
             CDB_Q        => CDB_Q,
             CDB_V        => CDB_V,
             I_EXCEPTION  => S_EXCEPTION_IN(0),
             EXECUTED     => S_EXECUTED(0),
             POP          => S_POP(0),
             DEST_RF      => S_DEST_RF(0),
             DEST_MEM     => S_DEST_MEM(0),
             VALUE        => S_VALUE(0),
             EXCEPTION    => S_EXCEPTION(0),
             PC           => S_PC(0),
             EMPTY        => S_EMPTY(0),
             TAG          => S_TAG(0));

--ROB SLOT 1
ROB_R1 : ROB_Reg
Port map(    CLK          => CLK,
             RST          => S_RST(1),
             MY_TAG       => "00010",
             ISSUE        => S_ISSUE(1),
             ISSUE_PC     => ISSUE_PC,
             ISSUE_I_type => ISSUE_I_type,
             ISSUE_Dest   => ISSUE_Dest,
             CDB_Q        => CDB_Q,
             CDB_V        => CDB_V,
             I_EXCEPTION  => S_EXCEPTION_IN(1),
             EXECUTED     => S_EXECUTED(1),
             POP          => S_POP(1),
             DEST_RF      => S_DEST_RF(1),
             DEST_MEM     => S_DEST_MEM(1),
             VALUE        => S_VALUE(1),
             EXCEPTION    => S_EXCEPTION(1),
             PC           => S_PC(1),
             EMPTY        => S_EMPTY(1),
             TAG          => S_TAG(1));

--ROB SLOT 2
ROB_R2 : ROB_Reg
Port map(    CLK          => CLK,
             RST          => S_RST(2),
             MY_TAG       => "00011",
             ISSUE        => S_ISSUE(2),
             ISSUE_PC     => ISSUE_PC,
             ISSUE_I_type => ISSUE_I_type,
             ISSUE_Dest   => ISSUE_Dest,
             CDB_Q        => CDB_Q,
             CDB_V        => CDB_V,
             I_EXCEPTION  => S_EXCEPTION_IN(2),
             EXECUTED     => S_EXECUTED(2),
             POP          => S_POP(2),
             DEST_RF      => S_DEST_RF(2),
             DEST_MEM     => S_DEST_MEM(2),
             VALUE        => S_VALUE(2),
             EXCEPTION    => S_EXCEPTION(2),
             PC           => S_PC(2),
             EMPTY        => S_EMPTY(2),
             TAG          => S_TAG(2));

--ROB SLOT 3
ROB_R3 : ROB_Reg
Port map(    CLK          => CLK,
             RST          => S_RST(3),
             MY_TAG       => "00100",
             ISSUE        => S_ISSUE(3),
             ISSUE_PC     => ISSUE_PC,
             ISSUE_I_type => ISSUE_I_type,
             ISSUE_Dest   => ISSUE_Dest,
             CDB_Q        => CDB_Q,
             CDB_V        => CDB_V,
             I_EXCEPTION  => S_EXCEPTION_IN(3),
             EXECUTED     => S_EXECUTED(3),
             POP          => S_POP(3),
             DEST_RF      => S_DEST_RF(3),
             DEST_MEM     => S_DEST_MEM(3),
             VALUE        => S_VALUE(3),
             EXCEPTION    => S_EXCEPTION(3),
             PC           => S_PC(3),
             EMPTY        => S_EMPTY(3),
             TAG          => S_TAG(3));

--ROB SLOT 4
ROB_R4 : ROB_Reg
Port map(    CLK          => CLK,
             RST          => S_RST(4),
             MY_TAG       => "00101",
             ISSUE        => S_ISSUE(4),
             ISSUE_PC     => ISSUE_PC,
             ISSUE_I_type => ISSUE_I_type,
             ISSUE_Dest   => ISSUE_Dest,
             CDB_Q        => CDB_Q,
             CDB_V        => CDB_V,
             I_EXCEPTION  => S_EXCEPTION_IN(4),
             EXECUTED     => S_EXECUTED(4),
             POP          => S_POP(4),
             DEST_RF      => S_DEST_RF(4),
             DEST_MEM     => S_DEST_MEM(4),
             VALUE        => S_VALUE(4),
             EXCEPTION    => S_EXCEPTION(4),
             PC           => S_PC(4),
             EMPTY        => S_EMPTY(4),
             TAG          => S_TAG(4));

--ROB SLOT 5
ROB_R5 : ROB_Reg
Port map(    CLK          => CLK,
             RST          => S_RST(5),
             MY_TAG       => "00110",
             ISSUE        => S_ISSUE(5),
             ISSUE_PC     => ISSUE_PC,
             ISSUE_I_type => ISSUE_I_type,
             ISSUE_Dest   => ISSUE_Dest,
             CDB_Q        => CDB_Q,
             CDB_V        => CDB_V,
             I_EXCEPTION  => S_EXCEPTION_IN(5),
             EXECUTED     => S_EXECUTED(5),
             POP          => S_POP(5),
             DEST_RF      => S_DEST_RF(5),
             DEST_MEM     => S_DEST_MEM(5),
             VALUE        => S_VALUE(5),
             EXCEPTION    => S_EXCEPTION(5),
             PC           => S_PC(5),
             EMPTY        => S_EMPTY(5),
             TAG          => S_TAG(5));

--ROB SLOT 6
ROB_R6 : ROB_Reg
Port map(    CLK          => CLK,
             RST          => S_RST(6),
             MY_TAG       => "00111",
             ISSUE        => S_ISSUE(6),
             ISSUE_PC     => ISSUE_PC,
             ISSUE_I_type => ISSUE_I_type,
             ISSUE_Dest   => ISSUE_Dest,
             CDB_Q        => CDB_Q,
             CDB_V        => CDB_V,
             I_EXCEPTION  => S_EXCEPTION_IN(6),
             EXECUTED     => S_EXECUTED(6),
             POP          => S_POP(6),
             DEST_RF      => S_DEST_RF(6),
             DEST_MEM     => S_DEST_MEM(6),
             VALUE        => S_VALUE(6),
             EXCEPTION    => S_EXCEPTION(6),
             PC           => S_PC(6),
             EMPTY        => S_EMPTY(6),
             TAG          => S_TAG(6));

--ROB SLOT 7
ROB_R7 : ROB_Reg
Port map(    CLK          => CLK,
             RST          => S_RST(7),
             MY_TAG       => "01000",
             ISSUE        => S_ISSUE(7),
             ISSUE_PC     => ISSUE_PC,
             ISSUE_I_type => ISSUE_I_type,
             ISSUE_Dest   => ISSUE_Dest,
             CDB_Q        => CDB_Q,
             CDB_V        => CDB_V,
             I_EXCEPTION  => S_EXCEPTION_IN(7),
             EXECUTED     => S_EXECUTED(7),
             POP          => S_POP(7),
             DEST_RF      => S_DEST_RF(7),
             DEST_MEM     => S_DEST_MEM(7),
             VALUE        => S_VALUE(7),
             EXCEPTION    => S_EXCEPTION(7),
             PC           => S_PC(7),
             EMPTY        => S_EMPTY(7),
             TAG          => S_TAG(7));

--ROB SLOT 8
ROB_R8 : ROB_Reg
Port map(    CLK          => CLK,
             RST          => S_RST(8),
             MY_TAG       => "01001",
             ISSUE        => S_ISSUE(8),
             ISSUE_PC     => ISSUE_PC,
             ISSUE_I_type => ISSUE_I_type,
             ISSUE_Dest   => ISSUE_Dest,
             CDB_Q        => CDB_Q,
             CDB_V        => CDB_V,
             I_EXCEPTION  => S_EXCEPTION_IN(8),
             EXECUTED     => S_EXECUTED(8),
             POP          => S_POP(8),
             DEST_RF      => S_DEST_RF(8),
             DEST_MEM     => S_DEST_MEM(8),
             VALUE        => S_VALUE(8),
             EXCEPTION    => S_EXCEPTION(8),
             PC           => S_PC(8),
             EMPTY        => S_EMPTY(8),
             TAG          => S_TAG(8));

--ROB SLOT 9
ROB_R9 : ROB_Reg
Port map(    CLK          => CLK,
             RST          => S_RST(9),
             MY_TAG       => "01010",
             ISSUE        => S_ISSUE(9),
             ISSUE_PC     => ISSUE_PC,
             ISSUE_I_type => ISSUE_I_type,
             ISSUE_Dest   => ISSUE_Dest,
             CDB_Q        => CDB_Q,
             CDB_V        => CDB_V,
             I_EXCEPTION  => S_EXCEPTION_IN(9),
             EXECUTED     => S_EXECUTED(9),
             POP          => S_POP(9),
             DEST_RF      => S_DEST_RF(9),
             DEST_MEM     => S_DEST_MEM(9),
             VALUE        => S_VALUE(9),
             EXCEPTION    => S_EXCEPTION(9),
             PC           => S_PC(9),
             EMPTY        => S_EMPTY(9),
             TAG          => S_TAG(9));

--ROB SLOT 10
ROB_R10 : ROB_Reg
Port map(    CLK          => CLK,
             RST          => S_RST(10),
             MY_TAG       => "01011",
             ISSUE        => S_ISSUE(10),
             ISSUE_PC     => ISSUE_PC,
             ISSUE_I_type => ISSUE_I_type,
             ISSUE_Dest   => ISSUE_Dest,
             CDB_Q        => CDB_Q,
             CDB_V        => CDB_V,
             I_EXCEPTION  => S_EXCEPTION_IN(10),
             EXECUTED     => S_EXECUTED(10),
             POP          => S_POP(10),
             DEST_RF      => S_DEST_RF(10),
             DEST_MEM     => S_DEST_MEM(10),
             VALUE        => S_VALUE(10),
             EXCEPTION    => S_EXCEPTION(10),
             PC           => S_PC(10),
             EMPTY        => S_EMPTY(10),
             TAG          => S_TAG(10));

--ROB SLOT 11
ROB_R11 : ROB_Reg
Port map(    CLK          => CLK,
             RST          => S_RST(11),
             MY_TAG       => "01100",
             ISSUE        => S_ISSUE(11),
             ISSUE_PC     => ISSUE_PC,
             ISSUE_I_type => ISSUE_I_type,
             ISSUE_Dest   => ISSUE_Dest,
             CDB_Q        => CDB_Q,
             CDB_V        => CDB_V,
             I_EXCEPTION  => S_EXCEPTION_IN(11),
             EXECUTED     => S_EXECUTED(11),
             POP          => S_POP(11),
             DEST_RF      => S_DEST_RF(11),
             DEST_MEM     => S_DEST_MEM(11),
             VALUE        => S_VALUE(11),
             EXCEPTION    => S_EXCEPTION(11),
             PC           => S_PC(11),
             EMPTY        => S_EMPTY(11),
             TAG          => S_TAG(11));

--ROB SLOT 12
ROB_R12 : ROB_Reg
Port map(    CLK          => CLK,
             RST          => S_RST(12),
             MY_TAG       => "01101",
             ISSUE        => S_ISSUE(12),
             ISSUE_PC     => ISSUE_PC,
             ISSUE_I_type => ISSUE_I_type,
             ISSUE_Dest   => ISSUE_Dest,
             CDB_Q        => CDB_Q,
             CDB_V        => CDB_V,
             I_EXCEPTION  => S_EXCEPTION_IN(12),
             EXECUTED     => S_EXECUTED(12),
             POP          => S_POP(12),
             DEST_RF      => S_DEST_RF(12),
             DEST_MEM     => S_DEST_MEM(12),
             VALUE        => S_VALUE(12),
             EXCEPTION    => S_EXCEPTION(12),
             PC           => S_PC(12),
             EMPTY        => S_EMPTY(12),
             TAG          => S_TAG(12));

--ROB SLOT 13
ROB_R13 : ROB_Reg
Port map(    CLK          => CLK,
             RST          => S_RST(13),
             MY_TAG       => "01110",
             ISSUE        => S_ISSUE(13),
             ISSUE_PC     => ISSUE_PC,
             ISSUE_I_type => ISSUE_I_type,
             ISSUE_Dest   => ISSUE_Dest,
             CDB_Q        => CDB_Q,
             CDB_V        => CDB_V,
             I_EXCEPTION  => S_EXCEPTION_IN(13),
             EXECUTED     => S_EXECUTED(13),
             POP          => S_POP(13),
             DEST_RF      => S_DEST_RF(13),
             DEST_MEM     => S_DEST_MEM(13),
             VALUE        => S_VALUE(13),
             EXCEPTION    => S_EXCEPTION(13),
             PC           => S_PC(13),
             EMPTY        => S_EMPTY(13),
             TAG          => S_TAG(13));

--ROB SLOT 14
ROB_R14 : ROB_Reg
Port map(    CLK          => CLK,
             RST          => S_RST(14),
             MY_TAG       => "01111",
             ISSUE        => S_ISSUE(14),
             ISSUE_PC     => ISSUE_PC,
             ISSUE_I_type => ISSUE_I_type,
             ISSUE_Dest   => ISSUE_Dest,
             CDB_Q        => CDB_Q,
             CDB_V        => CDB_V,
             I_EXCEPTION  => S_EXCEPTION_IN(14),
             EXECUTED     => S_EXECUTED(14),
             POP          => S_POP(14),
             DEST_RF      => S_DEST_RF(14),
             DEST_MEM     => S_DEST_MEM(14),
             VALUE        => S_VALUE(14),
             EXCEPTION    => S_EXCEPTION(14),
             PC           => S_PC(14),
             EMPTY        => S_EMPTY(14),
             TAG          => S_TAG(14));

--ROB SLOT 15
ROB_R15 : ROB_Reg
Port map(    CLK          => CLK,
             RST          => S_RST(15),
             MY_TAG       => "10000",
             ISSUE        => S_ISSUE(15),
             ISSUE_PC     => ISSUE_PC,
             ISSUE_I_type => ISSUE_I_type,
             ISSUE_Dest   => ISSUE_Dest,
             CDB_Q        => CDB_Q,
             CDB_V        => CDB_V,
             I_EXCEPTION  => S_EXCEPTION_IN(15),
             EXECUTED     => S_EXECUTED(15),
             POP          => S_POP(15),
             DEST_RF      => S_DEST_RF(15),
             DEST_MEM     => S_DEST_MEM(15),
             VALUE        => S_VALUE(15),
             EXCEPTION    => S_EXCEPTION(15),
             PC           => S_PC(15),
             EMPTY        => S_EMPTY(15),
             TAG          => S_TAG(15));

--ROB SLOT 16
ROB_R16 : ROB_Reg
Port map(    CLK          => CLK,
             RST          => S_RST(16),
             MY_TAG       => "10001",
             ISSUE        => S_ISSUE(16),
             ISSUE_PC     => ISSUE_PC,
             ISSUE_I_type => ISSUE_I_type,
             ISSUE_Dest   => ISSUE_Dest,
             CDB_Q        => CDB_Q,
             CDB_V        => CDB_V,
             I_EXCEPTION  => S_EXCEPTION_IN(16),
             EXECUTED     => S_EXECUTED(16),
             POP          => S_POP(16),
             DEST_RF      => S_DEST_RF(16),
             DEST_MEM     => S_DEST_MEM(16),
             VALUE        => S_VALUE(16),
             EXCEPTION    => S_EXCEPTION(16),
             PC           => S_PC(16),
             EMPTY        => S_EMPTY(16),
             TAG          => S_TAG(16));

--ROB SLOT 17
ROB_R17 : ROB_Reg
Port map(    CLK          => CLK,
             RST          => S_RST(17),
             MY_TAG       => "10010",
             ISSUE        => S_ISSUE(17),
             ISSUE_PC     => ISSUE_PC,
             ISSUE_I_type => ISSUE_I_type,
             ISSUE_Dest   => ISSUE_Dest,
             CDB_Q        => CDB_Q,
             CDB_V        => CDB_V,
             I_EXCEPTION  => S_EXCEPTION_IN(17),
             EXECUTED     => S_EXECUTED(17),
             POP          => S_POP(17),
             DEST_RF      => S_DEST_RF(17),
             DEST_MEM     => S_DEST_MEM(17),
             VALUE        => S_VALUE(17),
             EXCEPTION    => S_EXCEPTION(17),
             PC           => S_PC(17),
             EMPTY        => S_EMPTY(17),
             TAG          => S_TAG(17));

--ROB SLOT 18
ROB_R18 : ROB_Reg
Port map(    CLK          => CLK,
             RST          => S_RST(18),
             MY_TAG       => "10011",
             ISSUE        => S_ISSUE(18),
             ISSUE_PC     => ISSUE_PC,
             ISSUE_I_type => ISSUE_I_type,
             ISSUE_Dest   => ISSUE_Dest,
             CDB_Q        => CDB_Q,
             CDB_V        => CDB_V,
             I_EXCEPTION  => S_EXCEPTION_IN(18),
             EXECUTED     => S_EXECUTED(18),
             POP          => S_POP(18),
             DEST_RF      => S_DEST_RF(18),
             DEST_MEM     => S_DEST_MEM(18),
             VALUE        => S_VALUE(18),
             EXCEPTION    => S_EXCEPTION(18),
             PC           => S_PC(18),
             EMPTY        => S_EMPTY(18),
             TAG          => S_TAG(18));

--ROB SLOT 19
ROB_R19 : ROB_Reg
Port map(    CLK          => CLK,
             RST          => S_RST(19),
             MY_TAG       => "10100",
             ISSUE        => S_ISSUE(19),
             ISSUE_PC     => ISSUE_PC,
             ISSUE_I_type => ISSUE_I_type,
             ISSUE_Dest   => ISSUE_Dest,
             CDB_Q        => CDB_Q,
             CDB_V        => CDB_V,
             I_EXCEPTION  => S_EXCEPTION_IN(19),
             EXECUTED     => S_EXECUTED(19),
             POP          => S_POP(19),
             DEST_RF      => S_DEST_RF(19),
             DEST_MEM     => S_DEST_MEM(19),
             VALUE        => S_VALUE(19),
             EXCEPTION    => S_EXCEPTION(19),
             PC           => S_PC(19),
             EMPTY        => S_EMPTY(19),
             TAG          => S_TAG(19));

--ROB SLOT 20
ROB_R20 : ROB_Reg
Port map(    CLK          => CLK,
             RST          => S_RST(20),
             MY_TAG       => "10101",
             ISSUE        => S_ISSUE(20),
             ISSUE_PC     => ISSUE_PC,
             ISSUE_I_type => ISSUE_I_type,
             ISSUE_Dest   => ISSUE_Dest,
             CDB_Q        => CDB_Q,
             CDB_V        => CDB_V,
             I_EXCEPTION  => S_EXCEPTION_IN(20),
             EXECUTED     => S_EXECUTED(20),
             POP          => S_POP(20),
             DEST_RF      => S_DEST_RF(20),
             DEST_MEM     => S_DEST_MEM(20),
             VALUE        => S_VALUE(20),
             EXCEPTION    => S_EXCEPTION(20),
             PC           => S_PC(20),
             EMPTY        => S_EMPTY(20),
             TAG          => S_TAG(20));

--ROB SLOT 21
ROB_R21 : ROB_Reg
Port map(    CLK          => CLK,
             RST          => S_RST(21),
             MY_TAG       => "10110",
             ISSUE        => S_ISSUE(21),
             ISSUE_PC     => ISSUE_PC,
             ISSUE_I_type => ISSUE_I_type,
             ISSUE_Dest   => ISSUE_Dest,
             CDB_Q        => CDB_Q,
             CDB_V        => CDB_V,
             I_EXCEPTION  => S_EXCEPTION_IN(21),
             EXECUTED     => S_EXECUTED(21),
             POP          => S_POP(21),
             DEST_RF      => S_DEST_RF(21),
             DEST_MEM     => S_DEST_MEM(21),
             VALUE        => S_VALUE(21),
             EXCEPTION    => S_EXCEPTION(21),
             PC           => S_PC(21),
             EMPTY        => S_EMPTY(21),
             TAG          => S_TAG(21));

--ROB SLOT 22
ROB_R22 : ROB_Reg
Port map(    CLK          => CLK,
             RST          => S_RST(22),
             MY_TAG       => "10111",
             ISSUE        => S_ISSUE(22),
             ISSUE_PC     => ISSUE_PC,
             ISSUE_I_type => ISSUE_I_type,
             ISSUE_Dest   => ISSUE_Dest,
             CDB_Q        => CDB_Q,
             CDB_V        => CDB_V,
             I_EXCEPTION  => S_EXCEPTION_IN(22),
             EXECUTED     => S_EXECUTED(22),
             POP          => S_POP(22),
             DEST_RF      => S_DEST_RF(22),
             DEST_MEM     => S_DEST_MEM(22),
             VALUE        => S_VALUE(22),
             EXCEPTION    => S_EXCEPTION(22),
             PC           => S_PC(22),
             EMPTY        => S_EMPTY(22),
             TAG          => S_TAG(22));

--ROB SLOT 23
ROB_R23 : ROB_Reg
Port map(    CLK          => CLK,
             RST          => S_RST(23),
             MY_TAG       => "11000",
             ISSUE        => S_ISSUE(23),
             ISSUE_PC     => ISSUE_PC,
             ISSUE_I_type => ISSUE_I_type,
             ISSUE_Dest   => ISSUE_Dest,
             CDB_Q        => CDB_Q,
             CDB_V        => CDB_V,
             I_EXCEPTION  => S_EXCEPTION_IN(23),
             EXECUTED     => S_EXECUTED(23),
             POP          => S_POP(23),
             DEST_RF      => S_DEST_RF(23),
             DEST_MEM     => S_DEST_MEM(23),
             VALUE        => S_VALUE(23),
             EXCEPTION    => S_EXCEPTION(23),
             PC           => S_PC(23),
             EMPTY        => S_EMPTY(23),
             TAG          => S_TAG(23));

--ROB SLOT 24
ROB_R24 : ROB_Reg
Port map(    CLK          => CLK,
             RST          => S_RST(24),
             MY_TAG       => "11001",
             ISSUE        => S_ISSUE(24),
             ISSUE_PC     => ISSUE_PC,
             ISSUE_I_type => ISSUE_I_type,
             ISSUE_Dest   => ISSUE_Dest,
             CDB_Q        => CDB_Q,
             CDB_V        => CDB_V,
             I_EXCEPTION  => S_EXCEPTION_IN(24),
             EXECUTED     => S_EXECUTED(24),
             POP          => S_POP(24),
             DEST_RF      => S_DEST_RF(24),
             DEST_MEM     => S_DEST_MEM(24),
             VALUE        => S_VALUE(24),
             EXCEPTION    => S_EXCEPTION(24),
             PC           => S_PC(24),
             EMPTY        => S_EMPTY(24),
             TAG          => S_TAG(24));

--ROB SLOT 25
ROB_R25 : ROB_Reg
Port map(    CLK          => CLK,
             RST          => S_RST(25),
             MY_TAG       => "11010",
             ISSUE        => S_ISSUE(25),
             ISSUE_PC     => ISSUE_PC,
             ISSUE_I_type => ISSUE_I_type,
             ISSUE_Dest   => ISSUE_Dest,
             CDB_Q        => CDB_Q,
             CDB_V        => CDB_V,
             I_EXCEPTION  => S_EXCEPTION_IN(25),
             EXECUTED     => S_EXECUTED(25),
             POP          => S_POP(25),
             DEST_RF      => S_DEST_RF(25),
             DEST_MEM     => S_DEST_MEM(25),
             VALUE        => S_VALUE(25),
             EXCEPTION    => S_EXCEPTION(25),
             PC           => S_PC(25),
             EMPTY        => S_EMPTY(25),
             TAG          => S_TAG(25));

--ROB SLOT 26
ROB_R26 : ROB_Reg
Port map(    CLK          => CLK,
             RST          => S_RST(26),
             MY_TAG       => "11011",
             ISSUE        => S_ISSUE(26),
             ISSUE_PC     => ISSUE_PC,
             ISSUE_I_type => ISSUE_I_type,
             ISSUE_Dest   => ISSUE_Dest,
             CDB_Q        => CDB_Q,
             CDB_V        => CDB_V,
             I_EXCEPTION  => S_EXCEPTION_IN(26),
             EXECUTED     => S_EXECUTED(26),
             POP          => S_POP(26),
             DEST_RF      => S_DEST_RF(26),
             DEST_MEM     => S_DEST_MEM(26),
             VALUE        => S_VALUE(26),
             EXCEPTION    => S_EXCEPTION(26),
             PC           => S_PC(26),
             EMPTY        => S_EMPTY(26),
             TAG          => S_TAG(26));

--ROB SLOT 27
ROB_R27 : ROB_Reg
Port map(    CLK          => CLK,
             RST          => S_RST(27),
             MY_TAG       => "11100",
             ISSUE        => S_ISSUE(27),
             ISSUE_PC     => ISSUE_PC,
             ISSUE_I_type => ISSUE_I_type,
             ISSUE_Dest   => ISSUE_Dest,
             CDB_Q        => CDB_Q,
             CDB_V        => CDB_V,
             I_EXCEPTION  => S_EXCEPTION_IN(27),
             EXECUTED     => S_EXECUTED(27),
             POP          => S_POP(27),
             DEST_RF      => S_DEST_RF(27),
             DEST_MEM     => S_DEST_MEM(27),
             VALUE        => S_VALUE(27),
             EXCEPTION    => S_EXCEPTION(27),
             PC           => S_PC(27),
             EMPTY        => S_EMPTY(27),
             TAG          => S_TAG(27));

--ROB SLOT 28
ROB_R28 : ROB_Reg
Port map(    CLK          => CLK,
             RST          => S_RST(28),
             MY_TAG       => "11101",
             ISSUE        => S_ISSUE(28),
             ISSUE_PC     => ISSUE_PC,
             ISSUE_I_type => ISSUE_I_type,
             ISSUE_Dest   => ISSUE_Dest,
             CDB_Q        => CDB_Q,
             CDB_V        => CDB_V,
             I_EXCEPTION  => S_EXCEPTION_IN(28),
             EXECUTED     => S_EXECUTED(28),
             POP          => S_POP(28),
             DEST_RF      => S_DEST_RF(28),
             DEST_MEM     => S_DEST_MEM(28),
             VALUE        => S_VALUE(28),
             EXCEPTION    => S_EXCEPTION(28),
             PC           => S_PC(28),
             EMPTY        => S_EMPTY(28),
             TAG          => S_TAG(28));

--ROB SLOT 29
ROB_R29 : ROB_Reg
Port map(    CLK          => CLK,
             RST          => S_RST(29),
             MY_TAG       => "11110",
             ISSUE        => S_ISSUE(29),
             ISSUE_PC     => ISSUE_PC,
             ISSUE_I_type => ISSUE_I_type,
             ISSUE_Dest   => ISSUE_Dest,
             CDB_Q        => CDB_Q,
             CDB_V        => CDB_V,
             I_EXCEPTION  => S_EXCEPTION_IN(29),
             EXECUTED     => S_EXECUTED(29),
             POP          => S_POP(29),
             DEST_RF      => S_DEST_RF(29),
             DEST_MEM     => S_DEST_MEM(29),
             VALUE        => S_VALUE(29),
             EXCEPTION    => S_EXCEPTION(29),
             PC           => S_PC(29),
             EMPTY        => S_EMPTY(29),
             TAG          => S_TAG(29));
				 
end Behavioral;

