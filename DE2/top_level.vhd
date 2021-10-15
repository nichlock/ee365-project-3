library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity top_level is
    generic(
	   N: integer := 8;
	   DEB: std_logic_vector(15 downto 0) := X"FFFF";
	   MAX_CARS: std_logic_vector(7 downto 0) := X"0E"
	 );
    port (
    iRst       : in STD_LOGIC; 
    iClk       : in STD_LOGIC; 
    iA         : in STD_LOGIC;
    iB         : in STD_LOGIC;
    oMaxCars   : out STD_LOGIC;
	 oCount     : out STD_LOGIC_VECTOR(N-1 downto 0)
    );
end top_level;


architecture Structural of top_level is
  
 component univ_bin_counter is
	 generic(N: integer := N);
	 port(
		clk        : in std_logic;
		reset      : in std_logic;
		syn_clr    : in std_logic;
		load       : in std_logic;
		en         : in std_logic := '1';
		up         : in std_logic;
		clk_en     : in std_logic := '1';
		d          : in std_logic_vector(N-1 downto 0) := (others => '0');
		max_tick   : out std_logic;
		min_tick   : out std_logic;
		q          : out std_logic_vector(N-1 downto 0)
	 );
  end component;
  
  component encoder_sm is
    port(
           clock  : in   STD_LOGIC;
           reset  : in   STD_LOGIC;
           a      : in   STD_LOGIC;
           b      : in   STD_LOGIC;
           add    : out  STD_LOGIC;
           sub    : out  STD_LOGIC
    );
  end component;
  
  -- Signals from the state machine
  signal add_this_cycle :std_logic;
  signal sub_this_cycle :std_logic;
  
  -- Counter logic signals
  signal ctr_up :std_logic;
  signal ctr_count_this_cycle :std_logic := '0';
  signal ctr_over_under_flow_prevent :std_logic := '0';
  signal ctr_reached_max :std_logic := '0';
  signal ctr_reached_min :std_logic := '0';
  -- Counter register output signals
  signal ctr_count_this_cycle_q :std_logic := '0';
  signal ctr_over_under_flow_prevent_q :std_logic := '0';
  
  -- Internal logic for maximum cars allowed
  signal reached_max_cars_allowed :std_logic := '0';
  signal counter_value :STD_LOGIC_VECTOR(N-1 downto 0);
  
  begin
  
  -- COUNTER RESET AND DIRECTION LOGIC ----------------------------------------
  ctr_count_this_cycle <= (add_this_cycle OR sub_this_cycle) AND (NOT ctr_over_under_flow_prevent);
  ctr_up <= add_this_cycle;
  -- Prevents over/underflow by just not counting when it wants to count too high or low
  ctr_over_under_flow_prevent <= (add_this_cycle AND (ctr_reached_max OR reached_max_cars_allowed)) OR (sub_this_cycle AND ctr_reached_min);
  -- MAXIMUM CARS ALLOWED LOGIC -----------------------------------------------
  reached_max_cars_allowed <= '1' when unsigned(counter_value) = unsigned(MAX_CARS) else
                              '0';
  oMaxCars <= reached_max_cars_allowed;

  oCount <= counter_value;
  
  -- COUNTER REGISTERS FOR RST/DIR LOGIC --------------------------------------
  PROCESS (iClk)
   BEGIN
     IF iClk'EVENT AND iClk = '0' THEN
		  ctr_count_this_cycle_q <= ctr_count_this_cycle;
		  ctr_over_under_flow_prevent_q <= ctr_over_under_flow_prevent;
	  END IF;
   END PROCESS;
  -- END Counter registered values

  -- COUNTER AND STATE MACHINE ------------------------------------------------
  counter: univ_bin_counter 
    port map (
		clk        => iClk,
		reset      => iRst,
		syn_clr    => iRst,
		load       => iRst,
		--en         => , -- Always enabled
		up         => ctr_up,
		clk_en     => ctr_count_this_cycle,
		max_tick   => ctr_reached_max,
		min_tick   => ctr_reached_min,
		q          => counter_value
    );
	 
  state_machine: encoder_sm 
    port map (
	   clock  => iClk,
	   reset  => iRst,
	   a      => iA,
	   b      => iB,
	   add    => add_this_cycle,
	   sub    => sub_this_cycle
    );

end Structural;