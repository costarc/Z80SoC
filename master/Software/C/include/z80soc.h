/*
 *  z80soc.h
 *  XcodeProject
 *
 *  Created by Ronivon Costa on 11/7/10.
 *  Copyright 2010 __MyCompanyName__. All rights reserved.
 *
 */

#define Success     0
#define Error       1

#define greenAlert  0
#define redAlert    1

#define DE1         0
#define S3E         1
#define DE2115      2
#define O3S         3

#define GLEDSPORT	0x01
#define RLEDSPORTA	0x02
#define RLEDSPORTB	0x03
#define CHEXLSB0	0x10
#define CHEXMSB0	0x11
#define CHEXLSB1	0x12
#define CHEXMSB1    0x13
#define LCDCTLPORT  0x15
#define DPSWPORTA	0x20
#define DPSWPORTB	0x21
#define PBUTTPORT	0x30
#define ROTARY		0x70
#define KBDPORT		0x80
#define VOUTPORT	0x90
#define VXPORT		0x91
#define VYPORT		0x92

extern void cls(void);
extern void writeMemory(unsigned int address, unsigned char byte);
extern void writeMemoryInt(unsigned int address, unsigned int value);
extern unsigned char readMemory(unsigned int address);
extern unsigned int readMemoryInt(unsigned int address);
extern void cursorxy(int x, int y);
extern unsigned char inkey(void);
extern int getchar(void);
extern int putchar(int);
extern void greenLeds(unsigned char byte);
extern void redLedsA(unsigned char byte);
extern void redLedsB(unsigned char byte);
extern void hexlsb0(unsigned char byte);
extern void hexmsb0(unsigned char byte);
extern void hexlsb1(unsigned char byte);
extern void hexmsb1(unsigned char byte);
extern void lcdonoff(unsigned char byte);
extern void printlcd(unsigned char pos, char s[]);
extern unsigned char pushButton(void);
extern unsigned char dipSwitchA(void);
extern unsigned char dipSwitchB(void);
extern unsigned char rotaryButton(void);
