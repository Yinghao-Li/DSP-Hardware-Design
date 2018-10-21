library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity stage2 is
    port (
        clk, rst      : in std_logic;
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
    signal mul_real: signed (23 downto 0);
    signal mul_imag: signed (23 downto 0);

begin

    add_sub_process: process(clk)
        variable ar_ex: signed (14 downto 0);
        variable br_ex: signed (14 downto 0);
        variable ai_ex: signed (14 downto 0);
        variable bi_ex: signed (14 downto 0);
        variable sr : signed (14 downto 0);
        variable si : signed (14 downto 0);
        variable rr : signed (23 downto 0);
        variable ri : signed (23 downto 0);
        variable ir : signed (23 downto 0);
        variable ii : signed (23 downto 0);
    begin
        if (rising_edge(clk)) then
            if (rst = '0') then
                ar_ex := a_real(13) & a_real;
                br_ex := b_real(13) & b_real;
                ai_ex := a_imag(13) & a_imag;
                bi_ex := b_imag(13) & b_imag;
                add_real <= ar_ex + br_ex;
                add_imag <= ai_ex + bi_ex;
                sr := ar_ex - br_ex;
                si := ai_ex - bi_ex;

                rr := sr * w_real;
                ri := sr * w_imag;
                ir := si * w_real;
                ii := si * w_imag;
                mul_real <= rr - ii;
                mul_imag <= ri + ir;
            end if;
        end if;
    end process;

    x_real <= add_real(14) & add_real;
    x_imag <= add_imag(14) & add_imag;
    y_real <= mul_real(23 downto 8);
    y_imag <= mul_imag(23 downto 8);

end st2;
