--GIOVANNI CAMPANELLA FABIO BUSIGNANI TOMMASO CLEMENTE
---------------------------------------------LED------------------------------------------------------------
library IEEE;
use ieee.std_logic_1164.all;

entity LED is
generic( start_address, size : integer := 0);
port( CLK_I,RST_I,WE_I, STB_I, CYC_I: in std_logic;
		SEL_I: in std_logic_vector(1 downto 0);
		ADR_I: in std_logic_vector(15 downto 0);
		DAT_O : out std_logic_vector(15 downto 0);
		DAT_I : in std_logic_vector(15 downto 0);
		LEDR : out std_logic_vector(17 downto 0);
		ACK_O: out std_logic;
		SW: in std_logic_vector(17 downto 0)
	);
end LED;

architecture A of LED is
component FSM is
generic ( start_address, size : integer := 0);
port (	adr_I: in std_logic_vector(15 downto 0);
		stb_I, rst_I, clk_I, cyc_I, WE_I : in std_logic;
		Enable, ack_o : out std_logic
	);
end component;

component DP is
	port( SEL: in std_logic_vector(1 downto 0);
		LE,CK: in std_logic;
		dato_in : in std_logic_vector(15 downto 0);
		dato_out :out std_logic_vector(15 downto 0);
		LEDR : out std_logic_vector(17 downto 0);
		SW: in std_logic_vector(17 downto 0)
		);
end component;
signal LE : std_logic;
begin
U1: DP port map (SEL => SEL_I ,LE => LE ,CK => CLK_I ,dato_in => DAT_I ,
	dato_out => DAT_O, SW =>SW, LEDR => LEDR);
U2: FSM generic map (start_address => start_address, size => size) 
	port map (adr_I => ADR_I ,stb_I => STB_I ,rst_I => RST_I ,clk_I => CLK_I ,
	cyc_I => CYC_I , WE_I => WE_I ,Enable => LE ,ack_O => ACK_O );
end A;

-----------------------------------------------LOAD ENABLE-----------------------------------------------------
library IEEE;
use ieee.std_logic_1164.all;

entity Load_Enable is
	port( 	LE: in std_logic;
			SEL: in std_logic_vector(1 downto 0);
			LE_O: out std_logic_vector(1 downto 0));
end Load_Enable;

architecture A of Load_Enable is
begin
	LE_O(0) <= LE and SEL(0);
	LE_O(1) <= LE and SEL(1);
end A;
-----------------------------------------------DP--------------------------------------------------------------
library IEEE;
use ieee.std_logic_1164.all;

entity DP is
	port( SEL: in std_logic_vector(1 downto 0);
		LE,CK: in std_logic;
		dato_in : in std_logic_vector(15 downto 0);
		dato_out : out std_logic_vector(15 downto 0);
		LEDR : out std_logic_vector(17 downto 0);
		SW: in std_logic_vector(17 downto 0)
		);
end DP;

architecture a of DP is
component FFLE is
	port( 	D: in std_logic;
			Q : buffer std_logic;
			LE, CK, RST :in std_logic
		);end component;
component Load_Enable is
	port( 	LE: in std_logic;
			SEL: in std_logic_vector(1 downto 0);
			LE_O: out std_logic_vector(1 downto 0));
end component;
signal LE1, LE2 : std_logic;
signal uscita : std_logic_vector(15 downto 0);
begin
	s1: for i in 0 to 7 generate
			bloccoi: FFLE port map (D => dato_in(i), CK=> CK, LE => LE1, Q =>uscita(i), RST=>SW(16));
		end generate;
	s2: for i in 8 to 15 generate
			blocco2_i: FFLE port map (D => dato_in(i), CK => CK, LE => LE2, Q =>uscita(i), RST => SW(16));
		end generate; 
	s3: Load_Enable port map (LE => LE, SEL => SEL, LE_O(0) => LE1, LE_O(1) => LE2);
	dato_out <= uscita;
	LEDR(15 downto 0) <= uscita;
end a;
------------------------------------------------FSM--------------------------------------------------------------------------
library IEEE;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity FSM is
generic ( start_address, size : integer := 0);
port (	adr_I: in std_logic_vector(15 downto 0);
		stb_I, rst_I, clk_I, cyc_I, WE_I : in std_logic;
		Enable, ack_o : out std_logic
	);
end FSM;
architecture a of FSM is
type stato is(idle, load1, --load2,
  read1);
signal cs,ns: stato;
signal address: integer;
begin
address <= conv_integer( adr_I );
	process(clk_i, rst_i)
	begin
		if rst_i = '1' then
			cs <= idle;
		elsif clk_i'event and clk_i = '1' then
			cs <= ns;
		end if;
	end process;
	process(cs, stb_I, cyc_I, WE_I, address)
	begin
	case cs is
		when idle =>
			Enable <= '0';
			ack_o <= '0';
			if (((start_address <= address) and (address <= start_address+size)) 
				and (stb_I = '1') and (cyc_I = '1') and (WE_I='1')) then
				ns <= load1;
			elsif (((start_address <= address) and (address <= start_address+size)) 
				and (stb_I = '1') and (cyc_I = '1') and (WE_I='0')) then
				ns <= read1;
			else
				ns <= idle;
			end if;
		when load1 =>
			Enable <= '1';
			ack_o <= '1';
			ns <= idle;
		when read1 =>
			Enable <= '0';
			ack_o <= '1';
			ns <= idle;
		
	end case;
end process;
end A;
