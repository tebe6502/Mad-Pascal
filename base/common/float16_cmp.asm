
// ----------------------------------------------------------------
// changes: 2022-12-17 ; 2023-10-08
// ----------------------------------------------------------------

.proc	@F16_EQ				; FUNCTION

A	= :EAX
B	= :EAX+2

	lda A+1
_
	and #$7F
	cmp #$7C
	bne @+

	lda A
;	cmp #$00
	bne l_1005x
@
	seq
	bcs l_1005x

	lda B+1
	and #$7F
	cmp #$7C
	bne @+
	lda B
;	cmp #$00
	bne l_1005x
	beq l_1005
@
	bcc l_1005
	beq l_1005
l_1005x

	lda #$00
	rts				; exit
l_1005

	lda A
	ora B
	tay
	lda A+1
	ora B+1
	and #$7F
	bne l_1026

	tya
	bne l_1026

	lda #$01
	rts				; exit

l_1026
	ldy #1
	lda A+1
	cmp B+1
	bne @+
	lda A
	cmp B
@
	beq @+
	dey
@
	tya
	rts				; exit
.endp


// ----------------------------------------------------------------
// changes: 2022-12-17 ; 2023-03-08
// ----------------------------------------------------------------


.proc	@F16_GT				; FUNCTION

A	= :EAX
B	= :EAX+2

	lda A+1
_
	ora B+1
	and #$7F
	bne l_0F34

	lda A
	ora B
	bne l_0F34

	lda #$01
	rts				; exit

l_0F34
	lda A+1
	and #$7F
	cmp #$7C
	bne @+
	lda A
;	cmp #$00
	bne l_0F5Fx
@
	seq
	bcs l_0F5Fx

	lda B+1
	and #$7F
	cmp #$7C
	bne @+
	lda B
;	cmp #$00
	bne l_0F5Fx
	beq l_0F5F
@
	bcc l_0F5F
	beq l_0F5F
l_0F5Fx

	lda #$00
	rts				; exit
l_0F5F

	lda A+1
	bmi l_0F7B

	lda B+1
	bpl l_0F91

	lda #$01
	rts				; exit

l_0F91
	ldy #1
;	lda B+1
	cmp A+1
	bne @+
	lda B
	cmp A
@
	bcc @+
	dey
@
	tya
	rts				; exit

l_0F7B
	ldy B+1
	bmi l_0FC2
	
	lda #$00
	rts				; exit

l_0FC2
;	lda A+1
	and #$7F
	sta B+1

;	lda B+1
	tya
	and #$7F

	ldy #1
	cmp B+1
	bne @+
	lda A
	cmp B
@
	bcc @+
	dey
@
	tya
	rts				; exit
.endp


// ----------------------------------------------------------------
// changes: 2022-12-17
// ----------------------------------------------------------------


.proc	@F16_GTE			; FUNCTION

A	= :EAX
B	= :EAX+2

	lda A+1
_
	ora B+1
	and #$7F
	bne l_0E6D

	lda A
	ora B
	bne l_0E6D

	lda #$01
	rts				; exit

l_0E6D
	lda A+1
	and #$7F
	cmp #$7C
	bne @+

	lda A
;	cmp #$00
	bne l_0E98x
@
	seq
	bcs l_0E98x

	lda B+1
	and #$7F
	cmp #$7C
	bne @+
	lda B
;	cmp #$00
	bne l_0E98x
	beq l_0E98
@
	bcc l_0E98
	beq l_0E98
l_0E98x

	lda #$00
	rts				; exit
l_0E98
	lda A+1
	bmi l_0EB4

	lda B+1
	bpl l_0ECA
	
	lda #$01
	rts				; exit
l_0ECA

	ldy #1
	lda A+1
	cmp B+1
	bne @+
	lda A
	cmp B
@
	bcs @+
	dey
@
	tya
	rts				; exit
l_0EB4

	ldy B+1
	bmi l_0EFB
	
	lda #$00
	rts				; exit
l_0EFB

;	lda A+1
	and #$7F
	sta B+1

;	lda B+1
	tya
	and #$7F

	ldy #1
	cmp B+1
	bne @+
	lda B
	cmp A
@
	bcs @+
	dey
@
	tya				; exit
	rts
.endp

