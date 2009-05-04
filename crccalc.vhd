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

architecture data_flow of crccalc is

	-- Declarations (optional)

begin

	-- Process Statement (optional)

	-- Concurrent Procedure Call (optional)

	-- Concurrent Signal Assignment (optional)

	-- Conditional Signal Assignment (optional)

	-- Selected Signal Assignment (optional)

	-- Component Instantiation Statement (optional)

	-- Generate Statement (optional)

end data_flow;
