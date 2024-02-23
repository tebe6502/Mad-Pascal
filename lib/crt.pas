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

{$IFDEF C64}

  BLACK                 = $0;
  WHITE                 = $1;
  RED                   = $2;
  CYAN                  = $3;
  PURPLE                = $4;
  GREEN                 = $5;
  BLUE                  = $6;
  YELLOW                = $7;
  ORANGE                = $8;
  BROWN                 = $9;
  LIGHT_RED             = $A;
  DARK_GREY             = $B;
  GREY                  = $C;
  LIGHT_GREEN           = $D;
  LIGHT_BLUE            = $E;
  LIGHT_GREY            = $F;

{$ENDIF}


{$IFDEF C4P}

  BLACK                 = $0;
  WHITE                 = $1;
  RED                   = $2;
  CYAN                  = $3;
  PURPLE                = $4;
  GREEN                 = $5;
  BLUE                  = $6;
  YELLOW                = $7;
  ORANGE                = $8;
  BROWN                 = $9;
  YELLOW_GREEN          = $A;
  PINK                  = $B;
  BLUE_GREEN            = $C;
  LIGHT_BLUE            = $D;
  DARK_BLUE             = $E;
  LIGHT_GREEN           = $F;

{$ENDIF}


{$IFDEF ATARI}

  BLACK                 = $00;
  WHITE                 = $0F;
  RED                   = $26;
  CYAN                  = $AC;
  PURPLE                = $48;
  GREEN                 = $B6;
  BLUE                  = $86;
  YELLOW                = $DC;
  ORANGE                = $18;
  BROWN                 = $F4;
  LIGHT_RED             = $2A;
  DARK_GREY             = $04;
  GREY                  = $08;
  LIGHT_GREEN           = $BC;
  LIGHT_BLUE            = $9A;
  LIGHT_GREY            = $0C;

{$ENDIF}


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

{$IFDEF X16}

uses x16;

{$ENDIF}


{$i '../src/targets/crt.inc'}


end.
