
// Half-precision floating-point (float16)

// https://en.wikipedia.org/wiki/Half-precision_floating-point_format
// https://github.com/tebe6502/16bit-half-float-in-Pascal


.proc	@F16_MUL

// ----------------------------------------------------------------
// f16_mul
// changes: 2021-11-21 ; 2022-12-17 ; 2023-03-03 ; 2023-03-08 ;
//          2023-10-08
// ----------------------------------------------------------------

RESULT	= :EAX

V	= :EAX
M1	= :EAX

M2	= :ECX
SIGN	= :ECX+2

A	= :EDX
B	= :EDX+2

	lda A+1
_
	eor B+1
	and #$80
	sta SIGN

	lda A+1
	and #$7F
	cmp #$7C
;	bne @+
;	lda A
;	cmp #$00
;@
	bcs l_05D2x

	lda B+1
	and #$7F
	cmp #$7C
;	bne @+
;	lda B
;	cmp #$00
;@
	bcc l_05D2
l_05D2x

	lda A+1
	and #$7F
	cmp #$7C
	bne @+
	lda A
;	cmp #$00
	bne l_05F7x
	beq l_05D3
@
	seq
	bcs l_05F7x
l_05D3
	lda B+1
	and #$7F
	cmp #$7C
	bne @+
	lda B
;	cmp #$00
	bne l_05F7x
	beq l_05F7
@
	bcc l_05F7
	beq l_05F7

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
	ora SIGN
	sta RESULT+1
	rts					;exit

l_05D2

	lda A+1
	and #$7F
	bne @+
	lda A
	beq l_062Dx
@
	lda B+1
	and #$7F
	bne l_062D
	lda B
	bne l_062D

l_062Dx
	;lda #$00
	sta RESULT
	sta RESULT+1
	RTS					; exit
l_062D

	lda A+1
	and #$7C
	bne l_066A

	lda A+1
	and #$03
;	sta M1+1
	jmp l_067D
l_066A

	lda A+1
	and #$03
	ora #$04
l_067D
	sta M1+1

	lda A
	sta M1

	lda B+1
	and #$7C
	bne l_069F

	lda B+1
	and #$03
;	sta M2+1
	jmp l_06B2
l_069F

	lda B+1
	and #$03
	ora #$04
l_06B2
	sta M2+1

	lda B
	sta M2


.local	mul16x16

ptr1 = :eax
sreg = :eax+2
ptr3 = :ecx

        lda     #0
        sta     sreg+1

;	ldy     #16             ; Number of bits

        lsr     ptr1+1
        ror     ptr1            ; Get first bit into carry

/*
@L0:    bcc     @L1

        clc
        adc     ptr3
        
	sta	:ecx+3

        lda     ptr3+1
        adc     sreg+1
        sta     sreg+1

        lda	:ecx+3

@L1:    ror     sreg+1
        ror     @
        ror     ptr1+1
        ror     ptr1
*/

	.rept 16
	bcc     @+

        clc
        adc     ptr3
        
	tay

        lda     ptr3+1
        adc     sreg+1
        sta     sreg+1

        tya

@	ror     sreg+1
        ror     @
        ror     ptr1+1
        ror     ptr1
	.endr	
	
;	dey
;	bne     @L0

        sta     sreg            ; Save byte 3
.endl

	lda A+1
	and #$7C
	lsr @
	lsr @
	sne
	lda #1
	sta V

	lda B+1
	and #$7C
	lsr @
	lsr @
	sne
	lda #1

	add V
	sub #$0F
	tay

	lda V+2
	and #$20
	beq l_073D

	lda V+1
	sta V
	lda V+2
	sta V+1
	lda V+3
	sta V+2

	lsr @
	ror V+1
	ror V

	lsr @
	ror V+1
	ror V

	lsr @
	ror V+1
	ror V

	sta V+2

	lda #$00
	sta V+3

	iny
	jmp l_0753

l_073D
	lda V+2
	and #$10
	beq l_0767

	lda V+1
	sta V
	lda V+2
	sta V+1
	lda V+3
	sta V+2

	lsr @
	ror V+1
	ror V

	lsr @
	ror V+1
	ror V

	sta V+2

	lda #$00
	sta V+3

	jmp l_0753

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
;	cmp #$00
	bne l_077D
	lda V+1
	cmp #$08
;	bne @+
;	lda V
;	cmp #$00
;@
	bcs l_077D

l_0753
	;sty NEW_EXP
	tya
	bmi @+
	bne l_07A5
@
	eor #$ff
	tay
	iny
	
	lda V+1

l_0002_b
	lsr V+2
	ror @

	dey
	bpl l_0002_b		; +1	BPL

	and #$03
	ora SIGN
	sta RESULT+1
	rts					;exit

l_07A5

;	lda NEW_EXP
	sub #$1F
	svc
	eor #$80
	bmi l_07D6

	lda #$00
	sta RESULT
	lda #$7C
	ora SIGN
	sta RESULT+1
	rts					;exit

l_07D6
	tya

;	lda NEW_EXP
	asl @
	asl @
	sta M2

;	lda V
;	sta RESULT

	lda V+1
	and #$03
	ora M2
	
	ora SIGN
	sta RESULT+1

	RTS
.endp
