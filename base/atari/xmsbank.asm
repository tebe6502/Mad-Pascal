
; unit MISC: DetectMem
; by Tebe

.proc	@xmsBank

ptr3 = :eax			; position	(4)

	mva ptr3+3 :ztmp+1	; position shr 14
	mva ptr3+2 :ztmp
	lda ptr3+1

	.rept 6
	lsr :ztmp+1
	ror :ztmp
	ror @
	.endr

	tax			; index to bank

	lda portb
	and #1
	ora MAIN.SYSTEM.__PORTB_BANKS,x
	sta portb

	lda ptr3 		; offset
	sta :ztmp
	lda ptr3+1
	and #$3f
	ora #$40
	sta :ztmp+1

	rts
.endp
