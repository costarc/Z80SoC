-- VHDL CODE by Gerry O'Brien - HD44780 LCD Controller STATE_MACHINE
--==================================================--
--
-- VHDL Architecture DE2_LCD_lib.TOP_LCD_DE2.LCD_DISPLAY_arch
--
-- Created:
--          by - Gerry O'Brien 
--          WWW.DIGITAL-CIRCUITRY.COM
--          at - 15:30:18 26/03/2015
-- 
-- using Mentor Graphics HDL Designer(TM) 2010.3 (Build 21)
--
LIBRARY IEEE;
USE  IEEE.STD_LOGIC_1164.all;
USE  IEEE.STD_LOGIC_ARITH.all;
USE  IEEE.STD_LOGIC_UNSIGNED.all;


ENTITY LCD IS
   
   PORT( 
		reset             : IN     std_logic;  -- Map this Port to a Switch within your [Port Declarations / Pin Planer]  
		CLOCK_50          : IN     std_logic;  -- Using the DE2 50Mhz Clk, in order to Genreate the 400Hz signal... clk_count_400hz reset count value must be set to:  <= x"0F424"
		LCD_RS            : OUT    std_logic;
		LCD_EN            : OUT    std_logic;
		LCD_RW            : OUT    std_logic;
		LCD_ON            : OUT    std_logic;
		LCD_BLON          : OUT    std_logic;
		LCD_DATA          : INOUT 	STD_LOGIC_VECTOR(7 DOWNTO 0);
		lcd_on_sig		  : IN		STD_LOGIC;
		next_char		  : IN 		STD_LOGIC_VECTOR(7 DOWNTO 0);
		char_count        : OUT 	STD_LOGIC_VECTOR(4 downto 0);
		clk400hz	      : OUT		STD_LOGIC
   );

END LCD ;

--
ARCHITECTURE RTL OF LCD IS
  
  type state_type is (hold, func_set, display_on, mode_set, print_string,
                      line2, return_home, drop_LCD_EN, reset1, reset2,
                       reset3, display_off, display_clear);
                       
  signal state, next_command         : state_type;
  
  signal data_bus_value				 : STD_LOGIC_VECTOR(7 downto 0);
  signal clk_count_400hz             : STD_LOGIC_VECTOR(19 downto 0);
  signal char_count_sig              : STD_LOGIC_VECTOR(4 downto 0);
  signal clk_400hz_enable,LCD_RW_int : std_logic; 
  signal data_bus                    : STD_LOGIC_VECTOR(7 downto 0);	
  signal LCD_CHAR_ARRAY              : STD_LOGIC_VECTOR(3 DOWNTO 0);

BEGIN

LCD_DATA 	<= data_bus;
data_bus 	<= data_bus_value when LCD_RW_int = '0' else "ZZZZZZZZ";
LCD_RW 		<= LCD_RW_int;
char_count	<= char_count_sig;
clk400hz		<= clk_400hz_enable;

--======================= CLOCK SIGNALS ============================--  
process(CLOCK_50)
begin
      if (rising_edge(CLOCK_50)) then
         if (reset = '0') then
            clk_count_400hz <= x"00000";
            clk_400hz_enable <= '0';
         else
            if (clk_count_400hz <= x"0F424") then          -- If using the DE2 50Mhz Clock,  use clk_count_400hz <= x"0F424"  (50Mhz/400hz = 12500 converted to HEX = 0F424 )   
                   clk_count_400hz <= clk_count_400hz + 1; --  In Theory for a 27Mhz Clock,  use clk_count_400hz <= x"01A5E"  (27Mhz/400hz = 6750  converted to HEX = 01A5E )                                       
                   clk_400hz_enable <= '0';                --  In Theory for a 25Mhz Clock.  use clk_count_400hz <= x"0186A"  (25Mhz/400hz = 6250  converted to HEX = 0186A )
            else
                   clk_count_400hz <= x"00000";
                   clk_400hz_enable <= '1';
            end if;
         end if;
      end if;
end process;  
--==================================================================--    
  
--======================== LCD DRIVER CORE ==============================--   
--                     STATE MACHINE WITH RESET                          -- 
--===================================================-----===============--  
process (CLOCK_50, reset)
begin
        if reset = '0' then
           state <= reset1;
           data_bus_value <= x"38"; -- RESET
           next_command <= reset2;
           LCD_EN <= '1';
           LCD_RS <= '0';
           LCD_RW_int <= '0';
    
        elsif rising_edge(CLOCK_50) then
             if clk_400hz_enable = '1' then  
                 
                 
                 
              --========================================================--                 
              -- State Machine to send commands and data to LCD DISPLAY
              --========================================================--
                 case state is
                 -- Set Function to 8-bit transfer and 2 line display with 5x8 Font size
                 -- see Hitachi HD44780 family data sheet for LCD command and timing details
                       
                       
                       
--======================= INITIALIZATION START ============================--
                       when reset1 =>
                            LCD_EN <= '1';
                            LCD_RS <= '0';
                            LCD_RW_int <= '0';
                            data_bus_value <= x"38"; -- EXTERNAL RESET
                            state <= drop_LCD_EN;
                            next_command <= reset2;
                            char_count_sig <= "00000";
  
                       when reset2 =>
                            LCD_EN <= '1';
                            LCD_RS <= '0';
                            LCD_RW_int <= '0';
                            data_bus_value <= x"38"; -- EXTERNAL RESET
                            state <= drop_LCD_EN;
                            next_command <= reset3;
                            
                       when reset3 =>
                            LCD_EN <= '1';
                            LCD_RS <= '0';
                            LCD_RW_int <= '0';
                            data_bus_value <= x"38"; -- EXTERNAL RESET
                            state <= drop_LCD_EN;
                            next_command <= func_set;
            
            
                       -- Function Set
                       --==============--
                       when func_set =>                
                            LCD_EN <= '1';
                            LCD_RS <= '0';
                            LCD_RW_int <= '0';
                            data_bus_value <= x"38";  -- Set Function to 8-bit transfer, 2 line display and a 5x8 Font size
                            state <= drop_LCD_EN;
                            next_command <= display_off;
                            
                            
                            
                       -- Turn off Display
                       --==============-- 
                       when display_off =>
                            LCD_EN <= '1';
                            LCD_RS <= '0';
                            LCD_RW_int <= '0';
                            data_bus_value <= x"08"; -- Turns OFF the Display, Cursor OFF and Blinking Cursor Position OFF.......(0F = Display ON and Cursor ON, Blinking cursor position ON)
                            state <= drop_LCD_EN;
                            next_command <= display_clear;
                           
                           
                       -- Clear Display 
                       --==============--
                       when display_clear =>
                            LCD_EN <= '1';
                            LCD_RS <= '0';
                            LCD_RW_int <= '0';
                            data_bus_value <= x"01"; -- Clears the Display    
                            state <= drop_LCD_EN;
                            next_command <= display_on;
                           
                           
                           
                       -- Turn on Display and Turn off cursor
                       --===================================--
                       when display_on =>
                            LCD_EN <= '1';
                            LCD_RS <= '0';
                            LCD_RW_int <= '0';
                            data_bus_value <= x"0C"; -- Turns on the Display (0E = Display ON, Cursor ON and Blinking cursor OFF) 
                            state <= drop_LCD_EN;
                            next_command <= mode_set;
                          
                          
                       -- Set write mode to auto increment address and move cursor to the right
                       --====================================================================--
                       when mode_set =>
                            LCD_EN <= '1';
                            LCD_RS <= '0';
                            LCD_RW_int <= '0';
                            data_bus_value <= x"06"; -- Auto increment address and move cursor to the right
                            state <= drop_LCD_EN;
                            next_command <= print_string; 
                            
                                
--======================= INITIALIZATION END ============================--                          
                          
                          
                          
                          
--=======================================================================--                           
--               Write ASCII hex character Data to the LCD
--=======================================================================--
                       when print_string =>          
                            state <= drop_LCD_EN;
                            LCD_EN <= '1';
                            LCD_RS <= '1';
                            LCD_RW_int <= '0';
                          
                          
                               -- ASCII character to output
                               if (next_char(7 downto 4) /= x"0") then
                                  data_bus_value <= next_char;
                               else
                             
                                    -- Convert 4-bit value to an ASCII hex digit
                                    if next_char(3 downto 0) >9 then 
                              
                                    -- ASCII A...F
                                      data_bus_value <= x"4" & (next_char(3 downto 0)-9); 
                                    else 
                                
                                    -- ASCII 0...9
                                      data_bus_value <= x"3" & next_char(3 downto 0);
                                    end if;
                               end if;
                          
                            state <= drop_LCD_EN; 
                          
                          

                            -- Loop to send out 32 characters to LCD Display (16 by 2 lines)
                               if (char_count_sig < 31) AND (next_char /= x"fe") then
                                   char_count_sig <= char_count_sig +1;                            
                               else
                                   char_count_sig <= "00000";
                               end if;
                  
                  
                  
                            -- Jump to second line?
                               if char_count_sig = 15 then 
                                  next_command <= line2;
                   
                   
                   
                            -- Return to first line?
                               elsif (char_count_sig = 31) or (next_char = x"fe") then
                                     next_command <= return_home;
                               else 
                                     next_command <= print_string; 
                               end if; 
                 
                 
                 
                       -- Set write address to line 2 character 1
                       --======================================--
                       when line2 =>
                            LCD_EN <= '1';
                            LCD_RS <= '0';
                            LCD_RW_int <= '0';
                            data_bus_value <= x"c0";
                            state <= drop_LCD_EN;
                            next_command <= print_string;      
                     
                     
                       -- Return write address to first character position on line 1
                       --=========================================================--
                       when return_home =>
                            LCD_EN <= '1';
                            LCD_RS <= '0';
                            LCD_RW_int <= '0';
                            data_bus_value <= x"80";
                            state <= drop_LCD_EN;
                            next_command <= print_string; 
                    
                    
                    
                       -- The next states occur at the end of each command or data transfer to the LCD
                       -- Drop LCD E line - falling edge loads inst/data to LCD controller
                       --============================================================================--
                       when drop_LCD_EN =>
                            LCD_EN <= '0';
                            state <= hold;
                   
                       -- Hold LCD inst/data valid after falling edge of E line
                       --====================================================--
                       when hold =>
                            state <= next_command;
                            LCD_BLON <= '1';
									 LCD_ON <= lcd_on_sig;
                       end case;




             end if;-- CLOSING STATEMENT FOR "IF clk_400hz_enable = '1' THEN"
             
      end if;-- CLOSING STATEMENT FOR "IF reset = '0' THEN" 
      
end process;                                                            
  
END ARCHITECTURE RTL;
