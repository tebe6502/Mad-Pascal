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

{$IFDEF ATARI}
var
	TextAttr: byte = 0;			(* @var Text Attribute *)
	Consol: byte absolute $d01f;		// CONSOL register
{$ENDIF}

const
{$IFDEF ATARI}
	CN_START_SELECT_OPTION	= 0;		// Consol values
	CN_SELECT_OPTION	= 1;
	CN_START_OPTION		= 2;
	CN_OPTION		= 3;
	CN_START_SELECT		= 4;
	CN_SELECT		= 5;
	CN_START		= 6;
	CN_NONE			= 7;
{$ENDIF}

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
	procedure ClrScr;                                                                          //platform dependent
	procedure CursorOff;
	procedure CursorOn;
	procedure Delay(count: word); assembler;
	procedure DelLine;
	procedure GotoXY(x,y: byte); assembler;                                                    //platform dependent
	procedure InsLine;
	function Keypressed: Boolean; assembler;                                                   //platform dependent
	procedure NoSound; assembler;
	function ReadKey: char; assembler;                                                         //platform dependent
	procedure Sound(Chan,Freq,Dist,Vol: byte); assembler;
	procedure TextBackground(a: byte); assembler;
	procedure TextColor(a: byte); assembler;
	procedure TextMode(Mode: byte); assembler;
	function WhereX: byte; assembler;                                                          //platform dependent
	function WhereY: byte; assembler;                                                          //platform dependent


implementation

{$IFDEF ATARI}

uses atari;

{$ENDIF}



{$i '../src/targets/crt.inc'}


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
