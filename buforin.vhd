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
		enable : in std_logic;
		sel : in std_logic_vector ( 1 downto 0 );
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

-- dmuxy i muxy odpowiedzialne za rdm

component dmux4x32	
	port
	(
		input			: in std_logic_vector ( 31 downto 0 );
		sel				: in std_logic_vector( 1 downto 0 );
		o1, o2, o3, o4	: out std_logic_vector ( 31 downto 0 )
		
	);
end component;	

component mux4x32
	port(
		i1, i2, i3, i4	: in std_logic_vector ( 31 downto 0 );
		sel				: in std_logic_vector ( 1 downto 0 );
		output 			: out std_logic_vector ( 31 downto 0 )
	);
end component;

component reg32
	port
	(
		--INPUTS
		--@@ TODO dodaæ stygna³y z US
		clk : in std_logic;
		rst : in std_logic;
		ena : in std_logic;
		d : in std_logic_vector ( 31 downto 0 );
		

		--OUTPUTS
		q : out std_logic_vector ( 31 downto 0 )
		
		
	);
end component;
-- sygna³y do rdm
signal sig1_a_rdm, sig1_b_rdm, sig1_c_rdm, sig1_d_rdm, sig2_a_rdm, sig2_b_rdm, sig2_c_rdm, sig2_d_rdm : std_logic_vector ( 31 downto 0 );


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


-- rejestry RDM ka¿dy 32bit 

rdm_0 : reg32
		port map ( 
clk => clk,
rst => rst,
ena => enable,
d => sig1_a_rdm,
q => sig2_a_rdm
);

	rdm_1 : reg32
		port map (
clk => clk,
rst => rst,
ena => enable,
d => sig1_b_rdm,
q => sig2_b_rdm
);

	rdm_2 : reg32
		port map (
clk => clk,
rst => rst,
ena => enable,
d => sig1_c_rdm,
q => sig2_c_rdm
);

	rdm_3 : reg32
		port map (
clk => clk,
rst => rst,
ena => enable,
d => sig1_d_rdm,
q => sig2_d_rdm
);


	dmux1_rdm : dmux4x32
		port map (
			input => data,
			sel => sel,
			o1 => sig1_a_rdm,
			o2 => sig1_b_rdm,
			o3 => sig1_c_rdm,
			o4 => sig1_d_rdm
		);
		

	mux2_rdm : mux4x32 
		port map (
				output => data_index,
			sel => sel,
			i1 => sig2_a_rdm,
			i2 => sig2_b_rdm,
			i3 => sig2_c_rdm,
			i4 => sig2_d_rdm
		);







end data_flow;