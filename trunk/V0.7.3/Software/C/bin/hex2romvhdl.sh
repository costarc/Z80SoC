#!/bin/sh
# hex2romvhdl.sh
# By: Ronivon Candido Costa - ronivon.costa@gmail.com
# 2010 - 11 - 01
# -----------------------------------------------------------------------------------------------
# This tool runs on Cygwin, Linux/Unix and Mac OS X
#
# hex2romvhdl.sh will take a file with hexa bytes as input and convert to a rom format in vhdl
# Input file should be a file named rom.hex, and the format can be:
# - Motorola HEX format
# - Z80ASM format (after assembled, use the option View in Hex format, and copy the contents 
#   to rom.hex
# 
# To use:
# 1. Generate the file with the hex codes using z80asm or...
# 2. Compile you C program using SDCC
# 3. Rename the hex file to "rom.hex"
# 4. Run "hex2romvhdl.sh > rom.vhd" to create the VHDL file "rom.vhd"
# ----------------------------------------------------------------------------------------------

sortHexFile() {
 in=$1
 >$in.tmp
 while read line
 do
    if [[ "$line" != ":00000001FF" ]];then
       len=`echo ${line:1:2} | bc`*2
       addr=${line:3:4}
       echo "$addr:${line:9:$len}" >>$in.tmp
    fi
 done<$in
 cat $in.tmp | sort >$in
 echo ":END" >>$in
 rm $in.tmp
}


HexAciiFormat() {
file=$1
echo "-- File generated by hex2romvhdl.sh"
echo "-- by Ronivon C. Costa - ronivon.costa@gmail.com"
echo "-- `date`"
echo "--"
echo "library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;
--Library XilinxCoreLib;

entity rom is
        port(
                clka        : in std_logic;
                addra       : in std_logic_vector($ROMWIDTH downto 0);
                douta       : out std_logic_vector(7 downto 0)
        );
end rom;

architecture behaviour of rom is

signal A_sig : std_logic_vector($ROMWIDTH downto 0);

begin

process (clka)
begin
 if clka'event and clka = '1' then
    A_sig <= addra;
 end if;
end process;

process (A_sig)
begin
    case to_integer(unsigned(A_sig)) is"


ADDR=0
for i in `cat $file | tr ',' ' '`
do
  BL1="when "
  BL3=" => douta <= x\"$i\";"
  hexaddr="0000"`echo "obase=10;ibase=10;$ADDR" | bc`
  fixhexaddr=${hexaddr:(-5)}
  echo "             "$BL1$fixhexaddr$BL3
  let ADDR=ADDR+1
done
echo "             when others  => D <= \"ZZZZZZZZ\";
        end case;
end process;
end;"

}

MotorolaHEXFormat()  {
echo "-- File generated by hex2romvhdl.sh"
echo "-- by Ronivon C. Costa - ronivon.costa@gmail.com"
echo "-- `date`"
echo "--"
echo "library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;
--Library XilinxCoreLib;

entity rom is
        port(
            clka        : in std_logic;
            addra       : in std_logic_vector($ROMWIDTH downto 0);
            douta       : out std_logic_vector(7 downto 0)
        );
end rom;

architecture behaviour of rom is

signal A_sig : std_logic_vector($ROMWIDTH downto 0);

begin

process (clka)
begin
 if clka and clka = '1' then
    A_sig <= addra;
 end if;
end process;

process (A_sig)
begin
    case to_integer(unsigned(A_sig)) is"

## Generate address mapping
##

file=$1

  while read line   
  do
    if [[ "$line" != ":END" ]];then
 
       address=`echo "obase=10;ibase=16;${line:0:4}" | bc`

       let len=${#line}-5
       let bytepos=5
       while [[ $len -gt 0 ]] 
       do
          BYTE=${line:$bytepos:2}
          BL1="when "
          BL3=" => douta <= x\"$BYTE\";"
          hexaddr="0000"`echo "obase=10;ibase=10;$address" | bc`
          fixhexaddr=${hexaddr:(-5)}
          echo "             "$BL1$fixhexaddr$BL3
          let bytepos=bytepos+2
          let len=len-2
          let address=address+1
       done
    fi
  done<$file

echo "             when others  => D <= \"ZZZZZZZZ\";
        end case;
end process;
end;"

}

infile=$1
ROMWIDTH=$2

let ROMWIDTH=$ROMWIDTH-1
file=$infile.1
cp $infile $file
read line <$file

if [[ ${line:0:1} = ":" ]];then
    sortHexFile $file
    MotorolaHEXFormat $file
else if [[ ${line:4:1} = ":" ]];then
          MotorolaHEXFormat $file
     else HexAciiFormat $file
     fi
fi
rm $file

