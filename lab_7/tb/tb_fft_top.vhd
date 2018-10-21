
--Engineer     : Yanshen Su 
--Date         : 10/01/2018
--Name of file : tb_fft_top.vhd
--Description  : test bench for fft_top

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use std.env.all;
use std.textio.all;
use ieee.std_logic_textio.all;
use work.fft_pkg.all;

entity tb_fft_top is
  generic (
    input_file_str   : string := "input_seq.txt";
    output_file_str  : string := "output.txt";
    output_cycle_str : string := "output_cycle.txt"
          );
end tb_fft_top;

architecture tb_arch of tb_fft_top is 
  component fft_top
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
  end component;
  --signals local only to the present ip
  signal clk, rst      : std_logic;
  signal next_out      : std_logic;
  signal in_valid      : std_logic  := '0';
  signal data_in       : data_in_t;
  signal next_in       : std_logic;
  signal out_valid     : std_logic;
  signal data_real_out : data_out_t;
  signal data_imag_out : data_out_t;
  --signals related to the file operations
  file   input_data_file  : text;
  file   output_file      : text;
  file   output_cycle_file : text;
  -- time
  constant T: time  := 20 ns;
  signal cycle_count : integer;
  signal hanged_count: integer;

begin

  DUT: fft_top
  port map (
          -- input side
          clk      => clk,
          rst      => rst,
          data_in  => data_in,
          in_valid => in_valid,
          next_in  => next_in,
          -- output side
          out_valid     => out_valid,
          data_real_out => data_real_out,
          data_imag_out => data_imag_out
         );

  p_clk: process
  begin
    clk <= '0';
    wait for T/2;
    clk <= '1';
    wait for T/2;
  end process;

  -- counting cycles
  p_cycle: process (clk)
  begin
    if (rising_edge(clk)) then
      if (rst = '1') then
        cycle_count <= 0;
      else 
        cycle_count <= cycle_count + 1;
      end if;
    end if;
  end process;

  -- counting hang cycles
  p_hang_cycle: process (clk)
  begin
    if (rising_edge(clk)) then
      if (rst = '1' or out_valid = '1') then
        hanged_count <= 0;
      else 
        hanged_count <= hanged_count + 1;
      end if;
    end if;
  end process;

  -- SIMULATION STARTS
  p_read_data: process
    variable input_data_line  : line;
    variable term_in_valid    : std_logic;
    variable term_data_in_0   : std_logic_vector (7 downto 0);
    variable term_data_in_1   : std_logic_vector (7 downto 0);
    variable term_data_in_2   : std_logic_vector (7 downto 0);
    variable term_data_in_3   : std_logic_vector (7 downto 0);
    variable term_data_in_4   : std_logic_vector (7 downto 0);
    variable term_data_in_5   : std_logic_vector (7 downto 0);
    variable term_data_in_6   : std_logic_vector (7 downto 0);
    variable term_data_in_7   : std_logic_vector (7 downto 0);
    variable char_comma       : character;
    variable output_line      : line;
    variable output_cycle_line : line;
  begin
    file_open(input_data_file, input_file_str, read_mode);
    file_open(output_file, output_file_str, write_mode);
    file_open(output_cycle_file, output_cycle_str, write_mode);
    -- write the header
    write(output_cycle_line, string'("valid cycle"), left, 11);
    writeline(output_cycle_file, output_cycle_line);


    rst <= '1';
    wait until rising_edge(clk);
    rst <= '1';
    wait until rising_edge(clk);
    rst <= '0';

    while not endfile(input_data_file) loop
      -- read from input 
      readline(input_data_file, input_data_line);
      read(input_data_line, term_in_valid);
      read(input_data_line, char_comma);
      read(input_data_line, term_data_in_0);
      read(input_data_line, char_comma);
      read(input_data_line, term_data_in_1);
      read(input_data_line, char_comma);
      read(input_data_line, term_data_in_2);
      read(input_data_line, char_comma);
      read(input_data_line, term_data_in_3);
      read(input_data_line, char_comma);
      read(input_data_line, term_data_in_4);
      read(input_data_line, char_comma);
      read(input_data_line, term_data_in_5);
      read(input_data_line, char_comma);
      read(input_data_line, term_data_in_6);
      read(input_data_line, char_comma);
      read(input_data_line, term_data_in_7);
      if (in_valid = '0') then
        -- drive the DUT
        in_valid  <= term_in_valid;
        data_in(0) <= signed(term_data_in_0);
        data_in(1) <= signed(term_data_in_1);
        data_in(2) <= signed(term_data_in_2);
        data_in(3) <= signed(term_data_in_3);
        data_in(4) <= signed(term_data_in_4);
        data_in(5) <= signed(term_data_in_5);
        data_in(6) <= signed(term_data_in_6);
        data_in(7) <= signed(term_data_in_7);
      else
        while (next_in /= '1') loop
          wait until rising_edge(clk);
        end loop;
        -- drive the DUT
        in_valid  <= term_in_valid;
        data_in(0) <= signed(term_data_in_0);
        data_in(1) <= signed(term_data_in_1);
        data_in(2) <= signed(term_data_in_2);
        data_in(3) <= signed(term_data_in_3);
        data_in(4) <= signed(term_data_in_4);
        data_in(5) <= signed(term_data_in_5);
        data_in(6) <= signed(term_data_in_6);
        data_in(7) <= signed(term_data_in_7);
      end if;
      wait until rising_edge(clk);
    end loop;
    -- end generating input ...
    if (in_valid = '1') then 
      while (next_in /= '1') loop 
        wait until rising_edge(clk);
      end loop; 
    end if;
    in_valid <= '0';
    wait;
  end process;

  -- sampling the output
  p_sample: process (clk)
    variable output_line       : line;
    variable output_cycle_line : line;
  begin 
    if (rising_edge(clk)) then
      if (rst = '0' and out_valid = '1') then
        -- sample and write to output file
        write(output_line, string'("Real")     , right, 16);
        write(output_line, string'("Dec")      , right, 10);
        write(output_line, string'("Imaginary"), right, 20);
        write(output_line, string'("Dec")      , right, 10);
        writeline(output_file, output_line);

        for i in 0 to 7 loop 
          write(output_line, data_real_out(i), right, 16);
          write(output_line, string'("    "));
          write(output_line, to_integer(data_real_out(i)), right, 6);
          write(output_line, string'("    "));
          write(output_line, data_imag_out(i), right, 16);
          write(output_line, string'("    "));
          write(output_line, to_integer(data_imag_out(i)), right, 6);
          writeline(output_file, output_line);
        end loop;

        write(output_cycle_line, cycle_count, left, 11);
        writeline(output_cycle_file, output_cycle_line);
      end if; 
    end if; 
  end process;

  -- end simulation
  p_endsim: process (clk) 
  begin
    if (rising_edge(clk)) then 
      if (hanged_count >= 500) then 
        file_close(input_data_file);
        file_close(output_cycle_file);
        file_close(output_file);
        report "Test completed";
        stop(0);
      end if; 
    end if;
  end process;



end tb_arch;
