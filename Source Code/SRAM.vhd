--GIOVANNI CAMPANELLA FABIO BUSIGNANI TOMMASO CLEMENTE
--Slave interface della SRAM
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity FSM_RAM is
generic(start_address: integer := 0;
		size: integer :=0
		);
port (ACK_O: out std_logic;
		ADR_I:in std_logic_vector(15 downto 0);
		WE_I, RST_I, CLK_I, STB_I,CYC_I: in std_logic;
		OE, CS, WE, OE_DI : out std_logic);
end FSM_RAM;
architecture A of FSM_RAM is
type stato is (idle, read1, write1, wait_write);
signal stato_corrente, stato_futuro: stato;
signal address :integer;

begin
	address <= conv_integer(ADR_I);
	process( RST_I, CLK_I)
	begin
		if(RST_I = '1') then
			stato_corrente<= idle;
		elsif CLK_I'event and CLK_I = '1' then
			stato_corrente <= stato_futuro;
			
		end if;
	end process;
	process(stato_corrente, address, WE_I, RST_I,CLK_I, STB_I,CYC_I)
	begin
		case stato_corrente is
			when idle =>
				CS <= '1';
				ACK_O <= '0';
				WE <= '0';
				OE <= '1';
				OE_DI <= '1';
				if ( (start_address <= address) and (address <= start_address+size) and (stb_I = '1') and (cyc_I = '1')) then
					if WE_I = '0' then
						stato_futuro <= read1;
					else 
						stato_futuro <= wait_write;
					end if;
				    else 
				        stato_futuro<=idle;
				    end if;
			when read1 =>
				ACK_O <= '1';
				WE <= '1';
				CS <= '0';
				OE <= '0';
				OE_DI <= '0';
				stato_futuro <= idle;
			when wait_write =>
				ACK_O <= '0';
				WE <= '0';
				OE <= '1';
				OE_DI <= '1';
				CS <= '0';
				stato_futuro <= write1;
			when write1 =>
				ACK_O <= '1';
				WE <= '0';
				OE <= '1';
				OE_DI <= '1';
				CS <= '0';
				stato_futuro <= idle;
		end case;
	end process;
end A;
------------------------------------------------------------------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

entity SRAM is
generic (start_address: integer := 0;
		size: integer :=4
		);
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
end SRAM;
architecture A of SRAM is
component FSM_RAM is
generic(start_address: integer := 0;
		size: integer :=4
		);
port (ACK_O: out std_logic;
		ADR_I:in std_logic_vector(15 downto 0);
		WE_I, RST_I, CLK_I, STB_I,CYC_I: in std_logic;
		OE, CS, WE, OE_DI : out std_logic);
end component;
component DP_RAM is
 port( ADD_I, DAT_I : in std_logic_vector(15 downto 0);
		DAT_O : out std_logic_vector (15 downto 0);
		OE_DI : in std_logic;
		RAM_ADDR : out std_logic_vector ( 17 downto 0);
		RAM_DQ : inout std_logic_vector (15 downto 0)
		);
 end component;
 
 
signal writeenable:std_logic;
 signal enable_tristate: std_logic;
 begin
    SRAM_UB_N<= not(SEL_I(1));
    SRAM_LB_N<= not(SEL_I(0));
    
    
	S1: DP_RAM port map(ADD_I => ADD_I, DAT_I => DAT_I,DAT_O => DAT_O, OE_DI => enable_tristate,RAM_ADDR=> SRAM_ADDR,RAM_DQ => SRAM_DQ);
	S2: FSM_RAM generic map(start_address=>start_address, size => size) port map (ACK_O => ACK_O ,ADR_I => ADD_I ,
	WE_I => WE_I ,RST_I => RST_I ,CLK_I =>CLK_I ,STB_I =>STB_I ,CYC_I =>CYC_I, OE => SRAM_OE_N , CS =>SRAM_CE_N , 
	WE => SRAM_WE_N, OE_DI =>enable_tristate );
end A;