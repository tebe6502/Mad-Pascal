
var	WIN_LEFT: smallint = 0;
	WIN_RIGHT: smallint = 39;
	WIN_TOP: smallint = 0;
	WIN_BOTTOM: smallint = 23;


	procedure SetColorMapEntry; overload; assembler;
	procedure SetColorMapEntry(a,b,c: byte); overload; register; assembler;
	procedure SetColorMapDimensions(w,h: byte); register; assembler;
	procedure SetCurrentPaletteEntry(nr: word); register;
	procedure SetPaletteEntry(nr: word; r,g,b: byte); register; overload;
	procedure SetPaletteEntry(r,g,b: byte); register; overload;
	procedure SetRGBPalette(pal: byte); assembler; register; overload;
	procedure SetRGBPalette(pal, cnt: byte); assembler; register; overload;
	procedure SetRGBPalette(cnt: byte; r,g,b: byte); assembler; overload;
	procedure SetRGBPalette(r,g,b: byte); assembler; register; overload;
	procedure SetRGBPalette(c: cardinal); assembler; register; overload;
	procedure SetRGBPalette(cnt:byte; c: cardinal); assembler; register; overload;
	procedure SetPlayfieldPalette(a: byte); register; assembler;
	procedure SetOverlayPalette(a: byte); register; assembler;

	procedure SetDisplayBuffer(var a: TDisplayBuffer);
	procedure SetActiveBuffer(var a: TDisplayBuffer);
	function Scanline(y: smallint): PByte;
	function NewDisplayBuffer(var a: TDisplayBuffer; mode, bound: byte): TDisplayBuffer;
	procedure SwitchDisplayBuffer(var a,b: TDisplayBuffer);
