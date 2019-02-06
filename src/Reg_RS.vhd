----------------------------------------------------------------------------------
-- Company/University:        Technical University of Crete (TUC) - GR
-- Engineer:                  Spyridakis Christos 
--                            Bellonias Panagiotis
-- 
-- Create Date:                
-- Design Name: 	 
-- Module Name:               Reg_RS - Behavioral 
-- Project Name:              Tomasulo
-- Target Devices:            NONE
-- Tool versions:             Xilinx ISE 14.7 --TODO: VIVADO
-- Description:               Introduction in Dynamic Instruction Scheduling (Advanced Computer Architecture)
--                            implementing Tomasulo's Algorithm 	 
--
-- Dependencies:              NONE
--
-- Revision:                  2.1
-- Revision                   2.1 - ROB
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Reg_RS is
    Port ( CLK : in  STD_LOGIC;
           RST : in  STD_LOGIC;
			  
           ID : in  STD_LOGIC_VECTOR (4 downto 0);
           Available : out  STD_LOGIC;
			  
           --ISSUE
           ISSUE : in  STD_LOGIC;
           Op_ISSUE : in  STD_LOGIC_VECTOR (1 downto 0);
           Vj_ISSUE : in  STD_LOGIC_VECTOR (31 downto 0);
           Qj : in  STD_LOGIC_VECTOR (4 downto 0);
           Vk_ISSUE : in  STD_LOGIC_VECTOR (31 downto 0);
           Qk : in  STD_LOGIC_VECTOR (4 downto 0);
			  
           --CDB
           CDB_V : in  STD_LOGIC_VECTOR (31 downto 0);
           CDB_Q : in  STD_LOGIC_VECTOR (4 downto 0);
           
           Ready : out  STD_LOGIC;
           Op : out  STD_LOGIC_VECTOR (1 downto 0);
           Tag : out  STD_LOGIC_VECTOR (4 downto 0);
           Vj : out  STD_LOGIC_VECTOR (31 downto 0);
           Vk : out  STD_LOGIC_VECTOR (31 downto 0);
           Accepted : in  STD_LOGIC);
end Reg_RS;

architecture Behavioral of Reg_RS is

-- Ready Register
component Reg_1bit is
    Port ( CLK  : in  STD_LOGIC;
           RST  : in  STD_LOGIC;
           EN   : in  STD_LOGIC;
           INN  : in  STD_LOGIC;
           OUTT : out  STD_LOGIC);
end component;

-- Available Register
component Reg_1bit_N is
    Port ( CLK  : in  STD_LOGIC;
           RST  : in  STD_LOGIC;
           EN   : in  STD_LOGIC;
           INN  : in  STD_LOGIC;
           OUTT : out  STD_LOGIC);
end component;

-- Operation code store
component Reg_2bits is
    Port ( CLK  : in  STD_LOGIC;
           RST  : in  STD_LOGIC;
           EN   : in  STD_LOGIC;
           INN  : in  STD_LOGIC_VECTOR(1 downto 0);
           OUTT : out  STD_LOGIC_VECTOR(1 downto 0));
end component;

-- Reservation Station's Data and Tag Store
component Reg_V_Q is
    Port ( CLK : in  STD_LOGIC;
           RST : in  STD_LOGIC;
           EN : in  STD_LOGIC;
           VIN : in  STD_LOGIC_VECTOR (31 downto 0);
           QIN : in  STD_LOGIC_VECTOR (4 downto 0);
           VOUT : out  STD_LOGIC_VECTOR (31 downto 0);
           QOUT : out  STD_LOGIC_VECTOR (4 downto 0));
end component;			  

-- Input Value select
component Mux_2x32bits is
    Port ( In0 : in  STD_LOGIC_VECTOR (31 downto 0);
           In1 : in  STD_LOGIC_VECTOR (31 downto 0);
           Sel : in  STD_LOGIC;
           Outt : out  STD_LOGIC_VECTOR (31 downto 0));
end component;

-- Input tag select
component Mux_2x5bits is
    Port ( In0 : in  STD_LOGIC_VECTOR (4 downto 0);
           In1 : in  STD_LOGIC_VECTOR (4 downto 0);
           Sel : in  STD_LOGIC;
           Outt : out  STD_LOGIC_VECTOR (4 downto 0));
end component;

--Storing RS Tag
component Reg_5bits is
    Port ( CLK  : in  STD_LOGIC;
           RST  : in  STD_LOGIC;
           EN   : in  STD_LOGIC;
           INN  : in  STD_LOGIC_VECTOR (4 downto 0);
           OUTT : out  STD_LOGIC_VECTOR (4 downto 0));
end component;

-- Tmp Signals
signal  AvailableS, ReadyS, Av_RST, Av_EN, Op_RST, Op_EN, J_RST, J_EN, K_RST, K_EN, Re_RST, Re_EN : STD_LOGIC;							
signal  J_Vin, K_Vin: STD_LOGIC_VECTOR (31 downto 0);
signal  J_Qin, J_Q, K_Qin, K_Q: STD_LOGIC_VECTOR (4 downto 0);

--For storing Tag (ROB)
signal Tag_RST, Tag_EN:STD_LOGIC;

signal  TAG_TMP: STD_LOGIC_VECTOR (4 downto 0);

begin

	--Reservation Station FSM			  
	PROCESS(CLK, RST, AvailableS, ReadyS, ISSUE, Qj, Qk, CDB_Q, J_Q, K_Q, Accepted, ID)
	BEGIN
		--RST
		IF (RST='1') THEN                 																			    
			--Resets
			Av_RST <='1'; 
			Op_RST <='1';
			J_RST  <='1';
			K_RST  <='1';
			Re_RST <='1';
			Tag_RST <='1';
			--Enables
			Av_EN  <='0';
			Op_EN  <='0';
			J_EN   <='0';
			K_EN   <='0';
			Re_EN  <='0';
			Tag_EN <='0';

		--Issue with valid Data 
		ELSIF (AvailableS='1' AND ISSUE='1' AND ReadyS='0' AND Qj="00000" AND Qk="00000") THEN 			              
			--Resets
			Av_RST <='0'; 
			Op_RST <='0';
			J_RST  <='0';
			K_RST  <='0';
			Re_RST <='0';
			Tag_RST <='0';
			--Enables
			Av_EN  <='1';
			Op_EN  <='1';
			J_EN   <='1';
			K_EN   <='1';
			Re_EN  <='1';
			Tag_EN <='1';

		--Issue with One OR none of them Ready
		ELSIF (AvailableS='1' AND ISSUE='1' AND ReadyS='0' )	THEN													
			--Resets
			Av_RST <='0'; 
			Op_RST <='0';
			J_RST  <='0';
			K_RST  <='0';
			Re_RST <='0';
			Tag_RST <='0';
			--Enables
			Av_EN  <='1';
			Op_EN  <='1';
			J_EN   <='1';
			K_EN   <='1';
			Re_EN  <='0';
			Tag_EN <='1';
		
		--CDB_Q is equal with J's Tag And K is valid
		ELSIF (AvailableS='0' AND ISSUE='0' AND ReadyS='0' AND CDB_Q/="00000" AND CDB_Q=J_Q AND K_Q="00000")	THEN			
			--Resets
			Av_RST <='0'; 
			Op_RST <='0';
			J_RST  <='0';
			K_RST  <='0';
			Re_RST <='0';
			Tag_RST <='0';
			--Enables
			Av_EN  <='0';
			Op_EN  <='0';
			J_EN   <='1';
			K_EN   <='0';
			Re_EN  <='1';
			Tag_EN <='0';

		--CDB_Q is equal with K's Tag And J is valid
		ELSIF (AvailableS='0' AND ISSUE='0' AND ReadyS='0' AND J_Q="00000" AND CDB_Q/="00000" AND CDB_Q=K_Q)	THEN			
			--Resets
			Av_RST <='0'; 
			Op_RST <='0';
			J_RST  <='0';
			K_RST  <='0';
			Re_RST <='0';
			Tag_RST <='0';
			--Enables
			Av_EN  <='0';
			Op_EN  <='0';
			J_EN   <='0';
			K_EN   <='1';
			Re_EN  <='1';
			Tag_EN <='0';
		
		--CDB_Q is equal with K's and J's Tag
		ELSIF (AvailableS='0' AND ISSUE='0' AND ReadyS='0' AND CDB_Q/="00000" AND CDB_Q=J_Q AND CDB_Q=K_Q)	THEN				
			--Resets
			Av_RST <='0'; 
			Op_RST <='0';
			J_RST  <='0';
			K_RST  <='0';
			Re_RST <='0';
			Tag_RST <='0';
			--Enables
			Av_EN  <='0';
			Op_EN  <='0';
			J_EN   <='1';
			K_EN   <='1';
			Re_EN  <='1';
			Tag_EN <='0';

		--CDB_Q is equal with K's tag
		ELSIF (AvailableS='0' AND ISSUE='0' AND ReadyS='0' AND CDB_Q/="00000" AND CDB_Q=K_Q)	THEN								
			--Resets
			Av_RST <='0'; 
			Op_RST <='0';
			J_RST  <='0';
			K_RST  <='0';
			Re_RST <='0';
			Tag_RST <='0';
			--Enables
			Av_EN  <='0';
			Op_EN  <='0';
			J_EN   <='0';
			K_EN   <='1';
			Re_EN  <='0';
			Tag_EN <='0';

		--CDB_Q is equal with J's tag 
		ELSIF (AvailableS='0' AND ISSUE='0' AND ReadyS='0' AND CDB_Q/="00000" AND CDB_Q=J_Q)	THEN								
			--Resets
			Av_RST <='0'; 
			Op_RST <='0';
			J_RST  <='0';
			K_RST  <='0';
			Re_RST <='0';
			Tag_RST <='0';
			--Enables
			Av_EN  <='0';
			Op_EN  <='0';
			J_EN   <='1';
			K_EN   <='0';
			Re_EN  <='0';
			Tag_EN <='0';

		--RS Accepted from FU
		ELSIF (AvailableS='0' AND ISSUE='0' AND ReadyS='1' AND Accepted='1')	THEN														
			--Resets
			Av_RST <='0'; 
			Op_RST <='0';
			J_RST  <='0';
			K_RST  <='0';
			Re_RST <='1';
			Tag_RST <='0';
			--Enables
			Av_EN  <='0';
			Op_EN  <='0';
			J_EN   <='0';
			K_EN   <='0';
			Re_EN  <='0';
			Tag_EN <='0';

		--Operation Completed
		ELSIF (AvailableS='0' AND ISSUE='0' AND ReadyS='0' AND CDB_Q=TAG_TMP)	THEN													
			--Resets
			Av_RST <='1'; 
			Op_RST <='1';
			J_RST  <='1';
			K_RST  <='1';
			Re_RST <='1';
			Tag_RST <='1';
			--Enables
			Av_EN  <='0';
			Op_EN  <='0';
			J_EN   <='0';
			K_EN   <='0';
			Re_EN  <='0';
			Tag_EN <='0';
		ELSE
		--Resets
			Av_RST <='0'; 
			Op_RST <='0';
			J_RST  <='0';
			K_RST  <='0';
			Re_RST <='0';
			Tag_RST <='0';
			--Enables
			Av_EN  <='0';
			Op_EN  <='0';
			J_EN   <='0';
			K_EN   <='0';
			Re_EN  <='0';
			Tag_EN <='0';
		END IF;
	END PROCESS;
	
	
	--MY TAG
	Tag<=TAG_TMP;
	myTag : Reg_5bits 
	Port map( CLK  => CLK,
				RST  => Tag_RST,
				EN   => Tag_EN,
				INN  => ID,
				OUTT => TAG_TMP);
	
	-- Available 
	-- When a RS is Empty Avail='1' 
	AvailableR : Reg_1bit_N 
	Port map( CLK  => CLK,
			RST  => Av_RST,
			EN   => Av_EN,
			INN  => '0',											
			OUTT => AvailableS);
	Available <= AvailableS;

	-- Ready Registers
	-- When RS has valid data and is not in FU's execution queue Ready='1'
	ReadyR : Reg_1bit 
	Port map( CLK  => CLK,
			RST  => Re_RST,
			EN   => Re_EN,
			INN  => '1',
			OUTT => ReadyS);	
	Ready<=ReadyS;
	
	OpC : Reg_2bits 
	Port map( CLK  => CLK,
			RST  => Op_RST,
			EN   => Op_EN,
			INN  => Op_ISSUE,
			OUTT => Op);			  
			  
			    
	-- Data and Tag for J
	-- If RS is available (Avail='1'), it can only take Data and Tag From RF when a new instruction's ISSUE take place 
	-- If RS is NOT available, RS acceptes CDB Data only when RS ID is equal with CDB_Q and it's Tag changes to "00000"
	-- Vj_In and Qj_In are two MUXs for selecting properly RS Data and Tag values based on RS Availability
	Vj_In : Mux_2x32bits 
	Port map( In0  => CDB_V,
			In1  => Vj_ISSUE,
			Sel  => AvailableS,
			Outt => J_Vin);

	Qj_In : Mux_2x5bits 
	Port map( In0  => "00000",
			In1  => Qj,
			Sel  => AvailableS,
			Outt => J_Qin);	
	
	-- Data and Tag Register
	-- Input Values are based on RS Availability, in order to store (when it needs) the values, you have to enable Register's Write (K_EN)
	-- When a RS has been executed, just reset it (K_RST)
	J : Reg_V_Q
	Port map( CLK  => CLK,
			RST  => J_RST,
			EN   => J_EN,
			VIN  => J_Vin,
			QIN  => J_Qin,
			VOUT => Vj,
			QOUT => J_Q);
					 
			
	-- Data and Tag for K
	-- If RS is available (Avail='1'), it can only take Data and Tag From RF when a new instruction's ISSUE take place 
	-- If RS is NOT available, RS acceptes CDB Data only when RS ID is equal with CDB_Q and it's Tag changes to "00000"
	-- Vk_In and Qk_In are two MUXs for selecting properly RS Data and Tag values based on RS Availability	
	Vk_In : Mux_2x32bits 
	Port map( In0  => CDB_V,
			In1  => Vk_ISSUE,
			Sel  => AvailableS,
			Outt => K_Vin);

	Qk_In : Mux_2x5bits 
	Port map( In0  => "00000",
			In1  => Qk,
			Sel  => AvailableS,
			Outt => K_Qin);
					  
	-- Data and Tag Register
	-- Input Values are based on RS Availability, in order to store (when it needs) the values, you have to enable Register's Write (K_EN)
	-- When a RS has been executed, just reset it (K_RST)
	K : Reg_V_Q
	Port map( CLK  => CLK,
			RST  => K_RST,
			EN   => K_EN,
			VIN  => K_Vin,
			QIN  => K_Qin,
			VOUT => Vk,
			QOUT => K_Q); 
					  	
end Behavioral;