--Engineer     : Yanshen Su 
--Date         : 9/09/2018
--Name of file : tb_da.vhd
--Description  : test bench for da.vhd

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use std.env.all;
use std.textio.all;
use ieee.std_logic_textio.all;

entity tb_da is
  generic (
    input_file_str  : string := "input_seq.txt";
    output_file_str : string := "output.txt";
    output_cycle_str: string := "output_cycle.txt"
          );
end tb_da;

architecture tb_arch of tb_da is
  component da
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
  end component;
  --signals local only to the present ip
  signal clk, rst   : std_logic;
  signal data_in_0  : signed (3 downto 0);
  signal data_in_1  : signed (3 downto 0);
  signal data_in_2  : signed (3 downto 0);
  signal data_in_3  : signed (3 downto 0);
  signal in_valid   : std_logic := '0';
  signal next_in    : std_logic;
  signal data_out   : signed (9 downto 0);
  signal out_valid  : std_logic;
  --signals related to the file operations
  file   input_data_file   : text;
  file   output_file       : text;
  file   output_cycle_file : text;
  -- time
  constant T         : time   := 20 ns;
  signal cycle_count : integer;
  signal hanged_count: integer;

begin
  DUT: da
  port map (
      clk       => clk,
      rst       => rst,
      data_in_0 => data_in_0,
      data_in_1 => data_in_1,
      data_in_2 => data_in_2,
      data_in_3 => data_in_3,
      in_valid  => in_valid,
      next_in   => next_in,
      data_out  => data_out,
      out_valid => out_valid
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
    variable term_data_in_0   : std_logic_vector (3 downto 0);
    variable term_data_in_1   : std_logic_vector (3 downto 0);
    variable term_data_in_2   : std_logic_vector (3 downto 0);
    variable term_data_in_3   : std_logic_vector (3 downto 0);
    variable char_comma       : character;
    variable output_line      : line;
    variable output_cycle_line: line;
  begin
    file_open(input_data_file, input_file_str, read_mode);
    file_open(output_file, output_file_str, write_mode);
    file_open(output_cycle_file, output_cycle_str, write_mode);
    -- write the header
    write(output_line, string'("data_out when valid"), left, 20);
    writeline(output_file, output_line);

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
      if (in_valid = '0') then
        -- drive the DUT
        in_valid  <= term_in_valid;
        data_in_0 <= signed(term_data_in_0);
        data_in_1 <= signed(term_data_in_1);
        data_in_2 <= signed(term_data_in_2);
        data_in_3 <= signed(term_data_in_3);
      else
        while (next_in /= '1') loop
          wait until rising_edge(clk);
        end loop;
        -- drive the DUT
        in_valid  <= term_in_valid;
        data_in_0 <= signed(term_data_in_0);
        data_in_1 <= signed(term_data_in_1);
        data_in_2 <= signed(term_data_in_2);
        data_in_3 <= signed(term_data_in_3);
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
        write(output_line, data_out, left, 10);
        writeline(output_file, output_line);
        write(output_cycle_line, cycle_count, left, 11);
        writeline(output_cycle_file, output_cycle_line);
      end if; 
    end if; 
  end process;

  -- end simulation
  p_endsim: process (clk) 
  begin
    if (rising_edge(clk)) then 
      if (hanged_count >= 300) then 
        file_close(input_data_file);
        file_close(output_cycle_file);
        file_close(output_file);
        report "Test completed";
        stop(0);
      end if; 
    end if;
  end process;

end tb_arch;
