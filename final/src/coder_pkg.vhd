--Engineer      : Yinghao Li
--Created       : 11/19/2018
--Last Modified : 11/21/2018
--Name of file  : coder_pkg.vhd
--Description   : Support package for both encoder and decoder

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package coder_pkg is

  constant INPUT_LENGTH : integer := 256; -- Bits of input message of incoder
  constant DECODER_STATE_NUM : integer := 771; -- 3 + 3 * INPUT_LENGTH
  constant ENCODER_STATE_NUM : integer := 258; -- 2 + INPUT_LENGTH

  type node is record -- a node in trellis
    pm: unsigned (9 downto 0); -- path metric. TODO: make sure this won't overflow
    bw: unsigned (1 downto 0); -- the previous connected node
  end record;

  type layer_tp is array (0 to 3) of node; -- a layer of trellis
  type trellis_tp is array (0 to INPUT_LENGTH) of layer_tp; -- the whole trellis

  type bm_tp is array (0 to 1) of unsigned(1 downto 0); -- the branch metric for a node
  type bm_all_tp is array (0 to 3) of bm_tp; -- the branch metric for a layer
  type pm_tp is array (0 to 1) of unsigned(9 downto 0); -- the path metric for a node
  type pm_all_tp is array (0 to 3) of pm_tp; -- the path metric for a layer

  type coded_chain_tp is array (0 to INPUT_LENGTH) of unsigned(1 downto 0); -- the path with smallest pm

  -- Calculate Hamming distance between 2 2-bit sequences
  function cal_hamming(
    code1: in unsigned(1 downto 0);
    code2: in unsigned(1 downto 0)
  ) return unsigned;

  -- Find the expected next pair of codes for a node
  function fw_lookup(
    addr: in unsigned(1 downto 0)
  ) return unsigned;

end coder_pkg;

package body coder_pkg is

  function cal_hamming(
    code1: in unsigned(1 downto 0);
    code2: in unsigned(1 downto 0)
  ) return unsigned is
    variable distance: unsigned(1 downto 0);
    variable diff: unsigned(1 downto 0);
    variable diff1: std_logic;
    variable diff0: std_logic;
  begin
    diff1 := code1(1) xor code2(1);
    diff0 := code1(0) xor code2(0);
    diff := diff1 & diff0;
    case diff is
      when "00" => distance := "00";
      when "01" => distance := "01";
      when "10" => distance := "01";
      when "11" => distance := "10";
      when others => null;
    end case;
    return distance;
  end cal_hamming;

  function fw_lookup(
    addr: in unsigned(1 downto 0)
  ) return unsigned is
    variable exp_code: unsigned(3 downto 0);
  begin
    case addr is
      when "00" => exp_code := "0011";
      when "01" => exp_code := "1001";
      when "10" => exp_code := "1100";
      when "11" => exp_code := "0110";
      when others => null;
    end case;
    return exp_code;
  end fw_lookup;

end coder_pkg;
