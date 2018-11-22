--Engineer      : Yinghao Li
--Created       : 11/14/2018
--Last Modified : 11/15/2018
--Name of file  : tb_decoder.vhd
--Description   : test bench for viterbi decoder.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use std.env.all;
use std.textio.all;
use ieee.std_logic_textio.all;

entity tb_decoder is
  -- no ports needed for this since this 
  -- is the top most module and no interaction
  -- with outside modules needed
end tb_decoder;

architecture tb_decoder_arch of tb_decoder is
  --the component instructs the compiler that the 
  --following module(ip) is going to be used in the design
  component decoder
    port(
      --input side
      clk, rst : in std_logic;
      data_in : in std_logic_vector(1 downto 0);
      next_in : out std_logic;
      --output side
      data_out : out std_logic;
      out_valid : out std_logic
    );
  end component;

  --signals local only to the present ip
  signal clk, rst : std_logic;
  signal data_in : std_logic_vector(1 downto 0);
  signal next_in : std_logic;
  signal data_out : std_logic;
  signal out_valid : std_logic;
  --signals related to the file operations
  file input_file : text;
  file output_file : text;
  -- time
  constant T: time  := 20 ns;
  signal cycle_count: integer;

begin
  DUT: decoder
  port map (
    clk => clk,
    rst => rst,
    data_in => data_in,
    next_in => next_in,
    data_out => data_out,
    out_valid => out_valid
  );

  -- generate clock signal
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

  -- simulation process
  p_read_data: process
    variable input_line : line;
    variable term_data_in : std_logic_vector(15 downto 0);
    variable i : integer;
    
  begin
    file_open(input_file, "encoded_data.txt", read_mode); -- TODO: filename is subject to change.
    file_open(output_file, "output.txt", write_mode);
    -- no header needed since there is only one column of codes.

    -- initial state
    rst <= '1';
    wait until rising_edge(clk);
    rst <= '1';
    wait until rising_edge(clk);
    rst <= '0';
    i := 0;

    while not endfile(input_file) loop
      -- read from input file
      readline(input_file, input_line);
      read(input_line, term_data_in);

      while (i < 8) loop
        while (next_in /= '1') loop
          wait until rising_edge(clk);
        end loop;
        -- drive the DUT
        data_in <= std_logic_vector(term_data_in((15-2*i) downto (14-2*i)));
        i := i + 1;
        wait until rising_edge(clk);
      end loop;
      i := 0;
    end loop;
    file_close(input_file);
    file_close(output_file);
    report "Test completed";
    stop(0);
  end process;

  p_sample: process(clk)
    variable output_line : line;
    variable i : integer;
  begin
    if (rising_edge(clk)) then
      if (rst = '0') then
        if (out_valid = '1') then
          -- sample and write to output file
          if (i < 7) then
            write(output_line, data_out);
            i := i + 1;
          elsif (i = 7) then
            write(output_line, data_out);
            writeline(output_file, output_line);
            i := 0;
          end if;
        end if;
      else
        i := 0;
      end if;
    end if;
  end process;

end tb_decoder_arch;   
