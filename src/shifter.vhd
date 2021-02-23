library IEEE;
use IEEE.std_logic_1164.all;

entity shifter is
	generic(N : integer := 18);
	port(
		din: in std_logic_vector(N-1 downto 0);
		dout: out std_logic_vector(N-1 downto 0);
		cmd: in std_logic_vector (2 downto 0) -- maximum value of i = 7, so at most din shifts to the right 7 bits
	);
end shifter;

architecture bhv of shifter is

	signal worker1, worker2:  std_logic_vector(N-1 downto 0); -- internal signals, temporary variables
	
	begin
-- **********************************************************************
-- According to the value of the 3 bits of the cmd word we right shift a different number of locations
--	-> cmd(0) = '1' => right-shift of 1 location
--	-> cmd(1) = '1' => right-shift of 2 locations
--	-> cmd(2) = '1' => right-shift of 4 locations
-- **********************************************************************
		shift_by_one:process(din, cmd(0))
		begin
			if(cmd(0)='1') then
				worker1(N-1) <= din(N-1);
				worker1(N-2 downto 0) <= din(N-1 downto 1);
			else
				worker1(N-1 downto 0) <= din(N-1 downto 0);
			end if;
		end process;
	
		shift_by_two:process(worker1, cmd(1))
		begin
			if(cmd(1)='1') then
				worker2(N-1) <= worker1(N-1);
				worker2(N-2) <= worker1(N-1);
				worker2(N-3 downto 0) <= worker1(N-1 downto 2);
			else
				worker2(N-1 downto 0) <= worker1(N-1 downto 0);
			end if;
		end process;

		shift_by_four:process(worker2, cmd(2))
		begin
			if(cmd(2)='1') then
				dout(N-1) <= worker2(N-1);
				dout(N-2) <= worker2(N-1);
				dout(N-3) <= worker2(N-1);
				dout(N-4) <= worker2(N-1);
				dout(N-5 downto 0) <= worker2(N-1 downto 4);
			else
				dout(N-1 downto 0) <= worker2(N-1 downto 0);
			end if;
		end process;
end bhv;