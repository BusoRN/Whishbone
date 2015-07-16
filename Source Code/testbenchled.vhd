--CLEMENTE TOMMASO BUSIGNANI FABIO CAMPANELLA GIOVANNI
--testbench led
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity testbenchled is
end entity testbenchled;
 
architecture test_led of testbenchled is
 signal CLK_I,RST_I,WE_I, STB_I, CYC_I,ACK_O: std_logic;
 signal SEL_I: std_logic_vector(1 downto 0);
 signal	ADR_I,DAT_O,DAT_I: std_logic_vector(15 downto 0);
 signal LEDR : std_logic_vector(17 downto 0);
 signal SW: std_logic_vector(17 downto 0);
 
 component led is 
	port( CLK_I,RST_I,WE_I, STB_I, CYC_I: in std_logic;
		SEL_I: in std_logic_vector(1 downto 0);
		ADR_I: in std_logic_vector(15 downto 0);
		DAT_O : out std_logic_vector(15 downto 0);
		DAT_I : in std_logic_vector(15 downto 0);
		LEDR : out std_logic_vector(17 downto 0);
		ACK_O: out std_logic;
		SW: in std_logic_vector(17 downto 0)
	);
end component;

begin

LUT: led port map (CLK_I=>CLK_I,RST_I=>RST_I,WE_I=>WE_I,STB_I=>STB_I,CYC_I=>CYC_I,
              SEL_I=>SEL_I,ADR_I=>ADR_I,DAT_O=>DAT_O,DAT_I=>DAT_I,LEDR=>LEDR,ACK_O=>ACK_O,SW=>SW);

process
 begin 
 
 CLK_I <= '0';
 WAIT FOR 10 ns;
 CLK_I <= '1';
 WAIT FOR 10 ns;
end process;

process
 begin
 RST_I<='1';
 ADR_I<="0000010010100000";
 STB_I<='0';
 CYC_I<='0';
 SW<="010001110101110110";
 wait for 20 ns;
RST_I<='0';
 ADR_I<="0000000000000000";
 DAT_I<="0010110110011010";
 STB_I<='1';
 CYC_I<='1';
 WE_I<='1';
 SEL_I<="11";
 wait for 35 ns;
RST_I<='0';
 ADR_I<="0000010010100000";
 STB_I<='0';
 WE_I<='0';
 CYC_I<='0';
 SW<="010001110101110110";
 DAT_I<="0000000000000000";
 wait for 5 ns;
RST_I<='0';
 ADR_I<="0000000000000000";
 WE_I<='0';
 STB_I<='1';
 CYC_I<='1';
 SEL_I<="11";
 wait for 30 ns;
 end process;
 
end test_led;
