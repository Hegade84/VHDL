-- @team-members:
--     AMOUSSOU Z. Kenneth
--     Rushikesh Munde
--     Nitinchandra Hegade
--     Srinivasan Balakrishnan
--     Mahenth Jayakumar
--     Hatem Ahmed
--
-- @date: 22.11.2020
--
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity Adder is
  generic (
    -- Clock frequency of the adder in Hertz
    clockFrequencyHz: integer;

    -- Bit size of the adder
    -- This parameter would allow to extend the size of the adder is desired
    -- without changing the code
    size: integer
  );
  port(
    -- Buttons are used as input for the physical implementation
    -- Mapped to pin associated to the user button
    input: in std_logic;

    -- Mapped to pins associated to LEDs
    output: out std_logic_vector((size - 1) downto 0);

    -- clock signal
    clock: in std_logic;

    -- Mapped to the pin associated to the reset button
    reset: in std_logic
  );
end Adder;

--
-- Definition of the architecture of the adder
--
architecture AdderArch of Adder is
  type state_t is (
    INIT_STATE,         -- Initialization state (Reset all signals)
    IDLE_STATE,         -- Waiting for an action to occur
    DEBOUNCE_STATE,     -- Debounce the input
    READ_BIT_STATE,     -- Read an input as "0" or "1"
    OPERATION_STATE     -- Compute the output
  );
  constant INPUT_TIMEOUT: integer := clockFrequencyHz * 2;              -- Timeout 
  constant BIT_READING_TIME: integer := clockFrequencyHz / 66;          -- Debounce time to read bit 0 or 1   
  constant DEBOUNCE_TIME: integer := clockFrequencyHz / 200;            -- Debounce time to consider button press
  signal operands: std_logic_vector(0 to (2*size - 1));                 -- Number of input bits   
  alias A: std_logic_vector(0 to size-1) is operands(0 to size-1);      -- size of first inputs   
  alias B: std_logic_vector(0 to size-1) is operands(size to 2*size-1); -- size of second inputs 
  signal bitCount: integer range 0 to (2*size);                     
  signal timer: integer range 0 to (clockFrequencyHz * 120) := 0;       -- Current timer counter 
  signal currentState, nextState: state_t := INIT_STATE;                -- switching between states during execution. 
begin
  --
  -- Asynchronous input management process
  --
  asynchProcess: process (clock, reset)
  begin
    if reset = '0' then                     
      currentState <= INIT_STATE;                   -- Begin with Init state after reset 
      timer <= 0;
    elsif (rising_edge(clock)) then                 -- At every rising edge of the clock,
      if currentState /= nextState then
        timer <= 0;
      else
        timer <= timer + 1;                         -- Update timer counter. 
      end if;
      currentState <= nextState;                    -- Update the state.
    end if;
  end process asynchProcess;

  --
  -- State management process
  --
  stateProcess: process (currentState, input, timer)
  begin
    case (currentState) is
      when INIT_STATE =>                            -- Begin with init state 
        nextState <= IDLE_STATE;                    -- State change to Idle state 
        bitCount <= 0;                              -- Reset the data 
        output <= (others => '0');
      when IDLE_STATE =>                  
        if falling_edge(input) then                 -- Wait for falling_edge to occur
          nextState <= DEBOUNCE_STATE;            
        end if;
      when DEBOUNCE_STATE =>
        if (timer >= DEBOUNCE_TIME) then            -- Wait for the confirmation of falling edge,
          if (input = '0') then
            nextState <= READ_BIT_STATE;            -- if confirmed update state  
          else
            nextState <= IDLE_STATE;                -- if not go back to idle state 
          end if;
        end if;
      when READ_BIT_STATE =>
                if (bitCount >= 2*size) then        -- If bit count is full, 
          nextState <= OPERATION_STATE;             -- switch to operation state 
        elsif rising_edge(input) then               -- otherwise consider new input 
          if (timer < BIT_READING_TIME) then
            operands(bitCount) <= '0';
          else
            operands(bitCount) <= '1';
          end if;
          bitCount <= bitCount + 1;
          nextState <= IDLE_STATE;                  -- check for the new input again
        elsif (timer >= INPUT_TIMEOUT) then
          nextState <= INIT_STATE;                  -- at timeout switch to init state 
        end if;
      when OPERATION_STATE =>
        output <= std_logic_vector(unsigned(A) + unsigned(B));    -- Adder operation and result.
      when others =>
        nextState <= INIT_STATE;                                  -- For any other state switch to init state. 
    end case;
  end process stateProcess;
end AdderArch;
