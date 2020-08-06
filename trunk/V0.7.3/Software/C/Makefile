PROGRAMNAME=testsys

ROMDIR=~/Dev/z80soc-local/hw/0.7.3/ROMdata

IDIR =./include
CC=sdcc
CFLAGS=-I$(IDIR)
 
ODIR=.
LDIR=./lib
 
LIBS=-lm
 
_DEPS = z80soc.h
DEPS = $(patsubst %,$(IDIR)/%,$(_DEPS))
 
_OBJ = z80soc.rel
OBJ = $(patsubst %,$(ODIR)/%,$(_OBJ))
 
 
$(ODIR)/%.rel: $(PROGRAMNAME)/%.c $(DEPS)
	$(CC) -mz80  $(CFLAGS) -c -o $@ $< 
 
$(PROGRAMNAME): $(OBJ)
	sdasz80 -o crt0.rel $(PROGRAMNAME)/crt0.s
	$(CC) -mz80 $(CFLAGS) --code-loc 0x0100 --data-loc 0x0000 --no-std-crt0 crt0.rel $^ $(PROGRAMNAME)/$@.c
	touch $(ROMDIR)/rom.hex $(ROMDIR)/rom.mif $(ROMDIR)/rom.coe 
	rm *.lst *.sym *.lk *.noi $(ROMDIR)/rom.*
	packihx $(PROGRAMNAME).ihx        > $(PROGRAMNAME).hex
	cp $(PROGRAMNAME).hex $(ROMDIR)/rom.hex
	bin/hex2mif.sh $(PROGRAMNAME).ihx > $(PROGRAMNAME).mif
	bin/mif2coe.sh $(PROGRAMNAME).mif > $(PROGRAMNAME).coe
	cp $(PROGRAMNAME).mif $(ROMDIR)/rom.mif
	cp $(PROGRAMNAME).coe $(ROMDIR)/rom.coe
 

.PHONY: clean
 
clean:
	rm -f *.rel *.lst *.sym *.ihx *.asm *.lk *.map *.noi

