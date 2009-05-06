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
		--@@ TODO dodaæ stygna³y z US
		clk : in std_logic;
		rst : in std_logic;
		index : in std_logic_vector ( 1 downto 0 );
		data_index : in std_logic_vector (7 downto 0 );

		--OUTPUTS
		index_k : out std_logic_vector ( 1 downto 0 );
		crc2_index : out std_logic_vector (15 downto 0 )
		
	);
	
end crccalc;
-- Library Clause(s) (optional)
-- Use Clause(s) (optional)

architecture behavior of crccalc is



signal newCRC : std_logic_vector(15 downto 0) := "0000000000000000";
begin

	index_k <= index ;

	process (clk, data_index, newCRC)
	  begin
		if clk = '1' and rising_edge(clk) then  
		  newCRC <= nextCRC16_D8 (data_index, newCRC);
		else null;
	  end if;
	end process;
crc2_index <= newCRC;

end behavior;
--
--	signal crc2 : std_logic_vector ( 15 downto 0 );
--	--signal data : std_logic;
--
--begin
--  crc2 <= CRCSTART ;
--  
--               crc2(0)  <= data  xor crc2(15);
--               crc2(1)  <= crc2(0);
--               crc2(2)  <= crc2(1) xor (data xor crc2(15));
--               crc2(3)  <= crc2(2);
--               crc2(4)  <= crc2(3);
--               crc2(5)  <= crc2(4);
--               crc2(6)  <= crc2(5);
--			   crc2(7)  <= crc2(6);
--               crc2(8)  <= crc2(7);
--               crc2(9)  <= crc2(8);
--               crc2(10)  <= crc2(9);
--               crc2(11)  <= crc2(10);
--               crc2(12)  <= crc2(11);
--               crc2(13)  <= crc2(12);
--               crc2(14)  <= crc2(13);
--               crc2(15)  <= crc2(14) xor (data xor crc2(15));
--
--    crc2_index <= crc2; 

