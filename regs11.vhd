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


------------------------
-------rejestr 8bit-----
------------------------
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


------------------------
-------rejestr 2bit-----
------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity reg2 is
	port
	(
	
		--INPUTS
		--@@ TODO doda� stygna�y z US
		clk : in std_logic;
		rst : in std_logic;
		ena : in std_logic;
		d : in std_logic_vector ( 1 downto 0 );
		

		--OUTPUTS
		q : out std_logic_vector ( 1 downto 0 )
		
	);
end reg2;

-- Library Clause(s) (optional)
-- Use Clause(s) (optional)

architecture data_flow of reg2 is

	signal q_reg, q_next : std_logic_vector ( 1 downto 0 );

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

----------------------------
-------rejestr 8192bit------
----------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity reg8K is
	port
	(
	
		--INPUTS
		--@@ TODO doda� stygna�y z US
		clk : in std_logic;
		rst : in std_logic;
		ena : in std_logic;
		d : in std_logic_vector ( 8191 downto 0 );
		

		--OUTPUTS
		q : out std_logic_vector ( 8191 downto 0 )
		
	);
end reg8K;

-- Library Clause(s) (optional)
-- Use Clause(s) (optional)

architecture data_flow of reg8K is

	signal q_reg, q_next : std_logic_vector ( 1 downto 0 );

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

-------------------------
-------rejestr 16bit-----
-------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity reg16 is
	port
	(
	
		--INPUTS
		--@@ TODO doda� stygna�y z US
		clk : in std_logic;
		rst : in std_logic;
		ena : in std_logic;
		d : in std_logic_vector ( 15 downto 0 );
		

		--OUTPUTS
		q : out std_logic_vector ( 15 downto 0 )
		
	);
end reg16;

-- Library Clause(s) (optional)
-- Use Clause(s) (optional)

architecture data_flow of reg16 is

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

