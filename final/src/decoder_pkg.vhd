--Engineer      : Yinghao Li
--Created       : 11/01/2018
--Last Modified : 11/15/2018
--Name of file  : decoder_pkg.vhd
--Description   : Implementation of Viterbi Decoding Algorithm

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package decoder_pkg is

  constant STATE_NUM : integer := 19; -- TODO: subject to change

  type node is record -- a node in trellis
    pm: unsigned (7 downto 0); -- path metric TODO: length subject to change
    bw: unsigned (1 downto 0); -- the previous connected node
  end record;

  type layer_tp is array (0 to 3) of node; -- a layer of trellis
  type trellis_tp is array (0 to 8) of layer_tp; -- the whole trellis

  type bm_tp is array (0 to 1) of unsigned(1 downto 0);
  type bm_all_tp is array (0 to 3) of bm_tp;
  type pm_tp is array (0 to 1) of unsigned(7 downto 0); -- length should be the same as node.pm
  type pm_all_tp is array (0 to 3) of pm_tp;

  type coded_chain_tp is array (0 to 8) of unsigned(1 downto 0);

  function cal_hamming(
    code1: in unsigned(1 downto 0);
    code2: in unsigned(1 downto 0)
  ) return unsigned;

  function fw_lookup(
    addr: in unsigned(1 downto 0)
  ) return unsigned;

  -- FIXME: unsless function, just keep in case needed
  function bw_lookup(
    addr: in unsigned(1 downto 0)
  ) return unsigned;

end decoder_pkg;

package body decoder_pkg is

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

  function bw_lookup(
    addr: in unsigned(1 downto 0)
  ) return unsigned is
    variable bw_nd: unsigned(3 downto 0);
  begin
    case addr is
      when "00" => bw_nd := "0001";
      when "01" => bw_nd := "1011";
      when "10" => bw_nd := "0001";
      when "11" => bw_nd := "1011";
      when others => null;
    end case;
    return bw_nd;
  end bw_lookup;

end decoder_pkg;
