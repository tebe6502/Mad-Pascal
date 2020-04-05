
/*
	Reset(f, record)
	Rewrite(f, record)

	C = 1	SEC	IOCHECK TRUE
	C = 0	CLC	IOCHECK FALSE
*/

.proc	@openfile (.word ya .byte x) .reg

	sta bp2
	sty bp2+1

	stx code

	lda #0			;C
	rol @
	sta iocheck

	ldy #s@file.status
	lda (bp2),y
	and #e@file.eof^$ff
	sta (bp2),y

	ldy #s@file.pfname
	lda (bp2),y
	add #1
	sta lfname
	iny
	lda (bp2),y
	adc #0
	sta hfname

	jsr lookup
	bmi error

	ldy #s@file.chanel
	txa
	sta (bp2),y		;CHANNEL

; -----------------------------------------

	lda #$03		;komenda: OPEN
	sta iccmd,x
	lda #$00		;adres nazwy pliku
lfname	equ *-1
	sta icbufa,x
	lda #$00
hfname	equ *-1
	sta icbufa+1,x
	lda #$00		;kod dostepu: $04 odczyt, $08 zapis, $09 dopisywanie, $0c odczyt/zapis, $0d odczyt/dopisywanie
code	equ *-1
	sta icax1,x
	lda #$00		;dodatkowy parametr, $00 jest zawsze dobre
	sta icax2,x
	jsr ciov

error	sty MAIN.SYSTEM.IOResult

	bpl ok

msg	lda #true
iocheck	equ *-1
	beq ok	;skp

	sty dx
;	sty FX_CORE_RESET

	@clrscr

	lda <_error
	ldy >_error
	jsr @printSTRING

	lda #$00
	sta dx+1
	sta dx+2
	sta dx+3

	jsr @printVALUE

	jmp MAIN.@halt
/*
skp	ldy #s@file.status
	lda (bp2),y
	ora #e@file.eof
	sta (bp2),y

	ldy #s@file.record
	lda #$00
	sta (bp2),y
	iny
	sta (bp2),y

	rts
*/
ok	ldy #s@file.status
	lda (bp2),y
	ora #e@file.open
	sta (bp2),y

	rts

_error	dta 6,c'ERROR '

; -----------------------------------------

lookup	ldx #$00
	ldy #$01
loop	lda icchid,x
	cmp #$ff
	beq found
	txa
	clc
	adc #$10
	tax
	bpl loop
	ldy #-95       		; kod bledu "TOO MANY CHANNELS OPEN"
found	rts
.endp


/*
	Close(f)

	C = 1	SEC	IOCHECK TRUE
	C = 0	CLC	IOCHECK FALSE
*/

.proc	@closefile (.word ya) .reg
	sta	bp2
	sty	bp2+1

	ldy	#s@file.status

	lda	#0
	rol	@
	sta	@openfile.iocheck
;	beq	ok_open

	lda	(bp2),y
	and 	#e@file.open
	bne	ok_open

	ldy	#-123		; kod bledu "DEVICE OR FILE NOT OPEN"
	jmp	@openfile.error

ok_open	lda	(bp2),y
	ora	#e@file.eof
	sta	(bp2),y

	ldy	#s@file.chanel
	lda	(bp2),y
	tax

	lda	#$0c		;komenda: CLOSE
	sta	iccmd,x
	jsr	ciov

;	lda	#0		; iocheck off
;	sta	@openfile.iocheck

	jmp	@openfile.error

.endp


/*
	BlockRead(f, buf, num_records, numread)
	BlockWrite(f, buf, num_records, numwrite)

	C = 1	SEC	IOCHECK TRUE
	C = 0	CLC	IOCHECK FALSE
*/

.proc	@readfile (.word ya .byte x) .reg

	sta	bp2
	sty	bp2+1

	stx	code

	lda	#$00
	sta	eax+2
	sta	eax+3
	sta	ecx+2
	sta	ecx+3

	sta	MAIN.SYSTEM.IOResult

	rol	@
	sta	@openfile.iocheck

	ldy	#s@file.status
	lda	(bp2),y
	and	#e@file.open
	bne	ok_open

	ldy	#-123			; kod bledu "DEVICE OR FILE NOT OPEN"
	jmp	@openfile.error

ok_open	ldy	#s@file.record
	mwa	(bp2),y	ecx

	ldy	#s@file.nrecord
	mwa	(bp2),y	eax

;	lda	#0
	jsr	imulCX			; record * nrecord = file length to load

	cpw	eax #0
	beq	nothing

	ldy	#s@file.chanel
	lda	(bp2),y
	tax

	mwa	eax	icbufl,x

	ldy	#s@file.buffer
	mwa	(bp2),y	icbufa,x

	lda	#$00
code	equ *-1
	and	#$7f
	sta	iccmd,x

	jsr	ciov

	sty	MAIN.SYSTEM.IOResult

	bpl ok

	cpy #136
	beq done

	jsr eof

	lda #$00
	sta eax
	sta eax+1

	jmp	@openfile.msg

done	jsr eof

ok	mwa icbufl,x	eax
	ldy #s@file.record
	mwa (bp2),y	ecx

	lda #$00
	jsr idivAX_CX.main

nothing	lda code
	bpl quit			; blockread(f, buf, len)   short version

	ldy #s@file.numread
	mwa (bp2),y ztmp

	ldy #0
	mwa eax (ztmp),y		; length of loaded data / record = number of records

quit	rts

eof	ldy #s@file.status
	lda (bp2),y
	ora #e@file.eof
	sta (bp2),y

	rts
.endp


.proc	@ReadDirFileName (.word ya) .reg

	ldx #5
	clc		; iocheck off
	jsr @readfile	; (ya, x)

	ldy eax

	lda MAIN.SYSTEM.IOResult
	smi
	lda #0		; ok

	rts
.endp


.proc	@DirFileName

	lda #0
	sta attr

	lda @buf

	clc						; clear carry for add
	adc #$FF-'9'					; make m = $FF
	adc #'9'-'0'+1					; carry set if in range n to m
	bcs stop	
	

	lda @buf
	cmp #'*'
	bne skp

	lda #MAIN.SYSUTILS.faReadOnly
	sta attr

skp	ldy #1
	ldx #2
	lda #10
	jsr cpName

	ldx #10
	lda @buf,x
	pha
	bpl files

	lda attr
	ora #MAIN.SYSUTILS.faDirectory
	sta attr

	jmp skp2

files	lda attr
	ora #MAIN.SYSUTILS.faArchive
	sta attr

skp2	pla
	beq stp2

	lda #'.'
	sta (bp2),y
	iny

	lda #13
	jsr cpName
stp2
	dey
	tya
stop	ldy #0
	sta (bp2),y

	ldx #0
attr	equ *-1
	rts

cpName	sta ln
cp	lda @buf,x
	cmp #' '
	beq stp
	sta (bp2),y
	iny
	inx
	cpx #0
ln	equ *-1
	bne cp
stp	rts
.endp

