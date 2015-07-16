library ieee;
use ieee.std_logic_1164.all;

entity MasterSlave is
generic( StartAdderess_sram: integer := 0;
			StartAddress_LED: integer := 65534;
			StartAddress_Switch: integer := 65535;
			Size_sram : integer := 65533;
			Size_led : integer := 0;
			Size_Switch : integer := 0
);
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
end MasterSlave;
architecture A of MasterSlave is
component switch2 is
generic ( start_address, size : integer := 0);
--avvalendosi della regola 3.40, possiamo ridurre il numero delle porte di ingresso e uscita,
--l'interfaccia minima è data dai seguenti segnali: [ACK_O],[CLK_I],[CYC_I],[STB_I] e [RST_I]
port( CLK_I,RST_I,WE_I, STB_I, CYC_I: in std_logic;
		ADR_I: in std_logic_vector(15 downto 0);
		DAT_O : out std_logic_vector(15 downto 0);
		ACK_O: out std_logic;
		SW : in std_logic_vector(17 downto 0)
		);
end component;

component SRAM is
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
end component;

component LED is
generic( start_address, size : integer := 0);
port( CLK_I,RST_I,WE_I, STB_I, CYC_I: in std_logic;
		SEL_I: in std_logic_vector(1 downto 0);--implemento la selezione, se il master non l'ha � meglio cancellarla
		ADR_I: in std_logic_vector(15 downto 0);
		DAT_O : out std_logic_vector(15 downto 0);
		DAT_I : in std_logic_vector(15 downto 0);
		LEDR : out std_logic_vector(17 downto 0);
		ACK_O: out std_logic;
		SW: in std_logic_vector(17 downto 0)
	);
end component;

component wishbone_master is
    generic (
	switch_addr: integer := 35;
   ram_addr: integer := 12;
	led_addr: integer := 98
    );
    port (
      ck_i : in std_logic;
      reset_i : in std_logic;
      -- Address bus
      adr_o: out std_logic_vector( 15 downto 0 );
      -- Data bus (split into three read and one write bus)
      dat_o: out std_logic_vector( 15 downto 0 );
      dat_switch_i: in std_logic_vector( 15 downto 0 );
      dat_ram_i: in std_logic_vector( 15 downto 0 );
      dat_led_i: in std_logic_vector( 15 downto 0 );
      -- Control signals
      cyc_o: out std_logic; -- Transfer start
      stb_o: out std_logic;
      ack_switch_i: in std_logic; -- Wait input, used to stretch bus cycles
      ack_ram_i: in std_logic; -- Wait input, used to stretch bus cycles
      ack_led_i: in std_logic; -- Wait input, used to stretch bus cycles
      we_o: out std_logic; -- Transfer direction: 0 = read, 1 = write
      sel_o: out std_logic_vector( 1 downto 0 )
    );
end component;

signal adr, dat_switch_o, dat, dat_led_o,dat_sram_o : std_logic_vector(15 downto 0);
signal stb_I, cyc_I, ack_led_o, ack_sram_o, ack_switch_o, we_I : std_logic;
signal reset : std_logic;
signal sel_I : std_logic_vector(1 downto 0);
		
begin

reset <= sw(17);
U1 : wishbone_master generic map (switch_addr => StartAddress_Switch,ram_addr =>StartAdderess_sram ,led_addr => StartAddress_LED) 
			port map(ck_i => CLOCK_50,reset_i => reset,adr_o => adr,dat_o => dat ,dat_switch_i => dat_switch_o ,
		dat_ram_i => dat_sram_o,dat_led_i => dat_led_o,cyc_o => cyc_I,stb_o => stb_I,ack_switch_i =>ack_switch_o, 
		ack_ram_i =>ack_sram_o ,ack_led_i =>ack_led_o, we_o =>we_i, sel_o=>sel_I );
U2 : LED generic map (start_address => StartAddress_LED , size => Size_led) 
			port map (CLK_I => CLOCK_50,RST_I=>reset,WE_I=>we_I, STB_I=> stb_I, 
			CYC_I =>cyc_I,SEL_I => sel_I, ADR_I => adr, DAT_O => dat_led_o,DAT_I => dat,LEDR => LEDR,
			ACK_O => ack_led_o, SW => SW);
U3 : switch2 generic map(start_address => StartAddress_Switch, size => Size_Switch) 
		port map (CLK_I => CLOCK_50,RST_I=>reset,WE_I=>we_I, STB_I=> stb_I,
		CYC_I =>cyc_I, ADR_I => adr, DAT_O => dat_switch_o,
		ACK_O => ack_switch_o, SW => SW);
U4 : SRAM generic map(start_address => StartAdderess_sram , size =>Size_sram) 
	port map (CLK_I => CLOCK_50,RST_I=>reset,WE_I=>we_I, STB_I=> stb_I, 
	CYC_I =>cyc_I,SEL_I => sel_I, ADD_I => adr, DAT_O => dat_sram_o,DAT_I => dat,
	ACK_O => ack_sram_o, SW => SW, SRAM_DQ => SRAM_DQ, SRAM_ADDR => SRAM_ADDR,
	SRAM_UB_N => SRAM_UB_N, SRAM_LB_N => SRAM_LB_N, SRAM_WE_N => SRAM_WE_N,
	SRAM_CE_N => SRAM_CE_N, SRAM_OE_N => SRAM_OE_N );
	

end A;