
/*
	imulECX
	imulEAX_CX
	imulCARD
	idivCARD
	idivEAX_ECX
	idivEAX_CX
*/

;---------------------------------------------------------------------------

.proc	imulCARD

	jsr iniEAX_ECX_CARD

	jmp imulECX
.endp


.proc	idivCARD

MOD
	jsr iniEAX_ECX_CARD

	jmp idivEAX_ECX.CARD
.endp


;---------------------------------------------------------------------------
; *** MUL32: 32-bit multiply
; EAX * ECX -> ZTMP8-ZTMP11
.proc	imulECX

	lda #0
	sta :ZTMP10
	sta :ZTMP9
	sta :ZTMP8

	ldy #32
MUL320	lsr :ZTMP10
	ror :ZTMP9
	ror :ZTMP8
	ror @
	ror :eax+3
	ror :eax+2
	ror :eax+1
	ror :eax
	bcc MUL321
	clc
	adc :ecx
	pha
	lda :ecx+1
	adc :ZTMP8
	sta :ZTMP8
	lda :ecx+2
	adc :ZTMP9
	sta :ZTMP9
	lda :ecx+3
	adc :ZTMP10
	sta :ZTMP10
	pla
MUL321	dey
       	bpl MUL320

	rts
.endp


;---------------------------------------------------------------------------
; *** MUL32: 32-bit multiply
; EAX * CX -> ZTMP8-ZTMP11

.proc	imulEAX_CX

	lda #0
	sta :TMP

	ldy #32
MUL320	lsr :TMP
	ror @
	ror :eax+3
	ror :eax+2
	ror :eax+1
	ror :eax
	bcc MUL321

	clc
	adc :ecx
	sta :TMP+1
	lda :ecx+1
	adc :TMP
	sta :TMP
	
	lda :TMP+1
MUL321	dey
       	bpl MUL320

	rts
.endp


;---------------------------------------------------------------------------
; *** UDIV32: 32-bit unsigned division
; input: dividend at ZTMP0-ZTMP3
;        divisor at ZTMP4-ZTMP7
; output: result at ZTMP0-ZTMP3
;         remainder at ZTMP8-ZTMP11
; X,Y preserved


.proc	@CARDINAL

DIV	.local
A	= :EAX
B	= :ECX
	.endl

MOD	.local
A	= :EAX
B	= :ECX

RESULT	= :ZTMP
	.endl

	LDA #0
	STA :ZTMP8
	STA :ZTMP9
	STA :ZTMP10
	STA :ZTMP11

	LDY #32

UDIV320	ASL :eax
	ROL :eax+1
	ROL :eax+2
	ROL :eax+3
	ROL :ZTMP8
	ROL :ZTMP9
	ROL :ZTMP10
	ROL :ZTMP11
			;do a subtraction
	LDA :ZTMP8
	CMP :ecx
	LDA :ZTMP9
	SBC :ecx+1
	LDA :ZTMP10
	SBC :ecx+2
	LDA :ZTMP11
	SBC :ecx+3
	BCC UDIV321
 			;overflow, do the subtraction again, this time store the result
	STA :ecx+3	;we have the high byte already
	LDA :ZTMP8
	SBC :ecx	;byte 0
	STA :ZTMP8
	LDA :ZTMP9
	SBC :ecx+1
	STA :ZTMP9	;byte 1
	LDA :ZTMP10
	SBC :ecx+2
	STA :ZTMP10	;byte 2
	INC :eax	;set result bit

UDIV321	DEY
	BNE UDIV320

	rts
.endp



/*
.proc	idivEAX_ECX

REAL	mva :STACKORIGIN-1+STACKWIDTH*2,x :STACKORIGIN-1+STACKWIDTH*3,x
	mva :STACKORIGIN-1+STACKWIDTH,x :STACKORIGIN-1+STACKWIDTH*2,x
	mva :STACKORIGIN-1,x :STACKORIGIN-1+STACKWIDTH,x
	mva #$00 :STACKORIGIN-1,x

CARD	;jsr iniEAX_ECX_CARD

CARD.MOD

MAIN	LDA #0
	STA :ZTMP8
	STA :ZTMP9
	STA :ZTMP10
	STA :ZTMP11

	LDY #32

UDIV320	ASL :eax
	ROL :eax+1
	ROL :eax+2
	ROL :eax+3
	ROL :ZTMP8
	ROL :ZTMP9
	ROL :ZTMP10
	ROL :ZTMP11
			;do a subtraction
	LDA :ZTMP8
	CMP :ecx
	LDA :ZTMP9
	SBC :ecx+1
	LDA :ZTMP10
	SBC :ecx+2
	LDA :ZTMP11
	SBC :ecx+3
	BCC UDIV321
 			;overflow, do the subtraction again, this time store the result
	STA :ecx+3	;we have the high byte already
	LDA :ZTMP8
	SBC :ecx	;byte 0
	STA :ZTMP8
	LDA :ZTMP9
	SBC :ecx+1
	STA :ZTMP9	;byte 1
	LDA :ZTMP10
	SBC :ecx+2
	STA :ZTMP10	;byte 2
	INC :eax	;set result bit

UDIV321	DEY
	BNE UDIV320

	rts
.endp
*/


;---------------------------------------------------------------------------
; Ullrich von Bassewitz, 2009-11-04
;
; CC65 runtime: 32by16 => 16 unsigned division
;
;---------------------------------------------------------------------------
; 32by16 division. Divide ptr1:ptr2 by ptr3. Result is in ptr1, remainder
; in sreg.
;
;   lhs         rhs           result      result also in    remainder
; -----------------------------------------------------------------------
;   ptr1:ptr2   ptr3          ax          ptr1              sreg
;

.proc	idivEAX_CX

MOD

ptr1	= :eax
ptr2	= :eax+2
ptr3	= :ecx
sreg	= :ztmp

	LDA #0
	STA sreg
	STA sreg+1
	STA sreg+2
	STA sreg+3

        ldy     #32

L0:     asl     ptr1
        rol     ptr1+1
        rol     ptr2
        rol     ptr2+1
        rol     @
        rol     sreg+1

        sta	sreg
        cmp     ptr3
        lda     sreg+1
        sbc     ptr3+1
        bcc     L1

        sta     sreg+1
        lda	sreg
        sbc     ptr3
        sta	sreg
        inc     ptr1

L1:     lda	sreg
        dey
        bne     L0

        rts
.endp
