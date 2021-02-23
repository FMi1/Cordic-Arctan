library IEEE;
use IEEE.std_logic_1164.all;

entity cordic_arctan_tb is
end entity cordic_arctan_tb;

architecture structural of cordic_arctan_tb is -- Testbench architecture declaration
	-----------------------------------------------------------------------------------
	-- Testbench constants
	-----------------------------------------------------------------------------------
	constant T_CLK   : time := 10 ns; -- Clock period
	constant T_RESET : time := 25 ns; -- Period before the reset deassertion
	-----------------------------------------------------------------------------------
	-- Testbench signals
	-----------------------------------------------------------------------------------
	signal num_tb	: std_logic_vector(11 downto 0);
	signal den_tb	: std_logic_vector(11 downto 0);
	signal ris_tb	: std_logic_vector(11 downto 0);
	signal rst_tb  : std_logic := '0'; -- reset signal
	signal clk_tb : std_logic := '0'; -- clock signal, intialized to '0' 
	
	signal end_sim : std_logic := '1'; -- signal to use to stop the simulation when there is nothing else to test
	-----------------------------------------------------------------------------------
	-- Component to test (DUT) declaration
	-----------------------------------------------------------------------------------
	component cordic_arctan is      -- be careful, it is only a component declaration. The component shall be instantiated after the keyword "begin" by linking the gates with the testbench signals for the test
		port(
			num : in std_logic_vector(11 downto 0);
			den : in std_logic_vector(11 downto 0);
			ris : out std_logic_vector(11 downto 0);
			rst : in std_logic;
			clk : in std_logic
		);
	end component;

	begin
	
		clk_tb <= (not(clk_tb) and end_sim) after T_CLK / 2;  -- The clock toggles after T_CLK / 2 when end_sim is high. When end_sim is forced low, the clock stops toggling and the simulation ends.
		rst_tb <= '1' after T_RESET; -- Deasserting the reset after T_RESET nanosecods (remember: the reset is active low).
	  
		test_cordic_arctan: cordic_arctan
			port map(
				num => num_tb,
				den => den_tb,
				ris => ris_tb,
				rst => rst_tb,
				clk => clk_tb
			);

		d_process: process(clk_tb, rst_tb) -- process used to make the testbench signals change synchronously with the rising edge of the clock
			variable t : integer := 0; -- variable used to count the clock cycle after the reset
		begin
		   	if(rst_tb = '0') then
				t := 0;
				num_tb <= "010010000001";
				den_tb <= "010011001101";

			elsif(rising_edge(clk_tb)) then
			  	case(t) is   -- specifying the input d_tb and end_sim depending on the value of t ( and so on the number of the passed clock cycles).
					when 13 => end_sim <= '0';
        	    			when others => null; -- Specifying that nothing happens in the other cases 			
			  	end case;
			  	t := t + 1; -- the variable is updated exactly here (try to move this statement before the "case(t) is" one and watch the difference in the simulation)
			end if;
		 end process;
end structural;

	