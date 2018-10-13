library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity stage0 is
    port (
        clk, rst: in std_logic;
        in_valid: in std_logic;
        a_real: in signed (7 downto 0);
        b_real: in signed (7 downto 0);
        w_real: in signed (8 downto 0);
        w_imag: in signed (8 downto 0);

        x_real: out signed (10 downto 0);
        x_imag: out signed (10 downto 0);
        y_real: out signed (10 downto 0);
        y_imag: out signed (10 downto 0)
    );
end stage0;

architecture st0 of stage0 is
    signal x_temp_real: signed (10 downto 0);
    signal sub_real: signed (8 downto 0);
    signal mul_real: signed (18 downto 0);
    signal mul_imag: signed (18 downto 0);

begin

    --add and sub
    add_sub_process: process(a_real, b_real)
        variable a_ex: signed (8 downto 0);
        variable b_ex: signed (8 downto 0);
    begin
        a_ex := a_real(7) & a_real;
        b_ex := b_real(7) & b_real;
        x_temp_real(8 downto 0) <= a_ex + b_ex;
        x_temp_real(10 downto 9) <= (others => x_temp_real(8));
        sub_real <= a_ex - b_ex;
    end process;

    --mul
    mul_process: process(sub_real, w_real, w_imag)
        variable data_in_ext_1 : signed (26 downto 0);
        variable data_in_ext_2 : signed (26 downto 0);
        variable data_concat_p1 : signed (27 downto 0);
        variable data_mult_p2 : signed (36 downto 0);
        variable sign_ext_data: signed (1 downto 0);
        variable rr: signed (18 downto 0);
        variable ri: signed (18 downto 0);
    begin
        data_in_ext_1 (26 downto 18) := w_real;
        data_in_ext_1 (17 downto 0)  := (others => '0');
        data_in_ext_2 (8 downto 0)   := w_imag;
        data_in_ext_2 (26 downto 9)  := (others => w_imag (8));
        data_concat_p1 := (data_in_ext_1(26) & data_in_ext_1) + data_in_ext_2;
        data_mult_p2 := data_concat_p1 * sub_real;

        sign_ext_data := '0' & data_mult_p2(17);
        rr(17 downto 0) := signed(data_mult_p2(35 downto 18)) + sign_ext_data;
        ri(17 downto 0) := data_mult_p2(17 downto 0);
        rr := rr(17) & rr(17 downto 0);
        ri := ri(17) & ri(17 downto 0);
        mul_real <= rr;
        mul_imag <= ri;
    end process;

    --output
    x_real <= x_temp_real;
    x_imag <= (others => '0');

    y_real <= mul_real(18 downto 8);
    y_imag <= mul_imag(18 downto 8);

end st0;
