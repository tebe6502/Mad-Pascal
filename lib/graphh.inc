
type
	TDisplayBuffer = record
			dl: word;
			bp: word;
			clr: procedure ();
		       end;

const

	{ graphic drivers }
	CurrentDriver	= -128;
	Detect		= 0;
	CGA		= 1;
	MCGA		= 2;
	EGA		= 3;
	EGA64		= 4;
	EGAMono		= 5;
	LowRes		= 6;	{ nickysn: used to be 1, but moved to 6, because I added CGA }
	HercMono	= 7;
	VGA		= 9;
	VESA		= 10;

	D1bit	= 11;
	D2bit	= 12;
	D4bit	= 13;
	D6bit	= 14;		// 64 colors Half-brite mode - Amiga
	D8bit	= 15;
	D12bit	= 16;		// 4096 color modes HAM mode - Amiga

	m640x400 = 8 + 16;
	m640x480 = 8 + 16;

	{ error codes }
	grOK		= 1;
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

	{ CGA Driver modes }
	CGAC0 = 0;
	CGAC1 = 1;
	CGAC2 = 2;
	CGAC3 = 3;
	CGAHi = 4;

	{ MCGA Driver modes }
	MCGAC0 = 0;
	MCGAC1 = 1;
	MCGAC2 = 2;
	MCGAC3 = 3;
	MCGAMed = 4;
	MCGAHi = 5;

	{ EGA Driver modes }
	EGALo      = 0;  { 640x200 16 color 4 page }
	EGAHi      = 1;  { 640x350 16 color 2 page }

	{ EGA64 Driver modes }
	EGA64Lo    = 0;  { 640x200 16 color 1 page }
	EGA64Hi    = 1;  { 640x350 4 color  1 page }

	{ EGAMono Driver modes }
	EGAMonoHi  = 3;  { 640x350 64K on card, 1 page; 256K on card, 2 page }

	{ VGA Driver modes }
	VGALo   = 10;		//0;
	VGAMed  = 15+16;	//1;
	VGAHi   = 8+16;		//2;

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
	WIN_RIGHT: smallint = 39;
	WIN_TOP: smallint = 0;
	WIN_BOTTOM: smallint = 23;

	GraphResult: byte;

	GetColor: byte;

	VideoRAM: pointer;

{$ifdef c64}
	ScreenRAM : pointer;
{$endif}

	LastArcCoords: TLastArcCoords;

	procedure Arc(X, Y, StAngle, EndAngle, Radius: Word);
	procedure Bar(x1, y1, x2, y2: Smallint);
	procedure Bar3D(x1, y1, x2, y2 : smallint;depth : word;top : boolean);
	procedure Circle(x0, y0, radius: word);
	procedure ClipLine(x1, y1, x2, y2: smallint);
	procedure DrawPoly(amount: byte; var vertices);
	procedure FillCircle(x0, y0, radius: word);
	procedure FillPoly(amount: byte; var vertices);
	procedure Ellipse(x0, y0, a, b: word); overload;
	procedure Ellipse(X, Y, StAngle, EndAngle, xRadius,yRadius: Word); overload;
	procedure FillEllipse(x0, y0, a, b: word);
	procedure FillRect(Rect: TRect);
	procedure FloodFill(a,b: smallint; newcolor: byte);
	procedure FloodFillH(x,y: smallint; color: byte);
	function GetMaxX: word;
	function GetMaxY: word;
	function GetX: smallint;
	function GetY: smallint;
	function GetPixel(x,y: smallint): byte; assembler;
	function GetMaxColor: word;
	procedure InitGraph(mode: byte); overload;
	procedure InitGraph(driver, mode: byte; dev: PString); overload;
	procedure Line(x1,y1,x2,y2: smallint); overload;
	procedure Line(x1, y1, x2, y2: float16); overload;
	procedure Line(x1, y1, x2, y2: real); overload;
	procedure MoveRel(Dx, Dy: smallint);
	procedure MoveTo(x, y: smallint); assembler;
	procedure PieSlice(X, Y, StAngle, EndAngle, Radius: Word);
	procedure Rectangle(x1, y1, x2, y2: Smallint); overload;
	procedure Rectangle(Rect: TRect); overload;
	procedure SetBkColor(color: byte); assembler;
	procedure SetClipRect(x0,y0,x1,y1: smallint); overload;
	procedure SetClipRect(Rect: TRect); overload;
	procedure SetColor(color: byte); assembler;
//	procedure SetFillStyle(pattern, color: byte);
	procedure CloseGraph; assembler;

{$ifdef atari}
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
{$endif}