--------------------------------
-- File		:	buforin.vhd
-- Version	:	0.1
-- Date		:	03.05.2009
-- Desc		:	Buforin entity
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

entity buforin is

	port
	(
			-- INPUTS
			--@@ TODO: nale¿y dodaæ sygna³y z uk³adu steruj¹cego
		clk : in  std_logic ;
		rst : in std_logic;
		data  : in std_logic_vector ( 7 downto 0 );
		
			--OUTPUTS
		usb_endread : out std_logic;
		index : out std_logic_vector ( 1 downto 0 );
		status2_index : out std_logic_vector ( 1 downto 0 );
		data_index : out std_logic_vector ( 7 downto 0 );
		CRC_index : out std_logic_vector ( 15 downto 0 )
	);
end buforin;

-- Library Clause(s) (optional)
-- Use Clause(s) (optional)

architecture data_flow of buforin is


--component dmux4x8	
--	port
--	(
--		input			: in std_logic_vector ( 7 downto 0 );
--		sel				: in std_logic_vector( 1 downto 0 );
--		o1, o2, o3, o4	: out std_logic_vector ( 7 downto 0 )
--		
--	);
--end component;	

begin

--	dmux1 : dmux4x8
--		port map (
--		
--		);
--	dmux2 : dmux2x8 
--		port map (
--			
--		);

end data_flow;