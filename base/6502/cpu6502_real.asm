; REAL	fixed-point Q24.8, 32bit
; https://en.wikipedia.org/wiki/Q_(number_format)

/*
	mulREAL
	divREAL
*/


.proc	mulREAl

;	jsr iniEAX_ECX_CARD

	mva :STACKORIGIN,x ecx0
	mva :STACKORIGIN+STACKWIDTH,x ecx1
	mva :STACKORIGIN+STACKWIDTH*2,x ecx2
	mva :STACKORIGIN+STACKWIDTH*3,x ecx3

	mva :STACKORIGIN-1,x eax
	mva :STACKORIGIN-1+STACKWIDTH,x eax+1
	mva :STACKORIGIN-1+STACKWIDTH*2,x eax+2
	mva :STACKORIGIN-1+STACKWIDTH*3,x eax+3

;	jsr imul64				; imul ecx 64 bit

	lda #$00
	sta edx		;Clear upper half of
	sta edx+1	;product
	sta edx+2
	sta edx+3

	sta ztmp8
	sta ztmp9
	sta ztmp10
	sta ztmp11

	ldy #$20	;Set binary count to 32
SHIFT_R	lsr eax+3	;Shift multiplyer right
	ror eax+2
	ror eax+1
	ror eax
	bcc ROTATE_R	;Go rotate right if c = 0
	lda edx		;Get upper half of product
	clc		;and add multiplicand to
	adc #0		;it
ecx0	equ *-1
	sta edx
	lda edx+1
	adc #0
ecx1	equ *-1
	sta edx+1
	lda edx+2
	adc #0
ecx2	equ *-1
	sta edx+2
	lda edx+3
	adc #0
ecx3	equ *-1
ROTATE_R  ror @		;Rotate partial product
        sta edx+3	;right
        ror edx+2
        ror edx+1
        ror edx
        ror ztmp11
        ror ztmp10
        ror ztmp9
        ror ztmp8
        dey		;Decrement bit count and
        bne SHIFT_R	;loop until 32 bits are

;	mva ztmp8 eax
	mva ztmp9 eax
	mva ztmp10 eax+1
	mva ztmp11 eax+2


;	mva eax+1 eax
;	mva eax+2 eax+1
;	mva eax+3 eax+2

	ldy edx

	lda :STACKORIGIN-1+STACKWIDTH*3,x	; t1
	bpl @+
	sec
	tya
	sbc :STACKORIGIN,x
	tay
@
	lda :STACKORIGIN+STACKWIDTH*3,x		; t2
	bpl @+
	sec
	tya
	sbc :STACKORIGIN-1,x
	tay
@
	sty eax+3

	jmp movaBX_EAX
.endp


/*
;32 bit multiply with 64 bit product

.proc	imul64

	lda #$00
	sta edx		;Clear upper half of
	sta edx+1	;product
	sta edx+2
	sta edx+3

	sta ztmp8
	sta ztmp9
	sta ztmp10
	sta ztmp11

	ldy #$20	;Set binary count to 32
SHIFT_R	lsr eax+3	;Shift multiplyer right
	ror eax+2
	ror eax+1
	ror eax
	bcc ROTATE_R	;Go rotate right if c = 0
	lda edx		;Get upper half of product
	clc		;and add multiplicand to
	adc ecx		;it
	sta edx
	lda edx+1
	adc ecx+1
	sta edx+1
	lda edx+2
	adc ecx+2
	sta edx+2
	lda edx+3
	adc ecx+3
ROTATE_R  ror @		;Rotate partial product
        sta edx+3	;right
        ror edx+2
        ror edx+1
        ror edx
        ror ztmp11
        ror ztmp10
        ror ztmp9
        ror ztmp8
        dey		;Decrement bit count and
        bne SHIFT_R	;loop until 32 bits are

	mva ztmp8 eax
	mva ztmp9 eax+1
	mva ztmp10 eax+2
	mva ztmp11 eax+3

	rts
.endp
*/

; 64bit / 32bit = 32bit
; eax = eax + edx

.proc	divREAL

	mva :STACKORIGIN,x ecx0
	sta ecx0_
	mva :STACKORIGIN+STACKWIDTH,x ecx1
	sta ecx1_
	mva :STACKORIGIN+STACKWIDTH*2,x ecx2
	sta ecx2_
	mva :STACKORIGIN+STACKWIDTH*3,x ecx3

	mva :STACKORIGIN-1+STACKWIDTH*3,x eax+4
	mva :STACKORIGIN-1+STACKWIDTH*2,x eax+3
	mva :STACKORIGIN-1+STACKWIDTH,x eax+2
	mva :STACKORIGIN-1,x eax+1

	lda #$00
	sta eax
	sta eax+5
	sta eax+6
	sta eax+7

	STA ZTMP8
	STA ZTMP9
	STA ZTMP10
	STA ZTMP11

	LDY #64
UDIV320	ASL eax
	ROL eax+1
	ROL eax+2
	ROL eax+3
	ROL eax+4
	ROL eax+5
	ROL eax+6
	ROL eax+7

	ROL ZTMP8
	ROL ZTMP9
	ROL ZTMP10
	ROL ZTMP11
			;do a subtraction
	LDA ZTMP8
	CMP #0
ecx0	equ *-1
	LDA ZTMP9
	SBC #0
ecx1	equ *-1
	LDA ZTMP10
	SBC #0
ecx2	equ *-1
	LDA ZTMP11
	SBC #0
ecx3	equ *-1
	BCC UDIV321
 			;overflow, do the subtraction again, this time store the result
	STA ecx3	;we have the high byte already
	LDA ZTMP8
	SBC #0		;byte 0
ecx0_	equ *-1
	STA ZTMP8
	LDA ZTMP9
	SBC #0
ecx1_	equ *-1
	STA ZTMP9	;byte 1
	LDA ZTMP10
	SBC #0
ecx2_	equ *-1
	STA ZTMP10	;byte 2

	INC eax		;set result bit

UDIV321	DEY
	BNE UDIV320

	rts
.endp


/*
.proc	divREAL

	jsr iniEAX_ECX_CARD

	mva eax+3 eax+4
	mva eax+2 eax+3
	mva eax+1 eax+2
	mva eax eax+1

	lda #$00
	sta eax
	sta eax+5
	sta eax+6
	sta eax+7

	STA ZTMP8
	STA ZTMP9
	STA ZTMP10
	STA ZTMP11

	LDY #64
UDIV320	ASL eax
	ROL eax+1
	ROL eax+2
	ROL eax+3
	ROL eax+4
	ROL eax+5
	ROL eax+6
	ROL eax+7

	ROL ZTMP8
	ROL ZTMP9
	ROL ZTMP10
	ROL ZTMP11
			;do a subtraction
	LDA ZTMP8
	CMP ecx
	LDA ZTMP9
	SBC ecx+1
	LDA ZTMP10
	SBC ecx+2
	LDA ZTMP11
	SBC ecx+3
	BCC UDIV321
 			;overflow, do the subtraction again, this time store the result
	STA ecx+3	;we have the high byte already
	LDA ZTMP8
	SBC ecx		;byte 0
	STA ZTMP8
	LDA ZTMP9
	SBC ecx+1
	STA ZTMP9	;byte 1
	LDA ZTMP10
	SBC ecx+2
	STA ZTMP10	;byte 2

	INC eax		;set result bit

UDIV321	DEY
	BNE UDIV320

	rts
.endp
*/
