// sdxld.com + s_vbxe.sys

;ciov	= $e456

errn	= $86
fnam	= $87

;--------------------------
	org $8000
;--------------------------

s_vbxe
	ins 's_vbxe.sys'


ciov	.local
	cpx #$10
	beq ok

	jmp $e456

ok	lda $342,x
	cmp #3
	beq open
	cmp #7
	beq read

	ldy #1
	rts

read	lda $344,x
	sta dst+1
	lda $345,x
	sta dst+2

	lda $348,x
	sta cnt
	lda $349,x
	sta cnt+1

move	lda cnt
	ora cnt+1
	bne loa

	jsr src

	ldy #1
	rts

loa	jsr src
dst	sta $ffff

	inw dst+1

	dew cnt

	lda cnt
	ora cnt+1
	bne loa

	cpw src+1 #ciov
	bne skp

	ldy #136
	rts

skp	ldy #1
	rts

src	lda s_vbxe

	inw src+1
	rts

cnt	dta a(0)

open	mwa #s_vbxe src+1
	ldy #1
	rts

	.endl


;	.align
main
	lda $0700
	cmp #$53
	bne E_8035
	lda $0701
	cmp #$40
	bcc E_8035

	jsr printF

	dta $9B
	dta c'This DOS does not need SDXLD.COM',$9b,$00

	rts

E_8035	lda #$00
	ldx #$3F
E_8039	sta E_870F,x
	dex
	bpl E_8039
	ldx #$01
E_8041	lda $02E7,x
	sta E_8731,x
	dex
	bpl E_8041
/*
	lda <vbxecmd
	sta fnam
	lda >vbxecmd
	sta fnam+1
	jsr OpenFile
	bmi E_809B

	lda <buffer
	sta $0344,x
	lda >buffer
	sta $0345,x
	lda #$80
	sta $0348,x
	lda #$00
	sta $0349,x
	lda #$07
	jsr IoCmd

	lda $0344,x
	clc
	adc $0348,x
	sta $0089
	lda $0345,x
	adc $0349,x
	sta $008A
	ldy #$00
	lda #$9B
	sta ($0089),y
	jsr CloseFile

	ldx #$FF
E_808C	inx
	lda buffer,x
	cmp #$9B
	beq E_8098
	cmp #$20
	beq E_808C

E_8098	stx E_8734
E_809B	ldx #$00
	lda $0342,x
	cmp #$05
	bne E_80E0
	lda $0344,x
	sta $0089
	lda $0345,x
	sta $008A
	ldy #$00
E_80B0	lda ($0089),y
	cmp #$20
	beq E_80C1
	cmp #$2C
	beq E_80C1
	cmp #$9B
	beq E_80E0
	iny
	bne E_80B0
E_80C1	iny
	lda ($0089),y
	cmp #$20
	beq E_80C1
	cmp #$9B
	beq E_80E0
	ldx #$00
E_80CE	lda ($0089),y
	sta buffer,x
	inx
	cmp #$9B
	beq E_80DB
	iny
	bpl E_80CE
E_80DB	lda #$00
	sta buffer,x
*/
E_80E0	lda <vbxesys
	sta fnam
	lda >vbxesys
	sta fnam+1
	jsr OpenFile
	bmi E_8115

E_80ED	ldx #$10
	lda #$00
	ldy #$02
	jsr E_8337

	bmi E_8115
	ldy #$98
	ldx #$10
	lda header+1
	cmp >$FFFA
	bne E_8115
	lda header
	sbc <$FFFA
	bmi E_8115
	asl @
	tay
	lda E_84E2+1,y
	pha
	lda E_84E2,y
	pha
	rts

E_8115	jmp E_8353

Read	jsr E_82C7

	bmi E_818C
	lda #$02
	ldy #$0A
	jsr E_8337

	bmi E_818C
	jmp E_80ED

Close	lda <E_8735
	sta $0344,x
	lda >E_8735
	sta $0345,x
	lda #$08
	sta $0348,x
	lda #$00
	sta $0349,x
	lda #$07
	jsr IOCmd

	bmi E_818C

	lda <symbols
	sta $0080
	lda >symbols
	sta $0081

E_814C	ldy #$00
E_814E	lda ($0080),y
	beq E_8169
	cmp E_8735,y
	bne E_818F
	iny
	cpy #$08
	bcc E_814E
	lda ($0080),y
	sta E_870F
	iny
	lda ($0080),y
	sta E_8710
	bcs E_81A1
E_8169	lda #$00
	sta E_873D

	jsr printF

	dta c'Symbol %s not defined',$9B,$00
	dta a(E_8735)

	ldy #$9A
E_818C	jmp E_8353

E_818F	lda $0080
	clc
	adc #$0A
	sta $0080
	bcc E_814C
	inc $0081
	bne E_814C

Write	jsr E_82C7

	bmi E_818C
E_81A1	lda #$02
	ldy #$02
	jsr E_8337

	bmi E_818C
E_81AA	jsr E_82E3

	bmi E_818C
	cmp #$FE
	beq E_81DD
	bcs E_81CF
	cmp #$FC
	beq E_8204
	bcs E_81F0
	tay
E_81BC	lda ($0082),y
	clc
	adc E_870F
	sta ($0082),y
	iny
	lda ($0082),y
	adc E_8710
	sta ($0082),y
	dey
	tya
	dta $2C
E_81CF	lda #$FA
	clc
	adc $0082
	sta $0082
	bcc E_81AA
	inc $0083
	jmp E_81AA

E_81DD	jsr E_82E3

	bmi E_818C
	tax
	lda E_8711,x
	sta $0082
	lda E_8719,x
	sta $0083
	jmp E_81AA

E_81F0	jsr E_82E3

	bmi E_8271
	sta $0082
	jsr E_82E3

	bmi E_8271
	sta $0083
	ldy #$00
	tya
	jmp E_81BC

E_8204	jmp E_80ED

Status	jsr E_82E3

	bmi E_8271
	sta $0084
	jsr E_82E3

	bmi E_8271
	sta $0085
	jsr E_82E3

	bmi E_8271
	ldy $0084
	sta E_8721,y
	jsr E_82E3

	bmi E_8271
	ldy $0084
	sta E_8729,y
	lda #$02
	ldy #$02
	jsr E_8337

	bmi E_8271
	lda $0085
	bmi E_8257
	ldx #$10
	lda loaadr
	sta $0348,x
	lda loaadr+1
	sta $0349,x
	lda E_8731
	sta $0344,x
	lda E_8732
	sta $0345,x
	lda #$07
	jsr IOCmd

	bmi E_8271
E_8257	ldy $0084
	lda E_8731
	sta E_8711,y
	lda E_8732
	sta E_8719,y
	lda loaadr
	ldx loaadr+1
	jsr E_84CC

	jmp E_80ED

E_8271	jmp E_8353

Open	lda #$02
	ldy #$04
	jsr E_8337

	bmi E_8271
	lda E_839A+2
	cmp >E_83AD
	bne E_8296
	lda E_839A+1
	cmp <E_83AD
	bne E_8296
	ldy #$01
E_828D	lda loaadr,y
	sta E_839A+1,y
	dey
	bpl E_828D
E_8296	lda endadr
	sec
	sbc loaadr
	sta $0348,x
	lda endadr+1
	sbc loaadr+1
	sta $0349,x
	inc $0348,x
	bne E_82B1
	inc $0349,x
E_82B1	lda loaadr
	sta $0344,x
	lda loaadr+1
	sta $0345,x
	lda #$07
	jsr IOCmd

	bmi E_8271
	jmp E_80ED

E_82C7	jsr E_82E3

	bmi E_82E0
	tax
	sec
	lda E_8711,x
	sbc E_8721,x
	sta E_870F
	lda E_8719,x
	sbc E_8729,x
	sta E_8710
E_82E0	cpy #$00
	rts

E_82E3	txa
	pha
	lda #$02
	ldy #$01
	jsr E_8337

	pla
	tax
	lda loaadr
	cpy #$00
	rts

vbxesys	dta c'D:S_VBXE.SYS',$9B,$00

//vbxecmd	dta c'D:S_VBXE.CMD',$9B,$00

OpenFile
	ldx #$10
	jsr CloseFile

	lda fnam
	sta $0344,x
	lda fnam+1
	sta $0345,x
	lda #$04
	sta $034A,x
	lda #$00
	sta $034B,x
	lda #$03
	bne IOCmd

CloseFile
	ldx #$10
	lda #$0C
IOCmd	sta $0342,x
	jmp ciov

E_8337	ldx #$10
	clc
	adc <header
	sta $0344,x
	lda #$00
	adc >header
	sta $0345,x
	tya
	sta $0348,x
	lda #$00
	sta $0349,x
	lda #$07
	bne IOCmd

E_8353	sty errn
	jsr CloseFile

	ldy errn
	cpy #$88
	bne E_83AE
	ldx #$1D
	lda #$00
E_8362	sta header,x
	dex
	bpl E_8362
	lda #$10
	sta temp+23
	lda #$83
	sta temp+5
	ldx #$00
E_8374	lda $0400,x
	cmp #$20
	beq E_837F
	cmp #$4C
	bne E_8397
E_837F	lda $0401,x
	cmp #$EB
	bne E_8397
	lda $0402,x
	cmp #$07
	bne E_8397
	lda <E_8430
	sta $0401,x
	lda >E_8430
	sta $0402,x
E_8397	inx
	bne E_8374
E_839A	jsr E_83AD

	bit E_8733
	bpl E_83AD
	ldx #$01
E_83A4	lda E_8731,x
	sta $02E7,x
	dex
	bpl E_83A4

E_83AD	rts		; end

E_83AE	jsr printF

	dta c'Error %b loading %p',$9B,$00
	dta a(errn)
	dta a(fnam)

	jmp E_83AD
;	rts

symbols	dta c'S_ADD   ',a(_rts)
	dta c'EXTENDED',a(Break)
	dta c'SYMBOL  ',a(E_8735)
	dta c'COMTAB  ',a(header)
	dta c'PRINTF  ',a(printF)
	dta c'S_ADDIZ ',a(s_addiz)
	dta c'U_GETNUM',a(U_GETNUM)
	dta c'U_SLASH ',a(U_SLASH)
	dta c'INSTALL ',a(E_8733)
	dta c'T_      ',a(header)
	dta $00

E_8430	lda #$00
	rts

U_GETNUM
	lda <buffer
	clc
	adc E_8734
	pha
	lda >buffer
	adc #$00
	tax
	pla
	jsr E_85FD

	php
	pha
	tya
	pha
	ldy E_8734
E_844A	lda buffer,y
	cmp #$9B
	beq E_8464
	cmp #$2F
	beq E_8464
	iny
	bmi E_8464
	cmp #$20
	bne E_844A
E_845C	iny
	lda buffer,y
	cmp #$20
	beq E_845C
E_8464	sty E_8734
	pla
	tay
	pla
	plp

U_SLASH	sta $0080
	stx $0081
	sty $0089
E_8471	dey
	dey
	bmi E_847B
	lda #$00
	sta ($0080),y
	beq E_8471
E_847B	ldy #$01
	ldx E_8734
	lda buffer,x
	cmp #$2F
	bne E_849E
E_8487	ldy #$01
	inx
E_848A	lda buffer,x
	cmp ($0080),y
	bne E_8498
	dey
	lda #$FF
	sta ($0080),y
	bne E_8487
E_8498	iny
	iny
	cpy $0089
	bcc E_848A
E_849E	stx E_8734
	rts

s_addiz	sta E_84DC+1
	sty E_84DC+2
	lda $000C
	sta E_84DF+1
	lda $000D
	sta E_84DF+2
	ldx #$01
E_84B4	lda E_8731,x
	sta $000C,x
	sta $0080,x
	dex
	bpl E_84B4
	ldy #$05
E_84C0	lda E_84DC,y
	sta ($0080),y
	dey
	bpl E_84C0
	lda #$06
	ldx #$00
E_84CC	clc
	adc E_8731
	sta E_8731
	txa
	adc E_8732
	sta E_8732
	clc
_rts	rts

E_84DC	jsr $0000

E_84DF	jmp $0000

; http://tajemnice.atari8.info/8_91/8_91_dosy.html
; Tablica sterownika (ang. handler) zawiera szereg wektorów o określonym znaczeniu.
; Ich kolejność jest następująca:
;	OPEN (wektor otwarcia pliku)
;	CLOSE (wektor zamknięcia pliku)
;	GET BYTE (wektor pobrania bajtu z urządzenia źródłowego)
;	PUT BYTE (wektor wysłania bajtu do peryferia)
;	GET STATUS (wektor pobrania statusu)
;	SPECIAL (wektor specjalny).

E_84E2	dta a(Open-1, Close-1, Read-1, Write-1, Status-1, Open-1)

printF	pla
	sta $0032
	pla
	sta $0033
	ldy #$00
E_84F6	iny
	lda ($0032),y
	bne E_84F6
	sec
	tya
	adc $0032
	sta $0034
	lda #$00
	adc $0033
	sta $0035
	ldy #$01
E_8509	lda ($0032),y
	beq E_8523
	iny
	sty $0015
	ldx #$00
	stx $003A
	asl @
	ror $003A
	lsr @
	cmp #$25
	beq E_8527
E_851C	jsr E_85EE

E_851F	ldy $0015
	bne E_8509
E_8523	clv
	jmp ($0034)

E_8527	lda ($0032),y
	cmp #$25
	beq E_854E
	and #$5F
	cmp #$58
	beq E_8554
	cmp #$42
	beq E_8573
	cmp #$44
	beq E_856E
	cmp #$43
	beq E_8592
	cmp #$53
	beq E_859B
	cmp #$50
	beq E_85B0
	cmp #$46
	beq E_8561
	lda #$25
	dta $2C
E_854E	inc $0015
	bne E_851C
E_8552	beq E_851F
E_8554	jsr E_85BC

	jsr E_85DD

	lda $00D4
	jsr E_85DD

	bne E_851F
E_8561	jsr E_85C5

	ldx $0036
	ldy $0037
	jsr $DD89

	clv
	bvc E_857B
E_856E	jsr E_85BC

	bcs E_8578
E_8573	jsr E_85C5

	sty $00D5
E_8578	jsr $D9AA

E_857B	jsr $D8E6

	ldy #$00
E_8580	lda ($00F3),y
	php
	and #$7F
	sty $0039
	jsr E_85EE

	ldy $0039
	iny
	plp
	bpl E_8580
	bmi E_851F
E_8592	jsr E_85C5

	jsr E_85EE

	jmp E_851F

E_859B	jsr E_85C5

E_859E	lda ($0036),y
	beq E_8552
	cmp #$9B
	beq E_8552
	sty $0038
	jsr E_85EE

	ldy $0038
	iny
	bne E_859E
E_85B0	jsr E_85BC

	sta $0037
	lda $00D4
	sta $0036
	dey
	beq E_859E
E_85BC	jsr E_85C5

	iny
	lda ($0036),y
	sta $00D5
	rts

E_85C5	inc $0015
	ldx #$FE
	ldy #$00
E_85CB	lda ($0034),y
	sta $0038,x
	inc $0034
	bne E_85D5
	inc $0035
E_85D5	inx
	bmi E_85CB
	lda ($0036),y
	sta $00D4
	rts

E_85DD	pha
	:4	lsr @
	jsr E_85E8

	pla
	and #$0F
E_85E8	cmp #$0A
	sed
	adc #$30
	cld
E_85EE	ora $003A
	tay
	lda $0347
	pha
	lda $0346
	pha
	tya
	ldx #$00
	rts

E_85FD	sta $0015
	stx $0016
	ldy #$00
	sty $0032
	sty $0033
	sty $0034
	lda ($0015),y
	cmp #$24
	bne E_863B
E_860F	iny
	lda ($0015),y
	cmp #$30
	bcc E_867A
	cmp #$3A
	bcc E_8627
	and #$DF
	cmp #$41
	bcc E_867A
	cmp #$47
	bcs E_867A
	sec
	sbc #$37
E_8627	and #$0F
	ldx #$04
E_862B	asl $0032
	rol $0033
	rol $0034
	dex
	bne E_862B
	ora $0032
	sta $0032
	jmp E_860F

E_863B	lda ($0015),y
	jsr E_8685

	bcs E_867B
	and #$0F
	pha
	asl $0032
	rol $0033
	rol $0034
	lda $0033
	sta $0035
	lda $0034
	sta $0036
	lda $0032
	asl @
	rol $0035
	rol $0036
	asl @
	rol $0035
	rol $0036
	ldx #$FD
E_8661	adc $0035,x
	sta $0035,x
	lda $0038,x
	inx
	bne E_8661
	pla
	adc $0032
	sta $0032
	bcc E_8677
	inc $0033
	bne E_8677
	inc $0034
E_8677	iny
	bne E_863B
E_867A	dey
E_867B	tya
	php
	lda $0032
	ldx $0033
	ldy $0034
	plp
	rts

E_8685	cmp #$30
	bcc E_868C
	cmp #$3A
	dta $24
E_868C	sec
	rts

Break	brk

buffer	.ds 128

E_870F	.ds 1
E_8710	.ds 1
E_8711	.ds 8
E_8719	.ds 8
E_8721	.ds 8
E_8729	.ds 8
E_8731	.ds 1
E_8732	.ds 1
E_8733	.ds 1
E_8734	.ds 1
E_8735	.ds 8
E_873D	.ds 2

header	.ds 2
loaadr	.ds 2
endadr	.ds 2

temp	.ds 23

.print *

	ini main
