LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY encoder IS
  PORT (
    CLOCK_50    : IN STD_LOGIC;								-- On Board 50 MHz
    KEY         : IN STD_LOGIC_VECTOR(1 DOWNTO 0);		-- Pushbutton[1:0]
    SW          : IN STD_LOGIC_VECTOR(3 DOWNTO 0);		-- Toggle Switch[3:0]
    LED         : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)		-- LED [7:0]
  );
  
END encoder;

ARCHITECTURE structural OF encoder IS

component top_level is
		generic(N: integer := 8; MAX_CARS: std_logic_vector(7 downto 0) := X"0E");
		port (
		  iRst       : in STD_LOGIC; 
		  iClk       : in STD_LOGIC; 
		  iA         : in STD_LOGIC;
		  iB         : in STD_LOGIC;
		  oCount     : out STD_LOGIC_VECTOR(7 downto 0)
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


  -- Debouncing
  signal safe_A   :std_logic;
  signal safe_B   :std_logic;
  signal safe_Rst :std_logic;
  signal safe_A_n :std_logic;
  signal safe_B_n :std_logic;

BEGIN

safe_A_n <= NOT safe_A;
safe_B_n <= NOT safe_B;

Inst_top_level: top_level 
		generic map(N => 8)
      port map(
			iRst	   => safe_Rst,
			iClk		=> CLOCK_50,
			iA 	   => safe_A_n,
			iB    	=> safe_B_n,
			oCount   => LED(7 downto 0)
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


