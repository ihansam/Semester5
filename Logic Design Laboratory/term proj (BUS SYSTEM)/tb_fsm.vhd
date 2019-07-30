LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
 
ENTITY testbench IS
END testbench;
 
ARCHITECTURE behavior OF testbench IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT FSM
    PORT(
         FPGA_RSTB : IN  std_logic;
         st_clk : IN  std_logic;
         check : IN  std_logic;
         accel : IN  std_logic;
         door : IN  std_logic;
         time_left : IN  std_logic_vector(6 downto 0);
         state : OUT  std_logic_vector(3 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal FPGA_RSTB : std_logic := '0';
   signal st_clk : std_logic := '0';
   signal check : std_logic := '1';
   signal accel : std_logic := '1';
   signal door : std_logic := '1';
   signal time_left : std_logic_vector(6 downto 0) := (others => '0');

 	--Outputs
   signal state : std_logic_vector(3 downto 0);

   -- Clock period definitions
   constant st_clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: FSM PORT MAP (
          FPGA_RSTB => FPGA_RSTB,
          st_clk => st_clk,
          check => check,
          accel => accel,
          door => door,
          time_left => time_left,
          state => state
        );

   -- Clock process definitions
   st_clk_process :process
   begin
		st_clk <= '0';
		wait for st_clk_period/2;
		st_clk <= '1';
		wait for st_clk_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
		
		wait for 10 ns;
		
		FPGA_RSTB <= '1';
		wait for 10 ns;
		
		check <= '0';
		wait for 10 ns;
		
		check <= '1';
		wait for 100 ns;

		check <= '0';
		wait for 10 ns;
		
		check <= '1';
		wait for 100 ns;

		accel <= '0';			-- s to a
		wait for 10 ns;
		
		accel <= '1';
		time_left <= "1111111";
		wait for 100 ns;
		
		time_left <= "0000000";
		wait for 100 ns;
		
		door <= '0';
		wait for 100 ns;
		
		door <= '1';
		wait for 100 ns;
		
		accel <= '0';		-- a to b
		wait for 10 ns;
		
		accel <= '1';
		time_left <= "1111111";
		wait for 100 ns;
		
		time_left <= "0000000";
		wait for 100 ns;
		
		accel <= '0';		-- b to c
		wait for 10 ns;
		
		accel <= '1';
		time_left <= "1111111";
		wait for 100 ns;
		
		time_left <= "0000000";
		wait for 100 ns;
		
		accel <= '0';		-- c to d
		wait for 10 ns;
		
		accel <= '1';
		time_left <= "1111111";
		wait for 100 ns;
		
		time_left <= "0000000";
		wait for 100 ns;
		
		door <= '0';
		wait for 100 ns;

		
		
		
		
		
		check <= '0';
		wait for 10 ns;
		
		check <= '1';
		wait for 100 ns;
		
		
		wait;
   end process;

END;
