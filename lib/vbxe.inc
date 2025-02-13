
{

SetColorMapEntry
SetColorMapDimensions
SetRGBPalette
SetCurrentPaletteEntry
SetPaletteEntry
SetPlayfieldPalette
SetTopBorder
SetOverlayPalette

}


procedure SetColorMapEntry; overload; assembler;
asm
	@vbxe_cmap
end;


procedure SetColorMapEntry(a,b,c, i: byte); overload; assembler;
asm
	mva a colpf0s
	mva b colpf1s
	mva c colpf2s
	mva i @vbxe_cmap.config

	@vbxe_cmap
end;


procedure SetColorMapEntry(a,b,c: byte); overload; register; assembler;
asm
	mva a colpf0s
	mva b colpf1s
	mva c colpf2s

	@vbxe_cmap
end;


procedure SetTopBorder(a: byte); register; assembler;
asm
	fxs FX_MEMS #$80+MAIN.SYSTEM.VBXE_XDLADR/$1000

	lda a
	sub #1

	ldy #s@xdl.RPTL_
	sta MAIN.SYSTEM.VBXE_WINDOW,y

	fxs FX_MEMS #$00
end;


procedure SetXDLHeight(a: byte); register; assembler;
asm
	fxs FX_MEMS #$80+MAIN.SYSTEM.VBXE_XDLADR/$1000

	lda a
	sub #1

	ldy #s@xdl.RPTL
	sta MAIN.SYSTEM.VBXE_WINDOW,y

	fxs FX_MEMS #$00
end;


procedure SetMapStep(a: word); register; assembler;
asm
	fxs FX_MEMS #$80+MAIN.SYSTEM.VBXE_XDLADR/$1000

	ldy #s@xdl.MAPSTEP
	lda a
	sta MAIN.SYSTEM.VBXE_WINDOW,y
	lda a+1
	sta MAIN.SYSTEM.VBXE_WINDOW+1,y

	fxs FX_MEMS #$00
end;


procedure SetPlayfieldPalette(a: byte); register; assembler;
asm
	fxs FX_MEMS #$80+MAIN.SYSTEM.VBXE_XDLADR/$1000

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
end;


procedure SetOverlayPalette(a: byte); register; assembler;
asm
	fxs FX_MEMS #$80+MAIN.SYSTEM.VBXE_XDLADR/$1000

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
end;


procedure SetColorMapDimensions(w,h: byte); register; assembler;
asm
	fxs FX_MEMS #$80+MAIN.SYSTEM.VBXE_XDLADR/$1000

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
end;


procedure SetRGBPalette(pal: byte); assembler; register; overload;
asm
	fxs FX_PSEL, pal	; select Palette
	fxs FX_CSEL, #0		; select Color
end;


procedure SetRGBPalette(pal, cnt: byte); assembler; register; overload;
asm
	fxs FX_PSEL, pal	; select Palette
	fxs FX_CSEL, cnt	; select Color
end;


procedure SetRGBPalette(cnt: byte; r,g,b: byte); assembler; overload;
asm
	fxs FX_CSEL, cnt

	lda r
	fxsa FX_CR

	lda g
	fxsa FX_CG

	lda b
	fxsa FX_CB
end;


procedure SetRGBPalette(r,g,b: byte); assembler; register; overload;
asm
	lda r
	fxsa FX_CR

	lda g
	fxsa FX_CG

	lda b
	fxsa FX_CB
end;


procedure SetRGBPalette(c: cardinal); assembler; register; overload;
asm
	lda c+2
	fxsa FX_CR

	lda c+1
	fxsa FX_CG

	lda c
	fxsa FX_CB
end;


procedure SetRGBPalette(cnt:byte; c: cardinal); assembler; register; overload;
asm
	fxs FX_CSEL, cnt

	lda c+2
	fxsa FX_CR

	lda c+1
	fxsa FX_CG

	lda c
	fxsa FX_CB
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


procedure CloseGraph; assembler;
(*
@description:

*)
asm

//	m@call warmsv

end;
