/* ROM Demo for Z80SoC
 *
 *  game_demo.c
 *  XcodeProject
 *
 *  Created by Ronivon Costa on 10/5/16.
 *  Copyright 2016 __MyCompanyName__. All rights reserved.
 *
 */

#include <..\include\game_demo.h>
#include <..\include\z80soc.h>
#include <string.h>
#include <stdio.h>
#include <stdlib.h>

void delay(int count) {
	if (count > 0) {
		for (count; count>0; count--) {
			readMemory(0x0000);			// spend some time reading nothing
		}
	}
}

void drawHero(short int x) {
	cursorxy(x,55);
	putchar(0x01);
	putchar(0x02);
	cursorxy(x,56);
	putchar(0x03);
	putchar(0x04);
}

void drawTarget(unsigned char tgt, unsigned char x, unsigned char y) {
    tgt;
	/*
	 
	|/\|
	|\/|
	 
	*/
	 
	cursorxy(x,y);
	putchar('|');
    putchar('/');
	putchar('\\');
    putchar('|');
	cursorxy(x,y+1);
    putchar('|');
    putchar('\\');
	putchar('/');
    putchar('|');
}

void gameTitle(void) {
	cursorxy(26,2);
    
	printf("**** Z80SoC Zombie Aliens ****");
}
			
void drawScore(int points, int lives) {
	cursorxy(2,2);
	printf("Score:%u",points);
	cursorxy(68,2);
	printf("Lives:%u",lives);
}

void defineSprites(void) {
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
}

unsigned char heroFire(void) {
	return 1;
}

short int moveHero(short int herox, short int heroy) {
	unsigned char b = pushButton();
        heroy;
	switch (b) {
		case 0b00000001:
			if (herox < 75) {
				cursorxy(herox, 55);
				putchar(' ');
				cursorxy(herox, 56);
				putchar(' ');
				herox++;
				drawHero(herox);
			}
			break;
		case 0b00001000:
			if (herox > 0) {
				cursorxy(herox + 1, 55);
				putchar(' ');
				cursorxy(herox + 1, 56);
				putchar(' ');
				herox--;
				drawHero(herox);
			}
			break;
		default:
			break;
	}
	return herox;
}

void moveAlien(unsigned int baseAddress, unsigned char tgt, unsigned char dety) {
	/*
	Memory allocation for targets: 10 slots for every alien
	 baseAddress     : x position (0 to 79)
	 baseAddress + 1 : y position (2 to 59)
	 baseAddress + 2 : direction -> from 0 to 7, 0=north, 4 south, 7 nothwest
	 baseAddress + 3 : counter for the current direction
	 baseAddress + 4 : bullet fired 'y' / 'n'
	 baseAddress + 5 : bullet x position (when target has fired)
	 baseAddress + 6 : bullet y position (when target has fired)
	 baseAddress + 7 : 0=alien is dead, 1=alien is alive
	 baseAddress + 6 t0 9: reserved
	*/
	short int tgtInd = (tgt - 1) * 10;  // this index allows for multiples enemies in this function
	short int tx       = readMemory(baseAddress + tgtInd);
	short int ty       = readMemory(baseAddress + 1 + tgtInd);
	short int dirCount = readMemory(baseAddress + 3 + tgtInd);
	short int direction;
	short int newdirection;
	unsigned char leftBorder = 1, rightBorder = 57, top = 3, bottom = 56;
	
	// there are 10 slots of memory for every enemy
    // Verify if alien has moved mininum number of steps in the current direction
	if (dirCount > ALIENSTEPS) {
		direction = readMemoryInt(0x57C9) % 80; // it has, so can go any direction but UP
		if (direction < 10) newdirection = 1;
			else if (direction < 20 ) newdirection = 2;
			else if (direction < 30) newdirection = 3;
			else if (direction < 40) newdirection = 4;
			else if (direction < 50) newdirection = 5;
			else if (direction < 60) newdirection = 6;
			else if (direction < 70) newdirection = 7;
			else newdirection = 0;
		// Changes the direction of the alien
		writeMemory(baseAddress + 2 + tgtInd, newdirection);
		// Set direction counter to zero
		dirCount = 0;
	} else {
			newdirection = readMemory(baseAddress + 2 + tgtInd);
			dirCount++;
	}

	// Reset direction counter
	writeMemory(baseAddress + 3 + tgtInd, dirCount);

	// Move alien
	switch (newdirection) {
		// Up
		case 0:
			if (ty >  top) {
				cursorxy(tx, ty + 1);
				putchar(' ');
				putchar(' ');
                putchar(' ');
                putchar(' ');
				ty--;
				writeMemory(baseAddress + 1 + tgtInd, ty);
				drawTarget(tgtInd, tx, ty);
			}
			break;
		// Up and right
		case 1:
			if (ty > top && tx < rightBorder - 3) {
				cursorxy(tx, ty);
				putchar(' ');
                cursorxy(tx, ty + 1);
				putchar(' ');
				putchar(' ');
                putchar(' ');
                putchar(' ');
                ty--;
				tx++;
				writeMemory(baseAddress + tgtInd, tx);
				writeMemory(baseAddress + 1 + tgtInd, ty);
				drawTarget(tgtInd, tx, ty);
			}
			break;
			// Right
		case 2:
			if (tx < rightBorder - 3) {
				cursorxy(tx, ty);
				putchar(' ');
				cursorxy(tx, ty + 1);
				putchar(' ');
				tx++;
				writeMemory(baseAddress + tgtInd, tx);
				drawTarget(tgtInd, tx, ty);
			}
			break;
			// Down and right
		case 3:
			if (ty < bottom - 3 && tx < rightBorder - 3) {
				cursorxy(tx, ty);
				putchar(' ');
				putchar(' ');
                putchar(' ');
                putchar(' ');
                cursorxy(tx, ty + 1);
				putchar(' ');
				ty++;
				tx++;
				writeMemory(baseAddress + tgtInd, tx);
				writeMemory(baseAddress + 1 + tgtInd, ty);
				drawTarget(tgtInd, tx, ty);
			}
			break;
			// Down
		case 4:
			if (ty < bottom - 3) {
				cursorxy(tx, ty);
				putchar(' ');
				putchar(' ');
                putchar(' ');
                putchar(' ');
                ty++;
				writeMemory(baseAddress + 1 + tgtInd, ty);
				drawTarget(tgtInd, tx, ty);
			}
			break;
			// down and left
		case 5:
			if (ty < bottom - 3 && tx > leftBorder) {
				cursorxy(tx, ty);
				putchar(' ');
				putchar(' ');
                putchar(' ');
                putchar(' ');
				cursorxy(tx + 3, ty + 1);
				putchar(' ');
				ty++;
				tx--;
				writeMemory(baseAddress + tgtInd, tx);
				writeMemory(baseAddress + 1 + tgtInd, ty);
				drawTarget(tgtInd, tx, ty);
			}
			break;			
			// Left
		case 6:
			if (tx > leftBorder) {
				cursorxy(tx + 3, ty);
				putchar(' ');
				cursorxy(tx + 3, ty + 1);
				putchar(' ');
				tx--;
				writeMemory(baseAddress + tgtInd, tx);
				drawTarget(tgtInd, tx, ty);
			}
			break;	
			// Up and left
		case 7:
			if (ty > top && tx > leftBorder) {
				cursorxy(tx + 3, ty);
				putchar(' ');
				cursorxy(tx, ty + 1);
				putchar(' ');
				putchar(' ');
                putchar(' ');
                putchar(' ');
                ty--;
				tx--;
				writeMemory(baseAddress + tgtInd, tx);
				writeMemory(baseAddress + 1 + tgtInd, ty);
				drawTarget(tgtInd, tx, ty);
			}
			break;				
		default:
			break;
	}
	
	// verify if herofire has reached this alien and make ti dead
	if (dety <= ty) {
		writeMemory(baseAddress + tgtInd + 7, 0);	// this alien will not move anymore
		cursorxy(tx, ty + 2);
		//printf("Buuuummmmmm");
	}
	
}

void initALienFire(unsigned int baseAddress, unsigned char alienNumber) {
    //int baseAddress = 0x6000;		// game variables are store in the start of RAM
    short int index;
    index = alienNumber * 10;
    writeMemory(baseAddress + index + 4, 'y');		//fire triggered
    writeMemoryInt(baseAddress + index + 5, readMemoryInt(baseAddress + index)); // x,y of bullet ? x,y of alien
}

unsigned char moveAlienBullet(unsigned int baseAddress, unsigned char alienNumber, short int herox, short int heroy) {
	short int x,y;
	unsigned char hitHero = 0;
	// int baseAddress = 0x6000;		// game variables are store in the start of RAM
	unsigned char index = alienNumber * 10;
	
	// check if this alien has fired a bullet, if not end action
	if (readMemory(baseAddress + index + 4) == 'y') {
		
		x = readMemory(baseAddress + index + 5);	// current X position of bullet
		y = readMemory(baseAddress + index + 6);	// current Y position of bullet
		
		if (y + 1 < readMemory(0x57CB) - 3) {               // reached last line of video??
			// herox contains left edge coordinates
			// heroy contains upper edge of coordinates

			// Move bullet one line down
			cursorxy(x, y);
			putchar(' ');
			y++;
			cursorxy(x, y);
			putchar('v');
			// save new Y position of bullet
			writeMemory(baseAddress + index + 6, y);

			// check if bullet hit Hero
			if (y - 1 == heroy && (x == herox || x == herox + 1)) {
				cursorxy(x, y);
				//printf("Buuum!!!");
				hitHero = 1;
			}
		} else {
					// bullet reached last line of video, and its life has ended
					writeMemory(baseAddress + index + 4, 'n');
					cursorxy(x, y);
					putchar(' ');
				}

	} else {
			// check if it is time for this alien to fire and initialize fire
				if (readMemoryInt(0x57C9) > 100 && readMemory(baseAddress + index + 7) == 1) {
					initALienFire(baseAddress, alienNumber);
				}
			}
		
	return hitHero;
}


void initGameVariables(unsigned int baseAddress, short int enemiesQtd) {
	/*
	 Memory allocation for targets: 10 slots for every alien
	 baseAddress     : x position (0 to 79)
	 baseAddress + 1 : y position (2 to 59)
	 baseAddress + 2 : direction -> from 0 to 7, 0=north, 4 south, 7 nothwest
	 baseAddress + 3 : counter for the current direction
	 baseAddress + 4 : bullet fired 'y' / 'n'
	 baseAddress + 5 : bullet x position (when target has fired)
	 baseAddress + 6 : bullet y position (when target has fired)
	 baseAddress + 7 : 0=alien is dead, 1=alien is alive
	 baseAddress + 6 t0 9: reserved
	 */
	// int baseAddress = 0x6000;		// game variables are store in the start of RAM
	unsigned char i;
	unsigned char index;
	for (i = 0; i < enemiesQtd; i++) {
		index = i * 10;				// each alien will have 10 slots for variables
		writeMemory(baseAddress + index, 39);
		writeMemory(baseAddress + index + 1, 25);
		writeMemory(baseAddress + index + 2, i);
		writeMemory(baseAddress + index + 3, 0);
		writeMemory(baseAddress + index + 7, 1);
	}
}

void blownEverthing(unsigned char dety) {
	unsigned char i;
	cursorxy(0, dety);
	for (i=0; i<80; i++) {
		putchar(' ');
	}
	cursorxy(0, dety - 1);
	printf("BLOW-UP-SUCKERS-BLOW-UP-SUCKERS-BLOW-UP-SUCKERS-BLOW-UP-SUCKERS-BLOW-UP-SUCKERS-");
}

void game_over(void) {
	cursorxy(0, 20);
	printf("CONGRATULATIONS");
	printf("All alien invasors were anihilated!\n");
	printf("Reset system to exterminate more enemies\n(Using DipSwitch 9)");
}

void main (void) {
	unsigned int baseAddress = readMemoryInt(0x57D8) + 0x1000;
    unsigned char enemiesQtd = ALIENQTD;
	short int herox = 39;
	short int heroy = 56;
	int points = 0;
    unsigned char lives = LIVES;
	unsigned char shot;
	unsigned char i;
	unsigned char detonator, dety;
    unsigned char platform = readMemory(0x57DF);
    
	dety = 50;				// this will prevent aliens from exploding before it is their time
	detonator = 0;
	cls();
	defineSprites();
	gameTitle();
	initGameVariables(baseAddress, enemiesQtd);
	// main loop
	drawHero(herox);
	// Check if Board is Spartan 3E/DE2, and display game title on LCD
	if (platform == 1 || platform == 2) {
		printlcd(0, " Zombie  Aliens ");
		printlcd(16, "by Ronivon Costa");
	}
	while (1) {
		for (i = 1; i <= enemiesQtd; i++) {
			drawScore(points, lives);
			if (readMemory(baseAddress + ((i - 1) * 10) + 7) == 1) {
				moveAlien(baseAddress, i, dety);
			}
			if (moveAlienBullet(baseAddress, i, herox, heroy) == 1) {
				lives--;
			}

			herox = moveHero(herox,heroy);
			shot = heroFire();
			if (shot == 1) {
				points++;
			}

			// dip switches and red leds are both available for DE1 and S3E
			if (dipSwitchA() > 0) {
				greenLeds(0xFF);
				// Check if hardware is DE1 and drive something to hex display and green leds
				if (platform == 1 || platform == 2) {
					hexmsb0(0x66);
					hexlsb0(0x66);
					redLedsA(0xFF);
				}
			} else { 
						greenLeds(0x00); 
						// Check if hardware is DE1 and drive something to hex display and green leds
						if (platform == 1 || platform == 2) {
							hexmsb1(0x99);
							hexlsb1(0x99);
							redLedsA(0x00);
						}
					
					}
		} // for
		
		// delay only after processing all elements of game
		//delay(GAMEDELAY * dipSwitchA() * 100);
		
		if (dipSwitchA() == 64 && detonator == 0) {
			detonator = 1;
			dety = heroy - 1;
		}

		
		if (detonator > 0) {
			blownEverthing(dety);
			dety--;
			if (dety < 4) {
				game_over();
				while (1) {};
			}
		}
		
	} // while
	
}

