
/*
	fmulu_16
	imulCX
	@imulCX_AL
	imulWORD
	idivWORD
	@WORD.DIV
	@WORD.MOD
	
	@divAX_CL
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
;
;.proc multiply_16bit_unsigned
;		 <T1 * <T2 = AAaa
;		 <T1 * >T2 = BBbb
;		 >T1 * <T2 = CCcc
;		 >T1 * >T2 = DDdd
;		
;			AAaa
;		     BBbb
;		     CCcc
;		 + DDdd
;		 ----------
;		   PRODUCT!
;
;		 Setup T1 if changed
.proc	fmulu_16

t1	= :eax
t2	= :ecx

product	= :eax

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
;		inc PRODUCT+3
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
;		inc PRODUCT+3
		inx

	stx PRODUCT+3

	ldx @sp: #0

	rts
.endp


;---------------------------------------------------------------------------


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

	jmp @WORD
.endp


;---------------------------------------------------------------------------
;
; Ullrich von Bassewitz, 2010-11-03
;
; CC65 runtime: 16x16 => 32 unsigned multiplication
;

.proc	imulCX

ptr1 = :EAX
sreg = :EAX+2
ptr3 = :ECX

	lda	ptr1+1
	ora	ptr3+1
	beq	umul8x8r16

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

.local	umul8x8r16

	ldy #8
	
	sta :EAX+2
	sta :EAX+3

        lsr     :EAX            ; Get first bit into carry
@L0:    bcc     @L1
        clc
        adc     :ECX
@L1:    ror	@
        ror     :EAX

        dey
        bne     @L0

        sta	:EAX+1

	rts
.endl

.endp


;---------------------------------------------------------------------------
;
; Ullrich von Bassewitz, 2011-07-10
;
; CC65 runtime: 8x16 => 24 unsigned multiplication
;

.proc	@imulCX_AL

ptr1 = :EAX
sreg = :EAX+2
ptr3 = :ECX

        lda     #0
        sta     sreg
	sta	sreg+1

        ldy     #8              ; Number of bits

        lda     ptr1
        ror     @               ; Get next bit into carry
@L0:    bcc     @L1

        clc
        pha

        lda	ptr3
        adc     ptr1+1
        sta     ptr1+1
        lda     ptr3+1
        adc     sreg
        sta     sreg

        pla

@L1:    ror     sreg
        ror     ptr1+1
        ror     @
        dey
        bne     @L0

        sta     ptr1            ; Save low byte of result
        rts                     ; Done
.endp


;---------------------------------------------------------------------------
; 16by8 division

.proc	@divAX_CL

MOD

ptr1	= :ax
ptr4	= :cx
sreg	= :ztmp

	LDA #0
	STA :ztmp+1
	STA :ztmp+2
	STA :ztmp+3

	sta :eax+2
	sta :eax+3

udiv16by8a:

     .ifdef fmulinit

	.REPT 16
	asl     ptr1
	rol     ptr1+1
	rol     @
	bcs     @+0

	cmp     ptr4
	bcc     @+1
@	sbc     ptr4
	inc     ptr1
@
	.ENDR

     els

	ldy #$10

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

     eif

        sta     sreg

	rts
.endp


;---------------------------------------------------------------------------
; DIVIDE ROUTINE (16 BIT)
; AX/CX -> ACC, remainder in ZTMP

.proc	@WORD

DIV	.local
A	= :EAX
B	= :ECX
	.endl

MOD	.local
A	= :EAX
B	= :ECX

RESULT	= :ZTMP
	.endl
	
	lda DIV.B+1
	jeq @divAX_CL

	LDA #0
	STA :ztmp+1
	STA :ztmp+2
	STA :ztmp+3

	sta :eax+2
	sta :eax+3

     .ifdef fmulinit

	.REPT 16,#
	ASL :ax
	ROL :ax+1
	ROL @
	ROL :ztmp+1
	tay
	CMP :cx
	LDA :ztmp+1
	SBC :cx+1
	BCC @+
	STA :ztmp+1
	INC :ax
	tya
	SBC :cx
	jmp s:1
@	
	tya
s:1
	.ENDR
	
     els

	LDY #$10

LOOP	ASL :ax
	ROL :ax+1
	ROL @
	ROL :ztmp+1
	sta :edx
	CMP :cx
	LDA :ztmp+1
	SBC :cx+1
	BCC DIV2
	STA :ztmp+1
	INC :ax
	lda :edx
	SBC :cx
	jmp DIV3
;	sta :edx
DIV2	lda :edx
DIV3
	DEY
	BNE LOOP
	
     eif

	STA :ztmp

	rts
.endp
