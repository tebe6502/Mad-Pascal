unit crt;
(*
@type: unit
@name: screen and keyboard handling unit
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


{$i './targets/crth.inc'}


const

{ CRT modes }
	BW40	= 0;		{ 40x25 B/W on Color Adapter }
	CO40	= 1;		{ 40x25 Color on Color Adapter }
	BW80	= 2;		{ 80x25 B/W on Color Adapter }
	CO80	= 3;		{ 80x25 Color on Color Adapter }
	Mono	= 7;		{ 80x25 on Monochrome Adapter }

{ Mode constants for 3.0 compatibility }
	C40	= CO40;
	C80	= CO80;

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


{$i './targets/crt.inc'}


end.
