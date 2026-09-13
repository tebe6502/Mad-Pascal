
/*

 @addSTRING
 @concatSTRING

*/


.proc	@addSTRING(.word ya) .reg

// add STRING
// result -> @buf

	sta :TMP
	sty :TMP+1

	stx @sp

	ldx @buf
	inx
	beq stop

	ldy #0
	lda (:TMP),y
	sta ile
	beq stop

	iny

load	lda (:TMP),y
	sta @buf,x

	iny
	inx
	beq stop
	dec ile
	bne load

stop	dex
	stx @buf

	ldx #0
@sp	equ *-1
	rts

ile	brk
.endp


.proc	@concatSTRING

	lda :STACKORIGIN-1,x
	sta :TMP
	ldy :STACKORIGIN-1+STACKWIDTH,x
	sty :TMP+1
	bne skp		; if =0 then is CHAR

	sta @buf+1
	lda #1
	sta @buf
	jmp skp_

skp	ldy #0
lp	lda (:TMP),y
	sta @buf,y
	iny
	bne lp

skp_	lda :STACKORIGIN,x
	ldy :STACKORIGIN+STACKWIDTH,x
	beq addChar	; if =0 then is CHAR
	jsr @addSTRING

exit	lda <@buf	; Result
	sta :STACKORIGIN-1,x
	lda >@buf
	sta :STACKORIGIN-1+STACKWIDTH,x
	rts

addChar	ldy @buf
	cpy #$ff
	beq exit
	
	iny
	sta @buf,y
	sty @buf

	jmp exit
.endp