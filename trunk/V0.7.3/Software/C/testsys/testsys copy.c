#include <de2115.h>
#include <z80soc.h>
#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>

void delay(int count) {
	if (count > 0) {
		for (count; count>0; count--) {
			readMemory(0x0000);
		}
	}
}

// blink leds until pushbutton 0 is pressed
void waitToExit(void) {
    while (pushButton() != 0b00000001) {
        greenLeds(0xFF);
        delay(5000);
        greenLeds(0x00);
        delay(5000);
    }
}

unsigned char testmodule(unsigned int baseAddress, unsigned int endAddress, short int baseAddressL, short int baseAddressH) {
    
    unsigned char currdip = dipSwitchA();
    unsigned char mychar  = 0;
    
    while (baseAddress < endAddress) {
        hexlsb0(baseAddressL);
        hexmsb0(baseAddressH);

        mychar = 0x41;
        hexmsb1(mychar);
        writeMemory(baseAddress, mychar);
        
        mychar = 0xAA;
        mychar = readMemory(baseAddress);
        hexlsb1(mychar);
        
        if ( mychar == 0x41) {
            greenLeds(readMemory(baseAddress));
            baseAddressL++;
            baseAddress++;
            if (baseAddressL > 0xFF) {
                baseAddressL = 0x00;
                baseAddressH++;
            }
        } else {
            waitToExit();
            return 0xFF;
        }
    }
    
    waitToExit();
    return 0xAA;
}

unsigned char testvram(void) {
    unsigned char nchar = 0;
    unsigned int addr = readMemoryInt(0x57D4);
    unsigned int endaddr = addr + 4800;
    
    hexlsb0(readMemory(0x57D4));
    hexmsb0(readMemory(0x57D5));
    while (addr < endaddr) {
        writeMemory(addr,nchar);
        nchar++;
        if (nchar == 255) nchar = 0;
        addr++;
    }
    waitToExit();
    return 0xAA;
}

unsigned char testlcd(void) {
    unsigned char nchar = 0;
    unsigned int addr = readMemoryInt(0x57DC);
    
    hexlsb0(readMemory(0x57DC));
    hexmsb0(readMemory(0x57DD));

    printlcd(0,"**** Z80SoC ****");
    printlcd(16,"  Retro-CPU.run ");

    waitToExit();
    return 0xAA;
}

unsigned char lcdcls(void) {
    unsigned char nchar = 0;
    unsigned int addr = readMemoryInt(0x57DC);
    
    hexlsb0(readMemory(0x57DC));
    hexmsb0(readMemory(0x57DD));
    while (nchar < 32) {
        writeMemory(addr,32);
        nchar++;
        addr++;
    }
    return 0xAA;
}

unsigned char testCharRam(void) {
    // will redefine char with ascii codes 1 to 4
    unsigned int baseAddress = readMemoryInt(0x57D6) + 8;
    short int i;
    unsigned char hero_bits[] = {
        0x01,0x01,0x03,0x13,0x13,0x97,0x97,0x9e,
        0x80,0x80,0xc0,0xc8,0xc8,0xe9,0xe9,0x79,
        0xbc,0xbd,0xff,0xff,0xfb,0xf3,0xe1,0xc1,
        0x3d,0xbd,0xff,0xff,0xdf,0xcf,0x87,0x83
    };
    
    for (i = 0; i < 32; i++) {
        writeMemory(baseAddress + i, hero_bits[i]);
    }
    
    writeMemory(readMemoryInt(0x57D4) + 10*80 + 31,1);
    writeMemory(readMemoryInt(0x57D4) + 10*80 + 32,2);
    writeMemory(readMemoryInt(0x57D4) + 11*80 + 31,3);
    writeMemory(readMemoryInt(0x57D4) + 11*80 + 32,4);
    
    waitToExit();
    return 0xAA;
}

unsigned char testprintf(char s[]) {
    // set device output to video
    writeMemory(0x57CD,0);

    hexlsb0(readMemory(0x57D0));
    hexmsb0(readMemory(0x57D1));

    printf(s);
    
    return 0xAA;
}

void main(void) {
    
    unsigned char SW = 0;
    short int LEDCOUNT = 0;
    short int baseAddressL;
    short int baseAddressH;
    unsigned int baseAddress = 0;
    unsigned int endAddress = 0;
    unsigned int myvramaddr;
    int i;
    int direction;
    
    myvramaddr = readMemoryInt(0x57D4) + (5 * 32);
    writeMemoryInt(0x57D0, myvramaddr);
    
    cls();
    lcdonoff(1);
    
    printlcd(0,"TestSys Z80SoC  ");
    if (readMemory(0x57DF) == 0) {
        printlcd(16,"  running on DE1");
    } else if (readMemory(0x57DF) == 1) {
        printlcd(16,"  running on S3E");
    } else if (readMemory(0x57DF) == 2) {
        printlcd(16,"  running on DE2");
    }
    
    while (1) {

    cursorxy(15,3);
    printf("TestSys - A hardware test program for the Z80SoC");
        
    redLedsA(LEDCOUNT);
    LEDCOUNT++;
        
    SW = dipSwitchA();
        
     switch (SW) {
        case 1:
            // test sram
            printf("\n\n\n      Testing RAM. Check the address being tested on the 7SEG Display");
            baseAddressL = readMemory(0x57D8);
            baseAddressH = readMemory(0x57D9);
            baseAddress = readMemoryInt(0x57D8);
            endAddress = readMemoryInt(0x57DA) - 0x100;
            hexmsb1(testmodule(baseAddress, endAddress, baseAddressL, baseAddressH));
            waitToExit();
            break;
        case 2:
            // test vram
            //hexmsb1(testvram());
             baseAddressL = readMemory(0x57D4);
             baseAddressH = readMemory(0x57D5);
             baseAddress = readMemoryInt(0x57D4);
             endAddress = readMemoryInt(0x57D8);
             hexmsb1(testmodule(baseAddress, endAddress, baseAddressL, baseAddressH));
             waitToExit();
             cls();
            break;
        case 4:
             // test lcd
             if (readMemory(0x57DF) == 0) {
                 printf("\n\n\n     DE1 platform don't have LCD display");
                 waitToExit();
                 cls();
             } else {
                     printf("\n\n\n      Check the LCD display");
                     lcdonoff(0);
                     waitToExit();
                     lcdonoff(1);
                    }
             break;
        case 8:
             // test lcd
             if (readMemory(0x57DF) == 0) {
                 printf("\n\n\n     DE1 platform don't have LCD display");
                 waitToExit();
                 cls();
             } else {
                     printf("\n\n\n      Check the LCD display");
                     hexmsb1(testlcd());
                     waitToExit();
                     printlcd(0,"TestSys Z80SoC  ");
                 
                    if (readMemory(0x57DF) == 1) {
                        printlcd(16,"  running on S3E");
                    } else if (readMemory(0x57DF) == 2) {
                              printlcd(16,"  running on DE2");
                           }
              }
             break;
        case 16:
            // test charram
            hexlsb0(readMemory(0x57D6));
            hexmsb0(readMemory(0x57D7));
            hexmsb1(testCharRam());
            waitToExit();
            cls();
            break;
         case 32:
             printf("\n\n\n              Testing the printf C function and newlines \\n");
             cursorxy(10,10);
             printf("1******************** Z80SoC ********************");
             cursorxy(10,11);
             printf("2******************** Z80SoC ********************");
             cursorxy(10,12);
             printf("3******************** Z80SoC ********************");
             printf("<< end>>");
             
             printf("\n>>>printing after\n\n\n\n>>>four new lines\n");
             
             hexlsb0(readMemory(0x57D0));
             hexmsb0(readMemory(0x57D1));
             
             printf("    1\n");
             printf("    2\n");
             printf("    3\n\n");
             printf("    4\n");

             waitToExit();
             cls();
             break;
         case 64:
             cls();
             cursorxy(5,2);
             printf("Testing char type storage and retrieve using writeMemory() function\n");
             cursorxy(5,3);
             printf("Confirms that a single byte is being written");
             baseAddress = readMemoryInt(0x57D8);
             for (i=0; i<10; i++) {
                 writeMemory(baseAddress + i, i);
                 writeMemory(baseAddress + 20 + 9 - i, 9 - i);
             }
             
             cursorxy(5,5);
             printf("written up down");
             cursorxy(40,5);
             printf("written down up");
             
             for (i=0; i<10; i++) {
                 cursorxy(5,6+i);
                 printf("%d",readMemory(baseAddress + i));
                 cursorxy(40,6+i);
                 printf("%d",readMemory(baseAddress + 20 + i));
             }
             
             waitToExit();
             cls();
             break;
         case 128:
             // random number generator test
             printf("\n    Testing the random integer number generator implemented inside thr FPGA (0xFFCA)");
             cursorxy(5,5);
             for (i=0; i<2000; i++) {
                 direction = readMemoryInt(0x57C9); // get a rumdom number - integer
                 printf("%i ",direction);
             }
             waitToExit();
             cls();
             break;
     }
   }
}


