library IEEE;
use IEEE.std_logic_1164.all;

entity dff_tb is   -- The testbench has no interface, so it is an empty entity (Be careful: the keyword "is" was missing in the code written in class).
end dff_tb;

architecture bhv of dff_tb is -- Testbench architecture declaration
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
	signal d_tb	: std_logic_vector(17 downto 0);
	signal q_tb	: std_logic_vector(17 downto 0);
	signal end_sim : std_logic := '1'; -- signal to use to stop the simulation when there is nothing else to test
        -----------------------------------------------------------------------------------
        -- Component to test (DUT) declaration
        -----------------------------------------------------------------------------------
        component dff is      -- be careful, it is only a component declaration. The component shall be instantiated after the keyword "begin" by linking the gates with the testbench signals for the test
		generic( N : integer := 12);
		
		port( 
			d : in std_logic_vector(N - 1 downto 0); -- Input of the register
			q : out std_logic_vector(N - 1 downto 0); -- Output of the register
		        clk : in std_logic;
		        rst : in std_logic                
		);
	end component;
	
	
	begin
	
	  clk_tb <= (not(clk_tb) and end_sim) after T_CLK / 2;  -- The clock toggles after T_CLK / 2 when end_sim is high. When end_sim is forced low, the clock stops toggling and the simulation ends.
	  rst_tb <= '1' after T_RESET; -- Deasserting the reset after T_RESET nanosecods (remember: the reset is active low).
	  
	  test_dff: dff  
              generic map(N => 18) -- It is necessary to specify the number of bits of the shift register (3 in this case). Try to change and watch the difference in the simulation.
	   	port map(
			d => d_tb,
			q => q_tb,
			clk => clk_tb,
	                rst => rst_tb
	           );
	  
	  	d_process: process(clk_tb, rst_tb) -- process used to make the testbench signals change synchronously with the rising edge of the clock
			variable t : integer := 0; -- variable used to count the clock cycle after the reset
	  	begin
	   		if(rst_tb = '0') then
		  		--d_tb <= (others => '0' );
		  		t := 0;
			elsif(rising_edge(clk_tb)) then
		  		case(t) is   -- specifying the input d_tb and end_sim depending on the value of t ( and so on the number of the passed clock cycles).
		  			when 1 => d_tb <= "000000000000000001"; -- d_tb is forced to '0' when t = 1.
		  			when 2 => d_tb <= "001000000000000001"; -- d_tb is forced to '0' when t = 1.
					when 3 => d_tb <= "000000000000011111";
		  			when 4 => d_tb <= "000000000000000000"; -- d_tb is forced to '0' when t = 1.
		  			when 5 => d_tb <= "000000111100001111"; -- d_tb is forced to '0' when t = 1.
		  			when 6 => d_tb <= "000000000101010101"; -- d_tb is forced to '0' when t = 1.
		  			when 7 => d_tb <= "000010001000100001"; -- d_tb is forced to '0' when t = 1.
					when 10 => end_sim <= '0'; -- This command stops the simulation when t = 10
            				when others => null; -- Specifying that nothing happens in the other cases 
			
		  		end case;
		  		t := t + 1; -- the variable is updated exactly here (try to move this statement before the "case(t) is" one and watch the difference in the simulation)
			end if;
	 	end process;
	
end bhv;