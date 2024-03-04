

.extrn	eax, ecx	.byte

.extrn	square1_lo, square1_hi, square2_lo, square2_hi	.word

.extrn	fmulu_16 .word

.public fastdiv


	.reloc


lrcp	ins 'lrcp.bin'

hrcp	ins 'hrcp.bin'


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
