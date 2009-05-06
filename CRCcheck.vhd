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
		
		---------
		
		---------
		
		-- Output ports
			-- read signal to usb
		usb_read	: out std_logic;
			-- end of reading signal to usb
		usb_endread : out std_logic;
			-- write signal to usb
		usb_write	: out std_logic;
			-- raport vector 
		raport : out std_logic_vector ( 7 downto 0 )
		
	);
end CRCcheck;

architecture structure of CRCcheck is

	-- list of signals
	signal index : std_logic_vector ( 1 downto 0 );
	signal index_k : std_logic_vector ( 1 downto 0 );
	signal status_index : std_logic_vector ( 1 downto 0 );
	signal status2_index : std_logic_vector ( 1 downto 0 );
	signal data_index : std_logic_vector ( 7 downto 0 );
	signal crc_index : std_logic_vector ( 15 downto 0 );
	signal crc2_index : std_logic_vector ( 15 downto 0 );
	
	
	-- BUFOR.IN
component buforin 	
	port
	(
			-- INPUTS
			--@@ TODO: nale¿y dodaæ sygna³y z uk³adu steruj¹cego
		clk : in std_logic;
		rst : in std_logic;
		data  : in std_logic_vector ( 7 downto 0 );
		
			--OUTPUTS
		usb_endread : out std_logic;
		index : out std_logic_vector ( 1 downto 0 );
		status2_index : out std_logic_vector ( 1 downto 0 );
		data_index : out std_logic_vector ( 7 downto 0 );
		CRC_index : out std_logic_vector ( 15 downto 0 )
		
	);
end component;	

component crccalc
	port
	(
	
		--INPUTS
		--@@ TODO dodaæ stygna³y z US
		clk : in std_logic;
		rst : in std_logic;
		index : in std_logic_vector ( 1 downto 0 );
		data_index : in std_logic_vector (7 downto 0 );

		--OUTPUTS
		index_k : out std_logic_vector ( 1 downto 0 );
		crc2_index : out std_logic_vector (15 downto 0 )
		
	);
end component;
	
component buforout
	port
	(
	
		--INPUTS
		--@@ TODO dodaæ stygna³y z US
		clk : in std_logic;
		rst : in std_logic;
		status_index : in std_logic_vector ( 1 downto 0 );
		status2_index : in std_logic_vector (1 downto 0 );

		--OUTPUTS
		raport : out std_logic_vector (7 downto 0 )
		
	);
end component;

component comparator
	

	port
	(
	
		--INPUTS
		--@@ TODO dodaæ stygna³y z US
		index : in std_logic_vector ( 1 downto 0 );
		index_k : in std_logic_vector ( 1 downto 0 );
		CRC_index : in std_logic_vector ( 15 downto 0 );
		CRC2_index : in std_logic_vector ( 15 downto 0 );

		--OUTPUTS
		status_index : out std_logic_vector ( 1 downto 0 )
		
	);
end component;
	
begin
	bufor_in: buforin 
		port map (
			clk => clk,
			rst => rst,
			data => data,
			
			usb_endread => usb_endread,
			index => index,
			data_index => data_index,
			CRC_index => CRC_index,
			status2_index => status2_index
		);
		
	crc_calc : crccalc	
		port map (
			clk => clk,
			rst => rst,
			index => index,
			data_index => data_index,
			
			index_k => index_k,
			crc2_index => crc2_index
			
		);
		
	bufor_out : buforout
		port map (
			clk => clk,
			rst => rst,
			status_index => status_index,
			status2_index => status2_index,
			
			raport => raport
		);
		
	comparator_crc : comparator
		port map (
			index => index,
			index_k => index_k,
			CRC_index => CRC_index,
			CRC2_index => CRC2_index,
			
			status_index => status_index
			
		);
end structure;
	
	