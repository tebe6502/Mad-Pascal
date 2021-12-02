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


end.
