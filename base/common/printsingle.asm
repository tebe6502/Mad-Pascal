
; Single To ATASCII
; by David Schmenk

.proc	@FTOA

I	= :EDX

FRA	= :EAX

HLP	= :ECX

BIT	= @buf+64


	stx @sp

/*
	mva :STACKORIGIN,x I
	mva :STACKORIGIN+STACKWIDTH,x I+1

	mva :STACKORIGIN+STACKWIDTH*2,x I+2
	sta hlp

	mva :STACKORIGIN+STACKWIDTH*3,x I+3

	bpl skp
*/

	lda I+2
	sta HLP
	
	lda I+3
	bpl skp

	ldy #'-'
	jsr @printVALUE.pout

skp

	lda I+3
	asl hlp
	rol @
;	sta EXP				; Exponent

;	lda EXP
	sub #$7F
	tay

	ldx #$3f
	lda #0
	sta:rpl bit,x-

	lda I
	sta FRA
	lda I+1
	sta FRA+1
	lda I+3
	sta FRA+3
	lda I+2
;	sta FRA+2

	asl FRA
	rol FRA+1
	rol @		; FRA+2
	rol FRA+3

; For

;	lda FRA+2		; X = $FF

	jmp c_01D4

l_01D4

;	lda #$20
;	add B
;	tax

;	lda FRA+2
	sta BIT+$20,x

	asl FRA
	rol FRA+1
	rol @		; FRA+2
	rol FRA+3

; ForToDoEpilog
c_01D4
	inx

	cpx #$17+1
	bcc l_01D4
;	beq l_01D4

; WhileDoEpilog
;	jmp l_01D4
l_01EE
b_01D4

	mva #$80 BIT+$1f

	ldx #$00 
	stx I
	stx I+1
	stx I+2
	stx I+3

	stx FRA+1
	stx FRA+2
	stx FRA+3

	inx
	stx FRA

; For

	tya
	add #$1F
;	sta B

	tax

l_035B
;	lda B
;	cmp #$00
;	bcs *+5

; ForToDoProlog
;	jmp l_0375

;	ldy B
	lda BIT,x
	bpl l_03D7

	lda I				; Mantissa
	add FRA
	sta I
	lda I+1
	adc FRA+1
	sta I+1
	lda I+2
	adc FRA+2
	sta I+2
	lda I+3
	adc FRA+3
	sta I+3

; IfThenEpilog
l_03D7

	asl FRA
	rol FRA+1
	rol FRA+2
	rol FRA+3

; ForToDoEpilog
c_035B
;	dec B

	dex
	bpl l_035B

;	lda B
;	cmp #$ff
;	cpy #$ff
;	seq

; WhileDoEpilog
;	jmp l_035B
l_0375
b_035B

	lda #$00
	sta FRA
	sta FRA+1
	sta FRA+2
	sta FRA+3

;	sta EXP

	sta hlp
	sta hlp+1

	lda #$80
	sta hlp+2
; For

	tya
	add #$20
;	sta B

	tax

	add #23+1
	sta FORTMP_1273

	jmp c_0508
; To
l_0508

; ForToDoCondition

;	ldy B
	lda BIT,x
	bpl l_0596

	lda FRA
	add hlp
	sta FRA
	lda FRA+1
	adc hlp+1
	sta FRA+1
	lda FRA+2
	adc hlp+2
	sta FRA+2

; IfThenEpilog
l_0596

	lsr hlp+2
	ror hlp+1
	ror hlp

	inx

; ForToDoEpilog
c_0508
;	inc B					; inc ptr byte [CounterAddress]

	cpx #0
FORTMP_1273	equ *-1
	bcc l_0508
;	beq l_0508

l_0534
b_0508
;	:3 mva fra+# fracpart+#			; fracpart == eax

	mva #6 @float.afterpoint		; wymagana liczba miejsc po przecinku
	@float #500000

	ldx #0
@sp	equ *-1

	rts
.endp
