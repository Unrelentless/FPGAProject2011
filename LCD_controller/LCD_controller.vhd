LIBRARY IEEE;
USE  IEEE.STD_LOGIC_1164.all;
USE  IEEE.STD_LOGIC_ARITH.all;
USE  IEEE.STD_LOGIC_UNSIGNED.all;

-- This code displays time in the DE2's LCD Display
-- Key2  resets time
ENTITY LCD_controller IS

	PORT(clock_50Mhz, reset							: IN	STD_LOGIC;
		 LCD_EN, LCD_RS, LCD_ON						: OUT	STD_LOGIC;
		 LCD_RW										: BUFFER STD_LOGIC;
		 data_in									: IN	STD_LOGIC_VECTOR(15 DOWNTO 0);
		 address_in									: IN	STD_LOGIC_VECTOR(17 DOWNTO 0);
		 data_bus									: INOUT	STD_LOGIC_VECTOR(7 DOWNTO 0));
END LCD_controller;

ARCHITECTURE operation OF LCD_controller IS
	
	TYPE STATE_TYPE IS (HOLD, FUNC_SET, DISPLAY_ON, MODE_SET, MODE_SET2, WRITE_ADD1,
	WRITE_ADD2,WRITE_ADD3,WRITE_ADD4,WRITE_ADD5,WRITE_ADD6,WRITE_ADD7,
	WRITE_ADD8, WRITE_ADD9, WRITE_ADD10,WRITE_ADD11,WRITE_ADD12,
	WRITE_ADD13, WRITE_ADD14, WRITE_ADD15, WRITE_ADD16, WRITE_DATA1,
	WRITE_DATA2,WRITE_DATA3,WRITE_DATA4,WRITE_DATA5,WRITE_DATA6,WRITE_DATA7,
	WRITE_DATA8, WRITE_DATA9, WRITE_DATA10,WRITE_DATA11,WRITE_DATA12,
	WRITE_DATA13, WRITE_DATA14, WRITE_DATA15, WRITE_DATA16, RETURN_HOME, 
	TOGGLE_E, RESET1, RESET2, RESET3, DISPLAY_OFF, DISPLAY_CLEAR);
	
	SIGNAL state, next_command: STATE_TYPE;
	SIGNAL data_1, data_2, data_3, data_4		: STD_LOGIC_VECTOR(3 DOWNTO 0);
	SIGNAL add_1, add_2, add_3, add_4, add_5	: STD_LOGIC_VECTOR(3 DOWNTO 0);
	SIGNAL data_bus_value						: STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL clock_count_400Hz					: STD_LOGIC_VECTOR(19 DOWNTO 0);
	SIGNAL clock_400Hz		 					: STD_LOGIC;
	
BEGIN
	LCD_ON <= '1';
-- BIDIRECTIONAL TRI STATE LCD DATA BUS
	data_bus <= data_bus_value WHEN LCD_RW = '0' ELSE "ZZZZZZZZ";

	add_1 <= X"1" WHEN address_in(3 downto 0) = X"1" OR address_in(3 downto 0) = X"A" ELSE
			X"2" WHEN address_in(3 downto 0) = X"2" OR address_in(3 downto 0) = X"B" ELSE
			X"3" WHEN address_in(3 downto 0) = X"3" OR address_in(3 downto 0) = X"C" ELSE
			X"4" WHEN address_in(3 downto 0) = X"4" OR address_in(3 downto 0) = X"D" ELSE
			X"5" WHEN address_in(3 downto 0) = X"5" OR address_in(3 downto 0) = X"E" ELSE
			X"6" WHEN address_in(3 downto 0) = X"6" OR address_in(3 downto 0) = X"F" ELSE
			X"7" WHEN address_in(3 downto 0) = X"7" ELSE
			X"8" WHEN address_in(3 downto 0) = X"8" ELSE
			X"9" WHEN address_in(3 downto 0) = X"9" ELSE
			X"0";
			
			
	add_2 <= X"1" WHEN address_in(7 downto 4) = X"1" OR address_in(7 downto 4) = X"A" ELSE
			X"2" WHEN address_in(7 downto 4) = X"2" OR address_in(7 downto 4) = X"B" ELSE
			X"3" WHEN address_in(7 downto 4) = X"3" OR address_in(7 downto 4) = X"C" ELSE
			X"4" WHEN address_in(7 downto 4) = X"4" OR address_in(7 downto 4) = X"D" ELSE
			X"5" WHEN address_in(7 downto 4) = X"5" OR address_in(7 downto 4) = X"E" ELSE
			X"6" WHEN address_in(7 downto 4) = X"6" OR address_in(7 downto 4) = X"F" ELSE
			X"7" WHEN address_in(7 downto 4) = X"7" ELSE
			X"8" WHEN address_in(7 downto 4) = X"8" ELSE
			X"9" WHEN address_in(7 downto 4) = X"9" ELSE
			X"0";
			
	add_3 <= X"1" WHEN address_in(11 downto 8) = X"1" OR address_in(11 downto 8) = X"A" ELSE
			X"2" WHEN address_in(11 downto 8) = X"2" OR address_in(11 downto 8) = X"B" ELSE
			X"3" WHEN address_in(11 downto 8) = X"3" OR address_in(11 downto 8) = X"C" ELSE
			X"4" WHEN address_in(11 downto 8) = X"4" OR address_in(11 downto 8) = X"D" ELSE
			X"5" WHEN address_in(11 downto 8) = X"5" OR address_in(11 downto 8) = X"E" ELSE
			X"6" WHEN address_in(11 downto 8) = X"6" OR address_in(11 downto 8) = X"F" ELSE
			X"7" WHEN address_in(11 downto 8) = X"7" ELSE
			X"8" WHEN address_in(11 downto 8) = X"8" ELSE
			X"9" WHEN address_in(11 downto 8) = X"9" ELSE
			X"0";
			
	add_4 <= X"1" WHEN address_in(15 downto 12) = X"1" OR address_in(15 downto 12) = X"A" ELSE
			X"2" WHEN address_in(15 downto 12) = X"2" OR address_in(15 downto 12) = X"B" ELSE
			X"3" WHEN address_in(15 downto 12) = X"3" OR address_in(15 downto 12) = X"C" ELSE
			X"4" WHEN address_in(15 downto 12) = X"4" OR address_in(15 downto 12) = X"D" ELSE
			X"5" WHEN address_in(15 downto 12) = X"5" OR address_in(15 downto 12) = X"E" ELSE
			X"6" WHEN address_in(15 downto 12) = X"6" OR address_in(15 downto 12) = X"F" ELSE
			X"7" WHEN address_in(15 downto 12) = X"7" ELSE
			X"8" WHEN address_in(15 downto 12) = X"8" ELSE
			X"9" WHEN address_in(15 downto 12) = X"9" ELSE
			X"0";
			
	add_5 <= "00" & address_in(17 downto 16);
	
	data_1 <= X"1" WHEN data_in(3 downto 0) = X"1" OR data_in(3 downto 0) = X"A" ELSE
			X"2" WHEN data_in(3 downto 0) = X"2" OR data_in(3 downto 0) = X"B" ELSE
			X"3" WHEN data_in(3 downto 0) = X"3" OR data_in(3 downto 0) = X"C" ELSE
			X"4" WHEN data_in(3 downto 0) = X"4" OR data_in(3 downto 0) = X"D" ELSE
			X"5" WHEN data_in(3 downto 0) = X"5" OR data_in(3 downto 0) = X"E" ELSE
			X"6" WHEN data_in(3 downto 0) = X"6" OR data_in(3 downto 0) = X"F" ELSE
			X"7" WHEN data_in(3 downto 0) = X"7" ELSE
			X"8" WHEN data_in(3 downto 0) = X"8" ELSE
			X"9" WHEN data_in(3 downto 0) = X"9" ELSE
			X"0";
				
	
	data_2 <= X"1" WHEN data_in(7 downto 4) = X"1" OR data_in(7 downto 4) = X"A" ELSE
			X"2" WHEN data_in(7 downto 4) = X"2" OR data_in(7 downto 4) = X"B" ELSE
			X"3" WHEN data_in(7 downto 4) = X"3" OR data_in(7 downto 4) = X"C" ELSE
			X"4" WHEN data_in(7 downto 4) = X"4" OR data_in(7 downto 4) = X"D" ELSE
			X"5" WHEN data_in(7 downto 4) = X"5" OR data_in(7 downto 4) = X"E" ELSE
			X"6" WHEN data_in(7 downto 4) = X"6" OR data_in(7 downto 4) = X"F" ELSE
			X"7" WHEN data_in(7 downto 4) = X"7" ELSE
			X"8" WHEN data_in(7 downto 4) = X"8" ELSE
			X"9" WHEN data_in(7 downto 4) = X"9" ELSE
			X"0";
			
	data_3 <= X"1" WHEN data_in(11 downto 8) = X"1" OR data_in(11 downto 8) = X"A" ELSE
			X"2" WHEN data_in(11 downto 8) = X"2" OR data_in(11 downto 8) = X"B" ELSE
			X"3" WHEN data_in(11 downto 8) = X"3" OR data_in(11 downto 8) = X"C" ELSE
			X"4" WHEN data_in(11 downto 8) = X"4" OR data_in(11 downto 8) = X"D" ELSE
			X"5" WHEN data_in(11 downto 8) = X"5" OR data_in(11 downto 8) = X"E" ELSE
			X"6" WHEN data_in(11 downto 8) = X"6" OR data_in(11 downto 8) = X"F" ELSE
			X"7" WHEN data_in(11 downto 8) = X"7" ELSE
			X"8" WHEN data_in(11 downto 8) = X"8" ELSE
			X"9" WHEN data_in(11 downto 8) = X"9" ELSE
			X"0";
			
	data_4 <= X"1" WHEN data_in(15 downto 12) = X"1" OR data_in(15 downto 12) = X"A" ELSE
			X"2" WHEN data_in(15 downto 12) = X"2" OR data_in(15 downto 12) = X"B" ELSE
			X"3" WHEN data_in(15 downto 12) = X"3" OR data_in(15 downto 12) = X"C" ELSE
			X"4" WHEN data_in(15 downto 12) = X"4" OR data_in(15 downto 12) = X"D" ELSE
			X"5" WHEN data_in(15 downto 12) = X"5" OR data_in(15 downto 12) = X"E" ELSE
			X"6" WHEN data_in(15 downto 12) = X"6" OR data_in(15 downto 12) = X"F" ELSE
			X"7" WHEN data_in(15 downto 12) = X"7" ELSE
			X"8" WHEN data_in(15 downto 12) = X"8" ELSE
			X"9" WHEN data_in(15 downto 12) = X"9" ELSE
			X"0";
	
	PROCESS
	BEGIN
	 WAIT UNTIL clock_50Mhz'EVENT AND clock_50Mhz = '1';
		IF reset = '0' THEN
		 clock_count_400Hz <= X"00000";
		 clock_400Hz <= '0';
		ELSE
				IF clock_count_400Hz < X"0F424" THEN 
				 clock_count_400Hz <= clock_count_400Hz + 1;
				ELSE
		    	 clock_count_400Hz <= X"00000";
				 clock_400Hz <= NOT clock_400Hz;
				END IF;
		END IF;
	END PROCESS;
	
	PROCESS (clock_400Hz, reset)
	BEGIN
		IF reset = '0' THEN
			state <= RESET1;
			data_bus_value <= X"38";
			next_command <= RESET2;
			LCD_EN <= '1';
			LCD_RS <= '0';
			LCD_RW <= '0';

		ELSIF clock_400Hz'EVENT AND clock_400Hz = '1' THEN
					
-- SEND DATA AND ADDRESS TO LCD			
			CASE state IS
-- Set Function to 8-bit transfer and 2 line display with 5x8 Font size
-- see Hitachi HD44780 family data sheet for LCD command and timing details
				WHEN RESET1 =>
						LCD_EN <= '1';
						LCD_RS <= '0';
						LCD_RW <= '0';
						data_bus_value <= X"38";
						state <= TOGGLE_E;
						next_command <= RESET2;
				WHEN RESET2 =>
						LCD_EN <= '1';
						LCD_RS <= '0';
						LCD_RW <= '0';
						data_bus_value <= X"38";
						state <= TOGGLE_E;
						next_command <= RESET3;
				WHEN RESET3 =>
						LCD_EN <= '1';
						LCD_RS <= '0';
						LCD_RW <= '0';
						data_bus_value <= X"38";
						state <= TOGGLE_E;
						next_command <= FUNC_SET;
-- EXTRA STATES ABOVE ARE NEEDED FOR RELIABLE PUSHBUTTON RESET OF LCD
				WHEN FUNC_SET =>
						LCD_EN <= '1';
						LCD_RS <= '0';
						LCD_RW <= '0';
						data_bus_value <= X"38";
						state <= TOGGLE_E;
						next_command <= DISPLAY_OFF;
-- Turn off Display and Turn off cursor
				WHEN DISPLAY_OFF =>
						LCD_EN <= '1';
						LCD_RS <= '0';
						LCD_RW <= '0';
						data_bus_value <= X"08";
						state <= TOGGLE_E;
						next_command <= DISPLAY_CLEAR;
-- Turn on Display and Turn off cursor
				WHEN DISPLAY_CLEAR =>
						LCD_EN <= '1';
						LCD_RS <= '0';
						LCD_RW <= '0';
						data_bus_value <= X"01";
						state <= TOGGLE_E;
						next_command <= DISPLAY_ON;
-- Turn on Display and Turn off cursor
				WHEN DISPLAY_ON =>
						LCD_EN <= '1';
						LCD_RS <= '0';
						LCD_RW <= '0';
						data_bus_value <= X"0C";
						state <= TOGGLE_E;
						next_command <= MODE_SET;
-- Set write mode to auto increment address and move cursor to the right
				WHEN MODE_SET =>
						LCD_EN <= '1';
						LCD_RS <= '0';
						LCD_RW <= '0';
						data_bus_value <= X"06";
						state <= TOGGLE_E;
						next_command <= WRITE_ADD1;
-- Write ASCII hex character in first LCD character location
				WHEN WRITE_ADD1 =>
						LCD_EN <= '1';
						LCD_RS <= '1';
						LCD_RW <= '0';
						data_bus_value <= X"41";
						state <= TOGGLE_E;
						next_command <= WRITE_ADD2;
-- Write ASCII hex character in second LCD character location
				WHEN WRITE_ADD2 =>
						LCD_EN <= '1';
						LCD_RS <= '1';
						LCD_RW <= '0';
						data_bus_value <= X"64";
						state <= TOGGLE_E;
						next_command <= WRITE_ADD3;
-- Write ASCII hex character in third LCD character location
				WHEN WRITE_ADD3 =>
						LCD_EN <= '1';
						LCD_RS <= '1';
						LCD_RW <= '0';
						data_bus_value <= X"64";
						state <= TOGGLE_E;
						next_command <= WRITE_ADD4;
-- Write ASCII hex character in fourth LCD character location
				WHEN WRITE_ADD4 =>
						LCD_EN <= '1';
						LCD_RS <= '1';
						LCD_RW <= '0';
						data_bus_value <= X"72";
						state <= TOGGLE_E;
						next_command <= WRITE_ADD5;
-- Write ASCII hex character in fifth LCD character location
				WHEN WRITE_ADD5 =>
						LCD_EN <= '1';
						LCD_RS <= '1';
						LCD_RW <= '0';
						data_bus_value <= X"65";
						state <= TOGGLE_E;
						next_command <= WRITE_ADD6;
-- Write ASCII hex character in sixth LCD character location
				WHEN WRITE_ADD6 =>
						LCD_EN <= '1';
						LCD_RS <= '1';
						LCD_RW <= '0';
						data_bus_value <= X"73" ;
						state <= TOGGLE_E;
						next_command <= WRITE_ADD7;
-- Write ASCII hex character in seventh LCD character location
				WHEN WRITE_ADD7 =>
						LCD_EN <= '1';
						LCD_RS <= '1';
						LCD_RW <= '0';
						data_bus_value <= X"73";
						state <= TOGGLE_E;
						next_command <= WRITE_ADD8;
-- Write ASCII hex character in eighth LCD character location
				WHEN WRITE_ADD8 =>
						LCD_EN <= '1';
						LCD_RS <= '1';
						LCD_RW <= '0';
						data_bus_value <= X"20";
						state <= TOGGLE_E;
						next_command <= WRITE_ADD9;
				WHEN WRITE_ADD9 =>
						LCD_EN <= '1';
						LCD_RS <= '1';
						LCD_RW <= '0';
						data_bus_value <= X"3D";
						state <= TOGGLE_E;
						next_command <= WRITE_ADD10;
				WHEN WRITE_ADD10 =>
						LCD_EN <= '1';
						LCD_RS <= '1';
						LCD_RW <= '0';
						data_bus_value <= X"20";
						state <= TOGGLE_E;
						next_command <= WRITE_ADD11;
				WHEN WRITE_ADD11 =>
						LCD_EN <= '1';
						LCD_RS <= '1';
						LCD_RW <= '0';
						IF(address_in(17 downto 16) < X"A") THEN
						data_bus_value <= X"3" & add_5;
						ELSE
						data_bus_value <= X"4" & add_5;
						END IF;
						state <= TOGGLE_E;
						next_command <= WRITE_ADD12;
				WHEN WRITE_ADD12 =>
						LCD_EN <= '1';
						LCD_RS <= '1';
						LCD_RW <= '0';
						IF(address_in(15 downto 12) < X"A") THEN
						data_bus_value <= X"3" & add_4;
						ELSE
						data_bus_value <= X"4" & add_4;
						END IF;
						state <= TOGGLE_E;
						next_command <= WRITE_ADD13;
				WHEN WRITE_ADD13 =>
						LCD_EN <= '1';
						LCD_RS <= '1';
						LCD_RW <= '0';
						IF(address_in(11 downto 8) < X"A") THEN
						data_bus_value <= X"3" & add_3;
						ELSE
						data_bus_value <= X"4" & add_3;
						END IF;
						state <= TOGGLE_E;
						next_command <= WRITE_ADD14;
				WHEN WRITE_ADD14 =>
						LCD_EN <= '1';
						LCD_RS <= '1';
						LCD_RW <= '0';
						IF(address_in(7 downto 4) < X"A") THEN
						data_bus_value <= X"3" & add_2;
						ELSE
						data_bus_value <= X"4" & add_2;
						END IF;
						state <= TOGGLE_E;
						next_command <= WRITE_ADD15;
				WHEN WRITE_ADD15 =>
						LCD_EN <= '1';
						LCD_RS <= '1';
						LCD_RW <= '0';
						IF(address_in(3 downto 0) < X"A") THEN
						data_bus_value <= X"3" & add_1;
						ELSE
						data_bus_value <= X"4" & add_1;
						END IF;
						state <= TOGGLE_E;
						next_command <= WRITE_ADD16;		
				WHEN WRITE_ADD16 =>
						LCD_EN <= '1';
						LCD_RS <= '1';
						LCD_RW <= '0';
						data_bus_value <= X"20";
						state <= TOGGLE_E;
						next_command <= MODE_SET2;				
						
-- Set write mode to auto increment address and move cursor to the right on second line
				WHEN MODE_SET2 =>
						LCD_EN <= '1';
						LCD_RS <= '0';
						LCD_RW <= '0';
						data_bus_value <= X"C0";
						state <= TOGGLE_E;
						next_command <= WRITE_DATA1;
-- Write ASCII hex character in first LCD character location
				WHEN WRITE_DATA1 =>
						LCD_EN <= '1';
						LCD_RS <= '1';
						LCD_RW <= '0';
						data_bus_value <= X"44";
						state <= TOGGLE_E;
						next_command <= WRITE_DATA2;
-- Write ASCII hex character in second LCD character location
				WHEN WRITE_DATA2 =>
						LCD_EN <= '1';
						LCD_RS <= '1';
						LCD_RW <= '0';
						data_bus_value <= X"61";
						state <= TOGGLE_E;
						next_command <= WRITE_DATA3;
-- Write ASCII hex character in third LCD character location
				WHEN WRITE_DATA3 =>
						LCD_EN <= '1';
						LCD_RS <= '1';
						LCD_RW <= '0';
						data_bus_value <= X"74";
						state <= TOGGLE_E;
						next_command <= WRITE_DATA4;
-- Write ASCII hex character in fourth LCD character location
				WHEN WRITE_DATA4 =>
						LCD_EN <= '1';
						LCD_RS <= '1';
						LCD_RW <= '0';
						data_bus_value <= X"61";
						state <= TOGGLE_E;
						next_command <= WRITE_DATA5;
-- Write ASCII hex character in fifth LCD character location
				WHEN WRITE_DATA5 =>
						LCD_EN <= '1';
						LCD_RS <= '1';
						LCD_RW <= '0';
						data_bus_value <= X"20";
						state <= TOGGLE_E;
						next_command <= WRITE_DATA6;
-- Write ASCII hex character in sixth LCD character location
				WHEN WRITE_DATA6 =>
						LCD_EN <= '1';
						LCD_RS <= '1';
						LCD_RW <= '0';
						data_bus_value <= X"20" ;
						state <= TOGGLE_E;
						next_command <= WRITE_DATA7;
-- Write ASCII hex character in seventh LCD character location
				WHEN WRITE_DATA7 =>
						LCD_EN <= '1';
						LCD_RS <= '1';
						LCD_RW <= '0';
						data_bus_value <= X"20";
						state <= TOGGLE_E;
						next_command <= WRITE_DATA8;
-- Write ASCII hex character in eighth LCD character location
				WHEN WRITE_DATA8 =>
						LCD_EN <= '1';
						LCD_RS <= '1';
						LCD_RW <= '0';
						data_bus_value <= X"20";
						state <= TOGGLE_E;
						next_command <= WRITE_DATA9;
				WHEN WRITE_DATA9 =>
						LCD_EN <= '1';
						LCD_RS <= '1';
						LCD_RW <= '0';
						data_bus_value <= X"3D";
						state <= TOGGLE_E;
						next_command <= WRITE_DATA10;
				WHEN WRITE_DATA10 =>
						LCD_EN <= '1';
						LCD_RS <= '1';
						LCD_RW <= '0';
						data_bus_value <= X"20";
						state <= TOGGLE_E;
						next_command <= WRITE_DATA11;
				WHEN WRITE_DATA11 =>
						LCD_EN <= '1';
						LCD_RS <= '1';
						LCD_RW <= '0';
						data_bus_value <= X"20";
						state <= TOGGLE_E;
						next_command <= WRITE_DATA12;
				WHEN WRITE_DATA12 =>
						LCD_EN <= '1';
						LCD_RS <= '1';
						LCD_RW <= '0';
						IF(data_in(15 downto 12) < X"A") THEN
						data_bus_value <= X"3" & data_4;
						ELSE
						data_bus_value <= X"4" & data_4;
						END IF;
						state <= TOGGLE_E;
						next_command <= WRITE_DATA13;
				WHEN WRITE_DATA13 =>
						LCD_EN <= '1';
						LCD_RS <= '1';
						LCD_RW <= '0';
						IF(data_in(11 downto 8) < X"A") THEN
						data_bus_value <= X"3" & data_3;
						ELSE
						data_bus_value <= X"4" & data_3;
						END IF;
						state <= TOGGLE_E;
						next_command <= WRITE_DATA14;
				WHEN WRITE_DATA14 =>
						LCD_EN <= '1';
						LCD_RS <= '1';
						LCD_RW <= '0';
						IF(data_in(7 downto 4) < X"A") THEN
						data_bus_value <= X"3" & data_2;
						ELSE
						data_bus_value <= X"4" & data_2;
						END IF;
						state <= TOGGLE_E;
						next_command <= WRITE_DATA15;
				WHEN WRITE_DATA15 =>
						LCD_EN <= '1';
						LCD_RS <= '1';
						LCD_RW <= '0';
						IF(data_in(3 downto 0) < X"A") THEN
						data_bus_value <= X"3" & data_1;
						ELSE
						data_bus_value <= X"4" & data_1;
						END IF;
						state <= TOGGLE_E;
						next_command <= WRITE_DATA16;		
				WHEN WRITE_DATA16 =>
						LCD_EN <= '1';
						LCD_RS <= '1';
						LCD_RW <= '0';
						data_bus_value <= X"20";
						state <= TOGGLE_E;
						next_command <= RETURN_HOME;
-- Return write address to first character postion
				WHEN RETURN_HOME =>
						LCD_EN <= '1';
						LCD_RS <= '0';
						LCD_RW <= '0';
						data_bus_value <= X"80";
						state <= TOGGLE_E;
						next_command <= WRITE_ADD1;

-- The next two states occur at the end of each command to the LCD
-- Toggle E line - falling edge loads inst/data to LCD controller
				WHEN TOGGLE_E =>
						LCD_EN <= '0';
						state <= HOLD;
-- Hold LCD inst/data valid after falling edge of E line				
				WHEN HOLD =>
						state <= next_command;
			END CASE;
		END IF;
	END PROCESS;

END operation;
