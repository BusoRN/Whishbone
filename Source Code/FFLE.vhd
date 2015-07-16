--GIOVANNI CAMPANELLA FABIO BUSIGNANI TOMMASO CLEMENTE
------------Flip Flop con Load Enable-----------------
library IEEE;
  use IEEE.std_logic_1164.all;
 
entity FFLE is
port( D: in std_logic;
		Q : buffer std_logic;
		LE, CK, RST :in std_logic
		);
end FFLE;

architecture a of FFLE is
begin
	process(CK, RST)
	begin
		if RST = '0' then
			Q <= '0';
		elsif CK'event and CK = '1' then
			if LE = '1' then
				Q <= D;
			else
				Q<=Q;
			end if;
		end if;
	end process;
end a;