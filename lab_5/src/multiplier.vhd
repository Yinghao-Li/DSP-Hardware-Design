
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package multiplier is

	function mul (
		data_1: in signed (7 downto 0);
		data_2: in signed (7 downto 0);
		coef: in signed (7 downto 0))
		return signed;

	function get_real (
		data: in signed (32 downto 0)) return signed;

	function get_imag (
		data: in signed (32 downto 0)) return signed;

end multiplier;

package body multiplier is

	function mul(
			data_1: in signed (7 downto 0);
			data_2: in signed (7 downto 0);
			coef: in signed (7 downto 0)) return signed is
		variable data_in_ext_1 : signed (23 downto 0);
		variable data_in_ext_2 : signed (23 downto 0);
		variable data_concat_p1 : signed (24 downto 0);
		variable data_mult_p2 : signed (32 downto 0);
	begin
		data_in_ext_1 (23 downto 16) := data_1;
		data_in_ext_1 (15 downto 0)  := (others => '0');
		data_in_ext_2 (7 downto 0)   := data_2;
		data_in_ext_2 (23 downto 8)  := (others => data_2 (7));
		data_concat_p1 := (data_in_ext_1(23) & data_in_ext_1) + data_in_ext_2;
		data_mult_p2 := data_concat_p1 * coef;
		return data_mult_p2;
	end mul;

	function get_real(
			data: signed (32 downto 0)) return signed is
		variable real_num: signed (18 downto 0);
		variable sign_ext_data: signed (1 downto 0);
	begin
		sign_ext_data := '0' & data(15);
		real_num(15 downto 0) := signed(data(31 downto 16)) + sign_ext_data;
		real_num(18 downto 16) := (others =>real_num(15));
		return real_num;
	end get_real;

	function get_imag(
			data: signed (32 downto 0)) return signed is
		variable imag_num: signed (18 downto 0);
	begin
		imag_num(15 downto 0) := data(15 downto 0);
		imag_num(18 downto 16) := (others => data(15));
		return imag_num;
	end get_imag;


end multiplier;
