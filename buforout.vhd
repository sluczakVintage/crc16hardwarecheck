--------------------------------
-- File		:	buforout.vhd
-- Version	:	0.9
-- Date		:	03.05.2009
-- Desc		:	Output buffer entity
-- Author	:	Sebastian £uczak
-- Author	:	Maciej Nowak 
-- Based on	:	/
--------------------------------

---------------------------
--
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity buforout is

	port
	(
--INPUTS		
		clk : in std_logic;
		rst : in std_logic;
		
		bufout_send : in std_logic;
		bufout_trans : in std_logic;
		status_index : in std_logic_vector ( 1 downto 0 );
	
--OUTPUTS
		raport : out std_logic_vector (7 downto 0 ); 
		bufout_done : out std_logic;
		send		: out std_logic
		
	);
end buforout;


architecture data_flow of buforout is

---- automat buforout

type BUFOUT_FSM_STATE_TYPE is (
	bufout_idle,				--- stan spoczynkowy
	bufout_receiving,			--- stan odbierania danych 
	bufout_sending,				--- stan wysy³ania raportu
	bufout_clearing
	);

signal bufout_fsb_cur, bufout_fsb_next	: BUFOUT_FSM_STATE_TYPE; --- sygna³y automatu bufout

signal ready_bufout, done_bufout : std_logic; 		--sygna³y do komunikacji miêdzy bufout a us

component reg2bit_to_8bit
	port
	(
		--INPUTS
		clk : in std_logic;
		rst : in std_logic;
		ena : in std_logic;
		clr : in std_logic;
		d : in std_logic_vector ( 1 downto 0 );
		
		--OUTPUTS
		q : out std_logic_vector ( 7 downto 0 )

	);
end component;

signal enable, clear : std_logic;

begin

	raport_reg : reg2bit_to_8bit
		port map (
			clk => clk,
			rst => rst,
			ena => enable,
			clr => clear,
			d => status_index,
			q => raport
			);

		
----------AUTOMAT BUFOUT ---------------------

process (clk, rst)
	begin
		if rst = '1' then
			bufout_fsb_cur <= bufout_idle;	
		elsif rising_edge(clk) then
			bufout_fsb_cur <= bufout_fsb_next;
		end if;
	end process;



process(bufout_fsb_cur, bufout_trans, bufout_send)
	begin
		enable <= '0';
		clear <= '0';
		done_bufout <= '0';
		send <= '0';
		
		case bufout_fsb_cur is
			
			when bufout_idle => 	
					if bufout_trans = '1' then
						bufout_fsb_next <= bufout_receiving;
					elsif bufout_send = '1' then
						bufout_fsb_next <= bufout_sending;
					else
						bufout_fsb_next <= bufout_idle;		
					end if;		
			when bufout_receiving =>			
					done_bufout <= '1';
					enable <= '1';
					bufout_fsb_next <= bufout_idle;

			when bufout_sending =>
				bufout_fsb_next <= bufout_clearing;
				send <= '1';  
				
			when bufout_clearing =>
				bufout_fsb_next <= bufout_idle;
				clear <= '1';
				
		end case;				
			
	end process;
bufout_done <= done_bufout;	
end data_flow;
