
	opt l-

/*
	CMC		RAM / ROM
	CMCPLAY		RAM / ROM
	DOSFILE		RAM / ROM
	EXTMEM
	LIBRARY		PORTB -> RAM
	MPT		RAM / ROM
	MD1		RAM / ROM
	MPTPLAY		RAM / ROM
	MD1PLAY		RAM / ROM
	PP		RAM / ROM
	RCASM		RAM / ROM
	RCDATA		RAM / ROM
	RELOC		RAM
	RMT		RAM / ROM
	RMTPLAY		RAM
	RMTPLAY2	RAM / ROM
	RMTPLAYV	RAM / ROM	VinsCool Patch16-3.2
	XBMP
	SAPR		RAM / ROM
	SAPRPLAY	RAM / ROM
*/

	org CODEORIGIN

portb		= $d301
@mem_banks	= $0600

.struct	s@bmp
.word	bftype
.dword	bfsize
.word	bfreserv1
.word	bfreserv2
.dword	bfoffbits

.dword	bisize
.dword	biwidth
.dword	biheight
.word	biplanes
.word	bibitcount
.dword	bicompress
.dword	bisizeimage
.dword	biXPelsPerMeter
.dword	biYPelsPerMeter
.dword	biClrUsed
.dword	biClrImportant
.ends

.macro	m@romfont(a,b)
	ift !((%%b < $e000)||($e3ff < %%a))
	.ifndef :MAIN.@DEFINES.NOROMFONT
	.def :MAIN.@DEFINES.NOROMFONT
	.endif
	eif
.endm


	icl 'vbxe.hea'


.proc	vbxe_detect

	lda	#0
	ldx	#0xd6
	sta	0xd640			; make sure it isn't coincidence
	lda	0xd640
	cmp	#0x10			; do we have major version here?
	beq	VBXE_Detected		; if so, then VBXE is detected
	lda	#0
	inx
	sta	0xd740			; no such luck, try other location
	lda	0xd740
	cmp	#0x10
	beq	VBXE_Detected
	ldx 	#0  			; not here, so not present or FX core version too low
	stx	fxptr+1
	stx	fxptr

	sec
	rts

VBXE_Detected:
	stx	fxptr+1
	lda	#0
	sta	fxptr

;	ldy	#VBXE_MINOR		; get core minor version
;	lda	(fxptr),y

	clc	 			; x - page of vbxe
	rts
.endp


; Ullrich von Bassewitz, 2003-08-20
; Performance increase (about 20%) by
; Christian Krueger, 2009-09-13

memcpy	.proc (.word edx, ecx, eax) .var

;	cmp     edx
;	txa
;	sbc     edx+1
;	jcc     memcpy_upwards	; Branch if dest < src (upwards copy)

; Copy downwards. Adjust the pointers to the end of the memory regions.

	lda     edx+1
	add     eax+1
	sta     edx+1

	lda     ecx+1
	add     eax+1
	sta     ecx+1

; handle fractions of a page size first

	ldy     eax		; count, low byte
	bne     @entry		; something to copy?
	beq     PageSizeCopy	; here like bra...

@copyByte:
	lda     (edx),y
	sta     (ecx),y
@entry:
	dey
	bne     @copyByte
	lda     (edx),y		; copy remaining byte
	sta     (ecx),y

PageSizeCopy:			; assert Y = 0
	ldx     eax+1		; number of pages
	beq     done		; none? -> done

@initBase:
	dec     edx+1		; adjust base...
	dec     ecx+1
	dey			; in entry case: 0 -> FF
	lda     (edx),y		; need to copy this 'intro byte'
	sta     (ecx),y		; to 'land' later on Y=0! (as a result of the '.repeat'-block!)
	dey			; FF ->FE
@copyBytes:
	.rept 2			; Unroll this a bit to make it faster...
	lda     (edx),y
	sta     (ecx),y
	dey
	.endr
@copyEntry:			; in entry case: 0 -> FF
	bne     @copyBytes
	lda     (edx),y		; Y = 0, copy last byte
	sta     (ecx),y
	dex			; one page to copy less
	bne     @initBase	; still a page to copy?

done	rts
.endp


.proc	DetectMEM

ext_b	= $4000		;cokolwiek z zakresu $4000-$7FFF

	lda portb
	pha

	bit:rmi VCOUNT
	bit:rpl VCOUNT

;	lda #$ff
;	sta portb

	lda ext_b
	pha

	ldx #$0f	;zapamiêtanie bajtów ext (z 16 bloków po 64k)
_p0	jsr setpb
	lda ext_b
	sta bsav,x
	dex
	bpl _p0

	ldx #$0f	;wyzerowanie ich (w oddzielnej pêtli, bo nie wiadomo
_p1	jsr setpb	;które kombinacje bitów PORTB wybieraj¹ te same banki)
	lda #$00
	sta ext_b
	dex
	bpl _p1

	stx portb	;eliminacja pamiêci podstawowej
	stx ext_b
	stx $00		;niezbêdne dla niektórych rozszerzeñ do 256k

	ldy #$00	;pêtla zliczaj¹ca bloki 64k
	ldx #$0f
_p2	jsr setpb
	lda ext_b	;jeœli ext_b jest ró¿ne od zera, blok 64k ju¿ zliczony
	bne _n2

	dec ext_b	;w przeciwnym wypadku zaznacz jako zliczony

	lda ext_b	;sprawdz, czy sie zaznaczyl; jesli nie -> cos nie tak ze sprzetem
	bpl _n2

	lda portb	;wpisz wartoœæ PORTB do tablicy dla banku 0
	sta @mem_banks,y
	eor #%00000100	;uzupe³nij wartoœci dla banków 1, 2, 3
	sta @mem_banks+1,y
	eor #%00001100
	sta @mem_banks+2,y
	eor #%00000100
	sta @mem_banks+3,y
	iny
	iny
	iny
	iny

_n2	dex
	bpl _p2

	ldx #$0f	;przywrócenie zawartoœci ext
_p3	jsr setpb
	lda bsav,x
	sta ext_b
	dex
	bpl _p3

	stx portb	;X=$FF

	pla
	sta ext_b

	pla
	sta portb

	sty bank
	rts

; podprogramy
setpb	txa		;zmiana kolejnoœci bitów: %0000dcba -> %cba000d0
	lsr
	ror
	ror
	ror
	adc #$01	;ustawienie bitu nr 1 w zaleznosci od stanu C
	ora #$01	;ustawienie bitu steruj¹cego OS ROM na wartosc domyslna
	sta portb
	rts

bsav	:16 brk

bank	brk

.endp


.proc	@print(.word ya) .reg

iccmd    = $0342
icbufa   = $0344
icbufl   = $0348
jciomain = $e456

maxlen	 = $ff

	ldx #$00
;	lda <txt
	sta icbufa,x
;	lda >txt
	tya
	sta icbufa+1,x

	mwa	#maxlen	icbufl,x

	mva	#$09	iccmd,x

	jmp jciomain
.endp


.proc	sys

off	lda portb
	tay
	and #1
	beq exit

	sty pb

	lda #{nop}
	sta on

	lda:rne vcount

	sei
	inc nmien
	mva #$fe portb

	rts

exit	lda #{rts}
	sta on

on	nop

	lda:rne vcount

	lda #$ff
pb	equ *-1
	sta portb
	dec nmien
	cli

	rts
.endp


RESORIGIN	= *


/* ----------------------------------------------------------------------- */
/* CMCPLAY
/* ----------------------------------------------------------------------- */

.macro	CMCPLAY (nam, lab)

	org RESORIGIN

len = .sizeof(_%%2)

mcpy	ift (main.%%lab < $bc20)&&(main.%%lab+len >= $bc20)
	mva #0 sdmctl
	sta dmactl
	eif

	jsr sys.off

	memcpy #data #main.%%lab #len

	jmp sys.on
data

.local	_%%2, main.%%lab

	.link 'atari\players\cmc_player_reloc.obx'

.endl
	ini mcpy

	m@romfont main.%%lab, main.%%lab+len-1

	.print '$R CMCPLAY ',main.%%lab,'..',main.%%lab+len-1,', $FC..$FF'
.endm



/* ----------------------------------------------------------------------- */
/* MD1PLAY
/* ----------------------------------------------------------------------- */

.macro	MD1PLAY (nam, lab)

	org RESORIGIN

len = .sizeof(_%%2)

mcpy	ift (main.%%lab < $bc20)&&(main.%%lab+len >= $bc20)
	mva #0 sdmctl
	sta dmactl
	eif

	jsr sys.off

	memcpy #data #main.%%lab #len

	jmp sys.on
data

.local	_%%2, main.%%lab

	.link 'atari\players\md1_player_reloc.obx'

.endl
	ini mcpy

	m@romfont main.%%lab, main.%%lab+len-1

	.print '$R MD1PLAY ',main.%%lab,'..',main.%%lab+len-1,', $EC..$FF'
.endm


/* ----------------------------------------------------------------------- */
/* MPTPLAY
/* ----------------------------------------------------------------------- */

.macro	MPTPLAY (nam, lab)

	org RESORIGIN

len = .sizeof(_%%2)

mcpy	ift (main.%%lab < $bc20)&&(main.%%lab+len >= $bc20)
	mva #0 sdmctl
	sta dmactl
	eif

	jsr sys.off

	memcpy #data #main.%%lab #len

	jmp sys.on
data

.local	_%%2, main.%%lab

	.link 'atari\players\mpt_player_reloc.obx'

.endl
	ini mcpy

	m@romfont main.%%lab, main.%%lab+len-1

	.print '$R MPTPLAY ',main.%%lab,'..',main.%%lab+len-1,', $F0..$FB'
.endm


/* ----------------------------------------------------------------------- */
/* SAPRPLAY (SAP-R LZSS PLAYER)
/* ----------------------------------------------------------------------- */

.macro	SAPRPLAY (nam, lab)

	org RESORIGIN

len	= .sizeof(_%%2)

	ert <main.%%lab <> 0,'SAP-R LZSS PLAYER must start from the beginning of the memory page'	                                        

mcpy	ift (main.%%lab<$bc20) && (main.%%lab+len >= $bc20)
	mva #0 sdmctl
	sta dmactl
	eif

	jsr sys.off

	memcpy #data #main.%%lab #len

	jmp sys.on
data

.local	_%%2, main.%%lab

	.link 'atari\players\playlzs16_reloc.obx'

.endl
	ini mcpy

	m@romfont main.%%lab, main.%%lab+$c00-1

	.print '$R SAPRPLAY ',main.%%lab,'..',main.%%lab+$c00-1
.endm


/* ----------------------------------------------------------------------- */
/* RMTPLAYV
/* ----------------------------------------------------------------------- */

.macro	RMTPLAYV (nam, lab, mode, zp)

	org RESORIGIN

STEREOMODE	= %%mode
PLAYER		= main.%%lab

len	= .sizeof(_%%2)

	ert <PLAYER <> 0,'RMT PLAYER must start from the beginning of the memory page'

mcpy	jsr sys.off

	memcpy #data #PLAYER #.sizeof(_%%lab)

	jmp sys.on

	ift %%zp=0
	.ZPVAR = $e0
	els
	.ZPVAR = %%zp
	eif	
data

.local	_%%lab, PLAYER
	icl 'atari\players\rmt_playerv_reloc.feat'
	
	icl 'atari\players\rmt_playerv_reloc.asm'
.endl
	ini mcpy

	m@romfont PLAYER, _%%lab+.sizeof(_%%lab)-1

	.echo '$R RMTPLAY ',_%%lab.p_tis,'..',.zpvar-1,', ',PLAYER,'..',_%%lab+.sizeof(_%%lab)-1 //," %%nam"
.endm


/* ----------------------------------------------------------------------- */
/* RMTPLAY2
/* ----------------------------------------------------------------------- */

.macro	RMTPLAY2 (nam, lab, mode, zp)

	org RESORIGIN

STEREOMODE	= %%mode
PLAYER		= main.%%lab

len	= .sizeof(_%%2)

	ert <PLAYER <> 0,'RMT PLAYER must start from the beginning of the memory page'

mcpy	jsr sys.off

	memcpy #data #PLAYER #.sizeof(_%%lab)

	jmp sys.on

	ift %%zp=0
	.ZPVAR = $e0
	els
	.ZPVAR = %%zp
	eif	
data

.local	_%%lab, PLAYER
	icl %%1
	
	icl 'atari\players\rmt_player_reloc.asm'
.endl
	ini mcpy

	m@romfont PLAYER, _%%lab+.sizeof(_%%lab)-1

	.echo '$R RMTPLAY ',_%%lab.p_tis,'..',.zpvar-1,', ',PLAYER,'..',_%%lab+.sizeof(_%%lab)-1," %%nam"
.endm


/* ----------------------------------------------------------------------- */
/* RMTPLAY
/* ----------------------------------------------------------------------- */

.macro	RMTPLAY (nam, lab, mode, zp)

STEREOMODE	= %%mode
PLAYER		= main.%%lab

	ift %%zp=0
	org $e0
	els
	org %%zp
	eif	

	ert <PLAYER <> 0,'RMT PLAYER must start from the beginning of the memory page'

	icl 'atari\players\rmt_player.asm'

	icl %%1

	ert *>=$c000,'player address >= $c000, use RMTPLAY2'

	.echo '$R RMTPLAY ',p_tis,'..',zp_end-1,', ',track_variables,'..',RMTPLAYEREND-1," %%nam"
	
	ert (track_variables > CODEORIGIN) && (track_variables < PROGRAMSTACK), 'Memory overlap'

	ert (RMTPLAYEREND > CODEORIGIN) && (RMTPLAYEREND < PROGRAMSTACK), 'Memory overlap'
.endm


/* ----------------------------------------------------------------------- */
/* RCASM
/* ----------------------------------------------------------------------- */

.macro	RCASM (nam, lab)

	org RESORIGIN

len = .sizeof(_%%2)

mcpy	ift main.%%lab+len >= $bc20
	mva #0 sdmctl
	sta dmactl
	eif

	jsr sys.off

	memcpy #data #main.%%lab #len

	jmp sys.on
data

.local	_%%2, main.%%lab

	icl %%1

.endl
	ini mcpy

	.print '$R RCASM   ',main.%%lab,'..',main.%%lab+len-1," %%1"
.endm


/* ----------------------------------------------------------------------- */
/* RCDATA
/* ----------------------------------------------------------------------- */

.macro	RCDATA (nam, lab, ofs)

len = .filesize(%%1)-%%ofs

 ift main.%%lab+len >= $c000

 	ert (main.%%lab >= CODEORIGIN) && (main.%%lab < PROGRAMSTACK), 'Memory overlap'

	org RESORIGIN

mcpy	jsr sys.off

	memcpy #data #main.%%lab #len

	jmp sys.on

data	ins %%1,%%ofs

	m@romfont main.%%lab, main.%%lab+len-1

	.print '$R RCDATA  ',main.%%lab,'..',main.%%lab+len-1," %%1"

	ini mcpy
 els
	ert (main.%%lab >= CODEORIGIN) && (main.%%lab < PROGRAMSTACK), 'Memory overlap'

	org main.%%lab

	ins %%1,%%ofs

	.print '$R RCDATA  ',main.%%lab,'..',*-1," %%1"
 eif
 
.endm


/* ----------------------------------------------------------------------- */
/* DOSFILE
/* ----------------------------------------------------------------------- */

.macro	DOSFILE (nam, lab)
	.get %%1,0,6

?len = .filesize(%%1)

 ift .wget[2]+?len-6 >= $c000
 
	org RESORIGIN

_stop	jmp stop

mcpy	jsr sys.off

	mwa #data ztmp

	ldy #0			; $FFFF
	lda (ztmp),y
	cmp #$ff
	bne _stop
	iny
	lda (ztmp),y
	cmp #$ff
	bne _stop

	adw ztmp #2

loop	ldy #0
	lda (ztmp),y
	sta sadr
	iny
	lda (ztmp),y
	sta sadr+1

	iny
	lda (ztmp),y
	sta eadr
	iny
	lda (ztmp),y
	sta eadr+1

	adw ztmp #4

	sbw eadr sadr len

	inw len

	memcpy ztmp sadr len

	adw ztmp len

	ldy #0
	lda (ztmp),y
	cmp #$ff
	bne skp
	iny
	lda (ztmp),y
	cmp #$ff
	bne skp

	adw ztmp #2

skp	cpw ztmp #data_end
	jne loop
stop
	jmp sys.on

sadr	.word
eadr	.word
len	.word

data	ins %%1
data_end

	m@romfont .wget[2], .wget[4]

	ini mcpy
 els
 	opt h-
	ins %%1
	opt h+

 eif
	.print '$R DOSFILE ',.wget[2],'..',.wget[4]," %%1"
.endm


/* ----------------------------------------------------------------------- */
/* RELOC
/* ----------------------------------------------------------------------- */

.macro	RELOC (nam, lab)

len = .filesize(%%1)

 ift main.%%lab+len-16 >= $c000
	ert 'Use DOSFILE'
 els
	org main.%%lab
	.link %%1

	.print '$R RELOC   ',main.%%lab,'..',*-1," %%1"
 eif
 
.endm


/* ----------------------------------------------------------------------- */
/*  RMT Relocator v1.1 (16.12.2008)
/*  Example:	rmt_relocator 'file.rmt' , new_address
/* ----------------------------------------------------------------------- */

.macro	rmt_relocator

	.get [$100] :1,0,6				// wczytujemy plik do bufora MADS'a

	ert .wget[$100] <> $FFFF , 'Bad file format'

new_add = :2						// nowy adres dla modulu RMT

old_add	= .wget[$102]					// stary adres modulu RMT

length	= .wget[$104] - old_add + 1			// dlugosc pliku RMT bez naglowka DOS'u

ofset	= new_add-old_add

	.get [old_add-6] :1

	.put[old_add-4] = .lo(new_add)			// poprawiamy nag³ówek DOS'a
	.put[old_add-3] = .hi(new_add)			// tak aby zawieral informacje o nowym

	.put[old_add-2] = .lo(new_add + length - 1)	// adresie modulu RMT
	.put[old_add-1] = .hi(new_add + length - 1)

type	= .get[old_add+3]

pinst	= .get[old_add+8] + .get[old_add+9]<<8
pltrc	= .get[old_add+10] + .get[old_add+11]<<8
phtrc	= .get[old_add+12] + .get[old_add+13]<<8
ptlst	= .get[old_add+14] + .get[old_add+15]<<8

	.put[old_add+8] = .lo(pinst+ofset)
	.put[old_add+9] = .hi(pinst+ofset)

	.put[old_add+10] = .lo(pltrc+ofset)
	.put[old_add+11] = .hi(pltrc+ofset)

	.put[old_add+12] = .lo(phtrc+ofset)
	.put[old_add+13] = .hi(phtrc+ofset)

	.put[old_add+14] = .lo(ptlst+ofset)
	.put[old_add+15] = .hi(ptlst+ofset)

//	ISTRUMENTS
	.rept (pltrc-pinst)/2
	?tmp = .get[pinst+#*2] + .get[pinst+#*2+1]<<8

	.put[pinst+#*2] = .lo(?tmp+ofset)
	.put[pinst+#*2+1] = .hi(?tmp+ofset)

	.endr

//	TRACKS
	.rept phtrc-pltrc
	?tmp = .get[pltrc+#] + .get[phtrc+#]<<8

	ift ?tmp>0
	.put[pltrc+#] = .lo(?tmp+ofset)
	.put[phtrc+#] = .hi(?tmp+ofset)
	eif

	.endr

//	TRACK LIST

	ift type='8'
	skip=8
	els
	skip=4
	eif

	.rept [(old_add+length-ptlst)/skip]+1
	ift .get[ptlst+#*skip]=$fe
	?tmp = .get[ptlst+#*skip+2] + .get[ptlst+#*skip+3]<<8
	.put[ptlst+#*skip+2] = .lo(?tmp+ofset)
	.put[ptlst+#*skip+3] = .hi(?tmp+ofset)
	eif
	.endr

	.sav [old_add] length
.endm


/* ----------------------------------------------------------------------- */
/* RMT
/* ----------------------------------------------------------------------- */

.macro	RMT (nam, lab)

len = .filesize(%%1)

 ift main.%%lab+len-6 >= $c000
	org RESORIGIN

mcpy	jsr sys.off

	memcpy #data #main.%%lab #len-6

	jmp sys.on

data	rmt_relocator %%1,main.%%lab

	m@romfont main.%%lab, main.%%lab+len-6

	ini mcpy
 els

 	ift _end >= $bc20
	org RESORIGIN
	mva #0 sdmctl
	sta dmactl
	rts
	ini RESORIGIN
	eif

	org main.%%lab

	rmt_relocator %%1,main.%%lab
_end

 eif
 	.print '$R RMT     ',main.%%lab,'..',main.%%lab+len-6," %%1"
.endm

/* ----------------------------------------------------------------------- */


/*
  MPT Relocator

  $0000..$003F	- 32 adresy brzmien (LSB/MSB), bajty $00,$00 oznaczaja ze dane brzmienie jest puste
  $0040..$00BF	- 64 adresy patternow (LSB/MSB), bajty $00,$00 oznaczaja ze dany pattern jest pusty
  $01C0..$01C3	- mlodsze bajty adresow trackow
  $01C4..$01C7	- starsze bajty adresow trackow
  $01C8..$01C8	- dlugosc patternow (wartosci - $10,$20,$30 lub $40)
  $01C9..$01C9	- tempo utworu

  Example:
		mpt_relocator 'file.mpt' , new_address
*/

.macro	mpt_relocator

	.get :1					// wczytujemy plik do bufora MADS'a

	ift (.get[0] + .get[1]<<8) <> $FFFF
	 ert 'Bad file format'
	eif

new_add	= :2					// nowy adres dla modulu MPT

old_add	= .get[2] + .get[3]<<8			// stary adres modulu MPT

length	= .get[4] + .get[5]<<8 - old_add + 1	// dlugosc pliku MPT bez naglowka DOS'u

	.put[2] = .lo(new_add)			// poprawiamy naglowek DOS'a
	.put[3] = .hi(new_add)			// tak aby zawieral informacje o nowym

	.put[4] = .lo(new_add + length - 1)	// adresie modulu MPT
	.put[5] = .hi(new_add + length - 1)

ofs	= 6

;	.def lenpat	= .get[ofs+$1c8]
;	.def speed	= .get[ofs+$1c9]

// instruments

	.rept 32

	?tmp = .get[ofs+#*2] + .get[ofs+#*2+1]<<8

	ift ?tmp <> 0
	?hlp = ?tmp - old_add + new_add

	.put[ofs+#*2]   = .lo(?hlp)
	.put[ofs+#*2+1] = .hi(?hlp)
	eif

	.endr

// patterns

	.rept 64

	?tmp = .get[ofs+$40+#*2] + .get[ofs+$40+#*2+1]<<8

	ift ?tmp <> 0
	?hlp = ?tmp - old_add + new_add

	.put[ofs+$40+#*2]   = .lo(?hlp)
	.put[ofs+$40+#*2+1] = .hi(?hlp)
	eif

	.endr

// 4 tracks

	.rept 4

	?tmp = .get[ofs+$1c0+#] + .get[ofs+$1c4+#]<<8

	ift ?tmp <> 0
	?hlp = ?tmp - old_add + new_add

	.put[ofs+$1c0+#] = .lo(?hlp)
	.put[ofs+$1c4+#] = .hi(?hlp)
	eif

	.endr

// out new file

	.sav [6] length				// zapisujemy zawartosc bufora MADS'a do pliku
.endm


/* ----------------------------------------------------------------------- */
/* MPT
/* ----------------------------------------------------------------------- */

.macro	MPT (nam, lab)

len = .filesize(%%1)

	ert main.%%lab+len-6>$FFFF,'Memory overrun ',main.%%lab+len-6

 ift main.%%lab+len-6 >= $c000
	org RESORIGIN

mcpy	jsr sys.off

	memcpy #data #main.%%lab #len-6

	jmp sys.on

data	mpt_relocator %%1,main.%%lab

	m@romfont main.%%lab, main.%%lab+len-6

	ini mcpy
 els
	org main.%%lab
	mpt_relocator %%1,main.%%lab	
 eif
	.print '$R MPT     ',main.%%lab,'..',main.%%lab+len-6," %%1"
.endm


/* ----------------------------------------------------------------------- */
/* MD1
/* ----------------------------------------------------------------------- */

.macro	MD1 (nam, lab)

len = .filesize(%%1)

	ert main.%%lab+len-6>$FFFF,'Memory overrun ',main.%%lab+len-6

 ift main.%%lab+len-6 >= $c000
	org RESORIGIN

mcpy	jsr sys.off

	memcpy #data #main.%%lab #len-6

	jmp sys.on

data	mpt_relocator %%1,main.%%lab

	m@romfont main.%%lab, main.%%lab+len-6

	ini mcpy
 els
	org main.%%lab
	mpt_relocator %%1,main.%%lab	
 eif
	.print '$R MD1     ',main.%%lab,'..',main.%%lab+len-6," %%1"
.endm


/* ----------------------------------------------------------------------- */
/* PP (Power Packer)
/* ----------------------------------------------------------------------- */

.macro	PP (nam, lab)

len = .filesize(%%1)

	ert main.%%lab+len > $FFFF,'Memory overrun ',main.%%lab+len

 ift main.%%lab+len >= $c000
	org RESORIGIN

mcpy	jsr sys.off

	memcpy #data #main.%%lab #len

	jmp sys.on

data
	.get %%1
	
unp = .get[len-2]+.get[len-3]*256

	.put[0] = <[unp-1]
	.put[1] = >[unp-1]

	.put[2] = <[len-4]
	.put[3] = >[len-4]

	.sav [0] len

	m@romfont main.%%lab, main.%%lab+len+2

	ini mcpy
 els
	org main.%%lab

	.get %%1

unp = .get[len-2]+.get[len-3]*256

	.put[0] = <[unp-1]
	.put[1] = >[unp-1]

	.put[2] = <[len-4]
	.put[3] = >[len-4]

	.sav [0] len
 eif
	.print '$R PP    ',main.%%lab,'..',main.%%lab+len+2," %%1"
.endm


/* ----------------------------------------------------------------------- */
/* SAPR (SAPR LZSS DATA)
/* ----------------------------------------------------------------------- */

.macro	SAPR (nam, lab)

len = .filesize(%%1)

	ert main.%%lab+len+2>$FFFF,'Memory overrun ',main.%%lab+len+2

 ift main.%%lab+len+2 >= $c000
	org RESORIGIN

mcpy	jsr sys.off

	memcpy #data #main.%%lab #len+2

	jmp sys.on

.def :MAIN.@RESOURCE.%%lab = main.%%lab
.def :MAIN.@RESOURCE.%%lab.end = main.%%lab+len+2

data	dta a(len)
	ins %%1

	m@romfont main.%%lab, main.%%lab+len+2

	ini mcpy
 els
	org main.%%lab

.def :MAIN.@RESOURCE.%%lab = *
	
	dta a(len)
	ins %%1
	
.def :MAIN.@RESOURCE.%%lab.end = *
	
 eif
	.print '$R SAPR    ',main.%%lab,'..',main.%%lab+len+2," %%1"
.endm


/* ----------------------------------------------------------------------- */

/*
  CMC Relocator

  Offsets in the CMC file (after the DOS header):
  $0014..$0053	- LSB of pattern address
  $0054..$0093	- MSB of pattern address

  Example:
		cmc_relocator 'file.cmc' , new_address
*/

.macro	cmc_relocator

	.get :1					// Load the CMC file into the MADS buffer

	ift (.get[0] + .get[1]<<8) <> $FFFF
	 ert 'Bad file format'
	eif

new_add equ :2					// Get the new address for the CMC module

old_add	equ .get[2] + .get[3]<<8		// Get the old addressof the CMC module

	.def ?length = .get[4] + .get[5]<<8 - old_add + 1 // Length of the CMC file without the DOS header

	.put[2] = .lo(new_add)			// Correct the DOS header
	.put[3] = .hi(new_add)			// so it contains the information

	.put[4] = .lo(new_add + ?length - 1)	// about the new CMC module address
	.put[5] = .hi(new_add + ?length - 1)

ofs	equ 6

	.rept 64				// Loop over all 64 patterns

	?tmp = .get[ofs+$14+#] + .get[ofs+$54+#]<<8

	ift ?tmp < $FF00			// High byte $ff indicates unused pattern
	?hlp = ?tmp - old_add + new_add

	.put[ofs+$14+#] = .lo(?hlp)
	.put[ofs+$54+#] = .hi(?hlp)
	.else
	.put[ofs+$14+#] = $ff			// Normalize also the low byte to $ff
	.put[ofs+$54+#] = $ff
	eif

	.endr

	.sav [6] ?length			// Save the relocated music into the current output file

.endm


/* ----------------------------------------------------------------------- */
/* CMC
/* ----------------------------------------------------------------------- */

.macro	CMC (nam, lab)

len = .filesize(%%1)

	ert main.%%lab+len-6>$FFFF,'Memory overrun ',main.%%lab+len-6

 ift main.%%lab+len-6 >= $c000
 	org RESORIGIN

mcpy	jsr sys.off

	memcpy #data #main.%%lab #len-6

	jmp sys.on

data	cmc_relocator %%1,main.%%lab

	m@romfont main.%%lab, main.%%lab+len-6

	ini mcpy
 els
	org main.%%lab
	cmc_relocator %%1,main.%%lab	
 eif
 	.print '$R CMC     ',main.%%lab,'..',main.%%lab+len-6," %%1"
.endm


/* ----------------------------------------------------------------------- */
/* XBMP
/* ----------------------------------------------------------------------- */

.macro	XBMP (nam, lab, idx, pal)

he	= .sizeof(s@bmp)

	.get %%1,0,he

	ert .wget[0]<>$4d42,'Invalid BMP header'
	ert .wget[s@bmp.bibitcount]<>8,'Only 8 BitsPerPixel'

?bw	= .dget[s@bmp.biwidth]
?bh	= .dget[s@bmp.biheight]

	ift ?bw%4<>0
	?bw=(?bw>>2)<<2+4
	eif

;	ift ?bh>192
;	?bh = 192
;	eif

	org RESORIGIN

lbmp
	ift ?VBXDETECT=0

	jsr vbxe_detect
	bcc ok

	@print #notVBXE
	@print #_eol
	@print #anyKEY
	
keypres	lda $d20f
	and #4
	bne keypres

	pla
	pla
	rts

notVBXE	dta c'VBXE not detected'
_eol	dta $9b
anyKEY	dta c'Press any key to continue',$9b

	eif

	.def ?VBXDETECT=1

ok	fxs FX_MEMC #%1000+$b0

	fxs FX_PSEL, #%%pal
	fxs FX_CSEL, #%%idx

	ldx #%%idx

paloop	jsr pal
	sta ztmp
	jsr pal
	sta ztmp+1
	jsr pal
	sta ztmp+2
	jsr pal

	lda ztmp+2
	fxsa FX_CR

	lda ztmp+1
	fxsa FX_CG

	lda ztmp
	fxsa FX_CB

	inx
	bne paloop

	rts

pal	lda cpal
paladr	equ *-2
	inw paladr
	rts

cpal	ins %%1,he,1024

	ini lbmp


ln	= .filesize(%%1)-he-1024
?bnk	= main.%%lab/$1000
?cnt	= 1

	org RESORIGIN
	fxs FX_MEMS #?bnk+$80
	rts
	ini RESORIGIN

	org main.%%lab%$1000+$B000

	.rept  [ln/?bw]+[[ln%?bw]<>0]

	.xget %%1+%%idx,-?bw*?cnt,?bw

	ift *+?bw<$c000
	.sav ?bw
	els
	?tmp = ?bw-(*+?bw)%$c000
	.sav ?tmp

	?bnk++
	org RESORIGIN
	fxs FX_MEMS #?bnk+$80
	rts
	ini RESORIGIN

	org $B000
	.sav [?tmp] ?bw-?tmp
	eif

	?cnt++
	.endr

	org RESORIGIN
	fxs FX_MEMC, #0
	fxsa FX_MEMS
	rts
	ini RESORIGIN

	.print '$R XBMP    ',main.%%lab,'..',main.%%lab+ln-1," %%1",' width: ',?bw,' height: ',?bh,' palsel: ',%%pal,' colsel: ',%%idx
.endm


/* ----------------------------------------------------------------------- */
/* EXTMEM
/* ----------------------------------------------------------------------- */

.macro	EXTMEM (nam, lab)

len = .filesize(%%1)

	ift ?EXTDETECT=0
	ini DetectMem
	eif

	.def ?EXTDETECT=1

	?adr = main.%%lab

	org RESORIGIN

	ert (*>$4000) && (*<$8000),'RESORIGIN memory overlap $4000..$7FFF'

	mwa #[?adr&$3fff]+$4000 dst
	rts

quit	mva #$ff portb
	rts


move	ldx #?adr/$4000

	cpx DetectMem.bank
	bcs nomem

	lda @mem_banks,x
	sta portb

	ldy #0

lp	lda data,y

	sta $ffff
dst	equ *-2

	inw dst

	lda dst+1
	bpl ok

	inx

	cpx DetectMem.bank
	bcs nomem

	lda @mem_banks,x
	sta portb

	mwa #$4000 dst

ok	iny
	bne lp

	rts


noMem	.local

	@print #outMem

	pla
	pla
	rts

outMem	dta c'Out of memory',$9b

	.endl

	.align
data
	ini RESORIGIN

	.rept len/256
	org data
	ins %%1,#*256,256

	org move
	ldx #?adr/$4000

	?adr += $100

	ini move
	.endr


	ift len%256<>0
	org data
	ins %%1,-(len%256)

	org move
	ldx #[?adr>>14]

	ini move
	eif

	ini quit

.endm


/* ----------------------------------------------------------------------- */
/* LIBRARY
/* ----------------------------------------------------------------------- */

.macro	LIBRARY (nam, lab)

	.get %%1,0,6

?len = .filesize(%%1)

	ert .wget[2] < $4000,'library must fit in memory space $4000..$7FFF'
	ert .wget[2]+?len-6 >= $8000,'library must fit in memory space $4000..$7FFF'


	ift ?EXTDETECT=0
	ini DetectMem
	eif

	.def ?EXTDETECT=1

	ert (main.%%lab > 63), 'memory bank number must be in the range [0..63]'

	org RESORIGIN

	ert (*>$4000) && (*<$8000),'RESORIGIN memory overlap $4000..$7FFF'

quit	mva #$ff portb
	rts

setbnk	ldx #main.%%lab

	cpx DetectMem.bank
	bcs nomem

	lda @mem_banks,x
	sta portb
	rts

noMem	.local

	@print #outMem

	pla
	pla
	rts

outMem	dta c'Out of memory',$9b

	.endl

	ini setbnk

/* ----------------------------------------------------------------------- */
/* DOSFILE
/* ----------------------------------------------------------------------- */

 	opt h-
	ins %%1
	opt h+

	.print '$R LIBRARY ',.wget[2],'..',.wget[4],':',main.%%lab," %%1"

	ini quit

.endm

	opt l+
