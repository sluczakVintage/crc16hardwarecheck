--------------------------------
-- File		:	buforout.vhd
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

entity buforout is
	

	port
	(
		--INPUTS
		--@@ TODO dodaæ stygna³y z US
		clk : in std_logic;
		rst : in std_logic;
		--ena : in std_logic; ---<<<<<,
		status_index : in std_logic_vector ( 1 downto 0 );
		status2_index : in std_logic_vector (1 downto 0 );
	
		--OUTPUTS
		raport : out std_logic_vector (7 downto 0 )
		
	);
end buforout;
-- Library Clause(s) (optional)
-- Use Clause(s) (optional)

architecture data_flow of buforout is

	signal stat1, stat2, stat3, stat4, statout : std_logic_vector ( 1 downto 0 );
	signal sel : std_logic_vector ( 1 downto 0 );
	signal status : std_logic_vector ( 1 downto 0 );

--component reg2 is
--	port
--	(
--	
--		--INPUTS
--		--@@ TODO dodaæ stygna³y z US
--		clk : in std_logic;
--		rst : in std_logic;
--		ena : in std_logic;
--		d : in std_logic_vector ( 1 downto 0 );
--		
--
--		--OUTPUTS
--		q : out std_logic_vector ( 1 downto 0 )
--		
--	);
--end component;
--
--component dmux4x2 is
--	port(
--		input			: in std_logic_vector ( 1 downto 0 );
--		sel				: in std_logic_vector( 1 downto 0 );
--		o1, o2, o3, o4	: out std_logic_vector ( 1 downto 0 )
--	);
--end component;
--

begin
--	reg_1: reg2
--		port map (
--			clk => clk,
--			rst => rst,
--			ena => ena,
--			d => stat1,
--			q => statout
--		);
--
--
--	dmux_2: dmux4x2 
--		port map (
--		
--			input => status,
--			o1 => stat1,
--			o2 => stat2,
--			o3 => stat3,
--			o4 => stat4,
--			
--			sel => sel		
--		);
--	

end data_flow;
