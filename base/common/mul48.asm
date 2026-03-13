
.proc   @mul48

        ldy     #0              ; clear high-byte

	sty	:eax+1
	sty	:eax+2
	sty	:eax+3

        asl     @		; * 16
	rol	:eax+1
	asl	@
	rol	:eax+1
	asl	@
	rol	:eax+1
	asl	@
	rol	:eax+1
	sta	tmp+1
	ldy	:eax+1

	asl	@		; * 32
	rol	:eax+1

	clc
tmp	adc	#$00
	sta	:eax
	tya
	adc	:eax+1
	sta	:eax+1

        rts

.endp
