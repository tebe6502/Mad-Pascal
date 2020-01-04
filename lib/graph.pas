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

uses	types, atari;

	{$i graphh.inc}

	procedure DisplayBuffer(var a: TFrameBuffer);
	procedure fLine(x0, y0, x1, y1: smallint);
	procedure FrameBuffer(var a: TFrameBuffer);
	procedure HLine(x1,x2, y: smallint); 
	procedure LineTo(x, y: smallint); assembler;
	procedure PutPixel(x,y: smallint); assembler; overload;
	procedure PutPixel(x,y: smallint; color: byte); overload;
	function Scanline(y: smallint): PByte;
	function SetBuffer(var a: TFrameBuffer; mode, bound: byte): TFrameBuffer;
	procedure SwitchBuffer(var a,b: TFrameBuffer);

implementation

var
	CurrentX, CurrentY, VideoRam: word;
	
	Scanline_Width: byte;


procedure FrameBuffer(var a: TFrameBuffer);
(*
@description:

*)
begin

 VideoRam := a.bp;
 savmsc := VideoRam;

end;


procedure InitGraph(mode: byte); overload;
(*
@description:
Init graphics mode
*)
begin

	GraphResult := 0;

	ScreenMode := mode;
	
asm	
{
	txa:pha

	mva #$2c @putchar.vbxe

	lda mode
	and #$0f
	tay

	ldx #$60	; 6*16
	lda mode	; %00010000 with text window
	and #$10
	eor #$10
	ora #2		; read

	.nowarn @graphics
	
	
tlshc	equ $ee6d

	ldx dindex
	ldy tlshc,x
	lda #5
shift	asl @
	dey
	bne shift

	sta SCANLINE_WIDTH
	

; Fox/TQA

dindex	equ $57
tmccn	equ $ee7d
tmrcn	equ $ee8d

	ldx dindex
	lda tmccn,x
	ldy tmrcn,x
	ldx #0
	cmp #<320
	sne:inx
    
; X:A = horizontal resolution
; Y = vertical resolution

	sta MAIN.SYSTEM.ScreenWidth
	stx MAIN.SYSTEM.ScreenWidth+1
	
	sub #1
	sta WIN_RIGHT
	txa
	sbc #0
	sta WIN_RIGHT+1
	
	sty MAIN.SYSTEM.ScreenHeight
	lda #0
	sta MAIN.SYSTEM.ScreenHeight+1
	
	sta WIN_LEFT
	sta WIN_LEFT+1
	sta WIN_TOP
	sta WIN_TOP+1

	sta WIN_BOTTOM+1	
	dey
	sty WIN_BOTTOM

	pla:tax
};

end;


procedure SetBkColor(color: byte); assembler;
(*
@description:
Sets the background color to Color
*)
asm
{	mva color colbaks
};
end;


procedure SetColor(color: byte); assembler;
(*
@description:
Sets the foreground color to Color
*)
asm
{	mva color @COMMAND.colscr
	sta GetColor
};
end;


procedure PutPixel(x,y: smallint); assembler; overload;
(*
@description:
Puts a point at (X,Y) using color Color
*)
asm
{	txa:pha
{
	lda y+1
	bmi stop
	cmp MAIN.SYSTEM.ScreenHeight+1
	bne sk0
	lda y
	cmp MAIN.SYSTEM.ScreenHeight
sk0
	bcs stop

	lda x+1
	bmi stop
	cmp MAIN.SYSTEM.ScreenWidth+1
	bne sk1
	lda x
	cmp MAIN.SYSTEM.ScreenWidth
sk1
	bcs stop

	mwa x colcrs
	mva y rowcrs

	lda #@IDput

	jsr @COMMAND

stop	pla:tax
};
end;

procedure PutPixel(x,y: smallint; color: byte); overload;
(*
@description:
Puts a point at (X,Y) using color Color
*)
begin

asm
{	mva color @COMMAND.colscr
};
	PutPixel(x,y);
end;


function GetPixel(x,y: smallint): byte; assembler;
(*
@description:
Return color of pixel
*)
asm
{	txa:pha

	ldy #0

	lda y+1
	bmi stop
	cmp MAIN.SYSTEM.ScreenHeight+1
	bne sk0
	lda y
	cmp MAIN.SYSTEM.ScreenHeight
sk0
	bcs stop

	lda x+1
	bmi stop
	cmp MAIN.SYSTEM.ScreenWidth+1
	bne sk1
	lda x
	cmp MAIN.SYSTEM.ScreenWidth
sk1
	bcs stop

	mwa x colcrs
	mva y rowcrs

	lda #@IDget

	jsr @COMMAND
	tay

stop	sty Result

	pla:tax
};
end;


{$i graph2.inc}


procedure LineTo(x, y: smallint); assembler;
(*
@description:
Draw a line starting from current position to a given point
*)
asm
{	lda y+1
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
	txa:pha

	mwa CurrentX colcrs
	mva CurrentY rowcrs

	lda #@IDput

	jsr @COMMAND

	lda x
	sta colcrs
	sta CurrentX
	lda x+1
	sta colcrs+1
	sta CurrentX+1

	mva y rowcrs
	sta CurrentY
	lda y+1
	sta CurrentY+1

	lda #@IDdraw

	jsr @COMMAND

	pla:tax
};
end;


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

 Result:=pointer(a + VideoRam);

end;


{$i vbxe.inc}
{$i graph.inc}

end.
