= Computer Design Principles and Programming =

Have you ever imagined how complex is a computer, and how the various internal and external components interact with each other to ultimately be considered a helpful tool, something that helps us in our daily tasks or providing us with some fun playing games for example?
Learning the basic principles of engineering for computers that were used in the 70s and 80s to create our now beloved 8-bit machines is not that complicated , and this is the challenge that I propose to all those curious  souls who wants to understand how to make a computer, from the architectural decisions such as RAM size and resolution video to a proper memory mapping layout and peripheral control using ports or memory addresses, through the BIOS design and its programming in assembly language and C, to the development of a complete software such as a game that explore the resources implemented in the hardware.
Interested? So let's lay down the objectives for this series of articles , and even more importantly, what is not part of the objectives.


== Objectives ==

* An educational project that aims to study the anatomy of a computer, understand its operation and how the different parts interact;
* How to design a computer in every detail, from the architecture, specification of its resources, implementation using VHDL, BIOS development;
* Use of FPGA Developments Kits, use of VHDL as the hardware description language to implement the computer in the FPGA , and use of C and Assembly languages to develop the BIOS and software;
* Learn how ot use the most popular FPGA development kits FPGA by the community: Terasic DE1, DE2 Terasic, Xilinx Spartan 3E.



Not covered :
* This project is not a step by step guide on how to make a MSX, Spectrum, TRS- 80, or (your favorite computer here). If that is what you want, please refer to the references section, or run a internet search. There are plenty of projects ready to use and to run games if that is your purpose;
* We will not be designing printed circuit boards, soldering wires ro components. All components we need will be implemented using VHDL and upload to a FPGA development kit;
* We will not create a general purpose computer to use at home - the result of this project will be an 8-bit system for experimentation and learning. You will be able to write software or games for it, tough.



It does no matter if you can not code in assembly or C. By the end of this course, you will have acquired some basic knowledge and maybe actually learn some Z80 assembly and C.

Also it does not matter if you can not specify hardware using VHDL. At the end of this course you will have learned the basics of VHDL and should be able to read other projects and have some understanding of it, and even start doing modifications of your own in the Z80SoC.

And of course, if you don't understand how the software interacts with the hardware, how programs drive components connected to the computer, then be very welcome because this is one of the most interesting aspects of this course, since in this course it will be described and show how hardware and software interact.


Ready to Start?


Please refer to the table of contents at the top of the page to quick jump into topics, and let's start it!


= Introduction to Z80SoC =
The Z80SoC arose from a sudden interest in FPGA things, sometime in 2007. I do not remember exactly I became aware of FPGAs, but the wide range of applications won me over instantly and I literally stopped everything I was doing (excepting eating and working for a living) to dedicate myself to get more knowledge about this technology, its possibilities and how to use it. To fully explore the capabilities of FPGAs, it is required to know a language to describe the hardware you want to implement and so I got into VHDL as well..
Designing for FPGAs can be done in VHDL, Verilog and other languages, but after some research and experimentation with these two languages I chose VHDL, and that is the description language that we will use in these articles.


[[File:z80soc_rom1.png|400px]]

Z80SoC rodando ROM de demonstração

Next step was to identify the best development kits to explore all capabilities of FPGAs.

== FPGA Development Kits ==
After some research on forums, and another extensive internet search for existing projects of retro computers and consoles for FPGA development kits, I came to a conclusion that the vast majority of projects used mainly two developments kits readily available:
 

#Terasic DE1, winh an Altera FPGA;
#Xilinx Spartan 3E, with a Xilinx FPGA.

With these two kits it will be possible to implement and play with a number of different vintage computers and game consoles such as:

#Amiga
#Apple
#Atari console
#Colecovison
#TRS-80, TRS-80 Color Computer 1, 2 e 3
#Commodore 64
#MSX
#PC 8086
#ZX Spectrum
#Arcade games (Pac Man, Galaga, Defender, Space Invaders)
#… many others!

Following the research, my choice and therefore my recommendation to buy Is (by cost benefit order):

#Altera / [[http://www.terasic.com.tw/cgi-bin/page/archive.pl?Language=English&CategoryNo=53&No=83||Terasic DE1]]
#Xilinx / [[http://www.xilinx.com/support/documentation/data_sheets/ds312.pdf||Xilinx Spartan-3E]]
#Altera / [[http://www.terasic.com.tw/cgi-bin/page/archive.pl?Language=English&CategoryNo=53&No=30||Terasic DE2-70]]
#Altera / [[http://www.terasic.com.tw/cgi-bin/page/archive.pl?Language=English&CategoryNo=139&No=502||Terasic DE2-115]]

If you can buy a single kit, get (1).
If you can afford two kits, get (1) e (2).

If you have acquired already a good knowledge of VHDL to the point of being able to adapt and modify existing designs, you may consider buying kit (3) or (4). These two kits should not be the first choice for a beginner reason being they much more capacity internally and therefore are much more expensive than the  DE1 board. And being more expensive, means less people got them, reason why it will be much less common to find projects ready to use for these two kits, and consequently they will be underutilized if you do not have ability to adapt projects developed for other kits .


== Z80SoC Features ==
The Z80SoC is a system allows text mode 80 x 40 (80 columns and 40 lines of text), and pseudo graphics since the character table may be rewritten after the boot (the bits that compose each character is copied from ROM for CHARRAM, which is a RAM and therefore can be written). You can be write to video using memory addresses or I/O ports.
It is possible to write on the LCD display in the Spartan 3E and Altera DE2 in the same we write into the Video Memory or RAM, and the characters will be displayed instantaneously. The Spartan 3E implementation also allows to read the state of the knob, and in the Terasic DE1 and DE2 it is possible to write to the 7-segment displays. All these operations are performed writing into memory addresses or I/O ports as previously mentioned, and via programs developed in assembly or C.
I was developed a basic library of functions using SDCC to program in C for Z80SoC, allowing to drive and read signals from the computer peripherals, such as LEDs, LCD, memory, keyboard, etc.
The system was create using “parts” from the opensource community. The opensource community can be seen as a parts provider for such systems, since we can search, find and use those freely available components to build systems such as the Z80SoC. These “parts” are known as “core”, and there are cores available for the various components of a computer, such as ram controller, serial controller, VGA controller and so on.
The cores used in the Z80SoC are listed in the following table.



{| class="wikitable"
|+FPGA core in the Z80SoC

|CPU Z80
|T80 from opencores.org[http://opencores.com/project,t80]
|-
|VGA Controller
|From book “Rapid Prototyping of Digital Systems“[http://users.ece.gatech.edu/~hamblen/book/book4e.htm]
|-
|Keyboard controller
|Adapted from unknown source
|-
|LCD Controller
|Adapter from core from Rahul Vora, New Mexico University
|-
|7SEg Display controller
|Developed for Z80SoC
|-
|Rotary button
|Adapted from Xilinx Spartan-3E reference core
|-
|LED, Switches and Push Button controllers
|Developed for Z80SoC
|-
|SRAM controller
|Developed for Z80SoC
|-
|CHARRAM memory controller
|Developed for Z80SoC
|-
|ROM memory controller
|Developed for Z80SoC
|-
|BIOS and software
|Developed for Z80SoC
|}

= Z8SoC Architecture =

'''Nota:''' Architecture diagram will be inserted here briefly.

Avoid Trouble: From now on, we may refer to the different FPGA kits as “platform”.

Before start building a computer, we need to define what resources we need on it. This is a very simplistic definition of the computer architecture or computer design and specification.
In this initial phase, we must take into consideration things we need or things we would like to have on the computer, such as:
* what microprocessor to use
* main memory and its layout
* text-mode resolution
* graphics resolution
* number of colors
* sound, number of channels available
* external peripherals (keyboard, mouse, monitor output, disk system, K7)

Once defined the required resources, we must consider the viability of our design. For the Z80SoC we have to think in terms of FPGA capacity, and component development in VHDL. Note that if we can't find a core that fulfill our needs, than we need to develop the component ourselves.
The steps to define the specification of the Z80SoC for each development kit – the architectural decisions - will bi discussed within the section dedicated to each component. But its worth to mention now that the kits we will be working with has different specifications, directly driving the capabilities or limitations of our computer. Nevertherless and despite the development kit you might have, it will be a fun and challenging journey.

== Memory Mapping ==


As an overview of the difference between the FPGA kits and the resulting impact in our computer, we have for example a difference in RAM size for DE1/DE2 (40KB) an the Spartan-3E (only 12KB). This happens because even though the three kits has SDRAM available, we will not be using it due to the complexity to implement a controller. We are left with the possibility to use the Terasic DE1/DE2 SRAM, or the Spartan-3E BlockRAM (since the S3E don't have SRAM). But since BlockRAM is a very limited resource, the S3E can't have the same 40KB of RAM as the DE1/DE2 kits.
This was only an example of the restrictions and limitations we must overcome to accomplish a satisfactory design. Other challenges will appear during the course and we will discuss in details each case.

=== Terasic DE1 ===
 +-------------------+ 0000h 
 |                   | 
 |       ROM         | 
 |      16 KB        | 
 |                   | 3FFFh 
 +-------------------+ 4000h 
 |    VIDEO RAM      | 
 |   4800 Bytes      | 52BFh
 +-------------------+ 52C0h 
 |      System       | 
 |     Variables     | 57FFh
 +-------------------+ 5800h 
 |        | 
 |       table       | 
 |     (charram)     | 5FFFh
 +-------------------+ 6000h 
 |                   | 
 |       RAM         | 
 |                   | 
 |      40 KB        | 
 |                   | 
 |                   | 
 +-------------------+ FFFFh

=== Terasic DE2 ===
 +-------------------+ 0000h 
 |                   | 
 |       ROM         | 
 |      16 KB        | 
 |                   | 3FFFh 
 +-------------------+ 4000h 
 |    VIDEO RAM      | 
 |   4800 Bytes      | 52BFh
 +-------------------+ 52C0h 
 |      System       | 
 |     Variables     | 57DFh
 +-------------------+ 57E0h 
 |   LCD VIDEO RAM   | 
 |      2 X 16       | 57FFh
 +-------------------+ 5800h 
 |     Characters    | 
 |       table       | 
 |     (charram)     | 5FFFh
 +-------------------+ 6000h 
 |                   | 
 |       RAM         | 
 |                   | 
 |      40 KB        | 
 |                   | 
 |                   | 
 +-------------------+ FFFFh

=== Spartan-3E ===
 +-------------------+ 0000h 
 |                   | 
 |       ROM         | 
 |      16 KB        | 
 |                   | 3FFFh 
 +-------------------+ 4000h 
 |    VIDEO RAM      | 
 |   4800 Bytes      | 52BFh
 +-------------------+ 52C0h 
 |      System       | 
 |     Variables     | 57DFh
 +-------------------+ 57E0h 
 |   LCD VIDEO RAM   | 
 |      2 X 16       | 57FFh
 +-------------------+ 5800h 
 |     Characteres   | 
 |       table       | 
 |     (charram)     | 5FFFh
 +-------------------+ 6000h 
 |                   | 
 |       RAM         | 
 |                   | 
 |      12 KB        | 
 |                   | 
 |                   | 
 +-------------------+ 8FFFh

== Portas de E/S ==
External peripheral control will be implemented using the micro processor I/O ports. Whenever possible, the I/O ports will have the same address and function across all platforms. Some platforms will implement more or less I/O ports following the availability or absence of resources.

{| class="wikitable"
|-
! scope="col"| Port
! scope="col"| In/Out
! scope="col"| Resource
! scope="col"| Platform
|-
|+ I/O port in the CPU
|01H	 || Out || Green Leds (7-0) || DE1 / DE2 / S3E
|-
|02H || Out || Red Leds (7-0)  || DE1 / DE2
|-
|03H || Out || Red Leds (15-8) ||  DE2
|-
|10H || Out || HEX0 to HEX1  || DE1 / DE2
|-
|11H || Out || HEX2 to HEX3 || DE1 / DE2
|-
|12H || Out || HEX4 to HEX5 || DE2
|-
|13H || Out || HEX6 to HEX7 || DE2
|-
|15H || Out || LCD On/off || DE2 / S3E
|-
|20H || In || SW(7-0) || DE1 / DE2 / S3E*
|-
|21H || In || SW(15-8)  || DE2
|-
|30H || In || KEY(3-0) || DE1 / DE2 / S3E
|-
|80H || In || PS/2 Keyboard || DE1 / DE2 / S3E
|-
|90H || Out || Video  || DE1 / DE2 / S3E
|-
|91H || In/Out || Video cursor X || DE1 / DE2 / S3E
|-
|92H || In/Out || Video cursor Y || DE1 / DE2 / S3E
|}

(*) 4 Switches only in the Spartan-3E.

== Sysem Variables ==
System Variables, or registers, are internal attributes initialized at boot time with standard default values. Those registers has specific purposes such as to identify the platform, store the memory address where RAM starts and ends, and so on. The registers can be of type read-only or read-write.

{| class="wikitable"
|-
! scope="col"| Address
! scope="col"| R/W
! scope="col"| Description
|-
|+ System Variables
|-
| 57DFH
| R
| Platform: 0=DE1 / 1=S3E / 2=DE2
|-
| 57DEH
| R
| Last key typed
|-
| 57DCH
| R
| LCD VRAM Start Address
|-
| 57DAH
| R
| RAMTOP (Last available RAM address)
|-
| 57D8H
| R
| RAM Botton (First available RAM address)
|-
| 57D6H
| R
| CharRAM (Initial address)
|-
| 57D4H
| R
| VRAM (Initial address)
|-
| 57D2H
| R
| Stack address (Z80 stack, initially the same as RAMTOP)
|-
| 57D0H
| R/W
| VRAM address where next char will be written
|-
| 57CFH
| R/W
| Video coordinate X
|-
| 57CEH
| R/W
| Video coordinate Y
|-
| 57CDH
| R/W
| Standard output peripheral
|-
| 57CCH
| R
| Text Horizontal resolution (number of columns)
|-
| 57CBH
| R
| Text Vertical resolution (number of lines)
|}

= Preparing the FPGA Development Environment =
We will be using Xilinx ISE and Altera Qaurtus II Web Edition, both free software.

== Download the Software ==
You should download only the software for the platform you will be using, unless you have got both Altera and Xilinx development boards, i that case download both softwares below.

 [https://wl.altera.com/download/archives/arc-index.jsp Altera Quartus II 13.0 and Service Pack 1]
 [http://www.xilinx.com/support/download/index.html/content/xilinx/en/downloadNav/design-tools.html Xilinx ISE WebPack 14.7 and Service Pack 3]

 '''Avoid trouble:''' Stick to the versions indicated above. Using a version other than the suggested will require you to adapt or perform changes in the design or de componentes generated using the Core generators. If you are inexperienced user, you will be facing unnecessary problems.

==Create the Z80SoC Project ==
* Create a directory for the project, for example Z80SoCv0.7.3
* Unzip to a directory named Z80SoCv0.7.3 such as that you will end up with this structure:
 Z80SoCv0.7.3/
 Z80SoCv0.7.3/memoryCores/
 Z80SoCv0.7.3/vhdl/
 Z80SoCv0.7.3/ROMdata/

== Steps to Build the Project and Load the Design ==
* Run the Design Software (ISE / Quartus II) and open the Z80SoC project.
* Build the project. The build process will generate the binaries files:
** Altera: a .sof file and a.pof file. 
** Xilinx: <span style="background:#FF0000">update here</span>
* Using the FPGA Programmer, upload the binary file to the FPGA..

== Steps When Changing the Design ==
Some componentes were created using a generator plugin available for both Altera and Xilinx. They should be used every time changes are required to those cores.
Whenever changes are made to the BIOS, the ROM file (ihx or mif format) must be copied to the ROMdata directory, the project should be build and upload to the FPGA.

= Coding the BIOS and Programs =
= Coding tools =
== Coding in Assembly ==
=== Z80SoC Full System Test Program in Assembly Z80 ===
== Coding in C ==
=== Z80SoC Full System Test Program in C ===

== Updating the ROM ==

= Z80SoC Hardware Description in VHDL =
== LEDs ==
== Micro Switches ==
== Push Buttons ==
== 7 Segment LED Displays ==
== ROM ==
== RAM ==
== Video RAM ==
== Video character table (CharRAM) ==
== LCD Display (Spartan 3E and Terasic DE2-115) ==
== Rotary Knob (Spartan 3E) ==
== PS2 / Keyboard ==
== VGA ==
= Conclusion =
== Future Improvements ==
=== Colors ===
=== Use of onboard FlashMemory ===
=== Use of onboard FlashMemory ===
=== SD Card access ===

