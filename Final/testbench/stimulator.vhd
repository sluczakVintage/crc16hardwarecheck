--------------------------------
-- File		:	stimulator.vhd
-- Version	:	0.1
-- Date		:	03.06.2009
-- Desc		:	Project testbench entity
-- Author	:	Sebastian £uczak
-- Author	:	Maciej Nowak 
-- Based on	:	/
--------------------------------

---------------------------
--
library ieee;
use ieee.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.std_logic_textio.all;
use std.textio.all;
use work.text_util.all;


entity stimulator is
	generic(
			 stim_file: string :="sim.dat"
			);
	port(
		clk			: in std_logic;
		rst			: in std_logic;
		busy		: in std_logic;
		
		data		: out std_logic_vector ( 7 downto 0 );
		receive  	: out std_logic
		 
		);
end stimulator;

architecture behavior of stimulator is

	file stimulus: TEXT open read_mode is stim_file;
		
begin
	
	stimul : process

		variable l: line;
		variable s: string(1 to 8);
		variable c : character;
		variable module_number : integer  := 0;
		variable intch : integer := 0;
		variable eom : integer := 0;
	   
	begin
		while NOT endfile(stimulus) loop
			receive <= '0';
			if (busy = '0') then
				receive <= '1';
				wait until clk = '1';
		-- SOP	
				readline(stimulus, l);
				read(l, c);
				intch := character'pos(c);
				data <= std_logic_vector( to_unsigned(intch,8) );
				wait until clk = '1';
				read(l, c);
				intch := character'pos(c);
				data <= std_logic_vector( to_unsigned(intch,8) );
				wait until clk = '1';

		-- LICZBA MODULOW		
				readline(stimulus, l);
				read(l, s);
				data <= to_std_logic_vector(s);
				module_number := to_integer(unsigned(to_std_logic_vector(s)));
				wait until clk = '1';
				
		-- DLUGOSCI MODULOW
				for i in 0 to 3 loop 
					readline(stimulus, l);
					read(l, s);
					data <= to_std_logic_vector(s);
					wait until clk = '1';
					read(l, s);
					data <= to_std_logic_vector(s);
					wait until clk = '1';
				end loop;
				
		-- EOH		
				readline(stimulus, l);
				read(l, c);
				intch := character'pos(c);
				data <= std_logic_vector( to_unsigned(intch,8) );
				wait until clk = '1';
			  
				for i in 0 to module_number loop
				--CRC
				--	print("I@FILE_READ: Jestem w petli module_number " & str(i) );
					readline(stimulus, l);
					read(l, s);
					data <= to_std_logic_vector(s);
					wait until clk = '1';
					
					read(l, s);
					data <= to_std_logic_vector(s);
					wait until clk = '1';
				--DATA			
					eom := 0;
					readline(stimulus, l);
					while (eom = 0) loop
						read(l, c);
						intch := character'pos(c);
						data <= std_logic_vector( to_unsigned(intch,8) );
						--print("I@FILE_READ: Char " & str(character'pos(c)) & " " & str(intch) & " " & str(std_logic_vector( to_unsigned(intch,8) )));
						if std_logic_vector( to_unsigned(intch,8) ) = "00000011" then
							wait until clk = '1';
							read(l, c);
							intch := character'pos(c);
							data <= std_logic_vector( to_unsigned(intch,8) );
							eom := 1;
						else
							eom := 0;
						end if;
						--print("I@FILE_READ: Jestem w petli eom " & str(eom));
						wait until clk = '1';
					end loop; 
					
				end loop;
				
				readline(stimulus, l);
				read(l, c);
				intch := character'pos(c);
				data <= std_logic_vector( to_unsigned(intch,8) );
				
			
				print("I@FILE_READ: Koniec odczytu pakietu z "& stim_file );			
			else
			wait until clk = '1';
			end if;
		end loop;
		print("I@FILE_READ: Koniec odczytu z pliku "& stim_file );
		wait;
	end process stimul;

	
end behavior;
