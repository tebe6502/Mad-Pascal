// https://github.com/pfusik/numen/blob/master/dos.asx

SECTOR_SIZE equ	256
DIR_SECTOR equ	$169

icbalz	equ	$24
icax1z	equ	$2a
dsctln	equ	$2d5
runad	equ	$2e0
initad	equ	$2e2
memlo	equ	$2e7
dcomnd	equ	$302
dbuflo	equ	$304
dbufhi	equ	$305
daux1	equ	$30a
daux2	equ	$30b
hatabs	equ	$31a
dskinv	equ	$e453
pentv	equ	$e486

file_id	equ	$43
load_ptr equ	$44
load_end equ	$46
buffer	equ	$700

	opt	h-f+
	org	$800
buffer_ofs
	dta	c'F',3,a(buffer_ofs),a($e477)

:SECTOR_SIZE!=128	mwy	#SECTOR_SIZE	dsctln
	mwy	#dos_end	memlo

	ldx	#'D'
	ldy	<handler_table
	lda	>handler_table
	jsr	pentv

	jsr	open_findFile
	bmi	load_error

load_1
	jsr	read
	bmi	load_run
	sta	load_ptr
	jsr	read
	bmi	load_error
	sta	load_ptr+1
;	and	load_ptr
	cmp	#$ff
	bcs	load_1
	jsr	read
	bmi	load_error
	sta	load_end
	jsr	read
	bmi	load_error
	sta	load_end+1
	mwa	#ret	initad
load_2
	jsr	read
	bmi	load_error
	ldy	#0
	sta	(load_ptr),y
	ldy	load_ptr
	lda	load_ptr+1
	inw	load_ptr
	cpy	load_end
	sbc	load_end+1
	bcc	load_2
	lda:pha	>load_1-1
	lda:pha	<load_1-1
	jmp	(initad)
load_run
	jmp	(runad)
load_error
	sec
	rts

open
	mvx	#0	file_id
	lda	#':'
	ldy	#1
	cmp	(icbalz),y
	seq:iny

open_getName1
	iny
open_getName2
	lda	(icbalz),y
	cmp	#'_'+1
	bcs	open_getName3
	cmp	#'0'
	bcs	open_getName4
	cmp	#'.'
	bne	open_getName3
	cpx	#8
	beq	open_getName1
open_getName3
	dey
	lda	#' '
open_getName4
	sta	file_name,x+
	cpx	#11
	bcc	open_getName1

open_findFile
	ldy	#<DIR_SECTOR
	lda	#>DIR_SECTOR
	ldx	#'R'
	jsr	sio_sector
	bmi	open_ret
open_findFile1
	ldx	#11
open_findFile2
	lda	buffer-11,x
	beq	open_notFound
	and	#$df
	cmp	#$42
	bne	open_findFile4
	ldy	#11
open_findFile3
	lda	buffer+4,x
	cmp	file_name-1,y
	bne	open_findFile4
	dex
	dey
	bne	open_findFile3
	mva	buffer+3,x	buffer+SECTOR_SIZE-2
	lda	file_id
	asl:asl	@
	eor	buffer+4,x
	sta	buffer+SECTOR_SIZE-3
	tya	;#0
	sta	buffer+SECTOR_SIZE-1
	sta	buffer_ofs
	ldy	#SECTOR_SIZE-3
	sta:rne	buffer-1,y-
	iny	;#1
open_ret
	rts
open_findFile4
	inc	file_id
	txa
	and	#$f0
	add	#$1b
	tax
	bpl	open_findFile2
	inc	daux1
	ldx	#'R'
	jsr	sio_command
	bpl	open_findFile1
	rts
open_notFound
	ldy	#170
	rts

close
	lda	icax1z
	cmp	#8
	bne	success
	ldx	#'W'
sio_next
	lda	buffer+SECTOR_SIZE-3
	and	#$03
	ldy	buffer+SECTOR_SIZE-2
	bne	sio_sector
	cmp	#0
	beq	eof
sio_sector
	sty	daux1
	sta	daux2
	eor:sta	buffer+SECTOR_SIZE-3
	mva	#0	buffer+SECTOR_SIZE-2
sio_command
	stx	dcomnd
;	mwa	#buffer	dbuflo
	mva	>buffer	dbufhi
	jmp	dskinv
eof	ldy	#136
	rts

read
	ldy	buffer_ofs
	cpy	buffer+SECTOR_SIZE-1
	bcc	read_get
	ldx	#'R'
	jsr	sio_next
	bmi	read_ret
	ldy	buffer+SECTOR_SIZE-1
	beq	eof
	ldy	#0
read_get
	lda	buffer,y+
	sty	buffer_ofs
success
	ldy	#1
read_ret
ret
	rts

write
	ldy:inc	buffer+SECTOR_SIZE-1
	sta	buffer,y
	ldy	#1
	rts

handler_table
	dta	a(open-1,close-1,read-1,write-1,ret-1,ret-1)

file_name
	dta	c'AUTORUN    '

dos_end

	org buffer_ofs+$17f
	.byte 0			;Ensure $180 bytes size

.print *

	end