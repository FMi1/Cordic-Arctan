library IEEE;
use IEEE.std_logic_1164.all;

entity onecompl_adder_tb is   -- The testbench has no interface, so it is an empty entity (Be careful: the keyword "is" was missing in the code written in class).
end onecompl_adder_tb;

architecture bhv of onecompl_adder_tb is -- Testbench architecture declaration
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
	signal a_tb	: std_logic_vector(17 downto 0);
	signal b_tb	: std_logic_vector(17 downto 0);
	signal c_in_tb : std_logic;
	signal res_tb	: std_logic_vector(17 downto 0);
	signal c_out_tb : std_logic;
	signal end_sim : std_logic := '1'; -- signal to use to stop the simulation when there is nothing else to test
        -----------------------------------------------------------------------------------
        -- Component to test (DUT) declaration
        -----------------------------------------------------------------------------------
        component onecompl_adder is      -- be careful, it is only a component declaration. The component shall be instantiated after the keyword "begin" by linking the gates with the testbench signals for the test
		generic(N: integer := 18);
	
		port(
			a : in std_logic_vector(N-1 downto 0);
			b : in std_logic_vector(N-1 downto 0);
			c_in : in std_logic;
			res : out std_logic_vector(N-1 downto 0);
			c_out : out std_logic
		);

	end component;
	
	
	begin
	
	  clk_tb <= (not(clk_tb) and end_sim) after T_CLK / 2;  -- The clock toggles after T_CLK / 2 when end_sim is high. When end_sim is forced low, the clock stops toggling and the simulation ends.
	  rst_tb <= '1' after T_RESET; -- Deasserting the reset after T_RESET nanosecods (remember: the reset is active low).
	  
	  test_onecompl_adder: onecompl_adder  
              
		generic map(N => 18) -- It is necessary to specify the number of bits of the shift register (3 in this case). Try to change and watch the difference in the simulation.
	   	port map(
			a => a_tb,
			b => b_tb,
			c_in => c_in_tb,
			res => res_tb,
			c_out => c_out_tb
	           );
	  
	  	d_process: process(clk_tb, rst_tb) -- process used to make the testbench signals change synchronously with the rising edge of the clock
			variable t : integer := 0; -- variable used to count the clock cycle after the reset
	  	begin
	   		if(rst_tb = '0') then
		  		a_tb <= (others => '0' );
		  		b_tb <= (others => '0' );
				c_in_tb <= '0';
				t := 0;
			elsif(rising_edge(clk_tb)) then
		  		case(t) is   -- specifying the input d_tb and end_sim depending on the value of t ( and so on the number of the passed clock cycles).
					when 0 => a_tb <= "000000000000000101";
						b_tb <= "110000000000000101";
						c_in_tb <= '0';		  			
					when 1 => a_tb <= "100000000000000001";
						b_tb <= "011000000000000001";
						c_in_tb <= '0';
					when 2 => a_tb <= "000001100000000000";
						b_tb <= "000000100000000001";
						c_in_tb <= '0'; 
					when 10 => end_sim <= '0'; -- This command stops the simulation when t = 10
            				when others => null; -- Specifying that nothing happens in the other cases 
		  		end case;
		  		t := t + 1; -- the variable is updated exactly here (try to move this statement before the "case(t) is" one and watch the difference in the simulation)
			end if;
	 	end process;
	
end bhv;