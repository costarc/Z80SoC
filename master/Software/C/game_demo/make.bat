@echo off
set "ROM=game_demo"
set "QUARTUS_PROJECT_NAME=z80soc"
set "QUARTUS_PROJECT_FOLDER=..\..\..\DE1"
set "ROM_FOLDER=..\..\..\ROMData"
set "QUARTUS_INSTALL_DIR=c:\Apps\altera\13.0sp1\quartus"

echo Compiling %ROM%
sdcc -mz80 --opt-code-size -I../include -c %ROM%.c
if %ERRORLEVEL% NEQ 0 (
    echo Compiling %ROM% failed!
    exit /b 1
) else (
    echo Hardware Design Compilation finished.
)

sdcc -mz80 -I../include -c ..\include\z80soc.c
sdasz80 -o crt0.rel ..\include\crt0.s
sdcc -mz80 --code-loc 0x0100 --data-loc 0x0000 --no-std-crt0 -o %ROM%.ihx %ROM%.rel z80soc.rel ..\include\crt0.rel

echo Converting the ROM file
rem both .hex and .mif can be used. I created a ihx2mif since .mif seems more standard to use with MegaAizard Plugin memory cores.
rem To use .hex, the ROM memory core should be updated to load rom.hex instead of rom.mif
if not exist "%ROM%.ihx" (
    echo Error: The file "%ROM%.ihx" was not created.
    exit /b 1
)
packihx %ROM%.ihx > %ROM_FOLDER%\rom.hex
..\bin\ihx2mif2.exe %ROM%.ihx %ROM_FOLDER%\rom.mif
if %ERRORLEVEL% NEQ 0 (
    echo Convertion of ihx to mif failed!
    exit /b 1
) else (
    echo Convertion of ihx to mif finished.
)

echo Compiling bitstream %QUARTUS_PROJECT_NAME%
%QUARTUS_INSTALL_DIR%\bin\quartus_sh --flow compile %QUARTUS_PROJECT_FOLDER%\%QUARTUS_PROJECT_NAME%
if %ERRORLEVEL% NEQ 0 (
    echo Hardware Design Compilation failed!
    exit /b 1
) else (
    echo Hardware Design Compilation finished.
)

echo Programming FPGA
%QUARTUS_INSTALL_DIR%\bin\quartus_pgm -c USB-Blaster -m JTAG -o "p;%QUARTUS_PROJECT_FOLDER%\%QUARTUS_PROJECT_NAME%.sof"
if %ERRORLEVEL% NEQ 0 (
    echo Bitstream Programming failed!
    exit /b 1
) else (
    echo Programming successful!
)

echo Cleaning temporary files.
del *.ihx *.mem *.map *.lst *.lk *.sym *.rst *.rel *.noi *.asm *.summary *.rpt *.qpf *.qsf 
rd /S /Q "db"
