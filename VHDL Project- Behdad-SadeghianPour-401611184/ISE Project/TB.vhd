
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
 
ENTITY TB IS
END TB;
 
ARCHITECTURE behavior OF TB IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT SPI_3WIRE
    PORT(
         CLOCK 			 : IN  	std_logic;
         SCLK_Pol 		 : IN  	std_logic;
			SCLK_Pha 		 : IN  	std_logic;
         Enable    		 : IN  	std_logic;
         SyncReset 		 : IN 	std_logic;
         R_W 				 : IN 	std_logic;
         DATA 				 : OUT 	std_logic;
         LoadEnable  	 : OUT  	std_logic_vector(0 downto 0);
         Busy 				 : OUT  	std_logic;
			SCLK_20MHz_IBUFG: OUT   std_logic	
        );
    END COMPONENT;
    

   --Inputs
   signal CLOCK     			 : std_logic := '0';
   signal SCLK_Pol  			 : std_logic := '0';
	signal SCLK_Pha  			 : std_logic := '0';
   signal Enable    			 : std_logic := '0';
   signal SyncReset 			 : std_logic := '0';
   signal R_W       			 : std_logic := '0';

 	--Outputs
   signal DATA              : std_logic;
   signal LoadEnable        : std_logic_vector(0 downto 0);
   signal Busy              : std_logic;
	signal SCLK_20MHz_IBUFG  : std_logic;
   -- Clock period definitions
   constant CLOCK_period 	: time := 25 ns;
	--internal signal
	signal Clock_40MHz 		 : STD_LOGIC:= '0';
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: SPI_3WIRE PORT MAP (
          CLOCK 	   		=> CLOCK,
          SCLK_Pol   		=> SCLK_Pol,
			 SCLK_Pha   		=> SCLK_Pha,
          Enable     		=> Enable,
          SyncReset  		=> SyncReset,
          R_W        		=> R_W,
          DATA      			=> DATA,
          LoadEnable 		=> LoadEnable,
          Busy       		=> Busy,
          SCLK_20MHz_IBUFG => SCLK_20MHz_IBUFG
        );

   -- Clock process definitions
   CLOCK_process :process
   begin
		Clock <= '1';
		wait for CLOCK_period/2;
		Clock <= '0';
		wait for CLOCK_period/2;
   end process;
 
   -- Stimulus process
   stim_proc: process
   begin		
     
      -- insert stimulus here 
		-- hold reset state for 100 ns.
		SyncReset <=  '1';
		wait for 100 ns;
		R_W 	    <=  '1';
		Enable    <=  '1';
		SyncReset <=  '0';
		SCLk_Pol  <=  '0';
		SCLK_Pha  <=  '0';
		wait for 600 ns;
		SyncReset <= '1';
		wait for 30 ns;
		SyncReset <= '0';
      wait;
   end process;

END;
