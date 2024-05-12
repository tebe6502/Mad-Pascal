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


{$i '../src/targets/graphh.inc'}


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
	procedure PutPixel(x,y: smallint); assembler; overload;
	procedure PutPixel(x,y: smallint; color: byte); overload;


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


{$i '../src/targets/graph.inc'}


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

	sbw main.system.ScreenHeight #1 y
_2
	cpw x main.system.ScreenWidth
	bcc _3

	sbw main.system.ScreenWidth #1 x
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


{$ifdef atari}
	{$i vbxe.inc}
{$endif}


function GetX: smallint;
(*
@description:
GetX returns the X-coordinate of the current position of the graphical pointer
*)
begin

 Result := CurrentX;

end;


function GetY: smallint;
(*
@description:
GetY returns the Y-coordinate of the current position of the graphical pointer
*)
begin

 Result := CurrentY;

end;


procedure MoveRel(Dx, Dy: smallint);
(*
@description:
MoveRel moves the pointer to the point (DX,DY), relative to the current pointer position
*)
begin
     CurrentX := CurrentX + Dx;
     CurrentY := CurrentY + Dy;
end;


function GetMaxColor: word;
(*
@description:
GetMaxColor returns the maximum color-number which can be set with SetColor.
*)
begin

 Result:=4;

end;


function GetMaxX: word;
(*
@description:
GetMaxX returns the maximum horizontal screen length.
*)
begin

 Result := ScreenWidth;

end;


function GetMaxY: word;
(*
@description:
GetMaxY returns the maximum number of screen lines.
*)
begin

 Result := ScreenHeight;

end;


procedure Circle(x,y, r: word);
(*
@description:

 https://atariwiki.org/wiki/Wiki.jsp?page=Super%20fast%20circle%20routine

 REM *******************************
 REM PROGRAM  : FAST CIRCLE DRAWING
 REM AUTHOR   : ZLATKO BLEHA
 REM PUBLISHER: MOJ MIKRO MAGAZINE
 REM ISSUE NO.: 1989, NO.3, PAGE 29
 REM *******************************

*)
var a: smallint;
    b, c: byte;
begin

 if r = 0 then exit;

 b:=r;
 a:=r-1;
 c:=0;

while (b >= c) do begin

 while (a >= 0) and (b >= c) do begin

  PutPixel(x+C,Y+B);
  PutPixel(x+C,Y-B);
  PutPixel(x-C,Y-B);
  PutPixel(x-C,Y+B);
  PutPixel(x+B,Y+C);
  PutPixel(x+B,Y-C);
  PutPixel(x-B,Y-C);
  PutPixel(x-B,Y+C);

  inc(c);

  inc(a);
  dec(a, c);
  dec(a, c);

 end;

 dec(b);

 inc(a, b);
 inc(a, b);

end;

end;



(*
procedure Circle(x0, y0, radius: word);
var	x,y, dx,dy, txp, typ, txm, tym, d: word;

	procedure DrawCircle;
	begin
		PutPixel( txp, typ);
		PutPixel( txp, tym);
		PutPixel( txm, typ);
		PutPixel( txm, tym);
	end;

begin
	if radius = 0 then exit;

	x := 0;
	dx := 0;

	y := radius;
	dy := y shl 2;

	d := 3 - (radius shl 1);			// Decision criterion

	while (x <= y) do begin

		if d and $8000 = 0 then begin		// if d >= 0

			d := 4 + d - dy;

			dec(dy, 4);

			dec(y);
		end;

		txp := x0+x;  typ := y0+y;
		txm := x0-x;  tym := y0-y;

		DrawCircle;

		txp := x0+y;  typ := y0+x;
		txm := x0-y;  tym := y0-x;

		DrawCircle;

		d := 6 + d + dx;

		inc(dx, 4);

		inc(x);
	end;

end;
*)


procedure FillCircle(x0, y0, radius: word);
(*
@description:
Bresenham filled Circle with center (X0,Y0) and radius RADIUS.

https://github.com/tuupola/hagl/blob/master/src/hagl_circle.c
*)
var	x, y, d: word;

begin
	if radius = 0 then exit;

	x := 0;
	y := radius;
	d := 3 - radius shl 1;

	while y >= x do begin

	 HLine(x0 - x, x0 + x, y0 + y);
	 HLine(x0 - x, x0 + x, y0 - y);

	 HLine(x0 - y, x0 + y, y0 + x);
	 HLine(x0 - y, x0 + y, y0 - x);

	 if d and $8000 = 0 then begin		// if d >= 0
	  d := d + 10 + (x - y) shl 2;
	  dec(y);
	 end else
	  d := d + 6 + x shl 2;

	 inc(x);

	end;

end;


procedure SetArcCoords (x,y,xradius,yradius,StAngle,EndAngle : word);
(*
@description:

*)
var a,s: single;
begin
  LastArcCoords.X:=X;
  LastArccOords.y:=y;

  a:=StAngle*D_PI_180;
  s:=xradius*cos(a); Lastarccoords.xstart:=x+round(s);
  s:=yradius*sin(a); Lastarccoords.ystart:=y-round(s);

  a:=EndAngle*D_PI_180;
  s:=xradius*cos(a); LastArccoords.xend:=x+round(s);
  s:=yradius*sin(a); LastArccoords.yend:=y-round(s);
end;


procedure Arc(X, Y, StAngle, EndAngle, Radius: Word);
(*
@description:
Arc draws part of a circle with center at (X,Y), radius Radius, starting from StAngle, stopping at EndAngle. These angles are measured counterclockwise.
*)
var i : word;
    tmpAng : single;
    curX, curY: smallint;
begin

 if StAngle > EndAngle then begin
  i:=StAngle;
  StAngle:=EndAngle;
  EndAngle:=i;
 end;

 SetArcCoords (X,Y,radius,radius,StAngle,EndAngle);

 tmpAng:=StAngle * D_PI_180;

 For i:= StAngle To EndAngle Do
  Begin
   curX:= X + Round (Radius*Cos (tmpAng));
   curY:= Y - Round (Radius*Sin (tmpAng));
   PutPixel (curX, curY);

   tmpAng:=tmpAng+D_PI_180;
  End;
end;



procedure Ellipse(X, Y, StAngle, EndAngle, xRadius,yRadius: Word); overload;
(*
@description:
Arc draws part of a circle with center at (X,Y), radius Radius, starting from StAngle, stopping at EndAngle. These angles are measured counterclockwise.
*)
var i : word;
    tmpAng : single;
    curX, curY: smallint;
begin

 if StAngle > EndAngle then begin
  i:=StAngle;
  StAngle:=EndAngle;
  EndAngle:=i;
 end;

 SetArcCoords (X,Y,xRadius,yRadius,StAngle,EndAngle);

 MoveTo(LastArcCoords.xstart, LastArcCoords.ystart);

 tmpAng:=StAngle * D_PI_180;

 For i:= StAngle To EndAngle Do
  Begin
   curX:= X + Round (xRadius*Cos (tmpAng));
   curY:= Y - Round (yRadius*Sin (tmpAng));

   LineTo (curX, curY);

   tmpAng:=tmpAng+D_PI_180;
  End;
end;


procedure PieSlice(X, Y, StAngle, EndAngle, Radius: Word);
(*
@description:
PieSlice draws a sector of a circle with center (X,Y) and radius Radius, starting at StAngle and ending at EndAngle.
*)
var i : word;
    tmpAng : single;
    curX, curY: smallint;
begin
 Arc(X, Y, StAngle, EndAngle, Radius);

 Line(X,Y,LastArcCoords.xstart,LastArcCoords.ystart);
 Line(X,Y,LastArcCoords.xend,LastArcCoords.yend);
end;


procedure Ellipse(x0, y0, a, b: word); overload;
(*
@description:
Bresenham Ellipse with center (X0,Y0) and horizontal radius A, vertical radius B.
*)
var	error: integer register;
	stopx, stopy: integer;
	x, y: word;
	a2, b2, _a, _b: cardinal;

	procedure DrawEllipse;
	var txp, typ, txm, tym: word;
	begin
		txp := x0 + x;	typ := y0 + y;
		txm := x0 - x;	tym := y0 - y;

		PutPixel(txp, typ);
		PutPixel(txm, typ);
		PutPixel(txm, tym);
		PutPixel(txp, tym);
	end;

begin
			if (a = 0) or (b = 0) then exit;

			_a := a * a;
			a2 := _a shl 1;

			_b := b * b;
			b2 := _b shl 1;

			y := b;
			x := 0;
			stopy := 0;

			error := _a * b;
			stopx := error shl 1;

			while (stopy <= stopx) do begin

				DrawEllipse;

				inc(x);
				stopy := stopy + b2;
				error := error - stopy;

				if (error < 0) then begin
					dec(y);
					stopx := stopx - a2;
					error := error + stopx;
				end;
			end;

			x := a;
			y := 0;
			stopx := 0;

			error := _b * a;
			stopy := error shl 1;

			while (stopy >= stopx) do begin

				DrawEllipse;

				inc(y);
				stopx := stopx + a2;
				error := error - stopx;

				if (error < 0) then begin
					dec(x);
					stopy := stopy - b2;
					error := error + stopy;
				end;
			end;
end;


procedure FillEllipse(x0, y0, a, b: word);
(*
@description:
Bresenham filled Ellipse with center (X0,Y0) and horizontal radius A, vertical radius B.
*)
var	error: integer register;
	stopx, stopy: integer;
	x, y: word;
	a2, b2, _a, _b: cardinal;

	procedure DrawEllipse;
	begin
		HLine(x0 - x, x0 + x, y0 + y);
		HLine(x0 - x, x0 + x, y0 - y);
	end;

begin
			if (a = 0) or (b = 0) then exit;

			_a := a * a;
			a2 := _a shl 1;

			_b := b * b;
			b2 := _b shl 1;

			y := b;
			x := 0;
			stopy := 0;

			error := _a * b;
			stopx := error shl 1;

			while (stopy <= stopx) do begin

				DrawEllipse;

				inc(x);
				stopy := stopy + b2;
				error := error - stopy;

				if (error < 0) then begin
					dec(y);
					stopx := stopx - a2;
					error := error + stopx;
				end;
			end;

			x := a;
			y := 0;
			stopx := 0;

			error := _b * a;
			stopy := error shl 1;

			while (stopy >= stopx) do begin

				DrawEllipse;

				inc(y);
				stopx := stopx + a2;
				error := error - stopx;

				if (error < 0) then begin
					dec(x);
					stopy := stopy - b2;
					error := error + stopy;
				end;
			end;
end;


procedure Rectangle(x1, y1, x2, y2: Smallint); overload;
(*
@description:
Draws a rectangle with corners at (X1,Y1) and (X2,Y2), using the current color
*)
begin

 MoveTo(x1,y1);
 LineTo(x2,y1);
 LineTo(x2,y2);
 LineTo(x1,y2);
 LineTo(x1,y1);

end;


procedure Rectangle(Rect: TRect); overload;
(*
@description:
Draws a rectangle with corners at (X1,Y1) and (X2,Y2), using the current color
*)
begin

 MoveTo(Rect.Left, Rect.Top);
 LineTo(Rect.Right, Rect.Top);
 LineTo(Rect.Right, Rect.Bottom);
 LineTo(Rect.Left, Rect.Bottom);
 LineTo(Rect.Left, Rect.Top);

end;


procedure FloodFillH(x,y: smallint; color: byte);
(*
@description:
Horizontal flood fill
*)
var xStack: array [0..255] of word absolute $400;
    yStack: array [0..255] of byte absolute $600;
    stackEntry, sx: word;
    oldColor: byte;
    spanAbove: Boolean register;
    spanBelow: Boolean register;
    belowColor: byte register;
    aboveColor: byte register;
begin
	oldColor := GetPixel(x,y);

	if (oldColor = color) then exit;

	SetColor(color);

	stackEntry := 1;

	repeat

		while (x > 0) and (GetPixel(x-1,y) = oldColor) do dec(x);

		spanAbove := false;
		spanBelow := false;

		sx := x;

		while (word(x) < word(ScreenWidth)) and (GetPixel(x,y) = oldColor) do begin

			if (byte(y) < byte(ScreenHeight-1)) then begin

				belowColor := GetPixel(x, y+1);

				if (spanBelow=false) and (belowColor = oldColor) then begin

					xStack[stackEntry]  := x;
					yStack[stackEntry]  := y+1;
					inc(stackEntry);

					if stackEntry > High(xStack) then exit;

					spanBelow := true;
				end
				else if (spanBelow) and (belowColor <> oldColor) then
					spanBelow := false;
			end;

			if (byte(y) > 0) then begin

				aboveColor := GetPixel(x, y-1);

				if (spanAbove=false) and (aboveColor = oldColor) then begin

					xStack[stackEntry]  := x;
					yStack[stackEntry]  := y-1;
					inc(stackEntry);

					if stackEntry > High(xStack) then exit;

					spanAbove := true;
				end
				else if (spanAbove) and (aboveColor <> oldColor) then
					spanAbove := false;
			end;

			inc(x);
		end;

		dec(x);

		HLine(sx,x,y);

		dec(stackEntry);
		x := xStack[stackEntry];
		y := yStack[stackEntry];

	until stackEntry=0;

end;


{
separate xStack, yStack -> code too long

procedure FloodFill(a,b: smallint; newcolor: byte);
//----------------------------------------------------------------------------------------------
// Fill an area with a given color, seed fill algorithm
//----------------------------------------------------------------------------------------------
var ir, nf: word;
    c: cardinal;
    oldcolor: byte;
    xStack, yStack: array [0..0] of smallint;


procedure FloodFillExec;
var i: byte;
    xr,yr: smallint;
    yes: Boolean;
begin

 for i:=0 to 3 do begin

  case i of

   0: begin
	xr:=a+1;
	yr:=b;

	yes:=(xr<smallint(ScreenWidth));
      end;

   1: begin
	xr:=a-1;
//	yr:=b;

	yes:=(xr>=0);
      end;

   2: begin
	xr:=a;
	yr:=b+1;

	yes:=(yr<smallint(ScreenHeight));
      end;

   3: begin
//	xr:=a;
	yr:=b-1;

	yes:=(yr>=0);
      end;

  end;


  if yes then
   if GetPixel(xr,yr) = oldcolor then begin

    PutPixel(xr, yr);

    inc(nf);

    xStack[nf] := xr;
    yStack[nf] := yr;
   end;

 end;

end;


begin

 xStack:=pointer(dpeek(560)-2048);
 yStack:=pointer(dpeek(560)-1024);

 SetColor(newcolor);

 oldcolor:=GetPixel(a,b);

 nf := 1;
 ir := 1;
 xStack[nf] := a;
 yStack[nf] := b;

 FloodFillExec;

 while nf>ir do begin

  inc(ir);

  a := xStack[ir];
  b := yStack[ir];

  FloodFillExec;

  if (nf>500) then begin

   nf := nf-ir;

   if nf>500 then exit;

   move(xStack[ir+1], xStack[1], nf shl 1);
   move(yStack[ir+1], yStack[1], nf shl 1);

//   for i := 1 to nf do fill[i] := fill[ir+i];

   ir := 0;

  end;

 end;

end;
}


procedure FloodFill(a,b: smallint; newcolor: byte);
(*
@description:
Fill an area with a given color, seed fill algorithm
*)
const
    FILLSTACKSIZE = 512;

var stackPointer: word register;
    stackEntry: word register;
    c: cardinal;
    oldcolor: byte;
    FloodFillStack: array [0..FILLSTACKSIZE-1] of cardinal;


procedure FloodFillExec;
var i: byte;
    xr,yr: smallint;
    yes: Boolean;
begin

 for i:=0 to 3 do begin

  case i of

   0: begin
	xr:=a+1;
	yr:=b;

	yes:=(xr < ScreenWidth);
      end;

   1: begin
	xr:=a-1;
//	yr:=b;

	yes:=(xr >= 0);
      end;

   2: begin
	xr:=a;
	yr:=b+1;

	yes:=(yr < ScreenHeight);
      end;

   3: begin
//	xr:=a;
	yr:=b-1;

	yes:=(yr >= 0);
      end;

  end;


  if yes then
   if GetPixel(xr,yr) = oldcolor then begin

    PutPixel(xr, yr);

    inc(stackEntry);

    FloodFillStack[stackEntry]:= word(xr) shl 16 + word(yr);

   end;

 end;

end;


begin

 SetColor(newcolor);

 oldcolor:=GetPixel(a,b);

 stackEntry := 1;
 stackPointer := 1;

 FloodFillStack[stackEntry] := word(a) shl 16 + word(b);

 FloodFillExec;

 while stackEntry > stackPointer do begin

  inc(stackPointer);

  c:=FloodFillStack[stackPointer];

  a := hi(c);
  b := lo(c);

  FloodFillExec;

  if (stackEntry > FILLSTACKSIZE shr 1) then begin

   stackEntry := stackEntry - stackPointer;

   if stackEntry > FILLSTACKSIZE shr 1 then exit;

   move(FloodFillStack[stackPointer+1], FloodFillStack[1], stackEntry * sizeof(cardinal) );

   stackPointer := 0;

  end;

 end;

end;


procedure Bar(x1, y1, x2, y2: Smallint);
(*
@description:
Draw filled rectangle
*)
var i: smallint;
begin

 for i:=y1 to y2 do HLine(x1,x2, i);

end;


procedure FillRect(Rect: TRect);
(*
@description:
Draw filled rectangle
*)
var i: smallint;
begin

 NormalizeRect(Rect);

 for i:=Rect.Top to Rect.Bottom do HLine(Rect.Left, Rect.Right, i);

end;


procedure Bar3D(x1, y1, x2, y2 : smallint;depth : word;top : boolean);
(*
@description:
Draw filled 3-dimensional rectangle
*)
var
 origwritemode : smallint;
 OldX, OldY : smallint;
begin

  if x1 > x2 then
  begin
    OldX := x1;
    x1 := x2;
    x2 := OldX;
  end;
  if y1 > y2 then
  begin
    OldY := y1;
    y1 := y2;
    y2 := OldY;
  end;

  Bar(x1,y1,x2,y2);
  Rectangle(x1,y1,x2,y2);

  { Current CP should not be updated in Bar3D }
  { therefore save it and then restore it on  }
  { exit.                                     }
  OldX := CurrentX;
  OldY := CurrentY;

  if top then begin
    Moveto(x1,y1);
    Lineto(x1+depth,y1-depth);
    Lineto(x2+depth,y1-depth);
    Lineto(x2,y1);
  end;
  if Depth <> 0 then
    Begin
      Moveto(x2+depth,y1-depth);
      Lineto(x2+depth,y2-depth);
      Lineto(x2,y2);
    end;
  { restore CP }
  CurrentX := OldX;
  CurrentY := OldY;
end;


procedure SetClipRect(x0,y0,x1,y1: smallint); overload;
begin
	WIN_LEFT := x0;
	WIN_RIGHT := x1;
	WIN_TOP := y0;
	WIN_BOTTOM := y1;
end;


procedure SetClipRect(Rect: TRect); overload;
begin
	WIN_LEFT := Rect.Left;
	WIN_RIGHT := Rect.Right;
	WIN_TOP := Rect.Top;
	WIN_BOTTOM := Rect.Bottom;
end;


function calcRegCode(x, y: smallint): byte;
begin
   result := 0;

   if (x < WIN_LEFT)   then result := (result or 1);
   if (x > WIN_RIGHT)  then result := (result or 2);
   if (y > WIN_BOTTOM) then result := (result or 4);
   if (y < WIN_TOP)    then result := (result or 8);
end;


procedure ClipLine(x1, y1, x2, y2: smallint);
(*
@description:
Line clipping (Cohen-Sutherland algorithm)
*)
var
   rcode1, rcode2, rcode: byte;
   x, y: smallint;
begin

   // Algorytm Cohena-Sutherlanda
   // 1. Zakoduj końce odcinka zgodnie z kodami obszarów
   rcode1 := calcRegCode(x1, y1);
   rcode2 := calcRegCode(x2, y2);
   // 2. Jeżeli iloczyn logiczny (AND) tych kodów <>0,
   // to odcinek może być pominięty (w całości poza
   // oknem) - zaznacz go na czerwono
//   if ((rcode1 and rcode2) <> 0) then
//   begin
//      Image1.Canvas.Pen.Color := clRed;
//      Image1.Canvas.MoveTo(x1, y1);
//      Image1.Canvas.LineTo(x2, y2);
//   end
   // 3. Jeżeli suma logiczna (OR)tych kodów = 0,
   // to odcinek w całości mieści się w okienku
   // - zaznacz go na zielono
//   else
   if ((rcode1 or rcode2) = 0) then
   begin
//      Image1.Canvas.Pen.Color := clGreen;
      fLine(x1, y1, x2, y2);
   end
   else
   begin
      // pozostale przypadki - przeciecie z krawedzia okna
      repeat
         if (rcode1 <> 0) then
            rcode := rcode1
         else
            rcode := rcode2;

         // pozostale przypadki - przeciecie z krawedzia okna
         if (rcode and 1) <> 0 then
         begin
            y := y1+smallint(smallint(y2-y1)*smallint(WIN_LEFT-x1)) div smallint(x2-x1);
            x := WIN_LEFT;
         end
         else if (rcode and 2) <> 0 then
         begin
            y := y1+smallint(smallint(y2-y1)*smallint(WIN_RIGHT-x1)) div smallint(x2-x1);
            x := WIN_RIGHT;
         end
         else if (rcode and 4) <> 0 then
         begin
            x := x1+smallint(smallint(x2-x1)*smallint(WIN_BOTTOM-y1)) div smallint(y2-y1);
            y := WIN_BOTTOM;
         end
         else if (rcode and 8) <> 0 then
         begin
            x := x1+smallint(smallint(x2-x1)*smallint(WIN_TOP-y1)) div smallint(y2-y1);
            y := WIN_TOP;
         end;

         if (rcode = rcode1) then
         begin
//            Image1.Canvas.Pen.Color := clYellow;
//            Image1.Canvas.MoveTo(x1, y1);
//            Image1.Canvas.LineTo(x, y);
            x1 := x;
            y1 := y;
            rcode1 := calcRegCode(x1, y1);
         end
         else
         begin
//            Image1.Canvas.Pen.Color := clYellow;
//            Image1.Canvas.MoveTo(x2, y2);
//            Image1.Canvas.LineTo(x, y);
            x2 := x;
            y2 := y;
            rcode2 := calcRegCode(x2, y2);
         end;
      until (((rcode1 and rcode2) <> 0) or ((rcode1 or rcode2) = 0));

      if ((rcode1 or rcode2) = 0) then
      begin
//         Image1.Canvas.Pen.Color := clBlue;
         fLine(x1, y1, x2, y2);
      end
//      else
//      begin
//         Image1.Canvas.Pen.Color := clYellow;
//         Image1.Canvas.MoveTo(x1, y1);
//         Image1.Canvas.LineTo(x2, y2);
//      end;
   end;
end;


procedure DrawPoly(amount: byte; var vertices);
(*
@description:
Draw polygon
*)
var i: byte;
    P, Q: PWord;
begin
  
 if amount < 2 then exit;

 P:=@vertices;
 Q:=@vertices;

 for i:=amount-2 downto 0 do begin
  
  ClipLine(P[0], P[1], P[2], P[3]);

  inc(P, 2);
 end;

 ClipLine(Q[0], Q[1], P[0], P[1]); 

end;


procedure FillPoly(amount: byte; var vertices);
(*
@description:
Fill polygon

Adapted from  http://alienryderflex.com/polygon_fill/

https://github.com/tuupola/hagl/blob/master/src/hagl_polygon.c
*)
var P, Q: PWord;

    i: byte register;
    j: byte register;
    k: byte register;
    y: byte register;
    miny: byte register;
    maxy: byte register;

    count: byte;// register;

    swap: word;
    
    x0, x1: word;
    
    y0, y1: byte;
        
    [striped] nodes: array [0..63] of word;
begin

 if amount < 2 then exit;

 miny := 255;
 maxy := 0;

 k := amount - 1;
	
 P:=@vertices;

 for i := k downto 0 do begin
 
   swap := P[1];

   if (miny > swap) then miny := swap;

   if (maxy < swap) then maxy := swap;

   inc(P, 2);

 end;

 // Loop through the rows of the image.
    for y := miny to maxy-1 do begin

        // Build a list of nodes.
        count := 0;

	P:=@vertices;
	Q:=@vertices + k shl 2;

        for i := k downto 0 do begin

            x0 := P[0];
            y0 := P[1];

            x1 := Q[0];
            y1 := Q[1];

            if ( ((y0 < y) and (y1 >= y)) or ((y1 < y) and (y0 >= y)) ) then begin

                nodes[count] := x0 + trunc((y - y0) / (y1 - y0) * (x1 - x0));

                inc(count);
            end;

	    Q:=P;

	    inc(P, 2);
	end;

 // Sort the nodes, via a simple 'Bubble' sort.
     if count > 0 then begin
     
	j := count - 1;
        i := 0;
	
        while (i < j) do begin

            if (nodes[i] > nodes[i + 1]) then begin

                swap := nodes[i];
                nodes[i] := nodes[i + 1];
                nodes[i + 1] := swap;

                if i<>0 then dec(i);

            end else
             inc(i);

        end;
	
     end;


 // Draw lines between nodes.
	i:=0;
        while i < count do begin

	    Hline(nodes[i], nodes[i + 1], y);

	    inc(i, 2);
        end;

    end;

end;

end.
