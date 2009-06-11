--------------------------------
-- File		:	CRCcheck.vhd
-- Version	:	1.0
-- Date		:	03.05.2009
-- Desc		:	Crc transmission control system main entity
-- Author	:	Sebastian £uczak
-- Author	:	Maciej Nowak 
-- Based on	:	/
--------------------------------

---------------------------
--
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;


entity CRCcheck is
	
	port
	(
-- Input
			-- zegar
		clk		: in  std_logic ;
			-- reset asynchroniczny
		rst		: in  std_logic;
			-- polecenie odbioru danych
		receive : in std_logic;
			-- wektor danych
		data 	: in  std_logic_vector ( 7 downto 0 );

		
-- Output
			-- sygna³ zajêtoœci (po zakoñczeniu odbioru danych)
		busy	: out std_logic;
			-- sygna³ gotowoœci do wys³ania raportu
		send	: out std_logic;
			-- wektor raportu
		raport 	: out std_logic_vector ( 7 downto 0 )
		
	);
end CRCcheck;

architecture structure of CRCcheck is

	-- list of signals
	signal status_index : std_logic_vector ( 1 downto 0 ); 
	signal equal_crc : std_logic;
	signal data_index : std_logic_vector ( 7 downto 0 );
	signal CRC_index : std_logic_vector ( 15 downto 0 );
	signal CRC2_index : std_logic_vector ( 15 downto 0 );
	
	signal addr_calc_cnt_clr : std_logic;
	signal addr_calc_cnt_ena : std_logic;
	signal ren_DATA0, ren_DATA1, ren_DATA2, ren_DATA3 : std_logic;
	signal calc_done, bufout_ready, bufout_done : std_logic;	
	
	signal mod_count : std_logic_vector ( 7 downto 0 );
	signal mod_pass0, mod_pass1, mod_pass2, mod_pass3 : std_logic;
	signal mod_passed0, mod_passed1, mod_passed2, mod_passed3 : std_logic_vector ( 1 downto 0 );
	signal flow_in, calc_start, bufout_trans, bufout_send : std_logic;
	signal proc_mod : std_logic_vector ( 1 downto 0 );
	signal sent	: std_logic;
	
	-- US
	
component us
	
	port
	(
-- INPUTS
		rst		   	: in std_logic;
		clk		   	: in std_logic;
		data_incoming : in std_logic;
		calc_done	: in std_logic;
		equal_crc : in std_logic;
		bufout_done : in std_logic;
		
		mod_count	: in std_logic_vector ( 7 downto 0 );
		mod_pass0	: in std_logic;
		mod_pass1	: in std_logic;
		mod_pass2	: in std_logic;
		mod_pass3	: in std_logic;
		mod_passed0 : in std_logic_vector ( 1 downto 0 );
		mod_passed1 : in std_logic_vector ( 1 downto 0 );
		mod_passed2 : in std_logic_vector ( 1 downto 0 );
		mod_passed3 : in std_logic_vector ( 1 downto 0 );	
		
		sent	 	: in std_logic; -- oznacza, ze raport zostal juz wyslany

-- OUTPUTS
		flow_in		: out std_logic;
		
		status_index : out std_logic_vector ( 1 downto 0 );
		calc_start	: out std_logic;
		bufout_trans: out std_logic;
		bufout_send	: out std_logic;
		proc_mod	: out std_logic_vector ( 1 downto 0 );
		
		busy		: out std_logic
	);
end component;
	
	
	-- BUFOR.IN
component buforin 	
	port
	(
-- INPUTS
		clk : in  std_logic ;
		rst : in std_logic;
		data  : in std_logic_vector ( 7 downto 0 );
		proc_mod : in  std_logic_vector ( 1 downto 0 );
		flow_in : in std_logic; 
		sent 	: in std_logic; -- oznacza, ze raport zostal juz wyslany
	
		--zewnetrzny clr licznika adresow
		addr_calc_cnt_clr : in std_logic;
		addr_calc_cnt_ena : in std_logic;		
		
--OUTPUTS
		data_index : out std_logic_vector ( 7 downto 0 );
		CRC_index : out std_logic_vector ( 15 downto 0 );
		
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
end component;	

component crccalc
	port
	(
--INPUTS	
		clk : in std_logic;
		rst : in std_logic;
		calc_start : in std_logic;
		data_index : in std_logic_vector (7 downto 0 );
		
--OUTPUTS
		calc_done	: out std_logic;
		crc2_index : out std_logic_vector (15 downto 0 );
		addr_calc_cnt_clr : out std_logic;
		addr_calc_cnt_ena : out std_logic
		
	);
end component;

component comparator
	port
	(
--INPUTS
		CRC_index : in std_logic_vector ( 15 downto 0 );
		CRC2_index : in std_logic_vector ( 15 downto 0 );
--OUTPUTS
		equal_crc : out std_logic
	);
end component;
	
component buforout
	port
	(
--INPUTS
		clk : in std_logic;
		rst : in std_logic;
		
		bufout_send : in std_logic;
		bufout_trans : in std_logic;
		status_index : in std_logic_vector ( 1 downto 0 );
--OUTPUTS
		raport		: out std_logic_vector (7 downto 0 ); 
		bufout_done : out std_logic;
		send		: out std_logic
	);
end component;


begin

	u_s: us 
		port map (
			clk	=> clk,
			rst	=> rst,
			data_incoming => receive,
			calc_done => calc_done,
			equal_crc => equal_crc,
			bufout_done => bufout_done,
			mod_count => mod_count,
			mod_pass0 => mod_pass0,
			mod_pass1 => mod_pass1,
			mod_pass2 => mod_pass2,
			mod_pass3 => mod_pass3,
			mod_passed0 => mod_passed0,
			mod_passed1 => mod_passed1,
			mod_passed2 => mod_passed2,
			mod_passed3 => mod_passed3,	
			sent => sent,
			
			flow_in	=> flow_in,
			status_index => status_index,
			calc_start => calc_start,
			bufout_trans => bufout_trans,
			bufout_send	=> bufout_send,
			proc_mod => proc_mod,
			busy => busy
		);
		
	bufor_in: buforin 
		port map (
			clk => clk,
			rst => rst,
			data => data,
			flow_in	=> flow_in,
			sent => sent,
			proc_mod => proc_mod,
			data_index => data_index,
			CRC_index => CRC_index,
			addr_calc_cnt_clr => addr_calc_cnt_clr,
			addr_calc_cnt_ena => addr_calc_cnt_ena,
			
			mod_count => mod_count,		
			mod_pass0 => mod_pass0,
			mod_pass1 => mod_pass1,
			mod_pass2 => mod_pass2,
			mod_pass3 => mod_pass3,
			mod_passed0 => mod_passed0,
			mod_passed1 => mod_passed1,
			mod_passed2 => mod_passed2,
			mod_passed3 => mod_passed3
		);
		
	crc_calc : crccalc	
		port map (
			clk => clk,
			rst => rst,
			data_index => data_index,
			calc_start => calc_start,
			
			addr_calc_cnt_clr => addr_calc_cnt_clr,
			addr_calc_cnt_ena => addr_calc_cnt_ena,
			calc_done => calc_done,
			crc2_index => crc2_index
			
		);
	comparator_crc : comparator
		port map (
			CRC_index => CRC_index,
			CRC2_index => CRC2_index,
			
			equal_crc => equal_crc
			
		);
			
	bufor_out : buforout
		port map (
		
		clk => clk,
		rst => rst,
		bufout_send => bufout_send,
		bufout_trans => bufout_trans,
			
		bufout_done => bufout_done, 
		status_index => status_index,
		raport => raport,
		send => sent
		);
		
	send <= sent;
end structure;
	
	