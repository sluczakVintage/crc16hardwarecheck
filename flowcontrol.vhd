--------------------------------
-- File		:	flowcontrol.vhd
-- Version	:	0.1
-- Date		:	03.05.2009
-- Desc		:	Bit flow controler
-- Author	:	Sebastian £uczak
-- Author	:	Maciej Nowak 
-- Based on	:	/
--------------------------------

---------------------------
--
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;


entity flowcontrol is

	port
	(
		-- INPUTS
			--@@ TODO: nale¿y dodaæ sygna³y z uk³adu steruj¹cego
			
		clk 			: in std_logic;
		rst				: in std_logic;
		flow_in			: in std_logic_vector ( 1 downto 0 );
		-----------
		-- 00 - idle
		-- 01 - enable
		-- 11 - end transmission
		-----------
		
		
		--OUTPUTS
		flow_out			: out std_logic_vector ( 1 downto 0 );
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

	-- 16bit counter is enough
    signal count 	:	std_logic_vector ( 15 downto 0 );
	signal flow 	:	std_logic_vector ( 1 downto 0 );

begin
	
		
    process (clk, rst, flow_in) 
    begin
        if (rst = '1') then
				count <= (others => '0');
        elsif (flow_in = "00") then
				count <= (others => '0');
        elsif (flow_in = "01") then
				if (rising_edge(clk)) then
					count <= count + 8;
                end if;
        end if;
 
   
    end process;

	process (count, rst)
	begin
		
	    if (rst = '1') then
			enable_MAINdmux <= (others => '0');
			enable_HEADdmux <= (others => '0');
			enable_RDMdmux <= (others => '0');
			enable_PACKdmux <= (others => '0');
			enable_MODdmux0 <= (others => '0');
			enable_MODdmux1 <= (others => '0');
			enable_MODdmux2 <= (others => '0');
			enable_MODdmux3 <= (others => '0');
		elsif (flow_in = "00") then
			enable_MAINdmux <= (others => '0');
			enable_HEADdmux <= (others => '0');
			enable_RDMdmux <= (others => '0');
			enable_PACKdmux <= (others => '0');
			enable_MODdmux0 <= (others => '0');
			enable_MODdmux1 <= (others => '0');
			enable_MODdmux2 <= (others => '0');
			enable_MODdmux3 <= (others => '0');
			
		elsif (flow_in = "01") then
			
			case count is
			-- 8bit -> SOP
			when "0000000000001000" =>
				enable_MAINdmux <= "01";
			-- 16bit -> LM
			when "0000000000010000" =>
				enable_HEADdmux <= "1";
			-- 32bit -> DM1	
			when "0000000000100000" =>
				enable_RDMdmux <= "01";
			-- 48bit -> DM2
			when "0000000000110000" =>
				enable_RDMdmux <= "10";
			-- 64bit -> DM3
			when "0000000001000000" =>
				enable_RDMdmux <= "11";
			-- 80bit -> DM4
			when "0000000001010000" =>
				enable_MAINdmux <= "00";
			-- 88bit -> EOH
			when "0000000001011000" =>
				enable_MAINdmux <= "10";
			-- 104bit -> CRC0
			when "0000000001101000" =>
				enable_MODdmux0 <= "1";
			-- 8296bit -> DATA0
			when "0010000001101000" =>
				enable_PACKdmux <= "01";
				enable_MODdmux1 <= "0";
			-- 8312bit -> CRC1
			when "0010000001111000" =>
				enable_MODdmux1 <= "1";
			-- 16504bit -> DATA1
			when "0100000001111000" =>
				enable_PACKdmux <= "10";
				enable_MODdmux2 <= "0";
			-- 16520bit -> CRC2
			when "0100000010001000" =>
				enable_MODdmux2 <= "1";
			-- 24712bit -> DATA2
			when "0110000010001000" =>
				enable_PACKdmux <= "11";
				enable_MODdmux3 <= "0";
			-- 24728bit -> CRC3
			when "0110000010011000" =>
				enable_MODdmux3 <= "1";
			-- 32920bit -> DATA3
			when "1000000010011000" =>
				enable_MAINdmux <= "00";
			-- 32936bit -> EOP					
			when "1000000010101000" =>
			
			when others =>
				flow <= "11";
			end case;
		end if;
		
		flow_out <= flow;
	end process;

end data_flow;

