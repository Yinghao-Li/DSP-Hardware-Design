library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity stage0 is
    port (
        clk, rst      : in std_logic;
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
    signal add_real: signed (8 downto 0);
    signal mul_real: signed (18 downto 0);
    signal mul_imag: signed (18 downto 0);

begin

    --add and sub
    add_sub_process: process(clk)
        variable a_ex: signed (8 downto 0);
        variable b_ex: signed (8 downto 0);
        variable sr: signed (8 downto 0);
        variable rr: signed (18 downto 0);
        variable ri: signed (18 downto 0);
    begin
        if (rising_edge(clk)) then
            if (rst = '0') then
                a_ex := a_real(7) & a_real;
                b_ex := b_real(7) & b_real;
                add_real <= a_ex + b_ex;
                sr := a_ex - b_ex;

                rr(17 downto 0) := sr * w_real;
                ri(17 downto 0) := sr * w_imag;
                rr := rr(17) & rr(17 downto 0);
                ri := ri(17) & ri(17 downto 0);
                mul_real <= rr;
                mul_imag <= ri;
            end if;
        end if;
    end process;

    --output
    x_real(8 downto 0) <= add_real;
    x_real(10 downto 9) <= (others => add_real(8));
    x_imag <= (others => '0');

    y_real <= mul_real(18 downto 8);
    y_imag <= mul_imag(18 downto 8);

end st0;
