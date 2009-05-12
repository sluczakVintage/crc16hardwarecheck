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
		enable : in std_logic;
		sel : in std_logic_vector ( 1 downto 0 );
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

--	signal stat1, stat2, stat3, stat4, statout : std_logic_vector ( 1 downto 0 );
--	signal sel : std_logic_vector ( 1 downto 0 );
--	signal status : std_logic_vector ( 1 downto 0 );


--- rejestry w buforout. przechowuj¹ce statusy crc, 

component dmux4x2	
	port
	(
		input			: in std_logic_vector ( 1 downto 0 );
		sel				: in std_logic_vector( 1 downto 0 );
		o1, o2, o3, o4	: out std_logic_vector ( 1 downto 0 )
		
	);
end component;	

component mux4x2
	port(
		i1, i2, i3, i4	: in std_logic_vector ( 1 downto 0 );
		sel				: in std_logic_vector ( 1 downto 0 );
		output 			: out std_logic_vector ( 1 downto 0 )
	);
end component;

component reg2
	port
	(
		--INPUTS
		--@@ TODO dodaæ stygna³y z US
		clk : in std_logic;
		rst : in std_logic;
		ena : in std_logic;
		d : in std_logic_vector ( 1 downto 0 );
		

		--OUTPUTS
		q : out std_logic_vector ( 1 downto 0 )
		
		
	);
end component;

signal sig1_a, sig1_b, sig1_c, sig1_d, sig2_a, sig2_b, sig2_c, sig2_d : std_logic_vector ( 1 downto 0 );
begin
	status_0 : reg2
		port map ( 
clk => clk,
rst => rst,
ena => enable,
d => sig1_a,
q => sig2_a
);

	status_1 : reg2
		port map (
clk => clk,
rst => rst,
ena => enable,
d => sig1_b,
q => sig2_b
);

	status_2 : reg2
		port map (
clk => clk,
rst => rst,
ena => enable,
d => sig1_c,
q => sig2_c
);

	status_3 : reg2
		port map (
clk => clk,
rst => rst,
ena => enable,
d => sig1_d,
q => sig2_d
);


	dmux1 : dmux4x2
		port map (
			input => status_index,
			sel => sel,
			o1 => sig1_a,
			o2 => sig1_b,
			o3 => sig1_c,
			o4 => sig1_d
		);
		

	mux2 : mux4x2 
		port map (
				output => raport,
			sel => sel,
			i1 => sig2_a,
			i2 => sig2_b,
			i3 => sig2_c,
			i4 => sig2_d
		);



end data_flow;
