----------------------------------------------------------------------------------
-- Company/University:        Technical University of Crete (TUC) - GR
-- Engineer:                  Spyridakis Christos 
--                            Bellonias Panagiotis
-- 
-- Create Date:               10/22/2018
-- Design Name:      
-- Module Name:               Tomasulo - Behavioral 
-- Project Name:              Tomasulo
-- Target Devices:            NONE
-- Tool versions:             Xilinx ISE 14.7 --TODO: VIVADO
-- Description:               Introduction in Dynamic Instruction Scheduling (Advanced Computer Architecture)
--                            implementing Tomasulo's Algorithm      
--
-- Dependencies:              NONE
--
-- Revision:                  1.0
-- Revision                   1.0 
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Tomasulo is
Port (     CLK : in  STD_LOGIC;
           RST : in  STD_LOGIC;
 
           -- In case Issue='1' then Issue new Instruction
           Issue_I : in  STD_LOGIC;
   
           -- Fu_type 
           --    Case = 00 Issue Logical Instruction
           --    Case = 01 Issue Arithmetic Instruction
           Fu_type : in  STD_LOGIC_VECTOR (1 downto 0);
 
           -- FOP (Functional Operation)
           --    *For Arithmetical Instructions
           --        1) Case = 00 => add/addi (addi only when immediate is high)
           --        2) Case = 01 => sub/subi (subi only when immediate is high) 
           --        3) Case = 10 => sll
           --    *For Logical Instructions 
           --        1) Case = 00 => and/andi (andi only when immediate is high)
           --        2) Case = 01 => or/ori (ori only when immediate is high)
           --        3) Case = 10 => not 
           FOP : in  STD_LOGIC_VECTOR (1 downto 0);
 
           -- Based on MIPS terminology 
           -- * Ri is equal with Rd for R-type Instructions and with Rt for I-type
           -- * Rj is equal with Rs 
           -- * Rk is equal with Rt for R-type Instructions
           Ri : in  STD_LOGIC_VECTOR (4 downto 0);
           Rj : in  STD_LOGIC_VECTOR (4 downto 0);
           Rk : in  STD_LOGIC_VECTOR (4 downto 0);
  
           -- Immediate
           Immed : in  STD_LOGIC;
           -- Value of Immediate, assumed that sign extension or zero extension is already been executed
           V_immed : in  STD_LOGIC_VECTOR (31 downto 0); 
  
           Accepted : out  STD_LOGIC);
end Tomasulo;

architecture Behavioral of Tomasulo is

component ISSUE is
    Port ( CLK : in  STD_LOGIC;
           A_Available : in  STD_LOGIC;
           L_Available : in  STD_LOGIC;
           Issue_I : in  STD_LOGIC;
           Fu_type : in  STD_LOGIC_VECTOR (1 downto 0);
           Tag_WE : out  STD_LOGIC;
           Accepted : out  STD_LOGIC);
end component;

component RF is
    Port ( CLK : in  STD_LOGIC;
           RST : in  STD_LOGIC;
           Ri : in  STD_LOGIC_VECTOR (4 downto 0);
           Rj : in  STD_LOGIC_VECTOR (4 downto 0);
           Rk : in  STD_LOGIC_VECTOR (4 downto 0);
           Tag_WE : in  STD_LOGIC;
           Tag_Accepted : in  STD_LOGIC_VECTOR (4 downto 0);
           CDB_Q : in  STD_LOGIC_VECTOR (4 downto 0);
           CDB_V : in  STD_LOGIC_VECTOR (31 downto 0);
           Qj : out  STD_LOGIC_VECTOR (4 downto 0);
           Qk : out  STD_LOGIC_VECTOR (4 downto 0);
           Vj : out  STD_LOGIC_VECTOR (31 downto 0);
           Vk : out  STD_LOGIC_VECTOR (31 downto 0));
end component;

component RS is
    Port ( CLK : in  STD_LOGIC;
           RST : in  STD_LOGIC;
 
           --ISSUE
           A_Available : out  STD_LOGIC;    
           L_Available : out  STD_LOGIC;
  
           ISSUE : in  STD_LOGIC;
           FU_type : in  STD_LOGIC_VECTOR (1 downto 0);
           FOP : in  STD_LOGIC_VECTOR (1 downto 0);
   
           Vj : in  STD_LOGIC_VECTOR (31 downto 0);
           Qj : in  STD_LOGIC_VECTOR (4 downto 0);
           Vk : in  STD_LOGIC_VECTOR (31 downto 0);
           Qk : in  STD_LOGIC_VECTOR (4 downto 0);
   
           Tag_Accepted : out  STD_LOGIC_VECTOR (4 downto 0);
           
           Immed : in  STD_LOGIC;
           V_immed : in  STD_LOGIC_VECTOR (31 downto 0); 
  
           --CDB
           CDB_V : in  STD_LOGIC_VECTOR (31 downto 0);
           CDB_Q : in  STD_LOGIC_VECTOR (4 downto 0);
 
           --A_RS to A_FU
           A_Ready : out  STD_LOGIC;
           A_Op : out  STD_LOGIC_VECTOR (1 downto 0);
           A_Vj : out  STD_LOGIC_VECTOR (31 downto 0);
           A_Vk : out  STD_LOGIC_VECTOR (31 downto 0);
           A_Tag : out  STD_LOGIC_VECTOR (4 downto 0);
           A_Accepted : in  STD_LOGIC_VECTOR (4 downto 0);

           --L_RS to L_FU
           L_Ready : out  STD_LOGIC;
           L_Op : out  STD_LOGIC_VECTOR (1 downto 0);
           L_Vj : out  STD_LOGIC_VECTOR (31 downto 0);
           L_Vk : out  STD_LOGIC_VECTOR (31 downto 0);
           L_Tag : out  STD_LOGIC_VECTOR (4 downto 0);
           L_Accepted : in  STD_LOGIC_VECTOR (4 downto 0));
end component;


component FU is
    Port ( CLK : in  STD_LOGIC;
           RST : in  STD_LOGIC;
 
           --Aritmetic FU
           A_Ready : in  STD_LOGIC;                            
           A_Tag : in  STD_LOGIC_VECTOR (4 downto 0);
           A_Op : in  STD_LOGIC_VECTOR (1 downto 0);
           A_Vj : in  STD_LOGIC_VECTOR (31 downto 0);
           A_Vk : in  STD_LOGIC_VECTOR (31 downto 0);
           A_Accepted : out  STD_LOGIC_VECTOR (4 downto 0);                            
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
           L_Accepted : out  STD_LOGIC_VECTOR (4 downto 0);                            
           L_Request : out  STD_LOGIC;                            
           L_Grant : in  STD_LOGIC;                            
           L_Q : out  STD_LOGIC_VECTOR (4 downto 0);
           L_V : out  STD_LOGIC_VECTOR (31 downto 0));
end component;


component CDB is
    Port ( RST : in  STD_LOGIC;
           CLK : in  STD_LOGIC;
           A_REQUEST : in  STD_LOGIC;
           A_V : in  STD_LOGIC_VECTOR (31 downto 0);
           A_Q : in  STD_LOGIC_VECTOR (4 downto 0);
           L_REQUEST : in  STD_LOGIC;
           L_V : in  STD_LOGIC_VECTOR (31 downto 0);
           L_Q : in  STD_LOGIC_VECTOR (4 downto 0);
           A_GRAND : out STD_LOGIC;
           L_GRAND : out STD_LOGIC;
           CDB_V : out  STD_LOGIC_VECTOR (31 downto 0);
           CDB_Q : out  STD_LOGIC_VECTOR (4 downto 0));
end component;

--Issue
signal Tag_WE_TMP : STD_LOGIC;

--CDB
signal CDB_V_TMP: STD_LOGIC_VECTOR (31 downto 0);
signal CDB_Q_TMP : STD_LOGIC_VECTOR (4 downto 0);

--RS
signal Vk_TMP, Vj_TMP : STD_LOGIC_VECTOR (31 downto 0);
signal Qk_TMP, Qj_TMP : STD_LOGIC_VECTOR (4 downto 0);
signal Tag_Accepted_TMP : STD_LOGIC_VECTOR (4 downto 0);
signal A_Available_TMP, L_Available_TMP : STD_LOGIC;
 
--FU 
signal A_Ready_TMP, L_Ready_TMP : STD_LOGIC;
signal A_Op_TMP, L_Op_TMP: STD_LOGIC_VECTOR (1 downto 0);
signal A_Vj_TMP, A_Vk_TMP, L_Vj_TMP, L_Vk_TMP: STD_LOGIC_VECTOR (31 downto 0);
signal A_Tag_TMP, L_Tag_TMP : STD_LOGIC_VECTOR (4 downto 0);
signal A_Acccepted_TMP, L_Acccepted_TMP : STD_LOGIC_VECTOR (4 downto 0);

--CDB
signal A_Request_TMP, A_Grant_TMP, L_Request_TMP, L_Grant_TMP : STD_LOGIC;
signal A_V_TMP, L_V_TMP: STD_LOGIC_VECTOR (31 downto 0);
signal A_Q_TMP, L_Q_TMP : STD_LOGIC_VECTOR (4 downto 0);

begin

ISSUE_C : ISSUE
Port map(   CLK         => CLK,
            A_Available => A_Available_TMP,
            L_Available => L_Available_TMP,
            Issue_I     => Issue_I,
            Fu_type     => Fu_type,
            Tag_WE      => Tag_WE_TMP,
            Accepted    => Accepted);

RF_C : RF 
Port map(   CLK           => CLK,
            RST           => RST,
            Ri            => Ri,
            Rj            => Rj,
            Rk            => Rk,
            Tag_WE        => Tag_WE_TMP,
            Tag_Accepted  => Tag_Accepted_TMP,
            CDB_Q         => CDB_Q_TMP,
            CDB_V         => CDB_V_TMP,
            Qj            => Qj_TMP,
            Qk            => Qk_TMP,
            Vj            => Vj_TMP,
            Vk            => Vk_TMP);

RS_C : RS 
Port map(  CLK          => CLK,
           RST          => RST,
           A_Available  => A_Available_TMP,
           L_Available  => L_Available_TMP,
           ISSUE        => Issue_I,
           FU_type      => Fu_type,
           FOP          => FOP,
           Vj           => Vj_TMP,
           Qj           => Qj_TMP,
           Vk           => Vk_TMP,
           Qk           => Qk_TMP,
           Tag_Accepted => Tag_Accepted_TMP,
           Immed        => Immed,
           V_immed      => V_immed,
           CDB_V        => CDB_V_TMP,
           CDB_Q        => CDB_Q_TMP,
           A_Ready      => A_Ready_TMP,
           A_Op         => A_Op_TMP,
           A_Vj         => A_Vj_TMP,
           A_Vk         => A_Vk_TMP,
           A_Tag        => A_Tag_TMP,
           A_Accepted   => A_Acccepted_TMP,
           L_Ready      => L_Ready_TMP,
           L_Op         => L_Op_TMP,
           L_Vj         => L_Vj_TMP,
           L_Vk         => L_Vk_TMP,
           L_Tag        => L_Tag_TMP,
           L_Accepted   => L_Acccepted_TMP);
    
FU_C : FU 
Port map(  CLK        => CLK,
           RST        => RST,
           A_Ready    => A_Ready_TMP,                        
           A_Tag      => A_Tag_TMP,
           A_Op       => A_Op_TMP,
           A_Vj       => A_Vj_TMP,
           A_Vk       => A_Vk_TMP,
           A_Accepted => A_Acccepted_TMP,                        
           A_Request  => A_Request_TMP,                    
           A_Grant    => A_Grant_TMP,                    
           A_Q        => A_Q_TMP,
           A_V        => A_V_TMP,
           L_Ready    => L_Ready_TMP,                            
           L_Tag      => L_Tag_TMP,
           L_Op       => L_Op_TMP,
           L_Vj       => L_Vj_TMP,
           L_Vk       => L_Vk_TMP,
           L_Accepted => L_Acccepted_TMP,                        
           L_Request  => L_Request_TMP,                        
           L_Grant    => L_Grant_TMP,                        
           L_Q        => L_Q_TMP,
           L_V        => L_V_TMP);

CDB_C : CDB 
Port map(   RST       => RST,
            CLK       => CLK,
            A_REQUEST => A_Request_TMP,
            A_V       => A_V_TMP,
            A_Q       => A_Q_TMP,
            L_REQUEST => L_Request_TMP,
            L_V       => L_V_TMP,
            L_Q       => L_Q_TMP,
            A_GRAND   => A_Grant_TMP,
            L_GRAND   => L_Grant_TMP,
            CDB_V     => CDB_V_TMP,
            CDB_Q     => CDB_Q_TMP);    
  
end Behavioral;

