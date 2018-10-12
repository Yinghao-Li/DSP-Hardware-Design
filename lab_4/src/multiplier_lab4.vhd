--Engineer     : Yinghao Li
--Date         : Sept 24, 2018
--Name of file : multiplier_lab4.vhd
--Description  : implements concatenated signed multipliers
--               in DSP slice with handshake protocol

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity multiplier_lab4 is
  port (
        -- input side
        clk, rst   : in  std_logic;
        next_in    : out std_logic;
        in_valid   : in  std_logic;
        data_in_1  : in  signed (7 downto 0);
        data_in_2  : in  signed (7 downto 0);
        coef_in    : in  signed (7 downto 0);
        -- output side
        next_out   : in  std_logic;
        out_valid  : out std_logic;
        data_out_1 : out signed (15 downto 0);
        data_out_2 : out signed (15 downto 0)
       );
end multiplier_lab4;
-- DO NOT MODIFY PORT NAMES ABOVE


architecture arch of multiplier_lab4 is
	signal A_plus_D: signed (24 downto 0);
	signal B: signed (7 downto 0);
	signal M: signed (32 downto 0);
	signal out_temp_1: signed (15 downto 0);
	signal out_temp_2: signed (15 downto 0);
	signal temp_valid_1: std_logic;
	signal temp_valid_2: std_logic;
	signal temp_valid_3: std_logic;
	signal judg_4: std_logic;
	signal judg_3: std_logic;
	signal judg_2: std_logic;
begin
	process_m2: process(next_out, temp_valid_1, temp_valid_2, temp_valid_3)
	begin
		judg_4 <= next_out or not temp_valid_1 or not temp_valid_2 or not temp_valid_3;
		judg_3 <= next_out or not temp_valid_2 or not temp_valid_3;
		judg_2 <= next_out or not temp_valid_3;
		next_in <= next_out or not temp_valid_1 or not temp_valid_2 or not temp_valid_3;
	end process;

	process_0: process(data_in_1, data_in_2, coef_in)
	variable A: signed (24 downto 0) := (others => '0');
	variable D: signed (24 downto 0) := (others => '0');
	begin
		A := data_in_1(7) & data_in_1 & A(15 downto 0);
		D(7 downto 0) := data_in_2;
		D(24 downto 8) := (others => data_in_2(7));
		A_plus_D <= A + D;
		B <= coef_in;
	end process;

	process_1: process(clk)
	begin
		if (rising_edge(clk)) then
			if (rst = '0') then
				if (judg_4 = '1') then
					M <= A_plus_D * B;
					temp_valid_1 <= in_valid;
				end if;
			else
				M <= (others => '0');
				temp_valid_1 <= '0';
			end if;
		end if;
	end process;

	process_2: process(clk)
	begin
		if (rising_edge(clk)) then
			if (rst = '0') then
				if (judg_3 = '1') then
					out_temp_1 <= M(31 downto 16) - M(15 downto 15);
					out_temp_2 <= M(15 downto 0);
					temp_valid_2 <= temp_valid_1;
				end if;
			else
				temp_valid_2 <= '0';
				out_temp_1 <= (others => '0');
				out_temp_2 <= (others => '0');
			end if;
		end if;
	end process;

	process_3: process(clk)
	begin
		if (rising_edge(clk)) then
			if (rst = '0') then
				if (judg_2 = '1') then
					data_out_1 <= out_temp_1;
					data_out_2 <= out_temp_2;
					out_valid <= temp_valid_2;
					temp_valid_3 <= temp_valid_2;
				end if;
			else
				out_valid <= '0';
				temp_valid_3 <= '0';
				data_out_1 <= (others => '0');
				data_out_2 <= (others => '0');
			end if;
		end if;
	end process;
end arch;
