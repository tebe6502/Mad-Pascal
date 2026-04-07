
//---------------------------------------------------------------------
//	SPRITE RESTORE
//---------------------------------------------------------------------

.local	SpriteRestore

	sta	zp+@zp.hlp0
	sty	zp+@zp.hlp0+1

	ldy	#PlayfieldWidth*0
	mva	CharsBackup+0,x		(zp+@zp.hlp0),y+
	mva	CharsBackup+1,x		(zp+@zp.hlp0),y+
	mva	CharsBackup+2,x		(zp+@zp.hlp0),y+
	mva	CharsBackup+3,x		(zp+@zp.hlp0),y

	ldy	#PlayfieldWidth*1
	mva	CharsBackup+4,x		(zp+@zp.hlp0),y+
	mva	CharsBackup+5,x		(zp+@zp.hlp0),y+
	mva	CharsBackup+6,x		(zp+@zp.hlp0),y+
	mva	CharsBackup+7,x		(zp+@zp.hlp0),y

	rts
.endl
