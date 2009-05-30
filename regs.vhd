--------------------------------
-- File		:	regs.vhd
-- Version	:	0.9
-- Date		:	03.05.2009
-- Desc		:	Register library
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
use ieee.std_logic_unsigned.all;

--Rejestr 2bit
entity reg2 is
	port
	(
	
		--INPUTS
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
use ieee.std_logic_unsigned.all;


--rejestr reg2bit_to_8bit right to left 
entity reg2bit_to_8bit is 
	port
	(
	
		--INPUTS
		clk : in std_logic;
		rst : in std_logic;
		ena : in std_logic;
		clr : in std_logic;
		d : in std_logic_vector ( 1 downto 0 );
		

		--OUTPUTS
		q : out std_logic_vector ( 7 downto 0 )
		
	);
end reg2bit_to_8bit;


architecture data_flow of reg2bit_to_8bit is

	signal q_2reg, q_2next : std_logic_vector ( 1 downto 0 );
	signal q_4reg, q_4next : std_logic_vector ( 1 downto 0 );
	signal q_6reg, q_6next : std_logic_vector ( 1 downto 0 );
	signal q_8reg, q_8next : std_logic_vector ( 1 downto 0 );

begin
	
	process(clk, rst, clr)
	begin
		if(rst = '1') OR (clr = '1') then
			q_2reg <= (others => '0');
			q_4reg <= (others => '0');
			q_6reg <= (others => '0');
			q_8reg <= (others => '0');
		
		
		elsif rising_edge(clk) then
			q_2reg <= q_2next;
			q_4reg <= q_4next; 
			q_6reg <= q_6next; 
			q_8reg <= q_8next; 
		
		end if;
	end process;
	
	q_2next <= d when ena = '1' else
			q_2reg;
	q_4next <= q_2reg when ena = '1' else
			q_4reg;
	q_6next <= q_4reg when ena = '1' else
			q_6reg;
	q_8next <= q_6reg when ena = '1' else
			q_8reg;
	
	q <= (q_8reg & q_6reg & q_4reg & q_2reg); 
end data_flow;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

--rejestr reg8it_to16bit
entity reg8it_to16bit is 
	port
	(
	
		--INPUTS
		clk : in std_logic;
		rst : in std_logic;
		ena : in std_logic;
		d : in std_logic_vector ( 7 downto 0 );
		

		--OUTPUTS
		q : out std_logic_vector ( 15 downto 0 )
		
	);
end reg8it_to16bit;


architecture data_flow of reg8it_to16bit is

	signal q_8reg, q_8next, q_16reg, q_16next : std_logic_vector ( 7 downto 0 );

begin
	
	process(clk, rst)
	begin
		if(rst='1') then
			q_8reg <= (others => '0');
			q_16reg <= (others => '0');
		elsif rising_edge(clk) then
			q_8reg <= q_8next;
			q_16reg <= q_16next;
		end if;
		
	end process;
	
	q_8next <= d when ena = '1' else
			q_8reg;
	q_16next <= q_8reg when ena = '1' else
			q_16reg;
	
	q <= (q_16reg & q_8reg);
end data_flow;



library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

-- Rejestr 16bit
entity reg16 is
	port
	(
	
		--INPUTS
		clk : in std_logic;
		rst : in std_logic;
		ena : in std_logic;
		d : in std_logic_vector ( 15 downto 0 );
		

		--OUTPUTS
		q : out std_logic_vector ( 15 downto 0 )
		
	);
end reg16;


architecture data_flow of reg16 is

	signal q_reg, q_next : std_logic_vector ( 15 downto 0 );

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