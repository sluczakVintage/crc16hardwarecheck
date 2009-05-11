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

entity dmux4x8 is
	port(
		input			: in std_logic_vector ( 7 downto 0 );
		sel				: in std_logic_vector( 1 downto 0 );
		o1, o2, o3, o4	: out std_logic_vector ( 7 downto 0 )
	);
end dmux4x8;

architecture behavior of dmux4x8 is
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


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

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

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity buforbak is

	port
	(
			-- INPUTS
			--@@ TODO: nale¿y dodaæ sygna³y z uk³adu steruj¹cego
		clk : in  std_logic ;
		rst : in std_logic;
		data  : in std_logic_vector ( 7 downto 0 );
		enable : in std_logic;
		sel : in std_logic_vector ( 1 downto 0 );
			--OUTPUTS
		usb_endread : out std_logic;
		index : out std_logic_vector ( 1 downto 0 );
		status2_index : out std_logic_vector ( 1 downto 0 );
		data_index : out std_logic_vector ( 7 downto 0 );
		CRC_index : out std_logic_vector ( 15 downto 0 )
	);
end buforbak;

-- Library Clause(s) (optional)
-- Use Clause(s) (optional)

architecture data_flow of buforbak is


component dmux4x8	
	port
	(
		input			: in std_logic_vector ( 7 downto 0 );
		sel				: in std_logic_vector( 1 downto 0 );
		o1, o2, o3, o4	: out std_logic_vector ( 7 downto 0 )
		
	);
end component;	

component mux4x8
	port(
		i1, i2, i3, i4	: in std_logic_vector ( 7 downto 0 );
		sel				: in std_logic_vector ( 1 downto 0 );
		output 			: out std_logic_vector ( 7 downto 0 )
	);
end component;

component reg8
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
end component;

signal sig1_a, sig1_b, sig1_c, sig1_d, sig2_a, sig2_b, sig2_c, sig2_d : std_logic_vector ( 7 downto 0 );
begin
	reg_0 : reg8
		port map ( 
clk => clk,
rst => rst,
ena => enable,
d => sig1_a,
q => sig2_a
);

	reg_1 : reg8
		port map (
clk => clk,
rst => rst,
ena => enable,
d => sig1_b,
q => sig2_b
);

	reg_2 : reg8
		port map (
clk => clk,
rst => rst,
ena => enable,
d => sig1_c,
q => sig2_c
);

	reg_3 : reg8
		port map (
clk => clk,
rst => rst,
ena => enable,
d => sig1_d,
q => sig2_d
);


	dmux1 : dmux4x8
		port map (
			input => data,
			sel => sel,
			o1 => sig1_a,
			o2 => sig1_b,
			o3 => sig1_c,
			o4 => sig1_d
		);
		

	mux2 : mux4x8 
		port map (
				output => data_index,
			sel => sel,
			i1 => sig2_a,
			i2 => sig2_b,
			i3 => sig2_c,
			i4 => sig2_d
		);

end data_flow;