
; VBXE init

.proc	@vbxe_init

	fxs FX_MEMC #%1000+>MAIN.SYSTEM.VBXE_WINDOW	; $b000..$bfff (4K window), cpu on, antic off
	fxs FX_MEMS #$80+MAIN.SYSTEM.VBXE_XDLADR/$1000	; enable VBXE BANK #0

	ldx #.sizeof(s@xdl)-1
	mva:rpl xdlist,x MAIN.SYSTEM.VBXE_XDLADR+MAIN.SYSTEM.VBXE_WINDOW,x-

	jsr cmapini		; init color map

	fxsa FX_P1		; A = 0
	fxsa FX_P2
	fxsa FX_P3

	fxsa FX_IRQ_CONTROL
	fxsa FX_BLITTER_START

	fxsa FX_XDL_ADR0	; XDLIST PROGRAM ADDRES (VBXE_XDLADR = $0000) = bank #0
	fxsa FX_XDL_ADR1
	fxsa FX_XDL_ADR2

	sta colpf0s

	fxs FX_P0 #$ff

;	mva #{jsr*}	@putchar.vbxe		; jsr @vbxe_put
;	mwa #@vbxe_put	@putchar.vbxe+1		;
;	mva #$00	@putchar.chn		; #0
	
	m@putchar	{jsr*}, @vbxe_put

	fxs FX_VIDEO_CONTROL #VC_XDL_ENABLED|VC_XCOLOR	;|VC_NO_TRANS

	rts

cmapini	lda colpf1s
	and #$0f
	sta colpf1s

	lda #$80+MAIN.SYSTEM.VBXE_MAPADR/$1000
	sta ztmp

	mva #4 ztmp+1

loop	fxs FX_MEMS ztmp

	lda >MAIN.SYSTEM.VBXE_WINDOW
	sta :bp+1

	ldx #16
	ldy #0
lop
	mva colpf0s (:bp),y
	iny
	mva colpf1s (:bp),y
	iny
	mva colpf2s (:bp),y
	iny
	lda #%00010000		; playfield palette #0 ; overlay palette #1
	sta (:bp),y

	iny
	bne lop

	inc :bp+1
	dex
	bne lop

	inc ztmp

	dec ztmp+1
	bne loop

	fxs FX_MEMS #$00		; disable VBXE BANK
	rts

xdlist	dta s@xdl [0] (XDLC_RPTL, 24-1,\
	XDLC_END|XDLC_RPTL|XDLC_MAPON|XDLC_MAPADR|XDLC_OVADR|XDLC_CHBASE|XDLC_MAPPAR|XDLC_OVATT,\	;|XDLC_GMON,\
	192-1, MAIN.SYSTEM.VBXE_OVRADR,\
	320,\				; OVSTEP
	MAIN.SYSTEM.VBXE_CHBASE/$800,\	; CHBASE
	MAIN.SYSTEM.VBXE_MAPADR, $100,\
	0, 0, 7, 7,\			; XDLC_MAPPAR: hscroll, vscroll, width, height
	%00010001,\			; bit 7..6 PF Pal = 0 ; bit 5..4 OV Pal = 1 ; bit 0..1 NORMAL = 320px
	$ff)

.endp
