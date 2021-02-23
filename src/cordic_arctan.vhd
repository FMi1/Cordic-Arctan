library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use std.textio.all;



entity cordic_arctan is
	port(
		den : in std_logic_vector(11 downto 0);
		num : in std_logic_vector(11 downto 0);
		ris : out std_logic_vector(11 downto 0);
		rst: in std_logic;
		clk: in std_logic
	);
end cordic_arctan;

architecture structural of cordic_arctan is
--------------------------------------------------------------------------------------------------
-- debugging functions
--------------------------------------------------------------------------------------------------
	function to_bstring(sl : std_logic) return string is
		variable sl_str_v : string(1 to 3);  -- std_logic image with quotes around
		
		begin
			sl_str_v := std_logic'image(sl);
	  		return "" & sl_str_v(2);  -- "" & character to get string
	end function;

	function to_bstring(slv : std_logic_vector) return string is
		alias    slv_norm : std_logic_vector(1 to slv'length) is slv;
		variable sl_str_v : string(1 to 1);  -- String of std_logic
		variable res_v    : string(1 to slv'length);
	
		begin
			for idx in slv_norm'range loop
				sl_str_v := to_bstring(slv_norm(idx));
				res_v(idx) := sl_str_v(1);
			end loop;
	  		return res_v;
	end function;
-----------------------------------------------------------------------------------------
-- COMPONENTS
-----------------------------------------------------------------------------------------
	component selector is
		generic (N: integer := 18);

		port(
			xin: in std_logic_VECTOR (N-1 downto 0);
			cmd: in std_logic;
			xout: out std_logic_VECTOR(N-1 downto 0)
		);
	end component;

	component sss is 
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

	component shifter is
		generic(N : integer := 18);
		port(
			din: in std_logic_vector(N-1 downto 0);
			dout: out std_logic_vector(N-1 downto 0);
			cmd: in std_logic_vector (2 downto 0) -- maximum value of i = 7, so at most din shifts to the right 7 bits
		);
	end component;

	component rom is
		port(
			addr: in std_logic_vector(2 downto 0); -- rom address, 8 locations = 3 bit
			data: out std_logic_vector(11 downto 0) -- output datum 
		);
	end component;

---------------------------------------------------------------------------------------------------------
-- Internal Signals
---------------------------------------------------------------------------------------------------------
	-- higher part of circuit "worker"
	signal ext_num : std_logic_vector(17 downto 0);
	signal sel1_sss1 : std_logic_vector(17 downto 0);
	signal sss1_shifter1 : std_logic_vector(17 downto 0);
	signal shifter1_sel3: std_logic_vector(17 downto 0);
	signal sel3_sss2 : std_logic_vector(17 downto 0);

	-- lower part of circuit "worker"
	signal ext_den : std_logic_vector(17 downto 0);
	signal sel2_sss2 : std_logic_vector(17 downto 0);
	signal sss2_shifter2 : std_logic_vector(17 downto 0);
	signal shifter2_sel4: std_logic_vector(17 downto 0);
	signal sel4_sss1 : std_logic_vector(17 downto 0);
 
	-- control signals for selectors
	signal sign_num : std_logic;
	signal sign_b : std_logic;
	signal not_sign_b : std_logic;

	-- signals of circuit which produces result
	signal rom_sel5 : std_logic_vector(17 downto 0);
	signal sel5_sss3 : std_logic_vector(17 downto 0);
	signal sss3_out : std_logic_vector(17 downto 0); -- ext_ris

	-- utility signals
	signal iteration : std_logic_vector(2 downto 0); -- signal to count iterations
	-- signal clock 

	-- signal to "clean" the din2 of sss components
	signal real_sel4_sss1 : std_logic_vector(17 downto 0);
	signal real_sel3_sss2 : std_logic_vector(17 downto 0);
	signal real_sel5_sss3 : std_logic_vector(17 downto 0);

--****************************************************************************************
	signal start_computation : std_logic;
	signal selection : std_logic;
	signal end_computation : std_logic;
--****************************************************************************************
	
	begin
----------------------------------------------------------------------------------------------------
-- Mapping of components
---------------------------------------------------------------------------------------------------
-- SELECTORS
---------------------------------------------------------------------------------------------------
		-- selectors to select the proper input (case a < 0)
		SEL1 : selector
			port map(ext_num, sign_num, sel1_sss1);

		SEL2 : selector
			port map(ext_den, sign_num, sel2_sss2);
		
		-- selectors to select the proper din2 (ak or bk) for sss components of "worker"
		SEL3 : selector
			port map(shifter1_sel3, not_sign_b, sel3_sss2);

		SEL4 : selector
			port map(shifter2_sel4, sign_b, sel4_sss1);

		-- selector to select the proper angle (positive or negative)
		SEL5 : selector
			port map(rom_sel5, sign_b, sel5_sss3);

------------------------------------------------------------------------------------------------------
-- SSS COMPONENTS
------------------------------------------------------------------------------------------------------
		SSS1 : sss
			port map(sel1_sss1, real_sel4_sss1, sss1_shifter1, selection, rst, clk);
		
		SSS2 : sss
			port map(sel2_sss2, real_sel3_sss2, sss2_shifter2, selection, rst, clk);

		SSS3 : sss
			port map(B"000000000000000000", real_sel5_sss3, sss3_out, selection, rst, clk);

--------------------------------------------------------------------------------------------------------
-- SHIFTERS
--------------------------------------------------------------------------------------------------------
		SHIFTER1 : shifter
			port map(sss1_shifter1, shifter1_sel3, iteration);

		SHIFTER2 : shifter
			port map(sss2_shifter2, shifter2_sel4, iteration);

--------------------------------------------------------------------------------------------------------
-- ROM
--------------------------------------------------------------------------------------------------------
		ROM1 : rom
			port map(iteration, rom_sel5(11 downto 0));


--------------------------------------------------------------------------------------------------------
-- *****************************************************************************************************
-- *****************************************************************************************************
--------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------
-- MULTIPLEXING PROCESSES
--------------------------------------------------------------------------------------------------------
	--MULTIPLEXER1 : process(start_computation, sel4_sss1)
	MULTIPLEXER1 : process(selection, sel4_sss1)
		begin
			--if(start_computation = '0') then
			if(selection = '1') then
				real_sel4_sss1 <= (others => '0');
			else
				real_sel4_sss1 <= sel4_sss1;
			end if;
	end process MULTIPLEXER1;

	--MULTIPLEXER2 : process(start_computation, sel3_sss2)
	MULTIPLEXER2 : process(selection, sel3_sss2)
		begin
			--if(start_computation = '0') then
			if(selection = '1') then
				real_sel3_sss2 <= (others => '0');
			else
				real_sel3_sss2 <= sel3_sss2;
			end if;
	end process MULTIPLEXER2;

	--MULTIPLEXER3 : process(start_computation, sel5_sss3)
	MULTIPLEXER3 : process(selection, sel5_sss3)
		begin
			if(selection = '1') then
				real_sel5_sss3 <= (others => '0');
			else
				real_sel5_sss3 <= sel5_sss3;
			end if;
	end process MULTIPLEXER3;


---------------------------------------------------------------------------------------------------------
-- CORDIC ALGORITHM FOR ARCTAN PROCESS
---------------------------------------------------------------------------------------------------------
	CORDIC_ARCTAN_PROCESS : process(rst, clk)

		variable execute : std_logic := '0';
		variable counter : integer range 0 to 15;
		variable first_step : std_logic;
		variable line_v : line; --debugging

		begin
			if(rst ='0') then
					counter := 0;
					execute := '0';
					first_step := '1';
					start_computation <= '0';
					selection <= '1';

			elsif(clk = '1' and clk'event) then
					if(execute = '0' and start_computation <= '0') then
						if(den = B"000000000000" or den = B"111111111111") then
							report "CASO BASE DEN";
							execute := '0';
							ris <= B"000000000000";
						elsif(num = B"000000000000" or num = B"111111111111") then
							execute := '0';
							if(den(11) = '0') then
								ris <= B"010110100000";
							else
								ris <= B"101001011111";
							end if;
						else
							execute := '1';
							selection <= '1';
							counter := 0;
							start_computation <= '1';
							iteration <= std_logic_vector(to_unsigned(counter,3));
						end if;
					elsif(execute = '0' and start_computation <='1') then
						report "EXECUTE = 0, START_COMPUTATION = 1, ALGORITMO CONVERSO";

					else -- real execution of the algorithm execute = '1'
						selection <= '0';
						if(counter < 8) then
							if(sss2_shifter2 = B"000000000000000000" or sss2_shifter2 = B"111111111111111111") then
								-- to adjust the result as in documentation
								if(sss3_out(17)='0') then
									ris(10 downto 0) <= sss3_out(12 downto 2);
								else
									ris(10 downto 0) <= not sss3_out(12 downto 2);
								end if;
								ris(11) <= sss3_out(17);
								execute := '0';
							else
								if(first_step = '1') then
									first_step := '0';
								else
									counter := counter+1;
									iteration <= std_logic_vector(to_unsigned(counter,3));
								end if;
							end if;
						else -- counter = 8, execute = 1
							execute := '0';
							counter := 0;
							if(sss3_out(17)='0') then
								ris(10 downto 0) <= sss3_out(12 downto 2);
							else
								ris(10 downto 0) <= not sss3_out(12 downto 2);
							end if;
							ris(11) <= sss3_out(17);
						end if;
					end if;
			--write(line_v, to_bstring(sss1_shifter1));
			--writeline(output, line_v);

			end if;	
	end process CORDIC_ARCTAN_PROCESS;


----------------------------------------------------------------------------------------------------------------------
-- MANAGEMENT OF INTERNAL SIGNALS
----------------------------------------------------------------------------------------------------------------------
	sign_num <= num(11);
	sign_b <= sss2_shifter2(17);
	not_sign_b <= not sign_b;

	ext_num(15 downto 4) <= num;
	ext_num(17) <= num(11);
	ext_num(16) <= num(11);
	ext_num(3) <= num(11);
	ext_num(2) <= num(11);
	ext_num(1) <= num(11);
	ext_num(0) <= num(11);

	ext_den(15 downto 4) <= den;
	ext_den(17) <= den(11);
	ext_den(16) <= den(11);
	ext_den(3) <= den(11);
	ext_den(2) <= den(11);
	ext_den(1) <= den(11);
	ext_den(0) <= den(11);

	rom_sel5(17 downto 12) <= B"000000";

end structural;