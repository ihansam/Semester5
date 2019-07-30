-------------------- [Top Module] ---------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity BUS_system is
    port(FPGA_RSTB : IN STD_LOGIC;       -- RESET
        FPGA_CLK : IN STD_LOGIC;        -- FPGA Clock
        BASE_PUSH_SW0 : IN STD_LOGIC;   -- INB 버스를 타는 사람의 수를 입력하는 스위치
        BASE_PUSH_SW1 : IN STD_LOGIC;   -- OUTB 버스에서 내리는 사람의 수를 입력하는 스위치
        BASE_PUSH_SW2 : IN STD_LOGIC;   -- BELL 하차벨
        PUSH_SW0 : IN STD_LOGIC;        -- check 출발할 준비가 되거나 끝이 났을 때 모드를 바꿔주는 버튼
        PUSH_SW1 : IN STD_LOGIC;        -- accel 버스를 출발하게하는 엑셀버튼
        PUSH_SW2 : IN STD_LOGIC;        -- enable 한 정거장에 여러 명을 태울 수 있게 해주는 신호
        DIP_SW0 :  IN STD_LOGIC;        -- door 문 0이면 열리고 1이면 닫힌다.
        DIP_SW123 :  IN STD_LOGIC_VECTOR (2 downto 0);    -- 승객 승하차 / 차량속도를 정해주는 신호
        BUZZER : OUT STD_LOGIC;                       -- 버저 ( 1 : on / 0 : off) 
        LED : OUT  STD_LOGIC_VECTOR (7 downto 0);
        LCD_A : OUT STD_LOGIC_VECTOR(1 downto 0);   -- LCD Module      
        LCD_EN : OUT STD_LOGIC;
        LCD_D : OUT STD_LOGIC_VECTOR(7 downto 0);    
        DIGIT: OUT STD_LOGIC_VECTOR (6 downto 1);   -- LED Module     
        SEG_A : OUT STD_LOGIC;                                                     
        SEG_B : OUT STD_LOGIC;
        SEG_C : OUT STD_LOGIC;
        SEG_D : OUT STD_LOGIC;
        SEG_E : OUT STD_LOGIC;
        SEG_F : OUT  STD_LOGIC;
        SEG_G : OUT  STD_LOGIC;
        SEG_DP : OUT  STD_LOGIC);        
     
end BUS_system;

architecture Behavioral of BUS_system is
    component FSM
        port(FPGA_RSTB : IN STD_LOGIC;       -- RESET
        st_clk : IN STD_LOGIC;            -- state Clock
        check : IN STD_LOGIC;             -- 출발준비를 하기 위한 신호
        accel : IN STD_LOGIC;             -- 차량이 출발하기 위한 신호
        door : IN STD_LOGIC;              -- 문이 열리고 닫히는 신호
        time_left : IN STD_LOGIC_VECTOR (7 downto 0); --남은 시간을 받음 
        state : OUT STD_LOGIC_VECTOR (3 downto 0)); -- 현재 state를 내보내준다
    End component;
    
    component Calculator
        port(FPGA_RSTB : IN STD_LOGIC;       -- RESET
        st_clk : IN STD_LOGIC;            -- 1kHz Clock
        INB : IN STD_LOGIC;               -- 승객이 탑승하는 것을 받기 위한 신호
        OUTB : IN STD_LOGIC;              -- 승객이 하차하는 것을 받기 위한 신호
        ENABLE : IN STD_LOGIC;            -- 승객의 승하차 할 수 있는 상태를 임을 받는 신호
        state : IN STD_LOGIC_VECTOR (3 downto 0);  -- 현재의 상태 정류장인지 달리는 중인지 등을 표시
        number : IN STD_LOGIC_VECTOR (2 downto 0); -- 승객의 수, 속도 등 숫자를 받기 위한 신호
        data_out : OUT STD_LOGIC;         -- LCD에 데이터를 주는 상태임을 알려주는 변수
        addr : OUT STD_LOGIC_VECTOR(4 downto 0); -- LCD에 몇 번째 판에 데이터를 줄 지 알려주는 신호
        data : OUT STD_LOGIC_VECTOR(7 downto 0); -- LCD에 줄 데이터
        velocity : OUT STD_LOGIC_VECTOR (7 downto 0); -- 속도 / 차량의 종류를 결정 
        psg_cnt : OUT STD_LOGIC_VECTOR (7 downto 0); -- 승객의 수
        time_left : OUT STD_LOGIC_VECTOR (7 downto 0); --남은 시간 
        w_enable : IN STD_LOGIC; -- data_out을 계산하기 위한 
        door : IN STD_LOGIC); -- 다음 목적지까지 남은 시간
    End component;
    
    component LCD_Module
        port(FPGA_RSTB : IN STD_LOGIC;       -- RESET
        st_clk : IN STD_LOGIC;               -- 1KHZ의 Clock
        LCD_A : OUT STD_LOGIC_VECTOR(1 downto 0); -- address카운터를 쓰는 신호 
        LCD_EN : OUT STD_LOGIC;              -- LCD를 사용할 수 있게 해주는 신호
        LCD_D : OUT STD_LOGIC_VECTOR(7 downto 0); --LCD판에 줄 데이터
        data_out : IN STD_LOGIC;             -- Calculator로부터 데이터를 받기 위한 신호
        addr : IN STD_LOGIC_VECTOR(4 downto 0); 
        data : IN STD_LOGIC_VECTOR(7 downto 0);
        w_enable : OUT STD_LOGIC);
    End component;
    
    component LED_Module
        port(FPGA_RSTB : IN STD_LOGIC;       -- RESET
        st_clk : IN STD_LOGIC;            -- CLOCK
        velocity : IN STD_LOGIC_VECTOR (7 downto 0); --현재 차량의 속도  
        psg_cnt : IN STD_LOGIC_VECTOR (7 downto 0);  -- 승객의 수
        time_left : IN STD_LOGIC_VECTOR (7 downto 0); -- 남은 시간
        state : IN STD_LOGIC_VECTOR (3 downto 0); -- 현재의 상태 
        DIGIT: OUT STD_LOGIC_VECTOR (6 downto 1); -- 어떤 LED를 켤 지 결정하는 신호
        SEG_A : OUT STD_LOGIC;                                                     
        SEG_B : OUT STD_LOGIC;
        SEG_C : OUT STD_LOGIC;
        SEG_D : OUT STD_LOGIC;
        SEG_E : OUT STD_LOGIC;
        SEG_F : OUT  STD_LOGIC;
        SEG_G : OUT  STD_LOGIC;
        SEG_DP : OUT  STD_LOGIC);
    End component;
    
    signal load_100k : std_logic;        -- 100KHz 클락을 만들기 위한 신호
    signal make_clk : std_logic;          -- 100KHz 클락
    signal cnt_100k : std_logic_vector (7 downto 0); -- 100KHZ 클락을 만들기 위한 신호
    signal load_1k : std_logic;        -- 1kHz 클락을 만들기 위한 신호
    signal st_clk : std_logic;        -- 이 코드에서 사용할 클락
    signal cnt_1k : std_logic_vector (11 downto 0); -- 1KHZ클락을 만들기 위한 신호
    signal time_left : std_logic_vector (7 downto 0); -- 남은 시간
    signal state : STD_LOGIC_VECTOR (3 downto 0);     --현재 버스의 상태
    signal velocity : STD_LOGIC_VECTOR (7 downto 0);  --차량의 속도
    signal psg_cnt : STD_LOGIC_VECTOR (7 downto 0);   --승객의 수
    signal data_out : std_logic;                      
    signal addr : STD_LOGIC_VECTOR(4 downto 0);
    signal data : std_logic_vector (7 downto 0);
    signal w_enable : std_logic;
    
begin    
    -- 100KHz 클락을 만드는 프로세스
    process(FPGA_RSTB,FPGA_CLK,load_100k,cnt_100k)
    Begin
        if FPGA_RSTB = '0' then
            cnt_100k <= (others => '0');
            make_clk <= '0';
        elsif rising_edge (FPGA_CLK) then
            if load_100k = '1' then
                cnt_100k <= (others => '0');
                make_clk <= not make_clk;
            else
                cnt_100k <= cnt_100k + 1;
            end if;
        end if;
    end process;
    load_100k <= '1' when (cnt_100k = X"13") else '0';
    
    -- 1KHz 클락을 만드는 프로세스
    process(FPGA_RSTB,make_clk,load_1k,cnt_1k)
    Begin
        if FPGA_RSTB = '0' then
            cnt_1k <= (others => '0');
            st_clk <= '0';
        elsif rising_edge (make_clk) then
            if load_1k = '1' then
                cnt_1k <= (others => '0');
                st_clk <= not st_clk;
            else
                cnt_1k <= cnt_1k + 1;
            end if;
        end if;
    end process;
    load_1k <= '1' when (cnt_1k = X"31") else '0'; -- 49
     
    -- TOP MODULE 내에서 SUB MODULE들이 실행된다.
    B_FSM : FSM port map(FPGA_RSTB, st_clk, PUSH_SW0, PUSH_SW1,
                        DIP_SW0, time_left, state);
    B_cal : Calculator port map(FPGA_RSTB, st_clk, BASE_PUSH_SW0, BASE_PUSH_SW1,
                            PUSH_SW2, state, DIP_SW123, data_out, addr, data, velocity, psg_cnt, time_left, w_enable, DIP_SW0);
                            
    B_lcd : LCD_Module port map(FPGA_RSTB, st_clk, 
                            LCD_A, LCD_EN, LCD_D, data_out, addr, data, w_enable);
    B_led : LED_Module port map(FPGA_RSTB, st_clk,
                            velocity, psg_cnt,  time_left, state,
                            DIGIT, SEG_A, SEG_B, SEG_C, SEG_D,
                            SEG_E, SEG_F, SEG_G, SEG_DP);
    
  -- BUZZER
  process(FPGA_RSTB, st_clk, BASE_PUSH_SW2, DIP_SW0)
    begin        
        if FPGA_RSTB = '0' then
            BUZZER <= '0';
            LED <= (others => '0');
        elsif rising_edge(st_clk) then
            if BASE_PUSH_SW2 = '0' then -- 하차벨을 누르면
               LED <= (others => '1');    -- LED가 켜진다
               BUZZER <= '1';             -- 부저가 켜진다
            elsif BASE_PUSH_SW2 = '1' then --벨에서 손을 때면
               BUZZER <= '0'; -- 부저가 꺼진다
               if DIP_SW0 = '0' then -- 문이열리면
                  LED <= (others => '0');    -- LED가 꺼진다
               end if;
            end if;
         end if;
  end process;
    
    
end Behavioral;
-------------------- [FSM] --------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity FSM is
    port(FPGA_RSTB : IN STD_LOGIC;      -- RESET
        st_clk : IN STD_LOGIC;          -- state Clock
        check : IN STD_LOGIC;           -- 버스종류선택, 출발준비, 운행 종료(총 승객 표시)
        accel : IN STD_LOGIC;           -- 버스 출발
        door : IN STD_LOGIC;            -- 1: close, 0: open
        time_left : IN STD_LOGIC_VECTOR (7 downto 0);  -- 다음역까지의 남은 시간
        state : OUT STD_LOGIC_VECTOR (3 downto 0));         
end FSM;

architecture Behavioral of FSM is
   signal next_state : STD_LOGIC_VECTOR(3 downto 0);
   begin
   process(FPGA_RSTB, st_clk, check, accel, door, time_left)
   begin
      if (FPGA_RSTB = '0') then -- 초기화
         next_state <= "0000";  
      elsif rising_edge(st_clk) then
         case next_state is
            when "0000" => -- 초기상태
               if ( check = '0' and door = '0' ) then --준비가 완료되면
                  next_state <= "0001"; 
               end if;
            when "0001" => -- 버스종류선택  
               if (check = '0' and door = '1') then --버스를 선택 (버스 종류는 num으로선택한다)
                  next_state <= "0010"; 
               end if;
            when "0010" => -- 출발가능상태
               if ( accel = '0') then -- 출발버튼을 누르면
                  next_state <= "0011";
               end if;
            when "0011" => -- S -> A
               if time_left = "0000000" then -- 남은시간이 0일 때
                  next_state <= "0100";
               end if;
            when "0100" => -- A
               if (door = '0') then -- 문이 열렸을 때
                  next_state <= "0101";
               elsif (accel = '0') then -- Accel을 밟았을 때 / 출발 했을 때
                  next_state <= "0110";
               end if;
            when "0101" => -- Count_A
               if (door = '1') then -- 문이 닫혔을 때
                  next_state <= "0100";
               end if;
            when "0110" => -- A -> B
               if time_left = "0000000" then -- 남은시간이 0일 때
                  next_state <= "0111";
               end if;
            when "0111" => -- B
               if (door = '0') then -- 문이 열렸을 때
                  next_state <= "1000";
               elsif (accel = '0') then -- Accel을 밟았을 때 / 출발 했을 때
                  next_state <= "1001";
               end if;
            when "1000" => --count_B
               if (door = '1') then -- 문이 닫혔을 때
                  next_state <= "0111";
               end if;
            when "1001" => -- B -> C
               if time_left = "0000000" then -- 남은시간이 0일 때
                  next_state <= "1010";
               end if;
            when "1010" => -- C
               if (door = '0') then -- 문이 열렸을 때
                  next_state <= "1011";
               elsif (accel = '0') then -- Accel을 밟았을 때 / 출발 했을 때
                  next_state <= "1100";
               end if;
            when "1011" => --count_C
               if (door = '1') then -- 문이 닫혔을 때
                  next_state <= "1010";
               end if;
            when "1100" => -- C -> D
               if time_left = "0000000" then -- 남은시간이 0일 때
                  next_state <= "1101";
               end if;
            when "1101" => -- D
               if (door = '0') then  -- 문이 열렸을 때
                  next_state <= "1110";
               end if;
            when "1110" => --운행종료
               if (check = '0') then 
                  next_state <= "1111";
               end if;
            when others => -- 총 승객 표시
               next_state <= "1111";
            end case;
         end if;
      state <= next_state;  
   end process;
end Behavioral;
-------------------- [Calculator] --------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
entity Calculator is
    port(FPGA_RSTB : IN STD_LOGIC;       -- RESET
        st_clk : IN STD_LOGIC;            -- 1kHz Clock
        INB : IN STD_LOGIC;               -- 승객이 탑승하는 것을 받기 위한 신호
        OUTB : IN STD_LOGIC;              -- 승객이 하차하는 것을 받기 위한 신호
        ENABLE : IN STD_LOGIC;            -- 승객의 승하차 할 수 있는 상태를 임을 받는 신호
        state : IN STD_LOGIC_VECTOR (3 downto 0);  -- 현재의 상태 정류장인지 달리는 중인지 등을 표시
        number : IN STD_LOGIC_VECTOR (2 downto 0); -- 승객의 수, 속도 등 숫자를 받기 위한 신호
        data_out : OUT STD_LOGIC;         -- LCD에 데이터를 주는 상태임을 알려주는 변수
        addr : OUT STD_LOGIC_VECTOR(4 downto 0); -- LCD에 몇 번째 판에 데이터를 줄 지 알려주는 신호
        data : OUT STD_LOGIC_VECTOR(7 downto 0); -- LCD에 줄 데이터
        velocity : OUT STD_LOGIC_VECTOR (7 downto 0); -- 속도 / 차량의 종류를 결정 
        psg_cnt : OUT STD_LOGIC_VECTOR (7 downto 0); -- 승객의 수
        time_left : OUT STD_LOGIC_VECTOR (7 downto 0); --남은 시간 
        w_enable : IN STD_LOGIC; -- data_out을 계산하기 위한 
        door : IN STD_LOGIC); -- 다음 목적지까지 남은 시간       
end Calculator;

architecture Behavioral of Calculator is
 signal Bus_type : std_logic_vector (1 downto 0 );
 signal time_intervalA : std_logic_vector (3 downto 0); -- S -> A로 가는데 걸리는 시간
 signal time_intervalB : std_logic_vector (3 downto 0); -- A -> B로 가는데 걸리는 시간
 signal time_intervalC : std_logic_vector (3 downto 0); -- B -> C로 가는데 걸리는 시간
 signal time_intervalD : std_logic_vector (3 downto 0); -- C -> D로 가는데 걸리는 시간
signal time_count : std_logic_vector ( 10 downto 0); -- 1초를 세기위한 변수
 signal psg_enable : std_logic; -- 사람수를 셀 수 있게 해주는 변수
 --------
 signal count_left : std_logic_vector (7 downto 0); -- 시간이 지난 것을 계산
 signal total_psg : std_logic_vector (7 downto 0 ); -- 누적 탑승 승객
 signal now_psg : std_logic_vector (7 downto 0); -- 현재 탑승 승객
 --------
 signal bus_num1 : std_logic_vector(7 downto 0); -- 버스 번호
 signal bus_num2 : std_logic_vector(7 downto 0); 
 signal bus_num3 : std_logic_vector(7 downto 0);
 signal bus_num4 : std_logic_vector(7 downto 0);
 signal peoples_01 : std_logic_vector(3 downto 0); -- 승객수 1의 자리수 
 signal peoples_10 : std_logic_vector(3 downto 0); -- 승객수 10의 자리수 
 signal cnt : std_logic_vector(4 downto 0); 
 type reg is array (0 to 31) of std_logic_vector(7 downto 0); --LCDmodule에 보낼 정보를 위한 type
 signal reg_file : reg;
 begin
    -- Bus_type 변수에 버스 종류(시외버스, 시내버스, 마을버스)를 할당하고, 버스종류에 따른 각 구간별 이동 시간을 설정한다. 
   process(st_clk, FPGA_RSTB)
   begin
      if (FPGA_RSTB = '0') then -- 초기화 
         Bus_type <= "11";         
         time_intervalA <= "0000";  
         time_intervalB <= "0000";
         time_intervalC <= "0000";
         time_intervalD <= "0000";
      elsif (rising_edge(st_clk)) then

         if ( state = "0000") then -- 버스종류를 선택하는 상태일때
            if (number(2) = '0') then -- 속도 90
               Bus_type <= "00"; -- 시외버스
               bus_num1 <=  X"37"; -- 7
               bus_num2 <=  X"37"; -- 7
               bus_num3 <=  X"39"; -- 9
               bus_num4 <=  X"30"; -- 0
               time_intervalA <= "0010"; -- 시간간격 : 2s 
               time_intervalB <= "0100"; -- 시간간격 : 4s
               time_intervalC <= "0110"; -- 시간간격 : 6s
               time_intervalD <= "0100"; -- 시간간격 : 4s
            elsif (number(1) = '0') then --속도 60
               Bus_type <= "01"; -- 시내버스
               bus_num1 <= X"36"; -- 6 
               bus_num2 <= X"32"; -- 2
               bus_num3 <= X"2D"; -- -
               bus_num4 <= X"31"; -- 1
               time_intervalA <= "0011"; -- 시간간격 : 3s 
               time_intervalB <= "0110"; -- 시간간격 : 6s 
               time_intervalC <= "1001"; -- 시간간격 : 9s 
               time_intervalD <= "0110"; -- 시간간격 : 6s 
            elsif (number(0) = '0') then --속도 45
               Bus_type <= "10"; -- 마을버스
               bus_num1 <= X"32"; -- 2
               bus_num2 <= X"37"; -- 7
               bus_num3 <= X"2D"; -- -
               bus_num4 <= X"31"; -- 1
               time_intervalA <= "0100"; -- 시간간격 : 4s 
               time_intervalB <= "1000"; -- 시간간격 : 8s 
               time_intervalC <= "1100"; -- 시간간격 : 12s 
               time_intervalD <= "1000"; -- 시간간격 : 8s 
            else -- 속도 45
              Bus_type <= "10"; -- 마을버스
               bus_num1 <= X"32"; -- 2
               bus_num2 <= X"37"; -- 7
               bus_num3 <= X"2D"; -- -
               bus_num4 <= X"31"; -- 1
               time_intervalA <= "0100"; -- 시간간격 : 4s 
               time_intervalB <= "1000"; -- 시간간격 : 8s 
               time_intervalC <= "1100"; -- 시간간격 : 12s 
               time_intervalD <= "1000"; -- 시간간격 : 8s 
            end if;
         end if;
      end if;
   end process;

   -- 버스 타입에 따라 LED 모듈에 줄 속도를 정한다. 
   process(st_clk, FPGA_RSTB)

   begin
      if (FPGA_RSTB = '0') then
         velocity <= "00000000";
      elsif (rising_edge(st_clk)) then
         if ( (state = "0011") or (state = "0110") or (state = "1001") or (state = "1100")) then -- 버스가 달릴 때
            Case Bus_type is
               when "00" =>  -- 90
                  velocity <= "01011010"; 
               when "01" =>  -- 60
                  velocity <= "00111100";  
               when others => -- 45
                  velocity <= "00101101";  
             end case;
         else
            velocity <= "00000000"; -- 버스가 멈출 때 속도 '0'
         end if;
      end if;
   end process;
 
    -- 각 구간별 총 시간 time_interval에 count_left를 빼주어 남은 시간(time_left)를 계산한다. 
    process(state, FPGA_RSTB, st_clk)
      begin
      
      if (FPGA_RSTB = '0') then -- 초기화 
         time_left <= "00000000"; 
         time_count <= "00000000000";
         count_left <= "00000000";
      
      elsif (rising_edge(st_clk)) then 
         if (state = "0010") then --  출발 가능 상태
            time_left <= "0000" & time_intervalA; -- 남은시간 = time_intervalA
         elsif (state = "0100") then -- A
            time_left <= "0000" & time_intervalB; -- 남은시간 = time_intervalB
            count_left <= "00000000"; 
         elsif (state = "0111") then -- B
            time_left <= "0000" & time_intervalC; -- 남은시간 = time_intervalC
            count_left <= "00000000"; 
         elsif (state = "1010") then -- C 
            time_left <= "0000" & time_intervalD; -- 남은시간 = time_intervalD
            count_left <= "00000000";
         elsif((state = "0011")or(state = "0110")or(state = "1001")or(state = "1100")) then --버스가 달릴 때
            if (time_count < 998) then -- 초를 만드는 알고리즘
                time_count <= time_count + 1; 
            elsif (time_count = 998) then -- 0.999초일 때 지난 시간을 올리고
                case state is  -- 스테이트가 바뀌고 지난 시간을 센다.
                  when "0011" =>  --S ~ A
                     count_left <= count_left + 1;
                  when "0110" =>  --A ~ B
                     count_left <= count_left + 1;
                  when "1001" =>  --B ~ C
                     count_left <= count_left + 1;
                  when others =>  --C ~ D
                     count_left <= count_left + 1;
                end case;
                time_count <= time_count + 1;
            elsif (time_count = 999) then -- 1초가 됐을 때 지난시간을 빼준다. 
               Case State is 
                  when "0011" => -- 총 필요한 시간에서 지난 시간을 빼준다
                     time_left <= (("0000" & time_intervalA) - count_left);
                  when "0110" =>
                     time_left <= (("0000" & time_intervalB) - count_left);
                  when "1001" =>
                     time_left <= (("0000" & time_intervalC) - count_left);
                  when others =>
                     time_left <= (("0000" & time_intervalD) - count_left);
               end case;
            time_count <= "00000000000";
            end if;
         end if;
      end if;
   end process;

   
   -- 현재 승객 수와 버스에 탑승/하차 하는 승객 수를 비교하여 총 승객수를 계산한다.  
   process(FPGA_RSTB, st_clk)   
   begin
      if (FPGA_RSTB = '0') then
         now_psg <= "00000000";
         total_psg <= "00000000";
      elsif (rising_edge(st_clk)) then
         if ((state = "0101") or (state = "1000") or (state = "1011")) then -- 문이 열렸을 때
            if ((INB= '0') and (psg_enable = '1') and (enable = '1') ) then -- IN버튼을 누르면
               if (conv_integer(now_psg + number) > 45) then -- 사람수가 45명보다 많으면
                  now_psg <= now_psg; 
                  total_psg <= total_psg;
               elsif(conv_integer(total_psg + number) > 99) then
                  now_psg <= now_psg; 
                  total_psg <= total_psg;
               else -- 사람수가 45명보다 적으면
                  now_psg <= now_psg + number;
                  total_psg <= number + total_psg;
               end if;
            elsif ((OUTB = '0') and (psg_enable = '1') and (enable = '1')) then               
               if (now_psg < number) then -- 현재 승객보다 내린승객이 많으면,
                  now_psg <= now_psg;
               else -- 현재 승객이 내린승객보다 많으면,
                  now_psg <= now_psg - number; -- 현재 승객 - 내린 승객 
               end if;               
            end if;
         elsif (state = "1110") then
            now_psg <= "00000000";
         end if;
         if (total_psg < "0001010") then --10보다 작을 때 
             peoples_01 <= total_psg(3 downto 0);
             peoples_10 <= "0000";
         elsif (total_psg < "0010100") then --20보다 작을 때 
             peoples_01 <= conv_std_logic_vector(conv_integer(total_psg) - 10,4);
             peoples_10 <= "0001";
         elsif (total_psg < "0011110") then --30보다 작을 때
             peoples_01 <= conv_std_logic_vector(conv_integer(total_psg) - 20,4);
             peoples_10 <= "0010";
         elsif (total_psg < "0101000") then --40보다 작을 때
             peoples_01 <= conv_std_logic_vector(conv_integer(total_psg) - 30,4);
             peoples_10 <= "0011";
         elsif (total_psg < "0110010") then --50보다 작을 때
             peoples_01 <= conv_std_logic_vector(conv_integer(total_psg) - 40,4);
             peoples_10 <= "0100";    
         elsif (total_psg < "0111100") then --60보다 작을 때
             peoples_01 <= conv_std_logic_vector(conv_integer(total_psg) - 50,4);
             peoples_10 <= "0101";   
         elsif (total_psg < "1000110") then--70보다 작을 때, 
             peoples_01 <= conv_std_logic_vector(conv_integer(total_psg) - 60,4);
             peoples_10 <= "0110";
         elsif (total_psg< "1010000") then--80보다 작을 때,
             peoples_01 <= conv_std_logic_vector(conv_integer(total_psg) - 70,4);
             peoples_10 <= "0111";
         elsif (total_psg< "1011010") then--90보다 작을 때,
             peoples_01 <= conv_std_logic_vector(conv_integer(total_psg) - 80,4);
             peoples_10 <= "1000";
         else
             peoples_01 <= conv_std_logic_vector(conv_integer(total_psg) - 90,4);
             peoples_10 <= "1001";      
         end if;
      end if;
     
      if (state = "1111") then -- 도착하면 총 승객을 표시하고
         psg_cnt <= total_psg;
      else                     -- 그 전까지는 현재 승객을 표시한다.
         psg_cnt <= now_psg;
      end if;
      
   end process;
 -------------------------------------------------------  
   -- 승객을 셀지 세지 않을지 결정하며, 승객을 센 후에는 다시 승객을 세지 않도록 한다.
   process(FPGA_RSTB, st_clk)
   begin
      if (FPGA_RSTB = '0') then -- 초기화 
         psg_enable <= '0';
      elsif (rising_edge(st_clk)) then
         if ((state = "0101") or (state = "1000") or (state = "1011") ) then -- 문이 열렸을 때
            if (enable = '0') then -- enable 이 들어오면
               psg_enable <= '1'; -- 승객을 세아릴 수 있다.
            elsif (INB <= '0') or (OUTB <= '0') then -- 승객을 더하거나 뺀 후에는 다시 승객세기 불가능
               psg_enable <= '0'; 
            end if;
         end if;   
      end if;
   end process;
----------------------------------------------------------
 -- state에 따라  reg_file에 표시할 값들을 할당한다. 
 process(FPGA_RSTB, st_clk)
 Begin
     if FPGA_RSTB ='0' then -- 초기화 
         for i in 0 to 31 loop
            reg_file(i) <=X"20"; -- space 
         end loop;
      elsif st_clk ='1' and st_clk'event then
      if (door = '0') then -- 문이 열릴 때, 
         reg_file(15) <= X"4F"; -- 'o'
      else -- 문이 닫힐 때,
         reg_file(15) <= X"43"; -- 'c'
      end if;
      
      reg_file(6) <= X"42"; -- b
      reg_file(7) <= X"55"; -- u
      reg_file(8) <= x"53"; -- s
      
      case state is  -- reg (1~3) : 정류장, reg(10~13) :버스번호 , reg(15): door, reg(16~19): 기름, reg(21~29) : 지시사항, reg(31): belt
         when "0000" => reg_file(2) <= X"53"; --초기상태 
         
                     
                     reg_file(21) <= X"42";
                     reg_file(22) <= X"55";
                     reg_file(23) <= X"53";
                     reg_file(24) <= X"20";
                     reg_file(25) <= X"54";
                     reg_file(26) <= X"59";
                     reg_file(27) <= X"50";
                     reg_file(28) <= X"45";
                     reg_file(29) <= X"20"; 
                     reg_file(31) <= X"58";
                     
         when "0001" => reg_file(2) <= X"53"; --버스 준비 

                                       
                     reg_file(10) <= bus_num1;
                     reg_file(11) <= bus_num2;
                     reg_file(12) <= bus_num3;
                     reg_file(13) <= bus_num4;                    
                     reg_file(21) <= X"42";  --BELT&FUEL
                     reg_file(22) <= X"45";  
                     reg_file(23) <= X"4C";
                     reg_file(24) <= X"54";
                     reg_file(25) <= X"26";
                     reg_file(26) <= X"46";
                     reg_file(27) <= X"55";
                     reg_file(28) <= X"45";
                     reg_file(29) <= X"4C";
                     
                     
         when "0010" => reg_file(2) <= X"53";  --출발 가능 상태

                     reg_file(16) <= X"FF";
                     reg_file(17) <= X"FF";
                     reg_file(18) <= X"FF";
                     reg_file(19) <= X"FF";
                     reg_file(21) <= X"43";
                     reg_file(22) <= X"41";
                     reg_file(23) <= X"4E";
                     reg_file(24) <= X"20";
                     reg_file(25) <= X"44";
                     reg_file(26) <= X"52";   
                     reg_file(27) <= X"49";
                     reg_file(28) <= X"56";
                     reg_file(29) <= X"45";                  
                     reg_file(31) <= X"4F";
                       
         when "0011" => reg_file(1) <= X"53"; --S to A
                     reg_file(2) <= X"7E";
                     reg_file(3) <= X"41";                     
                     reg_file(16) <= X"FF";
                     reg_file(17) <= X"FF";
                     reg_file(18) <= X"FF";
                     reg_file(19) <= X"FF";
                     reg_file(19) <= X"20";
                     reg_file(21) <= X"44";   
                     reg_file(22) <= X"52";
                     reg_file(23) <= X"49";
                     reg_file(24) <= X"56";
                     reg_file(25) <= X"49";   
                     reg_file(26) <= X"4E";
                     reg_file(27) <= X"47";
                     reg_file(28) <= X"20";
                     reg_file(29) <= X"20";

                     
         when "0100" => reg_file(1) <= X"20";   -- A
                     reg_file(2) <= X"41";
                     reg_file(3) <= X"20";
                     reg_file(21) <= X"53";   
                     reg_file(22) <= X"54";
                     reg_file(23) <= X"4F";
                     reg_file(24) <= X"50";
                     reg_file(25) <= X"20";
                     reg_file(26) <= X"20";
                     reg_file(27) <= X"20";
                     reg_file(28) <= X"20";
                     reg_file(29) <= X"20";
                     
         when "0101" => reg_file(1) <= X"20";  -- count A
                     reg_file(2) <= X"41";
                     reg_file(3) <= X"20";
                     reg_file(21) <= X"44";   
                     reg_file(22) <= X"4F";
                     reg_file(23) <= X"4F";   
                     reg_file(24) <= X"52";
                     reg_file(25) <= X"20";
                     reg_file(26) <= X"4F";
                     reg_file(27) <= X"50";
                     reg_file(28) <= X"45";
                     reg_file(29) <= X"4E";
      

         when "0110" => reg_file(1) <= X"41";  --A to B
                     reg_file(2) <= X"7E";
                     reg_file(3) <= X"42";
                     reg_file(16) <= X"FF";
                     reg_file(17) <= X"FF";
                     reg_file(18) <= X"FF";
                     reg_file(19) <= X"20";
                     reg_file(21) <= X"44";
                     reg_file(22) <= X"52";
                     reg_file(23) <= X"49";
                     reg_file(24) <= X"56";
                     reg_file(25) <= X"49";
                     reg_file(26) <= X"4E";
                     reg_file(27) <= X"47";
                     reg_file(28) <= X"20";
                     reg_file(29) <= X"20";

                     
         when "0111" => reg_file(1) <= X"20";  --B
                     reg_file(2) <= X"42";
                     reg_file(3) <= X"20";
                     reg_file(21) <= X"53";   
                     reg_file(22) <= X"54";   
                     reg_file(23) <= X"4F";   
                     reg_file(24) <= X"50";
                     reg_file(25) <= X"20";
                     reg_file(26) <= X"20";
                     reg_file(27) <= X"20";
                     reg_file(28) <= X"20";
                     reg_file(29) <= X"20";
                     
         when "1000" => reg_file(1) <=X"20";   --count B
                     reg_file(2) <= X"42";
                     reg_file(3) <= X"20";
                     reg_file(21) <= X"44";   
                     reg_file(22) <= X"4F";
                     reg_file(23) <= X"4F";
                     reg_file(24) <= X"52";
                     reg_file(25) <= X"20";
                     reg_file(26) <= X"4F";   
                     reg_file(27) <= X"50";
                     reg_file(28) <= X"45";
                     reg_file(29) <= X"4E";
        
        when "1001" => reg_file(1) <= X"42"; --B to C
                     reg_file(2) <= X"7E";
                     reg_file(3) <= X"43";
                     reg_file(16) <= X"FF";
                     reg_file(17) <= X"FF";
                     reg_file(18) <= X"20";
                     reg_file(19) <= X"20";
                     reg_file(21) <= X"44";   
                     reg_file(22) <= X"52";
                     reg_file(23) <= X"49";
                     reg_file(24) <= X"56";
                     reg_file(25) <= X"49";   
                     reg_file(26) <= X"4E";
                     reg_file(27) <= X"47";
                     reg_file(28) <= X"20";
                     reg_file(29) <= X"20";
         
         when "1010" => reg_file(1) <= X"20";  -- C
                     reg_file(2) <= X"43";
                     reg_file(3) <= X"20";    
                     reg_file(21) <= X"53";   
                     reg_file(22) <= X"54";
                     reg_file(23) <= X"4F";
                     reg_file(24) <= X"50";
                     reg_file(25) <= X"20";
                     reg_file(26) <= X"20";
                     reg_file(27) <= X"20";
                     reg_file(28) <= X"20";
                     reg_file(29) <= X"20";

         when "1011" => reg_file(1) <= X"20";  --Count C
                     reg_file(2) <= X"43";
                     reg_file(3) <= X"20";                 
                     reg_file(21) <= X"44";   
                     reg_file(22) <= X"4F";
                     reg_file(23) <= X"4F";
                     reg_file(24) <= X"52";
                     reg_file(25) <= X"20";
                     reg_file(26) <= X"4F";
                     reg_file(27) <= X"50";
                     reg_file(28) <= X"45";   
                     reg_file(29) <= X"4E";


         when "1100" => reg_file(1) <= X"43"; --C to D
                     reg_file(2) <= X"7E";
                     reg_file(3) <= X"44";                     
                     reg_file(16) <= X"FF";
                     reg_file(17) <= X"20";
                     reg_file(18) <= X"20";
                     reg_file(19) <= X"20";
                     reg_file(21) <= X"44";   
                     reg_file(22) <= X"52";
                     reg_file(23) <= X"49";
                     reg_file(24) <= X"56";
                     reg_file(25) <= X"49";
                     reg_file(26) <= X"4E";
                     reg_file(27) <= X"47";
                     reg_file(28) <= X"20";
                     reg_file(29) <= X"20";
                     
         when "1101" => reg_file(1) <= X"20";  -- D
                     reg_file(2) <= X"44";
                     reg_file(3) <= X"20";
                     reg_file(16) <= X"20";
                     reg_file(17) <= X"20";
                     reg_file(18) <= X"20";
                     reg_file(19) <= X"20";
                     reg_file(21) <= X"4C";   
                     reg_file(22) <= X"41";
                     reg_file(23) <= X"53";
                     reg_file(24) <= X"54";
                     reg_file(25) <= X"20";
                     reg_file(26) <= X"53";
                     reg_file(27) <= X"54";   
                     reg_file(28) <= X"4F";
                     reg_file(29) <= X"50";
                     
         when "1110" => reg_file(1) <= X"20";  --운행 종료
                     reg_file(2) <= X"44";
                     reg_file(3) <= X"20";
                     reg_file(16) <= X"20";
                     reg_file(17) <= X"20";
                     reg_file(18) <= X"20";
                     reg_file(19) <= X"20";
                     reg_file(21) <= X"44";
                     reg_file(22) <= X"4F";
                     reg_file(23) <= X"4F";
                     reg_file(24) <= X"52";
                     reg_file(25) <= X"20";
                     reg_file(26) <= X"4F";
                     reg_file(27) <= X"50";
                     reg_file(28) <= X"45";
                     reg_file(29) <= X"4E";

         when others => reg_file(1) <= X"20";    --총 승객 표시
                     reg_file(2) <= X"44";
                     reg_file(3) <= X"20";
                     reg_file(21) <= X"54";   
                     reg_file(22) <= X"4F";
                     reg_file(23) <= X"54";
                     reg_file(24) <= X"41";
                     reg_file(25) <= X"4C";
                     reg_file(26) <= X"3A";
                     reg_file(27) <= peoples_10 + X"30"; -- 총 승객 1의 자리수 
                     reg_file(28) <= peoples_01 + X"30"; -- 총 승객 10의 자리수 
                     reg_file(29) <= X"20"; 
         end case;
      end if;
   end process;   
---------------LCD MODULE에 데이터를 줄 수 있게 만드는 process--------------------------
  process(FPGA_RSTB, st_clk)
  begin
  if FPGA_RSTB= '0' then -- 초기화 
      cnt <= (others => '0'); 
      data_out <='0';
  elsif st_clk = '1' and st_clk'event then
      if w_enable ='1' then -- w_enable ='1' (write) 
          data<=reg_file(conv_integer(cnt));
          addr<=cnt;
          data_out <='1';
           if cnt=X"1F" then -- cnt = 31 일 경우 
               cnt<=(others =>'0');
           else
               cnt <=cnt+1;
           end if;
      else
          data_out <='0';
      end if;
   end if;
end process;
end Behavioral;
-------------------------[LCD Module]------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity LCD_Module is
    port(FPGA_RSTB : IN STD_LOGIC;       -- RESET
        st_clk : IN STD_LOGIC;               -- 1KHZ의 Clock
        LCD_A : OUT STD_LOGIC_VECTOR(1 downto 0); 
        LCD_EN : OUT STD_LOGIC;              -- LCD를 사용할 수 있게 해주는 신호
        LCD_D : OUT STD_LOGIC_VECTOR(7 downto 0); --LCD판에 줄 데이터
        data_out : IN STD_LOGIC;             -- Calculator로부터 데이터를 받기 위한 신호
        addr : IN STD_LOGIC_VECTOR(4 downto 0); 
        data : IN STD_LOGIC_VECTOR(7 downto 0);
        w_enable : OUT STD_LOGIC);
end LCD_Module;

architecture Behavioral of LCD_Module is
type reg is array( 0 to 31 ) of std_logic_vector( 7 downto 0 ); 
signal reg_file : reg; 
signal w_enable_reg : std_logic; 
signal lcd_state : std_logic_vector (7 downto 0); --LCD 현재 상태 
signal lcd_nstate : std_logic_vector (7 downto 0); -- LCD 다음 상태
signal lcd_db : std_logic_vector (7 downto 0); 
signal peoples_10 : std_logic_vector (3 downto 0); -- 사람수를 계산할 변수
signal peoples_01 : std_logic_vector (3 downto 0); 

begin
    process(FPGA_RSTB, st_clk)
    Begin
       if FPGA_RSTB = '0' then 
          lcd_state <= (others => '0');
       elsif rising_edge(st_clk)then -- state clock이 rising edge일 때, 
          lcd_state <= lcd_nstate; -- 다음 상태를 현재 상태로 
       end if;
    end process;
    w_enable_reg <= '0' when lcd_state < X"06" else '1'; -- w_enable_reg = '0'일 경우 read, w_enable_reg = '1'일 경우 write 
 -------------------------------------------------------- 
    process(FPGA_RSTB, st_CLK) 
    Begin 
        if FPGA_RSTB = '0' then -- 초기화 
            for i in 0 to 31 loop  
                reg_file(i) <= X"20"; -- 모든 lcd 에 space
            end loop;
        elsif rising_edge(st_clk) then -- st_clk 이 rising edge일 때, 
            if w_enable_reg ='1' and data_out ='1' then 
                reg_file(conv_integer(addr)) <= data; -- reg_file에 data 할당
            end if; 
        end if; 
    end process;
----------------------------------------------------------
-- LCD에 표시할 값(reg file)들을 할당한다. 
    process(FPGA_RSTB, lcd_state)
    begin
        if(FPGA_RSTB = '0')then
            lcd_nstate <= X"00";
        else
            case lcd_state is
                when X"00" => lcd_db <= "00111000"; --Function set
                              lcd_nstate <= X"01";            
                when X"01" => lcd_db <= "00001000"; --Display OFF
                              lcd_nstate <= X"02"; 
                when X"02" => lcd_db <= "00000001"; --Display clear
                              lcd_nstate <= X"03";
                when X"03" => lcd_db <= "00000110"; --Entry mode set
                              lcd_nstate <= X"04";
                when X"04" => lcd_db <= "00001100"; --Display ON
                              lcd_nstate <= X"05";
                when X"05" => lcd_db <= "00000011"; --Return home
                              lcd_nstate <= X"06";
            ----------------------------------------------
                when X"06" => lcd_db <= reg_file(0);
                              lcd_nstate <= X"07";                        
                when X"07" => lcd_db <= reg_file(1);
                              lcd_nstate <= X"08";
                when X"08" => lcd_db <= reg_file(2);
                              lcd_nstate <= X"09";
                when X"09" => lcd_db <= reg_file(3);
                              lcd_nstate <= X"0A";
                when X"0A" => lcd_db <= reg_file(4);
                              lcd_nstate <= X"0B";
                when X"0B" => lcd_db <= reg_file(5);
                              lcd_nstate <= X"0C";
                when X"0C" => lcd_db <= reg_file(6);
                              lcd_nstate <= X"0D";
                when X"0D" => lcd_db <= reg_file(7);
                              lcd_nstate <= X"0E";
                when X"0E" => lcd_db <= reg_file(8);
                              lcd_nstate <= X"0F";
                when X"0F" => lcd_db <= reg_file(9);
                              lcd_nstate <= X"10";
                when X"10" => lcd_db <= reg_file(10);
                              lcd_nstate <= X"11";
                when X"11" => lcd_db <= reg_file(11);
                              lcd_nstate <= X"12";
                when X"12" => lcd_db <= reg_file(12);
                              lcd_nstate <= X"13";
                when X"13" => lcd_db <= reg_file(13);
                              lcd_nstate <= X"14";
                when X"14" => lcd_db <= reg_file(14);
                              lcd_nstate <= X"15";
                when X"15" => lcd_db <= reg_file(15);
                              lcd_nstate <= X"16";
                when X"16" => lcd_db <= X"C0"; -- change line
                              lcd_nstate <= X"17";
                when X"17" => lcd_db <= reg_file(16);
                              lcd_nstate <= X"18";
                when X"18" => lcd_db <= reg_file(17);
                              lcd_nstate <= X"19";
                when X"19" => lcd_db <= reg_file(18);
                              lcd_nstate <= X"1A";
                when X"1A" => lcd_db <= reg_file(19);
                              lcd_nstate <= X"1B";
                when X"1B" => lcd_db <= reg_file(20);
                              lcd_nstate <= X"1C";
                when X"1C" => lcd_db <= reg_file(21);
                              lcd_nstate <= X"1D";
                when X"1D" => lcd_db <= reg_file(22);
                              lcd_nstate <= X"1E";
                when X"1E" => lcd_db <= reg_file(23);
                              lcd_nstate <= X"1F";
                when X"1F" => lcd_db <= reg_file(24);
                              lcd_nstate <= X"20";
                when X"20" => lcd_db <= reg_file(25);
                              lcd_nstate <= X"21";
                when X"21" => lcd_db <= reg_file(26);
                              lcd_nstate <= X"22";
                when X"22" => lcd_db <= reg_file(27);
                              lcd_nstate <= X"23";
                when X"23" => lcd_db <= reg_file(28);
                              lcd_nstate <= X"24";
                when X"24" => lcd_db <= reg_file(29);
                              lcd_nstate <= X"25";
                when X"25" => lcd_db <= reg_file(30);
                              lcd_nstate <= X"26";
                when X"26" => lcd_db <= reg_file(31); 
                              lcd_nstate <= X"05";   --return home
                when others => lcd_db <= (others => '0');
            end case;
        end if;
    end process;
---------------------------------------------------
   LCD_A(1) <= '0'; 
   LCD_A(0) <= '0'  when (lcd_state >= X"00" and lcd_state < X"06") or 
                          (lcd_state =X"16") else '1'; -- function set, change line 일 경우 read, 나머지 경우 write
   LCD_EN <= not st_clk; 
   LCD_D <= lcd_db; 
   w_enable <= w_enable_reg; 
end Behavioral;
-------------------------[LED Module]--------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity LED_Module is
port(FPGA_RSTB : IN STD_LOGIC;       -- RESET
        st_clk : IN STD_LOGIC;            -- CLOCK
        velocity : IN STD_LOGIC_VECTOR (7 downto 0); --현재 차량의 속도  
        psg_cnt : IN STD_LOGIC_VECTOR (7 downto 0);  -- 승객의 수
        time_left : IN STD_LOGIC_VECTOR (7 downto 0); -- 남은 시간
        state : IN STD_LOGIC_VECTOR (3 downto 0); -- 현재의 상태 
        DIGIT: OUT STD_LOGIC_VECTOR (6 downto 1); -- 어떤 LED를 켤 지 결정하는 신호
        SEG_A : OUT STD_LOGIC;                                                     
        SEG_B : OUT STD_LOGIC;
        SEG_C : OUT STD_LOGIC;
        SEG_D : OUT STD_LOGIC;
        SEG_E : OUT STD_LOGIC;
        SEG_F : OUT  STD_LOGIC;
        SEG_G : OUT  STD_LOGIC;
        SEG_DP : OUT  STD_LOGIC);
end LED_Module; 

architecture Behavioral of LED_Module is
signal sel : std_logic_vector ( 2 downto 0); 
signal people_01 : std_logic_vector(3 downto 0); -- 승객 수 
signal people_10 : std_logic_vector(3 downto 0);
signal speed_01: std_logic_vector(3 downto 0); -- 속도 
signal speed_10: std_logic_vector(3 downto 0);
signal time_01: std_logic_vector(3 downto 0); -- 시간
signal time_10: std_logic_vector(3 downto 0);
signal data : std_logic_vector(3 downto 0); 
signal seg : std_logic_vector(7 downto 0);
signal time_enable : std_logic;

begin
    -- LED에 승객수를 표시한다. 
    process(sel)  
    begin 
      case sel is 
            when "000" => DIGIT <= "000001"; -- sel = "000" 일 때, DIGIT <= "000001"에 승객수의 10의 자리수 표시 
               data <= people_10;
            when "001" => DIGIT <= "000010"; -- sel = "001" 일 때, DIGIT <= "000010"에 승객수의 1의 자리수 표시 
               data <= people_01;
            when "010" => DIGIT <= "000100"; -- sel = "010" 일 때, DIGIT <= "000100"에 속도의 10의 자리수 표시 
               data <= speed_10;
            when "011" => DIGIT <= "001000"; -- sel = "011" 일 때, DIGIT <= "001000"에 속도의 1의 자리수 표시 
               data <= speed_01;
            when "100" => DIGIT <= "010000"; -- sel = "100" 일 때, DIGIT <= "010000"에 남은 시간의 10의 자리수 표시 
               data <= time_10;
            when "101" => DIGIT <= "100000"; -- sel = "101" 일 때, DIGIT <= "100000"에 남은 시간 1의 자리수 표시 
               data <= time_01;
            when others => null; 
      end case;
   end process;
   
   -- LED에 2번째 숫자와 4번째 숫자에는 값들을 구별해 주기 위해 점이 찍힌 숫자를 사용하였고, 나머지 숫자들은 점이 찍히지 않은 숫자를 사용하였다.   
   process(data)
   begin
      if ((sel = "001") or (sel = "011")) then
         case data is 
            when "0000" => seg <= "10111111"; --0.
            when "0001" => seg <= "10000110"; --1.
            when "0010" => seg <= "11011011"; --2.
            when "0011" => seg <= "11001111"; --3.
            when "0100" => seg <= "11100110"; --4.
            when "0101" => seg <= "11101101"; --5.
            when "0110" => seg <= "11111101"; --6.
            when "0111" => seg <= "10000111"; --7.
            when "1000" => seg <= "11111111"; --8.
            when "1001" => seg <= "11101111"; --9.
            when others => null;
         end case;
      else
         case data is 
            when "0000" => seg <= "00111111"; --0
            when "0001" => seg <= "00000110"; --1
            when "0010" => seg <= "01011011"; --2
            when "0011" => seg <= "01001111"; --3
            when "0100" => seg <= "01100110"; --4
            when "0101" => seg <= "01101101"; --5
            when "0110" => seg <= "01111101"; --6
            when "0111" => seg <= "00000111"; --7
            when "1000" => seg <= "01111111"; --8
            when "1001" => seg <= "01101111"; --9
            when others => null;
         end case;
      end if;
   end process;
   
   -- LED에 표시할 값(승객수, 남은시간, 속도)들을 계산한다. 
   process(FPGA_RSTB, st_clk) 
   begin
      if(FPGA_RSTB = '0') then --When reset
         sel <= "000";  
      elsif (rising_edge(st_clk)) then
         if(sel = "101") then
            sel <= "000";
         else --choose next segment
            sel <= sel + 1;
         end if;
         -- 승객수 
         if (psg_cnt < "0001010") then --10보다 작을 때 
             people_01 <= psg_cnt(3 downto 0);
             people_10 <= "0000";
         elsif (psg_cnt < "0010100") then --20보다 작을 때 
             people_01 <= conv_std_logic_vector(conv_integer(psg_cnt) - 10,4);
             people_10 <= "0001";
         elsif (psg_cnt < "0011110") then --30보다 작을 때
             people_01 <= conv_std_logic_vector(conv_integer(psg_cnt) - 20,4);
             people_10 <= "0010";
         elsif (psg_cnt < "0101000") then --40보다 작을 때
             people_01 <= conv_std_logic_vector(conv_integer(psg_cnt) - 30,4);
             people_10 <= "0011";
         elsif (psg_cnt < "0110010") then --50보다 작을 때
             people_01 <= conv_std_logic_vector(conv_integer(psg_cnt) - 40,4);
             people_10 <= "0100";    
         elsif (psg_cnt < "0111100") then --60보다 작을 때
             people_01 <= conv_std_logic_vector(conv_integer(psg_cnt) - 50,4);
             people_10 <= "0101";   
         elsif (psg_cnt < "1000110") then--70보다 작을 때, 
             people_01 <= conv_std_logic_vector(conv_integer(psg_cnt) - 60,4);
             people_10 <= "0110";
         elsif (psg_cnt < "1010000") then --80보다 작을 때,
             people_01 <= conv_std_logic_vector(conv_integer(psg_cnt) - 70,4);
             people_10 <= "0111";
         elsif (psg_cnt < "1011010") then --90보다 작을 때,
             people_01 <= conv_std_logic_vector(conv_integer(psg_cnt) - 80,4);
             people_10 <= "1000";
         else
             people_01 <= conv_std_logic_vector(conv_integer(psg_cnt) - 90,4);
             people_10 <= "1001";      
         end if;
         -- 남은 시간 표시
         if (state = "0011" or state = "0110" or state = "1001" or state = "1100") then -- 버스가 달릴 때, 
            if (time_left < "001010") then --10보다 작을 때 
                time_01 <= time_left(3 downto 0);
                time_10 <= "0000";
            elsif (time_left < "010100") then --20보다 작을 때 
                time_01 <= conv_std_logic_vector(conv_integer(time_left) - 10,4);
                time_10 <= "0001";
            elsif (time_left < "011110") then --30보다 작을 때
                time_01 <= conv_std_logic_vector(conv_integer(time_left) - 20,4);
                time_10 <= "0010";   
            end if;
         else --버스가 멈출 때, 
            time_01 <= "0000"; 
            time_10 <= "0000";
         end if;
         -- 속도
         case velocity is
            when "01011010" => -- 속도 90
                speed_10 <= "1001";
                speed_01 <= "0000";
            when "00111100" => -- 속도 60
                speed_10 <= "0110";
                speed_01 <= "0000";
            when "00101101" => -- 속도 45
                speed_10 <= "0100";
                speed_01 <= "0101";
            when others => -- 멈춰있을 때
                speed_10 <= "0000";
                speed_01 <= "0000";    
         end case;
       end if;
   end process;

   SEG_A <= seg(0);
   SEG_B <= seg(1);
   SEG_C <= seg(2);
   SEG_D <= seg(3);
   SEG_E <= seg(4);
   SEG_F <= seg(5);
   SEG_G <= seg(6);
   SEG_DP <= seg(7);
end Behavioral;