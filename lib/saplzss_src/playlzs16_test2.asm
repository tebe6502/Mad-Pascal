
	icl 'atari.hea'

	org $2000

main
	ldx <params	; lo DATA PARAMETERS
	ldy >params	; hi DATA PARAMETERS
	jsr sap_lzss.init


loop	mva #$00 $d01a

wai	lda vcount
	cmp #8
	bne wai

	mva #$0f $d01a

	jsr sap_lzss.play

	bcc loop

; end of music

	jsr sap_lzss.stop
	sta $d01a

	ldx <params2	; lo DATA PARAMETERS
	ldy >params2	; hi DATA PARAMETERS
	jsr sap_lzss.init

loop2	mva #$00 $d01a

wai2	lda vcount
	cmp #8
	bne wai2

	mva #$0f $d01a

	jsr sap_lzss.play

	bcc loop2

; end of music

	jsr sap_lzss.stop

	sta $d01a

	jmp main


params	dta a(song_data)		; (2) SAP-R LZSS address
	dta a(200);a(song_end-song_data)	; (2) SAP-R LZSS length
	dta h($a000)			; (1) Hi address of buffer (9*256)
	dta l($d200)			; (1) POKEY address


params2	dta a(song_data2)		; (2) SAP-R LZSS address
	dta a(200);a(song_end-song_data)	; (2) SAP-R LZSS length
	dta h($a000)			; (1) Hi address of buffer (9*256)
	dta l($d210)			; (1) POKEY address


song_data
        ins     'test.lz16'
song_end

song_data2
        ins     'test2.lz16'
song_end2

	.link 'playlzs16.obx'

	run main