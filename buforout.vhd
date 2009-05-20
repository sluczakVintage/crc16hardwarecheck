--------------------------------
-- File		:	buforout.vhd
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

entity buforout is

	port
	(
		--INPUTS
		--@@ TODO dodaæ stygna³y z US
		
		clk : in std_logic;
		rst : in std_logic;
		
		bufout_send : in std_logic;
		bufout_trans : in std_logic;
		trans_mod : in  std_logic_vector ( 1 downto 0 );
		status_index : in std_logic_vector ( 1 downto 0 );
	--	status2_index : in std_logic_vector ( 1 downto 0 );
	
		--OUTPUTS
		raport : out std_logic_vector (7 downto 0 ); --<<<<<<zmieniæ na 8bit!!
		
		bufout_ready : out std_logic;
		bufout_done : out std_logic
		
	);
end buforout;
-- Library Clause(s) (optional)
-- Use Clause(s) (optional)

architecture data_flow of buforout is

---- automat buforout

type BUFOUT_FSM_STATE_TYPE is (
	bufout_idle,				--- stan spoczynkowy
	bufout_receiving,			--- stan odbierania danych 
	bufout_sending				--- stan wysy³ania raportu
	);

signal bufout_fsb_cur, bufout_fsb_next	: BUFOUT_FSM_STATE_TYPE; --- sygna³y automatu bufout

signal ready_bufout, done_bufout : std_logic; 		--sygna³y do komunikacji miêdzy bufout a us


signal enable1, enable2, enable3, enable4 : std_logic;
signal sel_mux, sel_dmux, rap : std_logic_vector ( 1 downto 0 ); -------------<<<<


--- rejestry w buforout. przechowuj¹ce statusy crc, 
--component mux2x2
--	port
--	(
--	i1, i2 				: in std_logic_vector ( 1 downto 0 );
--	sel2 				: in std_logic_vector ( 0 downto 0);
--	output 				: out std_logic_vector ( 1 downto 0)
--	);
--end component;


component dmux4x2	
	port
	(
		input			: in std_logic_vector ( 1 downto 0 );
		sel				: in std_logic_vector( 1 downto 0 );
		o1, o2, o3, o4	: out std_logic_vector ( 1 downto 0 )
		
	);
end component;	

component mux4x2
	port(
		i1, i2, i3, i4	: in std_logic_vector ( 1 downto 0 );
		sel				: in std_logic_vector ( 1 downto 0 );
		output 			: out std_logic_vector ( 1 downto 0 )
	);
end component;

component reg2
	port
	(
		--INPUTS
		--@@ TODO dodaæ stygna³y z US
		clk : in std_logic;
		rst : in std_logic;
		ena : in std_logic;
		d : in std_logic_vector ( 1 downto 0 );
		
		--OUTPUTS
		q : out std_logic_vector ( 1 downto 0 )

	);
end component;


signal sig1_a, sig1_b, sig1_c, sig1_d, sig2_a, sig2_b, sig2_c, sig2_d : std_logic_vector ( 1 downto 0 );
begin
	status_0 : reg2
		port map ( 
			clk => clk,
			rst => rst,
			ena => enable1,
			d => sig1_a,
			q => sig2_a
		);

	status_1 : reg2
		port map (
			clk => clk,
			rst => rst,
			ena => enable2,
			d => sig1_b,
			q => sig2_b
		);

	status_2 : reg2
		port map (
			clk => clk,
			rst => rst,
			ena => enable3,
			d => sig1_c,
			q => sig2_c
		);

	status_3 : reg2
		port map (
			clk => clk,
			rst => rst,
			ena => enable4,
			d => sig1_d,
			q => sig2_d
		);

	dmux1 : dmux4x2
		port map (
			input => status_index,
			sel => sel_dmux,
			o1 => sig1_a,
			o2 => sig1_b,
			o3 => sig1_c,
			o4 => sig1_d
		);
	
	mux2 : mux4x2 
		port map (
			output => rap,   --------------------<<<<<
			sel => sel_mux,
			i1 => sig2_a,
			i2 => sig2_b,
			i3 => sig2_c,
			i4 => sig2_d
		);
		
		
----------AUTOMAT BUFOUT ---------------------

process (clk, rst)
	begin
		if rst = '0' then
			bufout_fsb_cur <= bufout_idle;	
		elsif rising_edge(clk) then
			bufout_fsb_cur <= bufout_fsb_next;
		end if;
	end process;



process(bufout_fsb_cur, bufout_trans, bufout_send, trans_mod)
	begin
		
		sel_dmux <= "00";
		enable1 <= '0';
		enable2 <= '0';
		enable3 <= '0';
		enable4 <= '0';
		done_bufout <= '0';
		ready_bufout <= '0';	
		
		case bufout_fsb_cur is
			
			when bufout_idle => 	
					if bufout_trans = '1' then
						bufout_fsb_next <= bufout_receiving;
					elsif bufout_send = '1' then
						bufout_fsb_next <= bufout_sending;
					else
						bufout_fsb_next <= bufout_idle;	
						ready_bufout <= '1';	
					end if;		
			when bufout_receiving =>
				
					if trans_mod  = "00" then
						bufout_fsb_next <= bufout_idle;
						ready_bufout <= '1';
						done_bufout <= '1';
						sel_dmux <= "00";
						enable1 <= '1';			
					elsif trans_mod  = "01" then
						bufout_fsb_next <= bufout_idle;
						ready_bufout <= '1';
						done_bufout <= '1';
						sel_dmux <= "01";
						enable2 <= '1';
					
					elsif trans_mod  = "10" then
						bufout_fsb_next <= bufout_idle;
						ready_bufout <= '1';
						done_bufout <= '1';
						sel_dmux <= "10";
						enable3 <= '1';
					
					elsif trans_mod  = "11" then
						bufout_fsb_next <= bufout_idle;
						ready_bufout <= '1';
						done_bufout <= '1';
						sel_dmux <= "11";
						enable4 <= '1';
					else 
						bufout_fsb_next <= bufout_idle;
					end if;	
			
			when bufout_sending =>
				bufout_fsb_next <= bufout_idle;
				ready_bufout <= '1';
		end case;				
			
	end process;
bufout_done <= done_bufout;	
bufout_ready <= ready_bufout;
	
end data_flow;
