library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity rom_tb is   -- The testbench has no interface, so it is an empty entity (Be careful: the keyword "is" was missing in the code written in class).
end rom_tb;

architecture bhv of rom_tb is -- Testbench architecture declaration
        -----------------------------------------------------------------------------------
        -- Testbench constants
        -----------------------------------------------------------------------------------
	constant T_CLK   : time := 10 ns; -- Clock period
	constant T_RESET : time := 25 ns; -- Period before the reset deassertion
	-----------------------------------------------------------------------------------
        -- Testbench signals
        -----------------------------------------------------------------------------------
	signal clk_tb : std_logic := '0'; -- clock signal, intialized to '0' 
	signal rst_tb  : std_logic := '0'; -- reset signal
	signal addr_tb	: std_logic_vector(2 downto 0);
	signal data_tb	: std_logic_vector(11 downto 0);
	signal end_sim : std_logic := '1'; -- signal to use to stop the simulation when there is nothing else to test
        -----------------------------------------------------------------------------------
        -- Component to test (DUT) declaration
        -----------------------------------------------------------------------------------
        component rom is      -- be careful, it is only a component declaration. The component shall be instantiated after the keyword "begin" by linking the gates with the testbench signals for the test
		port(
			addr: in std_logic_vector(2 downto 0); -- rom address, 8 locations = 3 bit
			data: out std_logic_vector(11 downto 0) -- output datum 
		);
	end component;
	
	
	begin
	
	  clk_tb <= (not(clk_tb) and end_sim) after T_CLK / 2;  -- The clock toggles after T_CLK / 2 when end_sim is high. When end_sim is forced low, the clock stops toggling and the simulation ends.
	  rst_tb <= '1' after T_RESET; -- Deasserting the reset after T_RESET nanosecods (remember: the reset is active low).
	  
	  test_rom: rom  
              generic map(N => 18) -- It is necessary to specify the number of bits of the shift register (3 in this case). Try to change and watch the difference in the simulation.
	   	port map(
			addr => addr_tb,
			data => data_tb
	           );
	  
	  	d_process: process(clk_tb, rst_tb) -- process used to make the testbench signals change synchronously with the rising edge of the clock
			variable t : integer := 0; -- variable used to count the clock cycle after the reset
	  	begin
	   		if(rst_tb = '0') then
		  		t := 0;
			elsif(rising_edge(clk_tb)) then
				if(t < 8) then
					addr_tb <= std_logic_vector(to_unsigned(t,3));
				else
					end_sim <= '0';
				end if;
		  		t := t + 1;  --the variable is updated exactly here (try to move this statement before the "case(t) is" one and watch the difference in the simulation)
			end if;
	 	end process;
	
end bhv;
