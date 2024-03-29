--------------------------------
-- File		:	comparator.vhd
-- Version	:	0.9
-- Date		:	04.05.2009
-- Desc		:	CRC comparator
-- Author	:	Sebastian �uczak
-- Author	:	Maciej Nowak 
-- Based on	:	wyk�ady dr in�. Mariusz Rawski / Programowalne uk�ady przetwarzania sygna��w i informacji prof. Tadeusz �uba
--------------------------------

---------------------------

--
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity comparator is
	port
	(
	
--INPUTS
		crc_index : in std_logic_vector ( 15 downto 0 );
		crc2_index : in std_logic_vector ( 15 downto 0 );
--OUTPUTS
		equal_crc : out std_logic
	);
end comparator;

architecture behavior of comparator is

	-- deklaracje sygna��w do por�wnywania - szybsza wersja na xor'ach
	signal crc15, crc14, crc13, crc12, crc11, crc10, crc9, crc8, crc7, crc6, crc5, crc4, crc3, crc2, crc1, crc0 : std_logic;
	-- deklaracja sygna�u opisuj�cego r�wno�� warto�ci crc
	signal crc_equal : std_logic;

begin				
				-- por�wnywanie crc, je�li bity takie same, to "1" na sygna�
				crc15 <= not (crc_index(15) xor crc2_index(15));
				crc14 <= not (crc_index(14) xor crc2_index(14));
				crc13 <= not (crc_index(13) xor crc2_index(13));
				crc12 <= not (crc_index(12) xor crc2_index(12));
				crc11 <= not (crc_index(11) xor crc2_index(11));
				crc10 <= not (crc_index(10) xor crc2_index(10));
				crc9 <= not (crc_index(9) xor crc2_index(9));
				crc8 <= not (crc_index(8) xor crc2_index(8));
				crc7 <= not (crc_index(7) xor crc2_index(7));
				crc6 <= not (crc_index(6) xor crc2_index(6));
				crc5 <= not (crc_index(5) xor crc2_index(5));
				crc4 <= not (crc_index(4) xor crc2_index(4));
				crc3 <= not (crc_index(3) xor crc2_index(3));
				crc2 <= not (crc_index(2) xor crc2_index(2));
				crc1 <= not (crc_index(1) xor crc2_index(1));
				crc0 <= not (crc_index(0) xor crc2_index(0));
	
	-- je�li wszystkie bity by�y takie same - jeden na sygna� equal_crc			
	equal_crc <= crc15 and crc14 and crc13 and crc12 and crc11 and crc10 and crc9 and crc8 and crc7 and crc6 and crc5 and crc4 and crc3 and crc2 and crc1 and crc0;
	
	--kodowanie status_index na podstawie status
	-----------
	-- opis kodowania equal_crc:
	-- 0 - blad crc
	-- 1 - ok
	------------	
	


end behavior;
