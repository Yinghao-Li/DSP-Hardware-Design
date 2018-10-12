-- Engineer     :
-- Date         :
-- Name of file : da.vhd
-- Description  : implements a signed Distributed Arithmetic,
--                with 4 signed input vectors. Each is 4-bit wide.
--                The coefs are also 4-bit wide signed numbers

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity da is
  port (
       -- input side
       clk, rst       : in  std_logic;
       data_in_0      : in  signed (3 downto 0);
       data_in_1      : in  signed (3 downto 0);
       data_in_2      : in  signed (3 downto 0);
       data_in_3      : in  signed (3 downto 0);
       in_valid       : in  std_logic;
       next_in        : out std_logic;
       -- output side
       data_out       : out signed (9 downto 0);
       out_valid      : out std_logic
       );
end da;
-- DO NOT MODIFY PORT NAMES ABOVE

architecture arch of da is

    signal lookup : signed (9 downto 0);
    signal data : std_logic_vector (3 downto 0);
    signal add_data : signed (9 downto 0);

    -------------------------------------

    signal count : unsigned (1 downto 0);
    signal turn_flag : std_logic;
    signal temp_valid : std_logic;

begin
    lookup_process: process(data)
    begin
        case data is
            when "0000" => lookup <= "0000000000";
            when "0001" => lookup <= "0000000111";
            when "0010" => lookup <= "0000000011";
            when "0011" => lookup <= "0000001010";
            when "0100" => lookup <= "1111111000";
            when "0101" => lookup <= "1111111111";
            when "0110" => lookup <= "1111111011";
            when "0111" => lookup <= "0000000010";
            when "1000" => lookup <= "1111111011";
            when "1001" => lookup <= "0000000010";
            when "1010" => lookup <= "1111111110";
            when "1011" => lookup <= "0000000101";
            when "1100" => lookup <= "1111110011";
            when "1101" => lookup <= "1111111010";
            when "1110" => lookup <= "1111110110";
            when "1111" => lookup <= "1111111101";
            when others => lookup <= "0000000000";
        end case;
    end process;


    turn_process: process(clk)
    begin
        if (rising_edge(clk)) then
            if (rst = '0') then
                temp_valid <= in_valid;
                if (in_valid = '1') then
                    if (count = "00") then
                        data <= data_in_3(0) & data_in_2(0) & data_in_1(0) & data_in_0(0);
						turn_flag <= '0';
                    elsif (count = "01") then
                        data <= data_in_3(1) & data_in_2(1) & data_in_1(1) & data_in_0(1);
						turn_flag <= '0';
                    elsif (count = "10") then
                        data <= data_in_3(2) & data_in_2(2) & data_in_1(2) & data_in_0(2);
						turn_flag <= '1';
                    else
                        data <= data_in_3(3) & data_in_2(3) & data_in_1(3) & data_in_0(3);
                        turn_flag <= '0';
                    end if;
                    count <= count + "01";
                end if;
            else
                count <= "00";
                temp_valid <= '0';
                data <= "0000";
                turn_flag <= '0';
            end if;
        end if;
    end process;

    next_in <= not in_valid or turn_flag;

    add_process: process(clk)
    begin
        if (rising_edge(clk)) then
            if (rst = '0') then
                if (count = "01") then
                    add_data <= lookup;
                    out_valid <= '0';
                elsif (count = "10") then
                    add_data <= add_data + shift_left(lookup, 1);
                    out_valid <= '0';
                elsif (count = "11") then
                    add_data <= add_data + shift_left(lookup, 2);
                    out_valid <= '0';
                else
                    add_data <= add_data - shift_left(lookup, 3);
                    out_valid <= temp_valid;
                end if;
            else
                add_data <= "0000000000";
                out_valid <= '0';
            end if;
        end if;
    end process;

data_out <= add_data;

end arch;
