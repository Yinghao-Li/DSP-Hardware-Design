library ieee;
library work;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.multiplier.all;

entity filter_8 is
  port (
        -- input side
        clk, rst      : in  std_logic;
        next_in       : out std_logic;
        in_valid      : in  std_logic;
        data_in       : in  signed (7 downto 0);
        -- output side
        next_out      : in  std_logic;
        out_valid     : out std_logic;
        data_real_out : out signed (9 downto 0);
        data_imag_out : out signed (9 downto 0)
       );
end filter_8;
-- DO NOT MODIFY PORT NAMES ABOVE


architecture arch of filter_8 is
    -- ********************** DEFINE TYPES **********************
    type array8x8b_t      is array (0 to 7) of signed (7 downto 0);
    -- ********************** DEFINE SIGNALS **********************
    signal coef_real     : array8x8b_t;
    signal coef_imag     : array8x8b_t;
    --------------------------------------------------------------
    signal temp_valid_1: std_logic;
    signal temp_valid_2: std_logic;
    signal special_case: std_logic;
    -------------------------------------------------------------
    signal ini_state: std_logic;
    signal ini_in: std_logic;
    signal counter: unsigned(3 downto 0);
    signal data_in_flag: std_logic;

    signal mul_real_0: signed (18 downto 0);
    signal mul_imag_0: signed (18 downto 0);
    signal mul_real_1: signed (18 downto 0);
    signal mul_imag_1: signed (18 downto 0);
    signal mul_real_2: signed (18 downto 0);
    signal mul_imag_2: signed (18 downto 0);
    signal mul_real_3: signed (18 downto 0);
    signal mul_imag_3: signed (18 downto 0);
    signal mul_real_4: signed (18 downto 0);
    signal mul_imag_4: signed (18 downto 0);
    signal mul_real_5: signed (18 downto 0);
    signal mul_imag_5: signed (18 downto 0);
    signal mul_real_6: signed (18 downto 0);
    signal mul_imag_6: signed (18 downto 0);
    signal mul_real_7: signed (18 downto 0);
    signal mul_imag_7: signed (18 downto 0);

    signal data_0: signed(7 downto 0);
    signal data_1: signed(7 downto 0);
    signal data_2: signed(7 downto 0);
    signal data_3: signed(7 downto 0);
    signal data_4: signed(7 downto 0);
    signal data_5: signed(7 downto 0);
    signal data_6: signed(7 downto 0);
    signal data_7: signed(7 downto 0);

begin
    coef_real(0) <= "10110010";
    coef_imag(0) <= "11100011";
    coef_real(1) <= "10100101";
    coef_imag(1) <= "11101110";
    coef_real(2) <= "00111000";
    coef_imag(2) <= "10010100";
    coef_real(3) <= "10001000";
    coef_imag(3) <= "01011011";
    coef_real(4) <= "01010010";
    coef_imag(4) <= "10001001";
    coef_real(5) <= "00110000";
    coef_imag(5) <= "01110100";
    coef_real(6) <= "00000000";
    coef_imag(6) <= "11100011";
    coef_real(7) <= "10011000";
    coef_imag(7) <= "01010100";
    ---------------------------------------------
    next_in <= next_out or ini_state or not in_valid;
    data_in_flag <= in_valid and (ini_state or next_out);
    ini_in <= ini_state and in_valid;
    --Initial process
    ini_process: process(clk)
    begin
        if (rising_edge(clk)) then
            if (rst = '0') then
                if(special_case = '1') then
                    special_case <= '0';
                end if;
                if(ini_in = '1') then
                    counter <= counter + 1;
                    if (counter = "0111") then
                        ini_state <= '0';
                        special_case <= '1';
                    end if;
                end if;
            else
                ini_state <= '1';
                counter <= "0000";
                special_case <= '0';
            end if;
        end if;
    end process;

    shift_process: process(clk)
    begin
        if (rising_edge(clk)) then
            if (rst = '0') then
                if (data_in_flag = '1') then
                    data_0 <= data_in;
                    data_1 <= data_0;
                    data_2 <= data_1;
                    data_3 <= data_2;
                    data_4 <= data_3;
                    data_5 <= data_4;
                    data_6 <= data_5;
                    data_7 <= data_6;
                end if;
                
            else
                data_0 <= (others => '0');
                data_1 <= (others => '0');
                data_2 <= (others => '0');
                data_3 <= (others => '0');
                data_4 <= (others => '0');
                data_5 <= (others => '0');
                data_6 <= (others => '0');
                data_7 <= (others => '0');
            end if;
        end if;
    end process;

    --multiplication process
    mul_process: process(clk)
    variable temp_0: signed (32 downto 0);
    variable temp_1: signed (32 downto 0);
    variable temp_2: signed (32 downto 0);
    variable temp_3: signed (32 downto 0);
    variable temp_4: signed (32 downto 0);
    variable temp_5: signed (32 downto 0);
    variable temp_6: signed (32 downto 0);
    variable temp_7: signed (32 downto 0);
    variable temp_logic: std_logic;
    begin
        if (rising_edge(clk)) then
            if (rst = '0') then
                if (next_out = '1') then
                    -- Multiplication
                    temp_0 := mul(coef_real(0), coef_imag(0), data_0);
                    mul_real_0 <= get_real(temp_0);
                    mul_imag_0 <= get_imag(temp_0);

                    temp_1 := mul(coef_real(1), coef_imag(1), data_1);
                    mul_real_1 <= get_real(temp_1);
                    mul_imag_1 <= get_imag(temp_1);

                    temp_2 := mul(coef_real(2), coef_imag(2), data_2);
                    mul_real_2 <= get_real(temp_2);
                    mul_imag_2 <= get_imag(temp_2);

                    temp_3 := mul(coef_real(3), coef_imag(3), data_3);
                    mul_real_3 <= get_real(temp_3);
                    mul_imag_3 <= get_imag(temp_3);

                    temp_4 := mul(coef_real(4), coef_imag(4), data_4);
                    mul_real_4 <= get_real(temp_4);
                    mul_imag_4 <= get_imag(temp_4);

                    temp_5 := mul(coef_real(5), coef_imag(5), data_5);
                    mul_real_5 <= get_real(temp_5);
                    mul_imag_5 <= get_imag(temp_5);

                    temp_6 := mul(coef_real(6), coef_imag(6), data_6);
                    mul_real_6 <= get_real(temp_6);
                    mul_imag_6 <= get_imag(temp_6);

                    temp_7 := mul(coef_real(7), coef_imag(7), data_7);
                    mul_real_7 <= get_real(temp_7);
                    mul_imag_7 <= get_imag(temp_7);

                    temp_logic := in_valid and (not ini_state);
                    temp_valid_1 <= temp_logic or special_case;
                end if;
            else
                mul_real_0 <= (others => '0');
                mul_imag_0 <= (others => '0');
                mul_real_1 <= (others => '0');
                mul_imag_1 <= (others => '0');
                mul_real_2 <= (others => '0');
                mul_imag_2 <= (others => '0');
                mul_real_3 <= (others => '0');
                mul_imag_3 <= (others => '0');
                mul_real_4 <= (others => '0');
                mul_imag_4 <= (others => '0');
                mul_real_5 <= (others => '0');
                mul_imag_5 <= (others => '0');
                mul_real_6 <= (others => '0');
                mul_imag_6 <= (others => '0');
                mul_real_7 <= (others => '0');
                mul_imag_7 <= (others => '0');
                temp_valid_1 <= '0';
            end if;
        end if;
    end process;

    --addition process
    add_process: process(clk)
    variable add_real_0: signed (18 downto 0);
    variable add_imag_0: signed (18 downto 0);
    variable add_real_1: signed (18 downto 0);
    variable add_imag_1: signed (18 downto 0);
    variable add_real_2: signed (18 downto 0);
    variable add_imag_2: signed (18 downto 0);
    variable add_real_3: signed (18 downto 0);
    variable add_imag_3: signed (18 downto 0);
    variable add_real_4: signed (18 downto 0);
    variable add_imag_4: signed (18 downto 0);
    variable add_real_5: signed (18 downto 0);
    variable add_imag_5: signed (18 downto 0);
    variable add_real_6: signed (18 downto 0);
    variable add_imag_6: signed (18 downto 0);

    begin
        if (rising_edge(clk)) then
            if (rst = '0') then
                if (next_out = '1') then
                    -- Addition 1
                    add_real_0 := mul_real_0 + mul_real_1;
                    add_imag_0 := mul_imag_0 + mul_imag_1;

                    add_real_1 := mul_real_2 + mul_real_3;
                    add_imag_1 := mul_imag_2 + mul_imag_3;

                    add_real_2 := mul_real_4 + mul_real_5;
                    add_imag_2 := mul_imag_4 + mul_imag_5;

                    add_real_3 := mul_real_6 + mul_real_7;
                    add_imag_3 := mul_imag_6 + mul_imag_7;

                    -- Addition 2
                    add_real_4 := add_real_0 + add_real_1;
                    add_imag_4 := add_imag_0 + add_imag_1;

                    add_real_5 := add_real_2 + add_real_3;
                    add_imag_5 := add_imag_2 + add_imag_3;

                    -- Addition 3
                    add_real_6 := add_real_4 + add_real_5;
                    add_imag_6 := add_imag_4 + add_imag_5;

                    data_real_out <= add_real_6(18 downto 9);
                    data_imag_out <= add_imag_6(18 downto 9);

                    temp_valid_2 <= temp_valid_1;
                    out_valid <= temp_valid_2;
                end if;
            else
                data_real_out <= (others => '0');
                data_imag_out <= (others => '0');
                temp_valid_2 <= '0';
                out_valid <= '0';
            end if;
        end if;
    end process;

    --out_valid <= temp_valid_2;
end arch;
