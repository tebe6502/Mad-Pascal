
/*
	@COMMAND
	@GRAPHICS
	@SCREENSIZE
*/


@open	= $03		; Otworz kanal
; $05 read line - Input
@close	= $0c		; Zamknij kanal

@IDget	= $07		; Odczytaj punkt
; $09 write line - Print
@IDput	= $0b		; Narysuj punkt
; $0c channel status - Status
@IDdraw	= $11		; Narysuj linie
@IDfill	= $12		; Wypelnij obszar


; out:	Y	status:
;			1 = OK

.proc	@COMMAND

	ldx	#$00
scrchn	equ *-1

	sta	iccmd,x

	lda	#$00		; len = 0 -> ACC
	sta	icbufl,x
	sta	icbufh,x
	
	sta	icax2,x

	lda	#$0C
	sta	icax1,x

	lda	#$00
colscr	equ *-1
	sta	atachr		; parametr dla CIOV przez ACC
	
	m@call	ciov
	
	rts
.endp



; in:	X	channel
;	Y	mode
;	A	option:
;			bit 5 - clear screen memory
;			bit 4 - E: window
;			bit 2 - read from screen

@GRAPHICS .proc (.byte x,y,a) .reg

	sta	byte1
	sty	byte2

	stx	@COMMAND.scrchn


	mva #$2c	@putchar.vbxe	; bit*
	mva #0		@putchar.chn	; #0 -> E: window

	sta	colcrs
	sta	colcrs+1
	sta	rowcrs

	lda	#@close
	jsr	xcio

	lda	#0		; =opcje
byte1	equ	*-1
	ora	#8		; +zapis na ekranie
	sta	icax1,x

	lda	#0
byte2	equ	*-1
	sta	icax2,x		;=nr.trybu

	mwa	#sname	icbufa,x

	lda	#@open

xcio	sta	iccmd,x

	m@call	ciov
	
	rts

sname	dta c'S:',$9b

	.endp



; in:	X:A	horizontal resolution
;	Y	vertical resolution

.proc	@SCREENSIZE

	sta MAIN.SYSTEM.ScreenWidth
	stx MAIN.SYSTEM.ScreenWidth+1

	sub #1
	sta MAIN.GRAPH.WIN_RIGHT
	txa
	sbc #0
	sta MAIN.GRAPH.WIN_RIGHT+1

	sty MAIN.SYSTEM.ScreenHeight
	lda #0
	sta MAIN.SYSTEM.ScreenHeight+1

	sta MAIN.GRAPH.WIN_LEFT
	sta MAIN.GRAPH.WIN_LEFT+1
	sta MAIN.GRAPH.WIN_TOP
	sta MAIN.GRAPH.WIN_TOP+1

	sta MAIN.GRAPH.WIN_BOTTOM+1	
	dey
	sty MAIN.GRAPH.WIN_BOTTOM

	rts
.endp

