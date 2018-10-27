-- Engineer     : 
-- Date         : 
-- Name of file : da_serial.vhd
-- Description  : implements a signed Distributed Arithmetic, an 4-tap FIR
--                with single 4-bit wide inputs serially fed into the design.
--                The real coefs are also 4-bit wide signed numbers. 
--                There is imaginary part for coefs but not for data_in

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity da_serial is
  port (
       -- input side
       clk, rst       : in  std_logic;
       data_in        : in  signed (3 downto 0);
       in_valid       : in  std_logic;
       next_in        : out std_logic;
       -- output side
       data_real_out  : out signed (9 downto 0);
       data_imag_out  : out signed (9 downto 0);
       out_valid      : out std_logic
       );
end da_serial;
-- DO NOT MODIFY PORT NAMES ABOVE

architecture arch of da_serial is
  -- ----------------- Define Signal Type -----------------
  type array4x4b_t      is array (0 to 3)  of signed (3 downto 0);
  type array4x1b_t      is array (0 to 3)  of std_logic;
  type array16x5b_t     is array (0 to 15) of signed (4 downto 0);
  -- ----------------- Define Intermediate Signals -----------------
  signal rom_re     :    array16x5b_t := ("00000", "00111", "00011", "01010", 
                                         "11000", "11111", "11011", "00010",
                                         "11011", "00010", "11110", "00101",
                                         "10011", "11010", "10110", "11101");
  signal rom_im     :    array16x5b_t := ("00000", "11011", "11000", "10011", 
                                         "00011", "11110", "11011", "10110",
                                         "00111", "00010", "11111", "11010",
                                         "01010", "00101", "00010", "11101");
  ------------------------------------------------------------------
  signal data_0 : signed (3 downto 0);
  signal data_1 : signed (3 downto 0);
  signal data_2 : signed (3 downto 0);
  signal data_3 : signed (3 downto 0);
  
  signal lookup_re : signed (9 downto 0);
  signal lookup_im : signed (9 downto 0);
  signal ini_count : unsigned (2 downto 0);
  signal count : unsigned (1 downto 0);

  signal data : unsigned (3 downto 0);
  signal add_data_re : signed (9 downto 0);
  signal add_data_im : signed (9 downto 0);

  signal input_data_flag : std_logic;

  signal turn_flag : std_logic;
  signal temp_valid : std_logic;

begin

  ini_input_process: process(clk)
  begin
    if (rising_edge(clk)) then
      if (rst = '0') then
        if (ini_count /= "100") then
          ini_count <= ini_count + 1;
        end if;
      else
        ini_count <= "000";
      end if;
    end if;
  end process;

  ini_process: process(ini_count, turn_flag, in_valid)
  begin
    if (ini_count = "100") then
      next_in <= not in_valid or turn_flag;
      input_data_flag <= not in_valid or turn_flag;
    else
      next_in <= '1';
      input_data_flag <= '1';
    end if;
  end process;

  data_in_process: process(clk)
  begin
    if (rising_edge(clk)) then
      if (rst = '0') then
        if (input_data_flag = '1') then
          if (in_valid = '1') then
            data_0 <= data_in;
            data_1 <= data_0;
            data_2 <= data_1;
            data_3 <= data_2;
          end if;
        end if;
      else
        data_0 <= "0000";
        data_1 <= "0000";
        data_2 <= "0000";
        data_3 <= "0000";
      end if;
    end if;
  end process;

  lookup_process: process(data)
  begin
    lookup_re <= resize(rom_re(to_integer(data)), lookup_re'length);
    lookup_im <= resize(rom_im(to_integer(data)), lookup_im'length);
  end process;

  turn_process: process(clk)
  begin
    if (rising_edge(clk)) then
      if (rst = '0') then
        if (ini_count = "100") then
          temp_valid <= in_valid;
          if (in_valid = '1') then
            if (count = "00") then
              data <= data_3(3) & data_2(3) & data_1(3) & data_0(3);
              turn_flag <= '0';
            elsif (count = "01") then
              data <= data_3(2) & data_2(2) & data_1(2) & data_0(2);
              turn_flag <= '0';
            elsif (count = "10") then
              data <= data_3(1) & data_2(1) & data_1(1) & data_0(1);
              turn_flag <= '1';
            else
              data <= data_3(0) & data_2(0) & data_1(0) & data_0(0);
              turn_flag <= '0';
            end if;
            count <= count + "01";
          end if;
        end if;
      else
        count <= "00";
        temp_valid <= '0';
        data <= "0000";
        turn_flag <= '0';
      end if;
    end if;
  end process;

  add_process: process(clk)
  begin
    if (rising_edge(clk)) then
      if (rst = '0') then
        if (ini_count = "100") then
          if (count = "01") then
            add_data_re <= -lookup_re;
            add_data_im <= -lookup_im;
            out_valid <= '0';
          elsif (count = "10") then
            add_data_re <= shift_left(add_data_re, 1) + lookup_re;
            add_data_im <= shift_left(add_data_im, 1) + lookup_im;
            out_valid <= '0';
          elsif (count = "11") then
            add_data_re <= shift_left(add_data_re, 1) + lookup_re;
            add_data_im <= shift_left(add_data_im, 1) + lookup_im;
            out_valid <= '0';
          else
            add_data_re <= shift_left(add_data_re, 1) + lookup_re;
            add_data_im <= shift_left(add_data_im, 1) + lookup_im;
            out_valid <= temp_valid;
          end if;
        end if;
      else
        add_data_re <= "0000000000";
        add_data_im <= "0000000000";
        out_valid <= '0';
      end if;
    end if;
  end process;

data_real_out <= add_data_re;
data_imag_out <= add_data_im;

end arch;
