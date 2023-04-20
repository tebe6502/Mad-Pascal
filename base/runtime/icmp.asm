
; Piotr Fusik, 15.04.2002
; originally by Ullrich von Bassewitz

/*
	cmpSHORTINT
	cmpSMALLINT
	cmpINT
*/

.proc	cmpSHORTINT
	lda	:STACKORIGIN-1,x
	sub	:STACKORIGIN,x
	bne     @L4
@L3	rts

@L4:    bvc     @L3
	eor     #$FF		; Fix the N flag if overflow
	ora     #$01		; Clear the Z flag
	rts	
.endp


.proc	cmpSMALLINT
	lda	:STACKORIGIN-1+STACKWIDTH,x
	sub	:STACKORIGIN+STACKWIDTH,x
	bne     @L4

	lda	:STACKORIGIN-1,x
	cmp	:STACKORIGIN,x	; Compare low byte
	beq     @L3

	lda	#$00
	adc     #$FF		; If the C flag is set then clear the N flag
	ora     #$01		; else set the N flag
@L3:    rts

@L4:    bvc     @L3
	eor     #$FF		; Fix the N flag if overflow
	ora     #$01		; Clear the Z flag
	rts	
.endp


.proc	cmpINT
	lda	:STACKORIGIN-1+STACKWIDTH*3,x
	sub	:STACKORIGIN+STACKWIDTH*3,x
	bne	L4

	lda	:STACKORIGIN-1+STACKWIDTH*2,x
	cmp	:STACKORIGIN+STACKWIDTH*2,x
	bne	L1

	lda	:STACKORIGIN-1+STACKWIDTH,x
	cmp	:STACKORIGIN+STACKWIDTH,x
	bne	L1

	lda	:STACKORIGIN-1,x
	cmp	:STACKORIGIN,x

L1	beq	L2
	bcs	L3
	lda	#$FF	; Set the N flag
L2	rts

L3	lda	#$01	; Clear the N flag
	rts

L4	bvc	L5
	eor	#$FF	; Fix the N flag if overflow
	ora	#$01	; Clear the Z flag
L5	rts
.endp
