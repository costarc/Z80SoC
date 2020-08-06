;; module crt0.s for Z80SoC 0.7.3
;; ==============================
	.module crt0
       .globl	_main
	.area	_HEADER (ABS)
       .org #0
init:
	;; Stack at the top of memory
	ld	sp,(#0x57D2)
    ;; Initialise global variables
	call    gsinit
	call	_main
	jp	_exit
    
	.area _CODE
	.area _CABS

	;; Ordering of segments for the linker.
	.area	_HOME
	.area	_CODE
	.area   _GSINIT
	.area   _GSFINAL

	.area	_DATA
	.area	_BSEG
	.area   _BSS
	.area   _HEAP

	.area   _CODE
;	---------------------------------
; Function putchar
; ---------------------------------
; Z80SoC V0.7.3
_putchar_start::
_putchar::
	push	ix
			; get output device port
	ld		a,(#0x57CD)
	or		a
    jr      z,printToVideo
    dec     a
    or      a
    jr      z,printToLCD
    pop     ix
	ret     ; No more valid output peripherals available

printToLCD::
    pop     ix
    ret     ; not implemented

printToVideo::
	ld		ix,#0
	add		ix,sp
	ld		a,4 (ix)
	cp		#0x0D
	jr		z,ignoreChar
	cp		#0x0A
	ld		hl,(#0x57D0)	     ;get video address to print
	jr		z,newLine
	ld		(hl),a			     ;write char to video memory
	inc		hl
    ; these part of the code will get the video coordenates x,y
    ; and calculate the absolute VRAM address to store in 0x57D0
    ; If the cursors has reached the last line, it will not be increased,
    ; that is, cursor will stay pointing to last line.
updtcursorXY::
verifySameLine::
	ld		a,(#0x57CC)         ; get number of columns in video
	ld		b,a				
	ld		a,(#0x57CF)         ; get current video X position
	inc		a
	cp		b			        ; compare to current column
	jr		c,sameLine		    ; did not find end of line
newLine::
	ld		a,(#0x57CB)		    ; Number of video lines
	ld		b,a	
	ld		a,(#0x57CE)		    ; current video Y position
	inc		a
	cp		b
	jr		c,updtcursorY	    ; not end of video screen
	dec		a                   ; end of video screen, keep cursor at last line
updtcursorY::
	ld		(#0x57CE),a		    ; save new video Y position
    ; now need to calcualte absolute vram addres on next line
    ld      a,(#0x57CF)         ;get current X position
    ld      c,a
    xor     a
    ld      b,a
    sbc     hl,bc                ;set vram to start of same line
    ld      a,(#0x57CC)
    ld      c,a
    add     hl,bc                ;next line in the vram
	;call     _calcVAddress_start
	xor		a 
sameLine::
    ld      (#0x57D0),hl
	ld		(#0x57CF),a		    ;save new video X position
ignoreChar::
	pop		ix
	ret
_calcVAddress_start::
_calcVAddress:
;printvars.c:26: return (0x4000 + (readMemory(0x57CC) * y) + 0);
	ld		a,(#0x57CC)			; get number of columns in video
	ld		l,a
	ld		h,#0x00
	ld		a,(#0x57CE)		    ; get current video Y
	ld		c,a
	ld		b,#0x00
	call    multiply            ; call multiply routine, return value in hl
   	push    hl
    ld      hl,(#0x57D4)        ;get VRAM address
    ld      b,h
    ld      c,l
    pop     hl
	add		hl,bc			    ; calc start of new line
	ld		(#0x57D0),hl	    ; store new video address
	ret
_calcVAddress_end::

multiply::
	;; multiply hl * bc and return in hl
	ld		a,b
	or		c			; is bc zero ?
	jr		nz,mul0		; no
	ld		hl,#0x0000	; X * 0 = zero
	ret
mul0::
	ld		d,h
	ld		e,l
mul::
	dec		bc			;dec bc does not update flags
	ld		a,b
	or		c			; is bc = zero ?
	ret		z			; return HL 
	add		hl,de
	jr		mul
putchar_end::

_exit::
	jr		_exit
	.area   _GSINIT
gsinit::
			;; outdevice = 0x00 = video
	xor		a
	ld		(#0x57CD),a
	ld		a,#60                  ; screen lines
	ld		(#0x57CB),a	
	ld		a,#80                  ; columns
	ld		(#0x57CC),a
	ld		hl,(#0x57D4)           ; get VRAM address
	ld		(#0x57D0),hl           ;current video memory address to print
	xor		a
	ld		(#0x57CE),a		; video cursor y
	ld		(#0x57CF),a		; video cursos x
	.area   _GSFINAL
	ret
