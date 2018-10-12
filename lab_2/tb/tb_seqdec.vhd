--Engineer     : Yanshen Su 
--Date         : 8/31/2018
--Name of file : tb_seqdec.vhd
--Description  : test bench for sequence_detector

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use std.env.all;
use std.textio.all;
use ieee.std_logic_textio.all;

entity tb_seqdec is
end tb_seqdec;

architecture tb_arch of tb_seqdec is
  component sequence_detector 
    port (
          clk, rst  : in  std_logic;
          data_in   : in  std_logic;
          data_out  : out std_logic
         );
  end component;
  --signals local only to the present ip
  signal clk, rst   : std_logic;
  signal data_in    : std_logic;
  signal data_out   : std_logic;
  --signals related to the file operations
  file   input_file : text;
  file   output_file: text;
  -- time
  constant T: time := 20 ns;

begin
  DUT: sequence_detector 
    port map (
      clk      => clk,
      rst      => rst,
      data_in  => data_in,
      data_out => data_out
             );

  p_clk: process
  begin
    clk <= '0';
    wait for T/2;
    clk <= '1';
    wait for T/2;
  end process;

  p_sim: process
    variable input_line : line;
    variable output_line: line;
    variable data_term  : std_logic;
  begin
    file_open(input_file, "input_seq.txt", read_mode);
    file_open(output_file, "output.txt", write_mode);

    rst <= '1';
    wait until rising_edge(clk);
    rst <= '1';
    wait until rising_edge(clk);
    rst <= '0';

    while not endfile(input_file) loop
      readline(input_file, input_line);
      read(input_line, data_term);
      data_in <= data_term;
      wait until rising_edge(clk);
      write(output_line, data_out);
      writeline(output_file, output_line);
    end loop;

    file_close(input_file);
    file_close(output_file);
    report "Test completed";
    stop(0);
  end process;

end tb_arch;
