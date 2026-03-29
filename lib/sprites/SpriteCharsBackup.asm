
//---------------------------------------------------------------------
//	SPRITE CHARS BACKUP
//---------------------------------------------------------------------

.local	SpriteCharsBackup

	sty	zp+@zp.hlp0
	iny
	sty	zp+@zp.hlp0+1
	iny
	sty	zp+@zp.hlp1
	iny
	sty	zp+@zp.hlp1+1

	ldy	#PlayfieldWidth*0
	mva	(zp+@zp.hlp5),y		CharsBackup+0,x
	mva	zp+@zp.hlp0		(zp+@zp.hlp5),y
	iny
	mva	(zp+@zp.hlp5),y		CharsBackup+1,x
	mva	zp+@zp.hlp0+1		(zp+@zp.hlp5),y
	iny
	mva	(zp+@zp.hlp5),y		CharsBackup+2,x
	mva	zp+@zp.hlp1		(zp+@zp.hlp5),y
	iny
	mva	(zp+@zp.hlp5),y		CharsBackup+3,x
	mva	zp+@zp.hlp1+1		(zp+@zp.hlp5),y

	ldy	#PlayfieldWidth*1
	mva	(zp+@zp.hlp5),y		CharsBackup+4,x
	mva	zp+@zp.hlp0		(zp+@zp.hlp5),y
	iny
	mva	(zp+@zp.hlp5),y		CharsBackup+5,x
	mva	zp+@zp.hlp0+1		(zp+@zp.hlp5),y
	iny
	mva	(zp+@zp.hlp5),y		CharsBackup+6,x
	mva	zp+@zp.hlp1		(zp+@zp.hlp5),y
	iny
	mva	(zp+@zp.hlp5),y		CharsBackup+7,x
	mva	zp+@zp.hlp1+1		(zp+@zp.hlp5),y

	ldy	#PlayfieldWidth*2
	mva	(zp+@zp.hlp5),y		CharsBackup+8,x
	mva	zp+@zp.hlp0		(zp+@zp.hlp5),y
	iny
	mva	(zp+@zp.hlp5),y		CharsBackup+9,x
	mva	zp+@zp.hlp0+1		(zp+@zp.hlp5),y
	iny
	mva	(zp+@zp.hlp5),y		CharsBackup+10,x
	mva	zp+@zp.hlp1		(zp+@zp.hlp5),y
	iny
	mva	(zp+@zp.hlp5),y		CharsBackup+11,x
	mva	zp+@zp.hlp1+1		(zp+@zp.hlp5),y

	ldy	#PlayfieldWidth*3
	mva	(zp+@zp.hlp5),y		CharsBackup+12,x
	mva	zp+@zp.hlp0		(zp+@zp.hlp5),y
	iny
	mva	(zp+@zp.hlp5),y		CharsBackup+13,x
	mva	zp+@zp.hlp0+1		(zp+@zp.hlp5),y
	iny
	mva	(zp+@zp.hlp5),y		CharsBackup+14,x
	mva	zp+@zp.hlp1		(zp+@zp.hlp5),y
	iny
	mva	(zp+@zp.hlp5),y		CharsBackup+15,x
	mva	zp+@zp.hlp1+1		(zp+@zp.hlp5),y

	rts
.endl
