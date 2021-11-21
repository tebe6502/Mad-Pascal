
// Half-precision floating-point (float16)

// https://en.wikipedia.org/wiki/Half-precision_floating-point_format
// https://github.com/tebe6502/16bit-half-float-in-Pascal


.proc	@F16_MUL

// ----------------------------------------------------------------
// f16_mul
// changes: 2021-11-21
// ----------------------------------------------------------------

RESULT	= :EAX

V	= :EAX
M1	= :EAX

M2	= :ECX
SIGN	= :ECX+2

A	= :EDX
B	= :EDX+2

	lda A+1
	eor B+1
	and #$80
	sta SIGN

	lda A+1
	and #$7F
	cmp #$7C
	bne @+
	lda A
	cmp #$00
@
	jcs l_05D2x
	lda B+1
	and #$7F
	cmp #$7C
	bne @+
	lda B
	cmp #$00
@
	jcc l_05D2
l_05D2x

	lda A+1
	and #$7F
	cmp #$7C
	bne @+
	lda A
	cmp #$00
@
	seq
	bcs @+
	jmp *+6
@	jmp l_05F7x
	lda B+1
	and #$7F
	cmp #$7C
	bne @+
	lda B
	cmp #$00
@
	jcc l_05F7
	jeq l_05F7
l_05F7x
	lda #$FF
	sta RESULT
	lda #$7F
	sta RESULT+1
	RTS					; exit
l_05F7

	lda #$00
	sta RESULT
	lda #$7C
	jmp _exit				; exit
l_05D2

	lda A+1
	and #$7F
	bne @+
	lda A
@
	jeq l_062Dx
	lda B+1
	and #$7F
	bne @+
	lda B
@
	jne l_062D
l_062Dx
	lda #$00
	sta RESULT
	sta RESULT+1
	RTS					; exit
l_062D

	lda A+1
	and #$7C
	jne l_066A

	lda A+1
	and #$03
	sta M1+1
	jmp l_067D
l_066A

	lda A+1
	and #$03
	ora #$04
	sta M1+1
l_067D

	lda A
	sta M1

	lda B+1
	and #$7C
	jne l_069F

	lda B+1
	and #$03
	sta M2+1
	jmp l_06B2
l_069F

	lda B+1
	and #$03
	ora #$04
	sta M2+1
l_06B2

	lda B
	sta M2


.local	mul16x16

ptr1 = eax
sreg = eax+2
ptr3 = ecx

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
.endl

	lda A+1
	and #$7C
	lsr @
	lsr @
	sne
	lda #1
	sta AX+1

	lda B+1
	and #$7C
	lsr @
	lsr @
	sne
	lda #1

	clc
AX	adc #0
	sub #$0F
	tay

	lda V+2
	and #$20
	jeq l_073D

	lda V+1
	sta V
	lda V+2
	sta V+1
	lda V+3
	sta V+2

	lda #$00
	lsr @
	ror V+2
	ror V+1
	ror V
	lsr @
	ror V+2
	ror V+1
	ror V
	lsr @
	ror V+2
	ror V+1
	ror V
	
	sta V+3

	iny
	jmp l_0753
l_073D

	lda V+2
	and #$10
	jeq l_0767

	lda V+1
	sta V
	lda V+2
	sta V+1
	lda V+3
	sta V+2

	lda #$00
	lsr @
	ror V+2
	ror V+1
	ror V

	lsr @
	ror V+2
	ror V+1
	ror V
	
	sta V+3

	jmp l_0779
l_0767

	tya
	sub #$0A
	tay

; --- WhileProlog
	jmp l_077C
l_077D

;	lsr V+3
	lsr V+2
	ror V+1
	ror V

	iny
l_077C

;	lda V+3
;	cmp #$00
;	bne @+
	lda V+2
	cmp #$00
	bne @+
	lda V+1
	cmp #$08
	bne @+
	lda V
	cmp #$00
@
	jcs l_077D

l_0779
l_0753
	;sty NEW_EXP
	tya
	bmi @+
	jne l_07A5
@
	eor #$ff
	add #1
;	lda #$00
;	sub NEW_EXP
	tay
	iny
;	sta :STACKORIGIN+10
	lda V
;	ldy :STACKORIGIN+10
;	beq l_0002_e
l_0002_b
;	lsr V+3
	lsr V+2
	ror V+1
	ror @
	dey
	bne l_0002_b
l_0002_e
;	sta V
;	sta RESULT

	lda V+1
	and #$03
	jmp _exit
l_07A5

;	lda NEW_EXP
	sub #$1F
	svc
	eor #$80
	jmi l_07D6

	lda #$00
	sta RESULT
	lda #$7C
	jmp _exit			; exit
l_07D6
	tya
l_07C4

;	lda NEW_EXP
	asl @
	asl @
	sta M2

;	lda V
;	sta RESULT

	lda V+1
	and #$03
	ora M2
	
_exit	ora SIGN
	sta RESULT+1

	RTS

.endp
