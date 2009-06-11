--------------------------------
-- File		:	maintest.vhd
-- Version	:	0.1
-- Date		:	03.06.2009
-- Desc		:	Project testbench entity
-- Author	:	Sebastian £uczak
-- Author	:	Maciej Nowak 
-- Based on	:	/
--------------------------------

---------------------------
--
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use std.textio.all;

entity CRCcheck_tb is
end CRCcheck_tb;

architecture test of CRCcheck_tb is

	component CRCcheck 
		
		port
		(
			clk 	: in  std_logic ;
			rst 	: in  std_logic;
			receive : in std_logic;
			data 	: in  std_logic_vector ( 7 downto 0 );
			
			send	: out std_logic;
			busy	: out std_logic;
			raport 	: out std_logic_vector ( 7 downto 0 )
			
		);
	end component;
			
	component stimulator

		generic(
				 stim_file: string :="testdata\sim.dat"
				);
		port(
			clk			: in std_logic;
			rst			: in std_logic;
			busy		: in std_logic;
			data		: out std_logic_vector ( 7 downto 0 );
			receive		: out std_logic
			 
			);
	end component;
	
	component monitor

		generic(
				 mon_file: string :="testdata\sim_res.dat"
				);
		port(
			sent   		: in std_logic;
			raport		: in std_logic_vector ( 7 downto 0 )
			);
	end component;

	signal clk		: std_logic := '0';
	signal rst		: std_logic;
	signal busy  	: std_logic;
	signal receive	: std_logic;
	signal data		: std_logic_vector ( 7 downto 0 );
	signal raport 	: std_logic_vector ( 7 downto 0 );
	signal sent  	: std_logic;

	begin
	
		rst <= '0', '1' after 10 ns, '0' after 30 ns;
		clk <= not clk after 10 ns;

		DUT : CRCcheck
		port map (
			clk => clk,
			rst => rst,
			data => data,
			receive => receive,
			
			send => sent,
			busy => busy,
			raport => raport
			
		);
		input_sim : stimulator
		port map (
			clk => clk,
			rst => rst,
			busy => busy,
			data => data,
			receive => receive
			
		);
		
		output_mon : monitor
		port map (
			sent => sent,
			raport => raport
		);
end test;