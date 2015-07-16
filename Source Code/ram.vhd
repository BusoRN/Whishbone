--GIOVANNI CAMPANELLA FABIO BUSIGNANI TOMMASO CLEMENTE
-- beavioural della SRAM
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE IEEE.numeric_std.all;
 ---------------------------------------------------
 ENTITY ram IS
  GENERIC ( bits: INTEGER := 16; -- # of bits per word
			words: INTEGER := 1); -- # of words in the memory
 PORT ( wr_ena,ce,oe,lb,ub: IN STD_LOGIC;
 addr: IN std_logic_vector(15 downto 0);
 data_inout: INOUT STD_LOGIC_VECTOR (bits-1 DOWNTO 0));
 END ram;
 ---------------------------------------------------
 ARCHITECTURE behaviour OF ram IS

 BEGIN
process(addr, wr_ena,ce,oe,lb,ub)
 TYPE vector_array IS ARRAY (0 TO words-1) OF
 STD_LOGIC_VECTOR (bits-1 DOWNTO 0);
 variable memory: vector_array;
  begin
data_inout <= (others=> 'Z');

 IF (ce='0') THEN
	IF (wr_ena='0' and lb = '0' and UB = '0' and oe ='0') THEN
		data_inout<=memory(to_integer(unsigned(addr)));
	elsif (wr_ena='1' and lb = '0' and UB = '0' and oe ='0') THEN
		memory(to_integer(unsigned(addr))):=data_inout;
	END IF;
 END IF;
 end process;
 
 
 END behaviour;
 ---------------------------------------------------
