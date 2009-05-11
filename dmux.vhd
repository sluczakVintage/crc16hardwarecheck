--------------------------------
-- File		:	mux.vhd
-- Version	:	0.1
-- Date		:	03.05.2009
-- Desc		:	Zestaw multiplekserów i demultiplekserów
-- Author	:	Sebastian £uczak
-- Author	:	Maciej Nowak 
-- Based on	:	Wyk³ady dr Mariusz Rawski
--------------------------------

---------------------------
--
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

----------------------
--Demultiplekser
-- 4 x 8
----------------------

entity dmux is
	port(
		input			: in std_logic_vector ( 7 downto 0 );
		sel				: in std_logic_vector( 1 downto 0 );
		o1, o2, o3, o4	: out std_logic_vector ( 7 downto 0 )
	);
end dmux;

architecture behavior of dmux is
begin
	
	process (input, sel)
	begin
		o1 <= (others => '0');
		o2 <= (others => '0');
		o3 <= (others => '0');
		o4 <= (others => '0');

		case sel is
			when "00" => 
				o1 <= input;
			when "01" => 
				o2 <= input;
			when "10" => 
				o3 <= input;
			when others => 
				o4 <= input;
		end case;
		
	end process;
end behavior;

--------------------------
----Demultiplekser
---- 4 x 2
--------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity dmux4x2 is
	port
	(
		input : in std_logic_vector ( 1 downto 0 );
		sel	: in std_logic_vector ( 1 downto 0 );
		o1, o2, o3, o4	: out std_logic_vector ( 1 downto 0 )
	);
end dmux4x2;


architecture behavior of dmux4x2 is
begin
	
	process (input, sel)
	begin
		o1 <= (others => '0');
		o2 <= (others => '0');
		o3 <= (others => '0');
		o4 <= (others => '0');

		case sel is
			when "00" => 
				o1 <= input;
			when "01" => 
				o2 <= input;
			when "10" => 
				o3 <= input;
			when others => 
				o4 <= input;
		end case;
		
	end process;
end behavior;


--------------------------
----Demultiplekser
---- 2 x 8
--------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity dmux2x8 is
	port(
		input			: in std_logic_vector ( 7 downto 0 );
		sel				: in std_logic_vector( 0 downto 0 );
		o1, o2	: out std_logic_vector ( 7 downto 0 )
	);
end dmux2x8;


architecture behavior of dmux2x8 is
begin
	
	process (input, sel)
	begin
		o1 <= (others => '0');
		o2 <= (others => '0');

		case sel is
			when "0" => 
				o1 <= input;
			when "1" => 
				o2 <= input;
		end case;
		
	end process;
end behavior;

--------------------------
----Multiplekser
---- 4 x 16
--------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity mux4x16 is
	port(
		i1, i2, i3, i4	: in std_logic_vector ( 15 downto 0 );
		sel				: in std_logic_vector ( 1 downto 0 );
		output 			: out std_logic_vector ( 15 downto 0 )
	);
end mux4x16;

architecture data_flow of mux4x16 is
begin
	with sel select
		output <= i1 when "00",
				  i2 when "01",
				  i3 when "10",
				  i4 when others;
end data_flow;

--------------------------
----Multiplekser
---- 4 x 8
--------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity mux4x8 is
	port(
		i1, i2, i3, i4	: in std_logic_vector ( 7 downto 0 );
		sel				: in std_logic_vector ( 1 downto 0 );
		output 			: out std_logic_vector ( 7 downto 0 )
	);
end mux4x8;

architecture data_flow of mux4x8 is
begin
	with sel select
		output <= i1 when "00",
				  i2 when "01",
				  i3 when "10",
				  i4 when others;
end data_flow;

--------------------------
----Multiplekser
---- 4 x 2
--------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity mux4x2 is
	port(
		i1, i2, i3, i4	: in std_logic_vector ( 1 downto 0 );
		sel				: in std_logic_vector ( 1 downto 0 );
		output 			: out std_logic_vector ( 1 downto 0 )
	);
end mux4x2;

architecture data_flow of mux4x2 is
begin
	with sel select
		output <= i1 when "00",
				  i2 when "01",
				  i3 when "10",
				  i4 when others;
end data_flow;
