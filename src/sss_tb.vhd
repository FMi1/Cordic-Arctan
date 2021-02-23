library IEEE;
use IEEE.std_logic_1164.all;

entity sss_tb is   -- The testbench has no interface, so it is an empty entity (Be careful: the keyword "is" was missing in the code written in class).
end sss_tb;

architecture bhv of sss_tb is -- Testbench architecture declaration
        -----------------------------------------------------------------------------------
        -- Testbench constants
        -----------------------------------------------------------------------------------
	constant T_CLK   : time := 10 ns; -- Clock period
	constant T_RESET : time := 25 ns; -- Period before the reset deassertion
	-----------------------------------------------------------------------------------
        -- Testbench signals
        -----------------------------------------------------------------------------------
	signal in1_tb	: std_logic_vector(17 downto 0);
	signal in2_tb	: std_logic_vector(17 downto 0);
	signal out1_tb	: std_logic_vector(17 downto 0);
	signal cmd_tb : std_logic := '0';
	signal rst_tb  : std_logic := '0'; -- reset signal
	signal clk_tb : std_logic := '0'; -- clock signal, intialized to '0' 

	signal end_sim : std_logic := '1'; -- signal to use to stop the simulation when there is nothing else to test
        -----------------------------------------------------------------------------------
        -- Component to test (DUT) declaration
        -----------------------------------------------------------------------------------
        component sss is      -- be careful, it is only a component declaration. The component shall be instantiated after the keyword "begin" by linking the gates with the testbench signals for the test
		generic(N : integer := 18);
			port(
				in1: in std_logic_vector(N-1 downto 0);
				in2: in std_logic_vector(N-1 downto 0);
				out1: out std_logic_vector(N-1 downto 0);
				cmd: in std_logic;
				rst: in std_logic;
				clk: in std_logic
			);
	end component;
	
	
	begin
	
	  clk_tb <= (not(clk_tb) and end_sim) after T_CLK / 2;  -- The clock toggles after T_CLK / 2 when end_sim is high. When end_sim is forced low, the clock stops toggling and the simulation ends.
	  rst_tb <= '1' after T_RESET; -- Deasserting the reset after T_RESET nanosecods (remember: the reset is active low).
	  
	  test_sss: sss  
              generic map(N => 18) -- It is necessary to specify the number of bits of the shift register (3 in this case). Try to change and watch the difference in the simulation.
	   	port map(
			in1 => in1_tb,
			in2 => in2_tb,
			out1 => out1_tb,
			cmd => cmd_tb,
			rst => rst_tb,
			clk => clk_tb
	           );
	  
	  	d_process: process(clk_tb, rst_tb) -- process used to make the testbench signals change synchronously with the rising edge of the clock
			variable t : integer := 0; -- variable used to count the clock cycle after the reset
	  	begin
	   		if(rst_tb = '0') then
				t := 0;
				report "RESET";
				cmd_tb <= '1';
			elsif(rising_edge(clk_tb)) then
		  		case(t) is   -- specifying the input d_tb and end_sim depending on the value of t ( and so on the number of the passed clock cycles).
		  			when 0 => in1_tb <= "000000000100000000"; -- d_tb is forced to '0' when t = 1.
						in2_tb <= "000000000000000001";
					when 1 => cmd_tb <= '0';
						in2_tb <= "000000000000000010";
					when 2 => in2_tb <= "000000000000000100";
					when 10 => end_sim <= '0'; -- This command stops the simulation when t = 10
            				when others => null; -- Specifying that nothing happens in the other cases 			
		  		end case;
		  		t := t + 1; -- the variable is updated exactly here (try to move this statement before the "case(t) is" one and watch the difference in the simulation)
			end if;
	 	end process;
	
end bhv;
