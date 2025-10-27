unit graph;
(*
@type: unit
@name: Unit to handle screen graphics
@author: Tomasz Biela (Tebe)

@description:
<http://www.freepascal.org/docs-html/rtl/graph/index-5.html>
*)


{

GetColor
GetPixel
HLine
InitGraph
Line
MoveTo
LineTo
MoveTo
PutPixel
SetBkColor
SetColor

Arc
Bar
Bar3D
calcRegCode
Circle
ClipLine
DisplayBuffer
DrawPoly
FrameBuffer
GetMaxColor
GetMaxX
GetMaxY
GetX
GetY
Ellipse
FillCircle
FillEllipse
FillPoly
FillRect
FloodFill
FloodFillH
MoveRel
NewBuffer
PieSlice
Rectangle
SetArcCoords
SetClipRect
SwitchBuffer

}


interface

{$IFDEF ATARI}
uses types, atari;
{$ELSE}
uses types;
{$ENDIF}


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

var
	GraphResult: byte;

	GetColor: byte;

	VideoRAM: pointer;

	LastArcCoords: TLastArcCoords;


{$i './targets/graphh.inc'}


	procedure Arc(X, Y, StAngle, EndAngle, Radius: Word);
	procedure Bar(x1, y1, x2, y2: Smallint);
	procedure Bar3D(x1, y1, x2, y2 : smallint;depth : word;top : boolean);
	procedure Circle(x, y, r: word);
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

	procedure fLine(x0, y0, x1, y1: smallint);
	procedure HLine(x1,x2, y: smallint);
	procedure LineTo(x, y: smallint);
	procedure LineRel(dx, dy: smallint);
	procedure PutPixel(x,y: smallint); assembler; overload;
	procedure PutPixel(x,y: smallint; color: byte); overload;
	function Scanline(y: smallint): PByte;


implementation

var
	Scanline_Width: byte;

	CurrentX, CurrentY: word;


function Scanline(y: smallint): PByte;
(*
@description:
ScanLine give access to memory starting point for each row raw data.
*)
var i: byte;
    a: word;
begin

 i:=y;

 if y < 0 then i:=0 else
  if y > ScreenHeight then i:=ScreenHeight-1;

 if Scanline_Width <> 40 then
  a:=i * Scanline_Width
 else begin
  a:=i shl 3;
  a:=a + a shl 2;
 end;

 Result:=pointer(VideoRam + a);

end;


{$i './targets/graph.inc'}


procedure MoveTo(x, y: smallint); assembler;
(*
@description:
Move cursor to absolute position.
*)
asm
	lda y+1
	bpl _0

	lda #0
	sta y
	sta y+1
_0
	lda x+1
	bpl _1

	lda #0
	sta x
	sta x+1
_1
	cpw y main.system.ScreenHeight
	bcc _2

	lda main.system.ScreenHeight
	ldy main.system.ScreenHeight+1
	sbc #1
	scs
	dey
	sta y
	sty y+1
_2
	cpw x main.system.ScreenWidth
	bcc _3

	lda main.system.ScreenWidth
	ldy main.system.ScreenWidth+1
	sbc #1
	scs
	dey
	sta x
	sty x+1
_3
	mwa x CurrentX
	mwa y CurrentY
end;


procedure Line(x1, y1, x2, y2: smallint); overload;
(*
@description:
Draw a line between 2 points
*)
var x, y: smallint;
begin
	x:=CurrentX;
	y:=CurrentY;

	MoveTo(x1,y1);
	LineTo(x2,y2);

	CurrentX:=x;
	CurrentY:=y;
end;


procedure Line(x1, y1, x2, y2: float16); overload;
(*
@description:
Draw a line between 2 points
*)
var x, y, a, b: smallint;
begin
	x:=CurrentX;
	y:=CurrentY;

	a:=round(x1);
	b:=round(y1);

	MoveTo(a,b);

	a:=round(x2);
	b:=round(y2);

	LineTo(a,b);

	CurrentX:=x;
	CurrentY:=y;
end;


procedure Line(x1, y1, x2, y2: real); overload;
(*
@description:
Draw a line between 2 points
*)
var x, y, a, b: smallint;
begin
	x:=CurrentX;
	y:=CurrentY;

	a:=round(x1);
	b:=round(y1);

	MoveTo(a,b);

	a:=round(x2);
	b:=round(y2);

	LineTo(a,b);

	CurrentX:=x;
	CurrentY:=y;
end;


procedure HLine(x1,x2,y: smallint);
(*
@description:
Draw horizontal line between 2 points
*)
begin

 Line(x1,y,x2,y);

end;


procedure fLine(x0, y0, x1, y1: smallint);
(*
@description:
Draw a line between 2 points
*)
begin

 Line(x0,y0,x1,y1);

end;


(*
procedure FloodFill(x1, y1: Smallint; color: byte); assembler;
asm
{	txa:pha

	mva color fildat

	mwa x1 colcrs
	mva y1 rowcrs

	inw colcrs
	inc y1

	lda #@IDfill

	jsr @COMMAND

	pla:tax
};
end;
*)


{$i graph.inc}


end.
