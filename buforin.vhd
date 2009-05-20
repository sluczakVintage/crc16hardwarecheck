--------------------------------
-- File		:	buforin.vhd
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
use ieee.std_logic_unsigned.all;
use work.PCK_CRC16_D8.all;

entity buforin is
	port
	(
			-- INPUTS
			--@@ TODO: nale�y doda� sygna�y z uk�adu steruj�cego
		clk : in  std_logic ;
		rst : in std_logic;
		data  : in std_logic_vector ( 7 downto 0 );
		sel : in std_logic_vector ( 1 downto 0 );  --<<----- >????????
		flow_in : in std_logic;  
		
			--OUTPUTS
		usb_endread : out std_logic;
	--	status2_index : out std_logic_vector ( 1 downto 0 );
		data_index : out std_logic_vector ( 7 downto 0 );
		CRC_index : out std_logic_vector ( 15 downto 0 ); ----<----- powinno by� 16 bit
		mod_passed0 : out std_logic;
		mod_passed1 : out std_logic;
		mod_passed2 : out std_logic;
		mod_passed3 : out std_logic	
		
	--	flow_out : out std_logic  --<<----- >????????
	);
end buforin;


architecture data_flow of buforin is


-----------------------------------
-- UBER mega flow control bit2bit
-----------------------------------


component flowcontrol

	port
	(
		-- INPUTS
			--@@ TODO: nale�y doda� sygna�y z uk�adu steruj�cego
			
		clk 			: in std_logic;
		rst				: in std_logic;
		flow_in			: in std_logic;

		-----------
		-- 00 - idle
		-- 01 - enable
		-- 11 - end transmission
		-----------
		
		
		--OUTPUTS
--		flow_out			: out std_logic;
			-- enable g��wnego demultipleksera
		enable_MAINdmux : out std_logic_vector ( 1 downto 0 );
			-- enable demultimpleksera nag��wka na liczb� modu��w i d�ugo�� modu��w
		enable_HEADdmux :  out std_logic_vector ( 0 downto 0 );
			-- enable demultipleksera d�ugo�ci modu��w
		enable_RDMdmux  : out std_logic_vector ( 1 downto 0 );
			-- enable demultipleksera danych na modu�y
		enable_PACKdmux : out std_logic_vector ( 1 downto 0 );
			-- enable demultipleksera modu��w na dane i crc
		enable_MODdmux0 : out std_logic_vector ( 0 downto 0 );	
		enable_MODdmux1 : out std_logic_vector ( 0 downto 0 );	
		enable_MODdmux2 : out std_logic_vector ( 0 downto 0 );	
		enable_MODdmux3 : out std_logic_vector ( 0 downto 0 );	
		ena_RLM, ena_RDM0, ena_RDM1, ena_RDM2, ena_RDM3, ena_CRC0, ena_CRC1, ena_CRC2, ena_CRC3, ena_DATA0, ena_DATA1, ena_DATA2, ena_DATA3 : out std_logic;
		
		mod_passed0 : out std_logic;
		mod_passed1 : out std_logic;
		mod_passed2 : out std_logic;
		mod_passed3 : out std_logic	
	);
end component;


component mux4x16		--- mux crc
	port(
		i1, i2, i3, i4	: in std_logic_vector ( 15 downto 0 );
		sel				: in std_logic_vector ( 1 downto 0 );
		output 			: out std_logic_vector ( 15 downto 0 )
	);
end component;

component mux4x8
	port(
		i1, i2, i3, i4	: in std_logic_vector ( 7 downto 0 );
		sel				: in std_logic_vector ( 1 downto 0 );
		output 			: out std_logic_vector ( 7 downto 0 )
	);
end component;


component dmux4x8	
	port
	(
		input			: in std_logic_vector ( 7 downto 0 );
		sel				: in std_logic_vector( 1 downto 0 );
		o1, o2, o3, o4	: out std_logic_vector ( 7 downto 0 )
		
	);
end component;	

component dmux2x8	-- dmux dziel�cy na crc i data
	port
	(
		input			: in std_logic_vector ( 7 downto 0 );
		sel				: in std_logic_vector( 0 downto 0 );
		o1, o2	 		: out std_logic_vector ( 7 downto 0 )
		
	);
end component;	

------------------------------------------------
---------------ram-------------------------------
-------------------------------------------------

component ram 
		PORT
		(
		address		: IN STD_LOGIC_VECTOR (9 DOWNTO 0);
		clock		: IN STD_LOGIC ;
		data		: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
		wren		: IN STD_LOGIC ;		-- write/read enable
		q			: OUT STD_LOGIC_VECTOR (7 DOWNTO 0)		-- output
		);

end component;


----------------------------------------------------
----------------------------------- REJESTRY -------
----------------------------------------------------


component reg8
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
end component;

component reg16		----rejestr CRC
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
end component;


signal enaRLM, enaRDM0, enaRDM1, enaRDM2, enaRDM3, enaCRC0, enaCRC1, enaCRC2, enaCRC3, enaDATA0, enaDATA1, enaDATA2, enaDATA3 : std_logic;
signal enable_MAINdmux,	enable_RDMdmux, enable_PACKdmux : std_logic_vector ( 1 downto 0 );
signal enable_HEADdmux, enable_MODdmux0, enable_MODdmux1, enable_MODdmux2, enable_MODdmux3 : std_logic_vector ( 0 downto 0 );
-------------------------------------
-- sygna�y DATA
-------------------------------------
signal sig01_main, sig00_main, sig10_main, sig11_main_empty : std_logic_vector (7 downto 0 );

-------------------------------------
--sygna�y HEAD 
-------------------------------------
signal sig0_head, sig1_head : std_logic_vector ( 7 downto 0 );

-------------------------------------
--sygna�y PACK
-------------------------------------
signal sig00_pack, sig01_pack, sig10_pack, sig11_pack : std_logic_vector ( 7 downto 0 );

-------------------------------------
--sygna�y RLM
-------------------------------------
signal sig2_rlm : std_logic_vector ( 7 downto 0 );  --<------------ OBS�U�Y�
-------------------------------------
-- sygna�y RDM
-------------------------------------
signal sig1_a_rdm, sig1_b_rdm, sig1_c_rdm, sig1_d_rdm : std_logic_vector ( 7 downto 0 );
signal sig2_a_rdm, sig2_b_rdm, sig2_c_rdm, sig2_d_rdm : std_logic_vector ( 7 downto 0 );

-------------------------------------
-- sygna�y DATA
-------------------------------------
signal sig1_a_data, sig1_b_data, sig1_c_data, sig1_d_data : std_logic_vector ( 7 downto 0 );		--sygna�y wej�cia do ramu
signal sig2_a_data, sig2_b_data, sig2_c_data, sig2_d_data : std_logic_vector ( 7 downto 0 );		-- sygna�y wyj�cia z ramu
signal wren_a, wren_b, wren_c, wren_d : std_logic;
signal address_a, address_b, address_c, address_d : std_logic_vector ( 9 downto 0);


-------------------------------------
-- sygna�y CRC
-------------------------------------
signal sig1_a_crc, sig1_b_crc, sig1_c_crc, sig1_d_crc : std_logic_vector ( 7 downto 0 );
signal sig2_a_crc, sig2_b_crc, sig2_c_crc, sig2_d_crc : std_logic_vector ( 7 downto 0 );


signal junk : std_logic_vector ( 7 downto 0 ); --<-----------sygna� wype�niany przez nieobs�u�one jeszcze dane

----------------------------------------------
------------------------------------------------- BEGIN
----------------------------------------------
begin

-------------------------------------
--------UBER FLOW CONTROL
-------------------------------------
	uberflow : flowcontrol
		port map ( 
		clk => clk,		
		rst	=> rst,		
		flow_in	=> flow_in,		
	
	--	flow_out => flow_out,	
		enable_MAINdmux => enable_MAINdmux, 
		enable_HEADdmux => enable_HEADdmux, 	
		enable_RDMdmux => enable_RDMdmux,
		enable_PACKdmux => enable_PACKdmux,	
		enable_MODdmux0 => enable_MODdmux0,
		enable_MODdmux1 => enable_MODdmux1,
		enable_MODdmux2 => enable_MODdmux2,
		enable_MODdmux3 => enable_MODdmux3, 
			ena_RLM     => enaRLM,
			ena_RDM0    => enaRDM0, 
			ena_RDM1	=> enaRDM1, 
			ena_RDM2	=> enaRDM2, 
			ena_RDM3	=> enaRDM3, 
			ena_CRC0	=> enaCRC0, 
			ena_CRC1	=> enaCRC1, 
			ena_CRC2	=> enaCRC2, 
			ena_CRC3	=> enaCRC3, 
			ena_DATA0   => enaDATA0, 
			ena_DATA1	=> enaDATA1, 
			ena_DATA2	=> enaDATA2, 
			ena_DATA3	=> enaDATA3,
			mod_passed0 => mod_passed0,
			mod_passed1 => mod_passed1,
			mod_passed2 => mod_passed2,
			mod_passed3 => mod_passed3
		);
-------------------------------------
--------MAIN DMUX--------------------
-------------------------------------
	dmux_main : dmux4x8
		port map ( 
			input => data,
			sel => enable_MAINdmux,
			o1 => sig00_main,
			o2 => sig01_main, --<------ DO OBSLUZENIA
			o3 => sig10_main,
			o4 => sig11_main_empty -- EMPTY
		);
-------------------------------------
--------HEADER DMUX------------------
-------------------------------------
dmux_head : dmux2x8
		port map ( 
			input => sig01_main,
			sel => enable_HEADdmux,
			o1 => sig0_head,
			o2 => sig1_head			
		);
-------------------------------------
--------DMUX rozdzielaj�cy pakiet----
-------------------------------------
dmux_pack : dmux4x8
		port map ( 
			input => sig10_main,
			sel => enable_PACKdmux,
			o1 => sig00_pack,
			o2 => sig01_pack,
			o3 => sig10_pack,
			o4 => sig11_pack
			
		);

---------------------------------------
------ dmuxy data/crc -----------------
---------------------------------------

	dmux0_data_crc : dmux2x8
		port map (
			input => sig00_pack,			----- tu powinien by� sygna� id�cy z dmuxa 
			sel => enable_MODdmux0,
			o1 => sig1_a_crc,
			o2 => sig1_a_data			
		);
		
	dmux1_data_crc : dmux2x8
		port map (
			input => sig01_pack,			----- tu powinien by� sygna� id�cy z dmuxa 
			sel => enable_MODdmux1,
			o1 => sig1_b_crc,
			o2 => sig1_b_data
		);
		
	dmux2_data_crc : dmux2x8
		port map (
			input => sig10_pack,			----- tu powinien by� sygna� id�cy z dmuxa 
			sel => enable_MODdmux2,
			o1 => sig1_c_crc,
			o2 => sig1_c_data			
		);
		
	dmux3_data_crc : dmux2x8
		port map (
			input => sig11_pack,			----- tu powinien by� sygna� id�cy z dmuxa 
			sel => enable_MODdmux3,
			o1 => sig1_d_crc,
			o2 => sig1_d_data			
		);		
--------------------------------------
--------- mux data -------------------
--------------------------------------
	mux_data : mux4x8 
		port map (
			output => data_index,			----- tu powinien by� sygna� id�cy do crccalc
			sel => sel,
			i1 => sig2_a_data,
			i2 => sig2_b_data,
			i3 => sig2_c_data,
			i4 => sig2_d_data
		);
		
--------------------------------------
-------- mux crc ---------------------
--------------------------------------

	mux_crc : mux4x8
		port map (
			output => junk,			----- tu powinien by� sygna� id�cy do komparatora
			sel => sel,
			i1 => sig2_a_crc,
			i2 => sig2_b_crc,
			i3 => sig2_c_crc,
			i4 => sig2_d_crc
		);

--------------------------------------
-------- mux i dmux rdm --------------
--------------------------------------
	dmux1_rdm : dmux4x8
		port map (
			input => sig1_head,
			sel => enable_RDMdmux,
			o1 => sig1_a_rdm,
			o2 => sig1_b_rdm,
			o3 => sig1_c_rdm,
			o4 => sig1_d_rdm
		);

	mux2_rdm : mux4x8 
		port map (
			output => junk,
			sel => sel,					--------- obsluzyc
			i1 => sig2_a_rdm,
			i2 => sig2_b_rdm,
			i3 => sig2_c_rdm,
			i4 => sig2_d_rdm
		);

-------------------------------------
--------ram data ---------------
-------------------------------------
	ram_data0 : ram
		PORT MAP (
		wren => enaDATA0,		-- write / read enable	-- TODO trzeba z US da� sygna� zapisuj�cy
		clock => clk,	
		address => address_a, --- TODO da� generator adres�w alvo inne cudo
		data => sig1_a_data,
		q => sig2_a_data		-- wyj�cie
	);
	
	ram_data1 : ram
		PORT MAP (
		wren => enaDATA1,		-- write / read enable	-- TODO trzeba z US da� sygna� zapisuj�cy
		clock => clk,	
		address => address_b, --- TODO da� generator adres�w alvo inne cudo
		data => sig1_b_data,
		q => sig2_b_data		-- wyj�cie
	);
		
	ram_data2 : ram
		PORT MAP (
		wren => enaDATA2,		-- write / read enable	-- TODO trzeba z US da� sygna� zapisuj�cy
		clock => clk,	
		address => address_c, --- TODO da� generator adres�w alvo inne cudo
		data => sig1_c_data,
		q => sig2_c_data		-- wyj�cie
	);
		
	ram_data3 : ram
		PORT MAP (
		wren => enaDATA3,		-- write / read enable	-- TODO trzeba z US da� sygna� zapisuj�cy
		clock => clk,	
		address => address_d, --- TODO da� generator adres�w alvo inne cudo
		data => sig1_d_data,
		q => sig2_d_data		-- wyj�cie
	);
				

-------------------------------------
--------rejesrty crc docelowo 16bit -
-------------------------------------

	crc_0 : reg16
		port map ( 
			clk => clk,
			rst => rst,
			ena => enaCRC0,
			d => sig1_a_crc,
			q => sig2_a_crc
		);

	crc_1 : reg16
		port map (
			clk => clk,
			rst => rst,
			ena => enaCRC1,
			d => sig1_b_crc,
			q => sig2_b_crc
		);

	crc_2 : reg16
		port map (
			clk => clk,
			rst => rst,
			ena => enaCRC2,
			d => sig1_c_crc,
			q => sig2_c_crc
		);

	crc_3 : reg16
		port map (
			clk => clk,
			rst => rst,
			ena => enaCRC3,
			d => sig1_d_crc,
			q => sig2_d_crc
		);


-------------------------------------
-- rejestry RDM ka�dy 16bit 
-------------------------------------
	rdm_0 : reg16
				port map ( 
			clk => clk,
			rst => rst,
			ena => enaRDM0,
			d => sig1_a_rdm,
			q => sig2_a_rdm
		);

	rdm_1 : reg16
				port map (
			clk => clk,
			rst => rst,
			ena => enaRDM1,
			d => sig1_b_rdm,
			q => sig2_b_rdm
		);

	rdm_2 : reg16
				port map (
			clk => clk,
			rst => rst,
			ena => enaRDM2,
			d => sig1_c_rdm,
			q => sig2_c_rdm
		);

	rdm_3 : reg16
				port map (
			clk => clk,
			rst => rst,
			ena => enaRDM3,
			d => sig1_d_rdm,
			q => sig2_d_rdm
		);
-------------------------------------
-- rejestr RLM 8bit 
-------------------------------------
	rlm_0 : reg8
				port map ( 
			clk => clk,
			rst => rst,
			ena => enaRLM,
			d => sig1_head,
			q => sig2_rlm
		);
end data_flow;