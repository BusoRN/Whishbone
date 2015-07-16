--GIOVANNI CAMPANELLA FABIO BUSIGNANI TOMMASO CLEMENTE
-------------------------------------------------------------------------
-- buffer bidirezionale
-------------------------------------
library ieee;
use ieee.std_logic_1164.all;

entity tristate is
  port (DATA_I  : in    std_logic_vector (15 downto 0);  -- input data
        DATA_O : out   std_logic_vector (15 downto 0);  -- Output data
        I_O : inout std_logic_vector (15 downto 0);  -- Bidirectional pin
        OE   : in    std_ulogic);   -- Output Enable
end tristate;

architecture RTL of tristate is

begin 
   I_O <= DATA_I when OE = '1' else (others => 'Z') ;
   DATA_O <= I_O;
end RTL;