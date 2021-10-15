 library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity encoder_tb is
end encoder_tb ;

architecture tb of encoder_tb is
-- inputs for top_level
		signal rst				: std_logic;
		signal sys_clk			: std_logic;
		signal a 				: std_logic;
		signal b 				: std_logic;
		signal count_result	: STD_LOGIC_VECTOR(3 downto 0);
		signal max_cars		: std_logic;
		
		signal add_sig	: std_logic;
		signal sub_sig	: std_logic;

begin
-- PORT MAP TO TOP_LEVEL ------------------------------------------------------
   DUT : entity work.top_level
		-- Debounce takes 3 clock cycles to transition 
		generic map(N => 4, DEB=> X"0002", MAX_CARS => X"0E") 
			port map (
			iRst => rst,
			iClk => sys_clk,
			iA => a,
			iB => b,
			oMaxCars => max_cars,
			oCount => count_result
		);

clock_driver : process
begin -- Clock rising edge every 10 ns
	sys_clk <= '1';
	wait for 5ns;
	sys_clk <= '0';
	wait for 5ns;
end process;


tb1 : process
begin
	----------------------------------------------------------------------------
	----------------------------------------------------------------------------
   -- BEGIN TEST CODE ---------------------------------------------------------
	rst <= '1';
	a <= '0';
	b <= '0';
	wait for 1ns; -- Sample after clocking
	wait for 20ns; -- Settle registers
	assert (count_result = x"0") report "FAILED: Counter loaded non-zero initial value" severity error;
	rst <= '0';
	wait for 20ns;
	
	-- COUNTS UP AFTER FULL CYCLE ----------------------------------------------
	a <= '1';
	b <= '0';
	wait for 20ns;
	wait for 20ns; -- Settle registers
	assert (count_result = x"0") report "FAILED: Counter counted before it should have" severity error;
	a <= '1';
	b <= '1';
	wait for 20ns;
	assert (count_result = x"0") report "FAILED: Counter counted before it should have" severity error;
	a <= '0';
	b <= '1';
	wait for 20ns;
	assert (count_result = x"0") report "FAILED: Counter counted before it should have" severity error;
	a <= '0';
	b <= '0';
	wait for 20ns;
	assert (count_result = x"1") report "FAILED: Counter did not count up" severity error; 
	wait for 20ns;
	wait for 20ns; -- Settle registers
	assert (count_result = x"1") report "FAILED: Counter counted too many times" severity error;
	
	-- RESETS CORRECTLY --------------------------------------------------------
	rst <= '1';
	wait for 10ns;
	assert (count_result = x"0") report "FAILED: Counter reset failed or loaded a non-zero value" severity error;
	rst <= '0';
	wait for 10ns;
	
	-- COUNTS DOWN AFTER FULL CYCLE --------------------------------------------
	a <= '1'; b <= '0'; wait for 10ns; -- Up-count #1
	a <= '1'; b <= '1'; wait for 10ns;
	a <= '0'; b <= '1'; wait for 10ns;
	a <= '0'; b <= '0'; wait for 10ns;
	wait for 20ns; -- Settle registers
	a <= '1'; b <= '0'; wait for 10ns; -- up-count #2
	a <= '1'; b <= '1'; wait for 10ns;
	a <= '0'; b <= '1'; wait for 10ns;
	a <= '0'; b <= '0'; wait for 10ns;
	wait for 20ns; -- Settle registers
	assert (count_result = x"2") report "FAILED: Counter did not count up" severity error; 
	a <= '0'; b <= '1'; wait for 10ns; -- down-count #1
	a <= '1'; b <= '1'; wait for 10ns;
	a <= '1'; b <= '0'; wait for 10ns;
	a <= '0'; b <= '0'; wait for 10ns;
	wait for 20ns; -- Settle registers
	assert (count_result = x"1") report "FAILED: Counter did not count down" severity error;
	a <= '0'; b <= '1'; wait for 10ns; -- down-count #2
	a <= '1'; b <= '1'; wait for 10ns;
	a <= '1'; b <= '0'; wait for 10ns;
	a <= '0'; b <= '0'; wait for 10ns;
	wait for 20ns; -- Settle registers
	assert (count_result = x"0") report "FAILED: Counter did not count down" severity error;
	
	
	-- CANNOT UNDERFLOW --------------------------------------------------------
	a <= '0'; b <= '1'; wait for 10ns; -- down-count from zero
	a <= '1'; b <= '1'; wait for 10ns;
	a <= '1'; b <= '0'; wait for 10ns;
	a <= '0'; b <= '0'; wait for 10ns;
	wait for 20ns; -- Settle registers
	assert (count_result = x"0") report "FAILED: Counter underflowed" severity error;

	-- CANNOT OVERFLOW ---------------------------------------------------------
	for i in 0 to 15 loop
		-- This single-line up counts once, with register settling delay included
		a <= '1'; b <= '0'; wait for 10ns; a <= '1'; b <= '1'; wait for 10ns; a <= '0'; b <= '1'; wait for 10ns;	a <= '0'; b <= '0'; wait for 10ns; wait for 20ns;
	end loop;
	assert (count_result = x"E") report "FAILED: Counter did not get to max value or counted past MAX_CARS" severity error;
	-- Downcounts again
	a <= '0'; b <= '1'; wait for 10ns; -- down-count #1
	a <= '1'; b <= '1'; wait for 10ns;
	a <= '1'; b <= '0'; wait for 10ns;
	a <= '0'; b <= '0'; wait for 10ns;
	wait for 20ns; -- Settle registers
	assert (count_result = x"D") report "FAILED: Counter did not count down" severity error;
	
	-- END OF TEST CODE --------------------------------------------------------
	----------------------------------------------------------------------------
	----------------------------------------------------------------------------
	wait;
end process;
end tb;