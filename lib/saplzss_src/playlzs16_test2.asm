
	icl 'atari.hea'


	org $2000

main
	lda <player1.data	; lo DATA PARAMETERS
	ldy >player1.data	; hi DATA PARAMETERS
	jsr player1.sap_lzss.init

	lda <player2.data	; lo DATA PARAMETERS
	ldy >player2.data	; hi DATA PARAMETERS
	jsr player2.sap_lzss.init


loop	mva #$00 $d01a

wai	lda vcount
	cmp #8
	bne wai

	mva #$0f $d01a

	jsr player1.sap_lzss.play
	jsr player2.sap_lzss.play

	jmp loop


song1_data
        ins     'test.lz16'
song1_end

song2_data
        ins     'test2.lz16'
song2_end


.local	player1

sap_lzss.zp	= $80	; (2)

	.link 'playlzs16.obx'

data	dta a(song1_data)		; SAP-R LZSS address
	dta a(song1_end-song1_data)	; SAP-R LZSS length
	dta h($a000)			; Hi address of buffer (9*256)
	dta l($d200)			; POKEY address
.endl


.local	player2

sap_lzss.zp	= $82	; (2)

	.link 'playlzs16.obx'

data	dta a(song2_data)		; SAP-R LZSS address
	dta a(song2_end-song2_data)	; SAP-R LZSS length
	dta h($a900)			; Hi address of buffer (9*256)
	dta l($d210)			; POKEY address
.endl

	run main