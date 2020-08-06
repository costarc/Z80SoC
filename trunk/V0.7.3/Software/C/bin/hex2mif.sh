#!/bin/sh
# hex2mif.sh
# By: Ronivon Candido Costa - ronivon.costa@gmail.com
# 2010 - 12 - 05
# ----------------------------------------------------------------------------------------------
# This tool runs on Cygwin, Linux and Mac OS X
#
# hex2mif.sh will take an input file in Hex format and convert to a .mif format,
# which can be used to initialize rom/rams for Alrera and Xilinx devices.
# hex2mif.sh understand the formats:
# - Motorola HEX format
# - Z80ASM format (after assembled, use the View in Hex format, and copy the contents to rom.hex
#
# To use, pass the input file as parameter::
# " hex2mif.sh file.ihx  >rom.mif
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


convMotorolaHexToMifXilinx() {

  in=$1

  let address=0
  while read line   
  do
    if [[ "$line" != ":END" ]];then
       let len=${#line}-5
       fileaddress=`echo "obase=10;ibase=16;${line:0:4}" | bc`

          while [[ $address -lt $fileaddress ]]
          do
              echo "00000000"
              let address=address+1
          done

       let bytepos=5
       while [[ $len -gt 0 ]] 
       do
          binvalue="00000000"`echo "obase=2;ibase=16;${line:$bytepos:2}" | bc`
          echo ${binvalue:(-8)}
          let bytepos=bytepos+2
          let len=len-2
          let address=address+1
       done
    fi
  done<$in
}

convMotorolaHexToMifAltera() {

  in=$1

  let address=0

echo "DEPTH = 16384;
WIDTH = 8;
ADDRESS_RADIX = HEX;
DATA_RADIX = BIN;
CONTENT
BEGIN"

  while read line
  do
    if [[ "$line" != ":END" ]];then
       let len=${#line}-5
       fileaddress=`echo "obase=10;ibase=16;${line:0:4}" | bc`
          while [[ $address -lt $fileaddress ]]
          do
              hexadd="0000"`echo "obase=16;ibase=10;${address:0:5}" | bc`
              echo "${hexadd:(-4)} : 00000000;"
              let address=address+1
          done

       let bytepos=5
       while [[ $len -gt 0 ]]
       do
          binvalue="00000000"`echo "obase=2;ibase=16;${line:$bytepos:2}" | bc`
          hexadd="0000"`echo "obase=16;ibase=10;${address:0:5}" | bc`
          echo "${hexadd:(-4)} : ${binvalue:(-8)};"
          let bytepos=bytepos+2
          let len=len-2
          let address=address+1
       done
    fi
  done<$in
echo "END;"

}

infile=rom.hex
cp $1 $infile
file=$infile.1
cp $infile $file

# Vefify if file is in Motorola Hex format, and convert to HEX Ascii codes

read line < $file

if [[ ${line:0:1} = ":" ]];then
    sortHexFile $file
    convMotorolaHexToMifAltera $file
else if [[ ${line:4:1} = ":" ]];then
        convMotorolaHexToMifAltera $file
     else echo "File in unknown format... not doing anything."
     fi
fi

rm $file

