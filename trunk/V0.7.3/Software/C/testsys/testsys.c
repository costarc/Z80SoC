#include <z80soc.h>
#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <stdbool.h>

void delay(int count) {
	if (count > 0) {
		for (count; count>0; count--) {
			readMemory(0x0000);
		}
	}
}

// Stedy LEDs for Success
// Blinking LEDs for error
// Keeps looping until push button 1 is pressed
void flashAlert(unsigned char al) {
    while (pushButton() != 0b00000010) {
        greenLeds(0xFF);
        if (al == Error) {
            delay(2000);
            greenLeds(0x00);
            delay(5000);
        }
    }
}

void alert(unsigned char rc) {
    cursorxy(5,13);
    if (rc == Success) {
        printf("Test passed.");
        flashAlert(greenAlert);
    } else {
        printf("Test Failed !!!");
        flashAlert(redAlert);
    }
}

static bool testram(unsigned int baseAddress, unsigned int endAddress) {

    unsigned char mychar0;
    unsigned char mychar1;
    unsigned char mychar2;
    
    while (baseAddress < endAddress) {

        // save current byte in memory
        mychar0 = readMemory(baseAddress);
        
        // write test values to memory
        writeMemory(baseAddress, 0x41);
        mychar1 = readMemory(baseAddress);
        writeMemory(baseAddress, 0x42);
        mychar2 = readMemory(baseAddress);
        
        // restore original byte to memory
        writeMemory(baseAddress, mychar0);

        cursorxy(5,11);
        printf("Writing to address: 0x%x     ",baseAddress);
        
        if ( mychar1 != 0x41 || mychar2 != 0x42) {
            alert(Error);
            return false;
        }
        
        baseAddress++;
    }
    
    alert(Success);
    return true;
}

void redefineChar(unsigned int baseAddress) {
    // will redefine char with ascii codes 1 to 4
    short int i;
    unsigned char hero_bits[] = {
        0x01,0x01,0x03,0x13,0x13,0x97,0x97,0x9e,
        0x80,0x80,0xc0,0xc8,0xc8,0xe9,0xe9,0x79,
        0xbc,0xbd,0xff,0xff,0xfb,0xf3,0xe1,0xc1,
        0x3d,0xbd,0xff,0xff,0xdf,0xcf,0x87,0x83
    };
    
    baseAddress = baseAddress + 8;
    
    for (i = 0; i < 32; i++) {
        writeMemory(baseAddress + i, hero_bits[i]);
    }
    
    writeMemory(readMemoryInt(0x57D4) + 14*80 + 5,1);
    writeMemory(readMemoryInt(0x57D4) + 14*80 + 6,2);
    writeMemory(readMemoryInt(0x57D4) + 15*80 + 5,3);
    writeMemory(readMemoryInt(0x57D4) + 15*80 + 6,4);
    
    alert(Success);
    
}

static bool testlcd(void) {
    unsigned char platf = readMemory(0x57DF);

    cursorxy(5,11);

    if (platf == S3E || platf == DE2115 || platf == O3S) {
        printf("Writing to LCD now...");
        printlcd(0,"**** Z80SoC ****");
        printlcd(16,"  Retro-CPU.run ");
        alert(Success);
        return true;
    } else {
        printf("This platform does not have LCD Display");
        alert(Error);
        return false;
       }
}

void clslcd(void) {
    printlcd(0,"                                ");
}

unsigned char testprintf(char s[]) {
    // set device output to video
    writeMemory(0x57CD,0);

    hexlsb0(readMemory(0x57D0));
    hexmsb0(readMemory(0x57D1));

    printf(s);
    
    return 0xAA;
}

bool platformCheck(unsigned char testId) {
    // testId = 0  => RAM
    // testId = 1  => VRAM
    // testId = 2  => CharRAM
    // testId = 3  => LCDRAM
    // testId = 4  => LCD On/Off
    // testId = 5  => Rotary Button
    // testId = 6  => Pushbuttons
    
    unsigned char platf = readMemory(0x57DF);
    
        if (platf == S3E || platf == DE2115 || platf == O3S ) 
            return true;
        else
            return false;
    
}

// read character from registry
unsigned char mygetchar(void) {
    return readMemory(0x57DE);
}

static bool testkbd(void) {
    unsigned char platf = readMemory(0x57DF);
    unsigned char c, b;

    cursorxy(5,11);
    printf("Starting pressing keys in the keyboard now.\n");
    cursorxy(5,12);
    printf("When you press ENTER the test will finish.\n");
    cursorxy(5,14);
    c = mygetchar();
    b = 0;
    while (c != 13) {
        if (c != b) printf("%c",c);
        b = c;
        c = mygetchar();
        if (platf != 1) {
            hexlsb0(c);
            //hexmsb0(c && 0xf0);
        }
    }
    
    alert(Success);
    return true;
}

void main(void) {
    
    unsigned char SW = 0;
    unsigned char LEDCOUNT = 1;

    unsigned int baseAddress = 0;
    unsigned int endAddress = 0;
    unsigned char platf = readMemory(0x57DF);
    
    /*
    char *PLATFDESC;
 
    switch (platf) {
        case 0: *PLATFDESC="DE1";
        case 1: *PLATFDESC="SPARTAN-3E";
        case 2: *PLATFDESC="DE2-115";
        case 3: *PLATFDESC="Open3S500E";
       default: *PLATFDESC="Unknown";
    }
    */
    
    // TestSys runs in a continuous loop
    while (1) {

    // clear video screen
    cls();
    cursorxy(15,3);
    printf("TestSys - A hardware test program for the Z80SoC");
    cursorxy(15,4);
    printf("Running on Platform %u",platf);
    
    cursorxy(0,20);
    printf("     CONTROLS\n");
    printf("     ========\n\n");
        
    if (platf == DE1) {
        printf("     Switch 9      ==> Reset\n");
        printf("     Switch 8      ==> 3.57Mh / 10Mhz\n");
    }

    if (platf == DE2115) {
        printf("     Switch 17     ==> Reset\n");
        printf("     Switch 16     ==> 3.57Mh / 10Mhz\n");
    }
        
    if (platf == S3E) {
        printf("     Rotary Putton ==> Reset\n");
        printf("     Switch 3      ==> 3.57Mh / 10Mhz\n");
    }

    if (platf == O3S) {
        printf("     North Button  ==> Reset\n");
        printf("     South Button  ==> 3.57Mh / 10Mhz\n");
    }
    
    if (platf == O3S) {
        printf("\n\n");
        printf("     This instructons assume you have the pushbuttons module installed.\n");
        printf("\n\n");
        printf("     These pushbutons will trigger the tests:\n\n");
        printf("     0  ==> RAM      read/write test\n");
        printf("     1  ==> VRAM     read/write test\n");
        printf("     2  ==> CharRAM  read/write test (!!will mess screen!!)\n");
        printf("     3  ==> CharRAM  character redefinition\n");
        printf("     4  ==> LCD      Print text to LCD screen\n");
        printf("     5  ==> KBD/7SEG Test Keyboard and 7 Seg Display\n");
        printf("\n\n");
        printf("     After test ends, press left Joy button to return to main screen\n");
        printf("\n\n");
    } else {
        printf("\n\n");
        printf("     Use the three right Switches to run different tests.\n");
        printf("     Switch positions and tests:\n\n");
        printf("     001  ==> RAM      read/write test\n");
        printf("     010  ==> VRAM     read/write test\n");
        printf("     011  ==> CharRAM  read/write test (!!will mess screen!!)\n");
        printf("     100  ==> CharRAM  character redefinition\n");
        printf("     101  ==> LCD      Print text to LCD screen\n");
        printf("     110  ==> KBD      Test Keyboard");
        
        if (platf != S3E) {
            printf(" and 7Seg Display");
        }
        
        printf("\n\n\n");
        printf("     Set the Switch and press button 0 to start the test\n");
        printf("     After test ends, press button 1 to return to main screen\n");
        printf("\n\n");

    }
        printf("     If green leds are steady, tests passed successfuly.\n");
        printf("     If green leds are flashing, test failed.\n");
        
    // Wait until user press push button 0
    // Switch On/Off Green leds from right to left
    while (pushButton() != 0b00000001) {
        if (LEDCOUNT == 0) LEDCOUNT = 1;
        if (platf == O3S) redLedsA(LEDCOUNT); else greenLeds(LEDCOUNT);
        delay(1000);
        LEDCOUNT=LEDCOUNT*2;
    }
    
    // When user press pushbutton, he has defined what test to run on dip switches
    if (platf != O3S) greenLeds(0); else redLedsA(0);
        
    if (platf != O3S) SW = dipSwitchA(); else SW = pushButton();
        
     switch (SW) {
        case 1:
            // test read/write to RAM
             cursorxy(5,10);
             printf("Testing: RAM");
             baseAddress = readMemoryInt(0x57D8);
             
             // end address leaves 50 bytes for Stack
             endAddress = readMemoryInt(0x57DA) - 50;
             testram(baseAddress, endAddress);
             break;
        case 2:
            // test read/write to VRAM
             cursorxy(5,10);
             printf("Testing: VRAM");
             baseAddress = readMemoryInt(0x57D4);
             endAddress = readMemoryInt(0x57D4) + 4800;
             testram(baseAddress, endAddress);
             break;
         case 3:
             // test read/write to CharRAM
             cursorxy(5,10);
             printf("Testing: CharRAM");
             baseAddress = readMemoryInt(0x57D6);
             // CharRAM size is 8 bits x 256 characters = 2048 bytes
             endAddress = readMemoryInt(0x57D6) + 8 * 256;
             testram(baseAddress, endAddress);
             break;
         case 4:
             // redefine characters in CharRAM and display on screen
             cursorxy(5,10);
             printf("Testing: CharRAM redefinition");
             baseAddress = readMemoryInt(0x57D6);
             redefineChar(baseAddress);
             break;
         case 5:
             // switch on LCD
             lcdonoff(1);
             // print text to lcd display
             testlcd();
             // clear LCD
             clslcd();
             // switch off lcd
             lcdonoff(0);
             break;
         case 6:
             // test keyboard
             cursorxy(5,10);
             printf("Testing: Keyboard input");
             testkbd();
             break;
     }
   }
}


