
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

	rts
.endl
