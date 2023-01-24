--DEFINE LIB--
library IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
--For IBUFG-- 
LIBRARY UNISIM;
use UNISIM.vcomponents.all;
--

entity SPI_3WIRE IS 
    --define generic parameters
    GENERIC(
		  DataWidth_CMD : INTEGER := 23 ;    -- DATA width for transmit  
		  SlavesNum     : INTEGER := 1    	 --Slaves Number
    );
    
    --define inputs and outputs
    PORT(
        --INPUT-- 
		  CLOCK         	 : IN   STD_LOGIC; --Module clock                                         
		  SCLK_Pol      	 : IN   STD_LOGIC; --initiate SPI CLOCK polarity                                        
		  SCLK_Pha		 	 : IN   STD_LOGIC; --SPI Clock Phase	 												   
		  Enable        	 : IN   STD_LOGIC; --enable SPI Module                                        
		  SyncReset     	 : IN   STD_LOGIC; --synchronous  RESET for SPI Module                                        
		  R_W           	 : IN   STD_LOGIC; --Read / wirte // this optional. in this module
														 --we use R_W just for write. according to datasheet                                        
        
		  --OUTPUT--
		  DATA          	 : OUT  STD_LOGIC := 'Z'; 								  --SPI DATA Line according to datasheet
																                          --this pin is JUST INPUT                                        
		  LoadEnable    	 : OUT  STD_LOGIC_VECTOR(SlavesNum - 1 downto 0); --SPI ENABLE SLaves          
		  Busy          	 : OUT  STD_LOGIC;   									  --optional: show SPI module Status                                         	  
        SCLK_20MHz_IBUFG : OUT  STD_LOGIC											   --spi Clock		  												   
    );
end SPI_3WIRE;

architecture behaviroal of SPI_3WIRE IS 
    signal SCLK              : STD_LOGIC                :='0';
    --define INTERNAL Signal for all PORTS except CLOCK PORT(REGISTER PORT)
    signal Enable_BUF        : STD_LOGIC                := '1';                    				 --active low enable
    signal SyncReset_BUF     : STD_LOGIC                := '1';                    			    --active low SyncReset
    signal R_W_BUF           : STD_LOGIC                := '1';                    				 --R_W = '1' -> for write and R_W = '0' -> for read
    signal LoadEnable_BUF    : STD_LOGIC_VECTOR(SlavesNum - 1 downto 0)   := (OTHERS => '1'); --LOAD ENABLE BUFFER
    Signal DATA_BUF          : STD_LOGIC := 'Z'; 
    signal Busy_BUF          : STD_LOGIC := '0';                                          	 --BUSY BUFFER     
    --internal signal
    signal Count		        : unsigned(1 downto 0)     := "00";
    signal ADR				     : INTEGER 					  := 0;
	 signal SCLK_Pol_BUF		  : STD_LOGIC 				     := '0';
	 signal SCLK_Pha_BUF		  : STD_LOGIC 				     := '0';
	 signal Counter			  : INTEGER 					  := 23;
	 signal Clock_40MHz 		  : STD_LOGIC 					  := '0';
	 --type 
    type FSM is (Idle,WriteStatus,InitDelay,FinalDelay,FinalState,CtrlDelay);						--FSM State 
    signal State : FSM       									  := Idle; 	
	 type Registers IS (R , C , N);																				--Synthesizer Register 
	 signal que   : Registers 									  := R;
	 --Registers 
	 Constant R_CounterlLatch : STD_LOGIC_VECTOR(23 downto 0):= "110111000011101010111100";   --ADF4360-5 REG -> R Counter Latch
	 Constant ControlLatch    : STD_LOGIC_VECTOR(23 downto 0):= "101000101110101011110001";	--ADF4360-5 REG -> Control Latch
	 Constant N_ControlLatch  : STD_LOGIC_VECTOR(23 downto 0):= "101011110101011110001010";	--ADF4360-5 REG -> N Counter Latch	
	 --DCM BLock Decleratin--
	 component DCM_40_40MHz
	 port
		(-- Clock in ports
		CLK_IN1           : in     std_logic;
		-- Clock out ports
		CLK_OUT1          : out    std_logic
		);
	 end component;
	 --
begin
      --INSTANT IBUFG for SPI Clock--
		IBUG_inst : IBUF
		generic map(
			IBUF_LOW_PWR => TRUE, --low Power 
			IOSTANDARD => "DEFAULT")
		port map (
			O => SCLK_20MHz_IBUFG,
			I => SCLK
		);
		--	DCM Block --
		DCM_BLOCK : DCM_40_40MHz
		port map
			(-- Clock in ports
			CLK_IN1  => Clock,
			-- Clock out ports
			CLK_OUT1 => Clock_40MHz);
			
      Enable_BUF 		<= Enable;
      R_W_BUF    		<= R_W;
      SyncReset_BUF  <= SyncReset;
		Data 				<= Data_BUF;
		Busy				<= Busy_BUF;
		LoadEnable(ADR)<= LoadEnable_BUF(ADR);
		SCLK_Pol_BUF   <= SCLK_Pol;
		
		process(Clock)
			variable counter_delay : integer := 0;
			variable counter_flag  : boolean := false;
			Variable CtrlD         : integer := 0;
			--Registers Flag 
			variable R_Latch 		  : boolean := false;
			variable C_Latch 		  : boolean := false;
			variable N_Latch 		  : boolean := false;
		begin
		  --rising edge Clock	
        if(Clock'EVENT and Clock = '1') then 		  --Check CLOCK SYSTEM Rising EDGE
			--check sync. reset -> active high
			if(SyncReset_BUF = '1') then  
            Busy_BUF   			  <= '1';                           --Status: busy      
            DATA_BUF   	        <= 'Z';                           --SPI  DATA  
            LoadEnable_BUF(ADR) <= '1';                           --DONT SELECT Slave
            State               <= Idle; 									--Reset State
				SCLK  	  	        <= SCLK_Pol_BUF;	               --Set SPI Clock Polarity
				Counter  			  <= 23;							         --Reset Data Transmision Counter					
				que                 <= R ;										--Reset que to first register		
			else 
				case State is 
					--IDLE State--
					when Idle =>			
						Data_BUF <= 'Z';							            --In IDLE State -> DATA <= '0'
						Busy_BUF <= '0';							            --In IDLE State The SPI module Is not Busy
						Counter  <= 23;							            --Reset Data Transmision Counter
						if(Enable_Buf = '1')then 				            --In IDLE State Check Enable Pin
							State   				 <= InitDelay;             --move to InitDelay
						   Busy_BUF				 <= '1';	
							LoadEnable_BUF(ADR)<= '0';		--
                     SCLK_Pha_BUF       <= SCLK_Pha;			      --Set SPI Clock phase to Clock phase buffer				
						else
							State            <= Idle;				         --stay in Idle State
							LoadEnable_Buf   <= (others => '1');	      --deactive slaves load enable Pins
						end if;
					
					--Init Delay--
					when InitDelay =>						
						LoadEnable_BUF(ADR) <= '0';							--Select Target Slave
						State   				  <= WriteStatus;					--move to WriteStatus
						Busy_BUF 			  <= '1';							--In Init State The SPI module Is  Busy
						--SEND BLOCK--												  SEND according to Register Flag
						case que is 		
							when R =>  Data_BUF <= R_CounterlLatch(Counter);	--send  R Latch DATA 
							when C =>  Data_BUF <= ControlLatch(Counter);	   --send  C Latch DATA
							when N =>  Data_BUF <= N_ControlLatch(Counter); 	--send  C Latch DATA
						end case;
						--
						Counter 				  <= Counter - 1;
					--Write State--
					when WriteStatus => 			
						if(Enable_BUF = '1' AND R_W_BUF = '1' ) THEN		--check enable and R_W Pins	
								SCLK  		  <= NOT SCLK;						--generate SPI CLOCK
								SCLK_Pha_BUF  <= NOT SCLK_Pha_BUF;			--SET SPI CLOCK phase
						end if;
						if(Counter >= 0 AND SCLK_Pha_BUF = '1' AND counter_flag = false) then 		--Check clock phase and counter
							--SEND BLOCK--													   --SEND according to Register Flag
							case que is 
								when R =>  Data_BUF <= R_CounterlLatch(Counter);	--send  R Latch DATA 
								when C =>  Data_BUF <= ControlLatch(Counter);	   --send  C Latch DATA
								when N =>  Data_BUF <= N_ControlLatch(Counter); 	--send  C Latch DATA
							end case;
							--
							Counter  		  <= Counter - 1;					--
						elsif (Counter = 0) then 									--that means SEND DATA finished 
								counter_flag := true;
								if(counter_delay = 1) then 						--MAKE DELAY FOR SEND LAST BIT 
									--SEND BLOCK--										  SEND according to Register Flag
									case que is 
										when R =>  Data_BUF <= R_CounterlLatch(Counter);	--send  R Latch DATA 
										when C =>  Data_BUF <= ControlLatch(Counter);	   --send  C Latch DATA
									   when N =>  Data_BUF <= N_ControlLatch(Counter); 	--send  C Latch DATA
									end case;
									--
								end if;
								counter_delay := counter_delay + 1;					
									if(counter_delay = 5)then
										counter_flag := false;
										counter_delay := 0;
										State   			  <= FinalDelay;					--Move to FinalDelay State
										if que = C then
											State         <= CtrlDelay;					-- 
										end if;
										Counter 			  <= 23;								--SET Counter TO 23
										Data_BUF         <= 'Z';
										SCLK    			  <= '0'; 							--turn off SPI clock after send Data
									end if;
						end if;
					--CtrlDelay --generate Delay with CtrlDelay Variable-- 
					when CtrlDelay =>
						CtrlD := CtrlD + 1;
						Case CtrlD is  
							When 1  => 
								LoadEnable_BUF(ADR) <= '1';
						   when 2  =>
								LoadEnable_BUF(ADR) <= '0';
							when 20 => 
								CtrlD := 0;
								State <= FinalDelay;
							when others => 
							
						end case;
					--Final Delay--
					when FinalDelay => 											
						State 			     <= FinalState;					--Move to Final State
						if que /= C then
							LoadEnable_BUF(ADR) <= '1';							--DESELECT SLAVE				
						end if;
					--Final State--	
					when FinalState =>														 
						State               <= Idle;							--Move to Idle State
						case que IS 
							when R => que <= C;
							when C => que <= N;
							when N => que <= R;
						end case;
				end case;
			end if;
        end if;
		  
		end process;
		
end architecture;