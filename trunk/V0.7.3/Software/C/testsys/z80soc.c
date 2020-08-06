#include <z80soc.h>
#include <stdio.h>
#include <string.h>

void cls(void) {
	__asm
    push    hl
    push    bc
    push    af
	ld		hl,(#0x57D4)
    ld		bc,#4799
cls1::
	ld		a,#0x20
	ld		(hl),a
    inc     hl
    dec     bc
    ld      a,b
    or      c
    jr      nz,cls1
    pop    af
    pop    bc
    pop    hl
	__endasm;
}


void writeMemory(unsigned int address, unsigned char byte)
{
    address;
    byte;
    
 // *(unsigned int*)address = byte;
 
    __asm
    pop     bc
    pop	    hl
    push	hl
    push	bc
    ld	    iy,#4
    add	    iy,sp
    ld	    d,0 (iy)
    ld	    (hl),d
    __endasm;
}

unsigned char readMemory(unsigned int address) {
    return *(unsigned int*)address;
}

void writeMemoryInt(unsigned int address, unsigned int value)
{
    address;
    value;
    
   /* __asm
    ;asmStore16bitValue.c:4: hl = address;
    ld		b,-3 (ix)
    ld		c,-4 (ix)
    ;asmStore16bitValue.c:5: bc = value;
    ld		h,-5 (ix)
    ld		l,-6 (ix)
    ld		(hl),c
    inc		hl
    ld		(hl),b
    __endasm;*/
    
    __asm
    pop     de
    pop     hl
    pop     bc
    push    bc
    push    hl
    push    de
    ld      (hl),c
    inc     hl
    ld      (hl),b
    __endasm;
}

unsigned int readMemoryInt(unsigned int address) {
    return *(unsigned int*)address;
}

void cursorxy(short int x, short int y) {
	writeMemory(0x57CE, y);
	writeMemory(0x57CF, x);
	writeMemoryInt(0x57D0, readMemoryInt(0x57D4) + ( readMemory(0x57CC) * y ) + x);
	// printf("DEBUG: NEW VIDEO MEMORY ADDRESS:%x",readMemoryInt(0x52C6));
}

unsigned char inkey(void) {
	__sfr __at KBDPORT static KBDIOPort;
	return KBDIOPort;
}

char getchar(void) {
    char key;
	key=inkey();
    while (key == 0 ) {
        key = inkey();
    }
	return key;
}


void greenLeds(unsigned char byte) {
	__sfr __at GLEDSPORT static GLEDIOPort;
	GLEDIOPort = byte;
} 

unsigned char pushButton(void) {
	__sfr __at PBUTTPORT static PB;
	return PB;
}

unsigned char dipSwitchA(void) {
	__sfr __at DPSWPORTA static SW;
	return SW;
}

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

void printlcd(unsigned char pos, char s[]) {
    unsigned char i;
    unsigned int lcdmem = readMemoryInt(0x57DC) + pos;
    for (i = 0;i < strlen(s); i++) {
        writeMemory(lcdmem + i, s[i]);
    }
}

unsigned char rotaryButton(void) {
    __sfr __at ROTARY static ROT;
    return ROT;
}


