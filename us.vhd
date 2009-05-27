--------------------------------
-- File		:	us.vhd
-- Version	:	0.1
-- Date		:	03.05.2009
-- Desc		:	Uklad sterujacy
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
		calc_done	: in std_logic;
		equal_crc 	: in std_logic;	
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
		--------------------
		--11 oznacza bezbledny przelot modulu
		--10 oznacza przelot modulu z bledami dlugosci
		--------------------
		-- Output ports
		flow_in	: out std_logic;
		
		status_index : out std_logic_vector ( 1 downto 0 );
		calc_start	: out std_logic;
		bufout_trans: out std_logic;
		bufout_send	: out std_logic;
		trans_mod : out std_logic_vector ( 1 downto 0 )
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
	proc_fsb_calc,
	proc_fsb_comp,
	proc_fsb_transmit
	);
signal proc_fsb_reg, proc_fsb_next	: PROC_FSM_STATE_TYPE;	

signal mod_passed0_reg, mod_passed1_reg, mod_passed2_reg, mod_passed3_reg : std_logic_vector ( 1 downto 0 );



signal flow, start_processing, send_bufout : std_logic;
signal mod_processed, start_calc, start_comp, start_trans : std_logic;
signal mod_trans, index_status  : std_logic_vector ( 1 downto 0 );
signal status_0bit, status_1bit : std_logic;
signal status_0bit_reg, status_1bit_reg : std_logic;

begin



	process(clk, rst, mod_pass0)
	begin
		if(rst='1') then
			mod_passed0_reg <= (others => '0');
		elsif (rising_edge(clk) AND mod_pass0 = '1') then
			mod_passed0_reg  <= mod_passed0;
		end if;
	end process;
	
	
	process(clk, rst, mod_pass1)
	begin
		if(rst='1') then
			mod_passed1_reg <= (others => '0');
		elsif (rising_edge(clk) AND mod_pass1 = '1') then
			mod_passed1_reg  <= mod_passed1;
		end if;
	end process;
	
	
	process(clk, rst, mod_pass2)
	begin
		if(rst='1') then
			mod_passed2_reg <= (others => '0');
		elsif (rising_edge(clk) AND mod_pass2 = '1') then
			mod_passed2_reg  <= mod_passed2;
		end if;
	end process;
	
	
	process(clk, rst, mod_pass3)
	begin
		if(rst='1') then
			mod_passed3_reg <= (others => '0');
		elsif (rising_edge(clk) AND mod_pass3 = '1') then
			mod_passed3_reg  <= mod_passed3;
		end if;
	end process;


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
	
process (main_fsb_reg, mod_processed, data_incoming, mod_count, mod_passed0_reg, mod_passed1_reg, mod_passed2_reg, mod_passed3_reg)
begin
	start_processing <= '0';
	flow_in <= '0';
	bufout_send <= '0';
	trans_mod <= "00";
	status_0bit <= '0';
	
	case main_fsb_reg is
	
		when main_fsb_idle =>   -- jesli dane wchodza, zacznij je odbierac, inaczej czekaj
			if data_incoming = '0' then
				main_fsb_next <= main_fsb_idle;
			else
				main_fsb_next <= main_fsb_receive;
				flow_in <= '1'; -- zacznij przeplyw
			end if;
			
		when main_fsb_receive => -- jesli dane z pierwszego pakietu juz zostaly odebrane, zacznij je przetwarzac
			if mod_passed0_reg = "11" then
				status_0bit <= '1';
				main_fsb_next <= main_fsb_proc0;
			elsif mod_passed0_reg = "10" then
				status_0bit <= '0';
				main_fsb_next <= main_fsb_busy0;
			else
				flow_in <= '1';
				main_fsb_next <= main_fsb_receive;
			end if;
			
		when main_fsb_proc0 => -- jesli dane z pierwszego pakietu zostaly odebrane, czekaj na zakonczenie przetwarzania
			if mod_processed = '1' then
				if mod_count = "00" then
					main_fsb_next <= main_fsb_send;
				else
					main_fsb_next <= main_fsb_busy0;
				end if;
			else
				trans_mod <= "00";
				start_processing <= '1'; -- zacznij przetwarzanie
				main_fsb_next <= main_fsb_proc0;
			end if;
			
		when main_fsb_busy0 => -- jesli dane przetworzone, rozpocznij przetwarzanie nastepnych
			if mod_passed1_reg = "11" then
				status_0bit <= '1';
				main_fsb_next <= main_fsb_proc1;
			elsif mod_passed1_reg = "10" then
				status_0bit <= '0';
				main_fsb_next <= main_fsb_busy1;
			else
				main_fsb_next <= main_fsb_busy0;
			end if;
------------------------------------------------------------------------------------------
		when main_fsb_proc1 => -- jesli dane z pierwszego pakietu zostaly odebrane, czekaj na zakonczenie przetwarzania
			if mod_processed = '1' then
				if mod_count = "01" then
					main_fsb_next <= main_fsb_send;
				else
					main_fsb_next <= main_fsb_busy1;
				end if;
			else
				trans_mod <= "01";
				start_processing <= '1'; -- zacznij przetwarzanie
				main_fsb_next <= main_fsb_proc1;
			end if;
			
		when main_fsb_busy1 => -- jesli dane przetworzone, rozpocznij przetwarzanie nastepnych
			if mod_passed2_reg = "11" then
				status_0bit <= '1';
				main_fsb_next <= main_fsb_proc2;
			elsif mod_passed2_reg = "10" then
				status_0bit <= '0';
				main_fsb_next <= main_fsb_busy2;
			else
				main_fsb_next <= main_fsb_busy1;
			end if;
			
		when main_fsb_proc2 => -- jesli dane z pierwszego pakietu zostaly odebrane, czekaj na zakonczenie przetwarzania
			if mod_processed = '1' then
				if mod_count = "10" then
					main_fsb_next <= main_fsb_send;
				else
					main_fsb_next <= main_fsb_busy2;
				end if;
			else
				trans_mod <= "10";
				start_processing <= '1'; -- zacznij przetwarzanie
				main_fsb_next <= main_fsb_proc2;
			end if;
			
		when main_fsb_busy2 => -- jesli dane przetworzone, rozpocznij przetwarzanie nastepnych
			if mod_passed3_reg = "11" then
				status_0bit <= '1';
				main_fsb_next <= main_fsb_proc3;
			elsif mod_passed3_reg = "10" then
				status_0bit <= '0';
				main_fsb_next <= main_fsb_send;
			else
				main_fsb_next <= main_fsb_busy2;
			end if;
			
		when main_fsb_proc3 => -- jesli dane z pierwszego pakietu zostaly odebrane, czekaj na zakonczenie przetwarzania
			if mod_processed = '1' then
				main_fsb_next <= main_fsb_send;
			else
				trans_mod <= "11";
				start_processing <= '1'; -- zacznij przetwarzanie
				main_fsb_next <= main_fsb_proc3;
			end if;
			
		when main_fsb_send => -- jesli buforout gotowy, rozpocznij wysylanie
				main_fsb_next <= main_fsb_idle;
				bufout_send <= '1'; -- zacznij przesylanie
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
		
	process (proc_fsb_reg, start_processing, calc_done, bufout_done, equal_crc, status_0bit)
	begin
	calc_start <= '0';
	bufout_trans <= '0';
	mod_processed <= '0';
	status_1bit <= '0';
	
		case proc_fsb_reg is
			when proc_fsb_idle =>  
				if start_processing = '0' then 
					proc_fsb_next <= proc_fsb_idle;
				elsif status_0bit = '1' then
					proc_fsb_next <= proc_fsb_transmit;
				else						-- jesli jest rozkaz zacznij przetwarzac
					proc_fsb_next <= proc_fsb_calc;
					calc_start <= '1'; 
				end if;
				
			when proc_fsb_calc =>			-- przelicz CRC modulu
				if calc_done = '0' then
					proc_fsb_next <= proc_fsb_calc;
				else
					proc_fsb_next <= proc_fsb_comp;
				end if;
				
			when proc_fsb_comp =>	
					status_1bit <= equal_crc;
					proc_fsb_next <= proc_fsb_transmit;
					
			when proc_fsb_transmit =>
				if bufout_done = '0' then
					proc_fsb_next <= proc_fsb_transmit;
					bufout_trans <= '1';
				else
					proc_fsb_next <= proc_fsb_idle;
					mod_processed <= '1';
				end if;
			end case;

	end process;


-----------------

	process (clk, rst)
	begin
		if rst = '1' then
			status_0bit_reg <= '0';	
		elsif rising_edge(clk) then
			status_0bit_reg <= status_0bit;
		end if;
	end process;

	process (clk, rst)
	begin
		if rst = '1' then
			status_1bit_reg <= '0';	
		elsif rising_edge(clk) then
			status_1bit_reg <= status_1bit;
		end if;
	end process;

	process (clk, rst)
	begin
		if rst = '1' then
			status_index <= "00";	
		elsif rising_edge(clk) then
			status_index <= ( status_0bit_reg & status_1bit_reg );
		end if;
	end process;



end rtl;
