--Engineer     : Yanshen Su
--Date         : 9/02/2018
--Name of file : multiplier_lab4.vhd
--Description  : implements 2 simple 8b*8b signed multipliers
--               DSP slice with bubble collapsing

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity multiplier_lab4 is
  port (
        -- input side
        clk, rst   : in  std_logic;
        next_in    : out std_logic;
        in_valid   : in  std_logic;
        data_in_1  : in  signed (7 downto 0);
        data_in_2  : in  signed (7 downto 0);
        coef_in    : in  signed (7 downto 0);
        -- output side
        next_out   : in  std_logic;
        out_valid  : out std_logic;
        data_out_1 : out signed (15 downto 0);
        data_out_2 : out signed (15 downto 0)
       );
end multiplier_lab4;
-- DO NOT MODIFY PORT NAMES ABOVE


architecture arch of multiplier_lab4 is
  -- -------------- Stage P1 -----------------
  signal pipeline_stall_p1  : std_logic;
  signal data_valid_p1      : std_logic;
  signal data_in_ext_1      : signed (23 downto 0);
  signal data_in_ext_2      : signed (23 downto 0);
  signal data_concat_p1     : signed (24 downto 0);
  signal coef_ext_p1        : signed (7 downto 0);
  -- -------------- Stage P2 -----------------
  signal pipeline_stall_p2 : std_logic;
  signal data_valid_p2     : std_logic;
  signal data_mult_p2      : signed (32 downto 0);
  -- -------------- Stage P3 -----------------
  signal pipeline_stall_p3 : std_logic;
  signal data_valid_p3     : std_logic;
  signal data_out_1_p3     : signed (15 downto 0);
  signal data_out_2_p3     : signed (15 downto 0);
  signal sign_ext_data_2   : signed (1 downto 0);

begin
  -- -------------- Stage P1 -----------------
  -- sign extension and left shift
  data_in_ext_1 (23 downto 16) <= data_in_1;
  data_in_ext_1 (15 downto 0)  <= (others => '0'); -- pad 0
  data_in_ext_2 (7 downto 0)   <= data_in_2;
  data_in_ext_2 (23 downto 8)  <= (others => data_in_2 (7)); -- sign extension
  
  p1: process (clk)
  begin
    if (rising_edge(clk)) then
      if (rst = '1') then
        data_valid_p1 <= '0';
      elsif (pipeline_stall_p1 = '0') then
        data_valid_p1 <= in_valid;
        if (in_valid = '1') then
          data_concat_p1 <= (data_in_ext_1(23) & data_in_ext_1) + data_in_ext_2; -- we are sure this will not overflow
          coef_ext_p1(7 downto 0)  <= coef_in;
        end if;
      end if;
    end if;
  end process;

  -- -------------- Stage P2 -----------------

  p2: process (clk) 
  begin
    if (rising_edge(clk)) then
      if (rst = '1') then
        data_valid_p2 <= '0';
      elsif (pipeline_stall_p2 = '0') then
        data_valid_p2 <= data_valid_p1;
        if (data_valid_p1 = '1') then
          data_mult_p2 <= data_concat_p1 * coef_ext_p1; -- Get LSBs
        end if;
      end if;
    end if;
  end process;

  -- -------------- Stage P3 -----------------
  sign_ext_data_2 <= '0' & data_mult_p2(15);

  p3: process (clk) 
  begin
    if (rising_edge(clk)) then
      if (rst = '1') then
        data_valid_p3 <= '0';
      elsif (pipeline_stall_p3 = '0') then
        data_valid_p3 <= data_valid_p2;
        if (data_valid_p2 = '1') then
          data_out_1_p3 <= signed(data_mult_p2(31 downto 16)) + sign_ext_data_2; 
          data_out_2_p3 <= data_mult_p2(15 downto 0);
        end if;
      end if;
    end if;
  end process;
  -- -------------- Stall Signals  -----------------
  pipeline_stall_p1 <= data_valid_p1 and pipeline_stall_p2;
  pipeline_stall_p2 <= data_valid_p2 and pipeline_stall_p3;
  pipeline_stall_p3 <= data_valid_p3 and (not next_out);
  -- -------------- Output   -----------------
  next_in    <= not pipeline_stall_p1;
  out_valid  <= data_valid_p3;
  data_out_1 <= data_out_1_p3;
  data_out_2 <= data_out_2_p3;
end arch;
