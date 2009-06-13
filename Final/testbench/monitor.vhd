--------------------------------
-- File		:	monitor.vhd
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
use ieee.std_logic_unsigned.all;
use std.textio.all;
use work.text_util.all;



entity monitor is
	generic(
			 mon_file: string :="sim_res.dat"
			);
	port(
		sent    	: in std_logic;
		raport		: in std_logic_vector ( 7 downto 0 )		 
		);
end monitor;

architecture behavior of monitor is

file monfile: TEXT open write_mode is mon_file;

begin
  
-- zapis raportu do pliku
	monit: process (sent, raport)
	
  variable l: line;
  variable k: integer := 0;
  variable rap : std_logic_vector ( 7 downto 0 );
	begin
	  if sent = '1' then
		rap := raport;
		k := (k + 1);
		print(monfile, " ____________");
		print(monfile, "% ");
		print(monfile, "% raport log pakietu " & str(k));
		print(monfile, "%____________");
		print(monfile, " ");
		print(monfile, "Otrzymany raport: " & str(rap));
		for i in 0 to 3 loop
			if (rap( (7-(2*i)) downto (6-(2*i)) )  = "11") then
				print(monfile, "Modul "& str(i+1) &" : Bezbledny");
			elsif (rap( (7-(2*i)) downto (6-(2*i)) )  = "01") then
				print(monfile, "Modul "& str(i+1) &" : Blad dlugosci");
			elsif (rap( (7-(2*i)) downto (6-(2*i)) )  = "10") then			
				print(monfile, "Modul "& str(i+1) &" : Blad przeslanych danych (niezgodnosc CRC)");
			else
				print(monfile, "Modul "& str(i+1) &" : --");
			end if;
		end loop;
		print(monfile, " ");
  	  	print("I@FILE_WRITE: RAPORT " & str(k) & " ZAPISANY");
		else
		 
		end if; 
		
	end process monit;

	
end behavior;
