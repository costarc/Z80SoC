#include <../include/z80soc.h>
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

void showMenu(unsigned char platf) {
    cursorxy(15,3);
    printf("TestSys - A hardware test program for the Z80SoC");
    cursorxy(15,4);
    printf("Running on Platform: %u",platf);
    
    cursorxy(5,20);printf("CONTROLS");
    cursorxy(5,21);printf("========");
	
	cursorxy(0,24);
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
	// clear video screen
    cls();
	showMenu(0);
	flashAlert(Success);
    while (1) { } 
}


