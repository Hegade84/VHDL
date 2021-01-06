-- @team-members:
--     AMOUSSOU Z. Kenneth
--     Rushikesh Munde
--     Nitinchandra Hegade
--     Srinivasan Balakrishnan
--     Mahenth Jayakumar
--     Hatem Ahmed
--
-- @date: 22-11-2020
-- @simulation-time: 9035 ms
--
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_adder is
end tb_adder;

-- Testbench architecture definition of the adder 

architecture tb_adder_arch of tb_adder is

  type TESTBENCH is array (0 to 15) of std_logic_vector(0 to 15);    -- Array of test input values

  constant size: integer := 8;                    
  constant Frequency: integer := 1e03;                               -- Clock frequency 
  constant T: time := 1 ms; -- 1ms / (1000 * Frequency);             -- Clock time

  signal encoding : std_logic_vector(0 to 15):=("0011010101010101"); -- Encoding Signal
  signal input: std_logic := '1';                                    -- Initialization of data 
  signal output: std_logic_vector(size-1 downto 0);
  signal clock: std_logic := '0';
  signal reset: std_logic := '1';

  signal testtable: TESTBENCH := (                                   -- Input values 
    "0101000000011001",
    "0000000000000001",
    "0000000000001111",
    "0000000100000001",
    "0000000100000011",
    "0000001100000011",
    "0000100000000001",
	"0000000000000000",
    "0000110000000010",
    "0011110001100011",
    "1001011000001111",
    "0000001111000000",
    "1100000000011111",
    "1111111100000001",
    "1111111100000110",
    "1111111111111111"
  );
  signal tb_sum: std_logic_vector(size - 1 downto 0);                -- result of operation

begin
  Adder: entity work.Adder(AdderArch)
  generic map (clockFrequencyHz => Frequency, size => size)
  port map (
    input => input,
    output => output,
    clock => clock,
    reset => reset
  );

  -- Clock generation
  clocking: process
  begin
    clock <= '1';
    wait for T/2;
    clock <= '0';
    wait for T/2;
  end process clocking;

-- Reading of inputs bits. 

  process
  begin
    wait for 5 ms;
    for tb_index in 0 to (testtable'length - 1) loop
      reset <= '0', '1' after 1 ms;
      wait for 2 ms;
      for input_bit_index in 0 to (testtable(tb_index)'length - 1) loop  
        if encoding(input_bit_index) = '0' then
		if testtable(tb_index)(input_bit_index) = '0' then
          input <= '0';
          wait for 8 ms;
      	  input <= '1';
      	  wait for 5 ms;
        else
          input <= '0';
          wait for 23 ms;
      	  input <= '1';
      	  wait for 5 ms; 
		end if;
		else
		if testtable(tb_index)(input_bit_index) = '0' then
          input <= '0';
          wait for 19 ms;
      	  input <= '1';
      	  wait for 5 ms;
        else
          input <= '0';
          wait for 40 ms;
      	  input <= '1';
      	  wait for 5 ms; 
		end if;
		end if;
		end loop;
      tb_sum <= std_logic_vector(unsigned(testtable(tb_index)(0 to size - 1)    -- perform the sum operation
        ) + unsigned(testtable(tb_index)(size to 2*size - 1)));
      wait for 1 ms;
      assert output = tb_sum report "Error in addition result." severity failure;    
    end loop;


    -- Input line held "low" but never released test case
    reset <= '0', '1' after 1 ms;
    wait for 2 ms;
    input <= '0';
    wait for (3 * Frequency) * T;
    -- The state machine is expected to be in idle state

    -- All the entries have been covered so the testbench can be stopped
    assert false report "End of simulation" severity failure;
  end process;
end tb_adder_arch;
