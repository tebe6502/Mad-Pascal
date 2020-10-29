
// y*256+y*64

.proc   @mul320			; = 33 bytes, 48/53 cycles

	sta :STACKORIGIN+10
	lda K+1
	sta :STACKORIGIN+STACKWIDTH+10
	lda #$00
	asl :STACKORIGIN+10
	rol :STACKORIGIN+STACKWIDTH+10
	rol @
	asl :STACKORIGIN+10
	rol :STACKORIGIN+STACKWIDTH+10
	rol @
	asl :STACKORIGIN+10
	rol :STACKORIGIN+STACKWIDTH+10
	rol @
	asl :STACKORIGIN+10
	rol :STACKORIGIN+STACKWIDTH+10
	rol @
	asl :STACKORIGIN+10
	rol :STACKORIGIN+STACKWIDTH+10
	rol @
	asl :STACKORIGIN+10
	rol :STACKORIGIN+STACKWIDTH+10
	rol @
	sta :STACKORIGIN+STACKWIDTH*2+10
	lda :STACKORIGIN+10
	sta CR
	lda K
	add :STACKORIGIN+STACKWIDTH+10
	sta CR+1
	lda K+1
	adc :STACKORIGIN+STACKWIDTH*2+10
	sta CR+2
	lda #$00
	adc #$00
	sta CR+3

        rts

.endp
