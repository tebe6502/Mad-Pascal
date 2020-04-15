
{

InitGraph
SetColorMapEntry
SetColorMapDimensions
SetRGBPalette
SetCurrentPaletteEntry
SetPaletteEntry

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

	lda #0
	jsr @vbxe_cmap

	pla:tax
};
end;


procedure SetColorMapEntry(a,b,c: byte); overload; register; assembler;
asm
{	txa:pha

	mva a colpf0s
	mva b colpf1s
	mva c colpf2s

	lda #0
	jsr @vbxe_cmap

	pla:tax
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


procedure SetRGBPalette(nr: word); assembler; register; overload;
asm
{	inc nr+1

	fxs FX_PSEL, nr+1
	fxs FX_CSEL, nr
};
end;


procedure SetRGBPalette(nr: word; r,g,b: byte); assembler; overload;
asm
{	inc nr+1

	fxs FX_PSEL, nr+1
	fxs FX_CSEL, nr

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

