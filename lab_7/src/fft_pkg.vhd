library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package fft_pkg is

  type data_in_t        is array (0 to 7) of signed (7 downto 0);
  type data_out_t       is array (0 to 7) of signed (15 downto 0);
  type data_temp_1_t    is array (0 to 7) of signed (10 downto 0);
  type data_temp_2_t    is array (0 to 7) of signed (13 downto 0);
  type w_t              is array (0 to 3) of signed (8 downto 0);

end fft_pkg;
