----------------------------------------------------------------------------------
-- Company/University:        Technical University of Crete (TUC) - GR
-- Engineer:                  Spyridakis Christos 
--                            Bellonias Panagiotis
-- 
-- Create Date:               10/22/2018
-- Design Name: 	 
-- Module Name:               FU - Behavioral 
-- Project Name:              Tomasulo
-- Target Devices:            NONE
-- Tool versions:             Xilinx ISE 14.7 --TODO: VIVADO
-- Description:               Introduction in Dynamic Instruction Scheduling (Advanced Computer Architecture)
--                            implementing Tomasulo's Algorithm 	 
--
-- Dependencies:              NONE
--
-- Revision:                  0.01
-- Revision                   0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity FU is
    Port ( CLK : in  STD_LOGIC;
           RST : in  STD_LOGIC;
			  
			  --Aritmetic FU
           A_Ready : in  STD_LOGIC;							
           A_Tag : in  STD_LOGIC_VECTOR (4 downto 0);
           A_Op : in  STD_LOGIC_VECTOR (1 downto 0);
           A_Vj : in  STD_LOGIC_VECTOR (31 downto 0);
           A_Vk : in  STD_LOGIC_VECTOR (31 downto 0);
           A_Accepted : out  STD_LOGIC;							
           A_Request : out  STD_LOGIC;							
           A_Grant : in  STD_LOGIC;							
           A_Q : out  STD_LOGIC_VECTOR (4 downto 0);
           A_V : out  STD_LOGIC_VECTOR (31 downto 0);
			  
			  --Logical FU
           L_Ready : in  STD_LOGIC;							
           L_Tag : in  STD_LOGIC_VECTOR (4 downto 0);
           L_Op : in  STD_LOGIC_VECTOR (1 downto 0);
           L_Vj : in  STD_LOGIC_VECTOR (31 downto 0);
           L_Vk : in  STD_LOGIC_VECTOR (31 downto 0);
           L_Accepted : out  STD_LOGIC;							
           L_Request : out  STD_LOGIC;							
           L_Grant : in  STD_LOGIC;							
           L_Q : out  STD_LOGIC_VECTOR (4 downto 0);
           L_V : out  STD_LOGIC_VECTOR (31 downto 0));
end FU;

architecture Behavioral of FU is

component FU_Control is
    Port ( CLK : in  STD_LOGIC;
	        A_Ready : in  STD_LOGIC;
	        A1_Q : in  STD_LOGIC_VECTOR (4 downto 0);
           A2_Q : in  STD_LOGIC_VECTOR (4 downto 0);
           A3_Q : in  STD_LOGIC_VECTOR (4 downto 0);
           A_Accepted : out  STD_LOGIC;
			  A_Request : out  STD_LOGIC;
			  A_Grant : in  STD_LOGIC;
			  A1_EN : out  STD_LOGIC;
           A2_EN : out  STD_LOGIC;
           A3_EN : out  STD_LOGIC;
			  
			  L_Ready : in  STD_LOGIC;
			  L1_Q : in  STD_LOGIC_VECTOR (4 downto 0);
           L2_Q : in  STD_LOGIC_VECTOR (4 downto 0);
           L_Accepted : out  STD_LOGIC;
           L_Request : out  STD_LOGIC;
           L_Grant : in  STD_LOGIC;
           L1_EN : out  STD_LOGIC;
           L2_EN : out  STD_LOGIC);
end component;

component Mux_2x5bits is
    Port ( In0 : in  STD_LOGIC_VECTOR (4 downto 0);
           In1 : in  STD_LOGIC_VECTOR (4 downto 0);
           Sel : in  STD_LOGIC;
           Outt : out  STD_LOGIC_VECTOR (4 downto 0));
end component;

component ALU is
    Port ( A_Vj : in  STD_LOGIC_VECTOR (31 downto 0);
           A_Vk : in  STD_LOGIC_VECTOR (31 downto 0);
           A_Op : in  STD_LOGIC_VECTOR (1 downto 0);
           A0_V : out  STD_LOGIC_VECTOR (31 downto 0);
			  
           L_Vj : in  STD_LOGIC_VECTOR (31 downto 0);
           L_Vk : in  STD_LOGIC_VECTOR (31 downto 0);
           L_Op : in  STD_LOGIC_VECTOR (1 downto 0);
           L0_V : out  STD_LOGIC_VECTOR (31 downto 0));
end component;

component Reg_V_Q is
    Port ( CLK : in  STD_LOGIC;
           RST : in  STD_LOGIC;
           EN : in  STD_LOGIC;
           VIN : in  STD_LOGIC_VECTOR (31 downto 0);
           QIN : in  STD_LOGIC_VECTOR (4 downto 0);
           VOUT : out  STD_LOGIC_VECTOR (31 downto 0);
           QOUT : out  STD_LOGIC_VECTOR (4 downto 0));
end component;

--Tmp Arithmetic and Logical Pipeline Signals
signal A1_EN, A2_EN, A3_EN, L1_EN, L2_EN : STD_LOGIC;							
signal A0_V, A1_V, A2_V, L0_V, L1_V : STD_LOGIC_VECTOR (31 downto 0);
signal A0_Q, A1_Q, A2_Q, A3_Q, L0_Q, L1_Q, L2_Q : STD_LOGIC_VECTOR (4 downto 0);

begin

--MUX for A1_Q and L1_Q 	  
A1_Qin : Mux_2x5bits 
    Port map( In0  => "00000",
				  In1  => A_Tag,
              Sel  => A_Ready,
              Outt => A0_Q);
L1_Qin : Mux_2x5bits 
    Port map( In0  => "00000",
				  In1  => L_Tag,
              Sel  => L_Ready,
              Outt => L0_Q);
				  
--ALU
A_L_ALU : ALU 
	Port map(  A_Vj => A_Vj,
              A_Vk => A_Vk,
              A_Op => A_Op,
              A0_V => A0_V,
              L_Vj => L_Vj,
              L_Vk => L_Vk,
              L_Op => L_Op,
              L0_V => L0_V);


--Arithmetic Pipeline FU stages
A1 : Reg_V_Q
    Port map( CLK  => CLK,
              RST  => RST,
              EN   => A1_EN,
              VIN  => A0_V,
              QIN  => A0_Q,
              VOUT => A1_V,
              QOUT => A1_Q);
			  
A2 : Reg_V_Q
    Port map( CLK  => CLK,
              RST  => RST,
              EN   => A2_EN,
              VIN  => A1_V,
              QIN  => A1_Q,
              VOUT => A2_V,
              QOUT => A2_Q);
			  
A3 : Reg_V_Q
    Port map( CLK  => CLK,
              RST  => RST,
              EN   => A3_EN,
              VIN  => A2_V,
              QIN  => A2_Q,
              VOUT => A_V,
              QOUT => A3_Q);
A_Q<=A3_Q;

--Logical Pipeline FU stages
L1 : Reg_V_Q
    Port map( CLK  => CLK,
              RST  => RST,
              EN   => L1_EN,
              VIN  => L0_V,
              QIN  => L0_Q,
              VOUT => L1_V,
              QOUT => L1_Q);
			  
L2 : Reg_V_Q
    Port map( CLK  => CLK,
              RST  => RST,
              EN   => L2_EN,
              VIN  => L1_V,
              QIN  => L1_Q,
              VOUT => L_V,
              QOUT => L2_Q);
L_Q<=L2_Q;

--FU control unit			
Fu_control_Unit : FU_Control
    Port map( CLK        => CLK,
	           A_Ready    => A_Ready,
	           A1_Q       => A1_Q,
              A2_Q       => A2_Q,
              A3_Q       => A3_Q,
              A_Accepted => A_Accepted,
			     A_Request  => A_Request,
			     A_Grant    => A_Grant,
			     A1_EN      => A1_EN,
              A2_EN      => A2_EN,
              A3_EN      => A3_EN,
			   
			     L_Ready    => L_Ready,
			     L1_Q       => L1_Q,
              L2_Q       => L2_Q,
              L_Accepted => L_Accepted,
              L_Request  => L_Request,
              L_Grant    => L_Grant,
              L1_EN      => L1_EN,
              L2_EN      => L2_EN);
end Behavioral;

