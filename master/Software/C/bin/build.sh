export PATH=/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin:/usr/local/MacGPG2/bin:/Users/ronivon/Dev/SDCC/bin:.:./bin:
PROG=test1
VER=3
BASEDIR=/Users/ronivon/Dev/SDCC/Z80SoC_v0.7.2_rom_C_src

# --

sdasz80 -o $BASEDIR/sources${VER}/crt0.s; mv $BASEDIR/sources${VER}/crt0.rel .
sdcc -mz80 -I$BASEDIR/sources${VER}/ --code-loc 0x0100 --data-loc 0 --stack-loc 0xfffe --no-std-crt0 -c -o de1.rel    $BASEDIR/sources${VER}/de1.c
sdcc -mz80 -I$BASEDIR/sources${VER}/ --code-loc 0x0100 --data-loc 0 --stack-loc 0xfffe --no-std-crt0 -c -o z80soc.rel $BASEDIR/sources${VER}/z80soc.c
sdcc -mz80 -I$BASEDIR/sources${VER}/ --code-loc 0x0100 --data-loc 0 --stack-loc 0xfffe --no-std-crt0 crt0.rel de1.rel z80soc.rel $BASEDIR/sources${VER}/$PROG.c
packihx $PROG.ihx >$BASEDIR/build/rom.hex

exit
# --

sdasz80 -o $BASEDIR/sources${VER}/crt0.s; mv $BASEDIR/sources${VER}/crt0.rel .
sdcc -mz80 -I$BASEDIR/sources${VER}/ --code-loc 0x0100 --data-loc 0 --no-std-crt0 -c -o de1.rel    $BASEDIR/sources${VER}/de1.c
sdcc -mz80 -I$BASEDIR/sources${VER}/ --code-loc 0x0100 --data-loc 0 --no-std-crt0 -c -o z80soc.rel $BASEDIR/sources${VER}/z80soc.c
sdcc -mz80 -I$BASEDIR/sources${VER}/ --code-loc 0x0100 --data-loc 0 --no-std-crt0 crt0.rel de1.rel z80soc.rel $BASEDIR/sources${VER}/$PROG.c
#sdcc -mz80 -I$BASEDIR/sources${VER}/  --no-std-crt0 -c -o de1.rel    $BASEDIR/sources${VER}/de1.c
#sdcc -mz80 -I$BASEDIR/sources${VER}/  --no-std-crt0 -c -o z80soc.rel $BASEDIR/sources${VER}/z80soc.c
#sdcc -mz80 -I$BASEDIR/sources${VER}/  --no-std-crt0 crt0.rel de1.rel z80soc.rel $BASEDIR/sources${VER}/$PROG.c
packihx $PROG.ihx >$BASEDIR/build/$PROG.hex
#hex2mif.sh $PROG.ihx >$BASEDIR/build/$PROG.mif
mv $PROG.ihx $BASEDIR/build/

