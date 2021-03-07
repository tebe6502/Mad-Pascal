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

	procedure SetDisplayBuffer(var a: TDisplayBuffer);
	procedure fLine(x0, y0, x1, y1: smallint);
	procedure SetActiveBuffer(var a: TDisplayBuffer);
	procedure HLine(x1,x2, y: smallint);
	procedure LineTo(x, y: smallint); assembler;
	procedure PutPixel(x,y: smallint); assembler; overload;
	procedure PutPixel(x,y: smallint; color: byte); overload;
	function Scanline(y: smallint): PByte;
	function NewDisplayBuffer(var a: TDisplayBuffer; mode, bound: byte): TDisplayBuffer;
	procedure SwitchDisplayBuffer(var a,b: TDisplayBuffer);

implementation

var
	CurrentX, CurrentY, VideoRam: word;

	Scanline_Width: byte;


procedure SetActiveBuffer(var a: TDisplayBuffer);
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
const
	tlshc: array [0..15] of byte = ($03,$02,$02,$01,$01,$02,$02,$03,$03,$03,$03,$03,$03,$03,$02,$03);	// $EE6D: Table Left SHift Columns
	tmccn: array [0..15] of byte = ($28,$14,$14,$28,$50,$50,$A0,$A0,$40,$50,$50,$50,$28,$28,$A0,$A0);	// $EE7D: Table Mode Column CouNts
	tmrcn: array [0..15] of byte = ($18,$18,$0C,$18,$30,$30,$60,$60,$C0,$C0,$C0,$C0,$18,$0C,$C0,$C0);	// $EE8D: Table Mode Row CouNts

begin
asm
{
	txa:pha

	lda mode
	sta MAIN.SYSTEM.GraphMode
	and #$0f
	tay

	ldx #$60		; 6*16
	lda mode		; %00010000 with text window
	and #$10
	eor #$10
	ora #2			; read

	.nowarn @GRAPHICS

	sty GraphResult


	.ifdef MAIN.@DEFINES.ROMOFF
	inc portb
	.endif

	ldx dindex
	ldy adr.tlshc,x
	lda #5
shift	asl @
	dey
	bne shift

	sta SCANLINE_WIDTH

; Fox/TQA

dindex	equ $57

	ldx dindex
	lda adr.tmccn,x
	ldy adr.tmrcn,x
	ldx #0
	cmp #<320
	sne:inx

; X:A = horizontal resolution
; Y = vertical resolution

	@SCREENSIZE

	.ifdef MAIN.@DEFINES.ROMOFF
	dec portb
	.endif

	pla:tax
};

 VideoRam:=savmsc;

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

;	lda #@IDput		; slower
;	jsr @COMMAND

	ldx @COMMAND.scrchn	; faster
	lda @COMMAND.colscr

	m@call	@putchar.main

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

;	lda #@IDput		; slower
;	jsr @COMMAND

	ldx @COMMAND.scrchn	; faster
	lda @COMMAND.colscr

	m@call	@putchar.main

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

 Result:=pointer(a + VideoRam);

end;


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


{$i vbxe.inc}
{$i graph.inc}

end.
