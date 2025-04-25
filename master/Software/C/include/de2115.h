/*
 *  de1.h
 *  XcodeProject
 *
 *  Created by Ronivon Costa on 11/16/10.
 *  Copyright 2010 __MyCompanyName__. All rights reserved.
 *
 */
/* PLATFORM: 0 = DE1, 1=S3E */
#define RLEDSPORTA	0x02
#define RLEDSPORTB	0x03
#define CHEXLSB0	0x10
#define CHEXMSB0	0x11
#define CHEXLSB1	0x12
#define CHEXMSB1    0x13
#define LCDCTLPORT  0x15
#define DPSWPORTB	0x21

extern void redLedsA(unsigned char byte);
extern void redLedsB(unsigned char byte);
extern void hexlsb0(unsigned char byte);
extern void hexmsb0(unsigned char byte);
extern void hexlsb1(unsigned char byte);
extern void hexmsb1(unsigned char byte);
extern void lcdonoff(unsigned char byte);
extern void printlcd(short int pos, char s[]);
extern unsigned char dipSwitchB(void);
