(*
type
	FillSettingsType =
	record
		pattern, color : byte;
	end;
*)

const
	{ graphic drivers }
	D1bit	= 11;
	D2bit	= 12;
	D4bit	= 13;
	D6bit	= 14;		// 64 colors Half-brite mode - Amiga
	D8bit	= 15;
	D12bit	= 16;		// 4096 color modes HAM mode - Amiga

	m640x480 = 8 + 16;

	{ error codes }
	grOK		= 0;
	grNoInitGraph	= -1;
	grNotDetected	= -2;
	grFileNotFound	= -3;
	grInvalidDriver	= -4;
	grNoLoadMem	= -5;
	grNoScanMem	= -6;
	grNoFloodMem	= -7;
	grFontNotFound	= -8;
	grNoFontMem	= -9;
	grInvalidMode	= -10;
	grError		= -11;
	grIOerror	= -12;
	grInvalidFont	= -13;
	grInvalidFontNum= -14;
	grInvalidVersion= -18;

(*
	{ fill pattern for Get/SetFillStyle: }
	EmptyFill	= 0;	// Uses backgroundcolor
	SolidFill	= 1;	// Uses filling color
	LineFill	= 2;	// Fills with horizontal lines
	ltSlashFill	= 3;	// Fills with lines from left-under to top-right
	SlashFill	= 4;	// Idem as previous, thick lines
	BkSlashFill	= 5;	// Fills with thick lines from left-Top to bottom-right
	LtBkSlashFill	= 6;	// Idem as previous, normal lines
	HatchFill	= 7;	// Fills with a hatch-like pattern
	XHatchFill	= 8;	// Fills with a hatch pattern, rotated 45 degrees
	InterLeaveFill	= 9;	// Interleaving lines
	WideDotFill	= 10;	// Widely spaced dotted lines
	CloseDotFill	= 11;	// Fills with dots, narrow spacing
	UserFill	= 12;	// Fills with a user-defined pattern
*)

var	WIN_LEFT: smallint = 0;
	WIN_RIGHT: smallint = 160-1;
	WIN_TOP: smallint = 0;
	WIN_BOTTOM: smallint = 192-1;

	GraphResult: byte;


	procedure Bar(x1, y1, x2, y2: Smallint);
	procedure Bar3D(x1, y1, x2, y2 : smallint;depth : word;top : boolean);
	procedure Circle(x0,y0,radius: word);
	procedure ClipLine(x1, y1, x2, y2: smallint);
	procedure Ellipse(x0, y0, a, b: word);
	procedure FillEllipse(x0, y0, a, b: word);
	procedure FillRect(Rect: TRect);
	procedure FloodFill(a,b: smallint; newcolor: byte);
	function GetMaxX: word;
	function GetMaxY: word;
	function GetX: smallint;
	function GetY: smallint;
	function GetPixel(x,y: smallint): byte; assembler;
	procedure InitGraph(mode: byte); overload;
	procedure InitGraph(driver, mode: byte; pth: TString); overload;
	procedure Line(x1,y1,x2,y2: smallint);
	procedure MoveRel(Dx, Dy: smallint);
	procedure MoveTo(x, y: smallint); assembler;
	procedure Rectangle(x1, y1, x2, y2: Smallint); overload;
	procedure Rectangle(Rect: TRect); overload;
	procedure SetBkColor(color: byte); assembler;
	procedure SetClipRect(x0,y0,x1,y1: smallint); overload;
	procedure SetClipRect(Rect: TRect); overload;
	procedure SetColor(color: byte); assembler;
	procedure SetColorMapEntry; overload; assembler;
	procedure SetColorMapEntry(a,b,c: byte); overload; register; assembler;
	procedure SetColorMapDimensions(w,h: byte); register; assembler;
	procedure SetCurrentPaletteEntry(nr: word); register;
//	procedure SetFillStyle(pattern, color: byte);
	procedure SetPaletteEntry(nr: word; r,g,b: byte); register; overload;
	procedure SetPaletteEntry(r,g,b: byte); register; overload;
	procedure SetRGBPalette(nr: word); assembler; register; overload;
	procedure SetRGBPalette(nr: word; r,g,b: byte); assembler; overload;
	procedure SetRGBPalette(r,g,b: byte); assembler; register; overload;

