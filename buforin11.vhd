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

entity buforin11 is

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
end buforin11;

-- Library Clause(s) (optional)
-- Use Clause(s) (optional)

architecture data_flow of buforin11 is


-------------------------------------------
-- dmuxy i muxy odpowiedzialne za rdm -----
-------------------------------------------

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


----------------------------------------------------
-- dmuxy i muxy odpowiedzialne za crc i data -------
----------------------------------------------------

component dmux2x8	-- dmux dziel¹cy na crc i data
	port
	(
		input			: in std_logic_vector ( 7 downto 0 );
		sel				: in std_logic_vector( 0 downto 0 );
		o1, o2	 		: out std_logic_vector ( 7 downto 0 )
		
	);
end component;	


component mux4x16		--- mux crc
	port(
		i1, i2, i3, i4	: in std_logic_vector ( 15 downto 0 );
		sel				: in std_logic_vector ( 1 downto 0 );
		output 			: out std_logic_vector ( 15 downto 0 )
	);
end component;

component mux4x8		--- mux data
	port(
		i1, i2, i3, i4	: in std_logic_vector ( 7 downto 0 );
		sel				: in std_logic_vector ( 1 downto 0 );
		output 			: out std_logic_vector ( 7 downto 0 )
	);
end component;

component reg16		----rejestr CRC
	port
	(
		--INPUTS
		--@@ TODO dodaæ stygna³y z US
		clk : in std_logic;
		rst : in std_logic;
		ena : in std_logic;
		d : in std_logic_vector ( 15 downto 0 );
		
		--OUTPUTS
		q : out std_logic_vector ( 15 downto 0 )
		
		
	);
end component;

component reg8K  --- rejestr DATA
	port
	(
		--INPUTS
		--@@ TODO dodaæ stygna³y z US
		clk : in std_logic;
		rst : in std_logic;
		ena : in std_logic;
		d : in std_logic_vector ( 8191 downto 0 );
		
		--OUTPUTS
		q : out std_logic_vector ( 8191 downto 0 )
		
		
	);
end component;


-- sygna³y do DATA
signal sig1_a_data, sig1_b_data, sig1_c_data, sig1_d_data, sig2_a_data, sig2_b_data, sig2_c_data, sig2_d_data : std_logic_vector ( 7 downto 0 );


-- sygna³y do CRC
signal sig1_a_crc, sig1_b_crc, sig1_c_crc, sig1_d_crc, sig2_a_crc, sig2_b_crc, sig2_c_crc, sig2_d_crc : std_logic_vector ( 15 downto 0 );


begin

-------------------------------------
--------rejesrty data ---------------
-------------------------------------
	data_0 : reg8K
		port map ( 
			clk => clk,
			rst => rst,
			ena => enable,
			d => sig1_a_data,
			q => sig2_a_data
		);

	data_1 : reg8K
		port map (
			clk => clk,
			rst => rst,
			ena => enable,
			d => sig1_b_data,
			q => sig2_b_data
		);

	data_2 : reg8K
		port map (
			clk => clk,
			rst => rst,
			ena => enable,
			d => sig1_c_data,
			q => sig2_c_data
		);

	data_3 : reg8K
		port map (
			clk => clk,
			rst => rst,
			ena => enable,
			d => sig1_d_data,
			q => sig2_d_data
		);

-------------------------------------
--------rejesrty crc ---------------
-------------------------------------

	crc_0 : reg16
		port map ( 
			clk => clk,
			rst => rst,
			ena => enable,
			d => sig1_a_crc,
			q => sig2_a_crc
		);

	crc_1 : reg16
		port map (
			clk => clk,
			rst => rst,
			ena => enable,
			d => sig1_b_crc,
			q => sig2_b_crc
		);

	crc_2 : reg16
		port map (
			clk => clk,
			rst => rst,
			ena => enable,
			d => sig1_c_crc,
			q => sig2_c_crc
		);

	crc_3 : reg16
		port map (
			clk => clk,
			rst => rst,
			ena => enable,
			d => sig1_d_crc,
			q => sig2_d_crc
		);


---------------------------------------
------ dmuxy data/crc -----------------
---------------------------------------

	dmux0_data_crc : dmux2x8
		port map (
			input => data,			----- tu powinien byæ sygna³ id¹cy z dmuxa 
			sel => sel,
			o1 => sig1_a_data,
			o2 => sig1_a_crc			
		);
		
	dmux1_data_crc : dmux2x8
		port map (
			input => data,			----- tu powinien byæ sygna³ id¹cy z dmuxa 
			sel => sel,
			o1 => sig1_b_data,
			o2 => sig1_b_crc			
		);
		
	dmux2_data_crc : dmux2x8
		port map (
			input => data,			----- tu powinien byæ sygna³ id¹cy z dmuxa 
			sel => sel,
			o1 => sig1_c_data,
			o2 => sig1_c_crc			
		);
		
	dmux3_data_crc : dmux2x8
		port map (
			input => data,			----- tu powinien byæ sygna³ id¹cy z dmuxa 
			sel => sel,
			o1 => sig1_d_data,
			o2 => sig1_d_crc			
		);		
--------------------------------------
--------- mux data ------------------
--------------------------------------
	mux_data : mux4x8 
		port map (
			output => data_index,			----- tu powinien byæ sygna³ id¹cy do crccalc
			sel => sel,
			i1 => sig2_a_data,
			i2 => sig2_b_data,
			i3 => sig2_c_data,
			i4 => sig2_d_data
		);
		
--------------------------------------
-------- mux crc --------------------
--------------------------------------

	mux_crc : mux4x16
		port map (
			output => data_index,			----- tu powinien byæ sygna³ id¹cy do komparatora
			sel => sel,
			i1 => sig2_a_crc,
			i2 => sig2_b_crc,
			i3 => sig2_c_crc,
			i4 => sig2_d_crc
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