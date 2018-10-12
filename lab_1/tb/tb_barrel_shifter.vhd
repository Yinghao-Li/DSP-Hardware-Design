--Engineer     : Yanshen Su 
--Date         : 8/27/2018
--Name of file : tb_barrel_shifter.vhd
--Description  : test bench for barrel shifter 16-bit

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use std.env.all;
use std.textio.all;
use ieee.std_logic_textio.all;

entity tb_barrel_shifter is
  -- no ports needed for this since this 
  -- is the top most module and no interaction
  -- with outside modules needed
end tb_barrel_shifter;

architecture tb_behav_barrel of tb_barrel_shifter is
  --the component instructs the compiler that the 
  --following module(ip) is going to be used in the design
  component barrel_shifter
    port (input  : in  std_logic_vector(15 downto 0);
          ctrl   : in  std_logic_vector(3 downto 0);
          output : out std_logic_vector(15 downto 0));
  end component;
  --signals local only to the present ip
  signal  input_data : std_logic_vector (15 downto 0);
  signal   ctrl_data : std_logic_vector (3 downto 0);
  signal output_data : std_logic_vector (15 downto 0);
  --signals related to the file operations
  file   output_file : text;
begin
    DUT : barrel_shifter port map (input  => input_data,
                                   ctrl   => ctrl_data,
                                   output => output_data);
    process 
      variable input_line : line;
      variable output_line: line;
    begin
      file_open(output_file, "output.txt", write_mode);

      -- STIMULATE THE DESIGN - PART 1
      -- Initialize the input
      input_data <= (others => '0');
      ctrl_data  <= (others => '0');
      wait for 10 ns;
      write(output_line, output_data, right, 16);
      writeline(output_file, output_line);
      for i in 1 to 15 loop
        input_data <= std_logic_vector(unsigned(input_data) + 1);
        ctrl_data  <= std_logic_vector(unsigned(ctrl_data)  + 1);
        wait for 10 ns;
        write(output_line, output_data, right, 16);
        writeline(output_file, output_line);
      end loop;
      
      -- STIMULATE THE DESIGN - PART 2
      -- Add your test cases here , use a granularity of 10ns between 3 test cases
      -- and write the output_line into the file following the following format (5 lines below)
        -- input_data <= "0000000000000001";
        -- ctrl_data <= "0010";
        -- wait for 10 ns;
        -- write(output_line, output_data, right, 16);
        -- writeline(output_file_info, output_line);

      -- ADD TEST CASE 1 BELOW THIS LINE
      input_data <= "0000100100000000";
      ctrl_data <= "0011";
      wait for 10 ns;
      write(output_line, output_data, right, 16);
      writeline(output_file, output_line);
      -- ADD TEST CASE 2 BELOW THIS LINE
      input_data <= "0000010000000001";
      ctrl_data <= "0010";
      wait for 10 ns;
      write(output_line, output_data, right, 16);
      writeline(output_file, output_line);
      -- ADD TEST CASE 3 BELOW THIS LINE
      input_data <= "0000010000000111";
      ctrl_data <= "0011";
      wait for 10 ns;
      write(output_line, output_data, right, 16);
      writeline(output_file, output_line);

      -- assert false
      file_close(output_file);
      report "Test completed";
      stop(0);
    end process;

end tb_behav_barrel;    
