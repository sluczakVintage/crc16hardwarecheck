--------------------------------
-- File		:	crccalc.vhd
-- Version	:	0.1
-- Date		:	03.05.2009
-- Desc		:	First iteration of crc transmission control system
-- Author	:	Sebastian £uczak
-- Author	:	Maciej Nowak 
-- Based on	:	/
--------------------------------
---------------------------
--
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.PCK_CRC16_D8.all;	


entity crccalc is
	
	port
	(
	
		--INPUTS
		--@@ TODO dodaæ sygna³y z US
		clk : in std_logic;
		rst : in std_logic;
		calc_start : in std_logic;
		data_index : in std_logic_vector (7 downto 0 );
		transmit_end : in std_logic;-- DO ZMIANY
		--OUTPUTS
		calc_done	: out std_logic;
		crc2_index : out std_logic_vector (15 downto 0 )
		
	);
	
end crccalc;
-- Library Clause(s) (optional)
-- Use Clause(s) (optional)

architecture behavior of crccalc is


signal done_calc : std_logic;
signal nextCRC, newCRC : std_logic_vector(15 downto 0) := "0000000000000000";

type CALC_FSM_STATE_TYPE is (
	calc_fsb_idle,
	calc_fsb_calculate,
	calc_fsb_processed
	);
signal calc_fsb_reg, calc_fsb_next	: CALC_FSM_STATE_TYPE;

begin
-- Opis dzialania automatu kalkulatora
	process (clk, rst)
	begin
		if rst = '1' then
			calc_fsb_reg <= calc_fsb_idle;	
		elsif rising_edge(clk) then
			calc_fsb_reg <= calc_fsb_next;
		end if;
	end process;
--	-- Funkcja przejsc-wyjsc
	
process (calc_fsb_reg, calc_start, transmit_end)
begin
done_calc <= '0';
	case calc_fsb_reg is
		when calc_fsb_idle =>  
			if calc_start = '0' then
				calc_fsb_next <= calc_fsb_idle;
			else
				calc_fsb_next <= calc_fsb_calculate;
			end if;
		when calc_fsb_calculate =>
			if transmit_end = '0' then
				calc_fsb_next <= calc_fsb_calculate;
			else
				calc_fsb_next <= calc_fsb_processed;
			end if;
		when calc_fsb_processed =>
			done_calc <= '1';
			calc_fsb_next <= calc_fsb_idle;
	end case;
end process;

process (clk, rst)
	begin
		if rst = '1' then
			newCRC <= (others => '0');
		elsif rising_edge(clk) then
			newCRC <= nextCRC;
		end if;
	end process;	
	
process (calc_fsb_reg, data_index, newCRC)
begin
	nextCRC <= (others => '0');
	if calc_fsb_reg = calc_fsb_calculate then
		  nextCRC <= nextCRC16_D8 (data_index, newCRC);
	else nextCRC <= (others => '0');
	end if;
		
end process;

crc2_index <= newCRC;

calc_done <= done_calc;
crc2_index <= newCRC;



end behavior;
