library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use std.textio.all;

entity sss is

	generic(N : integer := 18);
	port(
		in1: in std_logic_vector(N-1 downto 0);
		in2: in std_logic_vector(N-1 downto 0);
		out1: out std_logic_vector(N-1 downto 0);
		cmd: in std_logic;
		rst: in std_logic;
		clk: in std_logic
	);

end sss;

architecture structural of sss is
-----------------------------------------------------------------------------------------
-- COMPONENTS
-----------------------------------------------------------------------------------------
	component dff is
		generic( N : integer := 18);	
		
		port( 
			d : in std_logic_vector(N - 1 downto 0); -- Input of the register
			q : out std_logic_vector(N - 1 downto 0); -- Output of the register
	       		clk : in std_logic;
	        	rst : in std_logic                
		);
	end component dff;

	component onecompl_adder is
		generic ( N : integer := 18); 
	
		port (
			a : in std_logic_vector(N-1 downto 0);
			b : in std_logic_vector(N-1 downto 0);
			c_in : in std_logic;
			res : out std_logic_vector(N-1 downto 0);
			c_out : out std_logic
		);
	end component onecompl_adder;

----------------------------------------------------------------------------------------------
-- Internal signals
----------------------------------------------------------------------------------------------
	signal din_selected : std_logic_vector(N-1 downto 0);
	signal dff_out : std_logic_vector(N-1 downto 0);
	signal add_result : std_logic_vector(N-1 downto 0);
	signal previous_carry : std_logic;

	begin
		DFF1 : dff
			port map(add_result, dff_out, clk, rst);


		ONECOMPLEADDER : onecompl_adder
			port map(din_selected, in2, previous_carry, add_result, previous_carry);


		MULTIPLEXER : process(in1, cmd, dff_out)
			begin
				if(cmd ='1') then
					din_selected <= in1;
				else
					din_selected <= dff_out;
				end if;
			end process MULTIPLEXER;
		
		out1 <= dff_out;

end structural;






