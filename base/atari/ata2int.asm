
; ATASCII to INTERNAL

.proc	@ata2int
        asl
        php
        cmp #2*$60
        bcs @+
        sbc #2*$20-1
        bcs @+
        adc #2*$60
@       plp
        ror
	rts
.endp
