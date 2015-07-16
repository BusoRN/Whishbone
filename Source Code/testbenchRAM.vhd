--GIOVANNI CAMPANELLA FABIO BUSIGNANI TOMMASO CLEMENTE
--TestBench della Ram
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity testbench is
end entity testbench;
 
architecture test_sram of testbench is
 signal CLK_I,RST_I,WE_I, STB_I, CYC_I,ACK_O: std_logic;
 signal SEL_I: std_logic_vector(1 downto 0);
 signal	ADR_I,DAT_O,DAT_I: std_logic_vector(15 downto 0);
 signal SW: std_logic_vector(17 downto 0);
 signal SRAM_DQ : std_logic_vector(15 downto 0);	
 signal SRAM_ADDR : std_logic_vector(17 downto 0);
 signal SRAM_UB_N,SRAM_LB_N,SRAM_WE_N,SRAM_CE_N,SRAM_OE_N : std_logic;							
		
 component SRAM is 
	port(ACK_O: out std_logic;
		ADD_I, DAT_I : in std_logic_vector(15 downto 0);   
		DAT_O : out std_logic_vector (15 downto 0);
		WE_I, RST_I, CLK_I, STB_I,CYC_I: in std_logic;
		SEL_I: in std_logic_vector(1 downto 0);
		SW : in std_logic_vector ( 17 downto 0);
		SRAM_DQ   : inout std_logic_vector(15 downto 0);	--	SRAM Data bus 16 Bits
		SRAM_ADDR : out std_logic_vector(17 downto 0);		--	SRAM Address bus 18 Bits
		SRAM_UB_N : out std_logic;							--	SRAM High-byte Data Mask 
		SRAM_LB_N : out std_logic;							--	SRAM Low-byte Data Mask 
		SRAM_WE_N : out std_logic;							--	SRAM Write Enable
		SRAM_CE_N : out std_logic;							--	SRAM Chip Enable
		SRAM_OE_N : out std_logic							--	SRAM Output Enable
	);
end component;

begin

RUT: SRAM port map (CLK_I=>CLK_I,RST_I=>RST_I,WE_I=>WE_I,STB_I=>STB_I,CYC_I=>CYC_I,
              SEL_I=>SEL_I,ADD_I=>ADR_I,DAT_O=>DAT_O,DAT_I=>DAT_I,ACK_O=>ACK_O,SW=>SW,
              SRAM_DQ=>SRAM_DQ,SRAM_ADDR=>SRAM_ADDR,SRAM_UB_N=>SRAM_UB_N,SRAM_LB_N=>SRAM_LB_N, 
		      SRAM_WE_N=>SRAM_WE_N, SRAM_CE_N=>SRAM_CE_N,SRAM_OE_N=>SRAM_OE_N );
	
 process
 begin 
 
 CLK_I <= '0';
 WAIT FOR 10 ns;
 CLK_I <= '1';
 WAIT FOR 10 ns;
 end process;

 process 
 begin
 rst_i <= '0';
 WAIT FOR 5 ns;
 STB_I<='1';
 CYC_I<='1';
 WE_I<='1';
 ADR_I<="0000000000000000";
 SEL_I<="11";
 DAT_I<="0010011000010000";
 SW<="110000110011101010";
 WAIT FOR 40 ns;
 
STB_I<='0';
CYC_I<='0';
SEL_I<="00";
WE_I<='0';
 
 wait for 5 ns;
 STB_I<='1';
 CYC_I<='1';
 WE_I<='1';
 ADR_I<="0000000000000000";
 SEL_I<="11";
 SW<="110000110011101010";
 
 wait for 5 ns;
 STB_I<='1';
 CYC_I<='1';
 WE_I<='0';
 ADR_I<="0000000000000000";
 SEL_I<="11";
 DAT_I<="0011111000000001";
 SW<="110000110011101010";
 WAIT FOR 40 ns;
 STB_I<='0';
 CYC_I<='0';
 SEL_I<="00";
 WE_I<='0';
 wait for 5 ns;
 STB_I<='1';
 CYC_I<='1';
 WE_I<='0';
 ADR_I<="0000000000000000";
 SEL_I<="11";
 SW<="110000110011101010";

 
 
 end process;
 	      

		      
end test_sram;