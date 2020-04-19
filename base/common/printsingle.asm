
; Single To ATASCII
; by David Schmenk

.proc	@FTOA

i	= edx
fra	= ecx
hlp	= eax

exp	= ztmp
b	= ztmp+1
sht	= ztmp+2

bit	= @buf+64

	stx @sp

	mva :STACKORIGIN,x I
	sta :STACKORIGIN+9
	mva :STACKORIGIN+STACKWIDTH,x I+1
	sta :STACKORIGIN+STACKWIDTH+9
	mva :STACKORIGIN+STACKWIDTH*2,x I+2
	sta :STACKORIGIN+STACKWIDTH*2+9
	mva :STACKORIGIN+STACKWIDTH*3,x I+3
	sta :STACKORIGIN+STACKWIDTH*3+9	; Sign

	bpl skp

	ldy #'-'
	jsr @printVALUE.pout

skp
; optimize OK (test_3.pas), line = 32

	lda :STACKORIGIN+STACKWIDTH*3+9
	asl :STACKORIGIN+9
	rol :STACKORIGIN+STACKWIDTH+9
	rol :STACKORIGIN+STACKWIDTH*2+9
	rol @
	sta EXP				; Exponent

; optimize OK (test_3.pas), line = 33

	lda I
	sta FRA
	lda I+1
	sta FRA+1
	lda I+2
	sta FRA+2
	lda I+3
	sta FRA+3
	asl FRA
	rol FRA+1
	rol FRA+2
	rol FRA+3

; optimize OK (test_3.pas), line = 35

	lda EXP
	sub #$7F
	sta SHT

; optimize OK (test_3.pas), line = 37

	ldx #$3f
	lda #0
	sta:rpl bit,x-

; For

; optimize OK (test_3.pas), line = 39

;	sta B
	tax

; optimize OK (test_3.pas), line = 39

l_01D4
;	lda B
;	cmp #$17
	cpx #$17
	bcc *+7
	beq *+5

; ForToDoProlog
	jmp l_01EE

; optimize OK (test_3.pas), line = 40

;	lda #$20
;	add B
;	tax

	lda FRA+2
	sta BIT+$20,x

; optimize OK (test_3.pas), line = 41

	asl FRA
	rol FRA+1
	rol FRA+2
	rol FRA+3

; ForToDoEpilog
c_01D4
;	inc B
	inx

	seq

; WhileDoEpilog
	jmp l_01D4
l_01EE
b_01D4

; optimize OK (test_3.pas), line = 44

	mva #$80 BIT+$1f

; optimize OK (test_3.pas), line = 46

	mva #$00 I
	sta I+1
	sta I+2
	sta I+3

; optimize OK (test_3.pas), line = 47

	sta FRA+1
	sta FRA+2
	sta FRA+3

	mva #$01 FRA

; For

; optimize OK (test_3.pas), line = 49

	lda SHT
	add #$1F
	sta B

; optimize OK (test_3.pas), line = 49

	tay

l_035B
;	lda B
;	cmp #$00
;	bcs *+5

; ForToDoProlog
;	jmp l_0375

; optimize OK (test_3.pas), line = 50

;	ldy B
	lda BIT,y
	bpl l_03D7

; optimize OK (test_3.pas), line = 50

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

; optimize OK (test_3.pas), line = 52

	asl FRA
	rol FRA+1
	rol FRA+2
	rol FRA+3

; ForToDoEpilog
c_035B
;	dec B
	dey

;	lda B
;	cmp #$ff
	cpy #$ff
	seq

; WhileDoEpilog
	jmp l_035B
l_0375
b_035B

; optimize OK (test_3.pas), line = 55

	mva #$00 FRA
	sta FRA+1
	sta FRA+2
	sta FRA+3

; optimize OK (test_3.pas), line = 56

	sta EXP

	sta hlp
	sta hlp+1

	lda #$80
	sta hlp+2
; For

; optimize OK (test_3.pas), line = 58

	lda SHT
	add #$20
;	sta B

	tay

; optimize OK (test_3.pas), line = 58

	add #23
	sta FORTMP_1273
; To
l_0508

; ForToDoCondition

; optimize OK (test_3.pas), line = 58

;	lda B
;	cmp #0
	cpy #0
FORTMP_1273	equ *-1
	bcc *+7
	beq *+5

; ForToDoProlog
	jmp l_0534

; optimize OK (test_3.pas), line = 59

;	ldy B
	lda BIT,y
	bpl l_0596

; optimize OK (test_3.pas), line = 59

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

; ForToDoEpilog
c_0508
;	inc B					; inc ptr byte [CounterAddress]
	iny

	seq

; WhileDoEpilog
	jmp l_0508
l_0534
b_0508
	:3 mva fra+# fracpart+#

	mva #6 @float.afterpoint		; wymagana liczba miejsc po przecinku
	@float #500000

	ldx #0
@sp	equ *-1

	rts
.endp
