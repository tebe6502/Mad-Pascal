
/*
	fmulu_8
	imulCL
	imulBYTE
	idivBYTE
	@BYTE.MOD
	@BYTE.DIV
*/

; changes: 24.02.2024
;
; Description: Unsigned 8-bit multiplication with unsigned 16-bit result.
;
; Input: 8-bit unsigned value in T1
;	 8-bit unsigned value in T2
;	 Carry=0: Re-use T1 from previous multiplication (faster)
;	 Carry=1: Set T1 (slower)
;
; Output: 16-bit unsigned value in PRODUCT
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
.proc fmulu_8

t1	= :eax
t2	= :ecx

product	= :eax

;		bcc :+
		    lda T1
		    sta sm1+1
		    sta sm3+1
		    eor #$ff
		    sta sm2+1
		    sta sm4+1

		ldy T2
		sec
sm1:		lda square1_lo,y
sm2:		sbc square2_lo,y
		sta PRODUCT+0
sm3:		lda square1_hi,y
sm4:		sbc square2_hi,y
		sta PRODUCT+1

	rts
.endp


;---------------------------------------------------------------------------


.proc	imulBYTE

	mva :STACKORIGIN,x :ecx
	mva :STACKORIGIN-1,x :eax

	lda #$00

	sta :eax+2
	sta :eax+3

	.ifdef fmulinit
	jmp fmulu_8
	els
	jmp imulCL
	eif

.endp


.proc	idivBYTE

MOD
	mva :STACKORIGIN,x :ecx
	mva :STACKORIGIN-1,x :eax

	jmp @BYTE
.endp


;---------------------------------------------------------------------------
;
; Ullrich von Bassewitz, 2009-08-17
;
; CC65 runtime: 8x8 => 16 unsigned multiplication
;

.proc	imulCL

ptr1 = :ECX
ptr4 = :EAX
	
	ldy #8
	lda #0
	
	sta ptr4+2
	sta ptr4+3

        lsr     ptr4            ; Get first bit into carry
@L0:    bcc     @L1
        clc
        adc     ptr1
@L1:    ror	@
        ror     ptr4
        dey
        bne     @L0
        sta	ptr4+1

	rts
.endp


;---------------------------------------------------------------------------
; DIVIDE ROUTINE (8 BIT)
; AL/CL -> ACC, remainder in ZTMP

.proc 	@BYTE

DIV	.local
A	= :EAX
B	= :ECX
	.endl

MOD	.local
A	= :EAX
B	= :ECX

RESULT	= :ZTMP
	.endl

	lda #$00

	sta :eax+1
	sta :eax+2
	sta :eax+3

	STA :ZTMP+1
	STA :ZTMP+2
	STA :ZTMP+3

	LDY #$08
LOOP	ASL AL
	ROL @
	CMP CL
	BCC DIV2
	SBC CL
	INC AL
DIV2
	DEY
	BNE LOOP

	STA :ZTMP

	rts
.endp
