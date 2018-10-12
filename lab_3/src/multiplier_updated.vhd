--Engineer     : 
--Date         : 
--Name of file : multiplier_updated.vhd
--Description  : implements 2 simple 8b*8b signed multipliers
--               DSP slice

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity multiplier_updated is
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
end multiplier_updated;
-- DO NOT MODIFY PORT NAMES ABOVE


architecture arch of multiplier_updated is

	signal A_plus_D: signed (26 downto 0);
	signal B: signed (17 downto 0);
	signal M: signed (35 downto 0);
	signal out_temp_1: signed (15 downto 0);
	signal out_temp_2: signed (15 downto 0);
	
	signal temp_valid_1: std_logic;
	signal temp_valid_2: std_logic;
begin
	process_0: process(data_in_1, data_in_2, coef_in)
	variable A: signed (26 downto 0);
	variable D: signed (26 downto 0);
	begin
		--A := (25 downto 18 => data_in_1, 26 => data_in_1(7), others => '0');
		A(25 downto 18) := data_in_1;
		A(26) := data_in_1(7);
		A(17 downto 0) := (others => '0');
		--D := (7 downto 0 => data_in_2, others => data_in_2(7));
		D(7 downto 0) := data_in_2;
		D(26 downto 8) := (others => data_in_2(7));
		--B <= (7 downto 0 => coef_in, others => coef_in(7));
		B(7 downto 0) <= coef_in;
		B(17 downto 8) <= (others => coef_in(7));
		A_plus_D <= A + D;
	end process;

	process_1: process(clk)
	variable temp: signed (44 downto 0);
	begin
		if (rising_edge(clk)) then
			if (rst = '1') then
				M <= (others => '0');
				temp_valid_1 <= '0';
			else
				temp := A_plus_D * B;
				M <= temp(35 downto 0);
				temp_valid_1 <= in_valid;
			end if;
		end if;
	end process;

	process_2: process(clk)
	variable temp1: signed (15 downto 0);
	variable temp2: signed (15 downto 0);
	begin
		if (rising_edge(clk)) then
			if (rst = '1') then
				temp_valid_2 <= '0';
				out_temp_1 <= (others => '0');
				out_temp_2 <= (others => '0');
			else
				temp1 := M(33 downto 18);
				temp2(0) := M(15);
				temp2(15 downto 1) := (others => '0');
				temp1 := temp1 + temp2;
				--out_temp_1 <= M(33 downto 18) + M(15);
				out_temp_1 <= temp1;
				out_temp_2 <= M(15 downto 0);
				temp_valid_2 <= temp_valid_1;
			end if;
		end if;
	end process;

	process_3: process(clk)
	begin
		if (rising_edge(clk)) then
			if (rst = '1') then
				out_valid <= '0';
				data_out_1 <= (others => '0');
				data_out_2 <= (others => '0');
			else
				data_out_1 <= out_temp_1;
				data_out_2 <= out_temp_2;
				out_valid <= temp_valid_2;
			end if;
		end if;
	end process;

end arch;
