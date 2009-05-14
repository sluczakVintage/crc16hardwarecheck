--------------------------------
-- File		:	flowcontrol2.vhd
-- Version	:	0.1
-- Date		:	03.05.2009
-- Desc		:	Bit flow controler
-- Author	:	Sebastian £uczak
-- Author	:	Maciej Nowak 
-- Based on	:	/
--------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;


entity us is
	
	port
	(
		-- Input ports
		rst		   	: in std_logic;
		clk		   	: in std_logic;
		data_incoming : in std_logic;
		calc_ready	: in std_logic;
		calc_done	: in std_logic;
		comp_ready	: in std_logic;
		comp_done	: in std_logic;
		bufout_ready : in std_logic;
		bufout_done : in std_logic;
		mod_passed0 : in std_logic;
		mod_passed1 : in std_logic;
		mod_passed2 : in std_logic;
		mod_passed3 : in std_logic;	

		-- Output ports
		flow_in	: out std_logic;
		calc_start	: out std_logic;
		comp_start	: out std_logic;
		bufout_trans: out std_logic;
		bufout_send	: out std_logic
--		trans_mod0 : out std_logic;
--		trans_mod1 : out std_logic;
--		trans_mod2 : out std_logic;
--		trans_mod3 : out std_logic
	);
end us;

-- Library Clause(s) (optional)
-- Use Clause(s) (optional)

architecture rtl of us is


type MAIN_FSM_STATE_TYPE is (
	main_fsb_idle,
	main_fsb_receive,
	main_fsb_proc0,
	main_fsb_busy0,
	main_fsb_proc1,
	main_fsb_busy1,
	main_fsb_proc2,
	main_fsb_busy2,
	main_fsb_proc3,
	main_fsb_send
	);
signal main_fsb_reg, main_fsb_next	: MAIN_FSM_STATE_TYPE;

type PROC_FSM_STATE_TYPE is (
	proc_fsb_idle,
	proc_fsb_queue1,
	proc_fsb_calc,
	proc_fsb_queue2,
	proc_fsb_comp,
	proc_fsb_queue3,
	proc_fsb_transmit
	);
signal proc_fsb_reg, proc_fsb_next	: PROC_FSM_STATE_TYPE;	


signal flow, start_processing, send : std_logic;
signal mod_processed, start_calc, start_comp, start_trans : std_logic;

begin
-- Opis dzialania automatu glownego
	process (clk, rst)
	begin
		if rst = '1' then
			main_fsb_reg <= main_fsb_idle;	
		elsif rising_edge(clk) then
			main_fsb_reg <= main_fsb_next;
		end if;
	end process;
	-- Funkcja przejsc-wyjsc
	
process (main_fsb_reg, mod_processed, data_incoming, mod_passed0, mod_passed1, mod_passed2, mod_passed3, bufout_ready)
begin
	start_processing <= '0';
	flow <= '0';
	send <= '0';

	case main_fsb_reg is
		when main_fsb_idle =>   -- jesli dane wchodza, zacznij je odbierac, inaczej czekaj
			if data_incoming = '0' then
				main_fsb_next <= main_fsb_idle;
			else
				main_fsb_next <= main_fsb_receive;
				flow <= '1'; -- zacznij przeplyw
			end if;
		when main_fsb_receive => -- jesli dane z pierwszego pakietu juz zostaly odebrane, zacznij je przetwarzac
			if mod_passed0 = '0' then
				main_fsb_next <= main_fsb_receive;
			else
				main_fsb_next <= main_fsb_proc0;
				start_processing <= '1'; -- zacznij przetwarzanie
			end if;
		when main_fsb_proc0 => -- jesli dane z pierwszego pakietu zostaly odebrane, czekaj na zakonczenie przetwarzania
			if mod_passed1 = '1' then
				main_fsb_next <= main_fsb_busy0;
			else
				main_fsb_next <= main_fsb_proc0;
			end if;
		when main_fsb_busy0 => -- jesli dane przetworzone, rozpocznij przetwarzanie nastepnych
			if mod_processed = '0' then
				main_fsb_next <= main_fsb_busy0;
			else
				main_fsb_next <= main_fsb_proc1;
				start_processing <= '1'; -- zacznij przetwarzanie
			end if;
		when main_fsb_proc1 => -- jesli dane z drugiego pakietu zostaly odebrane, czekaj na zakonczenie przetwarzania
			if mod_passed2 = '1' then
				main_fsb_next <= main_fsb_busy1;
			else
				main_fsb_next <= main_fsb_proc1;
			end if;
		when main_fsb_busy1 => -- jesli dane przetworzone, rozpocznij przetwarzanie nastepnych
			if mod_processed = '0' then
				main_fsb_next <= main_fsb_busy1;
			else
				main_fsb_next <= main_fsb_proc2;
				start_processing <= '1'; -- zacznij przetwarzanie
			end if;
		when main_fsb_proc2 => -- jesli dane z trzeciego pakietu zostaly odebrane, czekaj na zakonczenie przetwarzania
			if mod_passed3 = '1' then
				main_fsb_next <= main_fsb_busy2;
				flow <= '0'; -- zakoncz przeplyw
			else
				main_fsb_next <= main_fsb_proc2;
			end if;
		when main_fsb_busy2 => -- jesli dane przetworzone, rozpocznij przetwarzanie nastepnych
			if mod_processed = '0' then
				main_fsb_next <= main_fsb_busy2;
			else
				main_fsb_next <= main_fsb_proc3;
				start_processing <= '1'; -- zacznij przetwarzanie
			end if;
		when main_fsb_proc3 => -- jesli dane przetworzone, zacznij wysylanie
			if mod_processed = '0' then
				main_fsb_next <= main_fsb_proc3;
			else
				main_fsb_next <= main_fsb_send;
			end if;
		when main_fsb_send => -- jesli buforout gotowy, rozpocznij wysylanie
			if bufout_ready = '0' then
				main_fsb_next <= main_fsb_send;
			else
				main_fsb_next <= main_fsb_idle;
				send <= '1'; -- zacznij przesylanie
			end if;
	end case;
end process;

-- Opis dzialania automatu przetwarzania
	process (clk, rst)
	begin
		if rst = '1' then
			proc_fsb_reg <= proc_fsb_idle;	
		elsif rising_edge(clk) then
			proc_fsb_reg <= proc_fsb_next;
		end if;
	end process;
--	-- Funkcja przejsc-wyjsc
	
process (proc_fsb_reg, start_processing, calc_ready, calc_done, comp_ready, comp_done, bufout_ready, bufout_done)
begin
start_calc <= '0';
start_comp <= '0';
start_trans <= '0';
mod_processed <= '0';
	case proc_fsb_reg is
		when proc_fsb_idle =>  
			if start_processing = '0' then
				proc_fsb_next <= proc_fsb_idle;
			else
				proc_fsb_next <= proc_fsb_queue1;
			end if;
		when proc_fsb_queue1 =>  
			if calc_ready ='0' then
				proc_fsb_next <= proc_fsb_queue1;
			else 
				proc_fsb_next <= proc_fsb_calc;
				start_calc <= '1'; 
			end if;
		when proc_fsb_calc =>
			if calc_done = '0' then
				proc_fsb_next <= proc_fsb_calc;
			else
				proc_fsb_next <= proc_fsb_queue2;
			end if;
		when proc_fsb_queue2 =>
			if comp_ready = '0' then
				proc_fsb_next <= proc_fsb_queue2;
			else
				proc_fsb_next <= proc_fsb_comp;
				start_comp <= '1';
			end if;
		when proc_fsb_comp =>
			if comp_done = '0' then
				proc_fsb_next <= proc_fsb_comp;
			else
				proc_fsb_next <= proc_fsb_queue3;
			end if;
		when proc_fsb_queue3 =>
			if bufout_ready = '0' then
				proc_fsb_next <= proc_fsb_queue3;
			else
				proc_fsb_next <= proc_fsb_transmit;
				start_trans <= '1';
			end if;
		when proc_fsb_transmit =>
			if bufout_done = '0' then
				proc_fsb_next <= proc_fsb_transmit;
			else
				proc_fsb_next <= proc_fsb_idle;
				mod_processed <= '1';
			end if;
		end case;

end process;
flow_in <= flow;
bufout_send <= send;
calc_start	<= start_calc;
comp_start	<= start_comp;
bufout_trans <= start_trans;
end rtl;
