/*
 *  s3e.c
 *  XcodeProject
 *
 *  Created by Ronivon Costa on 11/7/10.
 *  Copyright 2010 __MyCompanyName__. All rights reserved.
 *
 */

#include <s3e.h>
#include <z80soc.h>
#include <string.h>

void printlcd(short int pos, char s[]) {
    short int i;
    unsigned int lcdmem = readMemoryInt(0x57DC) + pos;
    for (i = 0;i < strlen(s); i++) {
        writeMemory(lcdmem + i, s[i]);
    }
}

unsigned char rotaryButton(void) {
	__sfr __at ROTARY static ROT;
	return ROT;
}


