// 0..65535 / 0..511

.extrn	eax, ecx	.byte

.extrn	square1_lo, square1_hi, square2_lo, square2_hi	.word

.extrn	fmulu_16 .word

.public fastdiv, fastdivS


	.reloc


lrcp	ins 'lrcp.bin'

hrcp	ins 'hrcp.bin'

// ---------------------------------------------------------------
.proc	fastdiv //(.word eax .word ecx) .var

	ldy ecx
	lda ecx+1
	bne _hi

	cpy #2
	bcs skp

	mwa eax eax+2

	rts
skp
	lda lrcp,y
	sta ecx
	lda hrcp,y
	sta ecx+1

	jmp fmulu_16

_hi
	lda lrcp+$100,y
	sta ecx
	lda hrcp+$100,y
	sta ecx+1

	jmp fmulu_16
.endp


.proc	fastdivS //(.word eax .word ecx) .var

	lda eax+1
	eor ecx+1
	php

	lda eax+1				; dividend sign
	bpl @+

	lda #$00
	sub eax
	sta eax

	lda #$00
	sbc eax+1
	sta eax+1
@
	lda ecx+1				; divisor sign
	bpl @+

	lda #$00
	sub ecx
	sta ecx

	lda #$00
	sbc ecx+1
	sta ecx+1
@
	jsr fastdiv

	plp
	bpl @+

	lda #$00
	sub eax+2
	sta eax+2

	lda #$00
	sbc eax+3
	sta eax+3
@
	rts
.endp
