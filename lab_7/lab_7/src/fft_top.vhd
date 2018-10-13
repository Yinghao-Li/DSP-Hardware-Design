
--Engineer     :
--Date         :
--Name of file : fft_top.vhd
--Description  : implements 8-point FFT

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.fft_pkg.all;

entity fft_top is
  port (
        -- input side
        clk, rst      : in std_logic;
        data_in       : in data_in_t;
        in_valid      : in std_logic;
        next_in       : out std_logic;
        -- output side
        out_valid     : out std_logic;
        data_real_out : out data_out_t;
        data_imag_out : out data_out_t
       );
end fft_top;
-- DO NOT MODIFY PORT NAMES ABOVE


architecture arch of fft_top is

    signal real_temp_1 : data_temp_1_t;
    signal imag_temp_1 : data_temp_1_t;
    signal real_temp_2 : data_temp_2_t;
    signal imag_temp_2 : data_temp_2_t;
    signal real_out_temp: data_out_t;
    signal imag_out_temp: data_out_t;
    signal w_r : w_t;
    signal w_i : w_t;

    component stage0
        port(
            clk, rst: in std_logic;
            in_valid: in std_logic;
            a_real: in signed (7 downto 0);
            b_real: in signed (7 downto 0);
            w_real: in signed (8 downto 0);
            w_imag: in signed (8 downto 0);

            x_real: out signed (10 downto 0);
            x_imag: out signed (10 downto 0);
            y_real: out signed (10 downto 0);
            y_imag: out signed (10 downto 0));
    end component;
    component stage1 is
        port (
            clk, rst: in std_logic;
            in_valid: in std_logic;
            a_real: in signed (10 downto 0);
            a_imag: in signed (10 downto 0);
            b_real: in signed (10 downto 0);
            b_imag: in signed (10 downto 0);
            w_real: in signed (8 downto 0);
            w_imag: in signed (8 downto 0);

            x_real: out signed (13 downto 0);
            x_imag: out signed (13 downto 0);
            y_real: out signed (13 downto 0);
            y_imag: out signed (13 downto 0));
    end component;
    component stage2 is
        port (
            clk, rst: in std_logic;
            in_valid: in std_logic;
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
    end component;
begin
    w_r(0) <= "011111111";
    w_r(1) <= "010110100";
    w_r(2) <= "000000000";
    w_r(3) <= "101001100";
    w_i(0) <= "000000000";
    w_i(1) <= "101001100";
    w_i(2) <= "100000001";
    w_i(3) <= "101001100";

    s00: stage0
    port map(
        clk => clk,
        rst => rst,
        in_valid => in_valid,
        a_real => data_in(0),
        b_real => data_in(4),
        w_real => w_r(0),
        w_imag => w_i(0),
        x_real => real_temp_1(0),
        x_imag => imag_temp_1(0),
        y_real => real_temp_1(4),
        y_imag => imag_temp_1(4));
    s01: stage0
    port map(
        clk => clk,
        rst => rst,
        in_valid => in_valid,
        a_real => data_in(1),
        b_real => data_in(5),
        w_real => w_r(1),
        w_imag => w_i(1),
        x_real => real_temp_1(1),
        x_imag => imag_temp_1(1),
        y_real => real_temp_1(5),
        y_imag => imag_temp_1(5));
    s02: stage0
    port map(
        clk => clk,
        rst => rst,
        in_valid => in_valid,
        a_real => data_in(2),
        b_real => data_in(6),
        w_real => w_r(2),
        w_imag => w_i(2),
        x_real => real_temp_1(2),
        x_imag => imag_temp_1(2),
        y_real => real_temp_1(6),
        y_imag => imag_temp_1(6));
    s03: stage0
    port map(
        clk => clk,
        rst => rst,
        in_valid => in_valid,
        a_real => data_in(3),
        b_real => data_in(7),
        w_real => w_r(3),
        w_imag => w_i(3),
        x_real => real_temp_1(3),
        x_imag => imag_temp_1(3),
        y_real => real_temp_1(7),
        y_imag => imag_temp_1(7));

    s10: stage1
    port map(
        clk => clk,
        rst => rst,
        in_valid => in_valid,
        a_real => real_temp_1(0),
        a_imag => imag_temp_1(0),
        b_real => real_temp_1(2),
        b_imag => imag_temp_1(2),
        w_real => w_r(0),
        w_imag => w_i(0),
        x_real => real_temp_2(0),
        x_imag => imag_temp_2(0),
        y_real => real_temp_2(2),
        y_imag => imag_temp_2(2));
    s11: stage1
    port map(
        clk => clk,
        rst => rst,
        in_valid => in_valid,
        a_real => real_temp_1(1),
        a_imag => imag_temp_1(1),
        b_real => real_temp_1(3),
        b_imag => imag_temp_1(3),
        w_real => w_r(2),
        w_imag => w_i(2),
        x_real => real_temp_2(1),
        x_imag => imag_temp_2(1),
        y_real => real_temp_2(3),
        y_imag => imag_temp_2(3));
    s12: stage1
    port map(
        clk => clk,
        rst => rst,
        in_valid => in_valid,
        a_real => real_temp_1(4),
        a_imag => imag_temp_1(4),
        b_real => real_temp_1(6),
        b_imag => imag_temp_1(6),
        w_real => w_r(0),
        w_imag => w_i(0),
        x_real => real_temp_2(4),
        x_imag => imag_temp_2(4),
        y_real => real_temp_2(6),
        y_imag => imag_temp_2(6));
    s13: stage1
    port map(
        clk => clk,
        rst => rst,
        in_valid => in_valid,
        a_real => real_temp_1(5),
        a_imag => imag_temp_1(5),
        b_real => real_temp_1(7),
        b_imag => imag_temp_1(7),
        w_real => w_r(2),
        w_imag => w_i(2),
        x_real => real_temp_2(5),
        x_imag => imag_temp_2(5),
        y_real => real_temp_2(7),
        y_imag => imag_temp_2(7));

    s20: stage2
    port map(
        clk => clk,
        rst => rst,
        in_valid => in_valid,
        a_real => real_temp_2(0),
        a_imag => imag_temp_2(0),
        b_real => real_temp_2(1),
        b_imag => imag_temp_2(1),
        w_real => w_r(0),
        w_imag => w_i(0),
        x_real => real_out_temp(0),
        x_imag => imag_out_temp(0),
        y_real => real_out_temp(4),
        y_imag => imag_out_temp(4));
    s21: stage2
    port map(
        clk => clk,
        rst => rst,
        in_valid => in_valid,
        a_real => real_temp_2(2),
        a_imag => imag_temp_2(2),
        b_real => real_temp_2(3),
        b_imag => imag_temp_2(3),
        w_real => w_r(0),
        w_imag => w_i(0),
        x_real => real_out_temp(2),
        x_imag => imag_out_temp(2),
        y_real => real_out_temp(6),
        y_imag => imag_out_temp(6));
    s22: stage2
    port map(
        clk => clk,
        rst => rst,
        in_valid => in_valid,
        a_real => real_temp_2(4),
        a_imag => imag_temp_2(4),
        b_real => real_temp_2(5),
        b_imag => imag_temp_2(5),
        w_real => w_r(0),
        w_imag => w_i(0),
        x_real => real_out_temp(1),
        x_imag => imag_out_temp(1),
        y_real => real_out_temp(5),
        y_imag => imag_out_temp(5));
    s23: stage2
    port map(
        clk => clk,
        rst => rst,
        in_valid => in_valid,
        a_real => real_temp_2(6),
        a_imag => imag_temp_2(6),
        b_real => real_temp_2(7),
        b_imag => imag_temp_2(7),
        w_real => w_r(0),
        w_imag => w_i(0),
        x_real => real_out_temp(3),
        x_imag => imag_out_temp(3),
        y_real => real_out_temp(7),
        y_imag => imag_out_temp(7));

    p1: process(clk)
    begin
        if(rising_edge(clk)) then
            if (rst = '1') then
                next_in <= '0';
                out_valid <= '0';
            else
                next_in <= '1';
                out_valid <= in_valid;
            end if;
        end if;
    end process;

    p2: process(clk)
    begin
        if(rising_edge(clk)) then
            if (rst = '1') then
                data_real_out <= (others => '0');
                data_imag_out <= (others => '0');
            else
                if (out_valid <= '1') then
                    data_real_out <= real_out_temp;
                    data_imag_out <= imag_out_temp;
                end if;
            end if;
        end if;
    end process;

end arch;
