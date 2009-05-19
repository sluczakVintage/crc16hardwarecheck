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


entity flowcontrol is

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

signal enaRLM, enaRDM0, enaRDM1, enaRDM2, enaRDM3, enaCRC0, enaCRC1, enaCRC2, enaCRC3, enaDATA0, enaDATA1, enaDATA2, enaDATA3 : std_logic;

-- Licznik jako rejestr - sygna�y
signal cnt_reg, cnt_next: std_logic_vector (12 downto 0);	

begin
-- Licznik jako rejestr 13bit
	process (clk, rst)
	begin
		if rst = '1' then
			cnt_reg <= (others => '0');	
		elsif rising_edge(clk) then
			cnt_reg <= cnt_next;
		end if;
	end process;

	process (cnt_reg, flow_in)
	begin
		if flow_in = '0' then
			cnt_next <= (others => '0');
		else
			cnt_next <= cnt_reg + "1";
		end if;
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
	process(flow_fsm_reg, flow_in, cnt_reg)
	begin
		case flow_fsm_reg is
			when flow_idle =>			
				if flow_in = '0' then 		
					flow_fsm_next <= flow_idle;				
				else 
					flow_fsm_next <= flow_sop;
				end if; 	
			when flow_sop => 
				if cnt_reg = 1 then -- 8bit
					flow_fsm_next <= flow_header_rlm;
				else 
					flow_fsm_next <= flow_sop;	
				end if;
			when flow_header_rlm =>
				if cnt_reg = 2 then -- 16bit
					flow_fsm_next <= flow_header_rdm0;
				else 
					flow_fsm_next <= flow_header_rlm;			
				end if;
			when flow_header_rdm0 =>
				if cnt_reg = 4 then -- 32bit
					flow_fsm_next <= flow_header_rdm1;
				else 
					flow_fsm_next <= flow_header_rdm0;
				end if;
			when flow_header_rdm1 =>
				if cnt_reg = 6 then -- 48bit
					flow_fsm_next <= flow_header_rdm2;				
				else 
					flow_fsm_next <= flow_header_rdm1;
				end if;
			when flow_header_rdm2 =>
				if cnt_reg = 8 then -- 64bit
					flow_fsm_next <= flow_header_rdm3;
				else 
					flow_fsm_next <= flow_header_rdm2;
				end if;
			when flow_header_rdm3 =>
				if cnt_reg = 10 then --80bit
					flow_fsm_next <= flow_eoh;
				else 
					flow_fsm_next <= flow_header_rdm3;
				end if; 	
			when flow_eoh =>
				if cnt_reg = 11 then --88bit
					flow_fsm_next <= flow_crc0;
				else 
					flow_fsm_next <= flow_eoh;
				end if; 	
			when flow_crc0 =>
				if cnt_reg = 13 then --104bit
					flow_fsm_next <= flow_data0;
				else 
					flow_fsm_next <= flow_crc0;
				end if; 	
			when flow_data0 => 
				if cnt_reg = 1037 then --8296bit
					flow_fsm_next <= flow_crc1;
				else 
					flow_fsm_next <= flow_data0;
				end if; 	
			when flow_crc1 =>
				if cnt_reg = 1039 then --8312bit
					flow_fsm_next <= flow_data1;
				else 
					flow_fsm_next <= flow_crc1;
				end if; 	
			when flow_data1 =>
				if cnt_reg = 2063  then --16504bit
					flow_fsm_next <= flow_crc2;
				else 
					flow_fsm_next <= flow_data1;
				end if; 	
			when flow_crc2 =>
				if cnt_reg = 2065 then --16520bit
					flow_fsm_next <= flow_data2;
				else 
					flow_fsm_next <= flow_crc2;
				end if; 	
			when flow_data2 =>
				if cnt_reg = 3089 then --24712bit
					flow_fsm_next <= flow_crc3;
				else 
					flow_fsm_next <= flow_data2;
				end if; 	
			when flow_crc3 =>
				if cnt_reg = 3091 then --24728bit
					flow_fsm_next <= flow_data3;
				else 
					flow_fsm_next <= flow_crc3;
				end if; 	
			when flow_data3 =>
				if cnt_reg = 4115 then --32920bit
					flow_fsm_next <= flow_eop;
				else 
					flow_fsm_next <= flow_data3;
				end if; 	
			when flow_eop =>
				if cnt_reg = 4117 then --32936bit
					flow_fsm_next <= flow_idle;
				else 
					flow_fsm_next <= flow_eop;
				end if; 		
		end case;
	end process;

	process(flow_fsm_reg)
	begin
				
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
				
		case flow_fsm_reg is
		when flow_idle => 
				
		when flow_sop => 
			--	enable_MAINdmux <= "00";
		when flow_header_rlm => 
				enable_MAINdmux <= "01";
				enaRLM <= '1';
		when flow_header_rdm0 => 
				enable_MAINdmux <= "01";
				enable_HEADdmux <= "1";
				enable_RDMdmux <= "00";
				enaRDM0 <= '1';
		when flow_header_rdm1 => 
				enable_MAINdmux <= "01";
				enable_HEADdmux <= "1";
				enable_RDMdmux <= "01";
				enaRDM1 <= '1';
		when flow_header_rdm2 => 
				enable_MAINdmux <= "01";
				enable_HEADdmux <= "1";
				enable_RDMdmux <= "10";
				enaRDM2 <= '1';
		when flow_header_rdm3 => 	
				enable_MAINdmux <= "01";
				enable_HEADdmux <= "1";
				enable_RDMdmux <= "11";
				enaRDM3 <= '1';
		when flow_eoh => 
			--	enable_MAINdmux <= "00";
		when flow_crc0 => 
				enable_MAINdmux <= "10";
				enable_PACKdmux <= "00";
				enable_MODdmux0 <= "0";
				enaCRC0 <= '1';
		when flow_data0 => 
				enable_MODdmux0 <= "1";
				enaDATA0 <= '1';
		when flow_crc1 => 
				enable_MAINdmux <= "10";
				enable_PACKdmux <= "01";
				enable_MODdmux1 <= "0";
				enaCRC1 <= '1';
		when flow_data1 => 
				enable_MAINdmux <= "10";
				enable_PACKdmux <= "01";
				enable_MODdmux1 <= "1";	
				enaDATA1 <= '1';
		when flow_crc2 => 	
				enable_MAINdmux <= "10";
				enable_PACKdmux <= "10";
				enable_MODdmux2 <= "0";
				enaCRC2 <= '1';
		when flow_data2 => 
				enable_MAINdmux <= "10";
				enable_PACKdmux <= "10";
				enable_MODdmux2 <= "1";	
				enaDATA2 <= '1';
		when flow_crc3 => 
				enable_MAINdmux <= "10";
				enable_PACKdmux <= "11";
				enable_MODdmux3 <= "0";
				enaCRC3 <= '1';
		when flow_data3 => 
				enable_MAINdmux <= "10";
				enable_PACKdmux <= "11";
				enable_MODdmux3 <= "1";	
				enaDATA3 <= '1';
		when flow_eop =>
				--enable_MAINdmux <= "00";
				
				
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

