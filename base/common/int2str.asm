
; IntToStr

.proc	@ValueToStr (.word ya) .reg

	sta adr
	sty adr+1

	mva #{bit*} @printVALUE.pout
	mva <@buf+1 @printVALUE.pbuf

	jsr $ffff
adr	equ *-2

	ldy @printVALUE.pbuf
	dey
	sty @buf

	rts
.endp


; Value To Record

.proc	@ValueToRec (.word ya) .reg

	sta adr
	sty adr+1

	mva #{bit*} @printVALUE.pout
	mva <@buf @printVALUE.pbuf

	jsr $ffff
adr	equ *-2

	ldy @printVALUE.pbuf

	rts
.endp
