
; VBXE Set XDL

.proc	@setxdl(.byte a) .reg

	asl @
	sta idx

	fxs FX_MEMS #$80+MAIN.SYSTEM.VBXE_XDLADR/$1000

	ldy #0
idx	equ *-1

	lda MAIN.SYSTEM.VBXE_WINDOW+s@xdl.xdlc
	and msk,y
	ora val,y
	sta MAIN.SYSTEM.VBXE_WINDOW+s@xdl.xdlc

	lda MAIN.SYSTEM.VBXE_WINDOW+s@xdl.xdlc+1
	and msk+1,y
	ora val+1,y
	sta MAIN.SYSTEM.VBXE_WINDOW+s@xdl.xdlc+1

	fxs FX_MEMS #0
	rts

msk	.array [7] .word
	[e@xdl.mapon]  = [XDLC_MAPON|XDLC_MAPOFF]^$FFFF
	[e@xdl.mapoff] = [XDLC_MAPON|XDLC_MAPOFF]^$FFFF
	[e@xdl.ovron]  = [XDLC_GMON|XDLC_OVOFF|XDLC_LR|XDLC_HR]^$FFFF
	[e@xdl.ovroff] = [XDLC_GMON|XDLC_OVOFF|XDLC_LR|XDLC_HR]^$FFFF
	[e@xdl.hr]     = [XDLC_GMON|XDLC_OVOFF|XDLC_LR|XDLC_HR]^$FFFF
	[e@xdl.lr]     = [XDLC_GMON|XDLC_OVOFF|XDLC_LR|XDLC_HR]^$FFFF
	[e@xdl.tmon]   = [XDLC_GMON|XDLC_TMON|XDLC_MAPOFF]^$FFFF
	.enda

val	.array [7] .word
	[e@xdl.mapon]  = XDLC_MAPON
	[e@xdl.mapoff] = XDLC_MAPOFF
	[e@xdl.ovron]  = XDLC_GMON
	[e@xdl.ovroff] = XDLC_OVOFF
	[e@xdl.hr]     = XDLC_GMON|XDLC_HR
	[e@xdl.lr]     = XDLC_GMON|XDLC_LR
	[e@xdl.tmon]   = XDLC_TMON
	.enda

.endp
