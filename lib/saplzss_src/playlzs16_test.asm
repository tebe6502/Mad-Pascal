
	icl 'atari.hea'

sap_lzss.zp	= $80	; (2) pointer on zero page 'lda (SAP_LZSS.ZP),y'

	org $2000
	
main
	lda <params	; lo DATA PARAMETERS
	ldy >params	; hi DATA PARAMETERS
	jsr sap_lzss.init	
	
	
loop	mva #$00 $d01a

wai	lda vcount
	cmp #8
	bne wai

	mva #$0f $d01a

	jsr sap_lzss.play

	jmp loop


params	dta a(song_data)		; (2) SAP-R LZSS address
	dta a(song_end-song_data)	; (2) SAP-R LZSS length
	dta h($a000)			; (1) Hi address of buffer (9*256)
	dta l($d200)			; (1) POKEY address


song_data
        ins     'test.lz16'
song_end
	

	.link 'playlzs16.obx'

	run main