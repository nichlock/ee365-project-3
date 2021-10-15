LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY encoder IS
  PORT (
    CLOCK_50    : IN STD_LOGIC;								-- On Board 50 MHz
    KEY         : IN STD_LOGIC_VECTOR(1 DOWNTO 0);		-- Pushbutton[1:0]
    SW          : IN STD_LOGIC_VECTOR(3 DOWNTO 0);		-- Toggle Switch[3:0]
    LED         : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);	-- LED [7:0]
	 MAX         : OUT STD_LOGIC;                       -- Max LED indicator
	 SEVEN_SEG   : OUT STD_LOGIC_VECTOR(13 DOWNTO 0)  -- Output to 2-digit seven segment display
  );
  
END encoder;

ARCHITECTURE structural OF encoder IS

component top_level is
		generic(N: integer := 8; MAX_CARS: std_logic_vector(7 downto 0) := X"19");
		port (
		  iRst       : in STD_LOGIC; 
		  iClk       : in STD_LOGIC; 
		  iA         : in STD_LOGIC;
		  iB         : in STD_LOGIC;
		  oCount     : out STD_LOGIC_VECTOR(7 downto 0);
		  oMaxCars   : out STD_LOGIC
		);
end component top_level;


component btn_debounce_toggle is
      GENERIC (CONSTANT CNTR_MAX : std_logic_vector(15 downto 0) := X"FFFF");
      port(
        BTN_I    : in   STD_LOGIC;
        CLK      : in   STD_LOGIC;
        BTN_O    : out  STD_LOGIC;
        TOGGLE_O : out  STD_LOGIC
      );
end component;

component seven_seg_interpreter is
		port (
		  iClk  : in STD_LOGIC;
		  iData : in STD_LOGIC_VECTOR(3 downto 0);
	     oData : out STD_LOGIC_VECTOR(6 downto 0)
      );
end component;


  -- Debouncing
  signal safe_A    :std_logic;
  signal safe_B    :std_logic;
  signal safe_Rst  :std_logic;
  signal safe_A_n  :std_logic;
  signal safe_B_n  :std_logic;
  signal count_out :std_logic_vector(7 downto 0); 

BEGIN

safe_A_n <= NOT safe_A;
safe_B_n <= NOT safe_B;
LED(7 downto 0) <= count_out(7 downto 0);

Inst_top_level: top_level 
		generic map(N => 8)
      port map(
			iRst	   => NOT safe_Rst,
			iClk		=> CLOCK_50,
			iA 	   => safe_A_n,
			iB    	=> safe_B_n,
			oCount   => count_out(7 downto 0),
			oMaxCars => MAX
		);
		
driver1: seven_seg_interpreter
		port map(
			iClk => CLOCK_50,
			iData => count_out(3 downto 0),
			oData => SEVEN_SEG(6 downto 0)
		
		);

driver2: seven_seg_interpreter
		port map(
			iClk => CLOCK_50,
			iData => count_out(7 downto 4),
			oData => SEVEN_SEG(13 downto 7)
		);
		
  -- DEBOUNCING ---------------------------------------------------------------
  debouncer_a: btn_debounce_toggle 
    port map (
      BTN_I     => KEY(0),
      CLK       => CLOCK_50,
      BTN_O     => safe_A
    );
	 
  debouncer_b: btn_debounce_toggle 
    port map (
      BTN_I     => KEY(1),
      CLK       => CLOCK_50,
      BTN_O     => safe_B
    );
	 
  debouncer_rst: btn_debounce_toggle 
    port map (
      BTN_I     => SW(0),
      CLK       => CLOCK_50,
      BTN_O     => safe_Rst
    );


END structural;


