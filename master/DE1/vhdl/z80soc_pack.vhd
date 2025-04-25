-------------------------------------------------------------------------------------------------
-- This design is part of:
-- Z80SoC (Z80 System on Chip)
-- Ronivon Candido Costa
-- ronivon.costa@gmail.com
--

library ieee;
use ieee.std_logic_1164.all;

package z80soc_pack is

    -- 0 = DE1, 1 = S3E, 2 = DE2, 3 = O3S
	constant Z80SOC_Arch_value	: std_logic_vector(2 downto 0) := "000";

	-- Generic constrainsts
	constant random_width      : integer := 16; -- size of random number to generate
	constant vid_cols          : integer := 80; -- video number of columns
	constant vid_lines         : integer := 60; -- video number of lines
	constant pixelsxchar       : integer := 1;
	constant Z80SOC_Arch_addr  : std_logic_vector(15 downto 0)  := x"57DF";	
	constant KEYPRESS_addr     : std_logic_vector(15 downto 0) := x"57DE";
	constant LCD_addr          : std_logic_vector(15 downto 0)  := x"57DC";
	constant RAMTOP_addr       : std_logic_vector(15 downto 0)  := x"57DA";
	constant RAMBOTT_addr      : std_logic_vector(15 downto 0) := x"57D8";
	constant CHARRAM_addr      : std_logic_vector(15 downto 0) := x"57D6";
	constant VRAM_addr         : std_logic_vector(15 downto 0) := x"57D4";
	constant STACK_addr        : std_logic_vector(15 downto 0) := x"57D2";
	constant LCD_value         : std_logic_vector(15 downto 0)  := x"57E0";
	constant RAMBOTT_value     : std_logic_vector(15 downto 0)  := x"6000";
	constant VRAM_value        : std_logic_vector(15 downto 0)  := x"4000";
	constant CHARRAM_value     : std_logic_vector(15 downto 0)  := x"5800";	
	
	-- DE1
	constant SRAM_width		: integer := 17;
	constant RAMTOP_value		: std_logic_vector(15 downto 0) := x"FFFF";
   constant STACK_value         : std_logic_vector(15 downto 0) := x"FFFF";

	-- DE2-115
	--constant SRAM_width        : integer := 20;
	--constant RAMTOP_value      : std_logic_vector(15 downto 0) := x"FFFF";
	--constant STACK_value         : std_logic_vector(15 downto 0) := x"FFFF";

   --Open3S500E
	--constant LCD_value          : std_logic_vector(15 downto 0) := x"57E0";
	--constant GLCD_value	      : std_logic_vector(15 downto 0) := x"UUUU";
       --constant SRAM_width         : integer := 14;
       --constant RAMTOP_value       : std_logic_vector(15 downto 0) := x"BFFF";
       --constant STACK_value        : std_logic_vector(15 downto 0) := x"BFFF";
	
end  z80soc_pack;