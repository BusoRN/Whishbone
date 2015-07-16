library IEEE;
  use IEEE.std_logic_1164.all;
 
 entity DP_RAM is
 port( ADD_I, DAT_I : in std_logic_vector(15 downto 0);
		DAT_O : out std_logic_vector (15 downto 0);
		CLK_I, OE_DI : in std_logic;
		RAM_ADDR : out std_logic_vector ( 17 downto 0);
		RAM_DQ : inout std_logic_vector (15 downto 0);
		SW : in std_logic_vector ( 17 downto 0)
		);
 end DP_RAM;
 
 architecture A of DP_RAM is
component tristate is
  port (DATA_I  : in    std_logic_vector (15 downto 0);  -- input data
        DATA_O : out   std_logic_vector (15 downto 0);  -- Output data
        I_O : inout std_logic_vector (15 downto 0);  -- Bidirectional pin
        OE   : in    std_ulogic);   -- Output Enable
end component;
begin
	RAM_ADDR(17 downto 16) <= (others=>'0');
	u2: tristate port map (DATA_I => dato_ingresso, DATA_O => dato_uscita, I_O => RAM_DQ, OE => OE_DI);
end A;