--------------------------------
-- File		:	.vhd
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
use ieee.std_logic_unsigned.all;

-- Rejestr 8bit
entity reg8 is
	port
	(
	
		--INPUTS
		--@@ TODO dodaæ stygna³y z US
		clk : in std_logic;
		rst : in std_logic;
		ena : in std_logic;
		d : in std_logic_vector ( 7 downto 0 );
		

		--OUTPUTS
		q : out std_logic_vector ( 7 downto 0 )
		
	);
end reg8;


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

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--Rejestr 2bit
entity reg2 is
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
end reg2;


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

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


--rejestr 16bit
entity reg16 is 
	port
	(
	
		--INPUTS
		--@@ TODO dodaæ stygna³y z US
		clk : in std_logic;
		rst : in std_logic;
		ena : in std_logic;
		d : in std_logic_vector ( 7 downto 0 );
		

		--OUTPUTS
		q : out std_logic_vector ( 15 downto 0 )
		
	);
end reg16;


architecture data_flow of reg16 is

	signal q_reg, q_next : std_logic_vector ( 7 downto 0 );
	signal q_16bit_reg : std_logic_vector ( 15 downto 0 );

begin
	
	process(clk, rst)
	begin
		if(rst='1') then
			q_reg <= (others => '0');
			q_16bit_reg <= (others => '0');
		elsif rising_edge(clk) then
			q_reg <= q_next;
			q_16bit_reg <= (q_reg & q_next);
		end if;
	end process;
	
	q_next <= d when ena = '1' else
			q_reg;
	
	q <= q_16bit_reg;
end data_flow;



library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Rejestr 8192bit
entity reg8K is
	port
	(
	
		--INPUTS
		--@@ TODO dodaæ stygna³y z US
		clk : in std_logic;
		rst : in std_logic;
		ena : in std_logic;
		d : in std_logic_vector ( 7 downto 0 );
		

		--OUTPUTS
		q : out std_logic_vector ( 7 downto 0 )
		
	);
end reg8K;


architecture data_flow of reg8K is

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