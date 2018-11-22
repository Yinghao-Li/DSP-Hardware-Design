--Engineer      : Yinghao Li
--Created       : 11/19/2018
--Last Modified : 11/19/2018
--Name of file  : encoder.vhd
--Description   : Implementation of convolutional encoder
--                input-extended version

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.coder_pkg.all;

entity encoder is
  --port list
  port(
    --input side
    clk, rst : in std_logic;
    data_in : in std_logic;
    next_in : out std_logic;
    --output side
    data_out : out std_logic_vector(1 downto 0);
    out_valid : out std_logic
  );
end encoder ;

architecture encoder_arch of encoder is
  
  signal count : unsigned(8 downto 0); -- FSM trigger
  signal out_sequence : std_logic_vector(1 downto 0); -- output

begin

  -- count process
  count_process: process(clk)
  begin
    if (rising_edge(clk)) then
      if (rst = '1') then
        count <= (others => '0');
      else
        if (count = ENCODER_STATE_NUM) then
          count <= (others => '0');
        else
          count <= count + 1;
        end if;
      end if;
    end if;
  end process;

  -- main process
  main_process: process(clk)
    variable window : std_logic_vector(2 downto 0); -- the content of sliding window
    variable p0 : std_logic;  -- parity bit 0 (MSB)
    variable p1 : std_logic;  -- parity bit 1 (LSB)
  begin
    if (rising_edge(clk)) then
      if (rst = '1') then
        window := "000";
        out_valid <= '0';
        next_in <= '0';
        out_sequence <= (others => '0');
      else

        -- activate input
        if (count = 0) then
          next_in <= '1';
        end if;
        -- deactivate input
        if (count = INPUT_LENGTH) then
          next_in <= '0';
        end if;

        -- if count = 1: do nothing. Waiting for input.

        -- sliding window convolution
        if (count > 1) then
          if (count < 2 + INPUT_LENGTH) then
            window := window(1 downto 0) & data_in;
            p0 := window(0) xor window(1) xor window(2);
            p1 := window(0) xor window(1);
            out_sequence <= p0 & p1;
          end if;
        end if;

        -- activate output
        if (count = 2) then
          out_valid <= '1';
        end if;
        -- deactivate output and reset window value.
        if (count = 2 + INPUT_LENGTH) then
          out_valid <= '0';
          window := "000";
        end if;
      end if;
    end if;
  end process;

  data_out <= out_sequence;

end encoder_arch;
