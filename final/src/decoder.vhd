--Engineer      : Yinghao Li
--Created       : 11/01/2018
--Last Modified : 11/15/2018
--Name of file  : decoder.vhd
--Description   : Implementation of Viterbi Decoding Algorithm

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.decoder_pkg.all;

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
  signal count : unsigned(4 downto 0); -- TODO: length subject to change
  signal out_sequence : std_logic_vector(7 downto 0);

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
        if (count = STATE_NUM) then
          count <= (others => '0');
        else
          count <= count + 1;
        end if;
      end if;
    end if;
  end process;

  -- main process
  main_process: process(clk)
  variable bm_all : bm_all_tp;
  variable pm_all : pm_all_tp;
  variable temp_pm : unsigned(7 downto 0);
  variable out_node :unsigned(1 downto 0);
  variable coded_chain : coded_chain_tp;
  variable iter : integer;
  begin
    if (rising_edge(clk)) then
      if (rst = '1') then

        trellis(0)(0).pm <= (others => '0');
        for i in 1 to 3 loop
          trellis(0)(i).pm <= "10000000"; -- something large
        end loop;
        out_valid <= '0';
        next_in <= '0';
        out_sequence <= (others => '0');

      else

        iter := to_integer(count) - 1;

        if (count = 0) then
          next_in <= '1';
        end if;
        if (count = 8) then
          next_in <= '0';
        end if;

        -- if count = 1: do nothing.

        if (count > 1) then
          if (count < 10) then

            for i in 0 to 3 loop
              bm_all(i)(0) := cal_hamming(code, fw_lookup(to_unsigned(i, 2))(3 downto 2));
              bm_all(i)(1) := cal_hamming(code, fw_lookup(to_unsigned(i, 2))(1 downto 0));
            end loop;
            for i in 0 to 3 loop
              pm_all(i)(0) := trellis(iter-1)(i).pm + bm_all(i)(0);
              pm_all(i)(1) := trellis(iter-1)(i).pm + bm_all(i)(1);
            end loop;

            -- calculate pm for all nodes
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
        if (count = 10) then

          -- find the node with smallest pm
          temp_pm := trellis(8)(0).pm;
          out_node := "00";
          if (trellis(8)(1).pm < temp_pm) then
            temp_pm := trellis(8)(1).pm;
            out_node := "01";
          end if;
          if (trellis(8)(2).pm < temp_pm) then
            temp_pm := trellis(8)(2).pm;
            out_node := "10";
          end if;
          if (trellis(8)(3).pm < temp_pm) then
            out_node := "11";
          end if;

          -- construct path
          coded_chain(8) := out_node;
          for i in 0 to 7 loop
            coded_chain(7 - i) := trellis(8 - i)(to_integer(coded_chain(8 - i))).bw;
          end loop;

          -- decode from path
          for i in 0 to 7 loop
            if (coded_chain(i+1) < 2) then
              out_sequence(7-i) <= '0';
            else
              out_sequence(7-i) <= '1';
            end if;
          end loop;
        end if;

        if (count = 11) then
          out_valid <= '1';
        end if;
        if (count = 19) then
          out_valid <= '0';
        end if;

        if (count > 10) then
          if (count < 19) then
            data_out <= out_sequence(18-to_integer(count));
          end if;
        end if;

      end if;
    end if;
  end process;
  
end decoder_arch; 
