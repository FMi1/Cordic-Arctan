library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

entity rom is
	port(
		addr: in std_logic_vector(2 downto 0); -- rom address, 8 locations = 3 bit
		data: out std_logic_vector(11 downto 0) -- output datum 
	);
end rom;

architecture bhv of rom is

	type int_array is array (natural range 0 to 7) of std_logic_vector(11 downto 0); -- int_array type declaration

	constant rom : int_array := (

		-- binary value		-- natural value 	-- fixed point value

		0=>"101101000000",	-- 2880			-- 45°
		1=>"011010100100",	-- 1700			-- 26,5625°
		2=>"001110000010",	-- 898			-- 14,03125°
		3=>"000111001000",	-- 456			-- 7,125°
		4=>"000011100101",	-- 229			-- 3,578125°
		5=>"000001110011",	-- 115			-- 1,796875°
		6=>"000000111001",	-- 57			-- 0,890625°
		7=>"000000011101"	-- 29			-- 0,453125°
	);

	begin
		data <= rom(conv_integer(addr));
end bhv;