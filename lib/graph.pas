unit graph;

{

http://www.freepascal.org/docs-html/rtl/graph/index-5.html


GetColor
GetPixel
InitGraph
Line
MoveTo
LineTo
PutPixel
SetBkColor
SetColor

}


interface

uses	types;

	{$i graphh.inc}

	function GetColor: byte; assembler;
	procedure LineTo(x, y: smallint); assembler;
	procedure PutPixel(x,y: smallint); assembler; overload;
	procedure PutPixel(x,y: smallint; color: byte); overload;


implementation

var
	CurrentX, CurrentY: word;

(*
	TheFillSettings : FillSettingsType;


procedure SetFillStyle(pattern, color: byte);
//----------------------------------------------------------------------------------------------
// Set drawing fill style
//----------------------------------------------------------------------------------------------
begin
	TheFillSettings.pattern := pattern;
	TheFillSettings.color	:= color;
end;
*)

procedure InitGraph(mode: byte); overload;
//----------------------------------------------------------------------------------------------
// init graphics mode
//----------------------------------------------------------------------------------------------
var window: byte;
begin

	GraphResult := 0;

	window := mode and $10;

	ScreenMode := mode;

	mode := mode and $0f;

	ScreenHeight := 192;

	case mode of
	0,3:	begin ScreenWidth := 40; ScreenHeight := 24 end;
	5:	begin ScreenWidth := 80; ScreenHeight := 48 end;
	7:	begin ScreenWidth := 160; ScreenHeight := 96 end;
	8:	ScreenWidth := 320;
	9..11:	ScreenWidth := 80;
	15:	ScreenWidth := 160

	else
		GraphResult := 128;
	end;

asm
{	txa:pha

	mva #$2c @putchar.vbxe

	ldy mode

	ldx #$60	; 6*16
	lda window	; %00010000 with text window
	eor #$10
	ora #2		; read

	.nowarn @graphics

	pla:tax
};
end;


procedure SetBkColor(color: byte); assembler;
//----------------------------------------------------------------------------------------------
// Sets the background color to Color
//----------------------------------------------------------------------------------------------
asm
{	mva color colbaks
};
end;


function GetColor: byte; assembler;
//----------------------------------------------------------------------------------------------
// Return current drawing color
//----------------------------------------------------------------------------------------------
asm
{	mva @COMMAND.colscr Result
};
end;


procedure SetColor(color: byte); assembler;
//----------------------------------------------------------------------------------------------
// Sets the foreground color to Color
//----------------------------------------------------------------------------------------------
asm
{	mva color @COMMAND.colscr
};
end;


procedure PutPixel(x,y: smallint); assembler; overload;
//----------------------------------------------------------------------------------------------
// Puts a point at (X,Y) using color Color
//----------------------------------------------------------------------------------------------
asm
{	txa:pha

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
//----------------------------------------------------------------------------------------------
// Puts a point at (X,Y) using color Color
//----------------------------------------------------------------------------------------------
begin

asm
{	mva color @COMMAND.colscr
};
	PutPixel(x,y);
end;


function GetPixel(x,y: smallint): byte; assembler;
//----------------------------------------------------------------------------------------------
// Return color of pixel
//----------------------------------------------------------------------------------------------
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
//----------------------------------------------------------------------------------------------
// Draw a line starting from current position to a given point
//----------------------------------------------------------------------------------------------
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
//----------------------------------------------------------------------------------------------
// Draw a line between 2 points
//----------------------------------------------------------------------------------------------
var x, y: smallint;
begin
	x:=CurrentX;
	y:=CurrentY;

	MoveTo(x1,y1);
	LineTo(x2,y2);

	CurrentX:=x;
	CurrentY:=y;
end;


procedure fLine(x0, y0, x1, y1: smallint);
//----------------------------------------------------------------------------------------------
// Draw a line between 2 points
//----------------------------------------------------------------------------------------------
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


{$i vbxe.inc}
{$i graph.inc}

end.
