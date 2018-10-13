library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity stage2 is
    port (
        a_real: in signed (13 downto 0);
        a_imag: in signed (13 downto 0);
        b_real: in signed (13 downto 0);
        b_imag: in signed (13 downto 0);
        w_real: in signed (8 downto 0);
        w_imag: in signed (8 downto 0);

        x_real: out signed (15 downto 0);
        x_imag: out signed (15 downto 0);
        y_real: out signed (15 downto 0);
        y_imag: out signed (15 downto 0)
    );
end stage2;

architecture st2 of stage2 is
    signal add_real: signed (14 downto 0);
    signal add_imag: signed (14 downto 0);
    signal sub_real: signed (14 downto 0);
    signal sub_imag: signed (14 downto 0);
    signal mul_real: signed (23 downto 0);
    signal mul_imag: signed (23 downto 0);

begin

    add_sub_process: process(a_real, b_real, a_imag, b_imag)
        variable ar_ex: signed (14 downto 0);
        variable br_ex: signed (14 downto 0);
        variable ai_ex: signed (14 downto 0);
        variable bi_ex: signed (14 downto 0);
    begin
        ar_ex := a_real(13) & a_real;
        br_ex := b_real(13) & b_real;
        ai_ex := a_imag(13) & a_imag;
        bi_ex := b_imag(13) & b_imag;
        add_real <= ar_ex + br_ex;
        add_imag <= ai_ex + bi_ex;
        sub_real <= ar_ex - br_ex;
        sub_imag <= ai_ex - bi_ex;
    end process;

    x_real <= add_real(14) & add_real;
    x_imag <= add_imag(14) & add_imag;

    mul_process: process(sub_real, sub_imag, w_real, w_imag)
        variable rr : signed (23 downto 0);
        variable ri : signed (23 downto 0);
        variable ir : signed (23 downto 0);
        variable ii : signed (23 downto 0);
    begin
        rr := sub_real * w_real;
        ri := sub_real * w_imag;
        ir := sub_imag * w_real;
        ii := sub_imag * w_imag;
        mul_real <= rr - ii;
        mul_imag <= ri + ir;
    end process;

    y_real <= mul_real(23 downto 8);
    y_imag <= mul_imag(23 downto 8);

end st2;
