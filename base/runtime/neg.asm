
/*
	negBYTE
	negWORD
	negCARD
	negBYTE1
	negWORD1
	negCARD1
	negEDX
	negSHORT
*/

.proc	negBYTE
	lda #$00
	sub :STACKORIGIN,x
	sta :STACKORIGIN,x

	lda #$00
	sbc #$00
	sta :STACKORIGIN+STACKWIDTH,x

	lda #$00
	sbc #$00
	sta :STACKORIGIN+STACKWIDTH*2,x

	lda #$00
	sbc #$00
	sta :STACKORIGIN+STACKWIDTH*3,x

	rts
.endp


.proc	negWORD
	lda #$00
	sub :STACKORIGIN,x
	sta :STACKORIGIN,x

	lda #$00
	sbc :STACKORIGIN+STACKWIDTH,x
	sta :STACKORIGIN+STACKWIDTH,x

	lda #$00
	sbc #$00
	sta :STACKORIGIN+STACKWIDTH*2,x

	lda #$00
	sbc #$00
	sta :STACKORIGIN+STACKWIDTH*3,x

	rts
.endp


.proc	negCARD
	lda #$00
	sub :STACKORIGIN,x
	sta :STACKORIGIN,x

	lda #$00
	sbc :STACKORIGIN+STACKWIDTH,x
	sta :STACKORIGIN+STACKWIDTH,x

	lda #$00
	sbc :STACKORIGIN+STACKWIDTH*2,x
	sta :STACKORIGIN+STACKWIDTH*2,x

	lda #$00
	sbc :STACKORIGIN+STACKWIDTH*3,x
	sta :STACKORIGIN+STACKWIDTH*3,x

	rts
.endp


.proc	negBYTE1
	lda #$00
	sub :STACKORIGIN-1,x
	sta :STACKORIGIN-1,x

	lda #$00
	sbc #$00
	sta :STACKORIGIN-1+STACKWIDTH,x

	lda #$00
	sbc #$00
	sta :STACKORIGIN-1+STACKWIDTH*2,x

	lda #$00
	sbc #$00
	sta :STACKORIGIN-1+STACKWIDTH*3,x

	rts
.endp


.proc	negWORD1
	lda #$00
	sub :STACKORIGIN-1,x
	sta :STACKORIGIN-1,x

	lda #$00
	sbc :STACKORIGIN-1+STACKWIDTH,x
	sta :STACKORIGIN-1+STACKWIDTH,x

	lda #$00
	sbc #$00
	sta :STACKORIGIN-1+STACKWIDTH*2,x

	lda #$00
	sbc #$00
	sta :STACKORIGIN-1+STACKWIDTH*3,x

	rts
.endp


.proc	negCARD1
	lda #$00
	sub :STACKORIGIN-1,x
	sta :STACKORIGIN-1,x

	lda #$00
	sbc :STACKORIGIN-1+STACKWIDTH,x
	sta :STACKORIGIN-1+STACKWIDTH,x

	lda #$00
	sbc :STACKORIGIN-1+STACKWIDTH*2,x
	sta :STACKORIGIN-1+STACKWIDTH*2,x

	lda #$00
	sbc :STACKORIGIN-1+STACKWIDTH*3,x
	sta :STACKORIGIN-1+STACKWIDTH*3,x

	rts
.endp


.proc	negEDX
	lda #$00	; minus
	sub edx
	sta edx

	lda #$00
	sbc edx+1
	sta edx+1

	lda #$00
	sbc edx+2
	sta edx+2

	lda #$00
	sbc edx+3
	sta edx+3

	rts
.endp


.proc	negSHORT
	lda #$00
	sub :STACKORIGIN,x
	sta :STACKORIGIN,x

	lda #$00
	sbc :STACKORIGIN+STACKWIDTH,x
	sta :STACKORIGIN+STACKWIDTH,x

	rts
.endp


