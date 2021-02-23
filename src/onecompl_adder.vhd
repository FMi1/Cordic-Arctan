library IEEE;
use IEEE.std_logic_1164.all;

entity onecompl_adder is
	generic(N: integer := 18);
	
	port(
		a : in std_logic_vector(N-1 downto 0);
		b : in std_logic_vector(N-1 downto 0);
		c_in : in std_logic;
		res : out std_logic_vector(N-1 downto 0);
		c_out : out std_logic
	);

end onecompl_adder;

architecture bhv of onecompl_adder is
	begin
		sum: process(a, b, c_in)
			variable internal_c: std_logic;
		
			begin
				internal_c:= c_in; -- first carry
		
				for i in 0 to N-1 loop
					res(i)<= a(i) xor b(i) xor internal_c;
					internal_c := (a(i) and b(i)) or (a(i) and internal_c) or (b(i) and internal_c);
				end loop;
				
				c_out <= internal_c;
			
		end process sum;
end bhv;
