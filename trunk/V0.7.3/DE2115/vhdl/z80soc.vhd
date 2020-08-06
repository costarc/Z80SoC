-------------------------------------------------------------------------------------------------
-- Z80SoC (Z80 System on Chip)
-- Ronivon Candido Costa
-- ronivon.costa@gmail.com
--
-- Version history:
-------------------
-- version 0.7.1
-- 2010 / 11 / 22
-- Change memory layout and increased Rom, using Megawizard plug in manager
-- Memory cores redefined
-- Fixed bug in the video.vhd
-- New rom demo in C (SDCC)
--
-- version 0.7
-- Release Date: 2010 / 02 / 17
-- version 0.6 for for Altera DE1
-- Release Date: 2008 / 05 / 21
--
-- Version 0.5 Beta for Altera DE1
-- Developer: Ronivon Candido Costa
-- Release Date: 2008 / 04 / 16
--
-- Based on the T80 core: http://www.opencores.org/projects.cgi/web/t80
-- This version developed and tested on: Altera DE1 Development Board
--
-- Peripherals configured (Using Ports):
--
--  16 KB Internal ROM  Read        (0x0000h - 0x3FFFh)
--  08 KB INTERNAL VRAM Write       (0x4000h - 0x5FFFh)
--  32 KB External SRAM Read/Write  (0x8000h - 0xFFFFh)
--  08 Green Leds       Out     (Port 0x01h)
--  08 Red Leds         Out     (Port 0x02h)
--  04 Seven Seg displays   Out     (Ports 0x11h and 0x10h)
--  36 Pins GPIO0       In/Out  (Ports 0xA0h, 0xA1h, 0xA2h, 0xA3h, 0xA4h, 0xC0h)
--  36 Pins GPIO1       In/Out  (Ports 0xB0h, 0xB1h, 0xB2h, 0xB3h, 0xB4h, 0xC1h)
--  08 Switches         In      (Port 0x20h)
--  04 Push buttons     In      (Port 0x30h)
--  01 PS/2 keyboard        In      (Port 0x80h)
--  01 Video write port In      (Port 0x90h)
--
--  Revision history:
--
-- 2008/05/23 - Modified RAM layout to support new and future improvements
--            - Added port 0x90 to write a character to video.
--            - Cursor x,y automatically updated after writing to port 0x90
--            - Added port 0x91 for video cursor X
--            - Added port 0x92 for video cursor Y
--            - Updated ROM to demonstrate how to use these new resources
--            - Changed ROM to support 14 bit addresses (16 Kb)
--
-- 2008/05/12 - Added support for the Rotary Knob
--            - ROT_CENTER push button (Knob) reserved for RESET
--            - The four push buttons are now available for the user (Port 0x30)
--
-- 2008/05/11 - Fixed access to RAM and VRAM,
--              Released same ROM version for DE1 and S3E
--
-- 2008/05/01 - Added LCD support for Spartan 3E
--
-- 2008/04(21 - Release of Version 0.5-S3E-Beta for Diligent Spartan 3E
--
--  2008/04/17 - Added Video support for 40x30 mode
--
-- 2008/04/16 - Release of Version 0.5-DE1-Beta for Altera DE1
--
-- TO-DO:
-- - Implement hardware control for the A/D and IO pins
-- - Monitor program to introduce Z80 Assmebly codes and run
-- - Serial communication, to download assembly code from PC
-- - Add hardware support for 80x40 Video out
-- - SD/MMC card interface to read/store data and programs
-------------------------------------------------------------------------------------------------
 
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;
use work.z80soc_pack.all;

entity  Z80SOC is
    port(
    CLOCK_50                    : in std_logic;
    KEY                         : in std_logic_vector(3 downto 0);
    SW                          : in std_logic_vector(17 downto 0);
    HEX0                        : out std_logic_vector(6 downto 0);
    HEX1                        : out std_logic_vector(6 downto 0);
    HEX2                        : out std_logic_vector(6 downto 0);
    HEX3                        : out std_logic_vector(6 downto 0);
    HEX4                        : out std_logic_vector(6 downto 0);
    HEX5                        : out std_logic_vector(6 downto 0);
    HEX6                        : out std_logic_vector(6 downto 0);
    HEX7                        : out std_logic_vector(6 downto 0);   
    LEDG                        : out std_logic_vector(8 downto 0);    -- Green LEDs
    LEDR                        : out std_logic_vector(17 downto 0);   -- Red LEDs

    -- UART
    UART_TXD                    : out std_logic;                       -- UART transmitter   
    UART_RXD                    : in std_logic;                        -- UART receiver
    UART_RTS                    : in std_logic;                        -- UART RTS
    UART_CTS                    : in std_logic;                        -- UART CTS

    -- SDRAM                                                          
    DRAM_BA_0                   : out std_logic;                       -- Bank Address 0
    DRAM_BA_1                   : out std_logic;                       -- Bank Address 1   
    DRAM_DQM_0                  : out std_logic;                       -- Byte Data Mask 0
    DRAM_DQM_1                  : out std_logic;                       -- Byte Data Mask 1
    DRAM_DQM_2                  : out std_logic;                       -- Byte Data Mask 2
    DRAM_DQM_3                  : out std_logic;                       -- Byte Data Mask 3
    DRAM_WE_N                   : out std_logic;                      
    DRAM_CAS_N                  : out std_logic;                       -- Column Address 
    DRAM_RAS_N                  : out std_logic;                       -- Row Address Strobe
    DRAM_CS_N                   : out std_logic;                       -- Chip Select
    DRAM_DQ                     : inout std_logic_vector(31 downto 0); -- Data Bus
    DRAM_ADDR                   : out std_logic_vector(12 downto 0);   -- Address Bus 
    DRAM_CLK                    : out std_logic;                       -- Clock
    DRAM_CKE                    : out std_logic;                       -- Clock Enable

    -- FLASH
    FL_DQ                       : inout std_logic_vector(7 downto 0);  -- Data bus
    FL_ADDR                     : out std_logic_vector(22 downto 0);   -- Address bus
    FL_RY                       : in std_logic;
    FL_WP_N                     : out std_logic;                       
    FL_WE_N                     : out std_logic;                       -- Write Enable
    FL_RST_N                    : out std_logic;                       -- Reset
    FL_OE_N                     : out std_logic;                       -- Output Enable
    FL_CE_N                     : out std_logic;                       -- Chip Enable

    -- SRAM
    SRAM_DQ                     : inout std_logic_vector(15 downto 0); -- Data bus 16 Bits
    SRAM_ADDR                   : out std_logic_vector(SRAM_width - 1 downto 0); -- Address bus 18 Bits
    SRAM_UB_N                   : out std_logic;                       -- High-byte Data Mask 
    SRAM_LB_N                   : out std_logic;                       -- Low-byte Data Mask 
    SRAM_WE_N                   : out std_logic;                       -- Write Enable
    SRAM_CE_N                   : out std_logic;                       -- Chip Enable
    SRAM_OE_N                   : out std_logic;                       -- Output Enable

    -- SD card interface
    SD_DAT0                     : in std_logic;                        -- SD Card Data      SD "DAT 0/DataOut"
    SD_DAT1                     : inout std_logic;                     -- SD Card Data   SD "DAT 1"
    SD_DAT2                     : inout std_logic;                     -- SD Card Data 3   SD "DAT 2"
    SD_DAT3                     : out std_logic;                       -- SD Card Data 3    SD "DAT 3/nCS"    
    SD_CMD                      : out std_logic;                       -- SD Card Command   SD "CMD/DataIn"
    SD_CLK                      : out std_logic;                       -- SD Card Clock     SD "CLK"

    -- PS/2 port
    PS2_DAT                     : inout std_logic;                     -- Data
    PS2_CLK                     : inout std_logic;                     -- Clock
    PS2_DAT2                    : inout std_logic;                     -- Data
    PS2_CLK2                    : inout std_logic;                     -- Clock

    -- VGA output
    VGA_SYNC_N                  : out std_logic;
    VGA_CLK                     : out std_logic;
    VGA_BLANK_N                 : out std_logic;
    VGA_HS                      : out std_logic;                       -- H_SYNC
    VGA_VS                      : out std_logic;                       -- SYNC
    VGA_R                       : out std_logic_vector(7 downto 0);    -- Red[7:0]
    VGA_G                       : out std_logic_vector(7 downto 0);    -- Green[7:0]
    VGA_B                       : out std_logic_vector(7 downto 0);    -- Blue[7:0]
  
    -- Audio CODEC
    AUD_ADCLRCK                 : inout std_logic;                     -- ADC LR Clock
    AUD_ADCDAT                  : in std_logic;                        -- ADC Data
    AUD_DACLRCK                 : inout std_logic;                     -- DAC LR Clock
    AUD_DACDAT                  : out std_logic;                       -- DAC Data
    AUD_BCLK                    : inout std_logic;                     -- Bit-Stream Clock
    AUD_XCK                     : out std_logic;                       -- Chip Clock
	
	-- LCD
    LCD_RS                      : out std_logic;
    LCD_EN                      : out std_logic;
    LCD_RW                      : out std_logic;
    LCD_ON                      : out std_logic;
    LCD_BLON                    : out std_logic; -- lcd on de2 do not support this signal
    LCD_DATA                    : inout std_logic_vector(7 downto 0));
end Z80SOC;

architecture rtl of Z80SOC is
    
    component T80se
    generic(
        Mode                    : integer := 0; -- 0 => Z80, 1 => Fast Z80, 2 => 8080, 3 => GB
        T2Write                 : integer := 1; -- 0 => WR_n active in T3, /=0 => WR_n active in T2
        IOWait                  : integer := 1  -- 0 => Siomngle cycle I/O, 1 => Std I/O cycle
    );
    port(
        RESET_n                 : in std_logic;
        CLK_n                   : in std_logic;
        CLKEN                   : in std_logic;
        WAIT_n                  : in std_logic;
        INT_n                   : in std_logic;
        NMI_n                   : in std_logic;
        BUSRQ_n                 : in std_logic;
        M1_n                    : out std_logic;
        MREQ_n                  : out std_logic;
        IORQ_n                  : out std_logic;
        RD_n                    : out std_logic;
        WR_n                    : out std_logic;
        RFSH_n                  : out std_logic;
        HALT_n                  : out std_logic;
        BUSAK_n                 : out std_logic;
        A                       : out std_logic_vector(15 downto 0);
        DI                      : in std_logic_vector(7 downto 0);
        DO                      : out std_logic_vector(7 downto 0)
    );
    end component;

    component rom
    port (
        clock                   : in std_logic;
        address                 : in std_logic_vector(13 downto 0);
        q                       : out std_logic_vector(7 downto 0));
    end component;
    
    component clk_div
    PORT
    (
        clock_in_50Mhz          : in    std_logic;
        clock_25MHz             : out   std_logic;
        clock_10MHz             : out   std_logic;
        clock_357MHz            : out   std_logic;
        clock_1MHz              : out   std_logic;
        clock_100KHz            : out   std_logic;
        clock_10KHz             : out   std_logic;
        clock_1KHz              : out   std_logic;
        clock_100Hz             : out   std_logic;
        clock_10Hz              : out   std_logic;
        clock_1Hz               : out   std_logic);
    end component;

    component decoder_7seg
    port (
        NUMBER                  : in   std_logic_vector(3 downto 0);
        HEX_DISP                : out  std_logic_vector(6 downto 0));
    end component;

    component ps2kbd
    port (  
        keyboard_clk            : inout std_logic;
        keyboard_data           : inout std_logic;
        clock                   : in std_logic;
        clkdelay                : in std_logic;
        reset                   : in std_logic;
        read                    : in std_logic;
        scan_ready              : out std_logic;
        ps2_ascii_code          : out std_logic_vector(7 downto 0));
    end component;
    
    component vram
    port
    (
        rdaddress               : in std_logic_vector (12 downto 0);
        wraddress               : in std_logic_vector (12 downto 0);
        rdclock                 : in std_logic;
        wrclock                 : in std_logic;
        data                    : in std_logic_vector (7 downto 0);
        wren                    : in std_logic;
        q                       : out std_logic_vector (7 downto 0)
    );
    end component;

    component charram
    port (
        data                    : in std_logic_vector (7 downto 0);
        rdaddress               : in std_logic_vector (10 downto 0);
        rdclock                 : in std_logic ;
        wraddress               : in std_logic_vector (10 downto 0);
        wrclock                 : in std_logic;
        wren                    : in std_logic;
        q                       : out std_logic_vector (7 downto 0));
    end component;
    
    COMPONENT video
    PORT (      
        CLOCK_25                : in std_logic;
        VRAM_DATA               : in std_logic_vector(7 downto 0);
        VRAM_ADDR               : out std_logic_vector(13 downto 0);
        VRAM_CLOCK              : out std_logic;
        VRAM_WREN               : out std_logic;
        CRAM_DATA               : in std_logic_vector(7 downto 0);
        CRAM_ADDR               : out std_logic_vector(10 downto 0);
        CRAM_WEB                : out std_logic;
        VGA_R                   : out std_logic_vector(3 downto 0);                
        VGA_G                   : out std_logic_vector(3 downto 0);                
        VGA_B                   : out std_logic_vector(3 downto 0);
        VGA_HS                  : out std_logic;               
        VGA_VS                  : out std_logic);
    END COMPONENT;
    
    COMPONENT LCD
    PORT( 
        reset                   : in     std_logic;  -- map this port to a Switch 
		                                             -- within your [port declarations / Pin Planer]  
        CLOCK_50                : in     std_logic;  -- using the de2 50mhz Clk, 
		                                             -- in order to genreate the 400Hz signal... 
						       -- clk_count_400hz reset count value must be set to:  <= x"0F424"
        LCD_RS                  : out std_logic;
        LCD_EN                  : out std_logic;
        LCD_RW                  : out std_logic;
        LCD_ON                  : out std_logic;
        LCD_BLON                : out std_logic;
        LCD_DATA                : inout std_logic_vector(7 downto 0);
        lcd_on_sig              : in std_logic;
        next_char               : in std_logic_vector(7 downto 0);
        char_count              : out std_logic_vector(4 downto 0);
        clk400hz                : out std_logic);
    END COMPONENT;
    
    signal MREQ_n               : std_logic;
    signal IORQ_n               : std_logic;
    signal RD_n                 : std_logic;
    signal WR_n                 : std_logic;
    signal MWr_n                : std_logic;
    signal Rst_n_s              : std_logic;
    signal Clk_Z80              : std_logic;
    signal DI_CPU               : std_logic_vector(7 downto 0);
    signal DO_CPU               : std_logic_vector(7 downto 0);
    signal A                    : std_logic_vector(15 downto 0);
    signal One                  : std_logic;
    
    signal D_ROM                : std_logic_vector(7 downto 0);
    signal rom_data             : std_logic_vector(7 downto 0);
    signal rom_wren             : std_logic;
    
    signal clk_count_400hz      : std_logic_vector(19 downto 0);
    signal clk100mhz            : std_logic;
    signal clk25mhz             : std_logic;
    signal clk1mhz              : std_logic;
    signal clk10mhz             : std_logic;
    signal clk400hz             : std_logic;
    signal clk100hz             : std_logic;
    signal clk10hz              : std_logic;
    signal clk1hz               : std_logic;
    signal clk357mhz            : std_logic;
    signal clk1khz              : std_logic;
    
    signal HEX_DISP0            : std_logic_vector(6 downto 0);
    signal HEX_DISP1            : std_logic_vector(6 downto 0);
    signal HEX_DISP2            : std_logic_vector(6 downto 0);
    signal HEX_DISP3            : std_logic_vector(6 downto 0);
    signal HEX_DISP4            : std_logic_vector(6 downto 0);
    signal HEX_DISP5            : std_logic_vector(6 downto 0);
    signal HEX_DISP6            : std_logic_vector(6 downto 0);
    signal HEX_DISP7            : std_logic_vector(6 downto 0);
                               
    signal NUMBER0              : std_logic_vector(3 downto 0);
    signal NUMBER1              : std_logic_vector(3 downto 0); 
    signal NUMBER2              : std_logic_vector(3 downto 0);
    signal NUMBER3              : std_logic_vector(3 downto 0);
    signal NUMBER4              : std_logic_vector(3 downto 0);
    signal NUMBER5              : std_logic_vector(3 downto 0); 
    signal NUMBER6              : std_logic_vector(3 downto 0);
    signal NUMBER7              : std_logic_vector(3 downto 0);

    signal  vram_addra          : std_logic_vector(15 downto 0);
    signal  vram_addrb          : std_logic_vector(13 downto 0);
    signal  vram_dina           : std_logic_vector(7 downto 0);
    signal  vram_dinb           : std_logic_vector(7 downto 0);
    signal  vram_douta          : std_logic_vector(7 downto 0);
    signal  vram_doutb          : std_logic_vector(7 downto 0);
    signal  vram_wea            : std_logic; --_vector(0 downto 0);
    signal  vram_web            : std_logic; --_vector(0 downto 0);
    signal  vram_clka           : std_logic;
    signal  vram_clkb           : std_logic;

    signal cram_addra           : std_logic_vector(15 downto 0);
    signal cram_addrb           : std_logic_vector(15 downto 0);
    signal cram_dina            : std_logic_vector(7 downto 0);
    signal cram_dinb            : std_logic_vector(7 downto 0);
    signal cram_douta           : std_logic_vector(7 downto 0);
    signal cram_doutb           : std_logic_vector(7 downto 0);
    signal cram_wea             : std_logic;
    signal cram_web             : std_logic;
    signal cram_clka            : std_logic;
    signal cram_clkb            : std_logic;
    
    -- PS/2 Keyboard
    signal ps2_read             : std_logic;
    signal ps2_scan_ready       : std_logic;
    signal ps2_ascii_sig        : std_logic_vector(7 downto 0);
    signal ps2_ascii_reg1       : std_logic_vector(7 downto 0);
    signal ps2_ascii_reg        : std_logic_vector(7 downto 0);

    -- LCD signals
    type character_string is array ( 0 to 31 ) of STD_LOGIC_VECTOR( 7 downto 0 );
	
    signal lcdvram              : character_string;
    signal lcdaddr_w_sig        : std_logic_vector(15 downto 0);
    signal lcdaddr_sig          : std_logic_vector(15 downto 0) := LCD_value;
    signal char_count_sig       : std_logic_vector(4 downto 0);
    signal next_char_sig        : std_logic_vector(7 downto 0);
    signal temp                 : std_logic;
    
    signal Z80SOC_Arch_reg      : std_logic_vector(2 downto 0)  := Z80SOC_Arch_value;   
	                              -- "000" = DE1, "001" = S3E, "010" = DE2115
    signal RAMTOP_reg           : std_logic_vector(15 downto 0) := RAMTOP_value;
    signal RAMBOTT_reg          : std_logic_vector(15 downto 0) := RAMBOTT_value;
    signal LCD_reg              : std_logic_vector(15 downto 0) := LCD_value;   
    signal VRAM_reg             : std_logic_vector(15 downto 0) := VRAM_value;
    signal STACK_reg            : std_logic_vector(15 downto 0) := STACK_value;
    signal CHARRAM_reg          : std_logic_vector(15 downto 0) := CHARRAM_value;
    signal VIDCOLS_reg          : std_logic_vector(7 downto 0)  := conv_std_logic_vector(vid_cols, 8);
    signal VIDROWS_reg          : std_logic_vector(7 downto 0)  := conv_std_logic_vector(vid_lines, 8);
    signal STDOUT_reg           : std_logic_vector(7 downto 0);
    signal VID_CURSOR           : std_logic_vector(15 downto 0);
    signal LCDON_reg            : std_logic;
	 signal RNDNUMBER_reg        : std_logic_vector (random_width-1 downto 0);
	 
begin
    
    VGA_BLANK_N <= '1';
    VGA_CLK     <= clk25mhz;
    HEX0 <= HEX_DISP0;
    HEX1 <= HEX_DISP1;
    HEX2 <= HEX_DISP2;
    HEX3 <= HEX_DISP3;
    HEX4 <= HEX_DISP4;
    HEX5 <= HEX_DISP5;
    HEX6 <= HEX_DISP6;
    HEX7 <= HEX_DISP7;
	
	--LCDON_reg <= SW(14);
    Rst_n_s       <= not SW(17);
    --STDOUT_reg  <= DO_CPU when (A = x"57CD" and Wr_n = '0' and MReq_n = '0');
    --CURX_reg    <= DO_CPU when (A = x"57CF" and Wr_n = '0' and MReq_n = '0');
    --CURY_reg    <= DO_CPU when (A = x"57CE" and Wr_n = '0' and MReq_n = '0');
    -- Turbo 10Mhz
    Clk_Z80     <= clk357mhz when SW(16) = '0' else clk10mhz;
					 
    --  Write into VRAM and System Variables
    vram_addra  <= A - VRAM_value;
    vram_dina   <= DO_CPU;
    vram_wea    <= '0' when (A >= VRAM_value and A < (VRAM_value + (vid_cols * vid_lines)) and Wr_n = '0' and MReq_n = '0') else 
                   '1';
    
    -- Write into char ram
    cram_addra  <= A - CHARRAM_value;
    cram_dina   <= DO_CPU;
    cram_wea    <= '0' when (A >= CHARRAM_value and A < RAMBOTT_value and Wr_n = '0' and MReq_n = '0') else '1';
 
    -- Write into LCD video ram
    lcdvram(CONV_INTEGER(A - LCD_value)) <= DO_CPU when A >= LCD_value and (A < LCD_value + 32) and Wr_n = '0' and MReq_n = '0';	
  
    lcd_printchar: process(clk400hz)
    begin
        if rising_edge(clk400hz) then
            next_char_sig <= lcdvram(CONV_INTEGER(char_count_sig));
        end if;
   end process;
	 
    -- SRAM control signals
    -- SRAM will store data for video, characters patterns and RAM (only on DE1 version)
    -- Due to limitation in dual-port block rams on this platform

    SRAM_ADDR(15 downto 0)  <= A - VRAM_value;
    SRAM_DQ(7 downto 0)     <= DO_CPU when (Wr_n = '0' and MREQ_n = '0' and A >= VRAM_value) else 
	                            (others => 'Z');                      
    SRAM_WE_N               <= '0' when (Wr_n = '0' and MREQ_n = '0' and A >= VRAM_value) else '1';            
    SRAM_OE_N               <= '0' when (Rd_n = '0' and MREQ_n = '0' and A >= VRAM_value) else '1';
    SRAM_DQ(15 downto 8)    <= (others => 'Z');
    SRAM_ADDR(19 downto 16) <= "0000";
    SRAM_UB_N               <= '1';
    SRAM_LB_N               <= '0';
    SRAM_CE_N               <= '0';
    
    -- Input to Z80
    DI_CPU <= ("00000" & Z80SOC_Arch_reg) when (Rd_n = '0' and MREQ_n = '0' and A = Z80SOC_Arch_addr) else
	          RNDNUMBER_reg(7 downto 0)   when (Rd_n = '0' and MREQ_n = '0' and A = x"57C9") else
			  RNDNUMBER_reg(15 downto 8)  when (Rd_n = '0' and MREQ_n = '0' and A = x"57CA") else
              ps2_ascii_reg               when (Rd_n = '0' and MREQ_n = '0' and A = KEYPRESS_addr) else
		      VIDCOLS_reg                 when (Rd_n = '0' and MREQ_n = '0' and A = x"57CC") else
              VIDROWS_reg                 when (Rd_n = '0' and MREQ_n = '0' and A = x"57CB") else
			  STACK_reg(7 downto 0)       when (Rd_n = '0' and MREQ_n = '0' and A = STACK_addr) else
              STACK_reg(15 downto 8)      when (Rd_n = '0' and MREQ_n = '0' and (A = STACK_addr + 1)) else
              RAMTOP_reg(7 downto 0)      when (Rd_n = '0' and MREQ_n = '0' and A = RAMTOP_addr) else
              RAMTOP_reg(15 downto 8)     when (Rd_n = '0' and MREQ_n = '0' and (A = RAMTOP_addr + 1)) else
              RAMBOTT_reg(7 downto 0)     when (Rd_n = '0' and MREQ_n = '0' and A = RAMBOTT_addr) else
              RAMBOTT_reg(15 downto 8)    when (Rd_n = '0' and MREQ_n = '0' and (A = RAMBOTT_addr + 1)) else
              LCD_reg(7 downto 0)         when (Rd_n = '0' and MREQ_n = '0' and A = LCD_addr) else
              LCD_reg(15 downto 8)        when (Rd_n = '0' and MREQ_n = '0' and (A = LCD_addr + 1)) else
              VRAM_reg(7 downto 0)        when (Rd_n = '0' and MREQ_n = '0' and A = VRAM_addr) else
              VRAM_reg(15 downto 8)       when (Rd_n = '0' and MREQ_n = '0' and (A = VRAM_addr + 1)) else
              CHARRAM_reg(7 downto 0)     when (Rd_n = '0' and MREQ_n = '0' and A = CHARRAM_addr) else
              CHARRAM_reg(15 downto 8)    when (Rd_n = '0' and MREQ_n = '0' and (A = CHARRAM_addr + 1)) else
              D_ROM                       when (Rd_n = '0' and MREQ_n = '0' and IORQ_n = '1' and A < VRAM_value) else
              SRAM_DQ(7 downto 0)         when (Rd_n = '0' and MREQ_n = '0' and IORQ_n = '1' and A >= VRAM_value) else
              SW(7 downto 0)              when (Rd_n = '0' and MREQ_n = '1' and IORQ_n = '0' and A(7 downto 0) = x"20") else
              SW(15 downto 8)             when (Rd_n = '0' and MREQ_n = '1' and IORQ_n = '0' and A(7 downto 0) = x"21") else          
              ("0000" & not KEY)          when (Rd_n = '0' and MREQ_n = '1' and IORQ_n = '0' and A(7 downto 0) = x"30") else
              "ZZZZZZZZ";
    
    -- Process to latch leds and hex displays
    pinout_process: process(Clk_Z80)
    variable NUMBER0_sig : std_logic_vector(3 downto 0);
    variable NUMBER1_sig : std_logic_vector(3 downto 0); 
    variable NUMBER2_sig : std_logic_vector(3 downto 0);
    variable NUMBER3_sig : std_logic_vector(3 downto 0);
    variable NUMBER4_sig : std_logic_vector(3 downto 0);
    variable NUMBER5_sig : std_logic_vector(3 downto 0); 
    variable NUMBER6_sig : std_logic_vector(3 downto 0);
    variable NUMBER7_sig : std_logic_vector(3 downto 0); 
    variable LEDG_sig    : std_logic_vector(7 downto 0);
    variable LEDR_sig    : std_logic_vector(15 downto 0);

    begin       
        if Clk_Z80'event and Clk_Z80 = '1' then
          if IORQ_n = '0' and MREQ_n = '1' and Wr_n = '0' then
            -- LEDG
            if A(7 downto 0) = x"01" then
                LEDG_sig := DO_CPU;
            -- LEDR
            elsif A(7 downto 0) = x"02" then
                LEDR_sig(7 downto 0) := DO_CPU;
            elsif A(7 downto 0) = x"03" then
                LEDR_sig(15 downto 8) := DO_CPU;                
            -- HEX1 and HEX0
            elsif A(7 downto 0) = x"10" then
                NUMBER0_sig := DO_CPU(3 downto 0);
                NUMBER1_sig := DO_CPU(7 downto 4);
            -- HEX3 and HEX2
            elsif A(7 downto 0) = x"11" then
                NUMBER2_sig := DO_CPU(3 downto 0);
                NUMBER3_sig := DO_CPU(7 downto 4);
            -- HEX5 and HEX4
            elsif A(7 downto 0) = x"12" then
                NUMBER4_sig := DO_CPU(3 downto 0);
                NUMBER5_sig := DO_CPU(7 downto 4);
            -- HEX7 and HEX6
            elsif A(7 downto 0) = x"13" then
                NUMBER6_sig := DO_CPU(3 downto 0);
                NUMBER7_sig := DO_CPU(7 downto 4);
            elsif A(7 downto 0) = x"15" then
                LCDON_reg <= DO_CPU(0);
            end if;
		    else
		    -- DEBUG ADDRESS BUSS
			    LEDR_sig(15 DOWNTO 0) := A;
          end if;
        end if;     
		
        -- Latches the signals
        LEDR(15 downto 0) <= LEDR_sig;
        LEDG(7 downto 0)  <= LEDG_sig;		
        NUMBER0           <= NUMBER0_sig;
        NUMBER1           <= NUMBER1_sig;
        NUMBER2           <= NUMBER2_sig;
        NUMBER3           <= NUMBER3_sig;
        NUMBER4           <= NUMBER4_sig;
        NUMBER5           <= NUMBER5_sig;
        NUMBER6           <= NUMBER6_sig;
        NUMBER7           <= NUMBER7_sig;     
    end process;        
        
    -- the following three processes deals with different clock domain signals
	-- to interface with the PS/2 keyboard
    ps2_process1: process(CLOCK_50)
    begin
        if CLOCK_50'event and CLOCK_50 = '1' then
            if ps2_read = '1' then
                if ps2_ascii_sig /= x"FF" then
                    ps2_read <= '0';
                    ps2_ascii_reg1 <= "00000000";
                end if;
            elsif ps2_scan_ready = '1' then
                if ps2_ascii_sig = x"FF" then
                    ps2_read <= '1';
                else
                    ps2_ascii_reg1 <= ps2_ascii_sig;
                end if;
            end if;
        end if;
    end process;
    
    ps2_process2: process(Clk_Z80)
    begin
        if Clk_Z80'event and Clk_Z80 = '1' then
            ps2_ascii_reg <= ps2_ascii_reg1;
        end if;
    end process;
    
	 random: process(CLOCK_50)
        variable rand_temp : std_logic_vector(random_width-1 downto 0):=(random_width-1 => '1',others => '0');
        variable temp : std_logic := '0';
        begin
        if(rising_edge(CLOCK_50)) then
            temp := rand_temp(random_width-1) xor rand_temp(random_width-2);
            rand_temp(random_width-1 downto 1) := rand_temp(random_width-2 downto 0);
            rand_temp(0) := temp;
        end if;
        RNDNUMBER_reg <= rand_temp;
	 end process;
	 
	 
    One <= '1';
    z80_inst: T80se 
    port map (
        M1_n                    => open,
        MREQ_n                  => MREQ_n,
        IORQ_n                  => IORQ_n,
        RD_n                    => Rd_n,
        WR_n                    => Wr_n,
        RFSH_n                  => open,
        HALT_n                  => open,
        WAIT_n                  => One,
        INT_n                   => One,
        NMI_n                   => One,
        RESET_n                 => Rst_n_s,
        BUSRQ_n                 => One,
        BUSAK_n                 => open,
        CLK_n                   => Clk_Z80,
        CLKEN                   => One,
        A                       => A,
        DI                      => DI_CPU,
        DO                      => DO_CPU
    );

    video_inst: video 
	port map (
        CLOCK_25                => clk25mhz,
        VRAM_DATA               => vram_doutb,
        VRAM_ADDR               => vram_addrb(13 downto 0),
        VRAM_CLOCK              => vram_clkb,
        VRAM_WREN               => vram_web,
        CRAM_DATA               => cram_doutb,
        CRAM_ADDR               => cram_addrb(10 downto 0),
        CRAM_WEB                => cram_web,
        VGA_R                   => VGA_R(7 downto 4),
        VGA_G                   => VGA_G(7 downto 4),
        VGA_B                   => VGA_B(7 downto 4),
        VGA_HS                  => VGA_HS,
        VGA_VS                  => VGA_VS
    );

    vram_inst : vram
    port map (
        rdclock                 => vram_clkb,
        wrclock                 => Clk_Z80, 
        wren                    => not vram_wea, -- inverted logic so code is similar to SRAM and S3E port
        wraddress               => vram_addra(12 downto 0),
        rdaddress               => vram_addrb(12 downto 0),
        data                    => vram_dina,
        q                       => vram_doutb
    );

    cram: charram
    port map (  
        rdaddress               => cram_addrb(10 downto 0),
        wraddress               => cram_addra(10 downto 0),
        wrclock                 => Clk_Z80,
        rdclock                 => vram_clkb,
        data                    => cram_dina,
        q                       => cram_doutb,
        wren                    => NOT cram_wea     
    );
    
    rom_inst: rom
    port map (
        clock                   => clk25mhz,
        address                 => A(13 downto 0),
        q                       => D_ROM
    );
 
    clkdiv_inst: clk_div
    port map (
        clock_in_50mhz          => CLOCK_50,
        clock_25mhz             => clk25mhz,
        clock_10MHz             => clk10mhz,
        clock_357Mhz            => clk357mhz,
        clock_1MHz              => clk1mhz,
        clock_100KHz            => open,
        clock_10KHz             => open,
        clock_1KHz              => clk1khz,
        clock_100Hz             => clk100hz,
        clock_10Hz              => clk10hz,
        clock_1Hz               => clk1hz
    );

    DISPHEX0 : decoder_7seg 
	port map (
        NUMBER                  =>  NUMBER0,
        HEX_DISP                =>  HEX_DISP0
    );      

    DISPHEX1 : decoder_7seg 
	port map (
        NUMBER                  =>  NUMBER1,
        HEX_DISP                =>  HEX_DISP1
    );      

    DISPHEX2 : decoder_7seg 
	port map (
        NUMBER                  =>  NUMBER2,
        HEX_DISP                =>  HEX_DISP2
    );      

    DISPHEX3 : decoder_7seg 
	port map (
        NUMBER                  =>  NUMBER3,
        HEX_DISP                =>  HEX_DISP3
    );

        DISPHEX4 : decoder_7seg 
		port map (
        NUMBER                  =>  NUMBER4,
        HEX_DISP                =>  HEX_DISP4
    );      

    DISPHEX5 : decoder_7seg 
	port map (
        NUMBER                  =>  NUMBER5,
        HEX_DISP                =>  HEX_DISP5
    );      

    DISPHEX6 : decoder_7seg 
	port map (
        NUMBER                  =>  NUMBER6,
        HEX_DISP                =>  HEX_DISP6
    );      

    DISPHEX7 : decoder_7seg 
	port map (
        NUMBER                  =>  NUMBER7,
        HEX_DISP                =>  HEX_DISP7
    );
    
    ps2_kbd_inst : ps2kbd 
    port map (
        keyboard_clk            => PS2_CLK,
        keyboard_data           => PS2_DAT,
        clock                   => CLOCK_50,
        clkdelay                => clk100hz,
        reset                   => Rst_n_s,
        read                    => ps2_read,
        scan_ready              => ps2_scan_ready,
        ps2_ascii_code          => ps2_ascii_sig
    );

    lcd_inst: lcd 
	 port map (
        reset                   => Rst_n_s,
        CLOCK_50                => CLOCK_50,
        LCD_RS                  => LCD_RS,
        LCD_EN                  => LCD_EN,
        LCD_RW                  => LCD_RW,
        LCD_ON                  => LCD_ON,
        LCD_DATA                => LCD_DATA(7 DOWNTO 0),
        lcd_on_sig              => LCDON_reg,
        next_char               => next_char_sig,
        char_count              => char_count_sig,
        clk400hz                => clk400hz
    );
    
    --
    UART_TXD    <= 'Z';
    DRAM_ADDR   <= (others => '0');
    DRAM_DQM_0  <= '0';
    DRAM_DQM_1  <= '0';
    DRAM_DQM_2  <= '0';
    DRAM_DQM_3  <= '0';  
    DRAM_WE_N   <= '1';
    DRAM_CAS_N  <= '1';
    DRAM_RAS_N  <= '1';
    DRAM_CS_N   <= '1';
    DRAM_BA_0   <= '0';
    DRAM_BA_1   <= '0';
    DRAM_CLK    <= '0';
    DRAM_CKE    <= '0';
    FL_ADDR     <= (others => '0');
    FL_WE_N     <= '1';
    FL_RST_N    <= '0';
    FL_OE_N     <= '1';
    FL_CE_N     <= '1';
    AUD_DACDAT  <= '0';
    AUD_XCK     <= '0';
    -- Set all bidirectional ports to tri-state
    DRAM_DQ     <= (others => 'Z');
    FL_DQ       <= (others => 'Z');

    AUD_ADCLRCK <= 'Z';
    AUD_DACLRCK <= 'Z';
    AUD_BCLK    <= 'Z';   
end;