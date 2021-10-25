
.macro	m@ora
	lda %%1
	ora %%2
	sta %%3
.endm

.macro	m@add
	lda %%1
	clc
	adc %%2
	sta %%3
.endm

.macro	m@adc
	lda %%1
	adc %%2
	sta %%3
.endm

.macro	m@sub
	lda %%1
	sec
	sbc %%2
	sta %%3
.endm

.macro	m@sbc
	lda %%1
	sbc %%2
	sta %%3
.endm


.macro	m@index2 (Ofset)
	asl :STACKORIGIN-%%Ofset,x
	rol :STACKORIGIN-%%Ofset+STACKWIDTH,x
.endm

.macro	m@index4 (Ofset)
	asl :STACKORIGIN-%%Ofset,x
	rol :STACKORIGIN-%%Ofset+STACKWIDTH,x
	asl :STACKORIGIN-%%Ofset,x
	rol :STACKORIGIN-%%Ofset+STACKWIDTH,x
.endm


m@move	.macro (src, dst, pages)
	ldy #$00
move	:+%%pages mva %%src+#*$100,y %%dst+#*$100,y
	:+%%pages mva %%src+$80+#*$100,y %%dst+$80+#*$100,y
	iny
	bpl move
	.endm


m@fill	.macro
	lda #0
	tay
	tax

loop	cpx >VLEN
	bne fil
	cpy <VLEN
	beq @+

fil	sta VADR,y
	iny
	bne loop
	inx
	inc fil+2
	bne loop

@	mva >VADR fil+2
	.endm


m@call	.macro (os_proc)

	.ifdef MAIN.@DEFINES.ROMOFF

		inc portb

		jsr %%os_proc

		dec portb

	.else

		jsr %%os_proc

	.endif

	.endm
