--GIOVANNI CAMPANELLA FABIO BUSIGNANI TOMMASO CLEMENTE
-- Semi synchronous bus master
-- Perform the following cycles:
-- Read from I/O slave
-- Write to memory location
-- Read from memory location
-- Write to I/O slave

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
    
entity wishbone_master is
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
end wishbone_master;

architecture behavioural of wishbone_master is

  type state_type is (RESET0, RESET1, RESET2, IDLE0, SW_RD, IDLE1, RAM_WR, IDLE2, RAM_RD, IDLE3, LED_WR);
  signal bus_state: state_type;
  signal tmp_data: std_logic_vector( 15 downto 0 );
  
begin

 -- purpose: main fsm - walk thtough the possibile access cyclea
  -- type   : sequential
  -- inputs : ck50in, reset_in
  -- outputs: 

  main_fsm: process (ck_i, reset_i)
  begin  -- process fsm
    if reset_i = '1' then              -- asynchronous reset (active high)
      bus_state <= RESET0;
    elsif ck_i'event and ck_i = '1' then  -- rising clock edge
      case bus_state is 
        when RESET0 =>
          bus_state <= RESET1;
        when RESET1 =>
          bus_state <= RESET2;
        when RESET2 =>
          bus_state <= IDLE0;
        when IDLE0 =>
          bus_state <= SW_RD;
        when SW_RD =>
          if ack_switch_i = '0' then
            bus_state <= SW_RD;
          else
            bus_state <= IDLE1;
          end if;
        when IDLE1 =>
          bus_state <= RAM_WR;
        when RAM_WR =>
          if ack_ram_i = '0' then
            bus_state <= RAM_WR;
          else
            bus_state <= IDLE2;
          end if;
        when IDLE2 =>
          bus_state <= RAM_RD;
        when RAM_RD =>
          if ack_ram_i = '0' then
            bus_state <= RAM_RD;
          else
            bus_state <= IDLE3;
          end if;
        when IDLE3 =>
          bus_state <= LED_WR;
        when LED_WR =>
          if ack_led_i = '0' then
            bus_state <= LED_WR;
          else
            bus_state <= IDLE0;
          end if;
        when others =>
          bus_state <= RESET0;
      end case;
    end if;
  end process main_fsm;
  
  sel_o <= "11";
  
  -- purpose: bus outputs generator
  -- type   : combinatorial
  -- inputs : bus_state
  busout_gen: process ( bus_state, tmp_data )
  begin  -- process busout_gen
    case bus_state is
      when RESET0 =>
        adr_o <= (others => 'X');
        dat_o <= (others => 'X');
        cyc_o <= '0';
        stb_o <= '0';
        we_o <= '0';
      when RESET1 =>
        adr_o <= (others => 'X');
        dat_o <= (others => 'X');
        cyc_o <= '0';
        stb_o <= '0';
        we_o <= '0';
      when RESET2 =>
        adr_o <= (others => 'X');
        dat_o <= (others => 'X');
        cyc_o <= '0';
        stb_o <= '0';
        we_o <= '0';
      when IDLE0 =>
        adr_o <= (others => 'X');
        dat_o <= (others => 'X');
        cyc_o <= '0';
        stb_o <= '0';
        we_o <= '0';
      when SW_RD =>
        adr_o <= conv_std_logic_vector( switch_addr, 16 );
        dat_o <= (others => 'X');
        cyc_o <= '1';
        stb_o <= '1';
        we_o <= '0';
      when IDLE1 =>
        adr_o <= (others => 'X');
        dat_o <= (others => 'X');
        cyc_o <= '0';
        stb_o <= '0';
        we_o <= '0';
      when RAM_WR =>
        adr_o <= conv_std_logic_vector( ram_addr, 16 );
        dat_o <= tmp_data;
        cyc_o <= '1';
        stb_o <= '1';
        we_o <= '1';
      when IDLE2 =>
        adr_o <= (others => 'X');
        dat_o <= (others => 'X');
        cyc_o <= '0';
        stb_o <= '0';
        we_o <= '0';
      when RAM_RD =>
        adr_o <= conv_std_logic_vector( ram_addr, 16 );
        dat_o <= (others => 'X');
        cyc_o <= '1';
        stb_o <= '1';
        we_o <= '0';
      when IDLE3 =>
        adr_o <= (others => 'X');
        dat_o <= (others => 'X');
        cyc_o <= '0';
        stb_o <= '0';
        we_o <= '0';
      when LED_WR =>
        adr_o <= conv_std_logic_vector( led_addr, 16 );
        dat_o <= tmp_data;
        cyc_o <= '1';
        stb_o <= '1';
        we_o <= '1';
      end case;
  end process busout_gen;

  data_reg: process( ck_i )
  begin
    if ( ck_i'event and ck_i = '1' ) then
      case bus_state is
        when SW_RD =>
          tmp_data <= dat_switch_i;
        when RAM_RD =>
          tmp_data <= dat_ram_i;
		  when others =>
			 tmp_data <= tmp_data;
      end case;
	 end if;
  end process data_reg;
      
end behavioural;
