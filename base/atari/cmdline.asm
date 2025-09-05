
; get arguments from command line (when DOS supports it)
; by drac030
; changes: 2024-03-12


.proc	@CmdLine (.byte a) .reg

	stx @sp

	sta idpar

	lda #0
	sta parno
	sta loop+1

	lda	#{jsr*}
	sta	res

; Get filename from SpartaDOS...
get_param
	lda boot?		; sprawdzamy, czy DOS w ogole jest w pamieci
	lsr
	bcc no_sparta

	lda dosvec+1		; a jesli tak, czy DOSVEC nie wskazuje ROM-u
	cmp #$c0
	bcs no_sparta

	ldy #$03
	lda (dosvec),y
	cmp #{jmp}
	bne no_sparta

	ldy #$0a		; COMTAB+$0A (BUFOFF)
	lda (dosvec),y
	sta lbuf
	iny
	lda (dosvec),y
	sta hbuf

	adw dosvec #33 tmp

	ldy #0
fnm	lda (tmp),y
	iny
	cmp #$9b
	bne fnm

	tya			; remove .COM
	sub #5
	tay
	lda #0
	sta (tmp),y
	tay

	lda	#3
	sta	loop+1
	add	dosvec
	sta	get_adr
	lda	#0
	adc	dosvec+1
	sta	get_adr+1

	jmp	_ok

no_sparta
	mwa #next get_adr

	lda	#{bit*}
	sta	res

; ... or channel #0
	lda	MAIN.SYSTEM.IOCB@COPY+2	; command
	cmp	#5			; read line
	bne	_no_command_line
	lda	MAIN.SYSTEM.IOCB@COPY+3	; status
	bmi	_no_command_line
; don't assume the line is EOL-terminated
; DOS II+/D overwrites the EOL with ".COM"
; that's why we rely on the length
	lda	MAIN.SYSTEM.IOCB@COPY+9	; length hi
	bne	_no_command_line
	ldx	MAIN.SYSTEM.IOCB@COPY+8	; length lo
	beq	_no_command_line
	inx:inx
	stx	arg_len
; give access to three bytes before the input buffer
; in DOS II+/D the device prompt ("D1:") is there
	lda	MAIN.SYSTEM.IOCB@COPY+4
	sub	#3
	sta	tmp
	lda	MAIN.SYSTEM.IOCB@COPY+5
	sbc	#0
	sta	tmp+1

	lda	#0
	ldy	#0
arg_len	equ *-1
	sta	(tmp),y


loop	ldy	#0

_ok	ldx	#0

lprea	lda	(tmp),y
	sta	@buf+1,x

	beq	stop

	cmp	#$9b
	beq	stop
	cmp	#' '
	beq	stop

	iny
	inx
	cpx #32
	bne lprea

stop	lda #0
parno	equ *-1
	cmp #0
idpar	equ *-1
	beq found

	jsr $ffff		; sty loop+1
get_adr	equ *-2
	beq found

	inc parno
	bne loop

found	lda #0	;+$9b
	sta @buf+1,x
	stx @buf

res	jsr sdxres

_no_command_line		; przeskok tutaj oznacza brak dostepnosci wiersza polecen

	lda parno

	ldx #0
@sp	equ *-1
	rts


sdxres	ldy #$0a		; przywracamy poprzednia wartosc BUFOFF
	lda #0
lbuf	equ *-1
	sta (dosvec),y
	iny
	lda #0
hbuf	equ *-1
	sta (dosvec),y
	rts


_next	iny
next	lda (tmp),y
	beq _eol
	cmp #' '
	beq _next

	cmp #$9b
	beq _eol

	sty loop+1
	rts

_eol	lda #0
	rts

.endp
