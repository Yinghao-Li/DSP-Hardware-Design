--Engineer     : 
--Date         : 8/27/2018
--Name of file : barrel_shifter.vhd
--Description  : implements a left-shifted barrel shifter
--               of data width 16 bits

library ieee;
use ieee.std_logic_1164.all;
entity barrel_shifter is
    --port list
    port(
         input  : in  std_logic_vector(15 downto 0); -- input data
         ctrl   : in  std_logic_vector(3 downto 0);  -- control word
         output : out std_logic_vector(15 downto 0)  -- output data
        );
end barrel_shifter ;

architecture barrel_arch of barrel_shifter is
begin
  with ctrl select
    output <= input                                    when "0000",
              input(14 downto 0) & input(15)           when "0001",
              input(13 downto 0) & input(15 downto 14) when "0010",
              input(12 downto 0) & input(15 downto 13) when "0011",
              input(11 downto 0) & input(15 downto 12) when "0100",
              input(10 downto 0) & input(15 downto 11) when "0101",
              input(9 downto 0) & input(15 downto 10)  when "0110",
              input(8 downto 0) & input(15 downto 9)   when "0111",
              input(7 downto 0) & input(15 downto 8)   when "1000",
              input(6 downto 0) & input(15 downto 7)   when "1001",
              input(5 downto 0) & input(15 downto 6)   when "1010",
              input(4 downto 0) & input(15 downto 5)   when "1011",
              input(3 downto 0) & input(15 downto 4)   when "1100",
              input(2 downto 0) & input(15 downto 3)   when "1101",
              input(1 downto 0) & input(15 downto 2)   when "1110",
              input(0) & input(15 downto 1)            when "1111",
              -- Complete your design below this line
              (others => '0')                          when others;

end barrel_arch; 
