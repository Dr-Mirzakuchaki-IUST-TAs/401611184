--------------------------------------------------------------------------------
-- Copyright (c) 1995-2013 Xilinx, Inc.  All rights reserved.
--------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor: Xilinx
-- \   \   \/     Version: P.20131013
--  \   \         Application: netgen
--  /   /         Filename: SPI_3WIRE_translate.vhd
-- /___/   /\     Timestamp: Tue Dec 27 23:45:21 2022
-- \   \  /  \ 
--  \___\/\___\
--             
-- Command	: -intstyle ise -rpw 100 -tpw 0 -ar Structure -tm SPI_3WIRE -w -dir netgen/translate -ofmt vhdl -sim SPI_3WIRE.ngd SPI_3WIRE_translate.vhd 
-- Device	: 6slx4tqg144-3
-- Input file	: SPI_3WIRE.ngd
-- Output file	: C:\Users\Behdad\Desktop\tt\tt\netgen\translate\SPI_3WIRE_translate.vhd
-- # of Entities	: 1
-- Design Name	: SPI_3WIRE
-- Xilinx	: C:\Xilinx\14.7\ISE_DS\ISE\
--             
-- Purpose:    
--     This VHDL netlist is a verification model and uses simulation 
--     primitives which may not represent the true implementation of the 
--     device, however the netlist is functionally correct and should not 
--     be modified. This file cannot be synthesized and should only be used 
--     with supported simulation tools.
--             
-- Reference:  
--     Command Line Tools User Guide, Chapter 23
--     Synthesis and Simulation Design Guide, Chapter 6
--             
--------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library SIMPRIM;
use SIMPRIM.VCOMPONENTS.ALL;
use SIMPRIM.VPACKAGE.ALL;

entity SPI_3WIRE is
  port (
    CLOCK : in STD_LOGIC := 'X'; 
    SCLK_Pol : in STD_LOGIC := 'X'; 
    Enable : in STD_LOGIC := 'X'; 
    SyncReset : in STD_LOGIC := 'X'; 
    R_W : in STD_LOGIC := 'X'; 
    DATA : out STD_LOGIC; 
    Busy : out STD_LOGIC; 
    LoadEnable : out STD_LOGIC_VECTOR ( 0 downto 0 ) 
  );
end SPI_3WIRE;

architecture Structure of SPI_3WIRE is
  signal GND_6_o_CLOCK_DFF_7_inv : STD_LOGIC; 
begin
  XST_VCC : X_ONE
    port map (
      O => GND_6_o_CLOCK_DFF_7_inv
    );
  DATA_OBUFT : X_OBUFT
    port map (
      I => GND_6_o_CLOCK_DFF_7_inv,
      CTL => GND_6_o_CLOCK_DFF_7_inv,
      O => DATA
    );
  LoadEnable_0_OBUF : X_OBUF
    port map (
      I => GND_6_o_CLOCK_DFF_7_inv,
      O => LoadEnable(0)
    );
  NlwBlockROC : X_ROC
    generic map (ROC_WIDTH => 100 ns)
    port map (O => GSR);
  NlwBlockTOC : X_TOC
    port map (O => GTS);

end Structure;

