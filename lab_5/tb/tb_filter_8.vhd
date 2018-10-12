
--Engineer     : Yanshen Su 
--Date         : 9/18/2018
--Name of file : tb_filter_8.vhd
--Description  : test bench for filter_8

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use std.env.all;
use std.textio.all;
use ieee.std_logic_textio.all;

entity tb_filter_8 is
  generic (
    input_file_str  : string := "input_seq.txt";
    output_file_str : string := "output.txt"
          );
end tb_filter_8;

architecture tb_arch of tb_filter_8 is 
  component filter_8 
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
  end component;
  --signals local only to the present ip
  signal clk, rst      : std_logic;
  signal next_out      : std_logic;
  signal in_valid      : std_logic  := '0';
  signal data_in       : signed (7 downto 0);
  signal next_in       : std_logic;
  signal out_valid     : std_logic;
  signal data_real_out : signed (9 downto 0);
  signal data_imag_out : signed (9 downto 0);
  --signals related to the file operations
  file   input_data_file  : text;
  file   input_ready_file : text;
  file   output_file      : text;
  -- time
  constant T: time  := 20 ns;
  signal hanged_count: integer;

begin
  DUT: filter_8 
  port map (
    clk           => clk,
    rst           => rst,
    next_in       => next_in,
    in_valid      => in_valid,
    data_in       => data_in,
    next_out      => next_out,
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

  -- counting hang cycles
  p_hang_cycle: process (clk)
  begin
    if (rising_edge(clk)) then
      if (rst = '1' or (out_valid = '1' and next_out = '1')) then
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
    variable term_data_in     : std_logic_vector (7 downto 0);
    variable char_comma       : character;
    variable output_line      : line;
  begin
    file_open(input_data_file, input_file_str, read_mode);
    file_open(output_file, output_file_str, write_mode);
    -- write the header
    write(output_line, string'("data_real"), right, 10);
    write(output_line, string'("  "));
    write(output_line, string'("data_imag"), right, 10);
    writeline(output_file, output_line);


    rst <= '1';
    wait until rising_edge(clk);
    rst <= '1';
    wait until rising_edge(clk);
    rst <= '0';

    -- read first line: coefs, and discard
    readline(input_data_file, input_data_line);
    while not endfile(input_data_file) loop
      -- read from input 
      readline(input_data_file, input_data_line);
      read(input_data_line, term_in_valid);
      read(input_data_line, char_comma);
      read(input_data_line, term_data_in);
      if (in_valid = '0') then
        -- drive the DUT
        in_valid  <= term_in_valid;
        data_in <= signed(term_data_in);
      else
        while (next_in /= '1') loop
          wait until rising_edge(clk);
        end loop;
        -- drive the DUT
        in_valid  <= term_in_valid;
        data_in <= signed(term_data_in);
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

  p_read_ready: process
    variable input_ready_line : line;
    variable term_next_out    : std_logic;
  begin
    file_open(input_ready_file, "input_out_ready.txt", read_mode);
    while not endfile(input_ready_file) loop
      wait until rising_edge(clk);
      -- read from input 
      readline(input_ready_file, input_ready_line);
      read(input_ready_line, term_next_out);
      next_out <= term_next_out;
    end loop;
    wait until rising_edge(clk);
    if (next_out = '0') then
      next_out <= '1';
    end if;
    wait;
  end process;

  -- sampling the output
  p_sample: process (clk)
    variable output_line       : line;
  begin 
    if (rising_edge(clk)) then
      if (rst = '0' and out_valid = '1' and next_out = '1') then
        -- sample and write to output file
        write(output_line, data_real_out, right, 10);
        write(output_line, string'("  "));
        write(output_line, data_imag_out, right, 10);
        writeline(output_file, output_line);
      end if; 
    end if; 
  end process;

  -- end simulation
  p_endsim: process (clk) 
  begin
    if (rising_edge(clk)) then 
      if (hanged_count >= 300) then 
        file_close(input_data_file);
        file_close(output_file);
        report "Test completed";
        stop(0);
      end if; 
    end if;
  end process;

end tb_arch;
