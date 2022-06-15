

// Half-precision floating-point (float16)

// https://en.wikipedia.org/wiki/Half-precision_floating-point_format
// https://github.com/tebe6502/16bit-half-float-in-Pascal


.proc	@F16_DIV

// ----------------------------------------------------------------
// f16_div
// changes: 2021-11-21
// ----------------------------------------------------------------

RESULT	= :EAX

V	= :EAX
M1	= :EAX+1	; V[1]

M2	= :ECX		; :ECX+2 -> SREG

REM	= :TMP
SIGN	= :TMP+2

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
	jcs l_0826x
	lda B+1
	and #$7F
	cmp #$7C
	bne @+
	lda B
	cmp #$00
@
	jcc l_0826
l_0826x

	lda #$FF
	sta RESULT
	lda #$7F
	sta RESULT+1
	RTS					; exit
l_0826

	lda A+1
	and #$7C
	cmp #$7C
	bne @+
	lda #$00
@
	jeq l_0851x
	lda B+1
	and #$7F
	bne @+
	lda B
@
	jne l_0851
l_0851x

	lda #$00
	sta RESULT
	lda #$7C
	jmp _exit					; exit
l_0851

	lda B+1
	and #$7C
	cmp #$7C
	jne l_0872

	lda #$00
	sta RESULT
	sta RESULT+1
	RTS					; exit
l_0872

	lda A+1
	and #$7F
	bne @+
	lda A
@
	jne l_088E

	lda #$00
	sta RESULT
	sta RESULT+1
	RTS					; exit
l_088E

	lda A+1
	and #$7C
	jne l_08AA

	lda A+1
	and #$03
	sta M1+1
	jmp l_08BD
l_08AA

	lda A+1
	and #$03
	ora #$04
	sta M1+1
l_08BD

	lda A
	sta M1

	lda B+1
	and #$7C
	jne l_08DF

	lda B+1
	and #$03
	sta M2+1
	jmp l_08F2
l_08DF

	lda B+1
	and #$03
	ora #$04
	sta M2+1
l_08F2

	lda B
	sta M2

;	lda M1
;	sta V+1
;	lda M1+1
;	sta V+2

	lda #$00
	sta V+3

	asl @
	rol V+1
	rol V+2
	rol V+3
	
	asl @
	rol V+1
	rol V+2
	rol V+3

	sta V

;	lda M2
;	sta :ecx
;	lda M2+1
;	sta :ecx+1

.local	div_EAX_CX

ptr1	= eax
ptr2	= eax+2
ptr3	= ecx
sreg	= ecx+2

	LDA #0
	STA sreg
	STA sreg+1

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

	sta REM
	lda sreg+1
	sta REM+1
.endl

	lda B+1
	and #$7C
	lsr @
	lsr @
	sne
	lda #$01
	sta BX+1

	lda A+1
	and #$7C
	lsr @
	lsr @
	sne
	lda #$01
;	sta AX

;	lda AX
	sec
BX	sbc #0
	add #$0F
	tay

; line = 508

;	lda V+3
;	ora V+2
	lda V+1
	ora V
	jne l_097A
	lda REM+1
	ora REM
	jne l_097A

	lda #$00
	sta RESULT
	sta RESULT+1
	RTS					; exit
l_097A

; --- WhileProlog
	jmp l_0983
l_0984

	asl V
	rol V+1
;	rol V+2
;	rol V+3

	asl REM
	rol REM+1

	lda REM+1
	cmp M2+1
	bne @+
	lda REM
	cmp M2
@
	jcc l_09A7

	inw V

	lda REM
	sub M2
	sta REM
	lda REM+1
	sbc M2+1
	sta REM+1
l_09A7

	dey
l_0983

;	lda V+3
;	cmp #$00
;	bne @+
;	lda V+2
;	cmp #$00
;	bne @+
	lda V+1
	cmp #$04
	bne @+
	lda V
	cmp #$00
@
	jcs l_09D5

	tya
	jmi l_09D5
	jne l_0984

; --- WhileProlog
	jmp l_09D5
l_09D6

	lsr V+1
	ror V

	iny
l_09D5

;	lda V+3
;	cmp #$00
;	bne @+
;	lda V+2
;	cmp #$00
;	bne @+
	lda V+1
	cmp #$08
	bne @+
	lda V
	cmp #$00
@
	jcs l_09D6

	tya
	bmi @+
	jne l_09FE
@
	eor #$ff
	add #1
	tay
	iny
	lda V
;	cpy #$00
;	beq l_0003_e
l_0003_b
	lsr V+1
	ror @
	dey
	bne l_0003_b
l_0003_e
;	sta V

;	lda #$00
;	sta NEW_EXP

	lda V+1
	and #$03
	jmp _exit				; exit
l_09FE

	tya
	sub #$1F
	svc
	eor #$80
	jmi l_0A2F

	lda #$00
	sta RESULT
	lda #$7C
	jmp _exit				; exit
l_0A2F
	tya
l_0A1D
;	lda NEW_EXP
	asl @
	asl @
	sta REM

;	lda V
;	sta RESULT

	lda V+1
	and #$03
	ora REM
_exit	ora SIGN
	sta RESULT+1

	RTS

.endp