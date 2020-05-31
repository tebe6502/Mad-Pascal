unit CRT;
(*
@type: unit
@name: Mad Pascal screen and keyboard handling units
@author: Tomasz Biela (Tebe)

@description:
<http://www.freepascal.org/docs-html/rtl/crt/index-5.html>
*)


{

Consol
ClrEol
ClrScr
CursorOff
CursorOn
Delay
DelLine
GotoXY
InsLine
Keypressed
NoSound
ReadKey
Sound
TextBackground
TextColor
TextMode
WhereX
WhereY

}

interface

var
	TextAttr: byte = 0;			(* @var Text Attribute *)
	Consol: byte absolute $d01f;		// CONSOL register

const
	CN_START_SELECT_OPTION	= 0;		// Consol values
	CN_SELECT_OPTION	= 1;
	CN_START_OPTION		= 2;
	CN_OPTION		= 3;
	CN_START_SELECT		= 4;
	CN_SELECT		= 5;
	CN_START		= 6;
	CN_NONE			= 7;

{ CRT modes }
	BW40	= 0;		{ 40x25 B/W on Color Adapter }
	CO40	= 1;		{ 40x25 Color on Color Adapter }
	BW80	= 2;		{ 80x25 B/W on Color Adapter }
	CO80	= 3;		{ 80x25 Color on Color Adapter }
	Mono	= 7;		{ 80x25 on Monochrome Adapter }

{ Mode constants for 3.0 compatibility }
	C40	= CO40;
	C80	= CO80;

{ Foreground and background color constants }
	Black		= 0;
	Blue		= 1;
	Green		= 2;
	Cyan		= 3;
	Red		= 4;
	Magenta		= 5;
	Brown		= 6;
	LightGray	= 7;

{ Foreground color constants }
	DarkGray	= 8;
	LightBlue	= 9;
	LightGreen	= 10;
	LightCyan	= 11;
	LightRed	= 12;
	LightMagenta	= 13;
	Yellow		= 14;
	White		= 15;

{ Add-in for blinking }
	Blink		= 128;


	procedure ClrEol;
	procedure ClrScr;
	procedure CursorOff;
	procedure CursorOn;
	procedure Delay(count: word); assembler;
	procedure DelLine;
	procedure GotoXY(x: byte; y: byte); assembler;
	procedure InsLine;
	function Keypressed: Boolean; assembler;
	procedure NoSound; assembler;
	function ReadKey: char; assembler;
	procedure Sound(Chan,Freq,Dist,Vol: byte); assembler;
	procedure TextBackground(a: byte); assembler;
	procedure TextColor(a: byte); assembler;
	procedure TextMode(Mode: byte); assembler;
	function WhereX: byte; assembler;
	function WhereY: byte; assembler;


implementation

uses atari;


procedure CursorOff;
(*
@description: Hide cursor
*)
begin

 crsinh:=1;		// znacznik widocznosci kursora

 write( CH_CURS_RIGHT, CH_CURS_LEFT );

end;


procedure CursorOn;
(*
@description: Display cursor
*)
begin

 crsinh:=0;		// znacznik widocznosci kursora

 write( CH_CURS_RIGHT, CH_CURS_LEFT );

end;


procedure ClrScr;
(*
@description: Clear screen
*)
begin
 write( CH_CLR );
end;


procedure DelLine;
(*
@description: Delete line at cursor position
*)
begin
 write( CH_DELLINE );
end;


procedure InsLine;
(*
@description: Insert an empty line at cursor position
*)
begin
 write( CH_INSLINE );
end;


function ReadKey: char; assembler;
(*
@description: Read key from keybuffer

@returns: char
*)
asm
{	txa:pha

	@GetKey

	sta Result

	pla:tax
};
end;


procedure TextBackground(a: byte); assembler;
(*
@description: Set text background

@param: a - color value 0..255
*)
asm
{	mwa a colpf2s
};
end;


procedure TextColor(a: byte); assembler;
(*
@description: Set text color

@param: a - color value 0..255
*)
asm
{	mva a colpf1s
};
end;


procedure Delay(count: word); assembler;
(*
@description: Waits a specified number of milliseconds

@param: count - number of milliseconds
*)
asm
{	txa:pha

	ldx #0
	ldy #0

loop	cpy count
	bne @+
	cpx count+1
	beq stop

@	:8 lda:cmp:req vcount

	iny
	sne
	inx

	bne loop

stop	pla:tax
};
end;


function Keypressed: Boolean; assembler;
(*
@description: Check if there is a keypress in the keybuffer

@returns: TRUE key has been pressed
@returns: FALSE otherwise
*)
asm
{	ldy #$00	; false
	lda kbcodes
	cmp #$ff
	beq skp
	iny		; true

;	sty kbcodes

skp	sty Result
};
end;


procedure GotoXY(x: byte; y: byte); assembler;
(*
@description:
Set cursor position on screen.


GotoXY positions the cursor at (X,Y), X in horizontal, Y in vertical direction relative to

the origin of the current window. The origin is located at (1,1), the upper-left corner of the window.

@param: x - horizontal positions (1..40)
@param: y - vertical positions (1..24)
*)
asm
{	ldy x
	beq @+

	dey

@	sty colcrs
	mvy #$00 colcrs+1

	ldy y
	beq @+

	dey

@	sty rowcrs
};
end;


function WhereX: byte; assembler;
(*
@description: Return X (horizontal) cursor position

@returns: byte (1..40)
*)
asm
{
	ldy colcrs
	iny
	sty Result
};
end;


function WhereY: byte; assembler;
(*
@description: Return Y (vertical) cursor position

@returns: byte (1..24)
*)
asm
{
	ldy rowcrs
	iny
	sty Result
};
end;


procedure ClrEol;
(*
@description:
ClrEol clears the current line, starting from the cursor position, to the end of the window.

The cursor doesn't move.
*)
begin
 FillChar( pointer(word(DPeek(88)+WhereX)+WhereY*40-41), byte(41-byte(WhereX)), 0);
end;


procedure NoSound; assembler;
(*
@description: Reset POKEY
*)
asm
{	lda #0
	sta $d208
	sta $d218

	ldy #3
	sty $d20f
	sty $d21f

	ldy #8
lp	sta $d200,y
	sta $d210,y
	dey
	bpl lp
};
end;


procedure Sound(Chan,Freq,Dist,Vol: byte); assembler;
(*
@description: Plays sound

@param: Chan - channel (0..3) primary POKEY, (4..7) secondary POKEY
@param: Freq - frequency (0..255)
@param: Dist - distortion (0,2,4,6,8,10,12,14)
@param: Vol - volume (0..15)
*)
//----------------------------------------------------------------------------------------------
// Chan = 0..3 primary Pokey
// Chan = 4..7 secondary Pokey
//----------------------------------------------------------------------------------------------
asm
{	lda Chan
	and #7

	ldy #$10
	cmp #4
	scs
	ldy #$00
	sty npokey

	and #3

	asl @
	add #0
npokey	equ *-1
	tay

	lda #$00
	sta audctl
	lda #$03
	sta skctl

	lda Freq
	sta audf1,y

	lda Vol
	and #$0F
	sta _t

	lda Dist	; -> bit 7-6-5
	:4 asl @
	ora #0
_t	equ *-1
	sta audc1,y
};
end;


procedure TextMode(Mode: byte); assembler;
(*
@description: Reset E: device

@param: Mode - unused value
*)
asm
{	txa:pha

	@clrscr

	pla:tax
};
end;

end.
