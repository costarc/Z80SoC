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

// read character from registry
unsigned char mygetchar(void) {
    return readMemory(0x57DE);
}

void plotCorners(int x1, int x2, int y1, int y2) {
	cursorxy(x1,y1); printf("X");
	cursorxy(x1,y2); printf("X");
	cursorxy(x2,y1); printf("X");
	cursorxy(x2,y2); printf("X");
}

void plotFromXtoY(int x1, int x2,int lines) {
	int i = 0;
    for (int y = 0; y <= lines; y++) {
        for (int x = x1; x <= x2; x++) {
			cursorxy(x,y);
            printf("%d",i);
			i++;
			if (i>9) i=0;
			if (y > 78)
				delay(10);
			
        }
    }
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
	plotCorners(1,78,1,38);
	plotFromXtoY(0,79,60);
	flashAlert(Success);
    while (1) { } 
}


