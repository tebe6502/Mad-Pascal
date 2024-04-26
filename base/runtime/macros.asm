
.macro m@lib (label)

	lda portb
	pha
	ldy #=%%label
	and #$01
	ora MAIN.SYSTEM.__PORTB_BANKS-1,y
	sta portb

	jsr %%label.@INITLIBRARY
.endm

   
.macro	m@call (os_proc)

	.ifdef MAIN.@DEFINES.ROMOFF

		inc portb

		jsr %%os_proc
		
		php		; save flags on stack
		
		dec portb

		plp		; restore flags from stack
	.else

		jsr %%os_proc

	.endif

.endm


.macro	m@init

	ldy <VADR
	ldx >VADR

	lda #$00
	beq skp_

clr	sta adr: $1000,y

	iny
	bne skp
	inx
skp_	stx adr+1

skp	cpx >VADR+VLEN
	bne clr
	cpy <VADR+VLEN
	bne clr
.endm


.macro	m@fill (adr, cnt)
	ldy #$7f
lp	:+:cnt sta :adr+#*$80,y
	dey
	bpl lp
.endm


; modify PP (Power Packer) file
.macro m@pp
	.get %%1
	
	len = .filesize(%%1)
	unp = .get[len-2]+.get[len-3]*256

	.put[0] = <[unp-1]
	.put[1] = >[unp-1]

	.put[2] = <[len-4]
	.put[3] = >[len-4]

	.sav [0] len
.endm
