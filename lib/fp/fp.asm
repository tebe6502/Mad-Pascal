
/*
   Przykladowa biblioteka wykorzystujaca pakiet matematyczny XE/XL

   _ATOFP (ascii,fp)	- zamienia ciag znakow ASCII na liczbe FP, pierwszy parametr to adres ciagu ASCII ktory bedzie
			  zamieniany na FP, drugi parametr to adres pod którym odlozona zostanie liczba FP
   			  zamieniany ciag ASCII musi byc zakonczony znakiem innym niz cyfra, np. EOL $9B

   _FPTOA (fp,ascii)	- zamienia liczbe FP na ciag znakow ASCII, pierwszy parametr to adres pod którym znajduje
			  sie liczba FP, drugi parametr to adres pod ktory odlozony zostanie ciag znaków ASCII
			  ciag ASCII bedzie zakonczony znakiem EOL $9b

   _ITOFP (int,fp)	- zamienia liczbe typu 'unsigned int' (word) na liczbe FP, pierwszym parametrem jest wartosc
			  bez znaku z zakresu 0..$FFFF, drugim parametrem jest adres pod którym zostanie zapisana
			  liczba FP

   _FPTOI (fp)		- zamienia liczbe FP na liczbe typu 'unsigned int' (word), parametrem jest adres pod
			  ktorym znajduje sie liczba FP, wynik zwracany jest przez rejestry CPU X,Y
			  X - mlodszy bajt liczby WORD
			  Y - starszy bajt liczby WORD

   _FPADD (fp0,fp1,fp2)	- FP2=FP0+FP1	suma dwóch liczb

   _FPSUB (fp0,fp1,fp2)	- FP2=FP0-FP1	róznica dwóch liczb

   _FPMUL (fp0,fp1,fp2)	- FP2=FP0*FP1	iloczyn dwóch liczb

   _FPDIV (fp0,fp1,fp2)	- FP2=FP0/FP1	iloraz dwóch liczb

   LOADFR0 (fp)		- przepisuje liczbe FP do rejestru pakietu zmiennoprzecinkowego FR0, parametrem
   			  jest adres pod ktorym znajduje sie liczba FP do przepisania

   LOADFR1 (fp)		- przepisuje liczbe FP do rejestru pakietu zmiennoprzecinkowego FR1, parametrem
   			  jest adres pod ktorym znajduje sie liczba FP do przepisania

*/


ptr0	= $D0		; temporary bytes
ptr1	= $D2		; temporary bytes

fr0	= $D4		; float reg 0
fr1	= $E0		; float reg 1

cix	= $F2		; index
inbuff	= $F3		; pointer to ascii num

flptr	= $FC		; pointer to a fp num

lbuff	= $580

zfr0	= $DA44		; fr0 = 0
fld0r	= $DD89		; (X:Y) -> fr0
fld1r	= $DD98		; (X:Y) -> fr1
fst0r	= $DDA7		; fr0 -> (X:Y)
fst0p	= $DDAB		; fr0 -> (FLPTR)

afp	= $D800		; ascii -> float
ifp	= $D9AA		; int in fr0 -> float in fr0
fpi	= $D9D2		; float in fr0 -> int in fr0
fasc	= $D8E6		; fr0 -> (inbuff)
fadd	= $DA66		; fr0 + fr1  -> fr0
fsub	= $DA60		; fr0 - fr1  -> fr0
fmul	= $DADB		; fr0 * fr1  -> fr0
fdiv	= $DB28		; fr0 / fr1  -> fr0
fexp	= $DDC0		; e ^ fr0    -> fr0
fexp10	= $DDCC		; 10 ^ fr0   -> fr0
fln	= $DECD		; ln(fr0)    -> fr0
flog10	= $DED1		; log10(fr0) -> fr0

loadfr0.adr	= ptr0
loadfr1.adr	= ptr1

	.public	loadfr1

	.reloc

;------------------------------------

_atofp.inbuff = inbuff
_atofp.flptr = flptr

	.globl _atofp, _atofp.inbuff, _atofp.flptr
;atofp(ascii,float)
_atofp	.proc	(.word inbuff, flptr) .var

	txa:pha

	inw	inbuff

	lda     #0
	sta     cix

	jsr     afp

	jsr	fst0p

	pla:tax
	rts

	.endp

;------------------------------------

_fptoa.loadfr0.adr = loadfr0.adr
_fptoa.ptr1 = ptr1

       .globl _fptoa, _fptoa.loadfr0.adr, _fptoa.ptr1
;      fptoa(float,ascii)
_fptoa	.proc	(.word loadfr0.adr, ptr1) .var

	txa:pha

	jsr	loadfr0

	lda     #0
	sta     cix

	mwa	#lbuff	inbuff	; COPY ADDRESS OF LBUFF INTO INBUFF

	jsr     fasc

	ldy     #$FF

	mwa	ptr1 len
	inw 	ptr1

loop:	iny
	lda     (inbuff),y
	sta     (ptr1),y
	bpl     loop
	and     #$7F
	sta     (ptr1),y
	iny
	tya
	sta     len: $FFFF

	pla:tax
	rts

	.endp

;------------------------------------

_itofp.fr0 = fr0
_itofp.flptr = flptr

       .globl _itofp, _itofp.fr0, _itofp.flptr
;          itofp(int,float)
_itofp	.proc	(.dword fr0 .word flptr) .var

	txa:pha

	lda fr0+3
	and #$80
	pha
	bpl plus

	lda #$00
	sub fr0
	sta fr0
	lda #$00
	sbc fr0+1
	sta fr0+1

plus	jsr     ifp

	pla
	bpl @+

	lda fr0
	ora #$80
	sta fr0

@	jsr	fst0p

	pla:tax
	rts

	.endp

;------------------------------------

_fptoi.flptr = flptr
_fptoi.result = fr0

       .globl _fptoi, _fptoi.flptr, _fptoi.result
;      int=fptoi(float)
_fptoi .proc	(.word flptr) .var

	txa:pha

	ldx flptr
	ldy flptr+1

	jsr	fld0r

	lda	fr0
	pha
	bpl	plus

	and	#$7f
	sta	fr0

plus	jsr	fpi

	pla
	and	#$80
	bpl @+

	lda #$00
	sub _fptoi.result
	sta _fptoi.result

	lda #$00
	sbc _fptoi.result+1
	sta _fptoi.result+1

	lda #$00
	sbc #$00

@	sta _fptoi.result+2
	sta _fptoi.result+3

	pla:tax
	rts

	.endp

;------------------------------------
/*
_fptoi.flptr = flptr
_fptoi.result = fr0

       .globl _fptoi, _fptoi.flptr, _fptoi.result
;      int=fptoi(float)
_fptoi	.proc	(.word flptr) .var

	txa:pha

	ldx flptr
	ldy flptr+1

	jsr	fld0r

	jsr	fpi

	pla:tax
	rts

	.endp
*/
;------------------------------------

_fpadd.loadfr0.adr = loadfr0.adr
_fpadd.loadfr1.adr = loadfr1.adr
_fpadd.flptr = flptr

       .globl _fpadd, _fpadd.loadfr0.adr, _fpadd.loadfr1.adr, _fpadd.flptr
;      fpadd(fp a,fp b,fp c)
;              a+b=c
_fpadd	.proc	(.word loadfr0.adr, loadfr1.adr, flptr) .var

	txa:pha

	jsr	loadfr0
	jsr	loadfr1

	jsr	fadd
	jsr	fst0p

	pla:tax
	rts

       .endp

;------------------------------------

_fpsub.loadfr0.adr = loadfr0.adr
_fpsub.loadfr1.adr = loadfr1.adr
_fpsub.flptr = flptr

       .globl _fpsub, _fpsub.loadfr0.adr, _fpsub.loadfr1.adr, _fpsub.flptr
;      fpsub(fp a,fp b,fp c)
;              a-b=c
_fpsub	.proc	(.word loadfr0.adr, loadfr1.adr, flptr) .var

	txa:pha

	jsr	loadfr0
	jsr	loadfr1

	jsr     fsub
	jsr	fst0p

	pla:tax
	rts

	.endp

;------------------------------------

_fpmul.loadfr0.adr = loadfr0.adr
_fpmul.loadfr1.adr = loadfr1.adr
_fpmul.flptr = flptr

       .globl _fpmul, _fpmul.loadfr0.adr, _fpmul.loadfr1.adr, _fpmul.flptr
;      fpmul(fp a,fp b,fp c)
;              a*b=c
_fpmul	.proc	(.word loadfr0.adr, loadfr1.adr, flptr) .var

	txa:pha

	jsr	loadfr0
	jsr	loadfr1

	jsr     fmul
	jsr	fst0p

	pla:tax
	rts

	.endp

;------------------------------------

_fpdiv.loadfr0.adr = loadfr0.adr
_fpdiv.loadfr1.adr = loadfr1.adr
_fpdiv.flptr = flptr

       .globl _fpdiv, _fpdiv.loadfr0.adr, _fpdiv.loadfr1.adr, _fpdiv.flptr
;      fpdiv(fp a,fp b,fp c)
;              a/b=c
_fpdiv	.proc	(.word loadfr0.adr, loadfr1.adr, flptr) .var

	txa:pha

	jsr	loadfr0
	jsr	loadfr1

	jsr     fdiv
	jsr	fst0p

	pla:tax
	rts

	.endp

;------------------------------------

_fpgt.loadfr0.adr = loadfr0.adr
_fpgt.loadfr1.adr = loadfr1.adr
_fpgt.result = flptr

       .globl _fpgt, _fpgt.loadfr0.adr, _fpgt.loadfr1.adr, _fpgt.result
;
_fpgt	.proc	(.word loadfr0.adr, loadfr1.adr) .var

	txa:pha

	jsr	_cmpvar
	bmi	false	; >
	beq	false
	bpl	true
	.endp

;------------------------------------

_fplt.loadfr0.adr = loadfr0.adr
_fplt.loadfr1.adr = loadfr1.adr
_fplt.result = flptr

       .globl _fplt, _fplt.loadfr0.adr, _fplt.loadfr1.adr, _fplt.result
;
_fplt	.proc	(.word loadfr0.adr, loadfr1.adr) .var

	txa:pha

	jsr	_cmpvar
	bmi	true	; <
	bpl	false
	.endp

;------------------------------------

_fpne.loadfr0.adr = loadfr0.adr
_fpne.loadfr1.adr = loadfr1.adr
_fpne.result = flptr

       .globl _fpne, _fpne.loadfr0.adr, _fpne.loadfr1.adr, _fpne.result
;
_fpne	.proc	(.word loadfr0.adr, loadfr1.adr) .var

	txa:pha

	jsr	_cmpvar
	beq	false	; <>
	bne	true
	.endp

;------------------------------------

_fplteq.loadfr0.adr = loadfr0.adr
_fplteq.loadfr1.adr = loadfr1.adr
_fplteq.result = flptr

       .globl _fplteq, _fplteq.loadfr0.adr, _fplteq.loadfr1.adr, _fplteq.result
;
_fplteq	.proc	(.word loadfr0.adr, loadfr1.adr) .var

	txa:pha

	jsr	_cmpvar
	bmi	true	; <=
	beq	true
	bpl	false
	.endp

;------------------------------------

_fpgteq.loadfr0.adr = loadfr0.adr
_fpgteq.loadfr1.adr = loadfr1.adr
_fpgteq.result = flptr

       .globl _fpgteq, _fpgteq.loadfr0.adr, _fpgteq.loadfr1.adr, _fpgteq.result
;
_fpgteq	.proc	(.word loadfr0.adr, loadfr1.adr) .var

	txa:pha

	jsr	_cmpvar
	bmi	false	; >=
	bpl	true
	.endp

;------------------------------------

_fpeq.loadfr0.adr = loadfr0.adr
_fpeq.loadfr1.adr = loadfr1.adr
_fpeq.result = flptr

       .globl _fpeq, _fpeq.loadfr0.adr, _fpeq.loadfr1.adr, _fpeq.result
;
_fpeq	.proc	(.word loadfr0.adr, loadfr1.adr) .var

	txa:pha

	jsr	_cmpvar
	beq	true	; =
	.endp

false	pla:tax

	lda	#0
	sta	flptr
	rts

true	pla:tax

	lda	#1
	sta	flptr
	rts

_cmpvar	jsr	loadfr0
	jsr	loadfr1

	jsr	fsub

	lda	fr0
	rts

;------------------------------------
loadfr0	.proc	(.word loadfr0.adr) .var

	ldy	#5
	mva	(loadfr0.adr),y		fr0,y-
	rpl

	rts

	.endp

;------------------------------------
loadfr1	.proc	(.word loadfr1.adr) .var

	ldy	#5
	mva	(loadfr1.adr),y		fr1,y-
	rpl

	rts

	.endp

;------------------------------------
;	.globl	_fst0r
;	fr0 -> fp
_fst0r	.proc	(.word yx) .reg

	jmp	fst0r

	.endp

;------------------------------------
;	.globl	_fld0r
;	fp -> fr1
_fld0r	.proc	(.word yx) .reg

	jmp	fld0r

	.endp

;------------------------------------
;	.globl	_fld1r
;	fp -> fr1
_fld1r	.proc	(.word yx) .reg

	jmp	fld1r

	.endp
