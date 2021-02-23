library ieee;
use ieee.std_logic_1164.all;


entity dff is
	generic( N : integer := 18);
		
	port( 
		d : in std_logic_vector(N - 1 downto 0); -- Input of the register
		q : out std_logic_vector(N - 1 downto 0); -- Output of the register
	        clk : in std_logic;
	        rst : in std_logic                
	);
end dff;
   

architecture bhv of dff is

	begin
		dff_proc : process(clk, rst)
			begin
				if(rst = '0') then
					q <= (N - 1 downto 0 => '0');
				elsif(clk = '1' and clk'event) then
					q <= d;
				end if;
		end process;
end bhv;