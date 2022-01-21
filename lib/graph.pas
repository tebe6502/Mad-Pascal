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
PutPixel
SetBkColor
SetColor

}


interface

{$ifdef atari}
uses types, atari;
{$endif}

{$ifdef c64}
uses types, c64;
{$endif}

	{$i graphh.inc}

	procedure SetDisplayBuffer(var a: TDisplayBuffer);
	procedure fLine(x0, y0, x1, y1: smallint);
	procedure SetActiveBuffer(var a: TDisplayBuffer);
	procedure HLine(x1,x2, y: smallint);
	procedure LineTo(x, y: smallint);
	procedure PutPixel(x,y: smallint); assembler; overload;
	procedure PutPixel(x,y: smallint; color: byte); overload;
	function Scanline(y: smallint): PByte;
	function NewDisplayBuffer(var a: TDisplayBuffer; mode, bound: byte): TDisplayBuffer;
	procedure SwitchDisplayBuffer(var a,b: TDisplayBuffer);

implementation

var
	Scanline_Width: byte;

	CurrentX, CurrentY: word;


{$i graph2.inc}


{$i '../src/targets/graph.inc'}


procedure Line(x1, y1, x2, y2: smallint);
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
  if y >= ScreenHeight then i:=ScreenHeight-1;

 if Scanline_Width <> 40 then
  a:=i * Scanline_Width
 else begin
  a:=i shl 3;
  a:=a + a shl 2;
 end;

 Result:=pointer(VideoRam + a);

end;


{$ifdef atari}
	{$i vbxe.inc}
{$endif}

{$i graph.inc}

end.
