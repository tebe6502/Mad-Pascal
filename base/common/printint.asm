
/*
	@printVALUE	
	@printMINUS

	@printSHORTINT
	@printSMALLINT
	@printINT

	@printBYTE
	@printWORD
	@printCARD
*/

.proc	@printSHORTINT

	lda :STACKORIGIN,x
	spl
	jsr @printMINUS

	jmp @printBYTE
.endp


.proc	@printSMALLINT

	lda :STACKORIGIN+STACKWIDTH,x
	spl
	jsr @printMINUS

	jmp @printWORD
.endp


.proc	@printINT

	lda :STACKORIGIN+STACKWIDTH*3,x
	spl
	jsr @printMINUS

	jmp @printCARD
.endp


.proc	@printBYTE
	lda :STACKORIGIN,x
_a
	sta dx

	lda #$00 
	sta dx+1
	sta dx+2
	sta dx+3

	jmp @printVALUE._8bit
.endp


.proc	@printWORD
	lda :STACKORIGIN,x
	ldy :STACKORIGIN+STACKWIDTH,x 
_ay
	sta dx
	sty dx+1

	lda #$00
	sta dx+2
	sta dx+3

	jmp @printVALUE._16bit
.endp


.proc	@printCARD
	mva :STACKORIGIN,x dx
	mva :STACKORIGIN+STACKWIDTH,x dx+1
	mva :STACKORIGIN+STACKWIDTH*2,x dx+2
	mva :STACKORIGIN+STACKWIDTH*3,x dx+3

	jmp @printVALUE
.endp


.proc	@printMINUS
	ldy #'-'
	jsr @printVALUE.pout

	jmp @negCARD
.endp


.proc	@printVALUE

	lda dx+3
	bne _32bit

	lda dx+2
	bne _24bit

	lda dx+1
	bne _16bit

_8bit	lda #3
	bne l3

_16bit	lda #5
	bne l3

_24bit	lda #8
	bne l3

	; prints a 32 bit value to the screen (Graham)

_32bit	lda #10

l3	sta limit

	stx @sp

	ldx #0
	stx cnt

lp	jsr div10

	sta tmp,x
	inx
	cpx #10
limit	equ *-1
	bne lp

	;ldx #9
	dex

l1	lda tmp,x
	bne l2
	dex		; skip leading zeros
	bne l1

l2	lda tmp,x
	ora #$30
	tay

	jsr pout
	inc cnt

	dex
	bpl l2

	mva #{jmp*} pout

	lda #0
cnt	equ *-1

	ldx #0
@sp	equ *-1
	rts

pout	jmp @print

	sty @buf+1
pbuf	equ *-2
	inc pbuf

	rts

tmp	.byte 0,0,0,0,0,0,0,0,0,0

.endp


; divides a 32 bit value by 10
; remainder is returned in akku

.proc	div10
        ldy #32		; 32 bits
        lda #0
        clc
l4      rol @
        cmp #10
        bcc skip
        sbc #10
skip    rol dx
        rol dx+1
        rol dx+2
        rol dx+3
        dey
        bpl l4

	rts
.endp
