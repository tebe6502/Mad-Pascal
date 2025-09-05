
; VBXE.INC

.proc	@vbxe_detect

	ldy #.sizeof(detect)-1
	mva:rpl copy,y detect,y-

	jmp detect

copy
	.local	detect,@buf
;
; 2009 by KMK/DLT
;
	lda #0
	sta fxptr

        lda #$d6
        sta fxptr+1
        ldy #FX_MEMB
        jsr ?clr

        jsr ?try
        bcc ok

        inc fxptr+1

	jsr ?try
	bcc ok

	lda #0
	sta fxptr+1
	rts

?try    ldx $4000
        jsr ?chk
        bcc ?ret
        inx
        stx $4000
        jsr ?chk
        dec $4000
?ret    rts

ok	ldy	#VBXE_MINOR		; get core minor version
	lda	(fxptr),y
	rts

?chk    lda #$80
        jsr _vbxe_write
        cpx $4000
        bne ?fnd
        sec
        .byte $24
?fnd    clc
?clr    lda #$00
_vbxe_write
        sta (fxptr),y
        rts

/*
	lda	#0
	ldx	#0xd6
	sta	0xd640			; make sure it isn't coincidence
	lda	0xd640
	cmp	#0x10			; do we have major version here?
	beq	VBXE_Detected		; if so, then VBXE is detected
	lda	#0
	inx
	sta	0xd740			; no such luck, try other location
	lda	0xd740
	cmp	#0x10
	beq	VBXE_Detected
	ldx 	#0  			; not here, so not present or FX core version too low
	stx	fxptr+1
	stx	fxptr

	sec
	rts

VBXE_Detected
	stx	fxptr+1
	lda	#0
	sta	fxptr

	ldy	#VBXE_MINOR		; get core minor version
	lda	(fxptr),y

	clc
	rts	 			; x - page of vbxe
*/

	.endl

.endp
