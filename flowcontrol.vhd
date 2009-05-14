--------------------------------
-- File		:	flowcontrol2.vhd
-- Version	:	0.1
-- Date		:	03.05.2009
-- Desc		:	Bit flow controler
-- Author	:	Sebastian �uczak
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
			--@@ TODO: nale�y doda� sygna�y z uk�adu steruj�cego
			
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
			-- enable g��wnego demultipleksera
		enable_MAINdmux : out std_logic_vector ( 1 downto 0 );
			-- enable demultimpleksera nag��wka na liczb� modu��w i d�ugo�� modu��w
		enable_HEADdmux :  out std_logic_vector ( 0 downto 0 );
			-- enable demultipleksera d�ugo�ci modu��w
		enable_RDMdmux  : out std_logic_vector ( 1 downto 0 );
			-- enable demultipleksera danych na modu�y
		enable_PACKdmux : out std_logic_vector ( 1 downto 0 );
			-- enable demultipleksera modu��w na dane i crc
		enable_MODdmux0 : out std_logic_vector ( 0 downto 0 );	
		enable_MODdmux1 : out std_logic_vector ( 0 downto 0 );	
		enable_MODdmux2 : out std_logic_vector ( 0 downto 0 );	
		enable_MODdmux3 : out std_logic_vector ( 0 downto 0 );	
		ena_RLM, ena_RDM0, ena_RDM1, ena_RDM2, ena_RDM3, ena_CRC0, ena_CRC1, ena_CRC2, ena_CRC3, ena_DATA0, ena_DATA1, ena_DATA2, ena_DATA3 : out std_logic
		
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
signal enaRLM, enaRDM0, enaRDM1, enaRDM2, enaRDM3, enaCRC0, enaCRC1, enaCRC2, enaCRC3, enaDATA0, enaDATA1, enaDATA2, enaDATA3 : std_logic;

begin
process (clk)
		variable   cnt	  : integer range MIN_COUNT to MAX_COUNT;
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
				else 
					flow_fsm_next <= flow_sop;
				end if; 	
			when flow_sop => 
				if count = 8 then
					flow_fsm_next <= flow_header_rlm;
				else 
					flow_fsm_next <= flow_sop;	
				end if;
			when flow_header_rlm =>
				if count = 16 then
					flow_fsm_next <= flow_header_rdm0;
				else 
					flow_fsm_next <= flow_header_rlm;			
				end if;
			when flow_header_rdm0 =>
				if count = 32 then
					flow_fsm_next <= flow_header_rdm1;
				else 
					flow_fsm_next <= flow_header_rdm0;
				end if;
			when flow_header_rdm1 =>
				if count = 48 then
					flow_fsm_next <= flow_header_rdm2;				
				else 
					flow_fsm_next <= flow_header_rdm1;
				end if;
			when flow_header_rdm2 =>
				if count = 64 then
					flow_fsm_next <= flow_header_rdm3;
				else 
					flow_fsm_next <= flow_header_rdm2;
				end if;
			when flow_header_rdm3 =>
				if count = 80 then
					flow_fsm_next <= flow_eoh;
				else 
					flow_fsm_next <= flow_header_rdm3;
				end if; 	
			when flow_eoh =>
				if count = 88 then
					flow_fsm_next <= flow_crc0;
				else 
					flow_fsm_next <= flow_eoh;
				end if; 	
			when flow_crc0 =>
				if count = 104 then
					flow_fsm_next <= flow_data0;
				else 
					flow_fsm_next <= flow_crc0;
				end if; 	
			when flow_data0 => 
				if count = 8296 then
					flow_fsm_next <= flow_crc1;
				else 
					flow_fsm_next <= flow_data0;
				end if; 	
			when flow_crc1 =>
				if count = 8312 then
					flow_fsm_next <= flow_data1;
				else 
					flow_fsm_next <= flow_crc1;
				end if; 	
			when flow_data1 =>
				if count = 16504  then
					flow_fsm_next <= flow_crc2;
				else 
					flow_fsm_next <= flow_data1;
				end if; 	
			when flow_crc2 =>
				if count = 16520 then
					flow_fsm_next <= flow_data2;
				else 
					flow_fsm_next <= flow_crc2;
				end if; 	
			when flow_data2 =>
				if count = 24712 then
					flow_fsm_next <= flow_crc3;
				else 
					flow_fsm_next <= flow_data2;
				end if; 	
			when flow_crc3 =>
				if count = 24728 then
					flow_fsm_next <= flow_data3;
				else 
					flow_fsm_next <= flow_crc3;
				end if; 	
			when flow_data3 =>
				if count = 32920 then
					flow_fsm_next <= flow_eop;
				else 
					flow_fsm_next <= flow_data3;
				end if; 	
			when flow_eop =>
				if count = 32936 then
					flow_fsm_next <= flow_idle;
				else 
					flow_fsm_next <= flow_eop;
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
				enaRLM <= '0';
				enaRDM0 <= '0';
				enaRDM1 <= '0';
				enaRDM2 <= '0';
				enaRDM3 <= '0';
				enaCRC0 <= '0';
				enaCRC1 <= '0';
				enaCRC2 <= '0';
				enaCRC3 <= '0';
				enaDATA0 <= '0';
				enaDATA1 <= '0';
				enaDATA2 <= '0';
				enaDATA3 <= '0';
				
		when flow_header_rlm => 
				enable_MAINdmux <= "01";
				enaRLM <= '1';
		when flow_header_rdm0 => 
				enable_HEADdmux <= "1";
				enable_RDMdmux <= "00";
				enaRDM0 <= '1';
		when flow_header_rdm1 => 
				enable_RDMdmux <= "01";
				enaRDM1 <= '1';
		when flow_header_rdm2 => 
				enable_RDMdmux <= "10";
				enaRDM2 <= '1';
		when flow_header_rdm3 => 	
				enable_RDMdmux <= "11";
				enaRDM3 <= '1';
		when flow_eoh => 
				enable_MAINdmux <= "00";
		when flow_crc0 => 
				enable_MAINdmux <= "10";
				enable_PACKdmux <= "00";
				enable_MODdmux0 <= "0";
				enaCRC0 <= '1';
		when flow_data0 => 
				enable_MODdmux0 <= "1";
				enaDATA0 <= '1';
		when flow_crc1 => 
				enable_PACKdmux <= "01";
				enable_MODdmux1 <= "0";	
				enaCRC1 <= '1';
		when flow_data1 => 
				enable_MODdmux1 <= "1";	
				enaDATA1 <= '1';
		when flow_crc2 => 	
				enable_PACKdmux <= "10";
				enable_MODdmux2 <= "0";	
				enaCRC2 <= '1';
		when flow_data2 => 
				enable_MODdmux2 <= "1";
				enaDATA2 <= '1';
		when flow_crc3 => 
				enable_PACKdmux <= "11";
				enable_MODdmux3 <= "0";		
				enaCRC3 <= '1';
		when flow_data3 => 
				enable_MODdmux3 <= "1";	
				enaDATA3 <= '1';
		when flow_eop =>
				enable_MAINdmux <= "00";
				
				
	end case;
						
end process;	


			ena_RLM     <= enaRLM;
			ena_RDM0    <= enaRDM0; 
			ena_RDM1	<= enaRDM1; 
			ena_RDM2	<= enaRDM2; 
			ena_RDM3	<= enaRDM3; 
			ena_CRC0	<= enaCRC0; 
			ena_CRC1	<= enaCRC1; 
			ena_CRC2	<= enaCRC2; 
			ena_CRC3	<= enaCRC3; 
			ena_DATA0   <= enaDATA0; 
			ena_DATA1	<= enaDATA1; 
			ena_DATA2	<= enaDATA2; 
			ena_DATA3	<= enaDATA3; 
end data_flow;

