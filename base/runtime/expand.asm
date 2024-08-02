
.proc	@expandSHORT2SMALL
	lda :STACKORIGIN,x
	ora #$7f
	smi
	lda #$00
	sta :STACKORIGIN+STACKWIDTH,x

	rts
.endp


.proc	@expandSHORT2SMALL1
	lda :STACKORIGIN-1,x
	ora #$7f
	smi
	lda #$00
	sta :STACKORIGIN-1+STACKWIDTH,x

	rts
.endp


.proc	@expandToCARD

SMALL	lda :STACKORIGIN+STACKWIDTH,x
	bpl WORD

	lda #$ff
	bne _wo

WORD	lda #$00
	beq _wo

SHORT	lda :STACKORIGIN,x
	bpl BYTE

	lda #$ff
	bne _by

BYTE	lda #$00

_by	sta :STACKORIGIN+STACKWIDTH,x
_wo	sta :STACKORIGIN+STACKWIDTH*2,x
_lo	sta :STACKORIGIN+STACKWIDTH*3,x
	rts
.endp


.proc	@expandToCARD1

SMALL	lda :STACKORIGIN-1+STACKWIDTH,x
	bpl WORD

	lda #$ff
	bne _wo

WORD	lda #$00
	beq _wo

SHORT	lda :STACKORIGIN-1,x
	bpl BYTE

	lda #$ff
	bne _by

BYTE	lda #$00

_by	sta :STACKORIGIN-1+STACKWIDTH,x
_wo	sta :STACKORIGIN-1+STACKWIDTH*2,x
_lo	sta :STACKORIGIN-1+STACKWIDTH*3,x
	rts
.endp


.proc	@expandToREAL

	lda :STACKORIGIN+STACKWIDTH*2,x
	sta :STACKORIGIN+STACKWIDTH*3,x
	lda :STACKORIGIN+STACKWIDTH,x
	sta :STACKORIGIN+STACKWIDTH*2,x
	lda :STACKORIGIN,x
	sta :STACKORIGIN+STACKWIDTH,x
	lda #$00
	sta :STACKORIGIN,x

	rts
.endp


.proc	@expandToREAL1

	lda :STACKORIGIN-1+STACKWIDTH*2,x
	sta :STACKORIGIN-1+STACKWIDTH*3,x
	lda :STACKORIGIN-1+STACKWIDTH,x
	sta :STACKORIGIN-1+STACKWIDTH*2,x
	lda :STACKORIGIN-1,x
	sta :STACKORIGIN-1+STACKWIDTH,x
	lda #$00
	sta :STACKORIGIN-1,x

	rts
.endp
