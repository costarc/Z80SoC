/*
 *  de1.c
 *  XcodeProject
 *
 *  Created by Ronivon Costa on 11/16/10.
 *  Copyright 2010 __MyCompanyName__. All rights reserved.
 *
 */
#include <de2115.h>
#include <z80soc.h>
#include <string.h>

void redLedsA(unsigned char byte) {
	__sfr __at RLEDSPORTA static RLEDIOPort;
	RLEDIOPort = byte;
} 

void redLedsB(unsigned char byte) {
    __sfr __at RLEDSPORTB static RLEDIOPort;
    RLEDIOPort = byte;
}

void hexlsb0(unsigned char byte) {
	__sfr __at CHEXLSB0 static HEX01;
	HEX01 = byte;
}

void hexmsb0(unsigned char byte) {
	__sfr __at CHEXMSB0 static HEX23;
	HEX23 = byte;
}

void hexlsb1(unsigned char byte) {
    __sfr __at CHEXLSB1 static HEX01;
    HEX01 = byte;
}

void hexmsb1(unsigned char byte) {
    __sfr __at CHEXMSB1 static HEX23;
    HEX23 = byte;
}

unsigned char dipSwitchB(void) {
    __sfr __at DPSWPORTB static SW;
    return SW;
}

void lcdonoff(unsigned char byte) {
    __sfr __at LCDCTLPORT static LCDOnOffPort;
    LCDOnOffPort = byte;
}

/*
void printlcd(short int pos, char s[]) {
    short int i;
    unsigned int lcdmem = readMemoryInt(0x57DC) + pos;
    for (i = 0;i < strlen(s); i++) {
        writeMemory(lcdmem + i, s[i]);
    }
}
 */
