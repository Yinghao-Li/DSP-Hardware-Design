--Engineer      : Yinghao Li
--Created       : 11/19/2018
--Last Modified : 11/21/2018
--Name of file  : decoder.vhd
--Description   : Implementation of Viterbi Decoding Algorithm
--                input-extended version

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.coder_pkg.all;

entity decoder is
  --port list
  port(
    --input side
    clk, rst : in std_logic;
    data_in : in std_logic_vector(1 downto 0);
    next_in : out std_logic;
    --output side
    data_out : out std_logic;
    out_valid : out std_logic
  );
end decoder ;

architecture decoder_arch of decoder is
  signal trellis : trellis_tp; -- the whole trellis
  signal code : unsigned(1 downto 0); -- the input encoded message
  signal count : unsigned(12 downto 0); -- FSM trigger. Won't overflow.
  signal out_sequence : std_logic_vector(INPUT_LENGTH - 1 downto 0); -- the whole decoded sequence

begin

  -- get encoded message for every state.
  code <= unsigned(data_in);

  -- count process
  count_process: process(clk)
  begin
    if (rising_edge(clk)) then
      if (rst = '1') then
        count <= (others => '0');
      else
        if (count = DECODER_STATE_NUM) then
          count <= (others => '0');
        else
          count <= count + 1;
        end if;
      end if;
    end if;
  end process;

  -- main process
  main_process: process(clk)
  variable bm_all : bm_all_tp; -- branch metrics for a whole layer
  variable pm_all : pm_all_tp; -- path matrics for a whole layer
  variable temp_pm : unsigned(9 downto 0); -- length same as node.pm
  variable out_node :unsigned(1 downto 0); -- the node in the last layer with the smallest cumulative pm
  variable coded_chain : coded_chain_tp; -- the path with smallest cumulative pm
  variable iter : integer; -- to_integer(count) - 1, for convenience.
  variable iter_1 : integer; -- to_integer(count) - 3 - INPUT_LENGTH, for convenience.
  variable iter_2 : integer; -- to_integer(count) - 3 - 2 * INPUT_LENGTH, for convenience.
  begin
    if (rising_edge(clk)) then
      if (rst = '1') then

        trellis(0)(0).pm <= (others => '0');
        for i in 1 to 3 loop
          trellis(0)(i).pm <= "1000000000"; -- something large
        end loop;
        out_valid <= '0';
        next_in <= '0';
        out_sequence <= (others => '0');

      else

        iter := to_integer(count) - 1;
        iter_1 := to_integer(count) - 3 - INPUT_LENGTH;
        iter_2 := to_integer(count) - 3 - 2 * INPUT_LENGTH;

        -- activate input
        if (count = 0) then
          next_in <= '1';
        end if;
        -- deactivate input
        if (count = INPUT_LENGTH) then
          next_in <= '0';
        end if;

        -- if count = 1: do nothing.

        if (count > 1) then
          if (count < 2 + INPUT_LENGTH) then

            -- calculate branch metrics for a layer
            for i in 0 to 3 loop
              bm_all(i)(0) := cal_hamming(code, fw_lookup(to_unsigned(i, 2))(3 downto 2));
              bm_all(i)(1) := cal_hamming(code, fw_lookup(to_unsigned(i, 2))(1 downto 0));
            end loop;
            -- calculate path metrics for a layer
            for i in 0 to 3 loop
              pm_all(i)(0) := trellis(iter-1)(i).pm + bm_all(i)(0);
              pm_all(i)(1) := trellis(iter-1)(i).pm + bm_all(i)(1);
            end loop;

            -- construct path and store cumulative pm in a new layer
            if (pm_all(0)(0) < pm_all(1)(0)) then
              trellis(iter)(0).pm <= pm_all(0)(0);
              trellis(iter)(0).bw <= "00";
            else
              trellis(iter)(0).pm <= pm_all(1)(0);
              trellis(iter)(0).bw <= "01";
            end if;
            if (pm_all(2)(0) < pm_all(3)(0)) then
              trellis(iter)(1).pm <= pm_all(2)(0);
              trellis(iter)(1).bw <= "10";
            else
              trellis(iter)(1).pm <= pm_all(3)(0);
              trellis(iter)(1).bw <= "11";
            end if;
            if (pm_all(0)(1) < pm_all(1)(1)) then
              trellis(iter)(2).pm <= pm_all(0)(1);
              trellis(iter)(2).bw <= "00";
            else
              trellis(iter)(2).pm <= pm_all(1)(1);
              trellis(iter)(2).bw <= "01";
            end if;
            if (pm_all(2)(1) < pm_all(3)(1)) then
              trellis(iter)(3).pm <= pm_all(2)(1);
              trellis(iter)(3).bw <= "10";
            else
              trellis(iter)(3).pm <= pm_all(3)(1);
              trellis(iter)(3).bw <= "11";
            end if;

          end if;
        end if;

        -- find the path with smallest pm
        if (count = 2 + INPUT_LENGTH) then

          -- find the node in the last layer with the smallest cumulative pm
          temp_pm := trellis(INPUT_LENGTH)(0).pm;
          out_node := "00";
          if (trellis(INPUT_LENGTH)(1).pm < temp_pm) then
            temp_pm := trellis(INPUT_LENGTH)(1).pm;
            out_node := "01";
          end if;
          if (trellis(INPUT_LENGTH)(2).pm < temp_pm) then
            temp_pm := trellis(INPUT_LENGTH)(2).pm;
            out_node := "10";
          end if;
          if (trellis(INPUT_LENGTH)(3).pm < temp_pm) then
            out_node := "11";
          end if;

          -- construct path
          coded_chain(INPUT_LENGTH) := out_node;
        end if;

        if (count > 2 + INPUT_LENGTH) then
          if (count < 3 + 2 * INPUT_LENGTH) then
            coded_chain(INPUT_LENGTH - 1 - iter_1) := 
              trellis(INPUT_LENGTH - iter_1)(to_integer(coded_chain(INPUT_LENGTH - iter_1))).bw;
          end if;
        end if;

        -- decode from path and sequencially output message (MSB->LSB)
        if (count > 2 + 2 * INPUT_LENGTH) then
          if (count < 3 + 3 * INPUT_LENGTH) then
            if (coded_chain(iter_2 + 1) < 2) then
              data_out <= '0';
            else
              data_out <= '1';
            end if;
          end if;
        end if;        

        -- activate output
        if (count = 3 + 2 * INPUT_LENGTH) then
          out_valid <= '1';
        end if;
        -- deactivate output
        if (count = 3 + 3 * INPUT_LENGTH) then
          out_valid <= '0';
        end if;

      end if;
    end if;
  end process;
  
end decoder_arch; 
