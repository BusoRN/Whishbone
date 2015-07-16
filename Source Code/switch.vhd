--GIOVANNI CAMPANELLA FABIO BUSIGNANI TOMMASO CLEMENTE
-- Slave interface degli switch

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity switch2 is
generic ( start_address, size : integer := 0);
port( CLK_I,RST_I,WE_I, STB_I, CYC_I: in std_logic;
		ADR_I: in std_logic_vector(15 downto 0);
		DAT_O : out std_logic_vector(15 downto 0);
		ACK_O: out std_logic;
		SW : in std_logic_vector(17 downto 0)
		);
end switch2;

architecture A of switch2 is
component DP_switch is
port( LE,CK: in std_logic;
		SW : in std_logic_vector(17 downto 0); 
		dato_out : out std_logic_vector(15 downto 0)
		);
end component;

component FSM_switch is
generic ( start_address, size : integer := 0);
port (	adr_I: in std_logic_vector(15 downto 0);
		stb_I, rst_I, clk_I, cyc_I, WE_I: in std_logic;
		ACK_O,Enable: out std_logic
	);
end component;

signal Enable: std_logic;
begin
U1: DP_switch port map (CK => CLK_I, dato_out => DAT_O, LE => Enable, SW => SW);
U2: FSM_switch generic map (start_address => start_address, size => size) port map (Enable => Enable, ACK_O => ACK_O, adr_I => ADR_I, stb_I => STB_I,rst_I =>RST_I,clk_I =>CLK_I ,WE_I =>WE_I, cyc_I =>CYC_I);

end A;



-----------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity FSM_switch is
generic ( start_address, size : integer := 0);
port (	adr_I: in std_logic_vector(15 downto 0);
		stb_I, rst_I, clk_I, cyc_I, WE_I : in std_logic;
		ACK_O,Enable: out std_logic
	);
end FSM_switch;

architecture A of FSM_switch is
type stato is (idle, read1);
signal cs, ns: stato;
signal address: integer;
begin
address <= conv_integer( adr_I ); -- converto in un intero il valore dell'indirizzo
------lower section------
	Process(rst_I, clk_I)
	begin
		if(rst_I='1') then
			cs <= idle;
		elsif clk_I'event and clk_I = '1' then
			cs<=ns;
		end if;
	end process;
--------upper section-----
	process(cs, stb_I, address, cyc_I, WE_I )
	begin
		case cs is
			when idle =>
				ACK_O <= '0';
				Enable <= '1';
				if (((start_address <= address) and (address <= start_address+size)) 
					and (stb_I = '1') and (cyc_I = '1') and (WE_I='0')) then
					ns <= read1;
				else
					ns <= idle;
				end if;
			
			when read1 =>
				ACK_O <= '1';
				Enable <= '0';
				ns <= idle;
		end case;
	end process;
end A;


-----------------------------------------------DP--------------------------------------------------------------
library IEEE;
use ieee.std_logic_1164.all;

entity DP_switch is
	port( LE,CK: in std_logic;
		SW : in std_logic_vector(17 downto 0); 
		dato_out : out std_logic_vector(15 downto 0)
		);
end DP_switch;

architecture a of DP_switch is
component FFLE is
port(	 D: in std_logic;
		Q : buffer std_logic;
		LE, CK, RST :in std_logic
		);
end component;
signal uscita : std_logic_vector(15 downto 0);
begin
	s1: for i in 0 to 15 generate
			FFLEi: FFLE port map (CK => CK, LE => LE, Q =>uscita(i), D =>SW(i), RST => SW(16));
		end generate;
	dato_out <= uscita;
end a;