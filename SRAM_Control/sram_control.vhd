LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all;

ENTITY sram_control IS
PORT
(	clock_50Mhz, reset, write_data 					: IN STD_LOGIC;
	WE, OE, CS										: OUT STD_LOGIC;
	address_in										: IN STD_LOGIC_VECTOR(17 downto 0);
	data_in											: IN STD_LOGIC_VECTOR(15 downto 0);
	address_switches								: IN STD_LOGIC_VECTOR(17 downto 0);
	data_out										: OUT STD_LOGIC_VECTOR(15 downto 0);
	sram_address, address_out						: OUT STD_LOGIC_VECTOR(17 downto 0);
	sram_data										: INOUT STD_LOGIC_VECTOR(15 downto 0));	
	
END sram_control;

ARCHITECTURE behav OF sram_control IS

TYPE STATE_TYPE IS (idle, read1, read2, read3, read4, read5, write1, write2, write3, write4);
SIGNAL state: STATE_TYPE;
SIGNAL data_in_temp: STD_LOGIC_VECTOR(15 downto 0);
SIGNAL data_out_temp: STD_LOGIC_VECTOR(15 downto 0);
SIGNAL data_in_value: STD_LOGIC_VECTOR(15 downto 0);
SIGNAL data_out_value: STD_LOGIC_VECTOR(15 downto 0);
SIGNAL address_bus: STD_LOGIC_VECTOR(17 downto 0);
SIGNAL read_en, write_en: STD_LOGIC;

BEGIN
	address_bus<=address_in WHEN write_data='1' ELSE address_switches; --multiplex the address selection
	sram_address<=address_bus; -- SRAM address is multiplexed address
	address_out <= address_bus;
	
	data_out_temp <= data_in; 
	data_out <= data_in_temp; --connecting pins to data to and from controller to and from SRAM
	
FF: PROCESS(clock_50Mhz, reset)
BEGIN	
		
 IF (clock_50Mhz = '1' AND clock_50Mhz'EVENT) THEN 
  			
			data_out_value <= data_out_temp;
			data_in_temp <= data_in_value;
			
     END IF;
END PROCESS FF; 

PROCESS (sram_data, data_out_value, write_data) 
BEGIN                    				 
	IF( write_data='1') THEN 
		write_en<='1';
		read_en<='0';
		sram_data <= data_out_value;
		data_in_value <= sram_data;
		
	ELSE
		read_en<='1';
		write_en<='0';
		sram_data <= (others => 'Z');
		data_in_value <= sram_data;		
		
	END IF;
END PROCESS;
	
PROCESS
BEGIN
WAIT UNTIL clock_50Mhz'EVENT AND clock_50Mhz = '1'; 
IF reset='0' THEN
		--DATA_OUT <= X"0000"; -- clear outputs to LEDs
		WE<='1';
		CS<='1';
		OE<='1'; -- initialise the SRAM control lines
	--	FLAG<='1'; -- set the flag so data can be written to first location
		state<=idle;
ELSE		
CASE state IS

WHEN idle =>
	IF(write_en = '1') THEN
	WE <= '1';
	OE <= '1';
	CS <= '1';
	state <= write1;
	ELSIF(read_en = '1') THEN
	WE <= '1';
	OE <= '1';
	CS <= '1';
	state <= read1;
	ELSE
	WE <= '1';
	OE <= '1';
	CS <= '1';
	state <= idle;
	END IF;

WHEN read1 =>
	WE <= '1';
	OE <= '1';
	CS <= '1';
	state <= read2;
WHEN read2 =>
	WE <= '1';
	OE <= '1';
	CS <= '0';
	state <= read3;
WHEN read3 =>
	WE <= '1';
	OE <= '0';
	CS <= '0';
	state <= read4;
WHEN read4 =>
	WE <= '1';
	OE <= '0';
	CS <= '1';
	state <= read5;
WHEN read5 =>
	WE <= '1';
	OE <= '1';
	CS <= '1';
	state <= idle;
	
WHEN write1 =>
	WE <= '1';
	OE <= '1';
	CS <= '1';
	state <= write2;
WHEN write2 =>
	WE <= '0';
	OE <= '1';
	CS <= '0';
	state <= write3;
WHEN write3 =>
	WE <= '0';
	OE <= '1';
	CS <= '0';
	state <= write4;
WHEN write4 =>
	WE <= '1';
	OE <= '1';
	CS <= '1';
	state <= idle;

END CASE;
END IF;
END PROCESS;
END behav;