library IEEE;
use IEEE.std_logic_1164.all;

entity selector is
	generic (N: integer := 18);

	port(
		xin: in std_logic_vector (N-1 downto 0);
		cmd: in std_logic;
		xout: out std_logic_vector(N-1 downto 0)
	);
end selector;

architecture bhv of selector is
	begin
		selector_proc: process(cmd, xin)
		begin
			if(cmd='1') then
				xout <= not xin;
			else
				xout <= xin;
			end if;
		end process selector_proc;
end bhv;