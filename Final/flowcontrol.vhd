--------------------------------
-- File		:	flowcontrol.vhd
-- Version	:	1.0
-- Date		:	03.05.2009
-- Desc		:	Bit flow controler
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


entity flowcontrol is

	port
	(
-- INPUTS
		
		clk 			: in std_logic;
		rst				: in std_logic;
		flow_in			: in std_logic;
		data			: in std_logic_vector ( 7 downto 0 );
		ml_reg			: in std_logic_vector ( 15 downto 0 );
		
		
		
--OUTPUTS
	-- enable g³ównego demultipleksera
		enable_MAINdmux : out std_logic_vector ( 0 downto 0 );
	-- enable demultimpleksera nag³ówka na liczbê modu³ów i d³ugoœæ modu³ów
		enable_HEADdmux :  out std_logic_vector ( 0 downto 0 );
	-- enable demultipleksera d³ugoœci modu³ów
		enable_RDMdmux  : out std_logic_vector ( 1 downto 0 );
	-- enable multilpeksera d³ugoœci modu³ów
		enable_RDMmux 	: out std_logic_vector ( 1 downto 0 );
	-- enable demultipleksera danych na modu³y
		enable_PACKdmux : out std_logic_vector ( 1 downto 0 );
	-- enable demultipleksera modu³ów na dane i crc
		enable_MODdmux0 : out std_logic_vector ( 0 downto 0 );	
		enable_MODdmux1 : out std_logic_vector ( 0 downto 0 );	
		enable_MODdmux2 : out std_logic_vector ( 0 downto 0 );	
		enable_MODdmux3 : out std_logic_vector ( 0 downto 0 );	
		
		ena_RLM, ena_RDM0, ena_RDM1, ena_RDM2, ena_RDM3, ena_CRC0, ena_CRC1, ena_CRC2, ena_CRC3, wen_DATA0, wen_DATA1, wen_DATA2, wen_DATA3 : out std_logic;
		
		addr_flow_cnt_clr : out std_logic;
		addr_flow_cnt_ena : out std_logic;
		trans_mod 		  : out  std_logic_vector ( 1 downto 0 );
		
		mod_pass0	: out std_logic;
		mod_pass1	: out std_logic;
		mod_pass2	: out std_logic;
		mod_pass3	: out std_logic;
		mod_passed0 : out std_logic_vector ( 1 downto 0 );
		mod_passed1 : out std_logic_vector ( 1 downto 0 );
		mod_passed2 : out std_logic_vector ( 1 downto 0 );
		mod_passed3 : out std_logic_vector ( 1 downto 0 )	
		
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
	flow_eom0,
	flow_crc1,
	flow_data1,
	flow_eom1,
	flow_crc2,
	flow_data2,
	flow_eom2,
	flow_crc3,
	flow_data3,
	flow_eom3,
	flow_eop
	);
	
signal flow_fsb_reg, flow_fsb_next	: FLOW_FSM_STATE_TYPE;



-- Licznik jako rejestr - sygna³y
signal cnt_reg, cnt_next : std_logic_vector ( 10 downto 0 );	
signal cnt_ena, cnt_clr : std_logic;

begin
-- Licznik jako rejestr 11bit 
	process (clk, rst)
	begin
		if rst = '1'  then
			cnt_reg <= ( others => '0' );
		elsif rising_edge(clk) then
			cnt_reg <= cnt_next;
		end if;
	end process;


	process (cnt_reg, cnt_clr, cnt_ena)
	begin
		if cnt_clr = '1' then
			cnt_next <= ( others => '0' );
		elsif cnt_ena = '1' then
			cnt_next <= cnt_reg + "1";
		else
			cnt_next <= cnt_reg;
		end if;
	end process;			  
	
	

--------------------------------------------------------------
process (clk, rst)
	begin
		if rst = '1' then
			flow_fsb_reg <= flow_idle;	
		elsif rising_edge(clk) then
			flow_fsb_reg <= flow_fsb_next;
		end if;
end process;

	-- Funkcja przejsc-wyjsc
process(flow_fsb_reg, flow_in, cnt_reg, data)
	begin
		cnt_clr <= '0';
		cnt_ena <= '1';

		case flow_fsb_reg is
			when flow_idle =>			
				cnt_clr <= '1';
				if flow_in = '0' then 	
					flow_fsb_next <= flow_idle;				
				else 
					if data = "00000010" then
						flow_fsb_next <= flow_sop;
					else
						flow_fsb_next <= flow_idle;
					end if;
				end if; 
					
			when flow_sop => 
			-- 8bit						
					cnt_clr <= '1';
					flow_fsb_next <= flow_header_rlm;

				
			when flow_header_rlm =>
					cnt_clr <= '1';
					flow_fsb_next <= flow_header_rdm0;
				
			when flow_header_rdm0 =>
					cnt_ena <= '1';
				if cnt_reg = 1 then -- 16bit
					cnt_clr <= '1';
					flow_fsb_next <= flow_header_rdm1;
				else 
					flow_fsb_next <= flow_header_rdm0;
				end if;
				
			when flow_header_rdm1 =>
					cnt_ena <= '1';
				if cnt_reg = 1 then -- 16bit
					cnt_clr <= '1';
					flow_fsb_next <= flow_header_rdm2;				
				else 
					flow_fsb_next <= flow_header_rdm1;
				end if;
				
			when flow_header_rdm2 =>
					cnt_ena <= '1';
				if cnt_reg = 1 then -- 16bit
					cnt_clr <= '1';
					flow_fsb_next <= flow_header_rdm3;
				else 
					flow_fsb_next <= flow_header_rdm2;
				end if;
				
			when flow_header_rdm3 =>
					cnt_ena <= '1';
				if cnt_reg = 1 then -- 16bit
					cnt_clr <= '1';
					flow_fsb_next <= flow_eoh;
				else 
					flow_fsb_next <= flow_header_rdm3;
				end if; 	
				
			when flow_eoh =>
							-- 8bit
					if data = "00000110" then
						cnt_clr <= '1';
						flow_fsb_next <= flow_crc0;	
					else
							flow_fsb_next <= flow_idle;
					end if;

			when flow_crc0 =>
					cnt_ena <= '1';
				if cnt_reg = 1 then -- 16bit
					cnt_clr <= '1';
					flow_fsb_next <= flow_data0;
				else 
					flow_fsb_next <= flow_crc0;
				end if; 
		
			when flow_data0 => 
					cnt_ena <= '1';
				if data = "00000011" then	
					flow_fsb_next <= flow_eom0;
				else 
					if cnt_reg = 1024 then --8296bit
						flow_fsb_next <= flow_idle;
					else 
						flow_fsb_next <= flow_data0;
					end if;
				end if; 
				
			when flow_eom0 => -- 16bit
					cnt_clr <= '1';
					flow_fsb_next <= flow_crc1;
					
			when flow_crc1 =>
					cnt_ena <= '1';
				if cnt_reg = 1 then -- 16bit
					cnt_clr <= '1';
					flow_fsb_next <= flow_data1;
				else 
					flow_fsb_next <= flow_crc1;
				end if; 	
				
			when flow_data1 =>
					cnt_ena <= '1';
				if data = "00000011" then		
					flow_fsb_next <= flow_eom1;
				else 
					if cnt_reg = 1024  then --16504bit
						flow_fsb_next <= flow_idle;
					else
						flow_fsb_next <= flow_data1;
					end if;
				end if; 	
				
			when flow_eom1 => -- 16bit
					cnt_clr <= '1';
					flow_fsb_next <= flow_crc2;
					
			when flow_crc2 =>
					cnt_ena <= '1';
				if cnt_reg = 1 then -- 16bit
					cnt_clr <= '1';
					flow_fsb_next <= flow_data2;
				else 
					flow_fsb_next <= flow_crc2;
				end if; 	
				
			when flow_data2 =>
					cnt_ena <= '1';
				if data = "00000011" then		
					flow_fsb_next <= flow_eom2;
				else 
					if cnt_reg = 1024 then --24712bit
						flow_fsb_next <= flow_idle;
					else
						flow_fsb_next <= flow_data2;
					end if;
				end if; 	
				
			when flow_eom2 => -- 16bit
					cnt_clr <= '1';
					flow_fsb_next <= flow_crc3;
					
			when flow_crc3 => -- 16bit
					cnt_ena <= '1';
				if cnt_reg = 1 then --24728bit
					cnt_clr <= '1';
					flow_fsb_next <= flow_data3;
				else 
					flow_fsb_next <= flow_crc3;
				end if; 	
				
			when flow_data3 => 
					cnt_ena <= '1';
				if data = "00000011" then
					flow_fsb_next <= flow_eom3;
				else 
					if cnt_reg = 1024 then --32920bit
						flow_fsb_next <= flow_idle;
					else
						flow_fsb_next <= flow_data3;
					end if;
				end if; 	
				
			when flow_eom3 => -- 16bit
					cnt_clr <= '1';
					flow_fsb_next <= flow_eop;
					
			when flow_eop => -- 16bit
				if data = "00000100" then
					flow_fsb_next <= flow_idle;
				else 
					flow_fsb_next <= flow_eop;
				end if; 
		end case;
	end process;

	process(flow_fsb_reg, cnt_reg, ml_reg)
		begin
					
			enable_MAINdmux <= (others => '0');
			enable_HEADdmux <= (others => '0');
			enable_RDMdmux <= (others => '0');
			enable_RDMmux <= (others => '0');
			enable_PACKdmux <= (others => '0');
			enable_MODdmux0 <= (others => '0');
			enable_MODdmux1 <= (others => '0');
			enable_MODdmux2 <= (others => '0');
			enable_MODdmux3 <= (others => '0');
			
			ena_RLM <= '0';
			ena_RDM0 <= '0';
			ena_RDM1 <= '0';
			ena_RDM2 <= '0';
			ena_RDM3 <= '0';
			ena_CRC0 <= '0';
			ena_CRC1 <= '0';
			ena_CRC2 <= '0';
			ena_CRC3 <= '0';
			
			wen_DATA0 <= '0';
			wen_DATA1 <= '0';
			wen_DATA2 <= '0';
			wen_DATA3 <= '0';
			
			addr_flow_cnt_clr <= '0';
			addr_flow_cnt_ena <= '0';
			trans_mod <= "00";
			
			mod_pass0 <= '0';
			mod_pass1 <= '0';
			mod_pass2 <= '0';
			mod_pass3 <= '0';
			mod_passed0 <= "00";
			mod_passed1 <= "00";
			mod_passed2 <= "00";
			mod_passed3 <= "00";
					
		case flow_fsb_reg is
		
			when flow_idle => 
					
			when flow_sop => 
					
			when flow_header_rlm => 
					enable_MAINdmux <= "0";
					ena_RLM <= '1';
					
			when flow_header_rdm0 => 
					enable_MAINdmux <= "0";
					enable_HEADdmux <= "1";
					enable_RDMdmux <= "00";
					ena_RDM0 <= '1';
					
			when flow_header_rdm1 => 
					enable_MAINdmux <= "0";
					enable_HEADdmux <= "1";
					enable_RDMdmux <= "01";
					ena_RDM1 <= '1';
					
			when flow_header_rdm2 => 
					enable_MAINdmux <= "0";
					enable_HEADdmux <= "1";
					enable_RDMdmux <= "10";
					ena_RDM2 <= '1';
					
			when flow_header_rdm3 => 	
					enable_MAINdmux <= "0";
					enable_HEADdmux <= "1";
					enable_RDMdmux <= "11";
					ena_RDM3 <= '1';
					
			when flow_eoh => 
							
			when flow_crc0 => 
					enable_MAINdmux <= "1";
					enable_PACKdmux <= "00";
					enable_MODdmux0 <= "0";
					ena_CRC0 <= '1';
					trans_mod <= "00";
					addr_flow_cnt_clr <= '1';

			when flow_data0 => 
					enable_MAINdmux <= "1";
					enable_PACKdmux <= "00";
					enable_MODdmux0 <= "1";
					wen_DATA0 <= '1';
					trans_mod <= "00";
					addr_flow_cnt_ena <= '1';								
					
			when flow_eom0 =>
					enable_RDMmux <= "00";
					mod_pass0 <= '1';
					
					if ml_reg = (cnt_reg - "1" ) then
						mod_passed0 <= "11";
					else
						mod_passed0 <= "10";
					end if;
			
			when flow_crc1 => 
					enable_MAINdmux <= "1";
					enable_PACKdmux <= "01";
					enable_MODdmux1 <= "0";
					ena_CRC1 <= '1';
					trans_mod <= "01";
					addr_flow_cnt_clr <= '1';
					
			when flow_data1 => 
					enable_MAINdmux <= "1";
					enable_PACKdmux <= "01";
					enable_MODdmux1 <= "1";	
					wen_DATA1 <= '1';
					trans_mod <= "01";
					addr_flow_cnt_ena <= '1';
					
			when flow_eom1 =>
					enable_RDMmux <= "01";
					mod_pass1 <= '1';
				
					if ml_reg = (cnt_reg - "1" ) then
						mod_passed1 <= "11";
					else
						mod_passed1 <= "10";
					end if;
							
			when flow_crc2 => 	
					enable_MAINdmux <= "1";
					enable_PACKdmux <= "10";
					enable_MODdmux2 <= "0";
					ena_CRC2 <= '1';
					trans_mod <= "10";
					addr_flow_cnt_clr <= '1';
					
			when flow_data2 => 
					enable_MAINdmux <= "1";
					enable_PACKdmux <= "10";
					enable_MODdmux2 <= "1";	
					wen_DATA2 <= '1';
					trans_mod <= "10";
					addr_flow_cnt_ena <= '1';
					
			when flow_eom2 =>
					enable_RDMmux <= "10";
					mod_pass2 <= '1';
				
					if ml_reg = (cnt_reg - "1" ) then
						mod_passed2 <= "11";
					else
						mod_passed2 <= "10";
					end if;
							
			when flow_crc3 => 
					
					enable_MAINdmux <= "1";
					enable_PACKdmux <= "11";
					enable_MODdmux3 <= "0";
					ena_CRC3 <= '1';
					trans_mod <= "11";
					addr_flow_cnt_clr <= '1';
					
			when flow_data3 => 
					enable_MAINdmux <= "1";
					enable_PACKdmux <= "11";
					enable_MODdmux3 <= "1";	
					wen_DATA3 <= '1';
					trans_mod <= "11";
					addr_flow_cnt_ena <= '1';
					
			when flow_eom3 =>
					enable_RDMmux <= "11";
					mod_pass3 <= '1';

					if ml_reg = (cnt_reg - "1" ) then
						mod_passed3 <= "11";
					else
						mod_passed3  <= "10";
					end if;
					
			when flow_eop =>						
		end case;
	end process;
	
end data_flow;

