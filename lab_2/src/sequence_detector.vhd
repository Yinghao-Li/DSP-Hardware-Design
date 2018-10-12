--Engineer     :
--Date         :
--Name of file : sequence_detector.vhd
--Description  : implements a sequence detector
--               detecting "101110" using state machine

library ieee;
use ieee.std_logic_1164.all;

entity sequence_detector is
  port (
        clk, rst  : in  std_logic;
        data_in   : in  std_logic;
        data_out  : out std_logic
       );
end sequence_detector;
-- DO NOT MODIFY THE PORT NAME ABOVE

architecture arch of sequence_detector is
type state_type is (idle, s1, s2, s3, s4, s5);
  signal state: state_type;

begin
  process_0: process(clk, rst)
  begin
    if (rst = '1') then
      state <= idle;
    elsif (falling_edge(clk)) then
      case state is

        when idle =>
          if data_in = '0' then state <= idle;
          else state <= s1;
          end if;
          data_out <= '0';

        when s1 =>
          if data_in = '1' then state <= s1;
          else state <= s2;
          end if;
          data_out <= '0';

        when s2 =>
          if data_in = '0' then state <= idle;
          else state <= s3;
          end if;
          data_out <= '0';

        when s3 =>
          if data_in = '0' then state <= s2;
          else state <= s4;
          end if;
          data_out <= '0';

        when s4 =>
          if data_in = '0' then state <= s2;
          else state <= s5;
          end if;
          data_out <= '0';

        when s5 =>
          if data_in = '1' then
            state <= s1;
            data_out <= '0';
          else
            state <= s2;
            data_out <= '1';
          end if;

	when others => null;
      end case;
    end if;
  end process;
end arch;
