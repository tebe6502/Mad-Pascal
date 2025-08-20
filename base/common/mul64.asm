
.proc   @mul64

	sta :eax+1
	lda #0

	lsr :eax+1
	ror @
	lsr :eax+1
	ror @

	sta :eax

        rts
.endp
