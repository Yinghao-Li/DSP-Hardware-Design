--Engineer     : Yinghao Li
--Date         : 9/14/2018
--Name of file : multiplier.vhd
--Description  : implements 2 simple 8b*8b signed multipliers

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity multiplier is
  port (
        -- input ports
        clk, rst   : in std_logic;
        in_valid   : in std_logic;
        data_in_1  : in signed (7 downto 0);
        data_in_2  : in signed (7 downto 0);
        coef_in    : in signed (7 downto 0);
        -- output ports
        out_valid  : out std_logic;
        data_out_1 : out signed (15 downto 0);
        data_out_2 : out signed (15 downto 0)
       );
end multiplier;
-- DO NOT MODIFY PORT NAMES ABOVE

architecture arch of multiplier is
	signal temp_1: signed (7 downto 0);
	signal temp_2: signed (7 downto 0);
	signal temp_coef: signed (7 downto 0);
	signal temp_valid: std_logic;
begin
	process_0: process (clk)
	begin
		if (rising_edge(clk)) then
			if (rst = '1') then
				temp_1 <= "00000000";
				temp_2 <= "00000000";
				temp_coef <= "00000000";
				temp_valid <= '0';
			else
				temp_1 <= data_in_1;
				temp_2 <= data_in_2;
				temp_coef <= coef_in;
				temp_valid <= in_valid;
			end if;
		end if;
	end process;

	process_1: process (clk)
	begin
		if (rising_edge(clk)) then
			if (rst = '1') then
				out_valid <= '0';
			else
				data_out_1 <= temp_1 * temp_coef;
				data_out_2 <= temp_2 * temp_coef;
				out_valid <= temp_valid;
			end if;
		end if;
	end process;
end arch;

