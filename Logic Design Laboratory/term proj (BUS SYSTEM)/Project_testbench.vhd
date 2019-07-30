LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
ENTITY testbus IS
END testbus;
 
ARCHITECTURE behavior OF testbus IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT BUS_system
    PORT(
         FPGA_RSTB : IN  std_logic;
         FPGA_CLK : IN  std_logic;
         BASE_PUSH_SW0 : IN  std_logic;
         BASE_PUSH_SW1 : IN  std_logic;
         BASE_PUSH_SW2 : IN  std_logic;
         PUSH_SW0 : IN  std_logic;
         PUSH_SW1 : IN  std_logic;
         PUSH_SW2 : IN  std_logic;
         DIP_SW0 : IN  std_logic;
         DIP_SW123 : IN  std_logic_vector(2 downto 0);
         BUZZER : OUT  std_logic;
         LED : OUT  std_logic_vector(7 downto 0);
         LCD_A : OUT  std_logic_vector(1 downto 0);
         LCD_EN : OUT  std_logic;
         LCD_D : OUT  std_logic_vector(7 downto 0);
         DIGIT : OUT  std_logic_vector(6 downto 1);
         SEG_A : OUT  std_logic;
         SEG_B : OUT  std_logic;
         SEG_C : OUT  std_logic;
         SEG_D : OUT  std_logic;
         SEG_E : OUT  std_logic;
         SEG_F : OUT  std_logic;
         SEG_G : OUT  std_logic;
         SEG_DP : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal FPGA_RSTB : std_logic := '0';
   signal FPGA_CLK : std_logic := '0';
   signal BASE_PUSH_SW0 : std_logic := '1';
   signal BASE_PUSH_SW1 : std_logic := '1';
   signal BASE_PUSH_SW2 : std_logic := '1';
   signal PUSH_SW0 : std_logic := '1';
   signal PUSH_SW1 : std_logic := '1';
   signal PUSH_SW2 : std_logic := '1';
   signal DIP_SW0 : std_logic := '1';
   signal DIP_SW123 : std_logic_vector(2 downto 0) := (others => '1');

 	--Outputs
   signal BUZZER : std_logic;
   signal LED : std_logic_vector(7 downto 0);
   signal LCD_A : std_logic_vector(1 downto 0);
   signal LCD_EN : std_logic;
   signal LCD_D : std_logic_vector(7 downto 0);
   signal DIGIT : std_logic_vector(6 downto 1);
   signal SEG_A : std_logic;
   signal SEG_B : std_logic;
   signal SEG_C : std_logic;
   signal SEG_D : std_logic;
   signal SEG_E : std_logic;
   signal SEG_F : std_logic;
   signal SEG_G : std_logic;
   signal SEG_DP : std_logic;

   -- Clock period definitions
   constant FPGA_CLK_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: BUS_system PORT MAP (
          FPGA_RSTB => FPGA_RSTB,
          FPGA_CLK => FPGA_CLK,
          BASE_PUSH_SW0 => BASE_PUSH_SW0,
          BASE_PUSH_SW1 => BASE_PUSH_SW1,
          BASE_PUSH_SW2 => BASE_PUSH_SW2,
          PUSH_SW0 => PUSH_SW0,
          PUSH_SW1 => PUSH_SW1,
          PUSH_SW2 => PUSH_SW2,
          DIP_SW0 => DIP_SW0,
          DIP_SW123 => DIP_SW123,
          BUZZER => BUZZER,
          LED => LED,
          LCD_A => LCD_A,
          LCD_EN => LCD_EN,
          LCD_D => LCD_D,
          DIGIT => DIGIT,
          SEG_A => SEG_A,
          SEG_B => SEG_B,
          SEG_C => SEG_C,
          SEG_D => SEG_D,
          SEG_E => SEG_E,
          SEG_F => SEG_F,
          SEG_G => SEG_G,
          SEG_DP => SEG_DP
        );

   -- Clock process definitions
   FPGA_CLK_process :process
   begin
		FPGA_CLK <= '0';
		wait for FPGA_CLK_period/2;
		FPGA_CLK <= '1';
		wait for FPGA_CLK_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      wait for 10 us;	
		FPGA_RSTB <= '1';
		
		-- state 0000, 버스 종류를 7790으로 골라
		-- 버스의 문을 열고 탑승하고 check
		dip_sw123 <= "010";	-- number
		wait for 10 ns;	
		dip_sw0 <= '0';		-- door
		push_sw0 <= '0';		-- check
		wait for 500 us;	
		push_sw0 <= '1';
		wait for 500 us;	
		
		-- state 0001
		-- 문을 닫고 check
		dip_sw0 <= '1';		-- door
		push_sw0 <= '0';		-- check
		wait for 500 us;	
		push_sw0 <= '1';
		wait for 500 us;	
		
		-- gear를 넣어 s to A state가 된다
		PUSH_SW1 <= '0';		-- gear
		wait for 500 us;	
		PUSH_SW1 <= '1';
		wait for 40 ms;		
		
		BASE_PUSH_SW2 <= '0';	-- 벨을 누른다
		wait for 500 us;	
		BASE_PUSH_SW2 <= '1';
		wait for 45 ms;		

		-- 시간이 지나 자동으로 A 정류장에 도착한다
		-- A state에서 문을 연다
		dip_sw0 <= '0';		-- door
		wait for 500 us;
		
		-- 3명을 탑승시킨다
		dip_sw123 <= "011";	-- number
		PUSH_SW2 <= '0';		-- enable
		wait for 500 us;
		PUSH_SW2 <= '1';
		wait for 500 us;
		
		BASE_PUSH_SW0 <= '0';	-- INB
		wait for 500 us;
		BASE_PUSH_SW0 <= '1';
		wait for 500 us;
		
		-- 2명을 하차시킨다
		dip_sw123 <= "010";	-- number
		PUSH_SW2 <= '0';		-- enable
		wait for 500 us;
		PUSH_SW2 <= '1';
		wait for 500 us;
		
		BASE_PUSH_SW1 <= '0';	-- OUTB
		wait for 500 us;
		BASE_PUSH_SW1 <= '1';
		wait for 500 us;
		
		-- 2명 하차를 시도한다
		dip_sw123 <= "010";	-- number
		PUSH_SW2 <= '0';		-- enable
		wait for 500 us;
		PUSH_SW2 <= '1';
		wait for 500 us;
		
		BASE_PUSH_SW1 <= '0';	-- OUTB
		wait for 500 us;
		BASE_PUSH_SW1 <= '1';
		
		-- 3명을 탑승시킨다
		dip_sw123 <= "011";	-- number
		PUSH_SW2 <= '0';		-- enable
		wait for 500 us;
		PUSH_SW2 <= '1';
		wait for 500 us;
		
		BASE_PUSH_SW0 <= '0';	-- INB
		wait for 500 us;
		BASE_PUSH_SW0 <= '1';
		wait for 500 us;
		
		-- 문을 닫는다
		dip_sw0 <= '1';		-- door
		wait for 500 us;
		
		-- 출발한다. A to B
		PUSH_SW1 <= '0';		-- gear
		wait for 500 us;	
		PUSH_SW1 <= '1';
		wait for 170 ms;		
		
		-- 출발한다. B to C
		PUSH_SW1 <= '0';		-- gear
		wait for 500 us;	
		PUSH_SW1 <= '1';
		wait for 255ms;		
		
		-- 출발한다. C to D
		PUSH_SW1 <= '0';		-- gear
		wait for 500 us;	
		PUSH_SW1 <= '1';
		wait for 170ms;		
		
		-- 문을 열고 check를 눌러 총원을 확인한다
		dip_sw0 <= '0';		-- door
		wait for 500 us;	
		push_sw0 <= '0';		-- check
		wait for 500 us;	
		push_sw0 <= '1';
		
      wait;
   end process;
END;