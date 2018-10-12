--Engineer     : Yanshen Su 
--Date         : 9/01/2018
--Name of file : tb_multiplier_updated.vhd
--Description  : test bench for multiplier_updated

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use std.env.all;
use std.textio.all;
use ieee.std_logic_textio.all;

entity tb_multiplier_updated is
end tb_multiplier_updated;

architecture tb_arch of tb_multiplier_updated is 
  component multiplier_updated 
    port (
        -- input ports
        clk, rst   : in std_logic;
        in_valid   : in std_logic;
        data_in_1  : in signed (7 downto 0);
        data_in_2  : in signed (7 downto 0);
        coef_in    : in signed (7 downto 0);
        -- output ports
        out_valid  : out std_logic;
        data_out_1 : out signed (15 downto 0);
        data_out_2 : out signed (15 downto 0)
         );
  end component;
  --signals local only to the present ip
  signal clk, rst   : std_logic;
  signal in_valid   : std_logic;
  signal data_in_1  : signed (7 downto 0);
  signal data_in_2  : signed (7 downto 0);
  signal coef_in    : signed (7 downto 0);
  signal out_valid  : std_logic;
  signal data_out_1 : signed (15 downto 0);
  signal data_out_2 : signed (15 downto 0);
  --signals related to the file operations
  file   input_file : text;
  file   output_file: text;
  -- time
  constant T: time  := 20 ns;
  signal cycle_count: integer;

begin
  DUT: multiplier_updated 
  port map (
    clk        => clk,
    rst        => rst,
    in_valid   => in_valid,
    data_in_1  => data_in_1,
    data_in_2  => data_in_2,
    coef_in    => coef_in,
    out_valid  => out_valid,
    data_out_1 => data_out_1,
    data_out_2 => data_out_2
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

  p_sim: process
    variable input_line     : line;
    variable term_in_valid  : std_logic;
    variable term_data_in_1 : std_logic_vector (7 downto 0);
    variable term_data_in_2 : std_logic_vector (7 downto 0);
    variable term_coef_in   : std_logic_vector (7 downto 0);
    variable char_comma     : character;
    variable output_line    : line;
  begin
    file_open(input_file, "input_seq.txt", read_mode);
    file_open(output_file, "output_updated.txt", write_mode);
    -- write the header
    write(output_line, string'("cycle"), left, 10);
    write(output_line, string'("valid"), left, 10);
    write(output_line, string'("data_out_1"), right, 16);
    write(output_line, string'("  "));
    write(output_line, string'("data_out_2"), right, 16);
    write(output_line, string'("  "));
    writeline(output_file, output_line);

    rst <= '1';
    wait until rising_edge(clk);
    rst <= '1';
    wait until rising_edge(clk);
    rst <= '0';

    while not endfile(input_file) loop
      -- read from input from
      readline(input_file, input_line);
      read(input_line, term_in_valid);
      read(input_line, char_comma);
      read(input_line, term_data_in_1);
      read(input_line, char_comma);
      read(input_line, term_data_in_2);
      read(input_line, char_comma);
      read(input_line, term_coef_in);
      -- drive the DUT
      in_valid  <= term_in_valid;
      data_in_1 <= signed(term_data_in_1);
      data_in_2 <= signed(term_data_in_2);
      coef_in   <= signed(term_coef_in);
      wait until rising_edge(clk);
      -- sample and write to output file
      write(output_line, cycle_count, left, 10);
      write(output_line, out_valid, left, 10);
      if (out_valid = '1') then
        write(output_line, data_out_1, right, 16);
        write(output_line, string'("  "));
        write(output_line, data_out_2, right, 16);
        write(output_line, string'("  "));
      else
        write(output_line, string'("----"), right, 16);
        write(output_line, string'("  "));
        write(output_line, string'("----"), right, 16);
        write(output_line, string'("  "));
      end if;
      writeline(output_file, output_line);
    end loop;

    file_close(input_file);
    file_close(output_file);
    report "Test completed";
    stop(0);

  end process;



end tb_arch;
