
	opt l-

/*
	CMC
	CMCPLAY
	DOSFILE
	EXTMEM
	MPT
	MPTPLAY
	RCASM
	RCDATA
	RELOC
	RMT
	RMTPLAY
	XBMP
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

	lda:rne vcount

;	lda #$ff
;	sta portb

	lda ext_b
	pha

	ldx #$0f	;zapamiętanie bajtów ext (z 16 bloków po 64k)
_p0	jsr setpb
	lda ext_b
	sta bsav,x
	dex
	bpl _p0

	ldx #$0f	;wyzerowanie ich (w oddzielnej pętli, bo nie wiadomo
_p1	jsr setpb	;które kombinacje bitów PORTB wybierają te same banki)
	lda #$00
	sta ext_b
	dex
	bpl _p1

	stx portb	;eliminacja pamięci podstawowej
	stx ext_b
	stx $00		;niezbędne dla niektórych rozszerzeń do 256k

	ldy #$00	;pętla zliczająca bloki 64k
	ldx #$0f
_p2	jsr setpb
	lda ext_b	;jeśli ext_b jest różne od zera, blok 64k już zliczony
	bne _n2

	dec ext_b	;w przeciwnym wypadku zaznacz jako zliczony

	lda ext_b	;sprawdz, czy sie zaznaczyl; jesli nie -> cos nie tak ze sprzetem
	bpl _n2

	lda portb	;wpisz wartość PORTB do tablicy dla banku 0
	sta @mem_banks,y
	eor #%00000100	;uzupełnij wartości dla banków 1, 2, 3
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

	ldx #$0f	;przywrócenie zawartości ext
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
setpb	txa		;zmiana kolejności bitów: %0000dcba -> %cba000d0
	lsr
	ror
	ror
	ror
	adc #$01	;ustawienie bitu nr 1 w zaleznosci od stanu C
	ora #$01	;ustawienie bitu sterującego OS ROM na wartosc domyslna
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

mcpy	ift main.%%lab+len >= $bc20
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

	.print '$R CMCPLAY ',main.%%lab,'..',main.%%lab+$0755

	ini mcpy
.endm


/* ----------------------------------------------------------------------- */
/* MPTPLAY
/* ----------------------------------------------------------------------- */

.macro	MPTPLAY (nam, lab)

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

	.link 'atari\players\mpt_player_reloc.obx'

.endl
	.print '$R MPTPLAY ',main.%%lab,'..',main.%%lab+$049e

	ini mcpy
.endm


/* ----------------------------------------------------------------------- */
/* RMTPLAY
/* ----------------------------------------------------------------------- */

.macro	RMTPLAY (nam, lab, mode)

STEREOMODE	= %%mode
PLAYER		= main.%%lab

	ert <PLAYER <> 0,'RMT player routine MUST be compiled from the begin of the memory page'

	icl 'atari\players\rmt_player.asm'

	icl %%1

	ert *>=$c000

	.echo '$R RMTPLAY ',track_variables,'..',RMTPLAYEREND," %%nam"
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
	.print '$R RCASM   ',main.%%lab,'..',main.%%lab+len-1," %%1"

	ini mcpy
.endm


/* ----------------------------------------------------------------------- */
/* RCDATA
/* ----------------------------------------------------------------------- */

.macro	RCDATA (nam, lab, ofs)

len = .filesize(%%1)-%%ofs

 ift main.%%lab+len >= $c000

 	ift main.%%lab>=CODEORIGIN && main.%%lab<PROGRAMSTACK
	ert 'Overlap memory'
	eif

	org RESORIGIN

mcpy	jsr sys.off

	memcpy #data #main.%%lab #len

	jmp sys.on

data	ins %%1,%%ofs

	.print '$R RCDATA  ',main.%%lab,'..',main.%%lab+len-1," %%1"

	ini mcpy
 els
	ift main.%%lab>=CODEORIGIN && main.%%lab<PROGRAMSTACK
	ert 'Overlap memory'
	eif

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

	.print '$R DOSFILE ',.wget[2],'..$xxxx'," %%1"

	ini mcpy
 els
 	opt h-
	ins %%1
	opt h+

	.print '$R DOSFILE ',.wget[2],'..',*-1," %%1"
 eif
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

	.put[old_add-4] = .lo(new_add)			// poprawiamy nagłówek DOS'a
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

	.print '$R RMT     ',main.%%lab,'..',main.%%lab+len-6," %%1"

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
	.print '$R RMT     ',main.%%lab,'..',main.%%lab+len-6," %%1"

 eif
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

 ift main.%%lab+len-6 >= $c000
	org RESORIGIN

mcpy	jsr sys.off

	memcpy #data #main.%%lab #len-6

	jmp sys.on

data	mpt_relocator %%1,main.%%lab

	ini mcpy
 els
	org main.%%lab
	mpt_relocator %%1,main.%%lab
	
	.print '$R MPT     ',main.%%lab,'..',main.%%lab+len-6," %%1"
 eif
.endm


/* ----------------------------------------------------------------------- */


/*
  CMC Relocator

  $0014..$0053	- LSB adresu patternu
  $0054..$0093	- MSB adresu patternu

  Example:
		cmc_relocator 'file.cmc' , new_address
*/

.macro	cmc_relocator

	.get :1					// wczytujemy plik do bufora MADS'a

	ift (.get[0] + .get[1]<<8) <> $FFFF
	 ert 'Bad file format'
	eif

new_add	= :2					// nowy adres dla modulu CMC

old_add	= .get[2] + .get[3]<<8			// stary adres modulu CMC

length	= .get[4] + .get[5]<<8 - old_add + 1	// dlugosc pliku MPT bez naglowka DOS'u

	.put[2] = .lo(new_add)			// poprawiamy naglowek DOS'a
	.put[3] = .hi(new_add)			// tak aby zawieral informacje o nowym

	.put[4] = .lo(new_add + length - 1)	// adresie modulu CMC
	.put[5] = .hi(new_add + length - 1)

ofs	equ 6

// patterns

	.rept 64

	?tmp = .get[ofs+$14+#] + .get[ofs+$54+#]<<8

	ift ?tmp <> $FFFF
	?hlp = ?tmp - old_add + new_add

	.put[ofs+$14+#] = .lo(?hlp)
	.put[ofs+$54+#] = .hi(?hlp)
	eif

	.endr

// out new file

	.sav [6] length				// zapisujemy zawartosc bufora MADS'a do pliku
.endm


/* ----------------------------------------------------------------------- */
/* CMC
/* ----------------------------------------------------------------------- */

.macro	CMC (nam, lab)

len = .filesize(%%1)

 ift main.%%lab+len-6 >= $c000
	org RESORIGIN

mcpy	jsr sys.off

	memcpy #data #main.%%lab #len-6

	jmp sys.on

data	cmc_relocator %%1,main.%%lab

	ini mcpy
 els
	org main.%%lab
	cmc_relocator %%1,main.%%lab
	
	.print '$R CMC     ',main.%%lab,'..',main.%%lab+len-6," %%1"	
 eif
.endm


/* ----------------------------------------------------------------------- */
/* XBMP
/* ----------------------------------------------------------------------- */

.macro	XBMP (nam, lab, idx)

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

	pla
	pla
	rts

notVBXE	dta c'VBXE not detected',$9b

	eif

	.def ?VBXDETECT=1

ok	fxs FX_MEMC #%1000+$b0

	fxs FX_PSEL, #1
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

	.print '$R XBMP    ',main.%%lab,'..',main.%%lab+ln-1," %%1"

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

	opt l+
