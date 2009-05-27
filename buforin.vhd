--------------------------------
-- File		:	buforin.vhd
-- Version	:	0.1
-- Date		:	03.05.2009
-- Desc		:	Buforin entity
-- Author	:	Sebastian £uczak
-- Author	:	Maciej Nowak 
-- Based on	:	/
--------------------------------

-----------------------------
--- Znaczniki 
---SOP 00000010
---EOH 00000110
---EOM 00000011
---EOP 00000100
-----------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity buforin is
	port
	(
-- INPUTS
			--@@ TODO: nale¿y dodaæ sygna³y z uk³adu steruj¹cego
		clk : in  std_logic ;
		rst : in std_logic;
		data  : in std_logic_vector ( 7 downto 0 );
		trans_mod : in  std_logic_vector ( 1 downto 0 );
		flow_in : in std_logic; 
		
		-- sygnaly z crccalc oczekuj¹ce na odczyt z RAM DATA 
	--	ren_DATA0, ren_DATA1, ren_DATA2, ren_DATA3 : in std_logic;
		-- mux wybierajacy sygnal do odczytu
		muxDATA : in std_logic_vector ( 1 downto 0 ); 
		--zewnetrzny clr licznika adresow
		addr_calc_cnt_clr : in std_logic;
		
		
--OUTPUTS
		data_index 	: out std_logic_vector ( 7 downto 0 );
		CRC_index 	: out std_logic_vector ( 15 downto 0 );
		
		mod_count	: out std_logic_vector ( 7 downto 0 );
		
		mod_pass0	: out std_logic;
		mod_pass1	: out std_logic;
		mod_pass2	: out std_logic;
		mod_pass3	: out std_logic;
		mod_passed0 : out std_logic_vector ( 1 downto 0 );
		mod_passed1 : out std_logic_vector ( 1 downto 0 );
		mod_passed2 : out std_logic_vector ( 1 downto 0 );
		mod_passed3 : out std_logic_vector ( 1 downto 0 )
		
	
	);
end buforin;


architecture data_flow of buforin is

signal ml_reg : std_logic_vector ( 15 downto 0 );
signal enaRLM, enaRDM0, enaRDM1, enaRDM2, enaRDM3, enaCRC0, enaCRC1, enaCRC2, enaCRC3 : std_logic;
signal wrenDATA0, wrenDATA1, wrenDATA2, wrenDATA3 : std_logic;
signal enable_RDMdmux, enable_RDMmux, enable_PACKdmux : std_logic_vector ( 1 downto 0 );
signal enable_MAINdmux, enable_HEADdmux, enable_MODdmux0, enable_MODdmux1, enable_MODdmux2, enable_MODdmux3 : std_logic_vector ( 0 downto 0 );
-------------------------------------
-- sygna³y DATA
-------------------------------------
signal sig0_main, sig1_main : std_logic_vector (7 downto 0 );

-------------------------------------
--sygna³y HEAD 
-------------------------------------
signal sig0_head, sig1_head : std_logic_vector ( 7 downto 0 );

-------------------------------------
--sygna³y PACK
-------------------------------------
signal sig00_pack, sig01_pack, sig10_pack, sig11_pack : std_logic_vector ( 7 downto 0 );

-------------------------------------
--sygna³y RLM
-------------------------------------
signal sig2_rlm : std_logic_vector ( 7 downto 0 );  --<------------ OBS£U¯YÆ
-------------------------------------
-- sygna³y RDM
-------------------------------------
signal sig1_a_rdm, sig1_b_rdm, sig1_c_rdm, sig1_d_rdm : std_logic_vector ( 7 downto 0 );
signal sig2_a_rdm, sig2_b_rdm, sig2_c_rdm, sig2_d_rdm : std_logic_vector ( 15 downto 0 );

-------------------------------------
-- sygna³y DATA
-------------------------------------
signal sig1_a_data, sig1_b_data, sig1_c_data, sig1_d_data : std_logic_vector ( 7 downto 0 );		--sygna³y wejœcia do ramu
signal sig2_a_data, sig2_b_data, sig2_c_data, sig2_d_data : std_logic_vector ( 7 downto 0 );		-- sygna³y wyjœcia z ramu


-------------------------------------
-------------------------------------
-- sygna³y CRC
-------------------------------------
signal sig1_a_crc, sig1_b_crc, sig1_c_crc, sig1_d_crc : std_logic_vector ( 7 downto 0 );
signal sig2_a_crc, sig2_b_crc, sig2_c_crc, sig2_d_crc : std_logic_vector ( 15 downto 0 );


-------------------------------------
-- do obslugi licznika adresow
-------------------------------------
signal addr_cnt_reg, addr_cnt_next : std_logic_vector ( 9 downto 0);
signal addr_cnt_clr : std_logic; 
signal addr_flow_cnt_clr : std_logic;


-----------------------------------
-- UBER mega flow control bit2bit
-----------------------------------

component flowcontrol

	port
	(
-- INPUTS
		clk 			: in std_logic;
		rst				: in std_logic;
		flow_in			: in std_logic;
		data			: in std_logic_vector ( 7 downto 0 );		
		ml_reg			: in std_logic_vector ( 15 downto 0 );
		
--OUTPUTS

	-- enable g³ównego demultipleksera
		enable_MAINdmux : out std_logic_vector ( 0 downto 0 );
	-- enable demultimpleksera nag³ówka na liczbê modu³ów i d³ugoœæ modu³ów
		enable_HEADdmux :  out std_logic_vector ( 0 downto 0 );
	-- enable demultipleksera d³ugoœci modu³ów
		enable_RDMdmux  : out std_logic_vector ( 1 downto 0 );
	-- enable multilpeksera d³ugoœci modu³ów
		enable_RDMmux 	: out std_logic_vector ( 1 downto 0 );
	-- enable demultipleksera danych na modu³y
		enable_PACKdmux : out std_logic_vector ( 1 downto 0 );
	-- enable demultipleksera modu³ów na dane i crc
		enable_MODdmux0 : out std_logic_vector ( 0 downto 0 );	
		enable_MODdmux1 : out std_logic_vector ( 0 downto 0 );	
		enable_MODdmux2 : out std_logic_vector ( 0 downto 0 );	
		enable_MODdmux3 : out std_logic_vector ( 0 downto 0 );	
		ena_RLM, ena_RDM0, ena_RDM1, ena_RDM2, ena_RDM3, ena_CRC0, ena_CRC1, ena_CRC2, ena_CRC3, wen_DATA0, wen_DATA1, wen_DATA2, wen_DATA3 : out std_logic;
		addr_flow_cnt_clr : out std_logic;

		
		mod_pass0	: out std_logic;
		mod_pass1	: out std_logic;
		mod_pass2	: out std_logic;
		mod_pass3	: out std_logic;
		mod_passed0 : out std_logic_vector ( 1 downto 0 );
		mod_passed1 : out std_logic_vector ( 1 downto 0 );
		mod_passed2 : out std_logic_vector ( 1 downto 0 );
		mod_passed3 : out std_logic_vector ( 1 downto 0 )
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

component dmux2x8	-- dmux dziel¹cy na crc i data
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
		clk : in std_logic;
		rst : in std_logic;
		ena : in std_logic;
		d : in std_logic_vector ( 7 downto 0 );
		--OUTPUTS
		q : out std_logic_vector ( 7 downto 0 )
		
		
	);
end component;

component reg8it_to16bit	----rejestr CRC
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
end component;


----------------------------------------------
------------------------------------------------- BEGIN
----------------------------------------------
begin
-- Opis dzialania licznika adresow

	process (clk, rst)
	begin
		if rst = '1'  then
			addr_cnt_reg <= ( others => '0' );
		elsif rising_edge(clk) then
			addr_cnt_reg <=addr_cnt_next;
		end if;
	end process;

	process (addr_cnt_reg, addr_flow_cnt_clr, addr_calc_cnt_clr)
	begin
		if (addr_flow_cnt_clr = '1') OR (addr_calc_cnt_clr = '1') then

			addr_cnt_next <= ( others => '0' );
		else
			 addr_cnt_next <= addr_cnt_reg + "1";
		end if;
	end process;			  
	


-------------------------------------
--------UBER FLOW CONTROL
-------------------------------------
	uberflow : flowcontrol
		port map ( 
		clk => clk,		
		rst	=> rst,		
		flow_in	=> flow_in,	
		data => data, 	
		ml_reg => ml_reg,
	
		enable_MAINdmux => enable_MAINdmux, 
		enable_HEADdmux => enable_HEADdmux, 	
		enable_RDMdmux => enable_RDMdmux,
		enable_RDMmux => enable_RDMmux,
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
		wen_DATA0   => wrenDATA0, 
		wen_DATA1	=> wrenDATA1, 
		wen_DATA2	=> wrenDATA2, 
		wen_DATA3	=> wrenDATA3,
		addr_flow_cnt_clr => addr_flow_cnt_clr,

		mod_pass0 => mod_pass0,
		mod_pass1 => mod_pass1,
		mod_pass2 => mod_pass2,
		mod_pass3 => mod_pass3,
		mod_passed0 => mod_passed0,
		mod_passed1 => mod_passed1,
		mod_passed2 => mod_passed2,
		mod_passed3 => mod_passed3
		);
-------------------------------------
--------MAIN DMUX--------------------
-------------------------------------
	dmux_main : dmux2x8
		port map ( 
			input => data,
			sel => enable_MAINdmux,
			o1 => sig0_main, 
			o2 => sig1_main
		);
-------------------------------------
--------HEADER DMUX------------------
-------------------------------------
dmux_head : dmux2x8
		port map ( 
			input => sig0_main,
			sel => enable_HEADdmux,
			o1 => sig0_head,
			o2 => sig1_head			
		);
-------------------------------------
--------DMUX rozdzielaj¹cy pakiet----
-------------------------------------
dmux_pack : dmux4x8
		port map ( 
			input => sig1_main,
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
			input => sig00_pack,			----- tu powinien byæ sygna³ id¹cy z dmuxa 
			sel => enable_MODdmux0,
			o1 => sig1_a_crc,
			o2 => sig1_a_data			
		);
		
	dmux1_data_crc : dmux2x8
		port map (
			input => sig01_pack,			----- tu powinien byæ sygna³ id¹cy z dmuxa 
			sel => enable_MODdmux1,
			o1 => sig1_b_crc,
			o2 => sig1_b_data
		);
		
	dmux2_data_crc : dmux2x8
		port map (
			input => sig10_pack,			----- tu powinien byæ sygna³ id¹cy z dmuxa 
			sel => enable_MODdmux2,
			o1 => sig1_c_crc,
			o2 => sig1_c_data			
		);
		
	dmux3_data_crc : dmux2x8
		port map (
			input => sig11_pack,			----- tu powinien byæ sygna³ id¹cy z dmuxa 
			sel => enable_MODdmux3,
			o1 => sig1_d_crc,
			o2 => sig1_d_data			
		);		

--------------------------------------
-------- mux crc ---------------------
--------------------------------------

-----------------------------
--------rejestry crc 16bit --
-----------------------------

	crc_0 : reg8it_to16bit
		port map ( 
			clk => clk,
			rst => rst,
			ena => enaCRC0,
			d => sig1_a_crc,
			q => sig2_a_crc
		);

	crc_1 : reg8it_to16bit
		port map (
			clk => clk,
			rst => rst,
			ena => enaCRC1,
			d => sig1_b_crc,
			q => sig2_b_crc
		);

	crc_2 : reg8it_to16bit
		port map (
			clk => clk,
			rst => rst,
			ena => enaCRC2,
			d => sig1_c_crc,
			q => sig2_c_crc
		);

	crc_3 : reg8it_to16bit
		port map (
			clk => clk,
			rst => rst,
			ena => enaCRC3,
			d => sig1_d_crc,
			q => sig2_d_crc
		);

-----------------------------
--------mux crc 16bit -------
-----------------------------

	mux_crc : mux4x16
		port map (
			output => CRC_index,			----- tu powinien byæ sygna³ id¹cy do komparatora
			sel => trans_mod,
			i1 => sig2_a_crc,
			i2 => sig2_b_crc,
			i3 => sig2_c_crc,
			i4 => sig2_d_crc
		);
--------------------------------------
--------- mux data -------------------
--------------------------------------
	mux_data : mux4x8 
		port map (
			output => data_index,			----- tu powinien byæ sygna³ id¹cy do crccalc
			sel => muxDATA,
			i1 => sig2_a_data,
			i2 => sig2_b_data,
			i3 => sig2_c_data,
			i4 => sig2_d_data
		);
		

-------------------------------------
--------ram data --------------------
-------------------------------------

				  
	ram_data0 : ram
		PORT MAP (
		wren => wrenDATA0,	
		clock => clk,	
		address =>  addr_cnt_reg, 
		data => sig1_a_data,
		q => sig2_a_data		-- wyjœcie
	);
	
	ram_data1 : ram
		PORT MAP (
		wren => wrenDATA1,	
		clock => clk,	
		address => addr_cnt_reg, 
		data => sig1_b_data,
		q => sig2_b_data		-- wyjœcie
	);
		
	ram_data2 : ram
		PORT MAP (
		wren => wrenDATA2,	
		clock => clk,	
		address => addr_cnt_reg, 
		data => sig1_c_data,
		q => sig2_c_data		-- wyjœcie
	);
		
	ram_data3 : ram
		PORT MAP (
		wren => wrenDATA3,	
		clock => clk,	
		address => addr_cnt_reg, 
		data => sig1_d_data,
		q => sig2_d_data		-- wyjœcie
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

	mux2_rdm : mux4x16 
		port map (
			output => ml_reg,
			sel => enable_RDMmux,					
			i1 => sig2_a_rdm,
			i2 => sig2_b_rdm,
			i3 => sig2_c_rdm,
			i4 => sig2_d_rdm
		);


-------------------------------------
-- rejestry RDM ka¿dy 16bit 
-------------------------------------
	rdm_0 : reg8it_to16bit
				port map ( 
			clk => clk,
			rst => rst,
			ena => enaRDM0,
			d => sig1_a_rdm,
			q => sig2_a_rdm
		);

	rdm_1 : reg8it_to16bit
				port map (
			clk => clk,
			rst => rst,
			ena => enaRDM1,
			d => sig1_b_rdm,
			q => sig2_b_rdm
		);

	rdm_2 : reg8it_to16bit
				port map (
			clk => clk,
			rst => rst,
			ena => enaRDM2,
			d => sig1_c_rdm,
			q => sig2_c_rdm
		);

	rdm_3 : reg8it_to16bit
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
			d => sig0_head,
			q => mod_count
		);


end data_flow;