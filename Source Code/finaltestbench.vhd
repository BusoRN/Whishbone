--CLEMENTE TOMMASO BUSIGNANI FABIO CAMPANELLA GIOVANNI
-- testbench di tutto il progetto
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity finaltestbench is
end entity finaltestbench;
 
architecture test of finaltestbench is
 signal CLK_I: std_logic;
 signal SW : std_logic_vector(17 downto 0);
 signal SRAM_DQ   : std_logic_vector(15 downto 0);	--	SRAM Data bus 16 Bits
 signal SRAM_ADDR : std_logic_vector(17 downto 0);		--	SRAM Address bus 18 Bits
 signal	SRAM_UB_N : std_logic;							--	SRAM High-byte Data Mas
 signal SRAM_LB_N : std_logic;							--	SRAM Low-byte Data Mask 
 signal	SRAM_WE_N : std_logic;							--	SRAM Write Enable
 signal	SRAM_CE_N : std_logic;							--	SRAM Chip Enable
 signal	SRAM_OE_N : std_logic;						--	SRAM Output Enable
 signal	LEDR : std_logic_vector(17 downto 0);

 
 component MasterSlave is
port(
		SW : in std_logic_vector ( 17 downto 0);
		SRAM_DQ   : inout std_logic_vector(15 downto 0);	--	SRAM Data bus 16 Bits
		SRAM_ADDR : out std_logic_vector(17 downto 0);		--	SRAM Address bus 18 Bits
		SRAM_UB_N : out std_logic;							--	SRAM High-byte Data Mask 
		SRAM_LB_N : out std_logic;							--	SRAM Low-byte Data Mask 
		SRAM_WE_N : out std_logic;							--	SRAM Write Enable
		SRAM_CE_N : out std_logic;							--	SRAM Chip Enable
		SRAM_OE_N : out std_logic;						--	SRAM Output Enable
		LEDR : out std_logic_vector(17 downto 0);
		CLOCK_50  : in std_logic
	);
end component;
begin

DUT: MasterSlave port map (CLOCK_50=>CLK_I,SRAM_DQ=>SRAM_DQ,SRAM_ADDR=>SRAM_ADDR,SRAM_UB_N=>SRAM_UB_N,
                           SRAM_LB_N=>SRAM_LB_N,SRAM_WE_N=>SRAM_WE_N,SRAM_CE_N=>SRAM_CE_N,
                           SRAM_OE_N=>SRAM_OE_N,LEDR=>LEDR,SW=>SW);
   
  process
 begin 
 
 CLK_I <= '0';
 WAIT FOR 10 ns;
 CLK_I <= '1';
 WAIT FOR 10 ns;
end process;

process
 begin
 
 wait for 5 ns;
 
 SW<="110001110101110110";
 
 
 end process;   
         

 end test;

