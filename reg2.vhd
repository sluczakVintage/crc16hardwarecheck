--------------------------------
-- File		:	.vhd
-- Version	:	0.1
-- Date		:	03.05.2009
-- Desc		:	Buforin entity
-- Author	:	Sebastian �uczak
-- Author	:	Maciej Nowak 
-- Based on	:	/
--------------------------------

---------------------------
--
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity reg8 is
	port
	(
	
		--INPUTS
		--@@ TODO doda� stygna�y z US
		clk : in std_logic;
		rst : in std_logic;
		ena : in std_logic;
		d : in std_logic_vector ( 7 downto 0 );
		

		--OUTPUTS
		q : out std_logic_vector ( 7 downto 0 )
		
	);
end reg8;

-- Library Clause(s) (optional)
-- Use Clause(s) (optional)

architecture data_flow of reg8 is

	signal q_reg, q_next : std_logic_vector ( 7 downto 0 );

begin
	process(clk, rst)
	begin
		if(rst='1') then
			q_reg <= (others => '0');
		elsif rising_edge(clk) then
			q_reg <= q_next;
		end if;
	end process;
	
	q_next <= d when ena = '1' else
			q_reg;
			
	q <= q_reg;
	
end data_flow;