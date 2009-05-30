--------------------------------
-- File		:	crccalc.vhd
-- Version	:	0.9
-- Date		:	03.05.2009
-- Desc		:	CRC Calculator
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
use work.PCK_CRC16_D8.all;	


entity crccalc is
	
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
	
end crccalc;
-- Library Clause(s) (optional)
-- Use Clause(s) (optional)

architecture behavior of crccalc is


--sygnaly informujace o stanie kalkulatora
signal wait_forCRC, done_calc : std_logic;
--sygnaly zawierajace wartosci CRC w roznych fazach
signal nextCRC, newCRC : std_logic_vector( 15 downto 0 ) := "0000000000000000";
--sygnal zawierajacy dane do przetworzenia
signal data_to_process : std_logic_vector ( 7 downto 0 ) := "00000000";

--Maszyna stanow odpowiedzialna za liczenie CRC
type CALC_FSM_STATE_TYPE is (
	calc_idle,
	calc_wait,
	calc_calculate,
	calc_store,
	calc_processed
	);
signal calc_fsb_reg, calc_fsb_next	: CALC_FSM_STATE_TYPE;

--sygna³y do licznika
signal cnt_reg, cnt_next: std_logic_vector (3 downto 0);	
signal cnt_clr, cnt_ena : std_logic;

component reg16
	port
	(
		--INPUTS
		clk : in std_logic;
		rst : in std_logic;
		ena : in std_logic;
		d : in std_logic_vector ( 15 downto 0 );
		--OUTPUTS
		q : out std_logic_vector ( 15 downto 0 )	
	);
end component;

begin
-- Licznik jako rejestr 4bit
	process (clk, rst)
	begin
		if rst = '1'  then
			cnt_reg <= (others => '0');	
		elsif rising_edge(clk) then
			cnt_reg <= cnt_next;
		end if;
	end process;

	process (cnt_reg, cnt_clr, cnt_ena)
	begin
		if cnt_clr = '1' then
			cnt_next <= (others => '0');
		elsif cnt_ena = '1' then
			cnt_next <= cnt_reg + "1";
		else 
			cnt_next <= cnt_reg;
		end if;
	end process;			  
	


-- Opis dzialania automatu kalkulatora
	process (clk, rst)
	begin
		if rst = '1' then
			calc_fsb_reg <= calc_idle;	
		elsif rising_edge(clk) then
			calc_fsb_reg <= calc_fsb_next;
		end if;
	end process;
--	-- Funkcja przejsc-wyjsc
	
	process (calc_fsb_reg, calc_start, data_index, cnt_reg)
	begin
	
		data_to_process <= "00000000";
		done_calc <= '0';
		addr_calc_cnt_clr  <= '0';
		addr_calc_cnt_ena <= '0';

		cnt_clr <= '0';
		cnt_ena <= '0';
		
		case calc_fsb_reg is
			when calc_idle =>  
				cnt_clr <= '1';
				if calc_start = '0' then
					calc_fsb_next <= calc_idle;
				else
					addr_calc_cnt_clr <= '1';
					calc_fsb_next <= calc_wait;
				end if;
				
			when calc_wait =>
						addr_calc_cnt_ena <= '1';
						calc_fsb_next <= calc_calculate;
						
			when calc_calculate =>
						addr_calc_cnt_ena <= '1';
						data_to_process <= data_index;
						if data_index = "00000011" then  
							data_to_process <= ( others => '0' );
							calc_fsb_next <= calc_store;
						else
						calc_fsb_next <= calc_calculate;
						end if;				
					
			when calc_store =>
				cnt_ena <= '1';
				data_to_process <= ( others => '0' );
				if cnt_reg = "1011" then 
					calc_fsb_next <= calc_processed;
				else
					calc_fsb_next <= calc_store;
				end if;
				
			when calc_processed =>
				addr_calc_cnt_clr <= '1';
				data_to_process <= ( others => '0' );
				done_calc <= '1';
				calc_fsb_next <= calc_idle;
		end case;
	end process;


------Liczenie CRC ------------
	process (clk, rst)
		begin
			if (rst = '1') then
				newCRC <= (others => '0');
			elsif rising_edge(clk) then
				newCRC <= nextCRC;
			end if;
		end process;	
		
	process (calc_fsb_reg, data_to_process, newCRC)
	begin
		nextCRC <= (others => '0');
		if calc_fsb_reg = calc_idle then
			nextCRC <= ( others => '0' );
		else 
			nextCRC <= nextCRC16_D8 (data_to_process, newCRC);
		
		end if;
			
	end process;

	rCRC : reg16
					port map ( 
				clk => clk,
				rst => rst,
				ena => done_calc,
				d => newCRC,
				q => crc2_index
	);


calc_done <= done_calc;
end behavior;
