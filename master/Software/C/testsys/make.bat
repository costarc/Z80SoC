sdcc -mz80 -c %1.c
sdcc -mz80 -c ..\include\z80soc.c
sdasz80 -o crt0.rel ..\include\crt0.s

sdcc -mz80 --code-loc 0x0100 --data-loc 0x0000 --no-std-crt0 -o %1.ihx %1.rel z80soc.rel ..\include\crt0.rel
packihx %1.ihx > ..\..\..\ROMData\rom.hex
del *.ihx *.mem *.map *.lst *.lk *.sym *.rst *.rel *.noi *.asm