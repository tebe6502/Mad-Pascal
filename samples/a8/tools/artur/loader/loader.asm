    icl 'atari.hea'
	org $2000

main    
    @ClrScr
    lda >CHARSET_ADDRESS
    sta chbas
    lda COLORS
    sta 710
    lda COLORS + 1
    sta 709
    mwa SDLSTL $fe
    ldy #4
    lda <ATASCII_ART_ADDRESS
    sta ($fe),y
    iny
    lda >ATASCII_ART_ADDRESS
    sta ($fe),y    

getk	
	lda kbcodes	
	cmp #255		
	beq getk	

    @ClrScr

.proc	@ClrScr
	ldx #$00
	lda #$0c
	jsr xcio
	mwa #ename ioadr,x
	mva #$0c ioaux1,x
	mva #$00 ioaux2,x
	lda #$03
xcio	sta iocom,x
	jmp ciov
ename	.byte 'E:',$9b
.endp

    run main

    org $2400
CHARSET_ADDRESS    
    ins 'atari.fnt'
ATASCII_ART_ADDRESS    
    ins 'ARTUR.ASC'
COLORS    
    ins 'colors.bin'
