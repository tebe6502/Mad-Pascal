
/*
	fmulu_16
	imulCX
	imulWORD
	idivWORD
	idivAX_CX
	idivAX_CL
*/

; Description: Unsigned 16-bit multiplication with unsigned 32-bit result.
;
; Input: 16-bit unsigned value in T1
;	 16-bit unsigned value in T2
;	 Carry=0: Re-use T1 from previous multiplication (faster)
;	 Carry=1: Set T1 (slower)
;
; Output: 32-bit unsigned value in PRODUCT
;
; Clobbered: PRODUCT, X, A, C
;
; Allocation setup: T1,T2 and PRODUCT preferably on Zero-page.
;		    square1_lo, square1_hi, square2_lo, square2_hi must be
;		    page aligned. Each table are 512 bytes. Total 2kb.
;
; Table generation: I:0..511
;		    square1_lo = <((I*I)/4)
;		    square1_hi = >((I*I)/4)
;		    square2_lo = <(((I-255)*(I-255))/4)
;		    square2_hi = >(((I-255)*(I-255))/4)
//.proc multiply_16bit_unsigned
		; <T1 * <T2 = AAaa
		; <T1 * >T2 = BBbb
		; >T1 * <T2 = CCcc
		; >T1 * >T2 = DDdd
		;
		;	AAaa
		;     BBbb
		;     CCcc
		; + DDdd
		; ----------
		;   PRODUCT!

		; Setup T1 if changed
.proc	fmulu_16

t1	= eax
t2	= ecx

product	= eax

	stx @sp
;		bcc @+
		    lda T1+0
		    sta sm1a+1
		    sta sm3a+1
		    sta sm5a+1
		    sta sm7a+1
		    eor #$ff
		    sta sm2a+1
		    sta sm4a+1
		    sta sm6a+1
		    sta sm8a+1
		    lda T1+1
		    sta sm1b+1
		    sta sm3b+1
		    sta sm5b+1
		    sta sm7b+1
		    eor #$ff
		    sta sm2b+1
		    sta sm4b+1
		    sta sm6b+1
		    sta sm8b+1
;@
		; Perform <T1 * <T2 = AAaa
		ldx T2+0
		sec
sm1a:		lda square1_lo,x
sm2a:		sbc square2_lo,x
		sta PRODUCT+0
sm3a:		lda square1_hi,x
sm4a:		sbc square2_hi,x
		;sta _AA+1
		tay

		; Perform >T1_hi * <T2 = CCcc
		sec
sm1b:		lda square1_lo,x
sm2b:		sbc square2_lo,x
		sta _cc+1
sm3b:		lda square1_hi,x
sm4b:		sbc square2_hi,x
		sta _CC_+1

		; Perform <T1 * >T2 = BBbb
		ldx T2+1
		sec
sm5a:		lda square1_lo,x
sm6a:		sbc square2_lo,x
		sta _bb+1
sm7a:		lda square1_hi,x
sm8a:		sbc square2_hi,x
		sta _BB_+1

		; Perform >T1 * >T2 = DDdd
		sec
sm5b:		lda square1_lo,x
sm6b:		sbc square2_lo,x
		sta _dd+1
sm7b:		lda square1_hi,x
sm8b:		sbc square2_hi,x
;		sta PRODUCT+3
		tax

		; Add the separate multiplications together
		clc
;_AA:		lda #0
		tya
_bb:		adc #0
;		sta PRODUCT+1
		tay
_BB_:		lda #0
_CC_:		adc #0
		sta PRODUCT+2
		bcc @+
;		    inc PRODUCT+3
		inx
		    clc
@
		tya
_cc:		adc #0
;		adc PRODUCT+1
		sta PRODUCT+1
_dd:		lda #0
		adc PRODUCT+2
		sta PRODUCT+2
		scc
;		    inc PRODUCT+3
		inx

	stx PRODUCT+3

	ldx #0
@sp	equ *-1

	rts
.endp


/*

 16 bit multiply and divide routines.
 Three 16 bit (two-byte) locations
 ACC, AUX and EXT must be set up,
 preferably on zero page.

 MULTIPLY ROUTINE

 EAX*ECX -> EAX (low,hi) 32 bit result

*/
/*
.proc	imulCX

	lda #$00
	sta eax+3

	LDY #$11			; A = 0 !
	CLC
LOOP	ROR eax+3
	ROR @
	ROR eax+1
	ROR eax
	BCC MUL2
	CLC
	ADC ecx
	PHA
	LDA ecx+1
	ADC eax+3
	STA eax+3
	PLA
MUL2	DEY
	BNE LOOP

	STA eax+2

	rts
.endp
*/


/*

;
; Ullrich von Bassewitz, 2010-11-03
;
; CC65 runtime: 16x16 => 32 unsigned multiplication
;

*/

.proc	imulCX

ptr1 = :eax
sreg = :eax+2
ptr3 = :ecx

        lda     #0
        sta     sreg+1
        ldy     #16             ; Number of bits

        lsr     ptr1+1
        ror     ptr1            ; Get first bit into carry
@L0:    bcc     @L1

        clc
        adc     ptr3
        pha
        lda     ptr3+1
        adc     sreg+1
        sta     sreg+1
        pla

@L1:    ror     sreg+1
        ror     @
        ror     ptr1+1
        ror     ptr1
        dey
        bne     @L0

        sta     sreg            ; Save byte 3
        rts                     ; Done

 .endp


.proc	imulWORD

	mva :STACKORIGIN,x :ecx
	mva :STACKORIGIN+STACKWIDTH,x :ecx+1

	mva :STACKORIGIN-1,x :eax
	mva :STACKORIGIN-1+STACKWIDTH,x :eax+1

	.ifdef fmulinit
	jmp fmulu_16
	els
	jmp imulCX
	eif
.endp


.proc	idivWORD

MOD
	mva :STACKORIGIN,x :ecx
	mva :STACKORIGIN+STACKWIDTH,x :ecx+1

	mva :STACKORIGIN-1,x :eax
	mva :STACKORIGIN-1+STACKWIDTH,x :eax+1

	jmp idivAX_CX
.endp


; DIVIDE ROUTINE (16 BIT)
; AX/CX -> ACC, remainder in ZTMP

.proc	idivAX_CX

MOD

;	jsr iniEAX_ECX_WORD
main
	LDA #0
	STA ztmp+1
	STA ztmp+2
	STA ztmp+3

	sta :eax+2
	sta :eax+3

	.ifdef fmulinit
	.rept 16
	ASL ax
	ROL ax+1
	ROL @
	ROL ztmp+1
	tay
	CMP cx
	LDA ztmp+1
	SBC cx+1
	BCC @+
	STA ztmp+1
	tya
	SBC cx
	tay
	INC ax
@	tya
	.endr

	els
	LDY #$10

LOOP	ASL ax
	ROL ax+1
	ROL @
	ROL ztmp+1
	sta edx
	CMP cx
	LDA ztmp+1
	SBC cx+1
	BCC DIV2
	STA ztmp+1
	lda edx
	SBC cx
	sta edx
	INC ax
DIV2	lda edx
	DEY
	BNE LOOP
	eif

	STA ztmp

	rts
.endp


;---------------------------------------------------------------------------
; 16by8 division

.proc	idivAX_CL

MOD

ptr1	= ax
ptr4	= cx
sreg	= ztmp

	LDA #0
	STA ztmp+1
	STA ztmp+2
	STA ztmp+3

	sta :eax+2
	sta :eax+3

	ldy #$10

udiv16by8a:
@L0:    asl     ptr1
        rol     ptr1+1
        rol     @
        bcs     @L1

        cmp     ptr4
        bcc     @L2
@L1:    sbc     ptr4
        inc     ptr1

@L2:    dey
        bne     @L0

        sta     sreg

	rts
.endp
