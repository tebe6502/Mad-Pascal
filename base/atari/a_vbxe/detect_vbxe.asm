
; VBXE.INC

.proc	@vbxe_detect

;
; 2009 by KMK/DLT
;
	lda #0
	sta fxptr

        lda #$d6
        sta fxptr+1
        ldy #memac_b_control
        jsr clr

        jsr try
        bcc ok

        inc fxptr+1

	jsr try
	bcc ok

	lda #0
	sta fxptr+1
	rts

try    ldx $4000
        jsr chk
        bcc ret
        inx
        stx $4000
        jsr chk
        dec $4000
ret    rts

ok	ldy	#minor_revision		; get core minor version
	lda	(fxptr),y
	rts

chk    lda #$80
        jsr _vbxe_write
        cpx $4000
        bne fnd
        sec
        .byte $24
fnd    clc
clr    lda #$00
_vbxe_write
        sta (fxptr),y
        rts

.endp
