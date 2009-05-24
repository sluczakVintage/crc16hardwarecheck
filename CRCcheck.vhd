--------------------------------
-- File		:	CRCcheck.vhd
-- Version	:	0.1
-- Date		:	03.05.2009
-- Desc		:	First iteration of crc transmission control system
-- Author	:	Sebastian £uczak
-- Author	:	Maciej Nowak 
-- Based on	:	/
--------------------------------

---------------------------
--
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity CRCcheck is
	
	port
	(
		-- Input ports
			-- clock signal
		clk : in  std_logic ;
			-- synchronous reset signal
		rst : in  std_logic;
			-- read aproval signal
		usb_rxf : in std_logic;
			-- data vector from usb
		data : in  std_logic_vector ( 7 downto 0 );

		
		-- Output ports
			-- read signal to usb
	--	usb_read	: out std_logic;
			-- end of reading signal to usb
	--	usb_endread : out std_logic;
			-- write signal to usb
	--	usb_write	: out std_logic;
			-- raport vector 
		raport : out std_logic_vector ( 7 downto 0 )
		
	);
end CRCcheck;

architecture structure of CRCcheck is

	-- list of signals
	signal status_index : std_logic_vector ( 1 downto 0 ); 
	signal equal_crc, equal_ml : std_logic;
	signal data_index : std_logic_vector ( 7 downto 0 );
	signal CRC_index : std_logic_vector ( 15 downto 0 );
	signal CRC2_index : std_logic_vector ( 15 downto 0 );
	
	signal addr_cal_cnt_clr : std_logic;
	signal ren_DATA0, ren_DATA1, ren_DATA2, ren_DATA3 : std_logic;
	signal mux_DATA : std_logic_vector ( 1 downto 0 );
	signal calc_done, bufout_ready, bufout_done, mod_passed0, mod_passed1, mod_passed2, mod_passed3 : std_logic;	
	signal flow_in, calc_start, bufout_trans, bufout_send, transmit_end : std_logic; ---<<<<< TRANSMIT END
	signal trans_mod : std_logic_vector ( 1 downto 0 );
	
	-- US
	
component us
	
	port
	(
		-- Input ports
		rst		   	: in std_logic;
		clk		   	: in std_logic;
		data_incoming : in std_logic;
		calc_done	: in std_logic;
		equal_crc : in std_logic;	
		equal_ml	: in std_logic;
		bufout_done : in std_logic;
		mod_passed0 : in std_logic;
		mod_passed1 : in std_logic;
		mod_passed2 : in std_logic;
		mod_passed3 : in std_logic;	

		-- Output ports
		flow_in	: out std_logic;
		
		status_index : out std_logic_vector ( 1 downto 0 );
		calc_start	: out std_logic;
		bufout_trans: out std_logic;
		bufout_send	: out std_logic;
		trans_mod : out std_logic_vector ( 1 downto 0 )
	);
end component;
	
	
	-- BUFOR.IN
component buforin 	
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
		ren_DATA0, ren_DATA1, ren_DATA2, ren_DATA3 : in std_logic;
		-- mux wybierajacy sygnal do odczytu
		muxDATA : in std_logic_vector ( 1 downto 0 ); 
		--zewnetrzny clr licznika adresow
		addr_calc_cnt_clr : in std_logic;
		
		
			--OUTPUTS
	--	usb_endread : out std_logic;
		equal_ml : out std_logic;
		data_index : out std_logic_vector ( 7 downto 0 );
		CRC_index : out std_logic_vector ( 15 downto 0 );
		mod_passed0 : out std_logic;
		mod_passed1 : out std_logic;
		mod_passed2 : out std_logic;
		mod_passed3 : out std_logic	
		
	);
end component;	

component crccalc
	port
	(
	
		clk : in std_logic;
		rst : in std_logic;
		calc_start : in std_logic;
		data_index : in std_logic_vector (7 downto 0 );
		trans_mod : in  std_logic_vector ( 1 downto 0 );
		--OUTPUTS
		calc_done	: out std_logic;
		crc2_index : out std_logic_vector (15 downto 0 );
		addr_calc_cnt_clr : out std_logic;
		ren_DATA0, ren_DATA1, ren_DATA2, ren_DATA3 : out std_logic;
		muxDATA : out std_logic_vector ( 1 downto 0 )
		
	);
end component;

component comparator
	port
	(
		--INPUTS
		--@@ TODO dodaæ stygna³y z US
		CRC_index : in std_logic_vector ( 15 downto 0 );
		CRC2_index : in std_logic_vector ( 15 downto 0 );
		--OUTPUTS
		equal_crc : out std_logic
	);
end component;
	
component buforout
	port
	(
		clk : in std_logic;
		rst : in std_logic;
		
		bufout_send : in std_logic;
		bufout_trans : in std_logic;
		status_index : in std_logic_vector ( 1 downto 0 );
			--OUTPUTS
		raport : out std_logic_vector (7 downto 0 ); 
		bufout_done : out std_logic
	);
end component;


begin

	u_s: us 
		port map (
			clk	=> clk,
			rst	=> rst,
			data_incoming => usb_rxf,
			calc_done => calc_done,
			equal_crc => equal_crc,
			equal_ml => equal_ml,
			bufout_done => bufout_done,
			mod_passed0 => mod_passed0,
			mod_passed1 => mod_passed1,
			mod_passed2 => mod_passed2,
			mod_passed3 => mod_passed3,	
			
			flow_in	=> flow_in,
			status_index => status_index,
			calc_start => calc_start,
			bufout_trans => bufout_trans,
			bufout_send	=> bufout_send,
			trans_mod => trans_mod
		);
		
	bufor_in: buforin 
		port map (
			clk => clk,
			rst => rst,
			data => data,
			flow_in	=> flow_in,
			trans_mod => trans_mod,
			data_index => data_index,
			CRC_index => CRC_index,
			equal_ml => equal_ml,
			addr_calc_cnt_clr => addr_cal_cnt_clr,
			ren_DATA0 => ren_DATA0, 
			ren_DATA1 => ren_DATA1, 
			ren_DATA2 => ren_DATA2, 
			ren_DATA3 => ren_DATA3, 
			muxDATA => mux_DATA,
			
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
			trans_mod => trans_mod,
			
			addr_calc_cnt_clr => addr_cal_cnt_clr,
			calc_done => calc_done,
			crc2_index => crc2_index,
			ren_DATA0 => ren_DATA0, 
			ren_DATA1 => ren_DATA1, 
			ren_DATA2 => ren_DATA2 , 
			ren_DATA3 => ren_DATA3, 
			muxDATA => mux_DATA
			
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
		raport => raport
		);
		
	
end structure;
	
	