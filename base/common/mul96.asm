
.proc	@mul96

        lsr @
        ror @
        sta :eax+1
        ror @
        tay
        and #%11000000
        sta :eax
        ror @
        adc :eax
        sta :eax
        tya
        and #%00011111
        adc :eax+1
        and #%01111111
        sta :eax+1

	rts

.endp
