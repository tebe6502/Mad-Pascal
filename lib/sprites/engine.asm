
//---------------------------------------------------------------------
// SOFTWARE SPRITES ENGINE II (CHARS MODE) v2.0 (29.10.2008)
//---------------------------------------------------------------------
// v2.1 28.03.2026

; ZAŁOŻENIA:
; - możliwość zdefiniowana liczby zestawów znakowych od 4..N zmienianych co wiersz (tablica CHARSETS) na przerwaniu DLI
; - kolory pola gry zmieniane co wiersz (przerwanie DLI) na podstawie tablic TCOLOR1, TCOLOR2, TCOLOR3
; - możliwość zdefiniowania szerokości (PLAYFIELDWIDTH) i wysokości pola gry (PLAYFIELDHEIGHT)
; - duch na pozycji X:Y = 0:0 jest poza polem gry, na pozycji 32:32 w lewym górnym narożniku pola gry
; - stała maksymalna liczba duchów = 6
; - stały maksymalny rozmiar duchów = 12x21 pixle
; - tylko jeden bufor dla pamięci obrazu, możliwe jest w nim użycie znaków 0..79
; - tylko 1 bitmapa kształtu dla 1 klatki ducha (zajmuje 64 bajty), przesuwanie bitów realizowane poprzez tablicę
; - bitmapa maski obliczana na podstawie aktualnej bitmapy kształtu poprzez tablicę (nie ma potrzeby jej przesuwać)
; - stałe wartości kodów znaków dla reprezentacji duchów rozpoczynające się od znaku 80 (first_char)
; - sprity programowe są na znakach 80..103 (bufor #0), 104..127 (bufor #1)

; ZALETY:
; - brak potrzeby rozpisania klatek kształtu i maski ducha, oszczędność pamięci
; - tylko 1 bufor obrazu, możliwość jego dowolnej modyfikacji poprzez procedurę PLAYFIELD_UPDATE

; WADY:
; - tylko 6 duchów wyrabia się w 2 ramkach na wąskim ekranie (silnik z gry BombJack obsłuży w tym czasie 11 duchów)

; 	# BUFOR #0
;	# duch0 = znak 80, 81, 82, 83
;	# duch1 = znak 84, 85, 86, 87
;	# duch2 = znak 88, 89, 90, 91
;	# duch3 = znak 92, 93, 94, 95
;	# duch4 = znak 96, 97, 98, 99
;	# duch5 = znak 100, 101, 102, 103

; 	# BUFOR #1
;	# duch0 = znak 104, 105, 106, 107
;	# duch1 = znak 108, 109, 110, 111
;	# duch2 = znak 112, 113, 114, 115
;	# duch3 = znak 116, 117, 118, 119
;	# duch4 = znak 120, 121, 122, 123
;	# duch5 = znak 124, 125, 126, 127

; każde 4 znaki muszą mieścić się w granicy strony pamięci

//---------------------------------------------------------------------

.enum	@dmactl
	blank	= %00
	narrow	= %01
	normal	= %10
	wide	= %11
	missiles= %100
	players	= %1000
	oneline	= %10000
	dma	= %100000
.ende

scr48	= @dmactl(wide|dma|players|missiles|oneline)		;screen 48b
scr40	= @dmactl(normal|dma|players|missiles|oneline)		;screen 40b
scr32	= @dmactl(narrow|dma|players|missiles|oneline)		;screen 32b


color0		= $D016
color1		= $D017
color2		= $D018
color3		= $D019
colbak		= $D01A
gtictl		= $D01B

irqen		= $D20E

portb		= $D301

dmactl		= $D400
dlptr		= $D402
chbase		= $D409
wsync		= $D40A
vcount		= $D40B
nmien		= $D40E
nmist		= $D40F

nmivec		= $FFFA

//---------------------------------------------------------------------

first_char	= 80

B0		= 0
B1		= 1


	icl 'Engine_1xBuf.hea'

	.reloc

	.public Sprite0.x, Sprite1.x, Sprite2.x, Sprite3.x, Sprite4.x, Sprite5.x
	.public Sprite0.y, Sprite1.y, Sprite2.y, Sprite3.y, Sprite4.y, Sprite5.y
	.public Sprite0.new, Sprite1.new, Sprite2.new, Sprite3.new, Sprite4.new, Sprite5.new
	.public Sprite0.bitmaps, Sprite1.bitmaps, Sprite2.bitmaps, Sprite3.bitmaps
	.public Sprite4.bitmaps, Sprite5.bitmaps

	.public Charsets, tColor1, tColor2, tColor3


//---------------------------------------------------------------------

.struct	@zp

	old0B0		.word
	old1B0		.word
	old2B0		.word
	old3B0		.word
	old4B0		.word
	old5B0		.word

	old0B1		.word
	old1B1		.word
	old2B1		.word
	old3B1		.word
	old4B1		.word
	old5B1		.word

	hlp0		.word
	hlp1		.word
	hlp2		.word
	hlp3		.word
	hlp4		.word
	hlp5		.word
.ends

	.print '@ZP Length: ',.sizeof(@zp)

//---------------------------------------------------------------------

.struct	@Spr

	x	.byte
	y	.byte

	xOk	.byte
	yOk	.byte

	adx	.byte
	ady	.byte

	row	.byte

	bitmaps	.word		; tablica z adresami bitmap (adres = $0000 kończy taką talicę)

	index	.byte		; indeks do tablicy BITMAPS
	delay	.byte
	new	.byte
.ends

//---------------------------------------------------------------------

	jmp engine
	jmp engine.init
	jmp engine.reset

dlist	dta a(dlist0)
dlivec	dta a(DLI)

dmactls	

	ift PlayfieldWidth=40
	dta scr32
	eli PlayfieldWidth=48
	dta scr40
	els
	ert 1=1
	eif

colbaks	dta $06

.print dlist,',',dlivec,',',dmactls,',',colbaks

.macro	@DLIST
	dta d'pp',$70+$80
	dta $44+$80,a(:1)
	:PlayfieldHeight-2 dta $44+$80,a(:1+#*[PlayfieldWidth]+PlayfieldWidth)
	dta $44,a(:1+[PlayfieldHeight-1]*[PlayfieldWidth])
	dta $41,a(:2)
.endm

dlist0	@DLIST PlayfieldBuf+4*PlayfieldWidth+4, dlist0

	:3 brk		; wyrownanie do poczatku strony pamieci



	:4 brk			; minimalna liczba zestawow znakowych = 4

Charsets
	dta	>Charset0	; row #0
	dta	>Charset1	; row #1
	dta	>Charset2	; row #2
	dta	>Charset3	; row #3
	dta	>Charset0	; row #4
	dta	>Charset1	; row #5
	dta	>Charset2	; row #6
	dta	>Charset3	; row #7
	dta	>Charset0	; row #8
	dta	>Charset1	; row #9
	dta	>Charset2	; row #10
	dta	>Charset3	; row #11

	dta	>Charset0	; row #12
	dta	>Charset1	; row #13
	dta	>Charset2	; row #14
	dta	>Charset3	; row #15
	dta	>Charset0	; row #16
	dta	>Charset1	; row #17
	dta	>Charset2	; row #18
	dta	>Charset3	; row #19
	dta	>Charset0	; row #20
	dta	>Charset1	; row #21
	dta	>Charset2	; row #22
	dta	>Charset3	; row #23

	:4 brk


tColor0 :32 dta $0c	; color0

tColor1 :32 dta $00	; color1

tColor2 :32 dta $1a	; color2

tColor3 :32 dta $f6	; color3


.print tColor0,',',tColor1,',',tColor2,',',tColor3

	ert <*<>0,*

//---------------------------------------------------------------------
//---------------------------------------------------------------------

.macro	@shift
		:+256 dta :1([#<<8]>>:2)
.endm

ShiftRight2H	@shift h 2
ShiftRight2L	@shift l 2

ShiftRight4H	@shift h 4
ShiftRight4L	@shift l 4

ShiftRight6H	@shift h 6
ShiftRight6L	@shift l 6


lAdrCharset	:256 dta l([#&$7f]*8)
hAdrCharset	:256 dta h([#&$7f]*8)


tByte		.rept 256
		?p3 = #&$c0
		?p2 = #&$30
		?p1 = #&$0c
		?p0 = #&$03

		?v = #
		ift ?p3=$c0
		?v=?v&[$c0^$ff]
		eif

		ift ?p2=$30
		?v=?v&[$30^$ff]
		eif

		ift ?p1=$0c
		?v=?v&[$0c^$ff]
		eif

		ift ?p0=$03
		?v=?v&[$03^$ff]
		eif

		dta ?v
		.endr


tMask		.rept 256
		?p3 = #&$c0
		?p2 = #&$30
		?p1 = #&$0c
		?p0 = #&$03

		?v = 0
		ift ?p3<>$c0
		?v=?v|$c0
		eif

		ift ?p2<>$30
		?v=?v|$30
		eif

		ift ?p1<>$0c
		?v=?v|$0c
		eif

		ift ?p0<>$03
		?v=?v|$03
		eif

		dta ?v^$ff
		.endr


shpBuf		:256 dta $ff

CharsBackup	:256 brk


.print 'mask: ',tbyte-$100,',',tmask-$100


	ert <*<>0,*

; !!! od poczatku strony pamieci !!!

	.pages
Sprite0		@Spr
Sprite1		@Spr
Sprite2		@Spr
Sprite3		@Spr
Sprite4		@Spr
Sprite5		@Spr

.print 'sprite :',*,',',Sprite0,',',Sprite1

lAdrPlayfield	:PlayfieldHeight+8	dta l(PlayfieldBuf+#*PlayfieldWidth)
hAdrPlayfield	:PlayfieldHeight+8	dta h(PlayfieldBuf+#*PlayfieldWidth)

tLShift		dta h(ShiftRight2L, ShiftRight2L, ShiftRight4L, ShiftRight6L)
tHShift		dta h(ShiftRight2H, ShiftRight2H, ShiftRight4H, ShiftRight6H)

tOraLeft	dta %00000000
		dta %11000000
		dta %11110000
		dta %11111100

tOraRight	dta %00000000
		dta %00111111
		dta %00001111
		dta %00000011

	.endpg


//---------------------------------------------------------------------
//	E N G I N E
//---------------------------------------------------------------------

.local	Engine

	sta prc0+1	; 'Playfield_Update'
	sta prc1+1
	sty prc0+2
	sty prc1+2

//*********************************************************************
//	GŁÓWNY BLOK AKTUALIZACJI BUFORA PLAYFIELD
//*********************************************************************

buf	lda #0
	eor #1
	sta buf+1

	jne rB0

rB1	@sprite_playfield_restore B1 5		; usuwamy wszystkie duchy z pola gry
	@sprite_playfield_restore B1 4
	@sprite_playfield_restore B1 3
	@sprite_playfield_restore B1 2
	@sprite_playfield_restore B1 1
	@sprite_playfield_restore B1 0

	jmp next0

rB0	@sprite_playfield_restore B0 5
	@sprite_playfield_restore B0 4
	@sprite_playfield_restore B0 3
	@sprite_playfield_restore B0 2
	@sprite_playfield_restore B0 1
	@sprite_playfield_restore B0 0

next0	lda buf+1			; modyfikacja bufora PLAYFIELD poprzez wstawienie znaków reprezentujących duchy
	jne uB0

	?ch = first_char

uB1	@sprite_backup B1 0		; licz nową klatkę ducha na nowej pozycji X:Y
	@sprite_backup B1 1
	@sprite_backup B1 2
	@sprite_backup B1 3
	@sprite_backup B1 4
	@sprite_backup B1 5

	@sprite_restore B1 5		; skasuj klatkę ducha z nowej pozycji X:Y
	@sprite_restore B1 4
	@sprite_restore B1 3
	@sprite_restore B1 2
	@sprite_restore B1 1
	@sprite_restore B1 0

prc0	jsr $100			; procedura użytkownika aktualizaująca pole gry 'Playfield_Update'

	?ch = first_char+6*4

	@sprite_show B0 0		; pokaż poprzednią klatkę ducha na poprzedniej pozycji X:Y
	@sprite_show B0 1
	@sprite_show B0 2
	@sprite_show B0 3
	@sprite_show B0 4
	@sprite_show B0 5

	jmp next1

	?ch = first_char+6*4

uB0	@sprite_backup B0 0
	@sprite_backup B0 1
	@sprite_backup B0 2
	@sprite_backup B0 3
	@sprite_backup B0 4
	@sprite_backup B0 5

	@sprite_restore B0 5
	@sprite_restore B0 4
	@sprite_restore B0 3
	@sprite_restore B0 2
	@sprite_restore B0 1
	@sprite_restore B0 0

prc1	jsr $100			; procedura użytkownika aktualizaująca pole gry 'Playfield_Update'

	?ch = first_char

	@sprite_show B1 0
	@sprite_show B1 1
	@sprite_show B1 2
	@sprite_show B1 3
	@sprite_show B1 4
	@sprite_show B1 5

//*********************************************************************

next1	lda buf+1		; modyfikacja znaków reprezentujących duchy
	jne B0

	?ch = first_char

B1	@sprite_create B1 0
	@sprite_create B1 1
	@sprite_create B1 2
	@sprite_create B1 3
	@sprite_create B1 4
	@sprite_create B1 5

	rts

B0	@sprite_create B0 0
	@sprite_create B0 1
	@sprite_create B0 2
	@sprite_create B0 3
	@sprite_create B0 4
	@sprite_create B0 5

	rts

//---------------------------------------------------------------------

INIT
	mwa #nmi nmivec


RESET	ldy #0				; wszystkie duchy wyłączone

cl	lda #0

	sta Sprite0.x,y
	sta Sprite0.y,y
	sta Sprite0.index,y
	sta Sprite0.delay,y
	sta Sprite0.new,y

	tya
	add #.sizeof(@Spr)
	tay
	cpy #.sizeof(@Spr)*6
	bne cl

	rts
	
.endl


//---------------------------------------------------------------------
//---------------------------------------------------------------------

.macro @sprite_backup

	ldy Sprite:2.x
	beq skp

	cpy #(PlayfieldWidth-4)*4
	scc
	ldy #(PlayfieldWidth-4)*4

	lda Sprite:2.y
	cmp #(PlayfieldHeight+8)*8-32
	scc
	lda #(PlayfieldHeight+8)*8-32

	sta Sprite:2.yOk
	sty Sprite:2.xOk

	lsr @
	lsr @
	lsr @
	tax

	sta Sprite:2.row

	tya
	lsr @
	lsr @
	add lAdrPlayfield,x
	sta zp+@zp.old:2:1
	sta zp+@zp.hlp5

	lda hAdrPlayfield,x
	adc #0
	sta zp+@zp.old:2:1+1
	sta zp+@zp.hlp5+1

	ldy #?ch

	ift :1=B0
	ldx #:2*16
	els
	ldx #:2*16+128
	eif

	jsr SpriteCharsBackup
skp
	.def ?ch+=4
.endm


//---------------------------------------------------------------------
//---------------------------------------------------------------------


.macro	@sprite_create

	lda Sprite:2.x
	beq skp

	ldy #?ch		// regY = znak
	ldx Sprite:2.row	// regX = numer wiersza

	ift :1=B0		// regA = bufor znaków
	lda #:2*16
	els
	lda #:2*16+128
	eif

	jsr SpriteChars

	ldx <Sprite:2

	jsr MoveShape2Buf
skp
	.def ?ch+=4
.endm


//---------------------------------------------------------------------
//---------------------------------------------------------------------

.macro	@sprite_playfield_restore

	lda Sprite:2.x
	beq skp

	lda Sprite:2.new
	beq ok

	lda #0
	sta Sprite:2.new
	beq skp

ok	lda zp+@zp.old:2:1
	ldy zp+@zp.old:2:1+1

	ift :1=B0
	ldx #:2*16
	els
	ldx #:2*16+128
	eif

	jsr SpriteRestore
skp
.endm


.macro	@sprite_restore

	lda Sprite:2.x
	beq skp

	lda zp+@zp.old:2:1
	ldy zp+@zp.old:2:1+1

	ift :1=B0
	ldx #:2*16
	els
	ldx #:2*16+128
	eif

	jsr SpriteRestore
skp
.endm


//---------------------------------------------------------------------
//---------------------------------------------------------------------

.macro	@sprite_show

	lda Sprite:2.x
	beq skp

	sec
	and #3
	ora Sprite:2.adx
	seq
	clc

	lda zp+@zp.old:2:1
	ldx zp+@zp.old:2:1+1

	ldy #?ch

	jsr SpriteShow
skp
	.def ?ch+=4
.endm

//---------------------------------------------------------------------
//---------------------------------------------------------------------

	icl 'MoveShape2Buf.asm'
	icl 'SpriteChars.asm'
	icl 'SpriteCharsBackup.asm'
	icl 'SpriteRestore.asm'
	icl 'SpriteShow.asm'

//---------------------------------------------------------------------
//---------------------------------------------------------------------

.print 'dli: ',*

.local	DLI

	.rept PlayfieldHeight,#,#+1
DLI:1	sta zp+36		; DLI
	stx zp+37
	;sty zp+38

	lda Charsets+:1
	ldx tColor0+:1
	sta wsync

	sta chbase
	stx color0

	lda tColor1+:1
	sta color1

	lda tColor2+:1
	ldx tColor3+:1
	sta color2
	stx color3

	ift :1<>PlayfieldHeight-1
	
		ift (>DLI:2) <> (>DLI:1)
		mwa #DLI:2 NMI.dliv+1
		els
		mva <DLI:2 NMI.dliv+1
		eif

	eif
	
	lda zp+36
	ldx zp+37
	;ldy zp+38
	rti
	.endr

dli24	rti

.endl

//---------------------------------------------------------------------

.local	NMI
	bit nmist
	bpl vbl

dliv	jmp DLI

vbl	phr
	sta nmist

	mwa dlist dlptr

	mva dmactls dmactl

	mva #4 gtictl

	mva colbaks colbak

	mwa dlivec dliv+1

	plr
	rti
.endl

//---------------------------------------------------------------------

.print *
