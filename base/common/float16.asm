
// Half-precision floating-point (float16)

// https://en.wikipedia.org/wiki/Half-precision_floating-point_format
// https://github.com/tebe6502/16bit-half-float-in-Pascal


.proc	@F16_ADD

// ----------------------------------------------------------------
// f16_add
// changes: 2021-11-19
// ----------------------------------------------------------------

RESULT		= :EAX

NEW_M		= :EAX
AM		= :EAX+2

EXP_PART	= :EDX
BX		= :EDX+1
SIGN		= :EDX+2

R		= :TMP

A		= :ECX
B		= :ECX+2

    
	lda A+1
	eor B+1
	and #$80
	bne @+
	lda #$00
@
	jeq l_03DD
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
	jcs l_0419

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
	bne @+
	lda A
	cmp #$00
@
	jcs l_0447x
	lda B+1
	cmp #$7C
	bne @+
	lda B
	cmp #$00
@
	jcc l_0447
l_0447x

	lda A+1
	cmp #$7C
	bne @+
	lda A
	cmp #$01
@
	jcs l_0464x
	lda B+1
	cmp #$7C
	bne @+
	lda B
	cmp #$01
@
	jcc l_0464
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

	jmp _exit				; exit
l_0447

	lda B+1
	and #$7C
	sta BX

	lda A+1
	and #$7C

	sta EXP_PART

	sub BX

	jeq l_04A8

	lsr @
	lsr @
	tay

	lda BX
	jeq l_04C3

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
	jne l_0503

	lda A
	add B
	sta RESULT
	lda A+1
	adc B+1

	jmp _exit					; exit
l_0503

	lda B+1
	and #$03
	ora #$04
	sta B+1
l_051C
l_04F2

	lda A
	add B
	sta R
	lda A+1
	adc B+1
	sta R+1

	and #$7C
	cmp EXP_PART
	jeq l_0549

	lda A+1
	and #$03
	ora #$04
	sta AM+1

	lda A
	sta AM

;	lda AM
	add B
	sta NEW_M
	lda AM+1
	adc B+1
	sta NEW_M+1
	lda #$00
	adc #$00
	lsr @
	ror NEW_M+1
	ror NEW_M

	lda NEW_M
	sta R

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
	jcc l_0587
	bne @+
	lda R
	jcc l_0587
@
	lda #$00
	sta RESULT
	lda #$7C
	jmp _exit					; exit
l_0587

	lda R
	sta RESULT

	lda R+1

_exit	ora SIGN
	sta RESULT+1

	rts
	
.endp



.proc	@F16_SUB

// ----------------------------------------------------------------
// f16_sub
// changes: 2021-11-19
// ----------------------------------------------------------------

RESULT		= :EAX

NEW_M		= :EAX
AM		= :EAX+2

EXP_PART	= :EDX
BX		= :EDX+1
SIGN		= :EDX+2

RES		= :TMP
R		= :TMP

A		= :ECX
B		= :ECX+2


	lda A+1
	eor B+1
	and #$80
	bne @+
	lda #$00
@
	jeq l_0143
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
	jcs l_017F

	lda A
	sta _a0+1
	lda A+1
	sta _a1+1

	lda B
	sta A
	lda B+1
	sta A+1

_a0	lda #$00
	sta B
_a1	lda #$00
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
	bne @+
	lda A
	cmp #$00
@
	jcs l_01C8x
	lda B+1
	cmp #$F8
	bne @+
	lda B
	cmp #$00
@
	jcc l_01C8
l_01C8x

	lda A+1
	cmp #$F8
	bne @+
	lda A
	cmp #$01
@
	jcs l_01F1x
	lda B+1
	cmp #$F8
	bne @+
	lda B
	cmp #$01
@
	jcs l_01F1x
	lda A+1
	cmp B+1
	bne @+
	lda A
	cmp B
@
	jne l_01F1
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
	bne @+
	lda A
@
	jne l_0212

	lda #$00
	sta RESULT
	lda RES+1
	sta RESULT+1
	RTS					; exit
l_0212

	lda #$00
	sta RESULT
	lda RES+1
	eor #$80
	sta RESULT+1
	RTS					; exit
l_0221
l_01C8

	lda EXP_PART

	sub BX

	jeq l_024C

	lsr @
	lsr @
	lsr @
	tay

	lda BX
	jeq l_0267

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
l_0000_e
	sta B
	jmp l_0296
l_024C

	lda BX
	jne l_02A7

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
	jne l_02C7

	lda RES
	sta RESULT
	lda RES+1
	sta RESULT+1
	RTS					; exit
l_02C7

	lda RES
	sta RESULT
	lda RES+1
	
	jmp _exit				; exit
l_02A7

	lda B+1
	and #$07
	ora #$08
	sta B+1
l_02E2
l_0296

	lda A
	sub B
	sta R
	lda A+1
	sbc B+1
	sta R+1

	and #$F8
	cmp EXP_PART
	jne l_030F

	lsr R+1
	ror R

	lda R
	sta RESULT
	lda R+1
	
	jmp _exit				; exit
l_030F

	lda A+1
	and #$07
	ora #$08
	sta AM+1

	lda A
	sta AM

;	lda AM
	sub B
	sta NEW_M
	lda AM+1
	sbc B+1
	sta NEW_M+1

	ora NEW_M
	jne l_034D

	lda #$00
	sta RESULT
	sta RESULT+1
	RTS					; exit
l_034D

; --- WhileProlog

	ldy EXP_PART

	jmp l_0356
l_0357

	tya;lda EXP_PART
	sub #$08
	tay;sta EXP_PART

	jeq l_0371

	asl NEW_M
	rol NEW_M+1
l_0371
l_0356

	tya;lda EXP_PART
	jeq l_0357w

	lda NEW_M+1
	and #$08
	jeq l_0357
l_0357w
	sty EXP_PART

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

_exit	ora SIGN
	sta RESULT+1

	rts
	
.endp
