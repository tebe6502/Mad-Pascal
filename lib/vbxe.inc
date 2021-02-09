
{

InitGraph
SetColorMapEntry
SetColorMapDimensions
SetRGBPalette
SetCurrentPaletteEntry
SetPaletteEntry
SetPlayfieldPalette
SetOverlayPalette

}


procedure InitGraph(driver, mode: byte; dev: PByte); overload;
begin

InitGraph(mode);

asm
{	lda driver
	bpl stop

	txa:pha

	jsr @vbxe_detect
	bcc ok

	ldx #grNoInitGraph
	jmp err

ok	jsr @vbxe_init

	ldx #grOK
err	stx GraphResult

	pla:tax
stop
};
end;


procedure SetColorMapEntry; overload; assembler;
asm
{	txa:pha

	@vbxe_put #0

	pla:tax
};
end;


procedure SetColorMapEntry(a,b,c: byte); overload; register; assembler;
asm
{	txa:pha

	mva a colpf0s
	mva b colpf1s
	mva c colpf2s

	@vbxe_put #0

	pla:tax
};
end;


procedure SetPlayfieldPalette(a: byte); register; assembler;
asm
{	fxs FX_MEMS #$80+MAIN.SYSTEM.VBXE_XDLADR/$1000

	ldy #s@xdl.ovwidth

	lda a
	and #3
	:6 asl @
	sta a

	lda MAIN.SYSTEM.VBXE_WINDOW,y
	and #%00111111
	ora a
	sta MAIN.SYSTEM.VBXE_WINDOW,y

	fxs FX_MEMS #$00
};
end;


procedure SetOverlayPalette(a: byte); register; assembler;
asm
{	fxs FX_MEMS #$80+MAIN.SYSTEM.VBXE_XDLADR/$1000

	ldy #s@xdl.ovwidth

	lda a
	and #3
	:4 asl @
	sta a

	lda MAIN.SYSTEM.VBXE_WINDOW,y
	and #%11001111
	ora a
	sta MAIN.SYSTEM.VBXE_WINDOW,y

	fxs FX_MEMS #$00
};
end;


procedure SetColorMapDimensions(w,h: byte); register; assembler;
asm
{	fxs FX_MEMS #$80+MAIN.SYSTEM.VBXE_XDLADR/$1000

	ldy w
	dey
	tya

	ldy #s@xdl.width
	sta MAIN.SYSTEM.VBXE_WINDOW,y

	ldy h
	dey
	tya

	ldy #s@xdl.height
	sta MAIN.SYSTEM.VBXE_WINDOW,y

	fxs FX_MEMS #$00
};
end;


procedure SetRGBPalette(pal: byte); assembler; register; overload;
asm
{
	fxs FX_PSEL, pal	; select Palette
	fxs FX_CSEL, #0		; select Color
};
end;


procedure SetRGBPalette(pal, cnt: byte); assembler; register; overload;
asm
{
	fxs FX_PSEL, pal	; select Palette
	fxs FX_CSEL, cnt	; select Color
};
end;


procedure SetRGBPalette(cnt: byte; r,g,b: byte); assembler; overload;
asm
{
	fxs FX_CSEL, cnt

	lda r
	fxsa FX_CR

	lda g
	fxsa FX_CG

	lda b
	fxsa FX_CB
};
end;


procedure SetRGBPalette(r,g,b: byte); assembler; register; overload;
asm
{	lda r
	fxsa FX_CR

	lda g
	fxsa FX_CG

	lda b
	fxsa FX_CB
};
end;


procedure SetCurrentPaletteEntry(nr: word); register;
begin
	SetRGBPalette(nr);
end;


procedure SetPaletteEntry(nr: word; r,g,b: byte); register; overload;
begin
	SetRGBPalette(nr, r,g,b);
end;


procedure SetPaletteEntry(r,g,b: byte); register; overload;
begin
	SetRGBPalette(r,g,b);
end;

