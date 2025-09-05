
// Half-precision floating-point (float16)

// https://en.wikipedia.org/wiki/Half-precision_floating-point_format
// https://github.com/tebe6502/16bit-half-float-in-Pascal


.proc	@F16_ADD

// ----------------------------------------------------------------
// f16_add
// changes: 2021-11-19 ; 2022-12-17
// ----------------------------------------------------------------

RESULT		= :EAX

NEW_M		= :EAX
R		= :EAX

EXP_PART	= :EDX
BX		= :EDX+1
SIGN		= :EDX+2

A		= :ECX
B		= :ECX+2
    
	lda A+1
	eor B+1
;	and #$80
;	sne
;	jmp l_03DD
	
	bpl l_03DD

;	lda B
;	sta @F16_SUB.B
	lda B+1
	eor #$80
	sta @F16_SUB.B+1
;	lda A
;	sta @F16_SUB.A
;	lda A+1
;	sta @F16_SUB.A+1

	jmp @F16_SUB

l_03DD

	lda A+1
	and #$80
	sta SIGN

	lda B+1
	and #$7F
	sta B+1

	lda A+1
	and #$7F
	sta A+1

;	lda A+1
	cmp B+1
	bne @+
	lda A
	cmp B
@
	bcs l_0419

	lda A
	sta _A0+1
	lda A+1
	sta _A1+1

	lda B
	sta A
	lda B+1
	sta A+1

_A0	lda #$00
	sta B
_A1	lda #$00
	sta B+1
l_0419

	lda A+1
	cmp #$7C
;	bne @+
;	lda A
;	cmp #$00
;@
	bcs l_0447x

	lda B+1
	cmp #$7C
;	bne @+
;	lda B
;	cmp #$00
;@
	bcc l_0447
l_0447x

	lda A+1
	cmp #$7C
	bne @+
	lda A
	cmp #$01
@
	bcs l_0464x

	lda B+1
	cmp #$7C
	bne @+
	lda B
	cmp #$01
@
	bcc l_0464
l_0464x
	lda #$FF
	sta RESULT
	lda #$7F
	sta RESULT+1
	RTS					; exit

l_0464
	lda #$00
	sta RESULT
	lda #$7C
	ora SIGN
	sta RESULT+1
	rts					;exit

l_0447

	lda B+1
	and #$7C
	sta BX

	lda A+1
	and #$7C

	sta EXP_PART

	sub BX

	beq l_04A8

	lsr @
	lsr @
	tay

	lda BX
	beq l_04C3

	lda B+1
	and #$03
	ora #$04
	sta B+1

	jmp l_04DA
l_04C3
	dey
l_04DA
	lda B
;	ldy SHIFT
;	beq l_0001_e
l_0001_b
	lsr B+1
	ror @

	dey
	bne l_0001_b

l_0001_e
	sta B
	jmp l_04F2

l_04A8

	lda BX
	bne l_0503

	lda A
	add B
	sta RESULT
	lda A+1
	adc B+1
	ora SIGN
	sta RESULT+1
	rts					;exit

l_0503

	lda B+1
	and #$03
	ora #$04
	sta B+1

	lda B
l_04F2
	add A
	sta R
	lda A+1
	adc B+1
	sta R+1

	and #$7C
	cmp EXP_PART
	beq l_0549

	lda A+1
	and #$03
	ora #$04
	;sta AM+1
	tay

	lda A
	;sta AM

;	lda AM
	add B
	sta NEW_M
	;lda AM+1
	tya
	adc B+1
	sta NEW_M+1
	lda #$00
	adc #$00
	lsr @
	ror NEW_M+1
	ror NEW_M

;	lda NEW_M
;	sta R

	lda EXP_PART
	add #$04
	sta EXP_PART

	lda #$03
	and NEW_M+1
	ora EXP_PART
	sta R+1
l_0549

	lda R+1
	cmp #$7C
	bcc l_0587
	bne @+
	lda R
	bcc l_0587
@
	lda #$00
	sta RESULT
	lda #$7C
	ora SIGN
	sta RESULT+1
	rts					;exit

l_0587

;	lda R
;	sta RESULT
	lda R+1
	ora SIGN
	sta RESULT+1

	rts
.endp



.proc	@F16_SUB

// ----------------------------------------------------------------
// f16_sub
// changes: 2021-11-19 ; 2022-12-17
// ----------------------------------------------------------------

RESULT		= :EAX

NEW_M		= :EAX
RES		= :EAX
R		= :EAX

EXP_PART	= :EDX
BX		= :EDX+1
SIGN		= :EDX+2

A		= :ECX
B		= :ECX+2

	lda A+1
	eor B+1
;	and #$80
;	sne
;	jmp l_0143
	
	bpl l_0143

;	lda B
;	sta @F16_ADD.B
	lda B+1
	eor #$80
	sta @F16_ADD.B+1
;	lda A
;	sta @F16_ADD.A
;	lda A+1
;	sta @F16_ADD.A+1

	jmp @F16_ADD

l_0143

	lda A+1
	and #$80
	sta SIGN

	asl A
	rol A+1

	asl B
	rol B+1

	lda A+1
	cmp B+1
	bne @+
	lda A
	cmp B
@
	bcs l_017F

	lda A
	sta RES
	lda A+1
	sta RES+1

	lda B
	sta A
	lda B+1
	sta A+1

	lda RES
	sta B
	lda RES+1
	sta B+1

	lda SIGN
	eor #$80
	sta SIGN
l_017F

	lda A+1
	and #$F8
	sta EXP_PART

	lda B+1
	and #$F8
	sta BX

	lda A+1
	cmp #$F8
;	bne @+
;	lda A
;	cmp #$00
;@
	bcs l_01C8x

	lda B+1
	cmp #$F8
;	bne @+
;	lda B
;	cmp #$00
;@
	bcc l_01C8
l_01C8x

	lda A+1
	cmp #$F8
	bne @+
	lda A
	cmp #$01
@
	bcs l_01F1x

	lda B+1
	cmp #$F8
	bne @+
	lda B
	cmp #$01
@
	bcs l_01F1x

	lda A+1
	cmp B+1
	bne l_01F1
	lda A
	cmp B
	bne l_01F1
l_01F1x
	lda #$FF
	sta RESULT
	lda #$7F
	sta RESULT+1
	RTS					; exit
l_01F1

	lda #$00
	sta RES

	lda SIGN
	ora #$7C
	sta RES+1

	lda A+1
	cmp #$F8
	bne l_0212
	lda A
	bne l_0212

;	lda #$00
;	sta RESULT
;	lda RES+1
;	sta RESULT+1
	RTS					; exit

l_0212
	lda #$00
	sta RESULT
	lda RES+1
	eor #$80
	sta RESULT+1
	RTS					; exit
l_01C8

	lda EXP_PART

	sub BX

	beq l_024C

	lsr @
	lsr @
	lsr @
	tay

	lda BX
	beq l_0267

	lda B+1
	and #$07
	ora #$08
	sta B+1
	jmp l_027E
l_0267

	dey
l_027E

	lda B
;	ldy SHIFT
;	beq l_0000_e
l_0000_b
	lsr B+1
	ror @

	dey
	bne l_0000_b

;l_0000_e
	sta B
	jmp l_0296
l_024C

	lda BX
	bne l_02A7

	lda A
	sub B
	sta RES
	lda A+1
	sbc B+1
	sta RES+1
	lda #$00
	sbc #$00
	lsr @
	ror RES+1
	ror RES

	lda RES+1
	ora RES
	bne l_02C7

;	lda RES
;	sta RESULT
;	lda RES+1
;	sta RESULT+1
	RTS					; exit
l_02C7

;	lda RES
;	sta RESULT
	lda RES+1
	ora SIGN
	sta RESULT+1
	rts					;exit

l_02A7

	lda B+1
	and #$07
	ora #$08
	sta B+1

l_0296

	lda A
	sub B
	sta R
	lda A+1
	sbc B+1
	sta R+1

	and #$F8
	cmp EXP_PART
	bne l_030F
	
	lda R+1

	lsr @
	ror R

;	lda R
;	sta RESULT
;	lda R+1
	ora SIGN
	sta RESULT+1
	rts					;exit

l_030F

	lda A+1
	and #$07
	ora #$08
	;sta AM+1
	tay

	lda A
;	sta AM

;	lda AM
	sub B
	sta NEW_M
	;lda AM+1
	tya
	sbc B+1
	sta NEW_M+1

	ora NEW_M
	bne l_034D

;	lda #$00
	sta RESULT
	sta RESULT+1
	RTS					; exit
l_034D

; --- WhileProlog

	ldy EXP_PART
	beq l_0357w_

	jmp l_0371

l_0357

	tya;lda EXP_PART
	sub #$08
	tay;sta EXP_PART

	beq l_0357w

	asl NEW_M
	rol NEW_M+1

l_0371

	lda NEW_M+1
	and #$08
	beq l_0357

l_0357w
	sty EXP_PART

l_0357w_

	lda NEW_M+1
	and #$07
	ora EXP_PART

	lsr @
	ror NEW_M
	
;	tay
;
;	lda NEW_M
;	sta RESULT
;
;	tya

	ora SIGN
	sta RESULT+1

	rts
	
.endp
