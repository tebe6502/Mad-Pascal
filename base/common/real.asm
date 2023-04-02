; REAL	fixed-point Q24.8, 32bit
; https://en.wikipedia.org/wiki/Q_(number_format)

/*
	@REAL_MUL
	@REAL_DIV

	divREAL
*/


.proc	@REAL_MUL

RESULT	= :EAX

A	= :EAX
B	= :ECX

	lda A+3
	sta t1+1

	lda B
	sta t1_+1

	lda B+3
	sta t2+1

	lda A
	sta t2_+1
	
	lda #$00
	sta :EDX	;Clear upper half of
	sta :EDX+1	;product
	sta :EDX+2
	sta :EDX+3

	sta :ZTMP8
	sta :ZTMP9
	sta :ZTMP10
	sta :ZTMP11

	ldy #$20	;Set binary count to 32
SHIFT_R	lsr A+3		;Shift multiplyer right
	ror A+2
	ror A+1
	ror A
	bcc ROTATE_R	;Go rotate right if c = 0
	lda :EDX	;Get upper half of product
	clc		;and add multiplicand to
	adc B
	sta :EDX
	lda :EDX+1
	adc B+1
	sta :EDX+1
	lda :EDX+2
	adc B+2
	sta :EDX+2
	lda :EDX+3
	adc B+3
ROTATE_R  ror @		;Rotate partial product
        sta :EDX+3	;right
        ror :EDX+2
        ror :EDX+1
        ror :EDX
        ror :ZTMP11
        ror :ZTMP10
        ror :ZTMP9
        ror :ZTMP8
        dey		;Decrement bit count and
        bne SHIFT_R	;loop until 32 bits are

;	mva :ZTMP8 A
	mva :ZTMP9 A
	mva :ZTMP10 A+1
	mva :ZTMP11 A+2

	ldy :EDX

t1	lda #$00	;:STACKORIGIN-1+STACKWIDTH*3,x	; t1
	bpl @+

	sec
	tya
t1_	sbc #$00	;:STACKORIGIN,x
	tay
@

t2	lda #$00	;:STACKORIGIN+STACKWIDTH*3,x	; t2
	bpl @+

	sec
	tya
t2_	sbc #$00	;:STACKORIGIN-1,x
	tay
@
	sty A+3

	rts
.endp


;---------------------------------------------------------------------------


.proc	@REAL_DIV

RESULT	= :EAX

A	= :EAX
B	= :ECX

	ldy #0

	lda A+3				; dividend sign
	bpl @+
	
	lda #$00
	sub A
	sta A

	lda #$00
	sbc A+1
	sta A+1

	lda #$00
	sbc A+2
	sta A+2

	lda #$00
	sbc A+3
	sta A+3

	iny
@
	lda B+3				; divisor sign
	bpl @+

	lda #$00
	sub B
	sta B

	lda #$00
	sbc B+1
	sta B+1

	lda #$00
	sbc B+2
	sta B+2

	lda #$00
	sbc B+3
	sta B+3

	iny
@
	tya
	and #1
	pha

	jsr divREAL			; idiv ecx

	pla
	beq @+

	lda #$00
	sub :eax
	sta :eax

	lda #$00
	sbc :eax+1
	sta :eax+1

	lda #$00
	sbc :eax+2
	sta :eax+2

	lda #$00
	sbc :eax+3
	sta :eax+3
@
	rts
.endp


;---------------------------------------------------------------------------
; 64bit / 32bit = 32bit
; eax = eax + edx

.proc	divREAL

	mva :ecx ecx0
	sta ecx0_
	mva :ecx+1 ecx1
	sta ecx1_
	mva :ecx+2 ecx2
	sta ecx2_
	mva :ecx+3 ecx3

	mva :eax+3 :eax+4
	mva :eax+2 :eax+3
	mva :eax+1 :eax+2
	mva :eax :eax+1

	lda #$00
	sta :eax
	sta :eax+5
	sta :eax+6
	sta :eax+7

	STA :ZTMP8
	STA :ZTMP9
	STA :ZTMP10
	STA :ZTMP11

	LDY #64
UDIV320	ASL :eax
	ROL :eax+1
	ROL :eax+2
	ROL :eax+3
	ROL :eax+4
	ROL :eax+5
	ROL :eax+6
	ROL :eax+7

	ROL :ZTMP8
	ROL :ZTMP9
	ROL :ZTMP10
	ROL :ZTMP11
			;do a subtraction
	LDA :ZTMP8
	CMP #0
ecx0	equ *-1
	LDA :ZTMP9
	SBC #0
ecx1	equ *-1
	LDA :ZTMP10
	SBC #0
ecx2	equ *-1
	LDA :ZTMP11
	SBC #0
ecx3	equ *-1
	BCC UDIV321
 			;overflow, do the subtraction again, this time store the result
	STA ecx3	;we have the high byte already
	LDA :ZTMP8
	SBC #0		;byte 0
ecx0_	equ *-1
	STA :ZTMP8
	LDA :ZTMP9
	SBC #0
ecx1_	equ *-1
	STA :ZTMP9	;byte 1
	LDA :ZTMP10
	SBC #0
ecx2_	equ *-1
	STA :ZTMP10	;byte 2

	INC :eax	;set result bit

UDIV321	DEY
	BNE UDIV320

	rts
.endp

