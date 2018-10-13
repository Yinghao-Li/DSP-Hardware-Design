library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity stage1 is
    port (
        clk, rst      : in std_logic;
        a_real: in signed (10 downto 0);
        a_imag: in signed (10 downto 0);
        b_real: in signed (10 downto 0);
        b_imag: in signed (10 downto 0);
        w_real: in signed (8 downto 0);
        w_imag: in signed (8 downto 0);

        x_real: out signed (13 downto 0);
        x_imag: out signed (13 downto 0);
        y_real: out signed (13 downto 0);
        y_imag: out signed (13 downto 0)
    );
end stage1;

architecture st1 of stage1 is
    signal add_real: signed (11 downto 0);
    signal add_imag: signed (11 downto 0);
    signal mul_real: signed (21 downto 0);
    signal mul_imag: signed (21 downto 0);

begin

    --add and sub
    add_sub_process: process(clk)
        variable ar_ex: signed (11 downto 0);
        variable br_ex: signed (11 downto 0);
        variable ai_ex: signed (11 downto 0);
        variable bi_ex: signed (11 downto 0);
        variable sr : signed (11 downto 0);
        variable si : signed (11 downto 0);
        variable rr : signed (21 downto 0);
        variable ri : signed (21 downto 0);
        variable ir : signed (21 downto 0);
        variable ii : signed (21 downto 0);
    begin
        if (rising_edge(clk)) then
            if (rst = '0') then
                ar_ex := a_real(10) & a_real;
                br_ex := b_real(10) & b_real;
                ai_ex := a_imag(10) & a_imag;
                bi_ex := b_imag(10) & b_imag;
                add_real <= ar_ex + br_ex;
                add_imag <= ai_ex + bi_ex;
                sr := ar_ex - br_ex;
                si := ai_ex - bi_ex;

                rr(20 downto 0) := sr * w_real;
                ri(20 downto 0) := sr * w_imag;
                ir(20 downto 0) := si * w_real;
                ii(20 downto 0) := si * w_imag;
                rr := rr(20) & rr(20 downto 0);
                ri := ri(20) & ri(20 downto 0);
                ir := ir(20) & ir(20 downto 0);
                ii := ii(20) & ii(20 downto 0);
                mul_real <= rr - ii;
                mul_imag <= ri + ir;
            end if;
        end if;
    end process;

    x_real(11 downto 0) <= add_real;
    x_real(13 downto 12) <= (others => add_real(11));
    x_imag(11 downto 0) <= add_imag;
    x_imag(13 downto 12) <= (others => add_imag(11));

    y_real <= mul_real(21 downto 8);
    y_imag <= mul_imag(21 downto 8);

end st1;
