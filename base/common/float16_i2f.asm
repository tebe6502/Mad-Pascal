
.proc	@F16_I2F				; FUNCTION

SV	= :EAX
V	= :EAX
RESULT	= :EAX

SIG	= :ECX

	lda #$00
	sta SIG

	lda SV+3
	jpl l_0A75

	lda #$00
	sub SV
	sta V
	lda #$00
	sbc SV+1
	sta V+1
	lda #$00
	sbc SV+2
	sta V+2
	lda #$00
	sbc SV+3
	sta V+3

	lda #$80
	sta SIG
	jmp l_0A8A
l_0A75

;	lda SV
;	sta V
;	lda SV+1
;	sta V+1
;	lda SV+2
;	sta V+2
;	lda SV+3
;	sta V+3
l_0A8A

	lda V+3
	ora V+2
	ora V+1
	ora V
	jne l_0A9E

;	lda #$00
	sta RESULT
	sta RESULT+1
	rts					; exit
l_0A9E

	ldy #$19
;	sty E

; --- WhileProlog
	jmp l_0AAB
l_0AAC

	lsr V+3
	ror V+2
	ror V+1
	ror V

	iny
l_0AAB

	lda V+3
	cmp #$00
	bne @+
	lda V+2
	cmp #$00
	bne @+
	lda V+1
	cmp #$08
	bne @+
	lda V
	cmp #$00
@
	jcs l_0AAC

; --- WhileProlog
	jmp l_0AC5
l_0AC6

	asl V
	rol V+1
	rol V+2
	rol V+3

	dey
l_0AC5

	lda V+3
	cmp #$00
	bne @+
	lda V+2
	cmp #$00
	bne @+
	lda V+1
	cmp #$04
	bne @+
	lda V
	cmp #$00
@
	jcc l_0AC6

;	lda E
	cpy #$1F
	jcc l_0AED

	lda #$00
	sta RESULT
	lda SIG
	and #$80
	ora #$7C
	sta RESULT+1
	rts					; exit
l_0AED

	tya
	asl @
	asl @
	sta E+1

;	lda V
;	sta RESULT

	lda V+1
	and #$03
E	ora #$00
	ora SIG
	sta RESULT+1

	rts

.endp
