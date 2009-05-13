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
use ieee.numeric_std.all;


entity flowcontrol is

	generic
	(
		MIN_COUNT : natural := 0;
		MAX_COUNT : natural := 32944
	);

	port
	(
		-- INPUTS
			--@@ TODO: nale¿y dodaæ sygna³y z uk³adu steruj¹cego
			
		clk 			: in std_logic;
		rst				: in std_logic;
		flow_in			: in std_logic;
		-----------
		-- 00 - idle
		-- 01 - enable
		-- 11 - end transmission
		-----------
		
		
		--OUTPUTS
		flow_out			: out std_logic;
			-- enable g³ównego demultipleksera
		enable_MAINdmux : out std_logic_vector ( 1 downto 0 );
			-- enable demultimpleksera nag³ówka na liczbê modu³ów i d³ugoœæ modu³ów
		enable_HEADdmux :  out std_logic_vector ( 0 downto 0 );
			-- enable demultipleksera d³ugoœci modu³ów
		enable_RDMdmux  : out std_logic_vector ( 1 downto 0 );
			-- enable demultipleksera danych na modu³y
		enable_PACKdmux : out std_logic_vector ( 1 downto 0 );
			-- enable demultipleksera modu³ów na dane i crc
		enable_MODdmux0 : out std_logic_vector ( 0 downto 0 );	
		enable_MODdmux1 : out std_logic_vector ( 0 downto 0 );	
		enable_MODdmux2 : out std_logic_vector ( 0 downto 0 );	
		enable_MODdmux3 : out std_logic_vector ( 0 downto 0 )	
		
	);
end flowcontrol;

architecture data_flow of flowcontrol is

type FLOW_FSM_STATE_TYPE is (
	flow_idle,
	flow_sop,
	flow_header_rlm,
	flow_header_rdm0,
	flow_header_rdm1,
	flow_header_rdm2,
	flow_header_rdm3,
	flow_eoh,
	flow_crc0,
	flow_data0,
	flow_crc1,
	flow_data1,
	flow_crc2,
	flow_data2,
	flow_crc3,
	flow_data3,
	flow_eop
	);
	
signal flow_fsm_reg, flow_fsm_next	:FLOW_FSM_STATE_TYPE;


signal count		  : integer range MIN_COUNT to MAX_COUNT;


begin
process (clk)
		variable   cnt		   : integer range MIN_COUNT to MAX_COUNT;
	begin
		if (rising_edge(clk)) then

			if rst = '1' then
				-- Reset the counter to 0
				cnt := 0;
			elsif  flow_in = '0' then
				-- Increment the counter if counting is enabled			   
				cnt := 0;

			elsif flow_in = '1' then
				-- Increment the counter if counting is enabled			   
				cnt := cnt + 8;

			end if;
		end if;

		-- Output the current count
		count <= cnt;
	end process;

	

--------------------------------------------------------------
process (clk, rst)
	begin
		if rst = '0' then
			flow_fsm_reg <= flow_idle;	
		elsif rising_edge(clk) then
			flow_fsm_reg <= flow_fsm_next;
		end if;
	end process;

	-- Funkcja przejsc-wyjsc
	process(flow_fsm_reg, flow_in, count)
	begin
		case flow_fsm_reg is
			when flow_idle =>			
				if flow_in = '0' then 		
					flow_fsm_next <= flow_idle;				
				else flow_fsm_next <= flow_sop;
				end if; 	
			when flow_sop => 
				if count = 8 then
					flow_fsm_next <= flow_header_rlm;
				end if;
			when flow_header_rlm =>
				if count = 16 then
					flow_fsm_next <= flow_header_rdm0;				
				end if;
			when flow_header_rdm0 =>
				if count = 32 then
					flow_fsm_next <= flow_header_rdm1;
				end if;
			when flow_header_rdm1 =>
				if count = 48 then
					flow_fsm_next <= flow_header_rdm2;				
				end if;
			when flow_header_rdm2 =>
				if count = 64 then
					flow_fsm_next <= flow_header_rdm3;
				end if;
			when flow_header_rdm3 =>
				if count = 80 then
					flow_fsm_next <= flow_eoh;
				end if; 	
			when flow_eoh =>
				if count = 88 then
					flow_fsm_next <= flow_crc0;
				end if; 	
			when flow_crc0 =>
				if count = 104 then
					flow_fsm_next <= flow_data0;
				end if; 	
			when flow_data0 => 
				if count = 8296 then
					flow_fsm_next <= flow_crc1;
				end if; 	
			when flow_crc1 =>
				if count = 8312 then
					flow_fsm_next <= flow_data1;
				end if; 	
			when flow_data1 =>
				if count = 16504  then
					flow_fsm_next <= flow_crc2;
				end if; 	
			when flow_crc2 =>
				if count = 16520 then
					flow_fsm_next <= flow_data2;
				end if; 	
			when flow_data2 =>
				if count = 24712 then
					flow_fsm_next <= flow_crc3;
				end if; 	
			when flow_crc3 =>
				if count = 24728 then
					flow_fsm_next <= flow_data3;
				end if; 	
			when flow_data3 =>
				if count = 32920 then
					flow_fsm_next <= flow_eop;
				end if; 	
			when flow_eop =>
				if count = 32936 then
					flow_fsm_next <= flow_idle;
				end if; 		
		end case;
	end process;

	process(flow_fsm_reg)
	begin
				
		case flow_fsm_reg is
		when flow_idle => 
				
		when flow_sop => 
				enable_MAINdmux <= (others => '0');
				enable_HEADdmux <= (others => '0');
				enable_RDMdmux <= (others => '0');
				enable_PACKdmux <= (others => '0');
				enable_MODdmux0 <= (others => '0');
				enable_MODdmux1 <= (others => '0');
				enable_MODdmux2 <= (others => '0');
				enable_MODdmux3 <= (others => '0');
				
		when flow_header_rlm => 
				enable_MAINdmux <= "01";
		when flow_header_rdm0 => 
				enable_HEADdmux <= "1";
				enable_RDMdmux <= "00";
		when flow_header_rdm1 => 
				enable_RDMdmux <= "01";
		when flow_header_rdm2 => 
				enable_RDMdmux <= "10";
		when flow_header_rdm3 => 	
				enable_RDMdmux <= "11";
		when flow_eoh => 
				enable_MAINdmux <= "00";
		when flow_crc0 => 
				enable_MAINdmux <= "10";
			enable_PACKdmux <= "00";
			enable_MODdmux0 <= "0";
		when flow_data0 => 
			enable_MODdmux0 <= "1";
		when flow_crc1 => 
			enable_PACKdmux <= "01";
			enable_MODdmux1 <= "0";	
		when flow_data1 => 
			enable_MODdmux1 <= "1";	
		when flow_crc2 => 	
			enable_PACKdmux <= "10";
			enable_MODdmux2 <= "0";	
		when flow_data2 => 
			enable_MODdmux2 <= "1";
		when flow_crc3 => 
			enable_PACKdmux <= "11";
			enable_MODdmux3 <= "0";		
		when flow_data3 => 
			enable_MODdmux3 <= "1";	
		when flow_eop =>
			enable_MAINdmux <= "00";
				
	end case;
						
end process;	
end data_flow;

