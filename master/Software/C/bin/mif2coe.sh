#!/bin/sh

IN=$1


cat $IN | grep -i data_radix | grep -i hex >>trash.tmp 2>>trash.tmp

if [[ $? -eq 0  ]];then
    radix=16
else cat $IN | grep -i data_radix | grep -i oct >>trash.tmp 2>>trash.tmp
     if [[ $? -eq 0  ]];then
         radix=8
     else cat $IN | grep -i data_radix | grep -i bin >>trash.tmp 2>>trash.tmp
         if [[ $? -eq 0  ]];then
             radix=2
         fi
     fi
fi
cat $IN | grep -v % | grep ":" | cut -f2 -d':' | cut -f1 -d";" | tr -d ' ' > mif2coe.tmp

NROWS=`cat mif2coe.tmp | wc -l | tr -d " "`

echo "memory_initialization_radix=$radix;"

echo "memory_initialization_vector="

awk -v ROWS=$NROWS '{if (NR==ROWS) { print $0";" } else { print $0"," }}' mif2coe.tmp 

rm mif2coe.tmp

